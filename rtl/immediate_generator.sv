`timescale 1ns / 1ps

module immediate_generator (
    input  logic [31:0] instr,
    output logic [31:0] imm
);

    logic [6:0] opcode;
    assign opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            // I-type: OP-IMM (0010011), LOAD (0000011), JALR (1100111)
            7'b0010011,
            7'b0000011,
            7'b1100111: begin
                imm = {{20{instr[31]}}, instr[31:20]};
            end

            // S-type: STORE (0100011)
            7'b0100011: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            // B-type: BRANCH (1100011)
            7'b1100011: begin
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            // U-type: LUI (0110111), AUIPC (0010111)
            7'b0110111,
            7'b0010111: begin
                imm = {instr[31:12], 12'b0};
            end

            // J-type: JAL (1101111)
            7'b1101111: begin
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: begin
                imm = 32'd0;
            end
        endcase
    end

endmodule