`timescale 1ns / 1ps

module branch_unit (
    input  logic [2:0]  funct3,
    input  logic        branch,
    input  logic        jump,
    input  logic        alu_zero,
    output logic        branch_taken
);

    logic condition_met;

    always @(*) begin
        case (funct3)
            3'b000:  condition_met = alu_zero;  // BEQ
            3'b001:  condition_met = ~alu_zero; // BNE
            default: condition_met = 1'b0;
        endcase
    end

    assign branch_taken = (branch & condition_met) | jump;

endmodule