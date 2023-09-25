module decode_stage (
    input wire i_clk,
    input wire [31:0] i_inst,
    input wire [31:0] i_write_data,
    input wire i_write_enable,
    output wire [31:0] o_read1,
    output wire [31:0] o_read2,
    output wire [31:0] o_imm
);
    wire [4:0] rs1 = i_inst[19:15];
    wire [4:0] rs2 = i_inst[24:20];
    wire [4:0] rd = i_inst[11:7];

    wire [5:0] ty;
    assign ty[R] = !i_inst[6] && i_inst[5] && i_inst[4] && i_inst[2];
    assign ty[I] = (!i_inst[5] && !i_inst[2]) || (i_inst[6:4] === 3'b111) || (i_inst[4:2] === 3'b001);
    assign ty[S] = i_inst[6:4] === 3'b010;
    assign ty[B] = i_inst[6] && (i_inst[4:2] === 3'b000);
    assign ty[U] = i_inst[4:2] === 3'b101;
    assign ty[J] = i_inst[3];

    register_file file (
        .clk(i_clk),
        .i_write_index(rd), .i_write_data(i_write_data), .i_write_enable(i_write_enable),
        .i_read_index1(rs1), .o_read_data1(o_read1),
        .i_read_index2(rs2), .o_read_data2(o_read2));

    immediate_generator imm_gen (.i_inst(i_inst), .i_type(ty), .o_immediate(o_imm));
endmodule
