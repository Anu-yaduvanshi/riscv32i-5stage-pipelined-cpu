// tb/pc_tb.sv
`timescale 1ns / 1ps

module pc_tb;

    logic        clk;
    logic        reset;
    logic        en;
    logic [31:0] next_pc;
    logic [31:0] current_pc;

    pc dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    // 100MHz clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/pc.vcd");
        $dumpvars(0, pc_tb);

        clk     = 0;
        reset   = 1;
        en      = 1;
        next_pc = 32'h0000_0004;

        #12;
        if (current_pc !== 32'h0000_0000) begin
            $display("[FAIL] Expected current_pc = 0 during reset, got %h", current_pc);
            $fatal(1);
        end

        @(negedge clk);
        reset = 0;

        @(posedge clk); #1;
        if (current_pc !== 32'h0000_0004) begin
            $display("[FAIL] Expected current_pc = 0x00000004, got %h", current_pc);
            $fatal(1);
        end

        next_pc = 32'h0000_0008;
        @(posedge clk); #1;
        if (current_pc !== 32'h0000_0008) begin
            $display("[FAIL] Expected current_pc = 0x00000008, got %h", current_pc);
            $fatal(1);
        end

        // Stall test
        en      = 0;
        next_pc = 32'h0000_000C;
        @(posedge clk); #1;
        if (current_pc !== 32'h0000_0008) begin
            $display("[FAIL] PC updated despite en=0! Expected 0x00000008, got %h", current_pc);
            $fatal(1);
        end

        // Jump redirection test
        en      = 1;
        next_pc = 32'h0000_1000;
        @(posedge clk); #1;
        if (current_pc !== 32'h0000_1000) begin
            $display("[FAIL] Redirection failed! Expected 0x00001000, got %h", current_pc);
            $fatal(1);
        end

        $display("[PASS] Program Counter tests completed successfully!");
        $finish;
    end

endmodule