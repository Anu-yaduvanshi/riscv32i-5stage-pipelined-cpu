`timescale 1ns / 1ps

module cpu_benchmark_tb;

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
        $dumpfile("waves/cpu_benchmark.vcd");
        $dumpvars(0, cpu_benchmark_tb);

        $readmemh("programs/benchmark.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        // Run for 25 cycles
        repeat (25) @(posedge clk);

        #1;
        $display("==================================================");
        $display(" PHASE 18: MIXED WORKLOAD VERIFICATION RESULTS    ");
        $display("==================================================");
        $display("x1 (Expected 10)  : %0d", dut.u_regfile.regs[1]);
        $display("x2 (Expected 10)  : %0d", dut.u_regfile.regs[2]);
        $display("x3 (Fwd, Exp 20)  : %0d", dut.u_regfile.regs[3]);
        $display("x4 (Load, Exp 20) : %0d", dut.u_regfile.regs[4]);
        $display("x5 (Stall, Exp 30): %0d", dut.u_regfile.regs[5]);
        $display("x6 (Target, Exp 42): %0d", dut.u_regfile.regs[6]);
        $display("x7 (Trap, Exp 0)  : %0d [FLUSHED!]", dut.u_regfile.regs[7]);
        $display("==================================================");

        if (dut.u_regfile.regs[1] === 32'd10 &&
            dut.u_regfile.regs[2] === 32'd10 &&
            dut.u_regfile.regs[3] === 32'd20 &&
            dut.u_regfile.regs[4] === 32'd20 &&
            dut.u_regfile.regs[5] === 32'd30 &&
            dut.u_regfile.regs[6] === 32'd42 &&
            dut.u_regfile.regs[7] === 32'd0) begin
            $display("[PASS] Mixed Workload Benchmark Executed Successfully!");
        end else begin
            $display("[FAIL] Benchmark register state mismatch!");
            $fatal(1);
        end

        u_perf.print_report();
        $finish;
    end

endmodule