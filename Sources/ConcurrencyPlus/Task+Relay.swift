import Foundation

public extension Task where Failure == Error {
    /// Relay the result of a Task to a function when complete.
    ///
    /// This function behaves just like Task.init(priority:,operation:), but will
    /// invoke the supplied function `block` with the result of the Task when complete.
    @discardableResult
    static func relayResult(priority: TaskPriority? = nil, to block: @escaping (Success?, Failure?) -> Void, operation: @escaping @Sendable () async throws -> Success) -> Self {
        return Task(priority: priority) {
            do {
                let value = try await operation()

                block(value, nil)

                return value
            } catch {
                block(nil, error)

                throw error
            }
        }
    }

    /// Relay the result of a Task to a function when complete.
    ///
    /// This function behaves just like Task.init(priority:,operation:), but will
    /// invoke the supplied function `block` with the result of the Task when complete.
    @discardableResult
    static func relayResult(priority: TaskPriority? = nil, to block: @escaping (Result<Success, Failure>) -> Void, operation: @escaping @Sendable () async throws -> Success) -> Self {
        return Task(priority: priority) {
            do {
                let value = try await operation()

                block(.success(value))

                return value
            } catch {
                block(.failure(error))

                throw error
            }
        }
    }
}

public extension Task where Success == (), Failure == Error {
    /// Relay the result of a Task to a function when complete.
    ///
    /// This function behaves just like Task.init(priority:,operation:), but will
    /// invoke the supplied function `block` with the result of the Task when complete.
    @discardableResult
    static func relayResult(priority: TaskPriority? = nil, to block: @escaping (Failure?) -> Void, operation: @escaping @Sendable () async throws -> Success) -> Self {
        return Task(priority: priority) {
            do {
                try await operation()

                block(nil)
            } catch {
                block(error)

                throw error
            }
        }
    }
}
