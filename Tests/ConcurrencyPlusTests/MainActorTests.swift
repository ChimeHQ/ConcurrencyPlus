import XCTest
@testable import ConcurrencyPlus

final class MainActorTests: XCTestCase {
	func testRunOnMainUnsafely() async throws {
		let t = Task {
			return await MainActor.run {
				return MainActor.runUnsafely {
					// this will crash if not on the main thread
					return 42
				}
			}
		}

		let value = await t.value

		XCTAssertEqual(value, 42)
	}
}
