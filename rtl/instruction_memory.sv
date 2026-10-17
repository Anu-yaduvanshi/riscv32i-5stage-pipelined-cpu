`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_DEPTH = 64
)(
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:MEM_DEPTH-1];

    assign instr = mem[addr[7:2]];

endmodule