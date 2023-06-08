import Foundation

/// A very thin wrapper around `DispatchQueue` with relaxed `Sendable` checks
public struct RelaxedDispatchQueue {
	public let internalQueue: DispatchQueue

	public init(label: String,
				qos: DispatchQoS = .unspecified,
				attributes: DispatchQueue.Attributes = [],
				autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit,
				target: DispatchQueue? = nil) {
		self.internalQueue = DispatchQueue(label: label,
										   qos: qos,
										   attributes: attributes,
										   autoreleaseFrequency: autoreleaseFrequency,
										   target: target)
	}

	public init(_ queue: DispatchQueue) {
		self.internalQueue = queue
	}

	/// Identical semantics to `DispatchQueue.asyncUnsafe()`.
	public func async(_ block: @escaping () -> Void) {
#if compiler(>=5.9)
		if #available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *) {
			internalQueue.asyncUnsafe(execute: block)
		} else {
			internalQueue.async(execute: block)
		}
#else
		internalQueue.async(execute: block)
#endif
	}

	public func sync<T>(_ block: @escaping () throws -> T) rethrows -> T {
		return try internalQueue.sync(execute: block)
	}
}

