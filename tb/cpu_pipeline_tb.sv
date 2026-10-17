`timescale 1ns / 1ps

module cpu_pipeline_tb;

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
        $dumpfile("waves/cpu_pipeline.vcd");
        $dumpvars(0, cpu_pipeline_tb);

        $readmemh("programs/pipeline_test.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        // Run for 20 clock cycles to execute and retire all instructions
        repeat (20) @(posedge clk);

        #1;
        $display(" 5-STAGE PIPELINED CPU VERIFICATION RESULTS       ");
        $display("x1 (Expected  5) : %0d", dut.u_regfile.regs[1]);
        $display("x2 (Expected 10) : %0d", dut.u_regfile.regs[2]);
        $display("x3 (Expected 15) : %0d (Forwarding Test)", dut.u_regfile.regs[3]);
        $display("x4 (Expected 15) : %0d (Load Test)", dut.u_regfile.regs[4]);
        $display("x5 (Expected 30) : %0d (Load-Use Stall Test)", dut.u_regfile.regs[5] );

        if (dut.u_regfile.regs[1] === 32'd5  &&
            dut.u_regfile.regs[2] === 32'd10 &&
            dut.u_regfile.regs[3] === 32'd15 &&
            dut.u_regfile.regs[4] === 32'd15 &&
            dut.u_regfile.regs[5] === 32'd30) begin
            $display("[PASS] 5-Stage Pipelined CPU executed correctly!" );
        end else begin
            $display("[FAIL] Register contents do not match expected values!" );
            $fatal(1);
        end

        $finish;
    end

endmodule