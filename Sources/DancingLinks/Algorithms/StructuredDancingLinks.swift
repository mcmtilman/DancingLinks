//
//  StructuredDancingLinks.swift
//
//  Created by Michel Tilman on 08/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 Manages the nodes.
 Most node-related operations are handled here for ease of use.
 */
fileprivate struct Store<RowId> where RowId: Hashable {

    // Represents a row node, a column node or a header node.
    struct Node: Equatable {
        
        // Nodes with same reference are equal.
        static func == (lhs: Node, rhs: Node) -> Bool {
            lhs.id == rhs.id
        }

        // MARK: Stored properties
        
        // Reference to the column node in the store.
        let column: Int
        
        // Reference of this node in the store.
        let id: Int
        
        // Client row reference. Same for all nodes in the same row.
        // Nil for headers and columns.
        let row: RowId?
        
        // References to left, right, up and down nodes in the store.
        var down, left, right, up: Int
        
        // Number of row nodes in a column. Only used by column nodes.
        var size = 0
        
        // MARK: Computed properties
        
        // Returns true if this node is a column node, false otherwise.
        var isColumn: Bool {
            row == nil
        }
        
        // MARK: Initializing
        
        // Initializes a column node.
        init(column: Int, id: Int) {
            self.init(nil, column, id)
        }
        
        // Initializes the header node.
        init(headerId: Int) {
            self.init(nil, 0, headerId)
        }
        
        // Initializes a row node.
        init(row: RowId, column: Int, id: Int) {
            self.init(row, column, id)
        }
        
        // MARK: Private initializing
        
        // Initializes a header, column or row node.
        // Initially all references to linked nodes point to the node itself.
        private init(_ r: RowId?, _ c: Int, _ i: Int) {
            (id, left, right, up, down, row, column) = (i, i, i, i, i, r, c)
        }
        
    }
    
    // MARK: Stored properties
    
    // Node store.
    var nodes: [Node]
    
    // MARK: Computed properties
    
    // ID generator.
    var nextId: Int {
        nodes.count
    }
    
    // MARK: Initizaling
    
    // Initializes the node store with given initial capacity.
    init(size: Int) {
        nodes = [Node]()
        nodes.reserveCapacity(size)
    }

    // MARK: Subscript accessing
    
    // Returns the node with given id.
    subscript(node: Int) -> Node {
        nodes[node]
    }
    
    // MARK: Creation operations for the grid.
    
    // Inserts a new node for given row at the bottom of the column.
    // Returns the new node.
    mutating func appendNode(row: RowId, column: Int) -> Node {
        let columnNode = nodes[column]
        let node = makeNode(row: row, column: column)
        
        nodes[node.id].up = columnNode.up
        nodes[node.id].down = columnNode.id
        nodes[columnNode.up].down = node.id
        nodes[columnNode.id].up = node.id
        nodes[columnNode.id].size += 1

        return nodes[node.id]
    }

    // Inserts the node on the right of the other node.
    // Returns the inserted node.
    mutating func insertNode(_ node: Node, after left: Node) -> Node {
        nodes[node.id].left = left.id
        nodes[node.id].right = left.right
        nodes[left.right].left = node.id
        nodes[left.id].right = node.id

        return nodes[node.id]
    }

    // MARK: Accessing
    
    // Returns the node directly below given node.
    func down(_ node: Node) -> Node {
        nodes[node.down]
    }

    // Returns the node directly to the left of given node.
    func left(_ node: Node) -> Node {
        nodes[node.left]
    }
    
    // Returns the node directly to the right of given node.
    func right(_ node: Node) -> Node {
        nodes[node.right]
    }
    
    // Returns the node directly above given node.
    func up(_ node: Node) -> Node {
        nodes[node.up]
    }

    // Returns the column of given node.
    func column(of node: Node) -> Node {
        node.isColumn ? node : nodes[node.column]
    }
    
    // MARK: DancingLinks search operations
    
    // Covers (removes node from the grid) the node by
    // * unlinking it from its row,
    // * unlinking any node that uses the column's constraint from that node's column.
    // Updates the column sizes.
    mutating func coverNode(_ node: Node) {
        let columnNode = column(of: node)
        var vNode = down(columnNode)
        
        unlinkFromRow(node: columnNode)
        while vNode != columnNode {
            var hNode = right(vNode)

            while hNode != vNode {
                unlinkFromColumn(node: hNode)
                nodes[hNode.column].size -= 1
                hNode = right(hNode)
            }
            vNode = down(vNode)
        }
    }
    
    // Uncovers (re-inserts node in the grid) the node by
    // * re-linking any node that uses this column's constraint in that node's column,
    // * re-linking it in its row.
    // Updates the column sizes.
    mutating func uncoverNode(_ node: Node) {
        let columnNode = column(of: node)
        var vNode = up(columnNode)

        while vNode != columnNode {
            var hNode = left(vNode)

            while hNode != vNode {
                nodes[hNode.column].size += 1
                relinkInColumn(node: hNode)
                hNode = left(hNode)
            }
            vNode = up(vNode)
        }
        relinkInRow(node: columnNode)
    }
    
    // Re-inserts the node in its row.
    mutating func relinkInRow(node: Node) {
        nodes[node.left].right = node.id
        nodes[node.right].left = node.id
    }
    
    // Re-inserts the node in its column.
    mutating func relinkInColumn(node: Node) {
        nodes[node.up].down = node.id
        nodes[node.down].up = node.id
    }

    // Removes the node from its row.
    mutating func unlinkFromRow(node: Node) {
        nodes[node.left].right = node.right
        nodes[node.right].left = node.left
    }
    
    // Removes the node from its column.
    mutating func unlinkFromColumn(node: Node) {
        nodes[node.up].down = node.down
        nodes[node.down].up = node.up
    }
    
    // MARK: Creating nodes
    
    // Creates a column node and adds it to the store.
    // Returns the column node.
    mutating func makeColumnNode(column: Int) -> Node {
        storeNode(Node(column: column, id: nextId))
    }
    
    // Creates the header node with given column nodes and adds it to the store.
    // Returns the header node.
    mutating func makeHeaderNode(columnNodes: [Node]) -> Node {
        let header = storeNode(Node(headerId: nextId))
        let _ = columnNodes.reduce(header) { node, column in insertNode(column, after: node) }
        
        return nodes[header.id]
    }

    // Makes a node for given row, column and adds it to the store.
    // Returns the node.
    mutating func makeNode(row: RowId, column: Int) -> Node {
        storeNode(Node(row: row, column: column, id: nextId))
    }

    // MARK: Private creating nodes
    
    // Adds the node to the store.
    // Returns the node.
    private mutating func storeNode(_ node: Node) -> Node {
        nodes.append(node)
        
        return node
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
        let headerId = store.makeHeaderNode(columnNodes: (0 ..< grid.constraints).map { store.makeColumnNode(column: $0) }).id
        let state = SearchState()
        var rows = [R]()

        // For each row in the grid, adds a node with given row id for each column in the row.
        func addRowNodes() {
            grid.generateRows { (row: R, columns: Int...) in
                guard let column = columns.first else { return }
                
                _ = columns.dropFirst().reduce(store.appendNode(row: row, column: column)) { node, column in store.insertNode(store.appendNode(row: row, column: column), after: node) }
            }
        }
        
        // Returns a column node according to the chosen strategy.
        // The header has at least one linked column.
        func selectColumn(_ header: Store<R>.Node) -> Store<R>.Node {
            guard strategy == .minimumSize else { return store.right(header) }
            var column = store.right(header), node = store.right(column)
            
            while node != header {
                if node.size < column.size { column = node }
                node = store.right(node)
            }
            
            return column
        }
        
        // Recursively search for a solution until we have exhausted all options.
        // When all columns have been covered, pass the solution to the handler.
        // Undo covering operations when backtracking.
        // Stop searching when the handler sets the search state to terminated.
        func solve() {
            let header = store[headerId]
            guard store.right(header) != header else { return handler(Solution(rows: rows), state) }
            let column = selectColumn(header)
            var vNode = store.down(column)
            
            store.coverNode(column)
            while vNode != column {
                var hNode = store.right(vNode)

                rows.append(vNode.row!)
                while hNode != vNode {
                    store.coverNode(hNode)
                    hNode = store.right(hNode)
                }
                
                solve()
                guard !state.terminated else { return }
                
                rows.removeLast()
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
