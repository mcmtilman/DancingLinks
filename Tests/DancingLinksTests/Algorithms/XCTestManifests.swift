import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BitSetTests.allTests),
        testCase(BitSetPerformanceTests.allTests),
        testCase(DancingLinksTests.allTests),
    ]
}
#endif
