import Foundation

public final class TaskQueue: @unchecked Sendable {
    public static let global = TaskQueue()

    public typealias WorkItem = @Sendable () async -> Void

    private struct TaskDetails: Sendable {
        let item: WorkItem
        let priority: TaskPriority?
    }

    private let lock: NSLock
    private var queue: [TaskDetails]

    public init() {
        self.lock = NSLock()
        self.queue = []

        lock.name = "com.chimehq.AsyncQueue"
    }

    public func addOperation(priority: TaskPriority? = nil, operation: @escaping WorkItem) {
        let details = TaskDetails(item: operation, priority: priority)

        lock.lock()

        let empty = queue.isEmpty

        if empty == false {
            queue.append(details)
        }

        lock.unlock()

        if empty {
            execute(details)
        }
    }

    var effectivePriority: TaskPriority? {
        // try to pass back a nil if we can, to avoid assuming that nil -> .medium

        let explicitPriorities = queue.compactMap({ $0.priority })

        guard let maxPriority = explicitPriorities.max() else {
            return nil
        }

        // no unspecified priorities
        if explicitPriorities.count == queue.count {
            return maxPriority
        }

        // we have items enqueued with no specified
        return max(maxPriority, .medium)
    }

    private func dequeueNextItem() -> TaskDetails? {
        guard queue.isEmpty == false else { return nil }

        let priority = effectivePriority
        let details = queue.removeFirst()

        return TaskDetails(item: details.item, priority: priority)
    }

    private func execute(_ details: TaskDetails) {
        Task.detached(priority: details.priority) {
            await details.item()

            self.executeNextItem()
        }
    }

    private func executeNextItem() {
        lock.lock()

        let details = dequeueNextItem()

        lock.unlock()

        if let details {
            execute(details)
        }
    }
}

extension Task where Success == Void, Failure == Never {
    public static func ordered(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Void) {
        TaskQueue.global.addOperation(priority: priority, operation: operation)
    }
}
