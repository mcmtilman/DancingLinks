//
//  NQueensSolverTests.swift
//
//  Created by Michel Tilman on 18/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests solving the N-Queens probleem.
 */
class NQueensSolverTests: XCTestCase {

    // Tests solving the N-Queens problem for a regular chessboard using ClassyDancingLinks.
    func testSolveClassyEightQueens() {
        guard let eightQueens = NQueens(number: 8) else { return XCTFail("Nil 8-Queens problem") }
        
        let expected = [(0, 0), (1, 4), (2, 7), (3, 5), (6, 1), (4, 2), (5, 6), (7, 3)].map(Square.init)
        let solutions = NQueensSolver.solve(nQueens: eightQueens, algorithm: .classy, limit: 1)
        
        XCTAssertEqual(solutions.first, expected)
    }
    
   // Tests solving the N-Queens problem for a regular chessboard using StructuredDancingLinks.
    func testSolveStructuredEightQueens() {
        guard let eightQueens = NQueens(number: 8) else { return XCTFail("Nil 8-Queens problem") }
        
        let expected = [(0, 0), (1, 4), (2, 7), (3, 5), (6, 1), (4, 2), (5, 6), (7, 3)].map(Square.init)
        let solutions = NQueensSolver.solve(nQueens: eightQueens, limit: 1)

        XCTAssertEqual(solutions.first, expected)
    }
    
    // Tests solving the N-Queens problem for a large 60 by 60 chessboard using StructuredDancingLinks.
    // The time for 63 queens is still acceptable for the unit tests, but jumps to 42 seconds for 64 queens.
    func testSolveManyQueens() {
        let number = 60
        guard let manyQueens = NQueens(number: number) else { return XCTFail("Nil \(number)-Queens problem") }
        guard let solution = NQueensSolver.solve(nQueens: manyQueens, limit: 1).first else { return XCTFail("Nil solution for \(number)-Queens problem") }

        XCTAssertEqual(solution.count, number)
        XCTAssertEqual(Set(solution).count, number)
        XCTAssertEqual(Set(solution.map { $0.rank }).count, number)
        XCTAssertEqual(Set(solution.map { $0.file }).count, number)
        XCTAssertEqual(Set(solution.map { $0.rank + $0.file }).count, number)
        XCTAssertEqual(Set(solution.map { $0.rank - $0.file }).count, number)
    }
    
    // Tests finding all solutions to the N-Queens problem for N in 1 ... 10.
    // Verifies:
    // * the number of solutions (cf. Wikipedia),
    // * that each solution is unique,
    // * that each solution has N different squares,
    // * that the squares of each solution have different ranks,
    // * that the squares of each solution have different files,
    // * that the squares of each solution have different diagonals,
    // * that the squares of each solution have different reverse diagonals.
    func testNQueensSolveAll() {
        let cases = [(1, 1), (2, 0), (3, 0), (4, 2), (5, 10), (6, 4), (7, 40), (8, 92), (9, 352), (10, 724)]
        
        for (number, count) in cases {
            guard let nQueens = NQueens(number: number) else { XCTFail("Nil \(number)-Queens problem"); continue }
            let solutions = NQueensSolver.solve(nQueens: nQueens)
            
            XCTAssertEqual(solutions.count, count)
            XCTAssertEqual(Set(solutions).count, count)
            for solution in solutions {
                XCTAssertEqual(solution.count, number)
                XCTAssertEqual(Set(solution).count, number)
                XCTAssertEqual(Set(solution.map { $0.rank }).count, number)
                XCTAssertEqual(Set(solution.map { $0.file }).count, number)
                XCTAssertEqual(Set(solution.map { $0.rank + $0.file }).count, number)
                XCTAssertEqual(Set(solution.map { $0.rank - $0.file }).count, number)
            }
        }
    }
    
}
