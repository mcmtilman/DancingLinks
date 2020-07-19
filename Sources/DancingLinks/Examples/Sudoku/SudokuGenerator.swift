//
//  RandomSudokuGenerator.swift
//
//  Created by Michel Tilman on 23/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Common

/**
 Generates sudoku solutions starting from an empty grid using random value placement.
 */
public class RandomSudokuGenerator {
    
    // MARK: Initializing
    
    /// Default public initializer must be declared explicitly
    public init() {}
    
    // MARK: Generating
    
    /// Generates a random solution for sudokus with given dimensions
    public func generateSolution(rows: Int = 3, columns: Int = 3) -> Sudoku? {
        let size = rows * columns, cells = size * size
        var gridOptions = [BitSet](repeating: BitSet(1 ... size), count: size * 3)
        var values = [Int?](repeating: nil, count: cells)
        
        func generate(_ cell: Int) -> Sudoku? {
            guard cell < cells else { return Sudoku(values: values, rows: rows, columns: columns) }
            
            let row = cell / size, temp = cell % size, column = temp + size, box = row / rows * rows + temp / columns + size * 2
            let saved = (gridOptions[row], gridOptions[column], gridOptions[box])
            var cellOptions = saved.0.intersection(saved.1).intersection(saved.2)
            
            while let value = cellOptions.randomElement() {
                values[cell] = value
                for i in [row, column, box] {
                    gridOptions[i].remove(value)
                }
                if let solution = generate(cell + 1) {
                    return solution
                }
                (gridOptions[row], gridOptions[column], gridOptions[box]) = saved
                cellOptions.remove(value)
            }
            
            return nil
        }
        
        return generate(0)
    }
    
}
