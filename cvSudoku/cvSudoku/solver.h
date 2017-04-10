//
//  solver.hpp
//  cvSudoku
//
//  Created by YANGHANYU on 4/8/17.
//  Copyright © 2017 CMU. All rights reserved.
//

#ifndef solver_h
#define solver_h

#include <stdio.h>

#endif /* solver_h */

void SwapSeqEntries(int S1, int S2);
void InitEntry(int i, int j, int val);
void PrintArray();
void ConsoleInput();
void PrintStats();
void Succeed();
int NextSeq(int S);
void Place(int S);
