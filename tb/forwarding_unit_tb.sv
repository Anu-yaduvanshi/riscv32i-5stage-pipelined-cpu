`timescale 1ns / 1ps

module forwarding_unit_tb;

    logic [4:0] ex_rs1;
    logic [4:0] ex_rs2;
    logic [4:0] mem_rd;
    logic       mem_reg_write;
    logic [4:0] wb_rd;
    logic       wb_reg_write;
    logic [1:0] forwardA;
    logic [1:0] forwardB;

    forwarding_unit dut (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    initial begin
        $dumpfile("waves/forwarding_unit.vcd");
        $dumpvars(0, forwarding_unit_tb);

        // 1. Baseline: No hazard
        ex_rs1 = 5'd1; ex_rs2 = 5'd2; mem_rd = 5'd3; mem_reg_write = 1; wb_rd = 5'd4; wb_reg_write = 1;
        #10;
        if (forwardA !== 2'b00 || forwardB !== 2'b00) $fatal(1, "[FAIL] Baseline failed");

        // 2. EX Hazard on rs1: mem_rd == ex_rs1 == 5'd1
        ex_rs1 = 5'd1; mem_rd = 5'd1; mem_reg_write = 1;
        #10;
        if (forwardA !== 2'b10) $fatal(1, "[FAIL] EX Hazard on rs1 failed");

        // 3. MEM Hazard on rs2: wb_rd == ex_rs2 == 5'd2
        mem_rd = 5'd0; mem_reg_write = 0; wb_rd = 5'd2; wb_reg_write = 1;
        #10;
        if (forwardB !== 2'b01) $fatal(1, "[FAIL] MEM Hazard on rs2 failed");

        // 4. x0 Protection: mem_rd == 0 should NOT trigger forwarding
        ex_rs1 = 5'd0; mem_rd = 5'd0; mem_reg_write = 1;
        #10;
        if (forwardA !== 2'b00) $fatal(1, "[FAIL] Forwarded x0 from EX/MEM");

        // 5. Priority Test: Both EX and MEM write to rs1 -> EX must win (2'b10)
        ex_rs1 = 5'd5;
        mem_rd = 5'd5; mem_reg_write = 1;
        wb_rd  = 5'd5; wb_reg_write  = 1;
        #10;
        if (forwardA !== 2'b10) $fatal(1, "[FAIL] Priority rule failed");

        $display("[PASS] Forwarding Unit tests completed successfully!");
        $finish;
    end

endmodule
