`timescale 1ns / 1ps

module control_unit_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       reg_write, mem_to_reg, mem_read, mem_write, alu_src, branch, jump;
    logic [3:0] alu_ctrl;

    control_unit dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        $dumpfile("waves/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        // 1. R-type ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 0; #10;
        if (reg_write !== 1 || alu_src !== 0 || alu_ctrl !== 4'b0000) $fatal(1, "[FAIL] R-type ADD");

        // 2. R-type SUB
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1; #10;
        if (reg_write !== 1 || alu_src !== 0 || alu_ctrl !== 4'b0001) $fatal(1, "[FAIL] R-type SUB");

        // 3. I-type ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7_5 = 0; #10;
        if (reg_write !== 1 || alu_src !== 1 || alu_ctrl !== 4'b0000) $fatal(1, "[FAIL] ADDI");

        // 4. LW
        opcode = 7'b0000011; funct3 = 3'b010; funct7_5 = 0; #10;
        if (reg_write !== 1 || mem_read !== 1 || mem_to_reg !== 1 || alu_src !== 1 || alu_ctrl !== 4'b0000) $fatal(1, "[FAIL] LW");

        // 5. SW
        opcode = 7'b0100011; funct3 = 3'b010; funct7_5 = 0; #10;
        if (reg_write !== 0 || mem_write !== 1 || alu_src !== 1 || alu_ctrl !== 4'b0000) $fatal(1, "[FAIL] SW");

        // 6. BEQ
        opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; #10;
        if (branch !== 1 || reg_write !== 0 || alu_src !== 0 || alu_ctrl !== 4'b0001) $fatal(1, "[FAIL] BEQ");

        // 7. JAL
        opcode = 7'b1101111; funct3 = 3'b000; funct7_5 = 0; #10;
        if (jump !== 1 || reg_write !== 1 || alu_src !== 0) $fatal(1, "[FAIL] JAL");

        $display("[PASS] Control Unit tests completed successfully!");
        $finish;
    end

endmodule