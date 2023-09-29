module cpu (
    input wire i_clk,
    input wire i_rst_n,
    output wire [31:0] o_pc,
    input wire [31:0] i_inst
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
    wire [31:0] rs1, rs2;
    wire [31:0] imm;
    wire [31:0] write_data;
    decode_stage decoder (
        .i_clk(i_clk),
        .i_inst(i_inst),
        .i_write_data(write_data), // TODO
        .i_write_enable(1'b1), // TODO
        .o_read1(rs1),
        .o_read2(rs2),
        .o_imm(imm)
    );

    assign pc_sel = (decoder.ty[B] && br_taken) || decoder.ty[J] || (opcode === 7'b1100111);

    // execute stage
    wire [6:0] opcode = i_inst[6:0];
    wire [3:0] f3 = i_inst[14:12];
    wire [6:0] f7 = i_inst[31:25];

    wire sub = f7[5] && decoder.ty[R]; // TODO: srai
    wire [1:0] bool_op = f3[1:0];
    wire [3:0] op_sel;
    assign op_sel[0] = !decoder.ty[R] || (f3[2:0] === 3'b000);
    assign op_sel[1] = f3[2:1] === 2'b01;
    assign op_sel[2] = (f3[2] === 1'b1) && (f3[1:0] !== 2'b01);
    assign op_sel[3] = (decoder.ty[R] || (opcode[6:4] === 3'b001)) && f3[1:0] === 2'b01;
    wire shift_dir = f3[2];
    wire a_sel = 1'b0; // TODO
    wire b_sel = !decoder.ty[R];

    wire [31:0] alu_result;
    wire cmp_lt, cmp_eq, cmp_gt;
    alu alu (
        .i_op_a(a_sel ? 32'hxxxxxxxx : rs1), // TODO
        .i_op_b(b_sel ? imm : rs2),
        .i_sub(sub),
        .i_bool_op(bool_op),
        .i_op_sel(op_sel),
        .i_shift_dir(shift_dir),
        .i_cmp_sig(1'b0), // TODO
        .o_result(alu_result),
        .o_lt(cmp_lt),
        .o_eq(cmp_eq),
        .o_gt(cmp_gt)
    );

    // memory stage
    wire [31:0] mem_addr, mem_mask;
    wire [4:0] load_size = f3[1:0];
    wire [4:0] shift_amount = (alu_result & 32'h3) << 3;
    rw_mask mask (.i_addr(alu_result), .i_size(load_size[1:0]), .o_addr(mem_addr), .o_mask(mem_mask));

    wire [31:0] raw_read;
    sim_pdmem dmem (
        .i_clk(i_clk),
        .i_addr(mem_addr),
        .i_write_data(rs2 << shift_amount),
        .i_write_enable(decoder.ty[S]),
        .i_write_mask(mem_mask),
        .o_read_data(raw_read)
    );
    wire signed [31:0] masked_read = raw_read & mem_mask;
    wire [31:0] aligned_read = f3[2] ? (masked_read >> shift_amount) : (masked_read >>> shift_amount);

    // write back stage
    wire [2:0] wb_sel;
    assign wb_sel[0] = decoder.ty[R] || (opcode[6:4] === 3'b001) || decoder.ty[U] || decoder.ty[J] || (opcode === 7'b1100111);
    assign wb_sel[1] = opcode[6:4] === 3'b000;
    assign wb_sel[2] = 1'b0;
    assign write_data = (wb_sel[0]) ? alu_result : 
                        (wb_sel[1]) ? aligned_read : 32'hx;
endmodule
