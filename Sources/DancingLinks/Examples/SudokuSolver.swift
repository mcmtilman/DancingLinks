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
 Grid protocol adoption.
 */
extension Sudoku: Grid {
    
    // MARK: Computed properties
    
    /// Maximum number of constraints added for all rows.
    var constraints: Int {
       cells * 4
    }
    
    // MARK: Generating
    
    /// Generate the rows, passing each row to the consumer.
    /// Note. We could reduced the number of rows by limiting empty cell vslues
    /// to only those numbers that are not used as a given in houses.
    func generateRows(consume: (CellValue, Int...) -> ()) {
        let rows = dimensions.rows, columns = dimensions.columns

        for row in 0 ..< size {
            for column in 0 ..< size {
                let cell = row * size + column
                
                for each in (values[cell].map { $0 ... $0 } ?? 1 ... size) {
                    let rowId = CellValue(cell: cell, value: each)
                    let cellConstraint = cell
                    let value = each - 1
                    let rowConstraint = cells + row * size + value
                    let columnConstraint = cells * 2 + column * size + value
                    let boxConstraint = cells * 3 + (row / rows * rows + column / columns) * size + value
                    
                    consume(rowId, cellConstraint, rowConstraint, columnConstraint, boxConstraint)
                }
            }
        }
    }
    
}


/**
 Sudoku solver using DancingLinks algorithm.
 */
class SudokuSolver {
    
    // Struct-based implementation of DancingLinks.
    private let dlx = StructuredDancingLinks()
    
    /// Returns single solution of sudoku, or nil otherwise (no or multiple solutions).
    func solve(sudoku: Sudoku) -> Sudoku? {
        guard let solution = dlx.solve(grid: sudoku) else { return nil }
        var values = [Int?](repeating: nil, count: sudoku.cells)
        
        for row in solution.rows {
            values[row.cell] = row.value
        }
        
        return Sudoku(values: values, dimensions: sudoku.dimensions)
    }
    
}
