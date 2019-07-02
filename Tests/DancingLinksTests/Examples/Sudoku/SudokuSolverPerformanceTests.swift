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
                guard let sudoku = SudokuSolver().solve(sudoku: evil, algorithm: algorithm) else { return XCTFail("Nil solution") }
                guard sudoku.isComplete() else { return XCTFail("Incomplete solution") }
            }
        }
    }
    
    // Test solving and validating the evil sudoku using StructuredDancingLinks.
    func testSolveStructuredEvilSudoku() {
        let evil = Sudoku.evil
        
        measure {
            for _ in 1 ... 10 {
                guard let sudoku = SudokuSolver().solve(sudoku: evil), sudoku.isComplete() else { return XCTFail("Nil") }
                guard sudoku.isComplete() else { return XCTFail("Incomplete solution") }
            }
        }
    }
    
    // Test solving and validating the evil sudoku using StructuredDancingLinksNR.
    func testSolveNonRecursiveStructuredEvilSudoku() {
        let evil = Sudoku.evil
        let algorithm = StructuredDancingLinksNR()
        
        measure {
            for _ in 1 ... 10 {
                guard let sudoku = SudokuSolver().solve(sudoku: evil, algorithm: algorithm) else { return XCTFail("Nil solution") }
                guard sudoku.isComplete() else { return XCTFail("Incomplete solution") }
            }
        }
    }
    
    // Test generating and validating a solution starting from an empty grid.
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
                guard let sudoku = SudokuSolver().solve(sudoku: empty) else { return XCTFail("Nil solution") }
                guard sudoku.isComplete() else { return XCTFail("Incomplete solution") }
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
        ("testSolveNonRecursiveStructuredEvilSudoku", testSolveNonRecursiveStructuredEvilSudoku),
        ("testGenerateSolution", testGenerateSolution),
    ]
    
}
