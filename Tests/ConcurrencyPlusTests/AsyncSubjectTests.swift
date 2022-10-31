import XCTest
import ConcurrencyPlus

enum TestError: Error {
	case boom
}

final class AsyncSubjectTests: XCTestCase {
	func testThing() async {
		let subject = AsyncSubject<Int>()

		Task {
			subject.send(1)
			subject.send(2)
			subject.send(3)
			subject.finish()
		}

		var values = [Int]()

		for await value in subject {
			values.append(value)
		}

		XCTAssertEqual(values, [1, 2, 3])
	}

	func testAddValues() async {
		let subject = AsyncSubject<Int>()

		var events = subject.makeAsyncIterator()

		Task {
			subject.send(1)
			subject.send(2)
			subject.send(3)
		}

		let value1 = await events.next()
		XCTAssertEqual(value1, 1)

		let value2 = await events.next()
		XCTAssertEqual(value2, 2)

		let value3 = await events.next()
		XCTAssertEqual(value3, 3)
	}

	func testTerminateStreamWithFailure() async {
		let subject = AsyncThrowingSubject<Int>()

		var events = subject.makeAsyncIterator()

		Task {
			subject.send(1)
			subject.send(.failure(TestError.boom))
			subject.send(3)
		}

		let value1 = try? await events.next()
		XCTAssertEqual(value1, 1)

		do {
			_ = try await events.next()

			XCTFail()
		} catch {
			XCTAssertTrue(true)
		}

		let value3 = try? await events.next()
		XCTAssertNil(value3)
	}

	func testTerminateStreamWithError() async {
		let subject = AsyncThrowingSubject<Int>()

		var events = subject.makeAsyncIterator()

		Task {
			subject.send(1)
			subject.finish(throwing: TestError.boom)
			subject.send(3)
		}

		let value1 = try? await events.next()
		XCTAssertEqual(value1, 1)

		do {
			_ = try await events.next()

			XCTFail()
		} catch {
			XCTAssertTrue(true)
		}

		let value3 = try? await events.next()
		XCTAssertNil(value3)

	}
}
