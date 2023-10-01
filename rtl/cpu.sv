module cpu #(
    parameter RESET_VECTOR = 32'h80000000
) (
    input wire i_clk,
    input wire i_rst_n,
    output wire [31:0] o_pc,
    input wire [31:0] i_inst,
    output wire [31:0] o_mem_addr,
    output wire [31:0] o_mem_wdata,
    output wire [31:0] o_mem_wmask,
    output wire o_mem_we,
    input wire [31:0] o_mem_rdata
);
    // fetch stage
    wire br_taken, pc_sel; // these will be filled in later down
    logic [31:0] pc;
    assign o_pc = pc;
    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n) begin
            pc <= 32'h0;
        end else begin
            pc <= pc_sel ? alu_result : (pc + 4);
        end
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
        .i_inst(i_inst),
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
    wire [31:0] wb_data;
    register_file rf (
        .i_clk(i_clk),
        .i_write_index(rd), .i_write_data(wb_data), .i_write_enable(wb_we),
        .i_read_index1(rs1), .o_read_data1(rs1_data),
        .i_read_index2(rs2), .o_read_data2(rs2_data)
    );

    // execute stage
    wire [31:0] op_a = alu_a_sel ? pc : rs1_data;
    wire [31:0] op_b = alu_b_sel ? imm : rs2_data;
    wire [31:0] alu_result;
    alu alu (
        .i_op_a(op_a),
        .i_op_b(op_b),
        .i_sub(alu_sub),
        .i_bool_op(alu_bool_op),
        .i_op_sel(alu_op_sel),
        .i_shift_dir(alu_shift_dir),
        .i_cmp_sig(cmp_sig),
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

    assign br_taken =   (br_type === 2'b00) ? cmp_eq :
                        (br_type === 2'b01) ? !cmp_eq :
                        (br_type === 2'b10) ? cmp_lt :
                        cmp_gt;

    // memory stage
    wire [31:0] mem_addr, mem_mask;
    wire [4:0] shift_amount = (alu_result & 32'h3) << 3;
    rw_mask mask (.i_addr(alu_result), .i_size(load_size), .o_addr(mem_addr), .o_mask(mem_mask));

    wire [31:0] raw_read;
    assign o_mem_addr = mem_addr;
    assign o_mem_wdata = rs2_data << shift_amount;
    assign o_mem_wmask = mem_mask;
    assign o_mem_we = mem_we;
    assign raw_read = o_mem_rdata;
    wire signed [31:0] masked_read = raw_read & mem_mask;
    wire [31:0] aligned_read = load_sig ? (masked_read >>> shift_amount) : (masked_read >> shift_amount);

    // write back stage
    assign wb_data = (wb_sel[0]) ? alu_result : 
                     (wb_sel[1]) ? aligned_read :
                     (pc + 4);
endmodule
