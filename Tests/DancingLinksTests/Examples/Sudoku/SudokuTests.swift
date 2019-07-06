//
//  SudokuTests.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Known sudokus.
 */
extension Sudoku {
    
    static let evil = Sudoku(values: [
        8, nil, nil, nil, nil, nil, nil, nil, nil,
        nil, nil, 3, 6, nil, nil, nil, nil, nil,
        nil, 7, nil, nil, 9, nil, 2, nil, nil,
        nil, 5, nil, nil, nil, 7, nil, nil, nil,
        nil, nil, nil, nil, 4, 5, 7, nil, nil,
        nil, nil, nil, 1, nil, nil, nil, 3, nil,
        nil, nil, 1, nil, nil, nil, nil, 6, 8,
        nil, nil, 8, 5, nil, nil, nil, 1, nil,
        nil, 9, nil, nil, nil, nil, 4, nil, nil
        ])!
    
}


/**
 Tests construction of sudokus.
 */
class SudokuTests: XCTestCase {
    
    // MARK: Testing dimensions (assumes 64 bit Int).
    
    // Test creating sudokus with out-of-bound dimensions.
    func testInvalidDimensions() {
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 4), rows: 1, columns: 2))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 4), rows: 2, columns: 1))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 7688), rows: 32, columns: 2))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 7688), rows: 2, columns: 32))
    }
    
    // Test creating sudokus with minimum and maximum dimensions.
    func testValidDimensions() {
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 16), rows: 2, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 3844), rows: 2, columns: 31))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 3844), rows: 31, columns: 2))
    }
    
    // Test creating sudokus with invalid numbers of values.
    func testInvalidValuesSize() {
        XCTAssertNil(Sudoku( values: Array(repeating: nil, count: 4), rows: 2, columns: 2))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 15), rows: 2, columns: 2))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 36), rows: 6, columns: 6))
        XCTAssertNil(Sudoku(values: Array(repeating: nil, count: 1295), rows: 6, columns: 6))
    }
    
    // Test creating square-box sudokus for all accepted dimensions.
    func testSquareBox() {
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 16), rows: 2, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 81), rows: 3, columns: 3))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 256), rows: 4, columns: 4))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 625), rows: 5, columns: 5))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 1296), rows: 6, columns: 6))
    }
    
    // Test creating non-square-box sudokus.
    func testRectangularBox() {
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 36), rows: 2, columns: 3))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 64), rows: 2, columns: 4))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 100), rows: 2, columns: 5))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 144), rows: 2, columns: 6))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 144), rows: 6, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 100), rows: 5, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 64), rows: 4, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 36), rows: 3, columns: 2))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 400), rows: 4, columns: 5))
        XCTAssertNotNil(Sudoku(values: Array(repeating: nil, count: 400), rows: 5, columns: 4))
    }
    
    // MARK: Testing sudoku creation
    
    // Test if we can create the evil sudoku.
    func testThreeByThree() {
        let values = [
            8, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        guard let sudoku = Sudoku(values: values) else { return XCTFail("Nil sudoku") }
        
        XCTAssertEqual(sudoku.dimensions.cells, 9)
        XCTAssertEqual(sudoku.values, values)
    }
    
    // Test if we can create a small sudoku.
    func testInitTwoByTwo() {
        let values = [
            1, nil, nil, nil,
            nil, nil, 3, 4,
            nil, 2, nil, nil,
            nil, 1, nil, nil
        ]
        let sudoku = Sudoku(values: values, rows: 2, columns: 2)
        
        XCTAssertNotNil(sudoku)
    }
    
    // Invalid high number in array input
    func testInvalidNumberHigh() {
        let values = [
            10, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        
        XCTAssertNil(Sudoku(values: values))
    }
    
    // Invalid low number in array input
    func testInvalidNumberLow() {
        let values = [
            0, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        
        XCTAssertNil(Sudoku(values: values))
    }
    
    // First row is too short
    func testInvalidRowSize() {
        let values = [
            8, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        
        XCTAssertNil(Sudoku(values: values))
    }

    // Test if we can create a large valid sudoku.
    func testInit30By2() {
        var values = [Int?](repeating: nil, count: 3600)
        
        for row in 0 ..< 60 {
            let start = row < 30 ? row * 2 : (row - 30) * 2 + 1
            
            for i in 0 ..< 60 {
                values[row * 60 + i] = (start + i) % 60 + 1
            }
        }
        let sudoku = Sudoku(values: values, rows: 30, columns: 2)
        
        XCTAssertNotNil(sudoku)
    }
    
    // MARK: Testing sudoku creation from string
    
    // Test empty string input.
    func testEmptyString() {
        let values = ""
        
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 2))
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 2, format: .line))
    }
    
    // Test using a string input with an empty row.
    func testEmptyRowString() {
        let values = """
            1...
            
            ..34
            .2..
            .1..
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 2))
    }
    
   // Test if we can use a string input to create a 2x2 sudoku.
    func testTwoByTwoString() {
        let values = """
            1...
            ..34
            .2..
            .1..
            """

        XCTAssertNotNil(Sudoku(string: values, rows: 2, columns: 2))
        XCTAssertNotNil(Sudoku(string: asLine(values), rows: 2, columns: 2, format: .line))
    }
    
    // Test if we can create a 2x3 sudoku from string.
    func testTwoByThreeString() {
        let values = """
            1.4..6
            ....1.
            ..3..2
            2..6..
            .4....
            3..5.1
            """
        
        XCTAssertNotNil(Sudoku(string: values, rows: 2, columns: 3))
        XCTAssertNotNil(Sudoku(string: asLine(values), rows: 2, columns: 3, format: .line))
    }
    
    // Test if we can create a 3x2 sudoku from string.
    func testThreeByTwoString() {
        let values = """
            1..2.3
            ....4.
            4.3...
            ...6.5
            .1....
            6.2..1
            """
        
        XCTAssertNotNil(Sudoku(string: values, rows: 3, columns: 2))
        XCTAssertNotNil(Sudoku(string: asLine(values), rows: 3, columns: 2, format: .line))
    }
    
    // Test if we can use a string input to create the evil sudoku.
    func testEvilString() {
        let values = """
            8........
            ..36.....
            .7..9.2..
            .5...7...
            ....457..
            ...1...3.
            ..1....68
            ..85...1.
            .9....4..
            """
        let expectedValues = [
            8, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        guard let sudoku = Sudoku(string: values) else { return XCTFail("Nil sudoku") }
        XCTAssertEqual(sudoku.values, expectedValues)

        guard let sudoku2 = Sudoku(string: asLine(values), format: .line) else { return XCTFail("Nil sudoku") }
        XCTAssertEqual(sudoku2.values, expectedValues)
    }
    
    // Box conflict
    // Wrong number in [9,7]
    func testConflictInBox() {
        let values = """
            8........
            ..36.....
            .7..9.2..
            .5...7...
            ....457..
            ...1...3.
            ..1....68
            ..85...1.
            .9....1..
            """
        
        XCTAssertNil(Sudoku(string: values))
        XCTAssertNil(Sudoku(string: asLine(values), format: .line))
    }
    
    // Column conflict
    // Wrong number in [9,7]
    func testConflictInColumn() {
        let values = """
            8........
            ..36.....
            .7..9.2..
            .5...7...
            ....457..
            ...1...3.
            ..1....68
            ..85...1.
            .9....7..
            """
        
        XCTAssertNil(Sudoku(string: values))
        XCTAssertNil(Sudoku(string: asLine(values), format: .line))
    }
    
    // Row conflict
    // Wrong number in [9,7]
    func testConflictInRow() {
        let values = """
            8........
            ..36.....
            .7..9.2..
            .5...7...
            ....457..
            ...1...3.
            ..1....68
            ..85...1.
            .9....9..
            """
        
        XCTAssertNil(Sudoku(string: values))
        XCTAssertNil(Sudoku(string: asLine(values), format: .line))
    }
    
    // Box conflict
    // Wrong number in [5,3]
    func testConflictInTwoByThreeBox() {
        let values = """
            1.4..6
            ....1.
            ..3..2
            2..6..
            .43...
            3..5.1
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 3))
        XCTAssertNil(Sudoku(string: asLine(values), rows: 2, columns: 3, format: .line))
    }
    
    // Invalid non-digit value in string input
    func testInvalidLabel() {
        let values = """
            W........
            ..36.....
            .7..9.2..
            .5...7...
            ....457..
            ...1...3.
            ..1....68
            ..85...1.
            .9....4..
            """
        
        XCTAssertNil(Sudoku(string: values))
        XCTAssertNil(Sudoku(string: asLine(values), format: .line))
    }
    
    // Invalid low number in string input
    func testInvalidLowerDigit() {
        let values = """
            0...
            ..34
            .2..
            .1..
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 2))
        XCTAssertNil(Sudoku(string: asLine(values), rows: 2, columns: 2, format: .line))
    }
    
   // Invalid high number in string input
    func testInvalidUpperDigit() {
        let values = """
            5...
            ..34
            .2..
            .1..
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 2, columns: 2))
        XCTAssertNil(Sudoku(string: asLine(values), rows: 2, columns: 2, format: .line))
    }
    
    // Invalid number of columns.
    // Should be 2 or 3.
    func testInvalidColumns() {
        let values = """
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 3, columns: 4))
    }
    
    // Invalid number of rows.
    // Should be 2 or 3.
    func testInvalidRows() {
        let values = """
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            ............
            """
        
        XCTAssertNil(Sudoku(string: values, rows: 4, columns: 3))
    }

    // MARK: Testing sudoku dimensions
    
    // Test 2x2 dimensions.
    func testTwoByTwoDimensions() {
        let values = """
            1...
            ..34
            .2..
            .1..
            """
        guard let sudoku = Sudoku(string: values, rows: 2, columns: 2) else { return XCTFail("Nil sudoku") }
        
        XCTAssertEqual(sudoku.dimensions.rows, 2)
        XCTAssertEqual(sudoku.dimensions.columns, 2)
        XCTAssertEqual(sudoku.dimensions.cells, 4)
        XCTAssertEqual(sudoku.size, 4)
        XCTAssertEqual(sudoku.cells, 16)
    }

    func testTwoByThreeDimensions() {
        let values = """
            1.4..6
            ....1.
            ..3..2
            2..6..
            .4....
            3..5.1
            """
        guard let sudoku = Sudoku(string: values, rows: 2, columns: 3) else { return XCTFail("Nil sudoku") }

        XCTAssertEqual(sudoku.dimensions.rows, 2)
        XCTAssertEqual(sudoku.dimensions.columns, 3)
        XCTAssertEqual(sudoku.dimensions.cells, 6)
        XCTAssertEqual(sudoku.size, 6)
        XCTAssertEqual(sudoku.cells, 36)
    }
    
    func testThreeByThreeDimensions() {
        let values = """
        8........
        ..36.....
        .7..9.2..
        .5...7...
        ....457..
        ...1...3.
        ..1....68
        ..85...1.
        .9....4..
        """
        guard let sudoku = Sudoku(string: values) else { return XCTFail("Nil sudoku") }

        XCTAssertEqual(sudoku.dimensions.rows, 3)
        XCTAssertEqual(sudoku.dimensions.columns, 3)
        XCTAssertEqual(sudoku.dimensions.cells, 9)
        XCTAssertEqual(sudoku.size, 9)
        XCTAssertEqual(sudoku.cells, 81)
    }

    // MARK: Testing sudoku equality
    
    // Test if the evil sudoku is the same as the one created here.
    func testEquality() {
        let values = [
            8, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, nil
        ]
        
        XCTAssertEqual(Sudoku(values: values), Sudoku.evil)
    }
    
    // Test if the evil sudoku is not the same as the one created here.
    // Bottom right cell should be nil.
    func testNonEquality() {
        let values = [
            8, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, 3, 6, nil, nil, nil, nil, nil,
            nil, 7, nil, nil, 9, nil, 2, nil, nil,
            nil, 5, nil, nil, nil, 7, nil, nil, nil,
            nil, nil, nil, nil, 4, 5, 7, nil, nil,
            nil, nil, nil, 1, nil, nil, nil, 3, nil,
            nil, nil, 1, nil, nil, nil, nil, 6, 8,
            nil, nil, 8, 5, nil, nil, nil, 1, nil,
            nil, 9, nil, nil, nil, nil, 4, nil, 5
        ]
        
        XCTAssertNotEqual(Sudoku(values: values), Sudoku.evil)
    }
    
    // Test accessing values using subscripts.
    func testSubscript() {
        XCTAssertEqual(Sudoku.evil[0], 8)
        XCTAssertNil(Sudoku.evil[80])
        XCTAssertEqual(Sudoku.evil[0, 0], 8)
        XCTAssertNil(Sudoku.evil[8, 8])
    }

    // Test completeness of a sudoku.
    func testCompleteness() {
        let values1 = """
            1234
            3412
            2143
            4321
            """
        let values2 = """
            1...
            ..34
            .2..
            .1..
            """

        guard let sudoku1 = Sudoku(string: values1, rows: 2, columns: 2) else { return XCTFail("Nil sudoku") }
        guard let sudoku2 = Sudoku(string: values2, rows: 2, columns: 2) else { return XCTFail("Nil sudoku") }

        XCTAssertTrue(sudoku1.isComplete())
        XCTAssertFalse(sudoku2.isComplete())
    }

    // MARK: Input formatting
    
    // Converts a grind string input into a single line by removing new lines.
    private func asLine(_ string: String) -> String {
        string.replacingOccurrences(of: "\n", with: "")
    }
    
}


/**
 For LinuxMain.
 */
extension SudokuTests {
    
    static var allTests = [
        ("testInvalidDimensions", testInvalidDimensions),
        ("testValidDimensions", testValidDimensions),
        ("testInvalidValuesSize", testInvalidValuesSize),
        ("testSquareBox", testSquareBox),
        ("testRectangularBox", testRectangularBox),
        ("testThreeByThree", testThreeByThree),
        ("testInitTwoByTwo", testInitTwoByTwo),
        ("testInvalidNumberHigh", testInvalidNumberHigh),
        ("testInvalidNumberLow", testInvalidNumberLow),
        ("testInvalidRowSize", testInvalidRowSize),
        ("testEmptyString", testEmptyString),
        ("testEmptyRowString", testEmptyRowString),
        ("testTwoByTwoString", testTwoByTwoString),
        ("testTwoByThreeString", testTwoByThreeString),
        ("testThreeByTwoString", testThreeByTwoString),
        ("testEvilString", testEvilString),
        ("testConflictInBox", testConflictInBox),
        ("testConflictInColumn", testConflictInColumn),
        ("testConflictInRow", testConflictInRow),
        ("testConflictInTwoByThreeBox", testConflictInTwoByThreeBox),
        ("testInvalidLabel", testInvalidLabel),
        ("testInvalidLowerDigit", testInvalidLowerDigit),
        ("testInvalidUpperDigit", testInvalidUpperDigit),
        ("testInvalidColumns", testInvalidColumns),
        ("testInvalidRows", testInvalidRows),
        ("testTwoByTwoDimensions", testTwoByTwoDimensions),
        ("testTwoByThreeDimensions", testTwoByThreeDimensions),
        ("testThreeByThreeDimensions", testThreeByThreeDimensions),
        ("testEquality", testEquality),
        ("testNonEquality", testNonEquality),
        ("testSubscript", testSubscript),
        ("testCompleteness", testCompleteness),
    ]
    
}
