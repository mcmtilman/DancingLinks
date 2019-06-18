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
        
        // Reference of this node in the store.
        let id: NodeId
        
        // Client row reference. Same for all nodes in the same row.
        // Nil for headers and columns.
        let row: RowId?
        
        // References to left, right, up and down nodes in the store.
        var down, left, right, up: NodeId
        
        // Number of row nodes in a column. Only used by column nodes.
        var size = 0
        
        // MARK: Computed properties
        
        // Returns true if this node is a column (or header) node, false otherwise.
        var isColumn: Bool {
            row == nil
        }
        
        // MARK: Initializing
        
        // Initializes a column node.
        init(column: NodeId) {
            self.init(nil, column, column)
        }
        
        // Initializes the header node.
        init(header: NodeId) {
            self.init(nil, 0, header)
        }
        
        // Initializes a row node.
        init(row: RowId, column: NodeId, id: NodeId) {
            self.init(row, column, id)
        }
        
        // MARK: Private initializing
        
        // Initializes a header, column or row node.
        // Initially all references to linked nodes point to the node itself.
        private init(_ r: RowId?, _ c: NodeId, _ i: NodeId) {
            (id, left, right, up, down, row, column) = (i, i, i, i, i, r, c)
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
    mutating func makeColumnNode() -> NodeId {
        storeNode(Node(column: nextId))
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
    
    // Returns the row referebce of given node.
    func row(of node: NodeId) -> RowId? {
        nodes[node].row
    }
    
    // MARK: DancingLinks operations
    
    // Covers (removes node from the grid) the node by
    // * unlinking it from its row,
    // * unlinking any node that uses the column's constraint from that node's column.
    // Updates the column sizes.
    mutating func coverNode(_ node: NodeId) {
        let columnNode = column(of: node)
        var vNode = nodes[columnNode].down
        
        unlinkFromRow(node: columnNode)
        while vNode != columnNode {
            var hNode = nodes[vNode].right
            
            while hNode != vNode {
                unlinkFromColumn(node: hNode)
                nodes[nodes[hNode].column].size -= 1
                hNode = nodes[hNode].right
            }
            vNode = nodes[vNode].down
        }
    }
    
    // Uncovers (re-inserts node in the grid) the node by
    // * re-linking any node that uses this column's constraint in that node's column,
    // * re-linking it in its row.
    // Updates the column sizes.
    mutating func uncoverNode(_ node: NodeId) {
        let columnNode = column(of: node)
        var vNode = nodes[columnNode].up
        
        while vNode != columnNode {
            var hNode = nodes[vNode].left
            
            while hNode != vNode {
                nodes[nodes[hNode].column].size += 1
                relinkInColumn(node: hNode)
                hNode = nodes[hNode].left
            }
            vNode = nodes[vNode].up
        }
        relinkInRow(node: columnNode)
    }
    
    // Returns the first column with the least rows.
    func smallestColumn(header: NodeId) -> NodeId {
        var column = nodes[nodes[header].right], node = nodes[column.right]

        while node.id != header {
            if node.size < column.size { column = node }
            node = nodes[node.right]
        }

        return column.id
    }

    // MARK: Private creating nodes
    
    // Adds the node to the store.
    // Returns the node.
    private mutating func storeNode(_ node: Node) -> NodeId {
        nodes.append(node)
        
        return node.id
    }
    
    // MARK: Private accessing
    
    // Returns the column of given node.
    private func column(of node: NodeId) -> NodeId {
        let nodeOrColumn = nodes[node]
        
        return nodeOrColumn.isColumn ? node : nodeOrColumn.column
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
    
    /// Reads a sparse grid of rows and injects each solution and the search state in the handler.
    /// Grid and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    public func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId {
        guard grid.constraints > 0 else { return }
        var store = Store<R>(size: 2 * grid.constraints + 1)
        let columnNodes = (0 ..< grid.constraints).map { _ in store.makeColumnNode() }
        let header = store.makeHeaderNode(columnNodes: columnNodes)
        let state = SearchState()
        var solvedRows = [R]()
        
        // For each row in the grid, adds a node with given row id for each column in the row.
        func addRowNodes() {
            grid.generateRows { (row: R, columns: Int...) in
                guard let c = columns.first else { return }
                
                _ = columns.dropFirst().reduce(store.appendNode(row: row, column: columnNodes[c])) { n, c in store.insertNode(store.appendNode(row: row, column: columnNodes[c]), after: n) }
            }
        }
        
        // Returns a column node according to the chosen strategy.
        // The header has at least one linked column.
        func selectColumn() -> Store<R>.NodeId {
            switch strategy {
            case .naive: return store.right(header)
            case .minimumSize: return store.smallestColumn(header: header)
            }
        }
        
        // Recursively search for a solution until we have exhausted all options.
        // When all columns have been covered, pass the solution to the handler.
        // Undo covering operations when backtracking.
        // Stop searching when the handler sets the search state to terminated.
        func solve() {
            guard store.right(header) != header else { return handler(Solution(rows: solvedRows), state) }
            let column = selectColumn()
            var vNode = store.down(column)
            
            store.coverNode(column)
            while vNode != column {
                var hNode = store.right(vNode)
                
                solvedRows.append(store.row(of: vNode)!)
                while hNode != vNode {
                    store.coverNode(hNode)
                    hNode = store.right(hNode)
                }
                
                solve()
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
        
        addRowNodes()
        solve()
    }
    
}
