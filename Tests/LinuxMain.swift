import XCTest

import DancingLinksTests

var tests = [XCTestCaseEntry]()

tests += BitSetTests.allTests()
tests += BitSetPerformanceTests.allTests()
tests += DancingLinksTests.allTests()
tests += NQueensSolverTests.allTests()
tests += SudokuTests.allTests()
tests += SudokuSolverTests.allTests()
tests += SudokuSolverPerformanceTests.allTests()

XCTMain(tests)
