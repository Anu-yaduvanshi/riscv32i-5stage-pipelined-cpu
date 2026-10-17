`timescale 1ns / 1ps

module instruction_memory_tb;

    logic [31:0] addr;
    logic [31:0] instr;

    instruction_memory #(.MEM_DEPTH(64)) dut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("waves/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        $readmemh("programs/program.hex", dut.mem);

        // Test 0: ADDI x1, x0, 5
        addr = 32'h0000_0000;
        #10;
        if (instr !== 32'h0050_0093) begin
            $display("[FAIL] Addr 0x00: expected 00500093, got %h", instr);
            $fatal(1);
        end

        // Test 1: ADDI x2, x0, 10
        addr = 32'h0000_0004;
        #10;
        if (instr !== 32'h00A0_0113) begin
            $display("[FAIL] Addr 0x04: expected 00A00113, got %h", instr);
            $fatal(1);
        end

        // Test 2: ADD x3, x1, x2
        addr = 32'h0000_0008;
        #10;
        if (instr !== 32'h0020_81B3) begin
            $display("[FAIL] Addr 0x08: expected 002081B3, got %h", instr);
            $fatal(1);
        end

        // Test 3: NOP
        addr = 32'h0000_000C;
        #10;
        if (instr !== 32'h0000_0013) begin
            $display("[FAIL] Addr 0x0C: expected 00000013, got %h", instr);
            $fatal(1);
        end

        $display("[PASS] Instruction Memory tests completed successfully!");
        $finish;
    end

endmodule