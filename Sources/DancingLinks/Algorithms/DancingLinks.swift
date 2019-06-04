//
//  DancingLinks.swift
//
//  Created by Michel Tilman on 04/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.


/**
 Row in a sparse DancingLinks grid.
 */
public protocol GridRow {
    
    /// Client-specific way of identifying a row.
    /// Adoption of Hashable protocol allows algorithms to check uniqueness if wanted.
    associatedtype Row: Hashable
    
    /// Identifies the row.
    var row: Row { get }
    
    /// Columns having a constraint set for this row.
    /// Unconstrained columns are omitted.
    var columns: [Int] { get }
    
}


/**
 Generator for the rows in a DancingLinks grid.
 */
public protocol GridGenerator: IteratorProtocol where Element: GridRow {
    
    /// Number of columns needed to represent all constraints.
    var columns: Int { get }
    
}


/**
 Solution consisting of rows ids, a subset of the rows created by the generator.
 */
public protocol Solution {
    
    /// Client-specific way of identifying a row.
    associatedtype Row
    
    /// Number of columns needed to represent all constraints.
    var rows: [Row] { get }
    
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
 Can only be terminated by the client. After termination the algorithm should stop searching.
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
    
    /// Constructs a sparse grid using the generator and injects each solution and a search state in the handler.
    /// Generator and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    func solve<G, S>(generator: G, strategy: SearchStrategy, handler: (S, SearchState) -> ()) where G: GridGenerator, S: Solution, G.Element.Row == S.Row
    
}

/**
 Simplified solver variants.
 */
extension DancingLinks {
    
    /// Returns all solutions found.
    func solveAll<G, S>(generator: G, strategy: SearchStrategy) -> [S] where G: GridGenerator, S: Solution, G.Element.Row == S.Row {
        var solutions = [S]()

        solve(generator: generator, strategy: strategy) { (solution: S, state: SearchState) in
            solutions.append(solution)
        }
        
        return solutions
    }
    
    /// Returns the first solution found, nil otherwise.
    func solveAny<G, S>(generator: G, strategy: SearchStrategy) -> S? where G: GridGenerator, S: Solution, G.Element.Row == S.Row {
        var anySolution: S?
        
        solve(generator: generator, strategy: strategy) { (solution: S, state: SearchState) in
            anySolution = solution
            state.terminate()
        }
        
        return anySolution
    }
    
    /// Returns the single solution if there is exactly one, nil otherwise.
    func solveStrict<G, S>(generator: G, strategy: SearchStrategy) -> S? where G: GridGenerator, S: Solution, G.Element.Row == S.Row {
        var strictSolution: S?

        solve(generator: generator, strategy: strategy) { (solution: S, state: SearchState) in
            guard strictSolution == nil else {
                strictSolution = nil
                return state.terminate()
            }
            strictSolution = solution
        }
        
        return strictSolution
    }
    
}
