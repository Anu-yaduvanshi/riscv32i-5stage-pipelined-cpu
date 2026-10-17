`timescale 1ns / 1ps

module cpu (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_out
);

    // IF Stage Wires
    logic [31:0] if_pc_current, if_pc_next, if_pc_plus_4;
    logic [31:0] if_instr;
    logic        pc_en;

    // IF/ID Pipeline Register Wires
    logic        if_id_en;
    logic        if_id_flush;
    logic [31:0] id_pc;
    logic [31:0] id_instr;

    // ID Stage Wires
    logic        id_reg_write, id_mem_to_reg, id_mem_read, id_mem_write;
    logic        id_alu_src, id_branch, id_jump;
    logic [3:0]  id_alu_ctrl;
    logic [31:0] id_rs1_data, id_rs2_data, id_imm;
    logic [4:0]  id_rs1, id_rs2, id_rd;
    logic        id_ex_flush_hazard;
    logic        id_ex_flush_final;

    assign id_rs1 = id_instr[19:15];
    assign id_rs2 = id_instr[24:20];
    assign id_rd  = id_instr[11:7];

    // ID/EX Pipeline Register Wires
    logic        ex_reg_write, ex_mem_to_reg, ex_mem_read, ex_mem_write;
    logic        ex_alu_src, ex_branch, ex_jump;
    logic [3:0]  ex_alu_ctrl;
    logic [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm;
    logic [4:0]  ex_rs1, ex_rs2, ex_rd;

    // EX Stage Wires
    logic [1:0]  forwardA, forwardB;
    logic [31:0] alu_fwd_a, alu_fwd_b, alu_operand_b;
    logic [31:0] ex_alu_result;
    logic        ex_alu_zero;
    logic [31:0] ex_pc_target;
    logic        branch_taken;

    // EX/MEM Pipeline Register Wires
    logic        mem_reg_write, mem_mem_to_reg, mem_mem_read, mem_mem_write;
    logic [31:0] mem_alu_result, mem_rs2_data;
    logic [4:0]  mem_rd;

    // MEM Stage Wires
    logic [31:0] mem_read_data;

    // MEM/WB Pipeline Register Wires
    logic        wb_reg_write, wb_mem_to_reg;
    logic [31:0] wb_read_data, wb_alu_result;
    logic [4:0]  wb_rd;
    logic [31:0] wb_final_data;

    // Pipeline Control / Hazard Management
    assign if_id_flush       = branch_taken;
    assign id_ex_flush_final = id_ex_flush_hazard | branch_taken;

    // IF Logic
    assign if_pc_plus_4 = if_pc_current + 32'd4;
    assign if_pc_next   = (branch_taken) ? ex_pc_target : if_pc_plus_4;

    pc u_pc (
        .clk(clk),
        .reset(reset),
        .en(pc_en),
        .next_pc(if_pc_next),
        .current_pc(if_pc_current)
    );

    instruction_memory #(.MEM_DEPTH(64)) u_imem (
        .addr(if_pc_current),
        .instr(if_instr)
    );

    if_id u_if_id (
        .clk(clk),
        .reset(reset),
        .en(if_id_en),
        .flush(if_id_flush),
        .if_pc(if_pc_current),
        .if_instr(if_instr),
        .id_pc(id_pc),
        .id_instr(id_instr)
    );

    control_unit u_control (
        .opcode(id_instr[6:0]),
        .funct3(id_instr[14:12]),
        .funct7_5(id_instr[30]),
        .reg_write(id_reg_write),
        .mem_to_reg(id_mem_to_reg),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .alu_src(id_alu_src),
        .branch(id_branch),
        .jump(id_jump),
        .alu_ctrl(id_alu_ctrl)
    );

    register_file u_regfile (
        .clk(clk),
        .reset(reset),
        .reg_write(wb_reg_write),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(wb_rd),
        .rd_data(wb_final_data),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );

    immediate_generator u_immgen (
        .instr(id_instr),
        .imm(id_imm)
    );

    hazard_unit u_hazard (
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .ex_rd(ex_rd),
        .ex_mem_read(ex_mem_read),
        .pc_en(pc_en),
        .if_id_en(if_id_en),
        .id_ex_flush(id_ex_flush_hazard)
    );

    id_ex u_id_ex (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush_final),
        .id_reg_write(id_reg_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_alu_src(id_alu_src),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_alu_ctrl(id_alu_ctrl),
        .id_pc(id_pc),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm(id_imm),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_alu_src(ex_alu_src),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_alu_ctrl(ex_alu_ctrl),
        .ex_pc(ex_pc),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd)
    );

    forwarding_unit u_forwarding (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    always @(*) begin
        case (forwardA)
            2'b10:   alu_fwd_a = mem_alu_result;
            2'b01:   alu_fwd_a = wb_final_data;
            default: alu_fwd_a = ex_rs1_data;
        endcase
    end

    always @(*) begin
        case (forwardB)
            2'b10:   alu_fwd_b = mem_alu_result;
            2'b01:   alu_fwd_b = wb_final_data;
            default: alu_fwd_b = ex_rs2_data;
        endcase
    end

    assign alu_operand_b = (ex_alu_src) ? ex_imm : alu_fwd_b;

    alu u_alu (
        .a(alu_fwd_a),
        .b(alu_operand_b),
        .alu_ctrl(ex_alu_ctrl),
        .alu_result(ex_alu_result),
        .zero(ex_alu_zero)
    );

    assign ex_pc_target = ex_pc + ex_imm;

    branch_unit u_branch (
        .funct3(3'b000), // BEQ default
        .branch(ex_branch),
        .jump(ex_jump),
        .alu_zero(ex_alu_zero),
        .branch_taken(branch_taken)
    );

    ex_mem u_ex_mem (
        .clk(clk),
        .reset(reset),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data(alu_fwd_b),
        .ex_rd(ex_rd),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_alu_result(mem_alu_result),
        .mem_rs2_data(mem_rs2_data),
        .mem_rd(mem_rd)
    );

    data_memory #(.MEM_DEPTH(64)) u_dmem (
        .clk(clk),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .addr(mem_alu_result),
        .write_data(mem_rs2_data),
        .read_data(mem_read_data)
    );

    mem_wb u_mem_wb (
        .clk(clk),
        .reset(reset),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_read_data(mem_read_data),
        .mem_alu_result(mem_alu_result),
        .mem_rd(mem_rd),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_read_data(wb_read_data),
        .wb_alu_result(wb_alu_result),
        .wb_rd(wb_rd)
    );

    assign wb_final_data = (wb_mem_to_reg) ? wb_read_data : wb_alu_result;

    assign pc_out         = if_pc_current;
    assign alu_result_out = ex_alu_result;

endmodule