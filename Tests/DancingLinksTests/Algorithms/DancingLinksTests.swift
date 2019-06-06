import XCTest
@testable import DancingLinks


fileprivate struct MockRow: GridRow {
    
    let row: Int
    
    let columns: [Int]
    
}

fileprivate struct MockGenerator: GridGenerator {
    
    struct TestIterator: IteratorProtocol {
        
        let rows: Int
        
        var i = 0
        
        mutating func next() -> MockRow? {
            guard i < rows else { return nil }
            defer { i += 1 }
            
            return MockRow(row: i, columns: Array(0 ... i))
        }
        
    }
    
    let rows: Int
    
    let columns = 5
    
    func makeIterator() -> TestIterator {
        TestIterator(rows: rows)
    }
    
}


/**
 Mock algorithm returning a solution for each grid row read.
 Each solution contains all the rows in input order.
 */
fileprivate struct MockDancingLinks: DancingLinks {
    
    func solve<G, R>(generator: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: GridGenerator, R == G.Element.Row {
        let state = SearchState()
        let rows = generator.map { $0.row }
        
        for _ in rows where !state.terminated {
            handler(Solution<R>(rows: rows), state)
        }
        
    }
    
}


/**
 Tests convenience solvers.
 */
final class DancingLinksTests: XCTestCase {
    
    // MARK: Covenience properties
    
    private var dlx: MockDancingLinks { MockDancingLinks() }
    
    private var generator: MockGenerator { MockGenerator(rows: 5) }
    
    // MARK: Testing

    func testSolveEmptyGenerator() {
        XCTAssertNil(dlx.solve(generator: MockGenerator(rows: 0)))
        XCTAssertEqual(dlx.solve(generator: MockGenerator(rows: 0)).count, 0)
    }
    
    func testSolveFirst() {
        guard let solution = dlx.solve(generator: generator) else { return XCTFail("Nil solution") }
        
        XCTAssertEqual(solution.rows.count, 5)
        XCTAssertEqual(solution.rows[0], 0)
        for (i, row) in solution.rows.enumerated() {
            XCTAssertEqual(row, i)
        }
    }
    
    func testSolveNegativeLimit() {
        XCTAssertEqual(dlx.solve(generator: generator, limit: -2).count, 0)
    }
    
    func testSolveNoLimit() {
        let solutions: [Solution<Int>] = dlx.solve(generator: generator)
        
        XCTAssertEqual(solutions.count, 5)
        for (_, solution) in solutions.enumerated() {
            XCTAssertEqual(solution.rows.count, 5)
            for (j, row) in solution.rows.enumerated() {
                XCTAssertEqual(row, j)
            }
        }
    }
    
    func testSolvePositiveLimit() {
        let solutions: [Solution<Int>] = dlx.solve(generator: generator, limit: 3)
        
        XCTAssertEqual(solutions.count, 3)
        for (_, solution) in solutions.enumerated() {
            XCTAssertEqual(solution.rows.count, 5)
            for (j, row) in solution.rows.enumerated() {
                XCTAssertEqual(row, j)
            }
        }
    }
    
    func testSolveZeroLimit() {
        XCTAssertEqual(dlx.solve(generator: generator, limit: 0).count, 0)
    }
    
}

/**
 For LinuxMain.
 */
extension DancingLinksTests {
    
    static var allTests = [
        ("testSolveEmptyGenerator", testSolveEmptyGenerator),
        ("testSolveFirst", testSolveFirst),
        ("testSolveNegativeLimit", testSolveNegativeLimit),
        ("testSolveNoLimit",testSolveNoLimit),
        ("testSolvePositiveLimit", testSolvePositiveLimit),
        ("testSolveZeroLimit", testSolveZeroLimit),
    ]

}
