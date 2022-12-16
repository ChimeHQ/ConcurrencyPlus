import Foundation

/// An sequence that you can add values to using a function call.
///
/// This type can make it a lot easier to adapt non-async code to sequences.
@available(*, deprecated, message: "Please see the project README for alternative libraires that provide this functionality")
public struct AsyncThrowingSubject<Element>: AsyncSequence {
	typealias Stream = AsyncThrowingStream<Element, Error>

	private let stream: Stream
	private let continuation: Stream.Continuation

	public init() {
		var innerContinuation: Stream.Continuation!

		self.stream = Stream {
			innerContinuation = $0
		}

		self.continuation = innerContinuation
	}

	/// Add results to the sequence
	public func send(_ result: Result<Element, Error>) {
		continuation.yield(with: result)
	}

	/// Add values to the sequence
	public func send(_ element: Element) {
		continuation.yield(element)
	}

	public func finish(throwing error: Error? = nil) {
		continuation.finish(throwing: error)
	}

	public struct Iterator: AsyncIteratorProtocol {
		var streamIterator: Stream.AsyncIterator

		init(stream: Stream) {
			self.streamIterator = stream.makeAsyncIterator()
		}

		public mutating func next() async throws -> Element? {
			return try await streamIterator.next()
		}
	}

	public func makeAsyncIterator() -> Iterator {
		return Iterator(stream: stream)
	}
}

extension AsyncThrowingSubject: Sendable where Element: Sendable {
}
