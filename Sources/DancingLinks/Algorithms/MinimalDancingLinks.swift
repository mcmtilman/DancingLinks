//
//  MinimalDancingLinks.swift
//
//  Created by Michel Tilman on 04/05/2020.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import Foundation

fileprivate struct Store<RowId> {
    
    typealias NodeId = Int

    private struct Node {
        
        let row: RowId?
        let column: Int
        
    }
    
    private var nodes = [Node]()

    mutating func makeNode(row: RowId?, column: Int) -> NodeId {
        let id = nodes.count
        
        nodes.append(Node(row: row, column: column))
        
        return id
    }
    
    func smallestColumn() -> Int {
        nodes.map { $0.column }.reduce(0) { min($0, $1) }
    }
    
    var rows: [RowId] {
        nodes.compactMap { $0.row }
    }
    
}

fileprivate func makeNodes<G>(grid: G, store: inout Store<G.RowId>) where G: Grid {
    grid.generateRows { (row: G.RowId, columns: Int...) in
        for c in columns {
            _ = store.makeNode(row: row, column: c)
        }
    }
}

/**
 Just mimicks some computation. Only 'works' if the (sudoku) grid input is complete.
 */
class MinimalDancingLinks {
    
    func solve<G>(grid: G, handler: (Solution<G.RowId>, SearchState) -> ()) where G: Grid {
        guard grid.constraints > 0 else { return }
        
        var store = Store<G.RowId>()
        let state = SearchState()
        var solvedRows = [G.RowId]()
        makeNodes(grid: grid, store: &store)
        
        func solve() -> () {
            for _ in  1...1000 {
                if store.smallestColumn() < 0 {
                    fatalError("Invalid columm")
                }
            }
            solvedRows.append(contentsOf: store.rows)
            
            return handler(Solution(rows: solvedRows), state)
        }

        solve()
     }
    
    /// Returns the first solution found, or nil if no solution found.
    func solve<G>(grid: G) -> Solution<G.RowId>? where G: Grid {
        var solutions = [Solution<G.RowId>]()

        solve(grid: grid) { solution, state in solutions.append(solution) }
        
        return solutions.first
    }
    
}


extension SudokuSolver {
    
    public static func solveMinimal(sudoku: Sudoku) -> Sudoku? {
        guard let solution = MinimalDancingLinks().solve(grid: sudoku) else { return nil }
        var values = [Int?](repeating: nil, count: sudoku.cells)
        
        for row in solution.rows {
            values[row.index] = row.value
        }

        return Sudoku(values: values, dimensions: sudoku.dimensions)
    }

}
