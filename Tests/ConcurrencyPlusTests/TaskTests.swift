import XCTest
import ConcurrencyPlus

extension String: Error {
}

final class TaskTests: XCTestCase {
	func testRelayValueErrorPair() async throws {
		let successClosure: (Int?, Error?) -> Void = {
			XCTAssertEqual($0, 42)
			XCTAssertNil($1)
		}

		let t1 = Task.relayResult(to: successClosure) {
			return 42
		}

		let _ = try await t1.value

		let failureClosure: (Int?, Error?) -> Void = {
			XCTAssertNil($0)
			XCTAssertNotNil($1)
		}

		let t2 = Task.relayResult(to: failureClosure) {
			throw "boo"
		}

		do {
			let _ = try await t2.value

			XCTFail()
		} catch {
		}
	}
}
