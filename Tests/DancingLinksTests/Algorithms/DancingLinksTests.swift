//
//  DancingLinksTests.swift
//
//  Created by Michel Tilman on 06/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

// Simple grid of 5 rows and 5 columns.
fileprivate struct MockGrid: Grid {
    
    let rows: Int

    let constraints = 5
    
    let optionalConstraints = 0
    
    func generateRows(consume: (Int, Int...) -> ()) {
        guard rows == 5 else { return }
        
        consume(0, 0)
        consume(1, 0, 1)
        consume(2, 0, 1, 2)
        consume(3, 0, 1, 2, 3)
        consume(4, 0, 1, 2, 3, 4)
    }
    
}


// Mock algorithm returning a solution for each grid row read.
// Each solution contains all the rows in input order.
fileprivate class MockDancingLinks: DancingLinks {
    
    func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId {
        let state = SearchState()
        var rows = [R]()
        
        grid.generateRows { (row: R, constraints: Int...) in rows.append(row) }
        
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
