# Dancing Links algorithm

Swift implementations of Knuth's *Dancing Links* algorithm (see also *DLX* and *Algorithm X*).

# Algorithm implementations

## Scala and Pharo implementations

An initial, straightforward implementation was first developed in *Scala* based on an existing *Java* example, but with some additional abstractions. The Java and Scala algorithms were able to solve the following 'evil' sudoku (Inkala 2012) in about 1 ms.

    8........
    ..36.....
    .7..9.2..
    .5...7...
    ....457..
    ...1...3.
    ..1....68
    ..85...1.
    .9....4..

A straightforward port to *Pharo* resulted in about 3.5 ms for solving the same sudoku, which was better than expected.

### Note

The Java / Scala and Pharo implementations assumed a regular 9-by-9 grid sudoku, which simplified some parts of the code. These implementations also did not support *optional constraints*.

## Swift implementations

The *ClassyDancingLinks* algorithm uses classes to represent the nodes of the Dancing Links grid. The grid is a sparse implementation of a constraint matrix, where the elements (nodes) are connected to other nodes in the same row and column by means of doubly-linked lists. Once the grid is set up, the bulk of the computation of the Dancing Links algorithm consists in unlinking and relinking nodes from and to the lists, resulting in constant updates of object references. Since ARC does not deal well with cycles in the context of this algorithm, the choice was made to not use *weak* or *unowned* references (given the performance loss). Instead, the algorithm keeps track of the nodes in the grid using *strong* references upon creation, separate from the actual links, and explicitly releases the grid nodes at the end. The links themselves originally used strong references, but this was later replaced by *unowned(unsafe)* references.

This implementation now takes about 1.1 ms for the evil sudoku performance test case, using Swift 5.1. Since several steps in the algorithm require traversing one of the linked lists in a given direction, an iterator was added to abstract the traversal process (similar to the Scala implementation). This iterator also uses unowned(unsafe) references, at least for Swift 5.1. It seems that Swift 5.2 and 5.3 do not properly handle unowned(unsafe) references, so for now the iterator uses strong references from Swift 5.2 onwards. With this approach Swift 5.3 takes 6.2 ms to solve the evil sudoku.

The *StructuredDancingLinks* algorithm is struct-based, and sort of implements its own memory management. A *node store* manages the links between the struct nodes (links are just indices in the node store array). This algorithm also foregoes iterator abstractions to traverse the linked lists. This algorithm is faster than *ClassyDancingLinks* and requires about 0.9 ms to find the evil sudoku solution (Swift 5.1 / 5.3). *StructuredDancingLinksNR*, an experimental non-recursive implementation of this algorithm, reduces this time slightly further to about 0.8 ms.

Implementing a version of the algorithm in Swift that approximates the performance of the Scala solution turned out to be much less straightforward than expected. One of the problems was the inconsistency of results between different versions of Swift. For instance, the struct-based implementation became about 20 times slower when moving from Swift 5.1 to 5.2. It seemed that Swift 5.2 and 5.3 no longer specialized some generics (resulting in a small rewrite of the code using type erasure). Another issue relates to using unsafe constructs - in this case unowned(unsafe) references - in the class-based implementation.

# Examples

## Sudoku

The sudoku example supports creating sudokus with other dimensions than the regular 9 x 9 grid (which consists of 9 rows, 9 columns and 9 3-by-3 boxes). This also includes creating sudokus with non-square boxes. For instance, a 4-by-3 box results in a sudoku with 12 rows, 12 columns, 12 4-by-3 boxes of 4 rows and 3 columns each, and 144 grid cells.

A valid sudoku puzzle can be solved with either of the two Swift algorithms, the struct-based algorithm being the default.

The Dancing Links algorithms can also be used to find multiple sudoku solutions by starting from an empty sudoku. The dedicated *SudokuGenerator* algorithm, which uses a straightforward random placement implementation, is a few times faster than the (first) solution found by DancingLinks. Note that the available DancingLinks search strategies currently do not contain a randomizer option.

## N-Queens problem

This example illustrates support for optional constraints.

# Test setup

All benchmarks used release builds with whole module compilation, full enforcement of exclusive access to memory and safety checks enabled, executing on a iMac 4.2 GHz Intel Core i7.

# Requirements

The code has initially been tested with the Swift 5.1 Snapshot 2019-06-28 toolchain and XCode 11.0 beta 2. Later, tests were performed using XCode 11.5 (Swift 5.2.4), as well as Xcode 11.5 with the Swift 5.3 Development Snapshot 2020-06-13 toolchain.
