// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Target.sv                              //
// Description: Send interrupt signal to target        //
// Version:     1.0                                    //
// =================================================== //

`include "Interrupt_def.svh"

module Target(
    input        [`INT_SRC_SIZE-1:0] ip,
    output logic                     irq,
    output logic /*[ `INT_ID_SIZE-1:0]*/ id
);

// // Compare tree
// genvar g;
// 
// generate
//     for (g = 0; g < `INT_TREE_DEPTH; g = g + 1) begin : cmp_tree
//         parameter  RES_BITS = `INT_SRC_SIZE/(2 ** (g+1));
//         logic     [RES_BITS-1:0] cmp_res;
// 
//         if (g == 0) begin : leaf
//             assign {id[`INT_TREE_DEPTH-g-1], cmp_tree[g].cmp_res} =
//                        |ip[0+:RES_BITS] ? 
//                            {1'b0, ip[0+:RES_BITS]}:
//                            {1'b1, ip[RES_BITS+:RES_BITS]};
//         end : leaf
//         else begin : tree
//             assign {id[`INT_TREE_DEPTH-g-1], cmp_tree[g].cmp_res} =
//                        |cmp_tree[g-1].cmp_res[0+:RES_BITS] ? 
//                            {1'b0, cmp_tree[g-1].cmp_res[0+:RES_BITS]}:
//                            {1'b1, cmp_tree[g-1].cmp_res[RES_BITS+:RES_BITS]};
//         end : tree
//     end : cmp_tree
// 
//     assign irq = cmp_tree[`INT_TREE_DEPTH-1].cmp_res;
// endgenerate

// assign id  = 1'b0;
// assign irq = ip;

assign id  = ~ip[0] & ip[1] ? 1'b1:
                              1'b0;
assign irq = |ip;

endmodule
