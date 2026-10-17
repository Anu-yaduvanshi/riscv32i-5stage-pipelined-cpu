`timescale 1ns / 1ps

module if_id (
    input  logic        clk,
    input  logic        reset,
    input  logic        en,      // Stall: 0 freezes register (holds current state)
    input  logic        flush,   // Flush: 1 turns instruction into a NOP (bubble)
    input  logic [31:0] if_pc,
    input  logic [31:0] if_instr,
    output logic [31:0] id_pc,
    output logic [31:0] id_instr
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            id_pc    <= 32'd0;
            id_instr <= 32'h0000_0013; // NOP (ADDI x0, x0, 0)
        end else if (flush) begin
            id_pc    <= 32'd0;
            id_instr <= 32'h0000_0013; // Inject NOP
        end else if (en) begin
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end

endmodule