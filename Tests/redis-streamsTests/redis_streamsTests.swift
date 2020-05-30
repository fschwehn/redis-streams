import XCTest
@testable import redis_streams

final class redis_streamsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(redis_streams().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
