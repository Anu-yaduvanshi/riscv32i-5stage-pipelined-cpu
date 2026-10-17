`timescale 1ns / 1ps

module cpu_perf_tb;

    logic        clk;
    logic        reset;
    logic [31:0] pc_out;
    logic [31:0] alu_result_out;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .alu_result_out(alu_result_out)
    );

    // Identify instruction retirement in WB stage
    logic inst_retired;
    assign inst_retired = dut.wb_reg_write && (dut.wb_rd != 5'd0);

    perf_monitor u_perf (
        .clk(clk),
        .reset(reset),
        .inst_retired(inst_retired),
        .stall_cycle(dut.id_ex_flush_hazard),
        .branch_flush(dut.branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/cpu_perf.vcd");
        $dumpvars(0, cpu_perf_tb);

        // Run pipeline hazard program (loads, stores, arithmetic dependencies)
        $readmemh("programs/pipeline_test.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        // Run 20 cycles to finish and drain pipeline
        repeat (20) @(posedge clk);

        #1;
        u_perf.print_report();
        $finish;
    end

endmodule