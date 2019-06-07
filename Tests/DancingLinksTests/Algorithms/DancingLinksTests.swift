import XCTest
@testable import DancingLinks


fileprivate struct MockRow: GridRow {
    
    let row: Int
    
    let columns: [Int]
    
}

fileprivate struct MockGrid: Grid, IteratorProtocol {
    
    let rows: Int
    
    let columns = 5
    
    var i = 0
    
    mutating func next() -> MockRow? {
        guard i < rows else { return nil }
        
        defer { i += 1 }
        return MockRow(row: i, columns: Array(0 ... i))
    }
    
}


/**
 Mock algorithm returning a solution for each grid row read.
 Each solution contains all the rows in input order.
 */
fileprivate struct MockDancingLinks: DancingLinks {
    
    func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.Element.Id {
        let state = SearchState()
        let rows = grid.map { $0.row }
        
        for _ in rows {
            guard !state.terminated else { return }
            
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
    
    private var grid: MockGrid { MockGrid(rows: 5) }
    
    // MARK: Testing

    func testSolveEmptyGenerator() {
        XCTAssertNil(dlx.solve(grid: MockGrid(rows: 0)))
        XCTAssertEqual(dlx.solve(grid: MockGrid(rows: 0)).count, 0)
    }
    
    func testSolveFirst() {
        guard let solution = dlx.solve(grid: grid) else { return XCTFail("Nil solution") }
        
        XCTAssertEqual(solution.rows.count, 5)
        XCTAssertEqual(solution.rows[0], 0)
        for (i, row) in solution.rows.enumerated() {
            XCTAssertEqual(row, i)
        }
    }
    
    func testSolveNegativeLimit() {
        XCTAssertEqual(dlx.solve(grid: grid, limit: -2).count, 0)
    }
    
    func testSolveNoLimit() {
        let solutions: [Solution<Int>] = dlx.solve(grid: grid)
        
        XCTAssertEqual(solutions.count, 5)
        for (_, solution) in solutions.enumerated() {
            XCTAssertEqual(solution.rows.count, 5)
            for (j, row) in solution.rows.enumerated() {
                XCTAssertEqual(row, j)
            }
        }
    }
    
    func testSolvePositiveLimit() {
        let solutions: [Solution<Int>] = dlx.solve(grid: grid, limit: 3)
        
        XCTAssertEqual(solutions.count, 3)
        for (_, solution) in solutions.enumerated() {
            XCTAssertEqual(solution.rows.count, 5)
            for (j, row) in solution.rows.enumerated() {
                XCTAssertEqual(row, j)
            }
        }
    }
    
    func testSolveZeroLimit() {
        XCTAssertEqual(dlx.solve(grid: grid, limit: 0).count, 0)
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
