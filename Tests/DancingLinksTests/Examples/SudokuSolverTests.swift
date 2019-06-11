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
        let rows = gridRows(sudoku)
        let givens = [1,2,3,4,3,4,1,2,2,1,4,3,4,3,2,1]
        
        XCTAssertEqual(sudoku.constraints, 64)
        XCTAssertEqual(rows.count, 16)
        for (i, (id, columns)) in zip(0 ..< 16, rows) {
            XCTAssertEqual(id.cell, i)
            XCTAssertEqual(id.value, givens[i])
            XCTAssertEqual(columns.count, 4)
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
        let rows = gridRows(sudoku)
        let values = (0 ..< 16).map { _ in [1, 2, 3, 4] }.flatMap { $0 }

        XCTAssertEqual(sudoku.constraints, 64)
        XCTAssertEqual(rows.count, 64)
        for (i, (id, columns)) in zip(0 ..< 64, rows) {
            XCTAssertEqual(id.cell, i / 4)
            XCTAssertEqual(id.value, values[i])
            XCTAssertEqual(columns.count, 4)
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
    
    private func gridRows(_ sudoku: Sudoku) -> [(id: CellValue, columns: [Int])] {
        var rows = [(id: CellValue, columns: [Int])]()
        
        sudoku.generateRows { (id: CellValue, columns: Int...) in rows.append((id: id, columns: columns)) }
        
        return rows
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
