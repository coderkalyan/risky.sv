module immediate_generator (
    input wire [31:0] i_inst,
    input wire i_format_i,
    input wire i_format_s,
    input wire i_format_b,
    input wire i_format_u,
    input wire i_format_j,

    output wire [31:0] o_immediate
);
    assign o_immediate[0] = i_format_i ? i_inst[20] : i_format_s ? i_inst[7] : 1'b0;
    assign o_immediate[4:1] =   (i_format_s || i_format_b) ? i_inst[11:8] :
                                (i_format_i || i_format_j) ? i_inst[24:21] : 4'b0;
    assign o_immediate[10:5] = i_format_u ? 6'b0 : i_inst[30:25];
    assign o_immediate[11] =    (i_format_i || i_format_s) ? i_inst[31] :
                                i_format_b ? i_inst[7] :
                                i_format_j ? i_inst[20] : 1'b0;
    assign o_immediate[19:12] = (i_format_u || i_format_j) ? i_inst[19:12] : {8{i_inst[31]}};
    assign o_immediate[30:20] = i_format_u ? i_inst[30:20] : {11{i_inst[31]}};
    assign o_immediate[31] = i_inst[31];
endmodule
