import XCTest
import ConcurrencyPlus

final class NonSendableType {
	init() {
	}

	func doThing() -> Int {
		return 42
	}
}

final class SendableContainerTests: XCTestCase {
	func testSendableBox() async {
		let nonsendable = NonSendableType()
		let container = SendableBox(nonsendable)

		let task = Task {
			container.value.doThing()
		}

		let value = await task.value

		XCTAssertEqual(value, 42)
	}

	func testNonSendableQueue() async {
		let nonsendable = NonSendableType()
		let queue = RelaxedDispatchQueue(label: "abc")

		let value = queue.sync {
			nonsendable.doThing()
		}
	}
}
