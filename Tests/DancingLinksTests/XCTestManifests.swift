import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(DancingLinksTests.allTests),
        testCase(NQueensSolverTests.allTests),
        testCase(SudokuTests.allTests),
        testCase(SudokuSolverTests.allTests),
        testCase(SudokuSolverPerformanceTests.allTests),
    ]
}
#endif
