`timescale 1ns / 1ps

module hazard_unit_tb;

    logic [4:0] id_rs1, id_rs2, ex_rd;
    logic       ex_mem_read;
    logic       pc_en, if_id_en, id_ex_flush;

    hazard_unit dut (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .ex_rd(ex_rd),
        .ex_mem_read(ex_mem_read),
        .pc_en(pc_en),
        .if_id_en(if_id_en),
        .id_ex_flush(id_ex_flush)
    );

    initial begin
        $dumpfile("waves/hazard_unit.vcd");
        $dumpvars(0, hazard_unit_tb);

        // 1. Normal execution: No hazard
        id_rs1 = 5'd1; id_rs2 = 5'd2; ex_rd = 5'd3; ex_mem_read = 1; #10;
        if (pc_en !== 1 || if_id_en !== 1 || id_ex_flush !== 0) $fatal(1, "[FAIL] Normal op stalled");

        // 2. Load-use on rs1
        id_rs1 = 5'd4; id_rs2 = 5'd2; ex_rd = 5'd4; ex_mem_read = 1; #10;
        if (pc_en !== 0 || if_id_en !== 0 || id_ex_flush !== 1) $fatal(1, "[FAIL] Load-use rs1 failed");

        // 3. Load-use on rs2
        id_rs1 = 5'd1; id_rs2 = 5'd6; ex_rd = 5'd6; ex_mem_read = 1; #10;
        if (pc_en !== 0 || if_id_en !== 0 || id_ex_flush !== 1) $fatal(1, "[FAIL] Load-use rs2 failed");

        // 4. Register match, but instruction in EX is NOT a load (ex_mem_read = 0)
        id_rs1 = 5'd7; id_rs2 = 5'd2; ex_rd = 5'd7; ex_mem_read = 0; #10;
        if (pc_en !== 1 || if_id_en !== 1 || id_ex_flush !== 0) $fatal(1, "[FAIL] Stalled on non-load");

        // 5. Load to x0 (should never stall)
        id_rs1 = 5'd0; id_rs2 = 5'd0; ex_rd = 5'd0; ex_mem_read = 1; #10;
        if (pc_en !== 1 || if_id_en !== 1 || id_ex_flush !== 0) $fatal(1, "[FAIL] Stalled on x0 load");

        $display("[PASS] Hazard Unit tests completed successfully!");
        $finish;
    end

endmodule