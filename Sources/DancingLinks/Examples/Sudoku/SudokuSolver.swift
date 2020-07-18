//
//  SudokuSolver.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Common

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
    
    /// Maximum number of mandatory constraints for the DancingLinks input.
    var constraints: Int {
        cells * 4
    }
    
    /// Maximum number of optional constraints for the DancingLinks input.
    var optionalConstraints: Int {
        0
    }
    
    // MARK: Generating
    
    /// Generates the rows and passes them to the consumer.
    /// Limits an empty cell's rows to those numbers that are not used as a given in any of the cell's houses.
    /// Generates one row for non-empty cells.
    func generateRows(consume: (Cell, Int...) -> ()) {
        let rows = dimensions.rows, columns = dimensions.columns
        let allOptions = BitSet(1 ... size)
        let givens = collectValues(rows, columns, size)
        
        for row in 0 ..< size {
            for column in 0 ..< size {
                let index = row * size + column
                let givens = givens.rows[row].union(givens.columns[column].union(givens.boxes[row / rows * rows + column / columns]))
                let options = values[index].map { BitSet($0) } ?? allOptions.subtracting(givens)
                
                for value in options {
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
    
    // Returns the given values for each row, column and box as a bit set.
    private func collectValues(_ rows: Int, _ columns: Int, _ size: Int) -> (rows: [BitSet], columns: [BitSet], boxes: [BitSet]) {
        var rowValues = [BitSet](repeating: BitSet(), count: size)
        var columnValues = [BitSet](repeating: BitSet(), count: size)
        var boxValues = [BitSet](repeating: BitSet(), count: size)
        
        for row in 0 ..< size {
            for column in 0 ..< size {
                if let value = values[row * size + column] {
                    rowValues[row].insert(value)
                    columnValues[column].insert(value)
                    boxValues[row / rows * rows + column / columns].insert(value)
                }
            }
        }
        
        return (rows: rowValues, columns: columnValues, boxes: boxValues)
    }
    
}


/**
 Sudoku solver using DancingLinks algorithm.
 */
public class SudokuSolver {
    
    // MARK: Solving sudokus
    
    /// Returns a solution of the sudoku, or nil if no solution found.
    /// Does not verify the existence of additional solutions.
    /// Default algorithm = StructuredDancingLinks.
    public static func solve(sudoku: Sudoku, algorithm: DancingLinksAlgorithm = .structured) -> Sudoku? {
        guard let solution = algorithm.solver().solve(grid: sudoku) else { return nil }
        var values = [Int?](repeating: nil, count: sudoku.cells)
        
        for row in solution.rows {
            values[row.index] = row.value
        }

        return Sudoku(values: values, dimensions: sudoku.dimensions)
    }
    
}
