// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    VolatileFilter.sv                      //
// Description: Prevent uncacheable data store into    //
//              cache                                  //
// Version:     1.0                                    //
// =================================================== //


module VolatileFilter(
    input        [31:0] ADDR,
    output logic        VOLATILE
);

assign VOLATILE = ADDR[31:27] == 5'b10 || ADDR[31:27] == 5'b1000 || ADDR[31:27] == 5'b1;

endmodule
