import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(BitSetTests.allTests),
        testCase(BitSetPerformanceTests.allTests),
        testCase(DancingLinksTests.allTests),
        testCase(SudokuTests.allTests)
    ]
}
#endif
