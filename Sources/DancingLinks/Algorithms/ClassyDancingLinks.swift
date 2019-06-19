//
//  ClassyDancingLinks.swift
//
//  Created by Michel Tilman on 14/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

// A node in the grid. Subclasses represent row, column and header nodes.
fileprivate class Node<RowId> where RowId: Hashable {
    
    // Row node at the intersection of a row and a constraint column.
    class Row: Node {
        
        // MARK: Initializing
        
        // Initializes the row node's reference and column.
        convenience init(row: RowId, column: Column) {
            self.init()
            self.row = row
            self.column = column
        }
        
    }
    
    // Column node referencing the row nodes in the same column.
    // Is its own column node.
    class Column: Node {
        
        // MARK: Stored properties
        
        // Flag denoting if the colum node is mandatory.
        // False for header nodes.
        let mandatory: Bool
        
        // Number of row nodes in a column. Zero for header nodes.
        // Varies dynamically during the covering / uncovering process.
        // At all times <= nodes.count.
        private (set) var size = 0
        
        // MARK: Private stored properties

        // References to the row nodes of this column, separate from the links.
        // Used for release process.
        private var nodes = [Row]()
        
        // MARK: Initializing
        
        // Sets the mandatory flag and initializes the column to this node.
        init(mandatory: Bool) {
            self.mandatory = mandatory
            super.init()
            column = self
        }
        
        // MARK: Releasing
        
        // Releases the nodes in this column and clears the links to other nodes.
        override func release() {
            super.release()
            for node in nodes {
                node.release()
            }
            nodes = []
        }
        
        // MARK: Constructing grid
        
        // Inserts a new node for given row at the bottom of the column.
        // Returns the new node.
        // Increments the column size.
        func appendNode(row: RowId) -> Node {
            let node = Row(row: row, column: self)

            nodes.append(node)
            node.up = up
            node.down = self
            up.down = node
            up = node
            size += 1
            
            return node
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
        
    }
    
    // A header node shares its row with the column nodes.
    // It has no row nodes in its column.
    // Is its own column node.
    class Header: Column {
        
        // MARK: Private stored properties
        
        // References to the column nodes for this header, separate from the links.
        // Used for release process.
        private var columns: [Column]
        
        // MARK: Initializing
        
        // Initializes the header node with the column nodes.
        // Constructs a row consting of the header node and the column nodes.
        init(columns: [Column]) {
            self.columns = columns
            super.init(mandatory: false)
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
    
    // MARK: Stored properties
    
    // Column node.
    // Points to the node itself in case of headers and columns.
    // Not nil after initialization in subclasses until explicit release.
    private (set) var column: Column!
    
    // Client row reference. Same for all nodes in the same row.
    // Nil for headers and columns.
    private (set) var row: RowId?
    
    // Row and column properties forming horizontal and vertical doubly-linked lists.
    // Not nil after initialization until explicit release.
    var down, left, right, up: Node!
    
    // MARK: Private initializing
    
    // Initializes the linked node properties to this node.
    private init() {
        (left, down, right, up) = (self, self, self, self)
    }
    
    // MARK: Releasing
    
    // Clears the links to other nodes.
    func release() {
        (left, down, right, up, column) = (nil, nil, nil, nil, nil)
    }
    
    // MARK: Constructing grid
    
    // Inserts the node on the right of this node.
    // Returns the inserted node.
    func insertRightNode(_ node: Node) -> Node {
        node.left = self
        node.right = right
        right.left = node
        right = node
        
        return node
    }
    
    // MARK: DancingLinks search operations delegation
    
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
    
    // MARK: DancingLinks search operations
    
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
extension Node {
    
    // Direction of iteration:
    // * along the row nodes (left, right)
    // * along the column nodes (down, up).
    enum Direction {
        case down, left, right, up
    }
    
    // Calculates the next node from the current node.
    // Stops when the next node is the same as the start node.
    struct Iterator: Sequence, IteratorProtocol {
        
        // MARK: Stored properties
        
        // Direction of iteration
        private let direction: Direction
        
        // Start node. Iteration stops when nextNode === start.
        private let start: Node
        
        // Current node.
        private var node: Node
        
        // MARK: Initializing
        
        // Initializes the iterator with a start (also end) node, and a function computing the next node.
        init(_ start: Node, _ direction: Direction) {
            self.direction = direction
            self.start = start
            self.node = start
        }
        
        // MARK: Iterating
        
        // Returns the next node or nil as soon as we return to the start node.
        mutating func next() -> Node? {
            switch direction {
            case .down: node = node.down
            case .left: node = node.left
            case .right: node = node.right
            case .up: node = node.up
            }
            
            return node === start ? nil : node
        }
    }
    
    // MARK: Default iterators
    
    // Iterates through the nodes in a column, starting at the node immediately below the start node.
    var downNodes: Iterator {
        Iterator(self, .down)
    }
    
    // Iterates through the nodes in a row, starting at the node immediately to the left of the start node.
    var leftNodes: Iterator {
        Iterator(self, .left)
    }
    
    // Iterates through the nodes in a row, starting at the node immediately to the right of the start node.
    var rightNodes: Iterator {
        Iterator(self, .right)
    }
    
    // Iterates through the nodes in a column, starting at the node immediately above the start node.
    var upNodes: Iterator {
        Iterator(self, .up)
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
        
        let allConstraints = grid.constraints + grid.optionalConstraints
        let header = Node<R>.Header(columns: (0 ..< allConstraints).map { i in Node.Column(mandatory: i < grid.constraints) })
        let state = SearchState()
        var solvedRows = [R]()
        
        // For each row in the grid, adds a node with given row id for each column in the row.
        func addRowNodes() {
            grid.generateRows { (row: R, columns: Int...) in
                guard let column = columns.first else { return }
                
                _ = columns.dropFirst().reduce(header[column].appendNode(row: row)) { node, column in node.insertRightNode(header[column].appendNode(row: row)) }
            }
        }
        
        // Returns the first mandatory column, or nil if none found.
        // Since mandatory columns precede optional columns in the list, and since the header is not mandatory,
        // a check on the mandatory flag suffices.
        func firstColumn() -> Node<R>? {
            guard let column = header.right, column.column.mandatory else { return nil }
            
            return column
        }
        
        // Returns the first mandatory column with the least rows, or nil if none found.
        // Since mandatory columns precede optional columns in the list and the header is not mandatory,
        // we continue iterating as long as the column is mandatory.
        // Note. We could cast the nodes to Column and skip the hop through the column, but this is faster for
        // the reference benchmark.
        func smallestColumn() -> Node<R>? {
            guard var column = header.right, column.column.mandatory else { return nil }
            var node: Node<R> = column.right
            
            while node.column.mandatory {
                if node.column.size < column.column.size { column = node }
                node = node.right
            }
            
            return column
        }
        
        // Returns a mandatory column node according to the chosen strategy, or nil if none found.
        // Note. The return type could be Column. We avoid the cast and use delegation to the column node
        // itself for the size and for the cover and uncover operations (cf. solve method).
        func selectColumn() -> Node<R>? {
            switch strategy {
            case .naive: return firstColumn()
            case .minimumSize: return smallestColumn()
            }
        }
        
        // Recursively search for a solution until we have exhausted all options.
        // When all columns have been covered, pass the solution to the handler.
        // Undo covering operations when backtracking.
        // Stop searching when the handler sets the search state to terminated.
        func solve() {
            guard let column = selectColumn() else { return handler(Solution(rows: solvedRows), state) }
            
            column.cover()
            for vNode in column.downNodes {
                solvedRows.append(vNode.row!) // vNode is a row node with a non-nil row reference.
                for node in vNode.rightNodes { node.cover() }
                solve()
                guard !state.terminated else { return }
                solvedRows.removeLast()
                for node in vNode.leftNodes { node.uncover() }
            }
            column.uncover()
        }
        
        addRowNodes()
        _ = solve()
        header.release()
    }
    
}
