//
//  SudokuGeneratorPerformanceTests.swift
//
//  Created by Michel Tilman on 23/06/2019.
//  Copyright © 2019 Dotted.Pair.
//  Licensed under Apache License v2.0.
//

import XCTest
@testable import DancingLinks

/**
 Tests solving sudokus.
 */
class SudokuGeneratorPerformanceTests: XCTestCase {
    
    // Test generating solutions using the random placement algorithm.
    func testGenerateRandomSolution() {
        let generator = RandomSudokuGenerator()
        
        measure {
            for _ in 1 ... 10 {
                guard generator.generateSolution() != nil else { return XCTFail("nil solution") }
            }
        }
    }
    
    // Test generating and validating solutions using the random placement algorithm.
    func testGenerateAndValidateRandomSolution() {
        let generator = RandomSudokuGenerator()
        
        measure {
            for _ in 1 ... 10 {
                guard let sudoku = generator.generateSolution(), sudoku.isComplete() else { return XCTFail("nil or invalid solution") }
            }
        }
    }
    
}
