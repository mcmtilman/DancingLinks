import XCTest

import DancingLinksTests

var tests = [XCTestCaseEntry]()

tests += BitSetTests.allTests()
tests += BitSetPerformanceTests.allTests()
tests += DancingLinksTests.allTests()
tests += SudokuTests.allTests()

XCTMain(tests)
