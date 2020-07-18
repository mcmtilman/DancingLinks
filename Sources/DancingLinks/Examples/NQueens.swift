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
public struct NQueens {
    
    // MARK: Stored properties
    
    // Number of queens = number of ranks and files on chessboard.
    let number: Int
    
    // MARK: Initializing
    
    /// Initializes the N-Queens problem for N >= 1. Fails otherwise.
    /// Default = 8.
    public init?(number: Int = 8) {
        guard number >= 1 else { return nil }
        
        self.number = number
    }
    
}


/**
 A chess square.
 */
public struct Square: Hashable {
    
    // MARK: Stored properties
    
    /// Rank and file of the square.
    public let rank, file: Int
 
    // MARK: Initializing
    
    /// Default initializer is internal.
    public init(rank: Int, file: Int) {
        self.rank = rank
        self.file = file
    }
    
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
public class NQueensSolver {
    
    // MARK: Solving N-Queens problem
    
    /// Returns solutions of the N-Queens problem, optionally up to a limit.
    /// Default algorithm = StructuredDancingLinks.
    public static func solve(nQueens: NQueens, algorithm: DancingLinksAlgorithm = .structured, limit: Int? = nil) -> [[Square]] {
        algorithm.solver().solve(grid: nQueens, limit: limit).map { $0.rows }
    }
    
}
