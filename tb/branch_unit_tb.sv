`timescale 1ns / 1ps

module branch_unit_tb;

    logic [2:0] funct3;
    logic       branch;
    logic       jump;
    logic       alu_zero;
    logic       branch_taken;

    branch_unit dut (
        .funct3(funct3),
        .branch(branch),
        .jump(jump),
        .alu_zero(alu_zero),
        .branch_taken(branch_taken)
    );

    initial begin
        $dumpfile("waves/branch_unit.vcd");
        $dumpvars(0, branch_unit_tb);

        // 1. BEQ Taken (alu_zero = 1)
        funct3 = 3'b000; branch = 1; jump = 0; alu_zero = 1; #10;
        if (branch_taken !== 1) $fatal(1, "[FAIL] BEQ taken failed");

        // 2. BEQ Not Taken (alu_zero = 0)
        funct3 = 3'b000; branch = 1; jump = 0; alu_zero = 0; #10;
        if (branch_taken !== 0) $fatal(1, "[FAIL] BEQ not taken failed");

        // 3. BNE Taken (alu_zero = 0)
        funct3 = 3'b001; branch = 1; jump = 0; alu_zero = 0; #10;
        if (branch_taken !== 1) $fatal(1, "[FAIL] BNE taken failed");

        // 4. BNE Not Taken (alu_zero = 1)
        funct3 = 3'b001; branch = 1; jump = 0; alu_zero = 1; #10;
        if (branch_taken !== 0) $fatal(1, "[FAIL] BNE not taken failed");

        // 5. JAL (Unconditional jump)
        funct3 = 3'b000; branch = 0; jump = 1; alu_zero = 0; #10;
        if (branch_taken !== 1) $fatal(1, "[FAIL] JAL jump failed");

        $display("[PASS] Branch Unit tests completed successfully!");
        $finish;
    end

endmodule