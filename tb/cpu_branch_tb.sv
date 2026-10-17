`timescale 1ns / 1ps

module cpu_branch_tb;

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

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/cpu_branch.vcd");
        $dumpvars(0, cpu_branch_tb);

        $readmemh("programs/branch_test.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        repeat (22) @(posedge clk);

        #1;
        $display("==================================================");
        $display(" PHASE 15: BRANCH FLUSH & CONTROL HAZARD RESULTS ");
        $display("==================================================");
        $display("x1 (Expected  5) : %0d", dut.u_regfile.regs[1]);
        $display("x2 (Expected  5) : %0d", dut.u_regfile.regs[2]);
        $display("x3 (Trap 1, Exp 0): %0d [FLUSHED!]", dut.u_regfile.regs[3]);
        $display("x4 (Trap 2, Exp 0): %0d [FLUSHED!]", dut.u_regfile.regs[4]);
        $display("x5 (Target, Exp 42): %0d", dut.u_regfile.regs[5]);
        $display("x6 (Sequential, 7): %0d", dut.u_regfile.regs[6]);
        $display("==================================================");

        if (dut.u_regfile.regs[1] === 32'd5  &&
            dut.u_regfile.regs[2] === 32'd5  &&
            dut.u_regfile.regs[3] === 32'd0  &&
            dut.u_regfile.regs[4] === 32'd0  &&
            dut.u_regfile.regs[5] === 32'd42 &&
            dut.u_regfile.regs[6] === 32'd7) begin
            $display("[PASS] Control Hazards and Branch Flushing Verified Successfully!");
        end else begin
            $display("[FAIL] Control hazard verification failed!");
            $fatal(1);
        end

        $finish;
    end

endmodule