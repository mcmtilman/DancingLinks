//
//  BitSet.swift
//
//  Created by Michel Tilman on 14/05/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

/**
 BitSet implements a set of elements of type Int.
 The elements are restricted to the range 0 ..< Int.bitWidth with enabled asserts.
 With disabled asserts, some results are not specified for values outside this range.
 */
public struct BitSet: SetAlgebra {
    
    // MARK: Constants
    
    /// The maximum supported value.
    public static let max = Int.bitWidth - 1
    
    /// The minimum supported value.
    public static let min = 0
    
    // MARK: Private stored properties
    
    // Representation as bits of an Int.
    private var value: Int
    
    // MARK: Computed properties
    
    /// The number of elements in the set.
    public var count: Int {
        value.nonzeroBitCount
    }
    
    /// True if the set is empty, false otherwise.
    public var isEmpty: Bool {
        value == 0
    }
    
    // MARK: Initializing
    
    /// Initializes an empty set.
    public init() {
        self.init(value: 0)
    }
    
    /// Initializes the set with given sequence of elements.
    /// Asserts that each element is inside the range.
    public init<S>(_ sequence: S) where S: Sequence, S.Element == Int {
        var value = 0
        
        for element in sequence {
            assert(element >= Self.min && element <= Self.max)
            
            value |= 1 &<< element
        }
        
        self.init(value: value)
    }
    
    /// Initializes the set with given elements.
    /// Asserts that each element is inside the range.
    public init(_ elements: Int...) {
        self.init(elements)
    }
    
    // MARK: Element testing
    
    /// Returns true if the element is in the set, false otherwise.
    /// Asserts that the element is inside the range.
    public func contains(_ element: Int) -> Bool {
        assert(element >= Self.min && element <= Self.max)
        
        return value & (1 &<< element) != 0
    }
    
    // MARK: Element operations
    
    /// Inserts the element in the set.
    /// Asserts that the element is inside the range.
    /// - SeeAlso: SetAlgebra
    @discardableResult
    public mutating func insert(_ element: Int) -> (inserted: Bool, memberAfterInsert: Int) {
        assert(element >= Self.min && element <= Self.max)
        
        let newValue = value | (1 &<< element)
        
        defer { value = newValue }
        return (inserted: newValue != value, memberAfterInsert: element)
    }
    
    /// Removes the element from the set.
    /// Asserts that the element is inside the range.
    /// - SeeAlso: SetAlgebra
    @discardableResult
    public mutating func remove(_ element: Int) -> Int? {
        assert(element >= Self.min && element <= Self.max)
        
        let newValue = value & ~(1 &<< element)
        
        defer { value = newValue }
        return newValue != value ? element : nil
    }
    
    /// Inserts the element in the set. Answer the element if added.
    /// Asserts that the element is inside the range.
    /// - SeeAlso: SetAlgebra
    @discardableResult
    public mutating func update(with element: Int) -> Int? {
        insert(element).inserted ? element : nil
    }
    
    // MARK: Mutating set operations
    
    /// Keeps the intersection with the other set.
    public mutating func formIntersection(_ other: Self) {
        self = intersection(other)
    }
    
    /// Subtracts the intersection with the other set.
    public mutating func formSymmetricDifference(_ other: Self) {
        self = symmetricDifference(other)
    }
    
    /// Extends this set with the other set.
    public mutating func formUnion(_ other: Self) {
        self = union(other)
    }
    
    /// Removes the other set from this set.
    public mutating func subtract(_ other: Self) {
        self = subtracting(other)
    }
    
    // MARK: Set operations
    
    /// Returns the intersection of both sets.
    public func intersection(_ other: Self) -> Self {
        Self(value: value & other.value)
    }
    
    /// Returns this set minus the other set.
    public func subtracting(_ other: Self) -> Self {
        intersection(symmetricDifference(other))
    }
    
    /// Returns the symmetric difference of both sets (union - intersection).
    public func symmetricDifference(_ other: Self) -> Self {
        Self(value: value ^ other.value)
    }
    
    /// Returns the union of both sets.
    public func union(_ other: Self) -> Self {
        Self(value: value | other.value)
    }
    
    // MARK: Set testing
    
    /// Returns true if this set is a strict subset of the other, false otherwise.
    func isStrictSubset(of other: Self) -> Bool {
        isSubset(of: other) && self != other
    }
    
    /// Returns true if this set is a subset of the other, false otherwise.
    public func isSubset(of other: Self) -> Bool {
        self == intersection(other)
    }
    
    /// Returns true if this set is a strict superset of the other, false otherwise.
    func isStrictSuperset(of other: Self) -> Bool {
        other.isStrictSubset(of: self)
    }
    
    /// Returns true if this set is a superset of the other, false otherwise.
    public func isSuperset(of other: Self) -> Bool {
        other.isSubset(of: self)
    }
    
    // MARK: Private initializing
    
    // Initializes the set with given value.
    private init(value: Int) {
        self.value = value
    }
    
}


/**
 ExpressibleByArrayLiteral protocol adoption.
 */
extension BitSet: ExpressibleByArrayLiteral {
    
    /// Initializes the set with a literal array of Int.
    /// Asserts that each element is inside the range.
    public init(arrayLiteral: Int...) {
        self.init(arrayLiteral)
    }
    
}


/**
 Sequence protocol adoption.
 */
extension BitSet: Sequence {
    
    /// Iterates the elements in increasing order of magnitude.
    /// Ignores changes to the set while iterating.
    public struct Iterator: IteratorProtocol {
        
        // MARK: Private stored properties
        
        // Bitset representation of successive elements (1, 2, 4, ...).
        // 'Incremented' on each iteration.
        // Could be private, but then the synthesized initializer is private too.
        fileprivate var bitMask = 1
        
        // Successive elements (0, 1, 2, ...).
        // Incremented on each iteration.
        // Could be private, but then the synthesized initializer is private too.
        fileprivate var element = 0
        
        // Value containing the bits yet to be processed.
        // Could be private, but then the synthesized initializer is private too.
        fileprivate var value: Int
        
        // MARK: Iterating

        /// Returns the next element in the set, or nil if we are at the end.
        public mutating func next() -> Int? {
            while value != 0 {
                defer {
                    if value != 0 {
                        bitMask &*= 2
                        element &+= 1
                    }
                }
                
                if value & bitMask != 0 {
                    value &= ~bitMask
                    
                    return element
                }
            }
            
            return nil
        }
        
    }
    
    /// Returns an iterator which ignores changes to this set after creation.
    public func makeIterator() -> Iterator {
        Iterator(value: value)
    }
    
}
