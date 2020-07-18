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
        guard let sudoku = Sudoku(string: string) else { return XCTFail("Nil sudoku") }
        let solution = SudokuSolver.solve(sudoku: sudoku)
        
        XCTAssertNotNil(solution)
    }
    
    // Test if sudoku solutions contain all the givens of the original sudokus.
    func testGivens() {
        let sudokus = Self.validSudokus.components(separatedBy: "\n").compactMap { Sudoku.init(string: $0, format: .line) }
        
        for sudoku in sudokus {
            guard let solution = SudokuSolver.solve(sudoku: sudoku) else { return XCTFail("Nil solution") }
            guard solution.isComplete() else { return XCTFail("Incomplete solution") }
            
            XCTAssertTrue(zip(sudoku.values, solution.values).allSatisfy { (v1, v2) in v1 == nil || v1 == v2 })
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
        let solution = SudokuSolver.solve(sudoku: evil, algorithm: .classy)
        
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
        let solution = SudokuSolver.solve(sudoku: evil)
        
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
        guard let solution = SudokuSolver.solve(sudoku: sudoku) else { return XCTFail("Nil solution") }

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
 Sudoku test data.
 */
extension SudokuSolverTests {
        
    static let validSudokus = """
        ..5.1...8.....7.2..2.8..961..6.95......7.21........69.9...7.8.3...1.8.7.......2..
        3.5..8.6........4......5.83.4.6.1.....1........2....7853.1.46..7...6.....1.5.....
        .7.9.6.1...8......39......8.....8.7..3.56....16....9....5.73...6...2.........152.
        .2....3.4....5.6.9..49.....7..4..163...........12..4..67312.9...1...7....5....2..
        ..52..8......1...68...3.912....5...1...........16..5.3..9.8.6..2..1....9463.9..2.
        8.....7.....5...93..74....6..6.3.5.7...6.8.4............48573....3.1..7....3..4.8
        ....245........8.95......1.....47..84.258.1....91.3.2.8..45...72...7..........98.
        .6.8.....1..5.3.....517...2.3.....7..52.96..39.6.......7...5.9.58....32..........
        .2.......5846..........1..3.7...9.282...7..1...8.......46....857...4...6..5....3.
        ...91....32...8.....9......985.....2...63..18.1.........18..6....436.2..2......84
        61.....7.7.8.4.6...........9..........1.9.26..72..6..4....8..3..9.37.4.8.3....1.7
        ...17...5..4....6.7...2..8.1...85473.......12......6....5..3...623..8.4.4...6...7
        .78.6....6.2.5...84..78............5...4..71.5.42...63......2.6.......3....64.85.
        .47..32..1....49...982.....63..1...7.1..69....7.....4.......6.1............3.68..
        ..7....1............45.187.1...9568...86...2..96.2.745.7.8........2.95...8..5....
        254......97.3.16..1...5.9.23..7....5...9..4........1.3........6......51.52..6.3.7
        .7......1.62.417..5..7..62....95.81......6........2.4....59.....34..7.6..5...3.9.
        ...1.5...6...9.....34..8...........8....517..1..3...94.7..1..5...8...4.6.9.563...
        ...3.....9....5.7...8.4.6.9...8.............4.46....32....5.7.6.....2.5..97..6.2.
        .2.....7..31.7....6.7..1.35..279.5.3.9...6.1.....5...7..85................3.829..
        ...57..4.............8.9..3..83....1......9.46...91....3..1..5.9.4.561.8.....34..
        ........2.49..1...51.3.9.8.9.5.6.2..4.8..5........36..384.16....914....6.........
        1.8...34...5.........53.6.1.2.......4...6..5..5.3..72834.........6....12...75....
        ...5.2..3.8.1....7.9.8.3.12.1.25.8.6...........9.....59.....6...53.....182.7.....
        ..1...3..47.12..8968....2.1..67....8.2893...77....4..2.....3...8....9....9.......
        ..48...19...1....8....4.7...72.9......94...57..8....4.....2.1..3.7...285.....3.7.
        9...2.1.5....9..8.4......2.548....3.....1.....63..8....159..3..29.54.............
        .9...752...7.41...8..6..9...........1.5.7...274..6..5.......468.5.....7.4.6....1.
        .1.6.2......78...98.41.....9.5..4.2...2...1..........7.....59..6......7......8..5
        .....7..9.9..2........314........82..8......77.6.....13.2.9.1.4.1.....8...9.6.2..
        .32.4.6....8..9..5...16.8..9.......1.4.5.3.2.6..2..9...1.........64.8..3.......9.
        3.9.6........3....54......2..8...97....82.5.....79...6.72..6..9........449.37....
        2.........1......7..9.3.8....8..392...17....5....24.8...7.5.1..9.........5387....
        2.46..3.85..4.2........7....63.4....8.....2..71.....6..2.....5...18.4....5....8.6
        ....682.....14.......3...6961.....2.2.....53.84...39.....832..1....14......9..48.
        2.6.......9..3.....8.4...936..2.1........34....2.7..18......8.....1...4...19.6.2.
        76.12..4.23..47............1.6....3.47...8.12...9.4...319.8....6.......8.....2...
        .8...49..3.6...1..42.1.8..7.4..1.3...........8..32....1.82...9.6...9.4.......7...
        1...9...2......65...3....9...1..23....5...7..2..938.......25..65......1..793.6...
        .2.....69.1..7....5..4.1...2.....74..9...7......5....1.4...3..6.....6.1.36..1.275
        ....5.6.9..1....5.45.96...7.........5..7.2..42.....9.57.61..392.....3......2...71
        ..........64.....11.96...3...8...2..9..1....6436.....97.139...8.2..8.1.4...2.....
        2.....1....6...978..7..3.2..1.2...8....7.5.......16.....38.2..1.8..61.5.....5..6.
        4.1.6.9..375.92..1..9.15....63......1.73...9.9....4...2............5.1.4....3.26.
        83..5..2.1......4..523...86..1.4...9.2.8....5....1926...5.........6....1.......38
        82..9.....9..1..........4....92.5..635.1.4..26...39..4.3....95.5.........14.5...3
        .74...2198.....67...9........17..5..96.1.2..4..8.9....1......4......9.5758......2
        1.2.9...8..6.7....98..1....32.....8...7.3....8.4.....2...1.743..9...3.26..3.2....
        .8.....6..26...9.4.....3.2....546........2......91.54..6.2.945..5.1...821........
        ..6..1..9........81.....35........86......9..9.52.6.4...861..92.....5...5..94.16.
        """

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
        ("testGenerateSolution", testGenerateSolution),
        ("testGivens", testGivens),
        ("testSolveClassyEvilSudoku", testSolveClassyEvilSudoku),
        ("testSolveStructuredEvilSudoku", testSolveStructuredEvilSudoku),
        ("testSolveLargeSudoku", testSolveLargeSudoku),
    ]

}
