import XCTest
@testable import DancingLinks


fileprivate struct TestRow: GridRow {
    
    let row: Int
    
    let columns: [Int]
    
}

fileprivate struct TestGenerator: GridGenerator {
    
    struct TestIterator: IteratorProtocol {
        
        var i = 0
        
        mutating func next() -> TestRow? {
            guard i < 5 else { return nil }
            defer { i += 1 }
            
            return TestRow(row: i, columns: Array(0 ... i))
        }
        
    }
    
    let columns = 5
    
    func makeIterator() -> TestIterator {
        TestIterator()
    }
    
}

fileprivate struct TestDancingLinks: DancingLinks {
    
    func solve<G, R>(generator: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: GridGenerator, R == G.Element.Row {
        let state = SearchState()

        for gridRow in generator where !state.terminated {
            handler(Solution<R>(rows: [gridRow.row]), state)
        }
        
    }
    
}

final class DancingLinksTests: XCTestCase {
    
    private var generator: TestGenerator { TestGenerator() }
    
    private var dlx: TestDancingLinks { TestDancingLinks() }

    func testSolveAll() {
        XCTAssertEqual(dlx.solve(generator: generator).count, 5)
    }

    func testSolveFirst() {
        XCTAssertNotNil(dlx.solve(generator: generator))
    }
    
    func testNegativeLimit() {
        XCTAssertEqual(dlx.solve(generator: generator, limit: -2).count, 0)
    }
    
    func testSolveNone() {
        XCTAssertEqual(dlx.solve(generator: generator, limit: 0).count, 0)
    }
    
    func testSolveSome() {
        XCTAssertEqual(dlx.solve(generator: generator, limit: 3).count, 3)
    }
    
    static var allTests = [
        ("testSolveAll", testSolveAll),
        ("testSolveFirst", testSolveFirst),
        ("testNegativeLimit", testNegativeLimit),
        ("testSolveNone", testSolveNone),
        ("testSolveSome", testSolveSome),
    ]
    
}
