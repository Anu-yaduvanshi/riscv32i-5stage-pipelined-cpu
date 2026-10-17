`timescale 1ns / 1ps

module cpu_tb;

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
        $dumpfile("waves/cpu.vcd");
        $dumpvars(0, cpu_tb);

        $readmemh("programs/single_cycle.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        // Run 12 cycles
        repeat (12) @(posedge clk);

        #1;
        $display("Execution Complete. Register Dump:");
        $display("x1 (Expected 10) : %0d", dut.u_regfile.regs[1]);
        $display("x2 (Expected 20) : %0d", dut.u_regfile.regs[2]);
        $display("x3 (Expected 30) : %0d", dut.u_regfile.regs[3]);
        $display("x4 (Expected 10) : %0d", dut.u_regfile.regs[4]);
        $display("x5 (Expected 30) : %0d", dut.u_regfile.regs[5]);
        $display("x6 (Expected 42) : %0d", dut.u_regfile.regs[6]);

        if (dut.u_regfile.regs[1] !== 32'd10 ||
            dut.u_regfile.regs[2] !== 32'd20 ||
            dut.u_regfile.regs[3] !== 32'd30 ||
            dut.u_regfile.regs[4] !== 32'd10 ||
            dut.u_regfile.regs[5] !== 32'd30 ||
            dut.u_regfile.regs[6] !== 32'd42) begin
            $display("[FAIL] Final CPU register state is incorrect!");
            $fatal(1);
        end

        $display("[PASS] Single-Cycle CPU executed successfully!");
        $finish;
    end

endmodule