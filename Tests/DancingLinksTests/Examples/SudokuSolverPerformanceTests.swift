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
    
    // Test solving the evil sudoku using ClassyDancingLinks.
    func testSolveClassyEvilSudoku() {
        let evil = Sudoku.evil
        let algorithm = ClassyDancingLinks()
        
        measure {
            for _ in 1 ... 10 {
                _ = SudokuSolver().solve(sudoku: evil, algorithm: algorithm)
            }
        }
    }
    
    // Test solving the evil sudoku using StructuredDancingLinks.
    func testSolveStructuredEvilSudoku() {
        let evil = Sudoku.evil
        
        measure {
            for _ in 1 ... 10 {
                _ = SudokuSolver().solve(sudoku: evil)
            }
        }
    }
    
    // Test solving the evil sudoku using ClassyDancingLinks.
    func testGenerateSolution() {
        let string = """
            .........
            .........
            .........
            .........
            .........
            .........
            .........
            .........
            .........
            """
        guard let empty = Sudoku(string: string) else { return XCTFail("Nil sudoku") }

        measure {
            for _ in 1 ... 10 {
                _ = SudokuSolver().solve(sudoku: empty)
            }
        }
    }
    
}


/**
 For LinuxMain.
 */
extension SudokuSolverPerformanceTests {
    
    static var allTests = [
        ("testSolveClassyEvilSudoku", testSolveClassyEvilSudoku),
        ("testSolveStructuredEvilSudoku", testSolveStructuredEvilSudoku),
        ("testGenerateSolution", testGenerateSolution),
    ]
    
}
