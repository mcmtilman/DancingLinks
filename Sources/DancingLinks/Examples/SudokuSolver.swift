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
    /// Limits an empty cell's rows to those numbers that are not used as a given in any of the cell's houses.
    /// Generates one row for non-empty cells.
    func generateRows(consume: (Cell, Int...) -> ()) {
        let rows = dimensions.rows, columns = dimensions.columns
        let options = remainingOptions(rows, columns, size)

        for row in 0 ..< size {
            for column in 0 ..< size {
                let index = row * size + column

                for value in (options[index]) {
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

    // Returns the options for each cell as a bit set.
    // For an empty cell eliminates givens in the cells's houses and returns the remaining options.
    // For a non-empty cell returns a singleton set containing the given.
    private func remainingOptions(_ rows: Int, _ columns: Int, _ size: Int) -> [BitSet] {
        let set = BitSet(1 ... size)
        var options = values.map { v in  v == nil ? set : BitSet(v!) }
        var i = 0

        for _ in 0 ..< size {
            var givens = BitSet()

            for _ in 0 ..< size {
                if let v = values[i] { givens.insert(v) }
                i += 1
            }
            i -= size
            for _ in 0 ..< size {
                if values[i] == nil { options[i].subtract(givens) }
                i += 1
            }
        }
        
        for c in 0 ..< size {
            var givens = BitSet()

            i = c
            for _ in 0 ..< size {
                if let v = values[i] { givens.insert(v) }
                i += size
            }
            i = c
            for _ in 0 ..< size {
                if values[i] == nil { options[i].subtract(givens) }
                i += size
            }
        }
        
        for b in 0 ..< size {
            let origin = b / rows * rows * size + b * columns % size
            var givens = BitSet()
            
            i = origin
            for _ in 0 ..< rows {
                for _ in 0 ..< columns {
                    if let v = values[i] { givens.insert(v) }
                    i += 1
                }
                i = origin + size
            }
            i = origin
            for _ in 0 ..< rows {
                for _ in 0 ..< columns {
                    if values[i] == nil { options[i].subtract(givens) }
                    i += 1
                }
                i = origin + size
            }
        }

        return options
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
