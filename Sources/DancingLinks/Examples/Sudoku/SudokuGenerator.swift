//
//  RandomSudokuGenerator.swift
//
//  Created by Michel Tilman on 23/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Generates sudoku solutions starting from an empty grid using random value placement.
 */
class RandomSudokuGenerator {
    
    // Generates a random solution for sudokus with given dimensions
    func generateSolution(rows: Int = 3, columns: Int = 3) -> Sudoku? {
        let size = rows * columns, cells = size * size
        var rowOptions = [BitSet](repeating: BitSet(1 ... size), count: size)
        var columnOptions = [BitSet](repeating: BitSet(1 ... size), count: size)
        var boxOptions = [BitSet](repeating: BitSet(1 ... size), count: size)
        var values = [Int?](repeating: nil, count: cells)
        
        func generate(_ cell: Int) -> Sudoku? {
            guard cell < cells else { return Sudoku(values: values, rows: rows, columns: columns) }
            
            let row = cell / size, column = cell % size, box = row / rows * rows + column / columns
            let savedRow = rowOptions[row], savedColumn = columnOptions[column], savedBox = boxOptions[box]
            var options = savedRow.intersection(savedColumn).intersection(savedBox)
            
            while let value = options.randomElement() {
                values[cell] = value
                rowOptions[row].remove(value)
                columnOptions[column].remove(value)
                boxOptions[box].remove(value)
                if let solution = generate(cell + 1) {
                    return solution
                }
                rowOptions[row] = savedRow
                columnOptions[column] = savedColumn
                boxOptions[box] = savedBox
                options.remove(value)
            }
            
            return nil
        }
        
        return generate(0)
    }
    
}
