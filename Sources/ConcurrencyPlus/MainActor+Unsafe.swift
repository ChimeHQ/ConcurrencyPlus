import Foundation

public extension MainActor {
	/// Execute the given body closure on the main actor without enforcing MainActor isolation.
	///
	/// This function exists to work around libraries with incorrect/inconsistent concurrency annotations. You should be **extremely** careful when using it, and only as a last resort.
	///
	/// It will crash if run on any non-main thread.
#if compiler(<5.9)
	@MainActor(unsafe)
	static func runUnsafely<T>(_ body: @MainActor () throws -> T) rethrows -> T {
		dispatchPrecondition(condition: .onQueue(.main))

		return try body()
	}
#else
	@_unavailableFromAsync
	static func runUnsafely<T>(_ body: @MainActor () throws -> T) rethrows -> T {
#if swift(>=5.9)
		if #available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *) {
			return try MainActor.assumeIsolated(body)
		}
#endif

		dispatchPrecondition(condition: .onQueue(.main))
		return try withoutActuallyEscaping(body) { fn in
			try unsafeBitCast(fn, to: (() throws -> T).self)()
		}
	}
#endif
}
