`timescale 1ns / 1ps

module hazard_unit (
    input  logic [4:0] id_rs1,
    input  logic [4:0] id_rs2,
    input  logic [4:0] ex_rd,
    input  logic       ex_mem_read,
    output logic       pc_en,
    output logic       if_id_en,
    output logic       id_ex_flush
);

    logic load_use_hazard;

    assign load_use_hazard = ex_mem_read && (ex_rd != 5'd0) &&
                             ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    always @(*) begin
        if (load_use_hazard) begin
            pc_en       = 1'b0; // Freeze PC
            if_id_en    = 1'b0; // Freeze IF/ID
            id_ex_flush = 1'b1; // Insert bubble (NOP) into ID/EX
        end else begin
            pc_en       = 1'b1;
            if_id_en    = 1'b1;
            id_ex_flush = 1'b0;
        end
    end

endmodule