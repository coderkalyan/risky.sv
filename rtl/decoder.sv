import types::alu_op_t;

module decoder (
    input wire [31:0] i_inst,

    output wire [4:0] o_rs1,
    output wire [4:0] o_rs2,
    output wire [4:0] o_rd,
    output wire [31:0] o_imm,

    output wire o_pc_sel,

    output wire [3:0] o_alu_op_sel,
    output wire o_alu_sub,
    output wire [1:0] o_alu_bool_op,
    output wire o_alu_shift_dir,
    output wire o_alu_a_sel,
    output wire o_alu_b_sel,
    output wire o_cmp_sig,
    output wire [1:0] o_br_type,
    output wire o_cond_br,
    output wire o_jump,

    output wire o_mem_we,
    output wire [1:0] o_load_size,
    output wire o_load_sig,

    output wire [2:0] o_wb_sel,
    output wire o_wb_we
);
    `include "rtl/defs.vh"

    wire [6:0] opcode = i_inst[6:0];
    wire opcode_arith = opcode === `OPCODE_ARITH;
    wire opcode_arimm = opcode === `OPCODE_ARIMM;
    wire opcode_load = opcode === `OPCODE_LOAD;
    wire opcode_store = opcode === `OPCODE_STORE;
    wire opcode_branch = opcode === `OPCODE_BRANCH;
    wire opcode_jal = opcode === `OPCODE_JAL;
    wire opcode_jalr = opcode === `OPCODE_JALR;
    wire opcode_auipc = opcode === `OPCODE_AUIPC;
    wire opcode_lui = opcode === `OPCODE_LUI;
    wire opcode_env = opcode === `OPCODE_ENV;

    wire format_i = opcode_arimm || opcode_load || opcode_jalr || opcode_env;
    wire format_s = opcode_store;
    wire format_b = opcode_branch;
    wire format_u = opcode_auipc || opcode_lui;
    wire format_j = opcode_jal;

    immediate_generator generator (
        .i_inst(i_inst),
        .i_format_i(format_i),
        .i_format_s(format_s),
        .i_format_b(format_b),
        .i_format_u(format_u),
        .i_format_j(format_j),
        .o_immediate(o_imm)
    );

    assign o_rs1 = i_inst[19:15];
    assign o_rs2 = i_inst[24:20];
    assign o_rd = i_inst[11:7];
    wire [2:0] f3 = i_inst[14:12];
    wire [6:0] f7 = i_inst[31:25];

    wire func_add = f3 === `FUNC_ADD;
    wire func_and = f3 === `FUNC_AND;
    wire func_or = f3 === `FUNC_OR;
    wire func_xor = f3 === `FUNC_XOR;
    wire func_sl = f3 === `FUNC_SL;
    wire func_sr = f3 === `FUNC_SR;
    wire func_slt = (f3 === `FUNC_SLT) || (f3 === `FUNC_SLTU);

    /*
    * 0 addition (and subtraction)
    * 1 slt/sltu
    * 2 boolean
    * 3 shift
    */
   assign o_alu_op_sel[0] = opcode_arith ? func_add : 1'b1;
   assign o_alu_op_sel[1] = opcode_arith && func_slt;
   assign o_alu_op_sel[2] = opcode_arith && (func_and || func_or || func_xor);
   assign o_alu_op_sel[3] = opcode_arith && (func_sl || func_sr);

   assign o_alu_sub = opcode_arith && f7[5]; // TODO: srai
   assign o_alu_bool_op = f3[1:0];
   assign o_alu_shift_dir = func_sr;
   assign o_alu_a_sel = opcode_branch || opcode_jal || opcode_auipc;
   assign o_alu_b_sel = !opcode_arith;
   assign o_cmp_sig = opcode_branch ? f3[1] : f3[0];
   
   assign o_br_type = {f3[2], f3[0]};
   assign o_cond_br = opcode_branch;
   assign o_jump = opcode_jal || opcode_jalr;

   assign o_mem_we = opcode_store;
   assign o_load_size = f3[1:0];
   assign o_load_sig = !f3[2];

   /*
   * 0 alu result
   * 1 memory read
   * 2 pc + 4
   */
  assign o_wb_sel[0] = opcode_arith || opcode_arimm || opcode_auipc || opcode_lui;
  assign o_wb_sel[1] = opcode_load;
  assign o_wb_sel[2] = opcode_jal || opcode_jalr;
  assign o_wb_we = !(opcode_store || opcode_branch);
endmodule
