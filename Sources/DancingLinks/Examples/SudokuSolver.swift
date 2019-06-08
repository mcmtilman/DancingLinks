//
//  SudokuSolver.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Identifies a sudoku grid row.
 */
struct CellValue: Hashable {
    
    /// Index in the sudoku values array.
    let cell: Int
    
    /// Either the cell's given, if it exists, or one of the avaialable choices of an empty cell.
    let value: Int
    
}


/**
 Row in a sudoku grid.
 */
struct Row: GridRow {
    
    /// The cell / value combination uniquely identifies a row.
    let id: CellValue
    
    /// Constraints for this row.
    /// There should be 4 constraints per row.
    let columns: [Int]
    
}


/**
 Sudoku grid, sequence of sudoku rows.
 */
struct SudokuGrid: Grid, IteratorProtocol {
    
    // MARK: Stored properties
    
    let sudoku: Sudoku
    
    // MARK: Private stored properties
    
    // C loops over the cells, v over the values for that cell.
    private var c = 0, v = 0
    
    // MARK: Computed properties
    
    /// Number of constraints added for each row.
    var columns: Int {
        sudoku.cells * 4
    }
    
    // MARK: Initializing
    
    /// Needed because we have private variables.
    init(sudoku: Sudoku) {
        self.sudoku = sudoku
    }
    
    // MARK: Iterating
    
    /// Answer the next row, or nil if now more left.
    /// Note. We could reduced the number of rows by limiting empty cell vslues
    /// to only those numbers that are not used as a given in houses.
    mutating func next() -> Row? {
        while c < sudoku.cells {
            if let value = sudoku[c] {
                defer { c += 1 }
                return Row(id: CellValue(cell: c, value: value), columns: constraints(c, value - 1))
            }
            
            v += 1
            guard v <= sudoku.size else {
                v = 0
                c += 1
                continue
            }
            
            return Row(id: CellValue(cell: c, value: v), columns: constraints(c, v - 1))
        }
        
        return nil
    }
    
    // MARK: Private iterating
    
    // Answer an array specifying 4 constraints:
    // - cell constraint: there is a value in cell i
    // - row constraint: unique occurrence of the value in the cell row
    // - column constraint: unique occurrence of the value in the cell column
    // - box constraint: unique occurrence of the value in the cell box.
    private func constraints(_ i: Int, _ value: Int) -> [Int] {
        let rows = sudoku.dimensions.rows, columns = sudoku.dimensions.columns, size = sudoku.size, cells = sudoku.cells
        let row = i / size, column = i % size
    
        return [
            i,
            cells + row * size + value,
            cells * 2 + column * size + value,
            cells * 3 + (row / rows * rows + column / columns) * size + value
        ]
    }
    
}
