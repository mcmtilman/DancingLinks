//
//  SudokuSolver.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 A cell with (resolved) given in a sudoku.
 */
struct Cell: Hashable {
    
    /// Index of a sudoku cell in row-major order.
    let index: Int
    
    /// Either the cell's given or one of the available choices in case of an empty cell.
    let value: Int
    
}


/**
 Grid protocol adoption.
 */
extension Sudoku: Grid {
    
    // MARK: Computed properties
    
    /// Maximum number of constraints needed.
    var constraints: Int {
       cells * 4
    }
    
    // MARK: Generating
    
    /// Generates the rows and passes them to the consumer.
    /// Note. We can reduce the number of rows by limiting empty cell values
    /// to those numbers that are not used as givens in any of the cell's houses.
    func generateRows(consume: (Cell, Int...) -> ()) {
        let rows = dimensions.rows, columns = dimensions.columns

        for row in 0 ..< size {
            for column in 0 ..< size {
                let index = row * size + column
                
                for value in (values[index].map { $0 ... $0 } ?? 1 ... size) {
                    let rowId = Cell(index: index, value: value)
                    let cellConstraint = index
                    let rowConstraint = cells + row * size + value - 1
                    let columnConstraint = cells * 2 + column * size + value - 1
                    let boxConstraint = cells * 3 + (row / rows * rows + column / columns) * size + value - 1
                    
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
    
    // MARK: Defaults
    
    // Default algorithm.
    private static let dlx = StructuredDancingLinks()
    
    // MARK: Solving sudokus
    
    /// Returns a solution of the sudoku, or nil if no solution found.
    /// Does not verify the existence of additional solutions.
    /// Default algorithm = StructuredDancingLinks.
    func solve(sudoku: Sudoku, algorithm: DancingLinks = dlx) -> Sudoku? {
        guard let solution = algorithm.solve(grid: sudoku) else { return nil }
        var values = [Int?](repeating: nil, count: sudoku.cells)
        
        for row in solution.rows {
            values[row.index] = row.value
        }
        
        return Sudoku(values: values, dimensions: sudoku.dimensions)
    }
    
}
