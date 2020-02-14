//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    def.svh
// Description: Hart defination
// Version:     0.1
//================================================
`ifndef DEF_SVH
`define DEF_SVH

// CPU
`define DATA_BITS 32

// Cache
`define CACHE_BLK_BITS 4
`define CACHE_IDX_BITS 6
`define CACHE_LINE_BITS 2 ** (`CACHE_BLK_BITS + 3)
`define CACHE_DEPTH 2 ** (`CACHE_IDX_BITS)
`define CACHE_ADDR_BITS (`CACHE_BLK_BITS + `CACHE_IDX_BITS)
`define CACHE_TAG_BITS `DATA_BITS - `CACHE_ADDR_BITS
`define CACHE_WRITE_BITS 16
`define CACHE_WRITE_WORD_BITS 4
`define CACHE_CNT_BITS 2
`define CACHE_TYPE_BITS 3
`define CACHE_BYTE `CACHE_TYPE_BITS'b000
`define CACHE_HWORD `CACHE_TYPE_BITS'b001
`define CACHE_WORD `CACHE_TYPE_BITS'b010
`define CACHE_BYTE_U `CACHE_TYPE_BITS'b100
`define CACHE_HWORD_U `CACHE_TYPE_BITS'b101

`endif
