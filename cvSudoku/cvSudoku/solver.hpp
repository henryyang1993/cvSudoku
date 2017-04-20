//
//  solver.hpp
//  cvSudoku
//
//  Created by YANGHANYU on 4/11/17.
//  Copyright © 2017 CMU. All rights reserved.
//

#ifndef solver_hpp
#define solver_hpp

#include <stdio.h>

// UNASSIGNED is used for empty cells in sudoku grid
#define UNASSIGNED 0

// N is used for size of Sudoku grid. Size will be NxN
#define N 9

/* Takes a partially filled-in grid and attempts to assign values to
 all unassigned locations in such a way to meet the requirements
 for Sudoku solution (non-duplication across rows, columns, and boxes) */
bool SolveSudoku(int grid[N][N]);

/* Searches the grid to find an entry that is still unassigned. If
 found, the reference parameters row, col will be set the location
 that is unassigned, and true is returned. If no unassigned entries
 remain, false is returned. */
bool FindUnassignedLocation(int grid[N][N], int &row, int &col);

/* Returns a boolean which indicates whether any assigned entry
 in the specified row matches the given number. */
bool UsedInRow(int grid[N][N], int row, int num);

/* Returns a boolean which indicates whether any assigned entry
 in the specified column matches the given number. */
bool UsedInCol(int grid[N][N], int col, int num);

/* Returns a boolean which indicates whether any assigned entry
 within the specified 3x3 box matches the given number. */
bool UsedInBox(int grid[N][N], int boxStartRow, int boxStartCol, int num);

/* Returns a boolean which indicates whether it will be legal to assign
 num to the given row,col location. */
bool isSafe(int grid[N][N], int row, int col, int num);

/* A utility function to print grid  */
void printGrid(int grid[N][N]);

#endif /* solver_hpp */
