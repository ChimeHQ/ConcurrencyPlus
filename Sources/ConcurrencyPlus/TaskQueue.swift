import Foundation

/// A serial queue that executes async tasks in the order they were submitted.
public final class TaskQueue: @unchecked Sendable {
    public static let global = TaskQueue()

    public typealias WorkItemBlock = @Sendable () async -> Void

    public struct WorkItem: Sendable {
        let work: @Sendable () async -> Void
    }

    private let lock: NSLock
    public let priority: TaskPriority?
    private var queue: [WorkItemBlock]
    private var executing: Bool

    public init(priority: TaskPriority? = nil) {
        self.lock = NSLock()
        self.queue = []
        self.priority = priority
        self.executing = false

        lock.name = "com.chimehq.AsyncQueue"
    }

    public func addOperation(operation: @escaping WorkItemBlock) {
        lock.lock()

        let idle = queue.isEmpty && executing == false

        if idle == false {
            queue.append(operation)
        } else {
            self.executing = true
        }

        lock.unlock()

        if idle {
            execute(operation)
        }
    }

    public func addResultOperation<Success>(operation: @escaping @Sendable () async throws -> Success) async throws -> Success {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Success, Error>) in
            self.addOperation {
                do {
                    let value = try await operation()

                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func allOperationsAreFinished() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<(), Never>) in
            self.addOperation {
                continuation.resume()
            }
        }
    }

    private func dequeueNextItem() -> WorkItemBlock? {
        guard queue.isEmpty == false else { return nil }

        return queue.removeFirst()
    }

    private func execute(_ item: @escaping WorkItemBlock) {
        Task.detached(priority: priority) {
            await item()

            self.executeNextItem()
        }
    }

    private func executeNextItem() {
        lock.lock()

        guard let details = dequeueNextItem() else {
            self.executing = false
            lock.unlock()
            return
        }

        self.executing = true

        lock.unlock()

        execute(details)
    }
}

extension Task where Success == Void, Failure == Never {
    public static func ordered(operation: @escaping @Sendable () async -> Void) {
        TaskQueue.global.addOperation(operation: operation)
    }
}
