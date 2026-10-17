`timescale 1ns / 1ps

module ex_mem (
    input  logic        clk,
    input  logic        reset,
    // Control
    input  logic        ex_reg_write,
    input  logic        ex_mem_to_reg,
    input  logic        ex_mem_read,
    input  logic        ex_mem_write,
    // Data
    input  logic [31:0] ex_alu_result,
    input  logic [31:0] ex_rs2_data,
    input  logic [4:0]  ex_rd,

    output logic        mem_reg_write,
    output logic        mem_mem_to_reg,
    output logic        mem_mem_read,
    output logic        mem_mem_write,
    output logic [31:0] mem_alu_result,
    output logic [31:0] mem_rs2_data,
    output logic [4:0]  mem_rd
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_reg_write  <= 1'b0;
            mem_mem_to_reg <= 1'b0;
            mem_mem_read   <= 1'b0;
            mem_mem_write  <= 1'b0;
            mem_alu_result <= 32'd0;
            mem_rs2_data   <= 32'd0;
            mem_rd         <= 5'd0;
        end else begin
            mem_reg_write  <= ex_reg_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_alu_result <= ex_alu_result;
            mem_rs2_data   <= ex_rs2_data;
            mem_rd         <= ex_rd;
        end
    end

endmodule