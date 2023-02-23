import Foundation

/// One-time transfer of ownership across actor boundaries for non-Sendable types.
public final class OwnershipTransferring<NonSendable>: @unchecked Sendable {
	private var value: NonSendable?
	private let lock = NSLock()

	public init(_ value: NonSendable) {
		self.value = value
	}

	deinit {
		// really tempted to use an atomic here
		if value != nil {
			preconditionFailure("deallocating an OwnershipTransferring before a transfer has occurred")
		}
	}

	/// Check to see if the ownership has been transferred
	public var hasOwnershipBeenTransferred: Bool {
		return lock.withLock { value == nil }
	}

	/// Safely assume ownership of the wrapped value.
	public func takeOwnership() -> NonSendable {
		return lock.withLock { unsafeTakeOwnership() }
	}

	/// Assume ownership of the wrapped value without synchronization.
	public func unsafeTakeOwnership() -> NonSendable {
		guard let transferredValue = value else {
			preconditionFailure("Ownership has already been transferred")
		}

		self.value = nil

		return transferredValue
	}
}

public struct SendableBox<NonSendable>: @unchecked Sendable {
	public let value: NonSendable

	public init(_ value: NonSendable) {
		self.value = value
	}
}
