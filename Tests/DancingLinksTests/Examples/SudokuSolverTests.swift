//
//  SudokuSolverTests.swift
//
//  Created by Michel Tilman on 08/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests solving sudokus.
 */
class SudokuSolverTests: XCTestCase {
    
    // Test iterating the grid of a complete sudoku.
    func testCompleteGrid() {
        let string = """
            1234
            3412
            2143
            4321
            """

        guard let sudoku = Sudoku(string: string, rows: 2, columns: 2) else { return XCTFail("Nil sudoku") }
        let grid = SudokuGrid(sudoku: sudoku)
        let givens = [1,2,3,4,3,4,1,2,2,1,4,3,4,3,2,1]
        
        XCTAssertEqual(grid.columns, 64)
        XCTAssertEqual(Array(grid).count, 16)
        for (i, row) in zip(0 ..< 16, grid) {
            XCTAssertEqual(row.id.cell, i)
            XCTAssertEqual(row.id.value, givens[i])
            XCTAssertEqual(row.columns.count, 4)
        }
    }

    // Test iterating the grid of an empty sudoku.
    func testEmptyGrid() {
        let string = """
            ....
            ....
            ....
            ....
            """
        
        guard let sudoku = Sudoku(string: string, rows: 2, columns: 2) else { return XCTFail("Nil sudoku") }
        let grid = SudokuGrid(sudoku: sudoku)
        let values = (0 ..< 16).map { _ in [1, 2, 3, 4] }.flatMap { $0 }
        
        XCTAssertEqual(grid.columns, 64)
        XCTAssertEqual(Array(grid).count, 64)
        for (i, row) in zip(0 ..< 64, grid) {
            XCTAssertEqual(row.id.cell, i / 4)
            XCTAssertEqual(row.id.value, values[i])
            XCTAssertEqual(row.columns.count, 4)
        }
    }
    
    // Test solving the evil sudoku.
    func testSolveEvilSudoku() {
        let string = """
            812753649
            943682175
            675491283
            154237896
            369845721
            287169534
            521974368
            438526917
            796318452
            """
        let evil = Sudokus.evil
        let solution = SudokuSolver().solve(sudoku: evil)
        
        XCTAssertNotNil(solution)
        XCTAssertEqual(solution, Sudoku(string: string))
    }
    
}


/**
 For LinuxMain.
 */
extension SudokuSolverTests {
    
    static var allTests = [
        ("testCompleteGrid", testCompleteGrid),
        ("testEmptyGrid", testEmptyGrid),
        ("testSolveEvilSudoku", testSolveEvilSudoku),
    ]

}
