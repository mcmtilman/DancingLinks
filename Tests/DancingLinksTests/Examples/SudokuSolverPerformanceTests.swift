//
//  SudokuSolverPerformanceTests.swift
//
//  Created by Michel Tilman on 10/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests solving sudokus.
 */
class SudokuSolverPerformanceTests: XCTestCase {
    
    // Test solving the evil sudoku.
    func testSolveEvilSudoku() {
        let evil = Sudokus.evil
        measure {
            for _ in 1 ... 10 {
                _ = SudokuSolver().solve(sudoku: evil)
            }
        }
    }
    
}


/**
 For LinuxMain.
 */
extension SudokuSolverPerformanceTests {
    
    static var allTests = [
        ("testSolveEvilSudoku", testSolveEvilSudoku),
    ]
    
}
