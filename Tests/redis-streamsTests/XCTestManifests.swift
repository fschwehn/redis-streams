import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(redis_streamsTests.allTests),
    ]
}
#endif
