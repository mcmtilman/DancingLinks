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
            XCTAssertEqual(id.index, i)
            XCTAssertEqual(id.value, givens[i])
            XCTAssertEqual(columns.count, 4)
        }
    }

    // Test if the complete sudoku returns the same number of constraints as the rows.
    func testCompleteConstraints() {
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
        guard let sudoku = Sudoku(string: string) else { return XCTFail("Nil sudoku") }
        
        XCTAssertEqual(sudoku.constraints, 324)
        XCTAssertEqual(Set(collectConstraints(sudoku)).count, 324)
        XCTAssertEqual(collectConstraints(sudoku).count, 324)
    }
    
    // Test if the empty sudoku returns the same number of constraints as the rows.
    func testEmptyConstraints() {
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
        guard let sudoku = Sudoku(string: string) else { return XCTFail("Nil sudoku") }

        XCTAssertEqual(sudoku.constraints, 324)
        XCTAssertEqual(Set(collectConstraints(sudoku)).count, 324)
        XCTAssertEqual(collectConstraints(sudoku).count, 2916)
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
            XCTAssertEqual(id.index, i / 4)
            XCTAssertEqual(id.value, values[i])
            XCTAssertEqual(columns.count, 4)
        }
    }

    // Test solving the evil sudoku using ClassyDancingLinks.
    func testSolveClassyEvilSudoku() {
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
        let evil = Sudoku.evil
        let solution = SudokuSolver().solve(sudoku: evil, algorithm: ClassyDancingLinks())
        
        XCTAssertNotNil(solution)
        XCTAssertEqual(solution, Sudoku(string: string))
    }
    
    // Test solving the evil sudoku using StructuredDancingLinks.
    func testSolveStructuredEvilSudoku() {
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
        let evil = Sudoku.evil
        let solution = SudokuSolver().solve(sudoku: evil)
        
        XCTAssertNotNil(solution)
        XCTAssertEqual(solution, Sudoku(string: string))
    }
    
   // Test if we can solve a large (20x2) sudoku.
    // Leave the top row cells empty.
    func testSolveLargeSudoku() {
        var values = [Int?](repeating: nil, count: 1600)
        
        for row in 1 ..< 40 {
            let start = row < 20 ? row * 2 : (row - 20) * 2 + 1
            
            for i in 0 ..< 40 {
                values[row * 40 + i] = (start + i) % 40 + 1
            }
        }

        guard let sudoku = Sudoku(values: values, rows: 20, columns: 2) else { return XCTFail("Nil sudoku") }
        guard let solution = SudokuSolver().solve(sudoku: sudoku) else { return XCTFail("Nil solution") }
        
        for i in 0 ..< 40 {
            XCTAssertNil(sudoku[i])
            XCTAssertEqual(solution[i], i + 1)
        }

        for i in 40 ..< 1600 {
            XCTAssertEqual(solution[i], sudoku[i])
        }
   }
    
    private func gridRows(_ sudoku: Sudoku) -> [(id: Cell, columns: [Int])] {
        var rows = [(id: Cell, columns: [Int])]()
        
        sudoku.generateRows { (id: Cell, columns: Int...) in rows.append((id: id, columns: columns)) }
        
        return rows
    }
    
    private func collectConstraints(_ sudoku: Sudoku) -> [Int] {
        gridRows(sudoku).reduce([]) { array, row in array + row.columns }
    }
    
}


/**
 For LinuxMain.
 */
extension SudokuSolverTests {
    
    static var allTests = [
        ("testCompleteGrid", testCompleteGrid),
        ("testCompleteConstraints", testCompleteConstraints),
        ("testEmptyConstraints", testEmptyConstraints),
        ("testEmptyGrid", testEmptyGrid),
        ("testSolveClassyEvilSudoku", testSolveClassyEvilSudoku),
        ("testSolveStructuredEvilSudoku", testSolveStructuredEvilSudoku),
        ("testSolveLargeSudoku", testSolveLargeSudoku),
    ]

}
