import Foundation

public extension MainActor {
	/// Execute the given body closure on the main actor without enforcing MainActor isolation.
	///
	/// This function exists to work around libraries with incorrect/inconsistent concurrency annotations. You should be **extremely** careful when using it, and only as a last resort.
	///
	/// It will crash if run on any non-main thread.
	@MainActor(unsafe)
	static func runUnsafely<T>(_ body: @MainActor () throws -> T) rethrows -> T {
		dispatchPrecondition(condition: .onQueue(.main))

		return try body()
	}
}
