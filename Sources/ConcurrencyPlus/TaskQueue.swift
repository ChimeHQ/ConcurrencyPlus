import Foundation

/// A serial queue that executes async tasks in the order they were submitted.
public final class TaskQueue: @unchecked Sendable {
    public static let global = TaskQueue()

    public typealias WorkItem = @Sendable () async -> Void

    private let lock: NSLock
    public let priority: TaskPriority?
    private var queue: [WorkItem]

    public init(priority: TaskPriority? = nil) {
        self.lock = NSLock()
        self.queue = []
        self.priority = priority

        lock.name = "com.chimehq.AsyncQueue"
    }

    public func addOperation(operation: @escaping WorkItem) {
        lock.lock()

        let empty = queue.isEmpty

        if empty == false {
            queue.append(operation)
        }

        lock.unlock()

        if empty {
            execute(operation)
        }
    }

    private func dequeueNextItem() -> WorkItem? {
        guard queue.isEmpty == false else { return nil }

        return queue.removeFirst()
    }

    private func execute(_ item: @escaping WorkItem) {
        Task.detached(priority: priority) {
            await item()

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
    public static func ordered(operation: @escaping @Sendable () async -> Void) {
        TaskQueue.global.addOperation(operation: operation)
    }
}
