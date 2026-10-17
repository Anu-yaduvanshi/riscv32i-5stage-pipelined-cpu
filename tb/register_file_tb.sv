`timescale 1ns / 1ps

module register_file_tb;

    logic        clk;
    logic        reset;
    logic        reg_write;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] rd_data;
    logic [31:0] rs1_data, rs2_data;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves/register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk       = 0;
        reset     = 1;
        reg_write = 0;
        rs1       = 0;
        rs2       = 0;
        rd        = 0;
        rd_data   = 0;

        // Reset check
        #12;
        reset = 0;

        // 1. Write 0xDEADBEEF into x1
        @(negedge clk);
        reg_write = 1;
        rd        = 5'd1;
        rd_data   = 32'hDEAD_BEEF;

        @(posedge clk); #1;
        reg_write = 0;

        // 2. Read x1 from rs1
        rs1 = 5'd1;
        #2;
        if (rs1_data !== 32'hDEAD_BEEF) begin
            $display("[FAIL] Expected x1 = 0xDEADBEEF, got %h", rs1_data);
            $fatal(1);
        end

        // 3. Attempt to write 0xCAFEBABE into x0 (must remain 0)
        @(negedge clk);
        reg_write = 1;
        rd        = 5'd0;
        rd_data   = 32'hCAFE_BABE;

        @(posedge clk); #1;
        reg_write = 0;

        // 4. Verify x0 reads as 0
        rs1 = 5'd0;
        #2;
        if (rs1_data !== 32'd0) begin
            $display("[FAIL] x0 was overwritten! Expected 0, got %h", rs1_data);
            $fatal(1);
        end

        // 5. Dual read check: write x2 and read x1 & x2 simultaneously
        @(negedge clk);
        reg_write = 1;
        rd        = 5'd2;
        rd_data   = 32'h1234_5678;

        @(posedge clk); #1;
        reg_write = 0;
        rs1       = 5'd1;
        rs2       = 5'd2;
        #2;
        if (rs1_data !== 32'hDEAD_BEEF || rs2_data !== 32'h1234_5678) begin
            $display("[FAIL] Dual read failed: rs1=%h, rs2=%h", rs1_data, rs2_data);
            $fatal(1);
        end

        $display("[PASS] Register File tests completed successfully!");
        $finish;
    end

endmodule