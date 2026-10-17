// rtl/pc.sv
`timescale 1ns / 1ps

module pc (
    input  logic        clk,
    input  logic        reset,      // Active-high reset
    input  logic        en,         // Write enable: 1 = update, 0 = stall (freeze)
    input  logic [31:0] next_pc,
    output logic [31:0] current_pc
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= 32'h0000_0000;
        end else if (en) begin
            current_pc <= next_pc;
        end
    end

endmodule