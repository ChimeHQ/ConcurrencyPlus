import Foundation

/// An sequence that you can add values to using a function call.
///
/// This type can make it a lot easier to adapt non-async code to sequences.
@available(*, deprecated, message: "Please see the project README for alternative libraires that provide this functionality")
public struct AsyncSubject<Element>: AsyncSequence {
	typealias Stream = AsyncStream<Element>

	private let stream: Stream
	private let continuation: Stream.Continuation

	public init() {
		var innerContinuation: Stream.Continuation!

		self.stream = Stream {
			innerContinuation = $0
		}

		self.continuation = innerContinuation
	}

	/// Add values to the sequence
	public func send(_ element: Element) {
		continuation.yield(element)
	}

	public func finish() {
		continuation.finish()
	}

	public struct Iterator: AsyncIteratorProtocol {
		var streamIterator: Stream.AsyncIterator

		init(stream: Stream) {
			self.streamIterator = stream.makeAsyncIterator()
		}

		public mutating func next() async -> Element? {
			return await streamIterator.next()
		}
	}

	public func makeAsyncIterator() -> Iterator {
		return Iterator(stream: stream)
	}
}

extension AsyncSubject: Sendable where Element: Sendable {
}
