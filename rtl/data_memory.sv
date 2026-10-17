`timescale 1ns / 1ps

module data_memory #(
    parameter MEM_DEPTH = 64
)(
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [31:0] mem [0:MEM_DEPTH-1];

    // Combinational read (aligned to 4 bytes)
    assign read_data = (mem_read) ? mem[addr[7:2]] : 32'd0;

    // Synchronous write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            mem[addr[7:2]] <= write_data;
        end
    end

endmodule