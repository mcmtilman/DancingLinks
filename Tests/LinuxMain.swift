import XCTest

import DancingLinksTests

var tests = [XCTestCaseEntry]()

tests += DancingLinksTests.allTests()
tests += NQueensSolverTests.allTests()
tests += SudokuTests.allTests()
tests += SudokuSolverTests.allTests()
tests += SudokuSolverPerformanceTests.allTests()
tests += SudokuGeneratorPerformanceTests.allTests()

XCTMain(tests)
