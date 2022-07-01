import Foundation

fileprivate protocol Awaitable: Sendable {
    func waitForCompletion() async
}

extension Task: Awaitable {
    func waitForCompletion() async {
        _ = try? await value
    }
}

/// A serial queue that executes async tasks in the order they were submitted.
public final class TaskQueue: @unchecked Sendable {
    static let global = TaskQueue()

    private let lock: NSLock
    private var lastOperation: (any Awaitable)?

    public init() {
        self.lock = NSLock()

        lock.name = "com.chimehq.TaskQueue"
    }

    /// Submit a throwing operation to the queue.
    @discardableResult
    public func addOperation<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success)
    -> Task<Success, Error> where Success : Sendable {
        lock.lock()
        defer { lock.unlock() }

        let lastOperation = self.lastOperation

        let task = Task.detached(priority: priority) {
            // this await will do the right thing to avoid priority inversion
            await lastOperation?.waitForCompletion()

            return try await operation()
        }

        self.lastOperation = task

        return task
    }

    /// Submit an operation to the queue.
    @discardableResult
    public func addOperation<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success)
    -> Task<Success, Never> where Success : Sendable {
        lock.lock()
        defer { lock.unlock() }

        let lastOperation = self.lastOperation

        let task = Task.detached(priority: priority) {
            // this await will do the right thing to avoid priority inversion
            await lastOperation?.waitForCompletion()

            return await operation()
        }

        self.lastOperation = task

        return task
    }

    public func allOperationsAreFinished() async {
        await addOperation(operation: {}).waitForCompletion()
    }
}

extension Task where Success == Void, Failure == Never {
    /// Submit a throwing operation to the global queue.
    @discardableResult
    public static func ordered<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success)
    -> Task<Success, Error> where Success : Sendable {
        return TaskQueue.global.addOperation(priority: priority, operation: operation)
    }

    /// Submit an operation to the global queue.
    @discardableResult
    public static func ordered<Success>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success)
    -> Task<Success, Never> where Success : Sendable {
        return TaskQueue.global.addOperation(priority: priority, operation: operation)
    }
}
