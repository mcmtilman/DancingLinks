//
//  Sudoku.swift
//
//  Created by Michel Tilman on 07/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Dimensions of a sudoku box, defined by number of rows and columns.
 */
struct Dimensions {
    
    // MARK: Constraints
    
    /// Specifies lower and upper bounds for the number of rows and columns in a box.
    /// Minimum = 2, maximum = 6.
    enum Bounds {
        
        /// Range of allowed number of columns in a box.
        static let columns = 2 ... 6
        
        /// Range of allowed number of rows in a box.
        static let rows = 2 ... 6
        
    }
    
    // MARK: Stored properties
    
    /// Box dimensions in range defined by Bounds.
    let rows, columns: Int
    
    // MARK: Computed properties
    
    /// The number of cells in a box = rows * columns.
    var cells: Int {
        rows * columns
    }
    
    // MARK: Initializing
    
    /// Create new dimensions.
    /// - Parameter rows: Number of rows in a box (range 2 ... 6).
    /// - Parameter columns: Number of columns in a box (range 2 ... 6).
    init?(rows: Int, columns: Int) {
        guard Bounds.rows.contains(rows), Bounds.columns.contains(columns) else { return nil }
        
        self.rows = rows
        self.columns = columns
    }

}


/**
 Equatable protocol adoption.
 Allows us to compare sudoku's easily.
 */
extension Dimensions: Equatable {}


/**
 A square-sized sudoku.
 It's size is determined by the dimensions of a sudoku box. Sudoku boxes need not be square,
 but the number of boxes in the sudoku is constrained by:
 * Horizontal number of boxes = number of box rows.
 * Vertical number of boxes = number of box columns.
 The size (number of rows or number columns in the sudoku) = the number of cells of the sudoku dimensions.
 The number of cells in the sudoku = size * size.
 
 Example:
 * Sudoku box dimensions = 2 (rows) x 3 (columns)
 * Number of sudoku rows = number of sudoku columns = size = 2 x 3 = 6
 * Number of sudoku cells = 36
 */
struct Sudoku {
    
    // MARK: Stored properties
    
    /// The dimensions of a box.
    let dimensions: Dimensions
    
    /// The list of all values within the sudoku, in row-major order.
    /// The array should be of size = square of the dimensions size.
    /// The array elements should be nil or in the range 1 ... dimensions size.
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
    /// - Dimensions are restricted to 2 ... 6 range.
    /// - Number of values must conform to given dimensions.
    /// - All givens (i.e. non-nil values) must contain a valid number in the range 1 ... size of a box.
    /// - There may be no conflict between givens in the same house (box, sudoku row or sudoku column).
    ///
    /// This does no include verifying that the input has one (and only one) solution.
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
    /// - Dimensions are restricted to 2 ... 6 range.
    /// - Values must conform to given dimensions.
    /// - All givens (i.e. non-nil values) must contain a valid number in the range 1 ... size of a box.
    /// - There may be no conflict between givens in the same house (box, sudoku row or sudoku column).
    ///
    /// - Parameter values: List of values for givens and empty cells (nil values), in row-major order.
    /// - Parameter dimensions: Dimensions of a box.
    private init?(values: [Int?], dimensions: Dimensions) {
        let size = dimensions.cells
        guard values.count == size * size else { return nil }
        
        for i in 0 ..< size {
            var rowValues = BitSet()

            for j in 0 ..< size {
                if let value = values[i * size + j] {
                    guard value >= 1, value <= size, rowValues.insert(value).inserted else { return nil }
                }
            }
        }
        for i in 0 ..< size {
            let rows = dimensions.rows, columns = dimensions.columns
            var columnValues = BitSet(), boxValues = BitSet()

            for j in 0 ..< size {
                if let value = values[i + j * size] {
                    guard columnValues.insert(value).inserted else { return nil }
                }
                if let value = values[(i / rows * rows + j / columns) * size + i % rows * columns + j % columns] {
                    guard boxValues.insert(value).inserted else { return nil }
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
    
    // MARK: Convenience initializing
    
    /// Initialize the sudoku from given string.
    /// Each line represents a row. An empty cell is represented by the dot character, other cells by a digit.
    /// Possible dimensions are (2,2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 2).
    ///
    /// - Parameter string: The values, with rows separated by a newline.
    /// - Parameter rows: The number of rows within a box. Default = 3.
    /// - Parameter columns: The number of columns within a box. Default = 3.
    ///
    /// Example of a sudoku with 2 by 2 boxes:
    ///     1.2.
    ///     ...4
    ///     ..31
    ///     42..
    // Note. (46, 48) = ascii codes of (".", "0").
    init?(string: String, rows: Int = 3, columns: Int = 3) {
        guard let dimensions = Dimensions(rows: rows, columns: columns) else { return nil }

        let size = dimensions.cells
        guard size >= 4, size <= 9 else { return nil }

        let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count == size else { return nil }

        let rows = lines.map { line in line.unicodeScalars.map { $0.value == 46 ? nil : Int($0.value) - 48 }}
        for row in rows {
            guard row.count == size else { return nil }
            for case let value? in row where value < 1 || value > size { return nil }
        }

        self.init(values: rows.flatMap { $0 }, dimensions: dimensions)
    }

    // MARK: Subscript accessing
    
    /// Returns the element at given position in row-major order.
    /// Fails if out of range.
    subscript(index: Int) -> Int? {
        values[index]
    }
    
    /// Returns the element at given row and column.
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
