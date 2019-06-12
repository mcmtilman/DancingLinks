//
//  DancingLinks.swift
//
//  Created by Michel Tilman on 04/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 DancingLinks input represented by a list of sparse grid rows.
 Generates rows by a call to generateRows, which accepts a consumer.
 */
public protocol Grid {
    
    associatedtype RowId where RowId: Equatable
    
    /// Generates rows consisting of an id and a list of constraint columns,
    /// and inputs each row into the consumer.
    func generateRows(consume: (RowId, Int...) -> ())
    
    /// Identifies the constraints (DancingLinks columns) for this row.
    /// If this list is empty, the row should be ignored by the consumer.
    var constraints: Int { get }
    
}


/**
 Solution consisting of a subset of row ids produced by the generator.
 */
public struct Solution<RowId> {
    
    /// List of row ids in the solution.
    let rows: [RowId]
    
}


/**
 Search strategies.
 * Naive: selects the first available column in the list.
 * Minimum size: selects the first column with minimum size.
 */
public enum SearchStrategy {
    case naive
    case minimumSize
}


/**
 Search state.
 Can be terminated by the client. After termination the algorithm should stop searching.
 Could contain additional information, such as statistics about the search.
 */
public class SearchState {
    
    // MARK: Stored properties
    
    /// Flag indicating if search may continue.
    public private (set) var terminated = false
    
    // MARK: Updating state
    
    /// From now on, search should be discontinued.
    public func terminate() {
        terminated = true
    }
    
}


/**
 Protocol for the DancingLinks algorithm (cf. Donald Knuth's Algorithm X).
 */
public protocol DancingLinks {
    
    /// Reads a sparse grid of rows and injects each solution and the search state in the handler.
    /// Grid and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId
    
}

/**
 Convenience solver variants.
 */
extension DancingLinks {
    
    /// Returns the solutions, optionally limited.
    /// The default search strategy selects a column with smallest size.
    func solve<G, R>(grid: G, strategy: SearchStrategy = .minimumSize, limit: Int? = nil) -> [Solution<R>] where G: Grid, R == G.RowId {
        var solutions = [Solution<R>]()

        solve(grid: grid, strategy: strategy) { solution, state in
            guard let limit = limit else { return solutions.append(solution) }
            
            if solutions.count < limit {
                solutions.append(solution)
            }
            if solutions.count >= limit {
                state.terminate()
            }
        }
        
        return solutions
    }
    
    /// Returns the first solution found, or nil if no solution found.
    /// The default search strategy selects a column with smallest size.
    func solve<G, R>(grid: G, strategy: SearchStrategy = .minimumSize) -> Solution<R>? where G: Grid, R == G.RowId {
        solve(grid: grid, strategy: strategy, limit: 1).first
    }
    
}
