`timescale 1ns / 1ps

module immediate_generator_tb;

    logic [31:0] instr;
    logic [31:0] imm;

    immediate_generator dut (
        .instr(instr),
        .imm(imm)
    );

    initial begin
        $dumpfile("waves/immediate_generator.vcd");
        $dumpvars(0, immediate_generator_tb);

        // 1. I-type positive: ADDI x1, x0, 5 -> imm = 5
        instr = 32'h00500093;
        #10;
        if (imm !== 32'd5) begin
            $display("[FAIL] I-type positive failed. Got %h", imm);
            $fatal(1);
        end

        // 2. I-type negative: ADDI x1, x0, -1 -> imm = -1 (0xFFFFFFFF)
        instr = 32'hFFF00093;
        #10;
        if (imm !== 32'hFFFF_FFFF) begin
            $display("[FAIL] I-type negative sign extension failed. Got %h", imm);
            $fatal(1);
        end

        // 3. S-type: SW x2, -4(x1) -> imm = -4 (0xFFFFFFFC)
        // imm[11:5] = 7'b1111111, imm[4:0] = 5'b11100, opcode = 0100011 -> FE20AE23
        instr = 32'hFE20AE23;
        #10;
        if (imm !== 32'hFFFF_FFFC) begin
            $display("[FAIL] S-type negative failed. Got %h", imm);
            $fatal(1);
        end

        // 4. B-type: BEQ x1, x2, -8 -> imm = -8 (0xFFFFFFF8)
        instr = 32'hFE208CE3;
        #10;
        if (imm !== 32'hFFFF_FFF8) begin
            $display("[FAIL] B-type negative failed. Got %h", imm);
            $fatal(1);
        end

        // 5. U-type: LUI x1, 0x12345 -> imm = 0x12345000
        instr = 32'h123450B7;
        #10;
        if (imm !== 32'h1234_5000) begin
            $display("[FAIL] U-type failed. Got %h", imm);
            $fatal(1);
        end
        
        // 6. J-type: JAL x1, 2048 -> offset +2048 (0x00000800)
        // imm[11] is placed at instr[20], sign bit instr[31] = 0
        instr = 32'h001000EF;
        #10;
        if (imm !== 32'h0000_0800) begin
            $display("[FAIL] J-type failed. Got %h", imm);
            $fatal(1);
        end

        $display("[PASS] Immediate Generator tests completed successfully!");
        $finish;
    end

endmodule