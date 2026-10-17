`timescale 1ns / 1ps

module cpu_top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_out
);

    // Instantiate core pipelined CPU
    cpu u_core (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .alu_result_out(alu_result_out)
    );

endmodule