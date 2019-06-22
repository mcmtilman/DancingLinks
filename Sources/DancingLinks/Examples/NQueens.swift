//
//  NQueens.swift
//
//  Created by Michel Tilman on 18/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Specifies the number of queens and the size of the (square) chessboard.
 */
struct NQueens {
    
    // MARK: Stored properties
    
    // Number of queens = number of ranks and files on chessboard.
    let number: Int
    
    /// Initializes the N-Queens problem for N >= 1. Fails otherwise.
    init?(number: Int) {
        guard number >= 0 else { return nil }
        
        self.number = number
    }
    
}


/**
 A chess square.
 */
struct Square: Hashable {
    
    /// Rank of the square.
    let rank: Int
    
    /// File of the square.
    let file: Int
    
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
    func generateRows(consume: (Square, Int...) -> ()) {
        for rank in 0 ..< number {
            for file in 0 ..< number {
                let rowId = Square(rank: rank, file: file)
                let rankConstraint = rank
                let fileConstraint = number + file
                let diagonalConstraint = 2 * number + rank + file
                let reverseDiagonalConstraint = 5 * number - 2 + rank - file

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
    
    /// Returns solutions of the N-Queens problem, optionally up to a limit.
    /// Default algorithm = StructuredDancingLinks.
    func solve(nQueens: NQueens, algorithm: DancingLinks = dlx, limit: Int? = nil) -> [[Square]] {
        algorithm.solve(grid: nQueens, limit: limit).map { $0.rows }
    }
    
}
