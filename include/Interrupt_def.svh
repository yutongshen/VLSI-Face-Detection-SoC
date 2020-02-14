// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Interrupt_def.svh                      //
// Description: Parameter defination                   //
// Version:     1.0                                    //
// =================================================== //

`define INT_SRC_SIZE   2
`define INT_TREE_DEPTH $clog2(`INT_SRC_SIZE)
`define INT_ID_SIZE    `INT_TREE_DEPTH ? `INT_TREE_DEPTH : 1
