# Dancing Links algorithm

Swift implementations of Knuth's *Dancing Links* algorithm (see also *DLX* and *Algorithm X*).

# Algorithms

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

A straightforward port to *Pharo* resulted in about 3.5 ms for solving the same sudoku, much better than expected.

Note that both the Pharo and Scala implementations assumed a regular 9-by-9 grid sudoku, which simplified some parts of the code. These implementations also did not support optional constraints.

## Pure Swift implementations

The *ClassyDancingLinks* algorithm also uses classes to represent the nodes of the Dancing Links grid. The grid is a sparse implementation of a constraint matrix, where the elements (nodes) are connected to other nodes in the same row and column by means of doubly-linked lists. Once the grid is set up, the bulk of the computation of the Dancing Links algorithm consists in unlinking and relinking nodes from and to the lists, resulting in constant updates of object references. Since ARC does not deal well with cycles in the context of this algorithm, the choice was made to not use weak references (some tests actually indicated a substantial performance loss when using weak references). Instead, the algorithm keeps track of the nodes in the grid using strong references, and explicitly releases the grid nodes at the end. This implementation takes about 7.5 ms for the included evil sudoku performance test case.

The *StructuredDancingLinks* algorithm is struct-based, and sort of implements its own memory management. A *node store* manages the links between the struct nodes (links are just indices in the node store array). This algorithm also foregoes simple iterator abstractions to loop over the doubly-linked lists. This algorithm is significantly faster than *ClassyDancingLinks*, requiring about 1.1 ms to find the evil sudoku solution. *StructuredDancingLinksNR*, an experimental non-recursive implementation of this algorithm, reduces this time slightly further to about 1 ms.

Both benchmarks measure the performance of the respective algorithms to find the solution for the evil sudoku. Each solution is tested for *correctness*: does the solution comply with the rules of a valid sudoku? This validation is taken care of by the sudoku initializer. Whether the solution is also *complete* (have all empty cells in the sudoku been assigned a number), is not verified by default. When we included this completeness test in the benchmarks, the results of both algorithms changed spectacularly. Performance of the class-based implementation dropped to about 10 ms, whereas the struct-based implementation suddenly required 35 ms. Changing the *DancingLinks* protocol to a ("abstract") superclass of both implementations fixed this problem.

Implementing a version of the algorithm in Swift that approximates the performance of the Scala solution clearly turned out to be less straightforward than expected.

# Examples

## Sudoku

The sudoku example supports creating sudokus with other dimensions than the regular 9 x 9 grid (which consists of 9 rows, 9 columns and 9 3-by-3 boxes). This also includes creating sudokus with non-square boxes. For instance, a 4-by-3 box results in a sudoku with 12 rows, 12 columns, 12 4-by-3 boxes of 4 rows and 3 columns each, and 144 grid cells.

A valid sudoku puzzle can be solved with either of the two Swift algorithms, the struct-based algorithm being the default.

The Dancing Links algorithms can also be used to find multiple sudoku solutions by starting from an empty sudoku. The dedicated *SudokuGenerator* algorithm, which uses a straightforward random placement implementation, is nearly an order of magnitude faster.

## N-Queens problem

This example illustrates support for optional constraints.

# Test setup

All benchmarks used release builds with full enforcement of exclusive access to memory and safety checks enabled, executing on a 4.2 GHz Intel Core i7.

# Requirements

The code has been tested with the Swift 5.1 Snapshot 2019-06-28 XCode toolchain and XCode 11.0 beta 2.
