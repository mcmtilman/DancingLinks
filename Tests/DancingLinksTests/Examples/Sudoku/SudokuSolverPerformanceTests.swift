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
    
    // Test solving and validating the evil sudoku using ClassyDancingLinks.
    func testSolveClassyEvilSudoku() {
        let evil = Sudoku.evil
        let algorithm = ClassyDancingLinks()
        
        measure {
            for _ in 1 ... 10 {
                guard SudokuSolver().solve(sudoku: evil, algorithm: algorithm) != nil else { return XCTFail("nil solution") }
            }
        }
    }
    
    // Test solving the evil sudoku using ClassyDancingLinks.
    func testSolveAndValidateClassyEvilSudoku() {
        let evil = Sudoku.evil
        let algorithm = ClassyDancingLinks()
        
        measure {
            for _ in 1 ... 10 {
                guard let sudoku = SudokuSolver().solve(sudoku: evil, algorithm: algorithm), sudoku.isComplete() else { return XCTFail("nil or invalid solution") }
            }
        }
    }
    
    // Test solving the evil sudoku using StructuredDancingLinks.
    func testSolveStructuredEvilSudoku() {
        let evil = Sudoku.evil
        
        measure {
            for _ in 1 ... 10 {
                guard SudokuSolver().solve(sudoku: evil) != nil else { return XCTFail("nil solution") }
            }
        }
    }
    
    // Test solving and validating the evil sudoku using StructuredDancingLinks.
    func testSolveAndValidateStructuredEvilSudoku() {
        let evil = Sudoku.evil
        
        measure {
            for _ in 1 ... 10 {
                guard let sudoku = SudokuSolver().solve(sudoku: evil), sudoku.isComplete() else { return XCTFail("nil or invalid solution") }
            }
        }
    }
    
    // Test solving the evil sudoku using StructuredDancingLinks.
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
                guard SudokuSolver().solve(sudoku: empty) != nil else { return XCTFail("nil solution") }
            }
        }
    }
    
    // Test solving and validating the evil sudoku using StructuredDancingLinks.
    func testGenerateAndValidateSolution() {
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
                guard let sudoku = SudokuSolver().solve(sudoku: empty), sudoku.isComplete() else { return XCTFail("nil or invalid solution") }
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
        ("testSolveAndValidateClassyEvilSudoku", testSolveAndValidateClassyEvilSudoku),
        ("testSolveStructuredEvilSudoku", testSolveStructuredEvilSudoku),
        ("testSolveAndValidateStructuredEvilSudoku", testSolveAndValidateStructuredEvilSudoku),
        ("testGenerateSolution", testGenerateSolution),
        ("testGenerateAndValidateSolution", testGenerateAndValidateSolution),
    ]
    
}
