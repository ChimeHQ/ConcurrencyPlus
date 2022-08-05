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

extension CancellingContinuation {
    public func resume(with value: T?, error: Error?) {
        switch (value, error) {
        case (let value?, nil):
            resume(returning: value)
        case (_, let error?):
            resume(throwing: error)
        case (nil, nil):
            resume(throwing: CancellingContinuationError.missingBothValueAndError)
        }
    }
}

extension CheckedContinuation where E == Error {
    public func resume(with value: T?, error: Error?) {
        switch (value, error) {
        case (let value?, nil):
            resume(returning: value)
        case (_, let error?):
            resume(throwing: error)
        case (nil, nil):
            resume(throwing: ConnectionContinuationError.missingBothValueAndError)
        }
    }

    public var resumingHandler: (T?, Error?) -> Void {
        return {
            self.resume(with: $0, error: $1)
        }
    }
}

extension CheckedContinuation where T == Void, E == Error {
    public var resumingHandler: (Error?) -> Void {
        return {
            resume(with: $0)
        }
    }
}

