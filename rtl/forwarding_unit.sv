`timescale 1ns / 1ps

module forwarding_unit (
    input  logic [4:0] ex_rs1,
    input  logic [4:0] ex_rs2,
    input  logic [4:0] mem_rd,
    input  logic       mem_reg_write,
    input  logic [4:0] wb_rd,
    input  logic       wb_reg_write,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

    // Forward A (ALU Operand 1)
    always @(*) begin
        // Priority 1: EX/MEM hazard (most recent)
        if (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs1)) begin
            forwardA = 2'b10;
        // Priority 2: MEM/WB hazard
        end else if (wb_reg_write && (wb_rd != 5'd0) && (wb_rd == ex_rs1)) begin
            forwardA = 2'b01;
        // Default: No hazard, use register file output
        end else begin
            forwardA = 2'b00;
        end
    end

    // Forward B (ALU Operand 2)
    always @(*) begin
        // Priority 1: EX/MEM hazard (most recent)
        if (mem_reg_write && (mem_rd != 5'd0) && (mem_rd == ex_rs2)) begin
            forwardB = 2'b10;
        // Priority 2: MEM/WB hazard
        end else if (wb_reg_write && (wb_rd != 5'd0) && (wb_rd == ex_rs2)) begin
            forwardB = 2'b01;
        // Default: No hazard, use register file output
        end else begin
            forwardB = 2'b00;
        end
    end

endmodule