//
//  StructuredDancingLinks.swift
//
//  Created by Michel Tilman on 08/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Manages the nodes.
 Handles node-related operations.
 */
fileprivate struct Store<RowId> where RowId: Hashable {

    // References a node in the store.
    typealias NodeId = Int

    // Represents a row node, a column node or a header node.
    // Store clients only communicate with the store through node ids.
    private struct Node {
        
        // MARK: Stored properties
        
        // Reference to the column node in the store.
        let column: NodeId
        
        // References to left, right, up and down nodes in the store.
        var down, left, right, up: NodeId
        
        // Reference of this node in the store.
        let id: NodeId
        
        // Flag denoting if mandatory (columns only).
        // False for header and row nodes.
        let mandatory: Bool
        
        // Client row reference. Same for all nodes in the same row.
        // Nil for headers and columns.
        let row: RowId?
        
        // Number of row nodes in a column. Only used by column nodes.
        var size = 0
        
        // MARK: Initializing
        
        // Initializes a column node.
        init(column: NodeId, mandatory: Bool) {
            self.init(nil, column, column, mandatory)
        }
        
        // Initializes the header node.
        init(header: NodeId) {
            self.init(nil, header, header, false)
        }
        
        // Initializes a row node.
        init(row: RowId, column: NodeId, id: NodeId) {
            self.init(row, column, id, false)
        }
        
        // MARK: Private initializing
        
        // Initializes a header, column or row node.
        // Initially all references to linked nodes point to the node itself.
        private init(_ r: RowId?, _ c: NodeId, _ i: NodeId, _ m: Bool) {
            (id, left, right, up, down, row, column, mandatory) = (i, i, i, i, i, r, c, m)
        }
        
    }
    
    // MARK: Private stored properties
    
    // Node store.
    private var nodes: [Node]
    
    // MARK: Private computed properties
    
    // Id generator.
    private var nextId: NodeId {
        nodes.count
    }
    
    // MARK: Initizaling
    
    // Initializes the node store with given initial capacity.
    init(size: Int) {
        nodes = [Node]()
        nodes.reserveCapacity(size)
    }
    
    // MARK: Creating nodes
    
    // Creates a column node and adds it to the store.
    // Returns the column node.
    mutating func makeColumnNode(mandatory: Bool) -> NodeId {
        storeNode(Node(column: nextId, mandatory: mandatory))
    }
    
    // Creates the header node with given column nodes and adds it to the store.
    // Returns the header node.
    mutating func makeHeaderNode(columnNodes: [NodeId]) -> NodeId {
        let header = storeNode(Node(header: nextId))
        let _ = columnNodes.reduce(header) { node, column in insertNode(column, after: node) }
        
        return header
    }
    
    // Makes a node for given row, column and adds it to the store.
    // Returns the node.
    mutating func makeNode(row: RowId, column: NodeId) -> NodeId {
        storeNode(Node(row: row, column: column, id: nextId))
    }
    
    // MARK: Creating grid
    
    // Inserts a new node for given row at the bottom of the column.
    // Returns the new node.
    mutating func appendNode(row: RowId, column: NodeId) -> NodeId {
        let columnNode = nodes[column]
        let node = makeNode(row: row, column: column)
        
        nodes[node].up = columnNode.up
        nodes[node].down = columnNode.id
        nodes[columnNode.up].down = node
        nodes[columnNode.id].up = node
        nodes[columnNode.id].size += 1
        
        return node
    }
    
    // Inserts the node on the right of the other node.
    // Returns the inserted node.
    mutating func insertNode(_ node: NodeId, after left: NodeId) -> NodeId {
        let right = nodes[left].right
        
        nodes[node].left = left
        nodes[node].right = right
        nodes[right].left = node
        nodes[left].right = node
        
        return node
    }
    
    // MARK: Accessing
    
    // Returns the column of given node.
    func column(of node: NodeId) -> NodeId {
        nodes[node].column
    }
    
    // Returns the node directly below given node.
    func down(_ node: NodeId) -> NodeId {
        nodes[node].down
    }
    
    // Returns the node directly to the left of given node.
    func left(_ node: NodeId) -> NodeId {
        nodes[node].left
    }
    
    // Returns the node directly to the right of given node.
    func right(_ node: NodeId) -> NodeId {
        nodes[node].right
    }
    
    // Returns the node directly above given node.
    func up(_ node: NodeId) -> NodeId {
        nodes[node].up
    }
    
    // Returns the row reference of given node.
    func row(of node: NodeId) -> RowId? {
        nodes[node].row
    }
    
    // MARK: DancingLinks operations
    
    // Covers (removes node from the grid) the node by
    // * unlinking it's column from its row,
    // * unlinking any node that uses the column's constraint from that node's column.
    // Updates the column sizes.
    mutating func coverNode(_ node: NodeId) {
        let columnNode = column(of: node)
        var vNode = down(columnNode)
        
        unlinkFromRow(node: columnNode)
        while vNode != columnNode {
            var hNode = right(vNode)
            
            while hNode != vNode {
                unlinkFromColumn(node: hNode)
                updateColumnSize(of: hNode, with: -1)
                hNode = right(hNode)
            }
            vNode = down(vNode)
        }
    }
    
    // Uncovers (re-inserts node in the grid) the node by
    // * re-linking any node that uses this column's constraint in that node's column,
    // * re-linking it's column in its row.
    // Updates the column sizes.
    mutating func uncoverNode(_ node: NodeId) {
        let columnNode = column(of: node)
        var vNode = up(columnNode)
        
        while vNode != columnNode {
            var hNode = left(vNode)
            
            while hNode != vNode {
                updateColumnSize(of: hNode, with: 1)
                relinkInColumn(node: hNode)
                hNode = left(hNode)
            }
            vNode = up(vNode)
        }
        relinkInRow(node: columnNode)
    }
    
    // MARK: Search strategies
    
    // Returns the first mandatory column, or nil if none found.
    // Note. Mandatory columns precede optional columns in the list.
    func firstColumn(header: NodeId) -> NodeId? {
        let columnId = nodes[header].right
        guard columnId != header else { return nil }
        
        let column = nodes[columnId]
        guard column.mandatory else { return nil }
        
        return columnId
    }
    
    // Returns the first mandatory column with the least rows, or nil if none found.
    // Note. Mandatory columns precede optional columns in the list.
    func smallestColumn(header: NodeId) -> NodeId? {
        let columnId = nodes[header].right
        guard columnId != header else { return nil }
        
        var column = nodes[columnId]
        guard column.mandatory else { return nil }
        
        var node = nodes[column.right]
        
        while node.mandatory {
            if node.size < column.size { column = node }
            node = nodes[node.right]
        }
        
        return column.id
    }
    
    // MARK: Testing
    
    // MARK: Private creating nodes
    
    // Adds the node to the store.
    // Returns the node.
    private mutating func storeNode(_ node: Node) -> NodeId {
        nodes.append(node)
        
        return node.id
    }
    
    // MARK: Private accessing
    
    // Update the column size with given amount.
    private mutating func updateColumnSize(of node: NodeId, with amount: Int) {
        let columnNode = column(of: node)
        
        nodes[columnNode].size += amount
    }
    
    // MARK: Private DancingLinks operations
    
    // Re-inserts the node in its row.
    private mutating func relinkInRow(node: NodeId) {
        let left = nodes[node].left, right = nodes[node].right
        
        nodes[left].right = node
        nodes[right].left = node
    }
    
    // Re-inserts the node in its column.
    private mutating func relinkInColumn(node: NodeId) {
        let down = nodes[node].down, up = nodes[node].up
        
        nodes[up].down = node
        nodes[down].up = node
    }
    
    // Removes the node from its row.
    private mutating func unlinkFromRow(node: NodeId) {
        let left = nodes[node].left, right = nodes[node].right
        
        nodes[left].right = right
        nodes[right].left = left
    }
    
    // Removes the node from its column.
    private mutating func unlinkFromColumn(node: NodeId) {
        let down = nodes[node].down, up = nodes[node].up
        
        nodes[up].down = down
        nodes[down].up = up
    }
    
}


/**
 Implementation of the DancingLinks algorithm using structs for nodes.
 */
public class StructuredDancingLinks: DancingLinks {
    
    // For each row in the grid, adds a node with given row id for each column in the row.
    fileprivate func makeNodes<G, R>(grid: G, store: inout Store<R>) -> Store<R>.NodeId where G: Grid, R == G.RowId {
        let columnNodes = (0 ..< grid.constraints + grid.optionalConstraints).map { i in store.makeColumnNode(mandatory: i < grid.constraints) }
        let header = store.makeHeaderNode(columnNodes: columnNodes)
        
        grid.generateRows { (row: R, columns: Int...) in
            guard let c = columns.first else { return }
            
            _ = columns.dropFirst().reduce(store.appendNode(row: row, column: columnNodes[c])) { n, c in store.insertNode(store.appendNode(row: row, column: columnNodes[c]), after: n) }
        }
        
        return header
    }
    
    // Returns a mandatory column node according to the chosen strategy, or nil if none found.
    fileprivate func selectColumn<R>(store: inout Store<R>, header: Store<R>.NodeId, strategy: SearchStrategy) -> Store<R>.NodeId? {
        switch strategy {
        case .naive: return store.firstColumn(header: header)
        case .minimumSize: return store.smallestColumn(header: header)
        }
    }
        
    /// Reads a sparse grid of rows and injects each solution and the search state in the handler.
    /// Grid and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    public override func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId {
        guard grid.constraints > 0 else { return }
        
        var store = Store<R>(size: 2 * (grid.constraints + grid.optionalConstraints) + 1)
        let header = makeNodes(grid: grid, store: &store)
        let state = SearchState()
        var solvedRows = [R]()
        
        // Recursively search for a solution until we have exhausted all options.
        // When all columns have been covered, pass the solution to the handler.
        // Undo covering operations when backtracking.
        // Stop searching when the handler sets the search state to terminated.
        // Note. Passing variables in the scope as function parameters improves performance.
        func solve(_ store: inout Store<R>, _ header: Store<R>.NodeId, _ state: SearchState, _ solvedRows: inout [R]) -> () {
            guard let column = selectColumn(store: &store, header: header, strategy: strategy) else { return handler(Solution(rows: solvedRows), state) }
            var vNode = store.down(column)
            
            store.coverNode(column)
            while vNode != column {
                var hNode = store.right(vNode)
                
                solvedRows.append(store.row(of: vNode)!)
                while hNode != vNode {
                    store.coverNode(hNode)
                    hNode = store.right(hNode)
                }
                
                solve(&store, header, state, &solvedRows)
                guard !state.terminated else { return }
                
                solvedRows.removeLast()
                hNode = store.left(vNode)
                while hNode != vNode {
                    store.uncoverNode(hNode)
                    hNode = store.left(hNode)
                }
                vNode = store.down(vNode)
            }
            store.uncoverNode(column)
        }

        solve(&store, header, state, &solvedRows)
     }
    
}

/**
 Non-recursive implementation of the DancingLinks algorithm using structs for nodes.
 Experimental (cf. article *Non-Recursive Dancing Links* by Jan Magne Tjensvold).
 */
public class StructuredDancingLinksNR: StructuredDancingLinks {
    
    /// Reads a sparse grid of rows and injects each solution and the search state in the handler.
    /// Grid and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    public override func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId {
        guard grid.constraints > 0 else { return }
        
        var store = Store<R>(size: 2 * (grid.constraints + grid.optionalConstraints) + 1)
        let header = makeNodes(grid: grid, store: &store)
        let state = SearchState()
        var solvedRows = [R]()
        var k = 0
        var stack = [Store<R>.NodeId]()
        var backtrack = false
        
        guard var column = selectColumn(store: &store, header: header, strategy: strategy) else { return }
        var vNode = store.down(column)
        var hNode: Store<R>.NodeId
        
        store.coverNode(column)
        while true {
            while vNode != column || backtrack {
                if !backtrack {
                    solvedRows.append(store.row(of: vNode)!)
                    hNode = store.right(vNode)
                    while hNode != vNode {
                        store.coverNode(hNode)
                        hNode = store.right(hNode)
                    }
                }
                if header == store.right(header) {
                    handler(Solution(rows: solvedRows), state)
                    if state.terminated { return }
                } else {
                    if (!backtrack) {
                        k += 1
                        stack.append(vNode)
                        guard let newColumn = selectColumn(store: &store, header: header, strategy: strategy) else { return }
                        column = newColumn
                        store.coverNode(column)
                        vNode = store.down(column)
                        continue
                    }
                    backtrack = false
                    vNode = stack.popLast()!
                    column = store.column(of: vNode)
                    k -= 1
                }
                
                solvedRows.removeLast()
                hNode = store.left(vNode)
                while hNode != vNode {
                    store.uncoverNode(hNode)
                    hNode = store.left(hNode)
                }
                vNode = store.down(vNode)
            }
            store.uncoverNode(column)
            if k > 0 { backtrack = true } else { return }
        }
    }
    
}
