module cpu #(
    parameter RESET_VECTOR = 32'h80000000
) (
    input wire i_clk,
    input wire i_rst_n,
    output wire [31:0] o_inst_raddr,
    output wire o_inst_re,
    input wire [31:0] i_inst_rdata,
    output wire [31:0] o_mem_addr,
    output wire [31:0] o_mem_wdata,
    output wire [31:0] o_mem_wmask,
    output wire o_mem_we,
    input wire [31:0] o_mem_rdata
);
    typedef enum {STAGE_IF, STAGE_ID, STAGE_EX, STAGE_MEM, STAGE_WB} stage_t;
    logic [4:0] stall = 5'b0;

    // fetch stage
    wire pc_sel;
    wire [31:0] alu_result;
    wire [31:0] pc, inst;
    inst_fetch #(.RESET_VECTOR(RESET_VECTOR)) fetch (
        .i_clk(i_clk), .i_rst_n(i_rst_n),
        .i_stall(1'b0), .i_jump(pc_sel), .i_jdest(alu_result),
        .o_raddr(o_inst_raddr),
        .o_re(o_inst_re),
        .i_rdata(i_inst_rdata),
        .o_pc(pc),
        .o_inst(inst)
    );

    logic [31:0] id_inst;
    logic [31:0] id_pc;
    always_ff @(posedge i_clk) begin
        id_inst <= inst;
        id_pc <= pc;
    end

    // decode stage
    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire [3:0] alu_op_sel;
    wire alu_sub;
    wire [1:0] alu_bool_op;
    wire alu_shift_dir, alu_a_sel, alu_b_sel;
    wire cmp_sig;
    wire [1:0] br_type;
    wire cond_br;
    wire jump;
    wire mem_we;
    wire [1:0] load_size;
    wire load_sig;
    wire [2:0] wb_sel;
    wire wb_we;
    decoder decoder (
        .i_inst(id_inst),
        .o_rs1(rs1), .o_rs2(rs2), .o_rd(rd),
        .o_imm(imm),
        .o_alu_op_sel(alu_op_sel),
        .o_alu_sub(alu_sub),
        .o_alu_bool_op(alu_bool_op),
        .o_alu_shift_dir(alu_shift_dir),
        .o_alu_a_sel(alu_a_sel), .o_alu_b_sel(alu_b_sel),
        .o_cmp_sig(cmp_sig),
        .o_br_type(br_type),
        .o_cond_br(cond_br),
        .o_jump(jump),
        .o_mem_we(mem_we),
        .o_load_size(load_size),
        .o_load_sig(load_sig),
        .o_wb_sel(wb_sel),
        .o_wb_we(wb_we)
    );
    assign pc_sel = (cond_br && br_taken) || jump;

    wire [31:0] rs1_data, rs2_data;
    logic [31:0] wb_data;
    logic [4:0] wb_rd;
    logic wb_wb_we;
    register_file rf (
        .i_clk(i_clk),
        .i_write_index(wb_rd), .i_write_data(wb_data), .i_write_enable(wb_wb_we),
        .i_read_index1(rs1), .o_read_data1(rs1_data),
        .i_read_index2(rs2), .o_read_data2(rs2_data)
    );

    logic [4:0] ex_rd;
    logic [31:0] ex_rs1_data, ex_rs2_data, ex_imm;
    logic [31:0] ex_pc;
    logic [3:0] ex_alu_op_sel;
    logic ex_alu_sub;
    logic [1:0] ex_alu_bool_op;
    logic ex_alu_shift_dir, ex_alu_a_sel, ex_alu_b_sel, ex_cmp_sig;
    logic ex_mem_we;
    logic [1:0] ex_load_size;
    logic ex_load_sig;
    logic [2:0] ex_wb_sel;
    logic ex_wb_we;
    always_ff @(posedge i_clk) begin
        ex_rd <= rd;
        ex_rs1_data <= rs1_data;
        ex_rs2_data <= rs2_data;
        ex_imm <= imm;
        ex_pc <= id_pc;
        ex_alu_op_sel <= alu_op_sel;
        ex_alu_sub <= alu_sub;
        ex_alu_bool_op <= alu_bool_op;
        ex_alu_shift_dir <= alu_shift_dir;
        ex_alu_a_sel <= alu_a_sel;
        ex_alu_b_sel <= alu_b_sel;
        ex_cmp_sig <= cmp_sig;
        ex_mem_we <= mem_we;
        ex_load_size <= load_size;
        ex_load_sig <= load_sig;
        ex_wb_sel <= wb_sel;
        ex_wb_we <= wb_we;
    end

    // execute stage
    wire [31:0] op_a = ex_alu_a_sel ? ex_pc : ex_rs1_data;
    wire [31:0] op_b = ex_alu_b_sel ? ex_imm : ex_rs2_data;
    alu alu (
        .i_op_a(op_a),
        .i_op_b(op_b),
        .i_sub(ex_alu_sub),
        .i_bool_op(ex_alu_bool_op),
        .i_op_sel(ex_alu_op_sel),
        .i_shift_dir(ex_alu_shift_dir),
        .i_cmp_sig(ex_cmp_sig),
        .o_result(alu_result)
    );

    wire cmp_lt, cmp_eq, cmp_gt;
    branch_comparator cmp (
        .i_op_a(rs1_data),
        .i_op_b(rs2_data),
        .i_cmp_sig(cmp_sig),
        .o_lt(cmp_lt),
        .o_eq(cmp_eq),
        .o_gt(cmp_gt)
    );

    // TODO
    assign br_taken =   (br_type === 2'b00) ? cmp_eq :
                        (br_type === 2'b01) ? !cmp_eq :
                        (br_type === 2'b10) ? cmp_lt :
                        cmp_gt;

    logic [31:0] mem_pc;
    logic [31:0] mem_alu_result;
    logic [31:0] mem_rs2_data;
    logic mem_mem_we;
    logic [1:0] mem_load_size;
    logic mem_load_sig;
    logic [2:0] mem_wb_sel;
    logic mem_wb_we;
    logic [4:0] mem_rd;
    always_ff @(posedge i_clk) begin
        mem_pc <= ex_pc;
        mem_alu_result <= alu_result;
        mem_rs2_data <= ex_rs2_data;
        mem_mem_we <= ex_mem_we;
        mem_load_size <= ex_load_size;
        mem_load_sig <= ex_load_sig;
        mem_wb_sel <= ex_wb_sel;
        mem_wb_we <= ex_wb_we;
        mem_rd <= ex_rd;
    end

    // memory stage
    wire [31:0] mem_addr, mem_mask;
    wire [4:0] shift_amount = (mem_alu_result & 32'h3) << 3;
    rw_mask mask (.i_addr(mem_alu_result), .i_size(mem_load_size), .o_addr(mem_addr), .o_mask(mem_mask));

    assign o_mem_addr = mem_addr;
    assign o_mem_wdata = mem_rs2_data << shift_amount;
    assign o_mem_wmask = mem_mask;
    assign o_mem_we = mem_mem_we;
    wire signed [31:0] masked_read = o_mem_rdata & mem_mask;
    wire [31:0] aligned_read = mem_load_sig ? (masked_read >>> shift_amount) : (masked_read >> shift_amount);

    always_ff @(posedge i_clk) begin
        wb_data <=  (mem_wb_sel[0]) ? mem_alu_result : 
                    (mem_wb_sel[1]) ? aligned_read :
                    (mem_pc + 4); // TODO: wrong pc
        wb_rd <= mem_rd;
        wb_wb_we <= mem_wb_we;
    end
endmodule
