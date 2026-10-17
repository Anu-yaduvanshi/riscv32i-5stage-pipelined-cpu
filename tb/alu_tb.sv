`timescale 1ns / 1ps

module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  alu_ctrl;
    logic [31:0] alu_result;
    logic        zero;

    alu dut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .alu_result(alu_result),
        .zero(zero)
    );

    initial begin
        $dumpfile("waves/alu.vcd");
        $dumpvars(0, alu_tb);

        // 1. ADD: 15 + 27 = 42
        a = 32'd15; b = 32'd27; alu_ctrl = 4'b0000; #10;
        if (alu_result !== 32'd42 || zero !== 1'b0) $fatal(1, "[FAIL] ADD failed");

        // 2. SUB: 50 - 50 = 0 (Check zero flag)
        a = 32'd50; b = 32'd50; alu_ctrl = 4'b0001; #10;
        if (alu_result !== 32'd0 || zero !== 1'b1) $fatal(1, "[FAIL] SUB zero failed");

        // 3. AND: 0xF0F0 & 0x00FF = 0x00F0
        a = 32'h0000_F0F0; b = 32'h0000_00FF; alu_ctrl = 4'b0010; #10;
        if (alu_result !== 32'h0000_00F0) $fatal(1, "[FAIL] AND failed");

        // 4. OR: 0x1200 | 0x0034 = 0x1234
        a = 32'h0000_1200; b = 32'h0000_0034; alu_ctrl = 4'b0011; #10;
        if (alu_result !== 32'h0000_1234) $fatal(1, "[FAIL] OR failed");

        // 5. XOR: 0xAAAA ^ 0xFFFF = 0x5555
        a = 32'h0000_AAAA; b = 32'h0000_FFFF; alu_ctrl = 4'b0100; #10;
        if (alu_result !== 32'h0000_5555) $fatal(1, "[FAIL] XOR failed");

        // 6. SLT: Signed -5 < 2 (True = 1)
        a = -32'd5; b = 32'd2; alu_ctrl = 4'b0101; #10;
        if (alu_result !== 32'd1) $fatal(1, "[FAIL] SLT signed check failed");

        // 7. SLTU: Unsigned -5 (0xFFFFFFFB) < 2 (False = 0)
        a = -32'd5; b = 32'd2; alu_ctrl = 4'b0110; #10;
        if (alu_result !== 32'd0) $fatal(1, "[FAIL] SLTU unsigned check failed");

        // 8. SLL: 1 << 4 = 16
        a = 32'd1; b = 32'd4; alu_ctrl = 4'b0111; #10;
        if (alu_result !== 32'd16) $fatal(1, "[FAIL] SLL failed");

        // 9. SRL: 0x80000000 >> 1 = 0x40000000
        a = 32'h8000_0000; b = 32'd1; alu_ctrl = 4'b1000; #10;
        if (alu_result !== 32'h4000_0000) $fatal(1, "[FAIL] SRL failed");

        // 10. SRA: 0x80000000 >>> 1 = 0xC0000000 (Sign preserved)
        a = 32'h8000_0000; b = 32'd1; alu_ctrl = 4'b1001; #10;
        if (alu_result !== 32'hC000_0000) $fatal(1, "[FAIL] SRA failed");

        $display("[PASS] ALU tests completed successfully!");
        $finish;
    end

endmodule