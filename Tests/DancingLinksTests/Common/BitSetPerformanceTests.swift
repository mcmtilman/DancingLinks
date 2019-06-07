//
//  BitSetPerformanceTests.swift
//
//  Created by Michel Tilman on 14/05/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests BitSet performance.
 Use release build.
 */
class BitSetPerformanceTests: XCTestCase {
    
    // MARK: Static properties
    
    // Number of iterations used in main loops.
    static var iterations = 100000
    
    // MARK: Tests
    
    // Test creation of bit sets.
    func testCreationPerformance() {
        measure {
            for _ in 1 ... Self.iterations {
                let set: BitSet = [1, 2, 3, 4, 6, 7, 8, 9]

                if set.count != 8 {
                    print("Wrong count \(set.count)")
                }
            }
        }
    }
    
    // Test iterating over a bit set.
    func testIteratorPerformance() {
        measure {
            let set = BitSet(BitSet.min ... BitSet.max)
            
            for _ in 1 ... Self.iterations {
                var c = 0
                
                for _ in set {
                    c += 1
                }
                
                if c != Int.bitWidth {
                    print("Wrong count \(c)")
                }
            }
        }
    }
    
   // Test various operations on bit sets.
    func testBitSetPerformance() {
        measure {
            let bs: BitSet = [1, 2, 3, 4, 6, 7, 8, 9]
            let bs2: BitSet = [1, 2, 3, 4, 6, 7, 8, 9, 10]
            
            for _ in 1 ... Self.iterations {
                var options: BitSet = bs
                if options.contains(10) { print("Wrong 10") }
                options.insert(10)
                if !options.contains(10) { print("Missing 10") }
                if options.isEmpty { print("Empty") }
                if options.count != 9 { print("Wrong count \(options.count)") }
                var count = 0
                for i in options {
                    if i != 5 { count += 1 }
                }
                if count != 9 { print(count) }
                let options2: BitSet = bs2
                if options != options2 { print("Not equal") }
            }
        }
    }
    
}

/**
 For LinuxMain.
 */
extension BitSetPerformanceTests {
    
    static var allTests = [
        ("testCreationPerformance", testCreationPerformance),
        ("testIteratorPerformance", testIteratorPerformance),
        ("testBitSetPerformance", testBitSetPerformance),
    ]
    
}
