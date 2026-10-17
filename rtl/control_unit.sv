`timescale 1ns / 1ps

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7_5, // instr[30]
    output logic       reg_write,
    output logic       mem_to_reg,
    output logic       mem_read,
    output logic       mem_write,
    output logic       alu_src,
    output logic       branch,
    output logic       jump,
    output logic [3:0] alu_ctrl
);

    logic [1:0] alu_op;

    // Main Decoder
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                reg_write  = 1'b1;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b10;
            end
            7'b0010011: begin // I-type ALU
                reg_write  = 1'b1;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b10;
            end
            7'b0000011: begin // LW
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                mem_read   = 1'b1;
                mem_write  = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;
            end
            7'b0100011: begin // SW
                reg_write  = 1'b0;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;
            end
            7'b1100011: begin // BEQ
                reg_write  = 1'b0;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b1;
                jump       = 1'b0;
                alu_op     = 2'b01;
            end
            7'b1101111: begin // JAL
                reg_write  = 1'b1;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
                jump       = 1'b1;
                alu_op     = 2'b00;
            end
            default: begin
                reg_write  = 1'b0;
                mem_to_reg = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;
            end
        endcase
    end

    // ALU Decoder
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD (LW, SW, JAL)
            2'b01: alu_ctrl = 4'b0001; // SUB (BEQ)
            2'b10: begin               // R-type or I-type ALU
                case (funct3)
                    3'b000:  alu_ctrl = (opcode == 7'b0110011 && funct7_5) ? 4'b0001 : 4'b0000; // SUB / ADD
                    3'b111:  alu_ctrl = 4'b0010; // AND
                    3'b110:  alu_ctrl = 4'b0011; // OR
                    3'b100:  alu_ctrl = 4'b0100; // XOR
                    3'b010:  alu_ctrl = 4'b0101; // SLT
                    3'b011:  alu_ctrl = 4'b0110; // SLTU
                    3'b001:  alu_ctrl = 4'b0111; // SLL
                    3'b101:  alu_ctrl = (funct7_5) ? 4'b1001 : 4'b1000; // SRA / SRL
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule