`timescale 1ns / 1ps

module cpu_monitor (
    input logic        clk,
    input logic        reset,
    input logic [31:0] pc,
    input logic [31:0] instr,
    input logic        reg_write,
    input logic [4:0]  rd,
    input logic [31:0] wb_data,
    input logic [1:0]  forwardA,
    input logic [1:0]  forwardB,
    input logic        branch_taken,
    input logic        pc_en
);

    always @(posedge clk) begin
        if (!reset) begin
            // 1. PC Alignment Check
            if (pc[1:0] !== 2'b00) begin
                $display("[ASSERT FAIL @ %0t ps] PC Misalignment detected! PC = %h", $time, pc);
                $fatal(1);
            end

            // 2. x0 Invariant Check
            if (reg_write && (rd == 5'd0) && (wb_data !== 32'd0)) begin
                $display("[ASSERT FAIL @ %0t ps] Illegal write to x0 with value %h!", $time, wb_data);
                $fatal(1);
            end

            // 3. Informational Pipeline Trace
            if (reg_write && (rd != 5'd0)) begin
                $display("[WB COMMIT @ %0t ps] x%0d <= %0d (0x%h)", $time, rd, wb_data, wb_data);
            end
            if (branch_taken) begin
                $display("[BRANCH FLUSH @ %0t ps] Pipeline Flush Triggered!", $time);
            end
        end
    end

endmodule