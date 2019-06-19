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

    // Test solving the N-Queens probleem for a regular chessboard using ClassyDancingLinks.
    func testSolveClassyEightQueens() {
        let eightQueens = NQueens(number: 8)
        
        guard let rows = NQueensSolver().solve(nQueens: eightQueens, algorithm: ClassyDancingLinks()) else { return XCTFail("Nil solution") }
        
        XCTAssertEqual(rows, [0, 12, 23, 29, 49, 34, 46, 59])
    }
    
   // Test solving the N-Queens probleem for a regular chessboard using StructuredDancingLinks.
    func testSolveStructuredEightQueens() {
        let eightQueens = NQueens(number: 8)
        
        guard let rows = NQueensSolver().solve(nQueens: eightQueens) else { return XCTFail("Nil solution") }
        
        XCTAssertEqual(rows, [0, 12, 23, 29, 49, 34, 46, 59])
    }
    
}


/**
 For LinuxMain.
 */
extension NQueensSolverTests {
    
    static var allTests = [
        ("testSolveClassyEightQueens", testSolveClassyEightQueens),
        ("testSolveStructuredEightQueens", testSolveStructuredEightQueens),
    ]
    
}
