// =================================================== //
// Auther:      Yu-Tong Shen                           //
// Filename:    Gateway.sv                             //
// Description: Platform Level Interrupt Controller    //
//              gateway, receive and handle interrupt  //
//              source.                                //
// Version:     1.0                                    //
// =================================================== //

module Gateway(
    input        clk,
    input        rst,
    input        src,      // Interrupt source
    input        claim,    // Interrupt claim
    input        complete, // Interrupt complete
    output logic ip        // Interrupt pending
);

logic src_lvl;  // Interrupt level trigger
logic src_edge; // Interrupt edge trigger
logic pending;
logic [1:0] state;
logic [1:0] nxt_state;

parameter [1:0] STATE_INIT    = 2'b00,
                STATE_INTPEND = 2'b01,
                STATE_HANDLE  = 2'b10;

// Finite State Machine
always_ff @(posedge clk or posedge rst) begin
    if (rst) state <= STATE_INIT;
    else     state <= nxt_state;
end

always_comb begin
    nxt_state = state;
    case (state)
        STATE_INIT:    nxt_state = pending | src_edge ? STATE_INTPEND : STATE_INIT;
        STATE_INTPEND: nxt_state = claim              ? STATE_HANDLE  : STATE_INTPEND;
        STATE_HANDLE:  nxt_state = complete           ? STATE_INIT    : STATE_HANDLE;
    endcase
end

always_comb begin
    ip = 1'b0;
    case (state)
        STATE_INIT:    ip = 1'b0;
        STATE_INTPEND: ip = 1'b1;
        STATE_HANDLE:  ip = 1'b0;
    endcase
end

// Interrupt posedge detect

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        src_lvl  <= 1'b0;
    end
    else begin
        src_lvl  <= src;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        src_edge <= 1'b0;
    end
    else begin
        src_edge <= src & ~src_lvl;
    end
end

// Interrupt pending

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pending <= 1'b0;
    end
    else begin
        if (src_edge)
            pending <= 1'b1;
        else if (claim)
            pending <= 1'b0;
    end
end

endmodule
