import XCTest
import ConcurrencyPlus

final class TaskQueueTests: XCTestCase {
    func testOrdered() async {
        var tasks = [Task<TimeInterval, Never>]()
        for _ in 0..<1_000 {
            let task = Task.ordered { Date().timeIntervalSince1970 }
            tasks.append(task)
        }

        var array = [TimeInterval]()
        for t in tasks {
            array.append(await t.value)
        }

        XCTAssertEqual(array, array.sorted())
    }

	func testThrowingTask() async {
		let taskA = Task.ordered {
			throw "abc"
		}

		let taskB = Task.ordered {
			return "B"
		}

		do {
			// this should throw
			let _ = try await taskA.value

			XCTFail()
		} catch {
		}

		let value = await taskB.value

		XCTAssertEqual(value, "B")
	}
}
