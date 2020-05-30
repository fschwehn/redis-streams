import XCTest

import redis_streamsTests

var tests = [XCTestCaseEntry]()
tests += redis_streamsTests.allTests()
XCTMain(tests)
