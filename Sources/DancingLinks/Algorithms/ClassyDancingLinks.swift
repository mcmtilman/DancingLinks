//
//  ClassyDancingLinks.swift
//
//  Created by Michel Tilman on 14/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

// A node in the grid. Subclasses represent column and header nodes.
fileprivate class Node<RowId> where RowId: Hashable {
    
    // Column node referencing the row nodes in the same column.
    class Column: Node {
        
        // MARK: Stored properties
        
        // Strong references to the nodes of this column, separate from links.
        // Used for release process.
        private var nodes = [Node]()
        
        // Number of row nodes in this column.
        // Varies dynamically during covering/ uncovering process.
        // At all times <= nodes.count.
        private (set) var size = 0
        
        // MARK: Initializing
        
        // Initializes the column to this node.
        override init() {
            super.init()
            _column = self
        }
        
        // Initializes the row node's row id and column.
        // Fails for columns.
        init(row: RowId, column: Column) {
            assert(false, "Not supported for columns")
        }

        // MARK: Releasing
        
        // Releases the nodes in this column and clears the links to other nodes.
        override func release() {
            super.release()
            for node in nodes { node.release() }
            nodes = []
        }
        
        // MARK: DancingLinks search operations
        
        // Covers (removes node from the grid) this column node by
        // * unlinking it from its row,
        // * unlinking any node that uses this column's constraint from that node's column.
        // Updates the column sizes.
       override func cover() {
            unlinkFromRow()
            for vNode in downNodes {
                for hNode in vNode.rightNodes {
                    hNode.unlinkFromColumn()
                    hNode.column.size -= 1
                }
            }
        }
        
        // Uncovers (re-inserts node in the grid) this column node by
        // * re-linking any node that uses this column's constraint in that node's column,
        // * re-linking this node in its row.
        // Updates the column sizes.
        override func uncover() {
            for vNode in upNodes {
                for hNode in vNode.leftNodes {
                    hNode.relinkInColumn()
                    hNode.column.size += 1
                }
            }
            relinkInRow()
        }
        
        // Inserts a new node for given row at the bottom of the column.
        // Returns the new node.
        // Updates the column sizes.
        func appendNode(row: RowId) -> Node {
            let node = Node(row: row, column: self)
            
            nodes.append(node)
            node.up = up
            node.down = self
            up.down = node
            up = node
            size += 1

            return node
        }
        
    }
    
    // A header node shares its row with the column nodes.
    // It has no row nodes in its column.
    class Header: Column {
        
        // MARK: Stored properties
        
        // Strong references to the column nodes for this header, separate from the grid links.
        private var columns: [Column]
        
        // MARK: Initializing
        
        // Initializes the header node with the column nodes.
        // Constructs a row consting of the header node and the column nodes.
        init(_ columns: [Column]) {
            self.columns = columns
            super.init()
            for column in columns {
                _ = left.insertRightNode(column)
            }
        }
        
        // MARK: Releasing
        
        // Releases the columns and clears the links to the other nodes.
        override func release() {
            super.release()
            for column in columns {
                column.release()
            }
            columns = []
        }
        
        // MARK: Subscript accessing
        
        /// Returns the column at given position.
        /// Fails if out of range.
        subscript(index: Int) -> Column {
            columns[index]
        }
        
    }
    
    // MARK: Private stored properties
    
    // Row and column properties forming horizontal and vertical doubly-linked lists.
    // Not nil after initialization until explicit release.
    // Private to hide the implicitly unwrapped behavior to client (this has a cost).
    private var _down, _left, _right, _up: Node!
    
    // Column node.
    // Points to the node itself in case of headers and columns.
    // Not nil after initialization until explicit release.
    // Private to hide the implicitly unwrapped behavior to the client (this has a cost).
    private var _column: Column!
    
    // MARK: Computed properties
    
    // The column node of this node, or the node itself in case of header and column nodes.
    // Hides the implicitly unwrapped behavior of the underlying stored property.
    var column: Column {
        set { _column = newValue }
        get { _column }
    }
    
    // The node immediately below this node (may be the node itself).
    // Hides the implicitly unwrapped behavior of the underlying stored property.
    var down: Node {
        set { _down = newValue }
        get { _down }
    }
    
    // The node immediately to the left of this node (may be the node itself).
    // Hides the implicitly unwrapped behavior of the underlying stored property.
    var left: Node {
        set { _left = newValue }
        get { _left }
    }
    
    // The node immediately to the right of this node (may be the node itself).
    // Hides the implicitly unwrapped behavior of the underlying stored property.
    var right: Node {
        set { _right = newValue }
        get { _right }
    }
    
    // The node immediately above this node (may be the node itself).
    // Hides the implicitly unwrapped behavior of the underlying stored property.
    var up: Node {
        set { _up = newValue }
        get { _up }
    }
    
    // Client row reference. Same for all nodes in the same row.
    // Nil for headers and columns.
    var row: RowId?
    
    // MARK: Initializing
    
    // Initializes the linked node properties to this node.
    init() {
        (_left, _down, _right, _up) = (self, self, self, self)
    }
    
    // Initializes the row node's row id and column.
    convenience init(row: RowId, column: Column) {
        self.init()
        self.row = row
        self.column = column
    }
    
    // MARK: Releasing
    
    // Clears the links to other nodes.
    func release() {
        (_left, _down, _right, _up, _column) = (nil, nil, nil, nil, nil)
    }
    
    // MARK: DancingLinks search operations
    
    // Covers the node's column node.
    // See selectColumn method for purpose of this method.
    func cover() {
        column.cover()
    }
    
    // Uncovers the node;s column node.
    // See selectColumn method for purpose of this method.
    func uncover() {
        column.uncover()
    }
    
    // Inserts the node on the right of this node.
    // Returns the inserted node.
    func insertRightNode(_ node: Node) -> Node {
        node.left = self
        node.right = right
        right.left = node
        right = node
        
        return node
    }
    
    // Re-inserts the node in its row.
    func relinkInRow() {
        left.right = self
        right.left = self
    }
    
    // Re-inserts the node in its column.
    func relinkInColumn() {
        up.down = self
        down.up = self
    }
    
    // Removes the node from its row.
    func unlinkFromRow() {
        left.right = right
        right.left = left
    }
    
    // Removes the node from its column.
    func unlinkFromColumn() {
        up.down = down
        down.up = up
    }
    
}


// Iterates the nodes in four directions: down, left, right, up, skipping the start node.
// Iteration halts when we return to the start node.
fileprivate extension Node {
    
    // Uses a function to calculate the next node from the current node.
    // Stops when the next node is the same as the start node.
    struct Iterator: Sequence, IteratorProtocol {
        
        // MARK: Stored properties
        
        // Calculates the next node from the current node.
        let nextNode: (Node) -> Node
        
        // Start node. Iteration stops when nextNode === start.
        let start: Node
        
        // Current node.
        var node: Node
        
        // MARK: Initializing
        
        // Initializes the iterator with a start (also end) node, and a function computing the next node.
        init(_ start: Node, _ nextNode: @escaping (Node) -> Node) {
            self.nextNode = nextNode
            self.start = start
            self.node = start
        }
        
        // Returns the next node or nil as soon as we return to the start node.
        mutating func next() -> Node? {
            node = nextNode(node)
            
            return node === start ? nil : node
        }
        
    }
    
    // Iterates through the nodes in a column, starting at the node immediately below the start node.
    var downNodes: Iterator {
        Iterator(self) { $0.down }
    }

    // Iterates through the nodes in a row, starting at the node immediately to the left of the start node.
    var leftNodes: Iterator {
        Iterator(self) { $0.left }
    }

    // Iterates through the nodes in a row, starting at the node immediately to the right of the start node.
    var rightNodes: Iterator {
        Iterator(self) { $0.right }
    }

    // Iterates through the nodes in a column, starting at the node immediately above the start node.
    var upNodes: Iterator {
        Iterator(self) { $0.up }
    }

}

/**
 Implementation of the DancingLinks algorithm using classes for nodes.
 */
class ClassyDancingLinks: DancingLinks {

    /// Reads a sparse grid of rows and injects each solution and the search state in the handler.
    /// Grid and solution use the same type of row identification.
    /// The algorithm must stop when the search space has been exhausted or when the handler instructs it to stop.
    /// The handler can set the search state to terminated.
    /// The search strategy may affect the performance and the order in which solutions are generated.
    public func solve<G, R>(grid: G, strategy: SearchStrategy, handler: (Solution<R>, SearchState) -> ()) where G: Grid, R == G.RowId {
        guard grid.constraints > 0 else { return }
        
        let header = Node<R>.Header((0 ..< grid.constraints).map { _ in Node.Column() })
        let state = SearchState()
        var rows = [R]()
        
        func addRowNodes() {
            grid.generateRows { (row: R, columns: Int...) in
                guard let column = columns.first else { return }

                _ = columns.dropFirst().reduce(header[column].appendNode(row: row)) { node, column in node.insertRightNode(header[column].appendNode(row: row)) }
            }
        }

        // Returns a column node according to the chosen strategy.
        // The header has at least one linked column.
        // Note. The return type could be Column. We avoid the cast and use delegation to the column node
        // itself in the cover and uncover operations in class Node.
        func selectColumn() -> Node<R> {
            guard strategy == .minimumSize else { return header.right }
            var column = header.right
            
            for node in header.rightNodes where node.column.size < column.column.size {
                column = node
            }

            return column
        }
        
        // Recursively search for a solution until we have exhausted all options.
        // When all columns have been covered, pass the solution to the handler.
        // Undo covering operations when backtracking.
        // Stop searching when the handler sets the search state to terminated.
        // Note. Parameter k is not really needed but may be useful for e.g. debugging.
        func solve(_ k: Int) {
            guard header.right !== header else { return handler(Solution(rows: rows), state) }

            let column = selectColumn()
            
            column.cover()
            for vNode in column.downNodes {
                rows.append(vNode.row!)
                for node in vNode.rightNodes {
                    node.cover()
                }
                solve(k + 1)
                guard !state.terminated else { return }
                rows.removeLast()
                for node in vNode.leftNodes {
                    node.uncover()
                }
            }
            column.uncover()
        }

        addRowNodes()
        _ = solve(0)
        header.release()
    }
    
}
