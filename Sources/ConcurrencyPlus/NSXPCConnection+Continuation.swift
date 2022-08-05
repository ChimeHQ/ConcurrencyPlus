import Foundation

public enum ConnectionContinuationError: Error {
    case serviceTypeMismatch
    case missingBothValueAndError
}

public extension NSXPCConnection {
    /// Create a continuation that is automatically cancelled on connection failure
    func withContinuation<Service, T>(function: String = #function, _ body: (Service, CheckedContinuation<T, Error>) -> Void) async throws -> T {
        return try await withCheckedThrowingContinuation(function: function) { continuation in
            let proxy = self.remoteObjectProxyWithErrorHandler { error in
                continuation.resume(throwing: error)
            }

            guard let service = proxy as? Service else {
                continuation.resume(throwing: ConnectionContinuationError.serviceTypeMismatch)
                return
            }

            body(service, continuation)
        }
    }
}
