import XCTest
import ConcurrencyPlus

final class TaskQueueTests: XCTestCase {
    func testOrdered() async {
        var array = [Int]()

        for i in 0..<1000 {
            let task: Task<Int, Never> = Task.ordered { return i }

            array.append(await task.value)
        }

        let sorted = array.sorted()

        XCTAssertEqual(array, sorted)
    }
}
