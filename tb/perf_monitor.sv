`timescale 1ns / 1ps

module perf_monitor (
    input logic clk,
    input logic reset,
    input logic inst_retired,
    input logic stall_cycle,
    input logic branch_flush
);

    integer total_cycles;
    integer total_retired;
    integer total_stalls;
    integer total_flushes;
    real    cpi;
    real    ipc;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            total_cycles  <= 0;
            total_retired <= 0;
            total_stalls  <= 0;
            total_flushes <= 0;
        end else begin
            total_cycles <= total_cycles + 1;

            if (inst_retired)
                total_retired <= total_retired + 1;

            if (stall_cycle)
                total_stalls <= total_stalls + 1;

            if (branch_flush)
                total_flushes <= total_flushes + 2; // Each flush discards 2 instructions
        end
    end

    // Task to report final statistics at end of testbench
    task print_report();
        begin
            if (total_retired > 0) begin
                cpi = real'(total_cycles) / real'(total_retired);
                ipc = 1.0 / cpi;
            end else begin
                cpi = 0.0;
                ipc = 0.0;
            end

            $display("       PIPELINE PERFORMANCE PROFILING REPORT      ");
            $display(" Total Clock Cycles       : %0d", total_cycles);
            $display(" Instructions Retired     : %0d", total_retired);
            $display(" Load-Use Stall Cycles    : %0d", total_stalls);
            $display(" Branch Penalty Cycles    : %0d", total_flushes);
            $display(" Measured CPI             : %0.2f", cpi);
            $display(" Measured IPC             : %0.2f", ipc);
        end
    endtask

endmodule