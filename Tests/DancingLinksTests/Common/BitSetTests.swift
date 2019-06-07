//
//  BitSetTests.swift
//
//  Created by Michel Tilman on 14/05/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests BitSet.
 */
class BitSetTests: XCTestCase {
    

    // MARK: Testing instantiation
    
    func testEmptyBitSet() {
        let set = BitSet()
        
        XCTAssertEqual(set.count, 0)
        XCTAssertTrue(set.isEmpty)
        for i in 0 ... 63 {
            XCTAssertFalse(set.contains(i))
        }
    }
    
    func testFullBitSet() {
        let set = BitSet(0 ... 63)
        
        XCTAssertEqual(set.count, 64)
        XCTAssertFalse(set.isEmpty)
        for i in 0 ... 63 {
            XCTAssertTrue(set.contains(i))
        }
    }
    
    func testPartialBitSet() {
        let set = BitSet(1, 2, 3)
        
        XCTAssertEqual(set.count, 3)
        XCTAssertFalse(set.isEmpty)
        for i in 1 ... 3 {
            XCTAssertTrue(set.contains(i))
        }
        for i in 0 ... 63 where i < 1 || i > 3 {
            XCTAssertFalse(set.contains(i))
        }
    }
    
    func testSingletonBitSet() {
        let set = BitSet(1)
        
        XCTAssertEqual(set.count, 1)
        XCTAssertFalse(set.isEmpty)
        XCTAssertTrue(set.contains(1))
        for i in 0 ... 63 where i != 1 {
            XCTAssertFalse(set.contains(i))
        }
    }
    
    // MARK: Testing equality
    
    func testBitSetEqality() {
        XCTAssertEqual(BitSet(), BitSet())
        XCTAssertEqual(BitSet(0), BitSet(0))
        XCTAssertEqual(BitSet(63), BitSet(63))
        XCTAssertEqual(BitSet(1, 2, 3), BitSet(1, 2, 3))
        XCTAssertEqual(BitSet(0 ... 63), BitSet(0 ... 63))
    }
    
    func testBitSetIneqality() {
        XCTAssertNotEqual(BitSet(), BitSet(0 ... 63))
        XCTAssertNotEqual(BitSet(0), BitSet(1))
        XCTAssertNotEqual(BitSet(0, 1, 2), BitSet(1, 2, 3))
    }
    
    // MARK: Testing updates
    
    func testInsert() {
        var set = BitSet()
        
        XCTAssertFalse(set.contains(1))
        set.insert(1)
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 1)
        set.insert(1)
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 1)
        set.insert(0)
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 2)
        set.insert(63)
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 3)
    }
    
    func testRemoveElement() {
        var set = BitSet(0, 1, 63)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 3)
        set.remove(63)
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 2)
        set.remove(0)
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 1)
        set.remove(1)
        XCTAssertFalse(set.contains(1))
        XCTAssertEqual(set.count, 0)
        set.remove(1)
        XCTAssertFalse(set.contains(1))
        XCTAssertEqual(set.count, 0)
    }
    
    func testRemoveNonElement() {
        var set = BitSet(0, 1, 63)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 3)
        set.remove(2)
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 3)
    }
    
    func testRemoveFromEmptySet() {
        var set = BitSet()
        
        XCTAssertEqual(set.count, 0)
        set.remove(2)
        XCTAssertEqual(set.count, 0)
    }
    
    func testSubtractEmptySet() {
        var set = BitSet(0, 1)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 2)
        set.subtract(BitSet())
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 2)
    }
    
    func testSubtractFromEmptySet() {
        var set = BitSet()
        
        XCTAssertEqual(set.count, 0)
        set.subtract(BitSet(0, 1))
        XCTAssertFalse(set.contains(0))
        XCTAssertFalse(set.contains(1))
        XCTAssertEqual(set.count, 0)
    }
    
    // Sets overlap partially.
    func testSubtractIntersectingSet() {
        var set = BitSet(0, 1, 62, 63)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(62))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 4)
        set.subtract(BitSet(61, 62))
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertFalse(set.contains(61))
        XCTAssertFalse(set.contains(62))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 3)
    }
    
    func testSubtractSubset() {
        var set = BitSet(0, 1, 62, 63)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertTrue(set.contains(62))
        XCTAssertTrue(set.contains(63))
        XCTAssertEqual(set.count, 4)
        set.subtract(BitSet(62, 63))
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertFalse(set.contains(62))
        XCTAssertFalse(set.contains(63))
        XCTAssertEqual(set.count, 2)
    }
    
    func testSubtractSuperset() {
        var set = BitSet(0, 1)
        
        XCTAssertTrue(set.contains(0))
        XCTAssertTrue(set.contains(1))
        XCTAssertEqual(set.count, 2)
        set.subtract(BitSet(0, 1, 62, 63))
        XCTAssertFalse(set.contains(0))
        XCTAssertFalse(set.contains(1))
        XCTAssertFalse(set.contains(62))
        XCTAssertFalse(set.contains(63))
        XCTAssertEqual(set.count, 0)
    }
    
    // MARK: Testing set operations
    
    func testIntersectionWithEmptySet() {
        let set = BitSet(0, 1).intersection(BitSet())
        
        XCTAssertEqual(set, BitSet())
    }
    
    func testEmptySetIntersection() {
        let set = BitSet().intersection(BitSet(0, 1))
        
        XCTAssertEqual(set, BitSet())
    }
    
    // Sets partially overlap
    func testIntersectionWithIntersectingSet() {
        let set = BitSet(0, 1, 62, 63).intersection(BitSet(61, 62))
        
        XCTAssertEqual(set, BitSet(62))
    }
    
    func testIntersectionWithSubset() {
        let set = BitSet(0, 1, 62, 63).intersection(BitSet(62, 63))
        
        XCTAssertEqual(set, BitSet(62, 63))
    }
    
    func testIntersectionWithSuperset() {
        let set = BitSet(0, 1).intersection(BitSet(0, 1, 62, 63))

        XCTAssertEqual(set, BitSet(0, 1))
    }
    
    func testSubtractingEmptySet() {
        let set = BitSet(0, 1).subtracting(BitSet())
        
        XCTAssertEqual(set, BitSet(0, 1))
    }
    
    func testSubtractingFromEmptySet() {
        let set = BitSet().subtracting(BitSet(0, 1))

        XCTAssertEqual(set, BitSet())
    }
    
    // Sets partially overlap
    func testSubtractingIntersectingSet() {
        let set = BitSet(0, 1, 62, 63).subtracting(BitSet(61, 62))
        
        XCTAssertEqual(set, BitSet(0, 1, 63))
    }
    
    func testSubtractingSubset() {
        let set = BitSet(0, 1, 62, 63).subtracting(BitSet(62, 63))
        
        XCTAssertEqual(set, BitSet(0, 1))
    }
    
    func testSubtractingSuperset() {
        let set = BitSet(0, 1).subtracting(BitSet(0, 1, 62, 63))
        
        XCTAssertEqual(set, BitSet())
    }
    
    func testEmptySetUnion() {
        let set = BitSet().union(BitSet(0, 1))
        
        XCTAssertEqual(set, BitSet(0, 1))
    }
    
    func testUnionWithEmptySet() {
        let set = BitSet(0, 1).union(BitSet())
        
        XCTAssertEqual(set, BitSet(0, 1))
    }
    
    // Sets partially overlap
    func testUnionWithIntersectingSet() {
        let set = BitSet(0, 1, 62, 63).union(BitSet(61, 62))
        
        XCTAssertEqual(set, BitSet(0, 1, 61, 62, 63))
    }
    
    func testUnionWithSubset() {
        let set = BitSet(0, 1, 62, 63).union(BitSet(0, 1))
        
        XCTAssertEqual(set, BitSet(0, 1, 62, 63))
    }
    
    func testUnionWithSuperset() {
        let set = BitSet(0, 1).union(BitSet(0, 1, 62, 63))
        
        XCTAssertEqual(set, BitSet(0, 1, 62, 63))
    }
    
    // MARK: Testing set tests
    
    func testIsSubsetWithEmptySet() {
        let set = BitSet()
            
        XCTAssertTrue(set.isSubset(of: BitSet()))
        XCTAssertTrue(set.isSubset(of: BitSet(1, 2)))
        XCTAssertFalse(BitSet(1, 2).isSubset(of: set))
    }
    
    func testIsStrictSubsetWithEmptySet() {
        let set = BitSet()
        
        XCTAssertFalse(set.isStrictSubset(of: BitSet()))
        XCTAssertTrue(set.isStrictSubset(of: BitSet(1, 2)))
        XCTAssertFalse(BitSet(1, 2).isStrictSubset(of: set))
    }

    func testIsSubset() {
        let set = BitSet(1, 2)
        
        XCTAssertTrue(set.isSubset(of: BitSet(1, 2)))
        XCTAssertTrue(set.isSubset(of: BitSet(1, 2, 62, 63)))
        XCTAssertFalse(set.isSubset(of: BitSet(1, 3)))
        XCTAssertFalse(set.isSubset(of: BitSet(1)))
    }
    
    func testIsStrictSubset() {
        let set = BitSet(1, 2)
        
        XCTAssertFalse(set.isStrictSubset(of: BitSet(1, 2)))
        XCTAssertTrue(set.isStrictSubset(of: BitSet(1, 2, 62, 63)))
        XCTAssertFalse(set.isStrictSubset(of: BitSet(1, 3)))
        XCTAssertFalse(set.isStrictSubset(of: BitSet(1)))
    }
    
    func testIsSupersetWithEmptySet() {
        let set = BitSet()
        
        XCTAssertTrue(set.isSuperset(of: BitSet()))
        XCTAssertFalse(set.isSuperset(of: BitSet(1, 2)))
        XCTAssertTrue(BitSet(1, 2).isSuperset(of: set))
    }
    
    func testIsStrictSupersetWithEmptySet() {
        let set = BitSet()
        
        XCTAssertFalse(set.isStrictSuperset(of: BitSet()))
        XCTAssertFalse(set.isStrictSuperset(of: BitSet(1, 2)))
        XCTAssertTrue(BitSet(1, 2).isStrictSuperset(of: set))
    }
    
    func testIsSuperset() {
        let set = BitSet(1, 2)
        
        XCTAssertTrue(set.isSuperset(of: BitSet(1, 2)))
        XCTAssertFalse(set.isSuperset(of: BitSet(1, 2, 62, 63)))
        XCTAssertFalse(set.isSuperset(of: BitSet(1, 3)))
        XCTAssertTrue(BitSet(1, 2, 3).isSuperset(of: set))
    }
    
    func testIsStrictSuperset() {
        let set = BitSet(1, 2)
        
        XCTAssertFalse(set.isStrictSuperset(of: BitSet(1, 2)))
        XCTAssertFalse(set.isStrictSuperset(of: BitSet(1, 2, 62, 63)))
        XCTAssertFalse(set.isStrictSuperset(of: BitSet(1, 3)))
        XCTAssertTrue(set.isStrictSuperset(of: BitSet(1)))
    }
    
    // MARK: Testing ExpressibleByArrayLiteral
    
    func testCreateSetByArrayLiteral() {
        let set: BitSet = [0, 1, 62, 63]
        
        XCTAssertEqual(set, BitSet(0, 1, 62, 63))
    }
    
    func testSetEqualityWithArrayLiteral() {
        let set = BitSet(0, 1, 62, 63)
        
        XCTAssertEqual(set, [0, 1, 62, 63])
    }
    
    func testSetOperationWithArrayLiteral() {
        let set = BitSet(0, 1).union([62, 63])
        
        XCTAssertEqual(set, BitSet(0, 1, 62, 63))
    }
    
    // MARK: Testing collections
    
    func testIsEmpty() {
        XCTAssertTrue(BitSet().isEmpty)
        XCTAssertFalse(BitSet(0, 1).isEmpty)
    }
    
    func testCount() {
        XCTAssertEqual(BitSet().count, 0)
        XCTAssertEqual(BitSet(1).count, 1)
        XCTAssertEqual(BitSet(0, 1).count, 2)
        XCTAssertEqual(BitSet(0 ..< 64).count, 64)
    }
    
    // MARK: Testing sequences
    
    func testEmptySequence() {
        let set = BitSet()

        for _ in set {
            XCTFail("Non-empty sequence")
        }
    }
    
    func testFullSequence() {
        let set = BitSet(0 ... 63)
        
        for (i, value) in zip(0 ... 63, set) {
            XCTAssertEqual(i, value)
        }
    }

    func testIterateAndInsert() {
        var set = BitSet(0 ..< 5)
        
        XCTAssertEqual(set.count, 5)
        for (i, _) in set.enumerated() {
            set.insert(i + 5)
            if i > 4 {
                XCTFail("Element inserted while iterating")
            }
        }
        XCTAssertEqual(set.count, 10)
    }
    
    func testIterateAndRemove() {
        var set = BitSet(0 ..< 10)
        var count = 0
        
        XCTAssertEqual(set.count, 10)
        for (i, _) in set.enumerated() {
            count += 1
            if i < 5 {
                set.remove(i + 5)
            }
        }
        if count < 10 {
            XCTFail("Element removed while iterating")
        }
        XCTAssertEqual(set.count, 5)
    }
    
}


/**
 For LinuxMain.
 */
extension BitSetTests {
    
    static var allTests = [
        ("testEmptyBitSet", testEmptyBitSet),
        ("testFullBitSet", testFullBitSet),
        ("testPartialBitSet", testPartialBitSet),
        ("testSingletonBitSet", testSingletonBitSet),
        ("testBitSetEqality", testBitSetEqality),
        ("testBitSetIneqality", testBitSetIneqality),
        ("testInsert", testInsert),
        ("testRemoveElement", testRemoveElement),
        ("testRemoveNonElement", testRemoveNonElement),
        ("testRemoveFromEmptySet", testRemoveFromEmptySet),
        ("testSubtractEmptySet", testSubtractEmptySet),
        ("testSubtractFromEmptySet", testSubtractFromEmptySet),
        ("testSubtractIntersectingSet", testSubtractIntersectingSet),
        ("testSubtractSubset", testSubtractSubset),
        ("testSubtractSuperset", testSubtractSuperset),
        ("testIntersectionWithEmptySet", testIntersectionWithEmptySet),
        ("testEmptySetIntersection", testEmptySetIntersection),
        ("testIntersectionWithIntersectingSet", testIntersectionWithIntersectingSet),
        ("testIntersectionWithSubset", testIntersectionWithSubset),
        ("testIntersectionWithSuperset", testIntersectionWithSuperset),
        ("testSubtractingEmptySet", testSubtractingEmptySet),
        ("testSubtractingFromEmptySet", testSubtractingFromEmptySet),
        ("testSubtractingIntersectingSet", testSubtractingIntersectingSet),
        ("testSubtractingSubset", testSubtractingSubset),
        ("testSubtractingSuperset", testSubtractingSuperset),
        ("testEmptySetUnion", testEmptySetUnion),
        ("testUnionWithEmptySet", testUnionWithEmptySet),
        ("testUnionWithIntersectingSet", testUnionWithIntersectingSet),
        ("testUnionWithSubset", testUnionWithSubset),
        ("testUnionWithSuperset", testUnionWithSuperset),
        ("testIsSubsetWithEmptySet", testIsSubsetWithEmptySet),
        ("testIsStrictSubsetWithEmptySet", testIsStrictSubsetWithEmptySet),
        ("testIsSubset", testIsSubset),
        ("testIsStrictSubset", testIsStrictSubset),
        ("testIsSupersetWithEmptySet", testIsSupersetWithEmptySet),
        ("testIsStrictSupersetWithEmptySet", testIsStrictSupersetWithEmptySet),
        ("testIsSuperset", testIsSuperset),
        ("testIsStrictSuperset", testIsStrictSuperset),
        ("testCreateSetByArrayLiteral", testCreateSetByArrayLiteral),
        ("testSetEqualityWithArrayLiteral", testSetEqualityWithArrayLiteral),
        ("testSetOperationWithArrayLiteral", testSetOperationWithArrayLiteral),
        ("testIsEmpty", testIsEmpty),
        ("testCount", testCount),
        ("testEmptySequence", testEmptySequence),
        ("testFullSequence", testFullSequence),
        ("testIterateAndInsert", testIterateAndInsert),
        ("testIterateAndRemove", testIterateAndRemove),
    ]
    
}
