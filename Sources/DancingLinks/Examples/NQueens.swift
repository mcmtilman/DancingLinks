//
//  NQueens.swift
//
//  Created by Michel Tilman on 18/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Specifies number of queens (and chessboard size).
 */
struct NQueens {
    
    // MARK: Stored properties
    
    // Number of queens = number of ranks and files on chessboard.
    let number: Int
    
}


/**
 Grid protocol adoption.
 */
extension NQueens: Grid {
    
    // MARK: Computed properties
    
    /// Maximum number of mandatory constraints for the DancingLinks input.
    /// Rank and file constraints.
    var constraints: Int {
        2 * number
    }
    
    /// Maximum number of optional constraints for the DancingLinks input.
    /// Diagonal constraints.
    var optionalConstraints: Int {
        4 * number - 2
    }
    
    // MARK: Generating
    
    /// Generates the rows and passes them to the consumer.
    /// Each row has 4 constraints: rank, file, diagonal and reverse diagonal.
    func generateRows(consume: (Int, Int...) -> ()) {
        for rank in 0 ..< number {
            for file in 0 ..< number {
                let rowId = rank * number + file
                let rankConstraint = rank
                let fileConstraint = number + file
                let diagonalConstraint = 2 * number + rank + file
                let reverseDiagonalConstraint = 5 * number - 2 - rank + file

                consume(rowId, rankConstraint, fileConstraint, diagonalConstraint, reverseDiagonalConstraint)
            }
        }
    }

}


/**
 N-Queens problem solver using DancingLinks algorithm.
 */
class NQueensSolver {
    
    // MARK: Defaults
    
    // Default algorithm.
    private static let dlx = StructuredDancingLinks()
    
    // MARK: Solving N-Queens problem
    
    /// Returns a solution of the N-Queens problem, or nil if no solution found.
    /// Does not verify the existence of additional solutions.
    /// Default algorithm = StructuredDancingLinks.
    func solve(nQueens: NQueens, algorithm: DancingLinks = dlx) -> [Int]? {
        guard let solution = algorithm.solve(grid: nQueens) else { return nil }
        
        return solution.rows
    }
    
}
