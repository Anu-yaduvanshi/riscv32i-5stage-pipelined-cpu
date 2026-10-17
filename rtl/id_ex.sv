`timescale 1ns / 1ps

module id_ex (
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,
    // Control lines
    input  logic        id_reg_write,
    input  logic        id_mem_to_reg,
    input  logic        id_mem_read,
    input  logic        id_mem_write,
    input  logic        id_alu_src,
    input  logic        id_branch,
    input  logic        id_jump,
    input  logic [3:0]  id_alu_ctrl,
    // Data lines
    input  logic [31:0] id_pc,
    input  logic [31:0] id_rs1_data,
    input  logic [31:0] id_rs2_data,
    input  logic [31:0] id_imm,
    input  logic [4:0]  id_rs1,
    input  logic [4:0]  id_rs2,
    input  logic [4:0]  id_rd,

    // Outputs to EX stage
    output logic        ex_reg_write,
    output logic        ex_mem_to_reg,
    output logic        ex_mem_read,
    output logic        ex_mem_write,
    output logic        ex_alu_src,
    output logic        ex_branch,
    output logic        ex_jump,
    output logic [3:0]  ex_alu_ctrl,
    output logic [31:0] ex_pc,
    output logic [31:0] ex_rs1_data,
    output logic [31:0] ex_rs2_data,
    output logic [31:0] ex_imm,
    output logic [4:0]  ex_rs1,
    output logic [4:0]  ex_rs2,
    output logic [4:0]  ex_rd
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ex_reg_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_mem_read   <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_branch     <= 1'b0;
            ex_jump       <= 1'b0;
            ex_alu_ctrl   <= 4'b0000;
            ex_pc         <= 32'd0;
            ex_rs1_data   <= 32'd0;
            ex_rs2_data   <= 32'd0;
            ex_imm        <= 32'd0;
            ex_rs1        <= 5'd0;
            ex_rs2        <= 5'd0;
            ex_rd         <= 5'd0;
        end else begin
            ex_reg_write  <= id_reg_write;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_mem_read   <= id_mem_read;
            ex_mem_write  <= id_mem_write;
            ex_alu_src    <= id_alu_src;
            ex_branch     <= id_branch;
            ex_jump       <= id_jump;
            ex_alu_ctrl   <= id_alu_ctrl;
            ex_pc         <= id_pc;
            ex_rs1_data   <= id_rs1_data;
            ex_rs2_data   <= id_rs2_data;
            ex_imm        <= id_imm;
            ex_rs1        <= id_rs1;
            ex_rs2        <= id_rs2;
            ex_rd         <= id_rd;
        end
    end

endmodule