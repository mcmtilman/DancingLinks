//
//  Sudoku.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation

/**
 Dimensions of a sudoku box. Specifies the number of rows and columns.
 */
struct Dimensions {
    
    // MARK: Constraints
    
    /// Specifies lower and upper bounds for the number of rows and number of columns in a box.
    /// Minimum = 2, maximum = 32.
    /// The number of cells (rows * columns) should be less than or equal to the BitSet maximum value.
    enum Bounds {
        
        /// Range of the allowed number of columns in a box.
        static let columns = 2 ... 32
        
        /// Range of the allowed number of rows in a box.
        static let rows = 2 ... 32
        
        /// Maximum number of cells in a box.
        /// Note. We can double the maximum by 'encoding' the range of cells values (1 ... cells) as (0 ..< cells).
        static let maxCells = BitSet.max
        
    }
    
    // MARK: Stored properties
    
    /// Box dimensions, constrained by Bounds.
    let rows, columns: Int
    
    // MARK: Computed properties
    
    /// The number of cells in a box = rows * columns.
    var cells: Int {
        rows * columns
    }
    
    // MARK: Initializing
    
    /// Initializes the dimensions.
    /// - Parameter rows: Number of rows in a box (range 2 ... 32).
    /// - Parameter columns: Number of columns in a box (range 2 ... 32).
    /// The number of cells should be in the range 4 ..< 64 (assuming 64 bit Int).
    /// Fails if the dimensions are outside the Bounds ranges.
    init?(rows: Int, columns: Int) {
        guard Bounds.rows.contains(rows), Bounds.columns.contains(columns), rows * columns <= Bounds.maxCells else { return nil }
        
        self.rows = rows
        self.columns = columns
    }
    
}


/**
 Equatable protocol adoption.
 Allows us to compare sudoku's.
 */
extension Dimensions: Equatable {}


/**
 Traditional sudoku consisting of rows, columns and boxes (aka houses) consisting of cells.
 Each cell may be empty or contain a number constrained by the size of the sudoku.
 Within each house a non-nil value may occur in only one cell.
 
 While the sudoku is a square, the sudoku boxes may be rectangular.
 The sudoku size is determined by the dimensions of its sudoku boxes.
 The number of boxes in the sudoku is constrained by:
 * Horizontal number of boxes = number of box rows.
 * Vertical number of boxes = number of box columns.
 The size (number of rows or number of columns in the sudoku) = the number of cells of the sudoku dimensions.
 The number of cells in the total sudoku = size * size.
 
 Example:
 * Sudoku box dimensions = 2 rows x 3 columns
 * Sudoku size = number of sudoku rows = number of sudoku columns = 2 x 3 = 6
 * Number of sudoku cells = 36
 * Each non-nil cell value must lie in the range 1 ... 6 and be unique in the houses containing that cell.
 */
struct Sudoku {
    
    // MARK: Stored properties
    
    /// The dimensions of a box.
    let dimensions: Dimensions
    
    /// The list of all values within the sudoku, in row-major order.
    /// The size of the array equals the number of cells in the sudoku.
    /// The array elements should be nil or in the range 1 ... sudoku size.
    let values: [Int?]
    
    // MARK: Computed properties
    
    /// Number of rows and columns in the sudoku.
    var size: Int {
        dimensions.cells
    }
    
    /// Number of cells in the sudoku.
    var cells: Int {
        size * size
    }
    
    // MARK: Initializing
    
    /// Initialize a sudoku with given box dimensions and list of values.
    /// Fail if the sudoku is not valid.
    ///
    /// The following validations are performed:
    /// - Box dimensions are restricted to the 2 ... 32 range.
    /// - Number of values must conform to given dimensions and fit in a bitset.
    /// - All givens (i.e. non-nil values) must contain a valid number in the range 1 ... size of a box.
    /// - There may be no conflict between givens in the same house (box, sudoku row or sudoku column).
    /// This does not include verifying that the input has one (and only one) solution.
    ///
    /// - Parameter values: List of givens and empty cells (nil values), in row-major order.
    /// - Parameter rows: The number of rows within a box. Default = 3.
    /// - Parameter columns: The number of columns within a box. Default = 3.
    init?(values: [Int?], rows: Int = 3, columns: Int = 3) {
        guard let dimensions = Dimensions(rows: rows, columns: columns) else { return nil }
        
        self.init(values: values, dimensions: dimensions)
    }
    
    // MARK: Private initializing
    
    /// Initialize a sudoku with given dimensions and list of values.
    /// Fail if the sudoku is not valid.
    ///
    /// The following validations are performed:
    /// - Dimensions are restricted to 2 ... 32 range.
    /// - Values must conform to given dimensions and fit in a bitset.
    /// - All givens (i.e. non-nil values) must contain a valid number in the range 1 ... size of a box.
    /// - There may be no conflict between givens in the same house (box, sudoku row or sudoku column).
    ///
    /// - Parameter values: List of values for givens and empty cells (nil values), in row-major order.
    /// - Parameter dimensions: Dimensions of a box.
    init?(values: [Int?], dimensions: Dimensions) {
        let size = dimensions.cells, rows = dimensions.rows, columns = dimensions.columns
        guard values.count == size * size else { return nil }
        
        var rowValues = [BitSet](repeating: BitSet(), count: size)
        var columnValues = [BitSet](repeating: BitSet(), count: size)
        var boxValues = [BitSet](repeating: BitSet(), count: size)
        
        for row in 0 ..< size {
            for column in 0 ..< size {
                if let value = values[row * size + column] {
                    guard value >= 1, value <= size,
                        rowValues[row].insert(value).inserted,
                        columnValues[column].insert(value).inserted,
                        boxValues[row / rows * rows + column / columns].insert(value).inserted
                        else { return nil }
                }
            }
        }
        
        self.dimensions = dimensions
        self.values = values
    }
    
}


/**
 Equatable protocol adoption
 */
extension Sudoku: Equatable {}


/**
 Convenience methods
 */
extension Sudoku {
    
    // MARK: Formats
    
    // Supported string formats
    enum Format {
        case grid, line
    }
    
    // MARK: Convenience initializing
    
    /// Initializes the sudoku from given string.
    /// An empty cell is represented by the dot character, other cells by a single digit.
    /// Possible dimensions are (2,2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 2).
    /// The string may consist of multiple lines of values, one line per row (grid format),
    /// or of a single line of values in row-major order.
    /// Fails if the dimensions are invalid or if the string contains invalid characters,
    ///
    /// - Parameter string: The values where each cell contains either a single digit or a dot.
    /// - Parameter rows: The number of rows within a box. Default = 3.
    /// - Parameter columns: The number of columns within a box. Default = 3.
    /// - Parameter format: String format. Default = grid.
    ///
    /// Example of a sudoku with 2 by 2 boxes using the grid format:
    ///     """
    ///     1.2.
    ///     ...4
    ///     ..31
    ///     42..
    ///     """
    /// Example of the same sudoku using the line format:
    ///     "1.2....4..3142.."
    init?(string: String, rows: Int = 3, columns: Int = 3, format: Format = .grid) {
        guard let dimensions = Dimensions(rows: rows, columns: columns) else { return nil }
        let size = dimensions.cells
        guard size >= 4, size <= 9 else { return nil }

        switch format {
        case .grid: self.init(grid: string, dimensions: dimensions)
        case .line: self.init(line: string, dimensions: dimensions)
        }
    }

    // MARK: Private initializing
    
    // Initializes the sudoku from given multi-line string, with each line representing a row.
    // An empty cell is represented by the dot character, other cells by a single digit.
    //
    // - Parameter grid: The values, with rows separated by a newline.
    // - Parameter dimensions: The dimensions.
    //
    // Example of a sudoku with 2 by 2 boxes:
    //     """
    //     1.2.
    //     ...4
    //     ..31
    //     42..
    //     """
    // Note. (46, 48) = ascii codes of (".", "0").
    private init?(grid: String, dimensions: Dimensions) {
        let size = dimensions.cells
        let lines = grid.components(separatedBy: "\n")
        guard lines.count == size else { return nil }
        
        let rows = lines.map { line in line.unicodeScalars.map { $0.value == 46 ? nil : Int($0.value) - 48 }}
        for row in rows {
            guard row.count == size else { return nil }
            for case let value? in row where value < 1 || value > size { return nil }
        }
        
        self.init(values: rows.flatMap { $0 }, dimensions: dimensions)
    }
    
    // Initializes the sudoku from given string representing the values in row-major order.
    // An empty cell is represented by the dot character, other cells by a single digit.
    //
    // - Parameter line: The values in row-major order.
    // - Parameter dimensions: The dimensions.
    //
    // Example of a sudoku with 2 by 2 boxes:
    //     "1.2....4..3142.."
    // Note. (46, 48) = ascii codes of (".", "0").
    private init?(line: String, dimensions: Dimensions) {
        let size = dimensions.cells
        let values = line.unicodeScalars.map { $0.value == 46 ? nil : Int($0.value) - 48 }

        guard values.count == size * size else { return nil }
        for case let value? in values where value < 1 || value > size { return nil }
        
        self.init(values: values, dimensions: dimensions)
    }
    
    // MARK: Subscript accessing
    
    /// Returns the element at given zero-based position in row-major order.
    /// Fails if out of range.
    subscript(index: Int) -> Int? {
        values[index]
    }
    
    /// Returns the element at given zero-based row and column.
    /// Fails if out of range.
    subscript(row: Int, column: Int) -> Int? {
        values[row * size + column]
    }
    
    // MARK: Testing
    
    /// Returns true if there are no empty cells, false otherwise.
    func isComplete() -> Bool {
        !values.contains(nil)
    }
    
}
