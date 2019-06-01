//
//  BitSet.swift
//
//  Created by Michel Tilman on 14/05/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.


/**
 BitSet implements a set of elements of type Int.
 The elements are restricted to the range 0 ..< Int.bitWidth with enabled asserts.
 With disabled asserts, some results are not specified for values outside this range.
 */
public struct BitSet: SetAlgebra {
    
    // MARK: Constants
    
    /// Answer the maximum supported value.
    public static let max = Int.bitWidth - 1
    
    /// Answer the minimum supported value.
    public static let min = 0
    
    // MARK: Private stored properties
    
    // Representation as bits of an Int.
    private var value: Int
    
    // MARK: Computed properties
    
    /// The number of elements in the set.
    public var count: Int {
        value.nonzeroBitCount
    }
    
    /// Answer true if the set is empty.
    public var isEmpty: Bool {
        value == 0
    }
    
    // MARK: Initializing
    
    /// Initialize an empty set.
    public init() {
        self.init(value: 0)
    }
    
    /// Initialize the set with given sequence of elements.
    /// Asserts that each element is inside the range.
    public init<S>(_ sequence: S) where S: Sequence, S.Element == Int {
        var value = 0
        
        for element in sequence {
            assert(element >= Self.min && element <= Self.max)
            
            value |= 1 &<< element
        }
        
        self.init(value: value)
    }
    
    /// Initialize the set with given elements.
    /// Asserts that each element is inside the range.
    public init(_ elements: Int...) {
        self.init(elements)
    }
    
    // MARK: Testing
    
    /// Answer if the element is in the set.
    /// Asserts that the element is inside the range.
    public func contains(_ element: Int) -> Bool {
        assert(element >= Self.min && element <= Self.max)
        
        return value & (1 &<< element) != 0
    }
    
    // MARK: Element operations
    
    /// Insert the element in the set. Answer if the element was inserted.
    /// Asserts that the element is inside the range.
    @discardableResult
    public mutating func insert(_ element: Int) -> (inserted: Bool, memberAfterInsert: Int) {
        assert(element >= Self.min && element <= Self.max)
        
        let newValue = value | (1 &<< element)
        
        defer { value = newValue }
        return (inserted: newValue != value, memberAfterInsert: element)
    }
    
    /// Remove the element from the set. Answer the element if removed.
    /// Asserts that the element is inside the range.
    @discardableResult
    public mutating func remove(_ element: Int) -> Int? {
        assert(element >= Self.min && element <= Self.max)
        
        let newValue = value & ~(1 &<< element)
        
        defer { value = newValue }
        return newValue != value ? element : nil
    }
    
    /// Insert the element in the set. Answer the element if added.
    /// Asserts that the element is inside the range.
    @discardableResult
    public mutating func update(with element: Int) -> Int? {
        insert(element).inserted ? element : nil
    }
    
    // MARK: Mutating set operations
    
    /// Keep the intersection with the other set.
    public mutating func formIntersection(_ other: BitSet) {
        self = intersection(other)
    }
    
    /// Subtract the intersection with the other set.
    public mutating func formSymmetricDifference(_ other: BitSet) {
        self = symmetricDifference(other)
    }
    
    /// Extend this set with the other set.
    mutating public func formUnion(_ other: BitSet) {
        self = union(other)
    }
    
    /// Remove the other set from this set.
    mutating public func subtract(_ other: BitSet) {
        self = subtracting(other)
    }
    
    // MARK: Set operations
    
    /// Answer the intersection of both sets.
    public func intersection(_ other: BitSet) -> BitSet {
        BitSet(value: value & other.value)
    }
    
    /// Answer the this set minus the other set.
    public func subtracting(_ other: BitSet) -> BitSet {
        intersection(symmetricDifference(other))
    }
    
    /// Answer the symmetric difference of both sets (union - intersection).
    public func symmetricDifference(_ other: BitSet) -> BitSet {
        BitSet(value: value ^ other.value)
    }
    
    /// Answer the union of both sets.
    public func union(_ other: BitSet) -> BitSet {
        BitSet(value: value | other.value)
    }
    
    // MARK: Set testing
    
    /// Answer if this set is a strict subset of the other.
    func isStrictSubset(of other: BitSet) -> Bool {
        isSubset(of: other) && self != other
    }
    
    /// Answer if this set is a subset of the other.
    public func isSubset(of other: BitSet) -> Bool {
        self == intersection(other)
    }
    
    /// Answer if this set is a strict superset of the other.
    func isStrictSuperset(of other: BitSet) -> Bool {
        other.isStrictSubset(of: self)
    }
    
    /// Answer if this set is a superset of the other.
    public func isSuperset(of other: BitSet) -> Bool {
        other.isSubset(of: self)
    }
    
    // MARK: Private initializing
    
    // Initialize the set with given bits.
    private init(value: Int) {
        self.value = value
    }
    
}


/**
 ExpressibleByArrayLiteral protocol adoption.
 */
extension BitSet: ExpressibleByArrayLiteral {
    
    /// Initialize the set with a literal array of Int.
    /// Asserts that each element is inside the range.
    public init(arrayLiteral: Int...) {
        self.init(arrayLiteral)
    }
    
}


/**
 Sequence protocol adoption.
 */
extension BitSet: Sequence {
    
    /// Iterates elements in increasing order of magnitude.
    /// Ignores changes to the set while iterating.
    public struct BitSetIterator: IteratorProtocol {
        
        // Bitset representation of successive elements (1, 2, 4, ...).
        // 'Incremented' on each iteration.
        // If private we need an explicit initializer.
        fileprivate var bitMask = 1
        
        // Successive elements (0, 1, 2, ...).
        // Incremented on each iteration.
        // If private we need an explicit initializer.
        fileprivate var element = 0
        
        // Value containing the bits yet to be processed.
        // If private we need an explicit initializer.
        fileprivate var value: Int
        
        /// Answer the next element in the set, or nil if we are at the end.
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
    
    /// Answer an iterator ignoring changes after creation.
    public func makeIterator() -> BitSetIterator {
        BitSetIterator(value: value)
    }
    
}
