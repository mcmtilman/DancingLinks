# Dancing Links algorithm

Swift implementations of Knuth's *Dancing Links* algorithm (see also DLX and algorithm X).

# Algorithms

## Scala and Pharo implementations

An initial, straightforward implementation was first developed in *Scala* based on an existing *Java* example, but with some additional abstractions. The Java and Scala algorithms were able to solve the 'evil' sudoku (cf. below) in less than 1 ms.

    8........
    ..36.....
    .7..9.2..
    .5...7...
    ....457..
    ...1...3.
    ..1....68
    ..85...1.
    .9....4..

A straightforward port to *Pharo* resulted in about 5 ms for solving the same sudoku, which was better than expected.

## Pure Swift implementations

The *ClassyDancingLinks* algorithm also uses classes to represent the nodes of the Dancing Links grid. The grid is a sparse implementation of a constraint matrix, where the elements (nodes) are connected to other nodes in the same row and column by means of doubly-linked lists. Once the grid is set up, the bulk of the computation of the Dancing Links algorithm consists in unlinking and relinking nodes from and to the lists, resulting in constant updates of object references. Since ARC does not deal well with cycles in the context of this algorithm, the choice was made to not use weak or unowned references (for instance, tests actually indicated a substantial performance loss when using weak references). Instead, the algorithm keeps track of the nodes in the grid using strong references, and explicitly releases the grid nodes at the end. This implementation takes about 9 ms when using the included performance test case within XCode. (All benchmarks use release builds with full enforcement of exclusive access to memory.)

The *StructuredDancingLinks* algorithm is struct-based, and, sort of implements its own memory management. A *node store* manages the links between the struct nodes (links are just indices in the node store array). This algorithm also foregoes simple iterator abstractions to loop over the doubly-linked lists. This algorithm is about 5 to 6 times faster than *ClassyDancingLinks* for the evil sudoku, requiring about 1.7 ms.

Implementing a version of the algorithm in Swift approximating the performance of the Scala solution turned out to be a bit harder than expected.

# Examples

## Sudoku

The sudoku example supports creating sudokus with other dimensions than the regular 9 x 9 grid (which consists of 9 rows, 9 columns and 9 3-by-3 boxes). This also includes creating sudokus with non-square boxes. For instance, a 4-by-3 box results in a sudoku with 12 rows, 12 columns, 12 4-by-3 boxes of 4 rows and 3 columns each, and 144 grid cells.

A valid sudoku puzzle can be solved with either of the two Swift algorithms, the fastest algorithm being the default.

# Requirements

Swift 5.1
