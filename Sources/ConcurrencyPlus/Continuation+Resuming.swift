import Foundation

extension CheckedContinuation where T == Void {
    public func resume(with error: E?) {
        if let error = error {
            resume(throwing: error)
        } else {
            resume()
        }
    }
}

extension CancellingContinuation where T == Void {
    public func resume(with error: Error?) {
        if let error = error {
            resume(throwing: error)
        } else {
            resume()
        }
    }
}
