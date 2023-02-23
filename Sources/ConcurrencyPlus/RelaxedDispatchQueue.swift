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

	public func async(_ block: @escaping () -> Void) {
		internalQueue.async(execute: block)
	}

	public func sync<T>(_ block: @escaping () throws -> T) rethrows -> T {
		return try internalQueue.sync(execute: block)
	}
}

