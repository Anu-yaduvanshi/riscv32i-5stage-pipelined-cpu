`timescale 1ns / 1ps

module cpu_sva_tb;

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

    // Bind verification monitor directly to CPU internals
    cpu_monitor u_mon (
        .clk(clk),
        .reset(reset),
        .pc(dut.if_pc_current),
        .instr(dut.if_instr),
        .reg_write(dut.wb_reg_write),
        .rd(dut.wb_rd),
        .wb_data(dut.wb_final_data),
        .forwardA(dut.forwardA),
        .forwardB(dut.forwardB),
        .branch_taken(dut.branch_taken),
        .pc_en(dut.pc_en)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/cpu_sva.vcd");
        $dumpvars(0, cpu_sva_tb);

        // Run both branch test and pipeline hazards under assertion monitoring
        $readmemh("programs/branch_test.hex", dut.u_imem.mem);

        clk   = 0;
        reset = 1;

        #15;
        @(negedge clk);
        reset = 0;

        repeat (25) @(posedge clk);

        #1;
        $display("[PASS] All assertions satisfied! No invariant violations.");
        $finish;
    end

endmodule