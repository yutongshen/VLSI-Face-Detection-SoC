//================================================
// Auther:      Hsieh Hsien-Hua (Henry)
// Filename:    Decoder.sv
// Description: Decode which slave to select
// Version:     1.0
//================================================

`include "AHB_def.svh"

module Decoder (
    input        [`AHB_ADDR_BITS-1:0] HADDR,
    output logic                      HSELDefault,
    output logic                      HSEL_S1,
    output logic                      HSEL_S2,
    output logic                      HSEL_S3,
    output logic                      HSEL_S4,
    output logic                      HSEL_S5,
    output logic                      HSEL_S6,
    output logic                      HSEL_S7
);

always_comb // define HSELDefault, HSEL_S1 and HSEL_S2
begin
    /* complete this part by yourself */
    {HSEL_S7, HSEL_S6, HSEL_S5, HSEL_S4, HSEL_S3, HSEL_S2, HSEL_S1, HSELDefault} 
        = HADDR[`AHB_ADDR_BITS- 1]     ? `AHB_SLAVE_0:
          HADDR[`AHB_ADDR_BITS- 2]     ? `AHB_SLAVE_6:
          HADDR[`AHB_ADDR_BITS- 3]     ? `AHB_SLAVE_5:
          HADDR[`AHB_ADDR_BITS- 4]     ? `AHB_SLAVE_4:
          HADDR[`AHB_ADDR_BITS- 5]     ? `AHB_SLAVE_7:
          HADDR[`AHB_ADDR_BITS-15]     ? `AHB_SLAVE_3:
          HADDR[`AHB_ADDR_BITS-16]     ? `AHB_SLAVE_2:
          ~|HADDR[`AHB_ADDR_BITS-1:16] ? `AHB_SLAVE_1:
                                         `AHB_SLAVE_0;
end

endmodule
