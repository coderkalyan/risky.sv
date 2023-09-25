enum {R, I, S, B, U, J} inst_type;

module immediate_generator (
    input wire [31:0] i_inst,
    input wire [5:0] i_type,

    output wire [31:0] o_immediate
);
    wire [4:1] chunk1_a = {4{i_type[I] | i_type[J]}} & i_inst[24:21];
    wire [4:1] chunk1_b = {4{i_type[S] | i_type[B]}} & i_inst[11:8];
    wire chunk3_sext = i_inst[31];
    wire chunk3_data = i_type[B] ? i_inst[7] : (i_type[J] & i_inst[20]);

    assign o_immediate[0] = (i_type[I] & i_inst[20]) | (i_type[S] & i_inst[7]);
    assign o_immediate[4:1] = chunk1_a | chunk1_b;
    assign o_immediate[10:5] = {6{!i_type[U]}} & i_inst[30:25];
    assign o_immediate[11] = (i_type[I] | i_type[S]) ? chunk3_sext : chunk3_data;
    assign o_immediate[19:12] = (i_type[U] | i_type[J]) ? i_inst[19:12] : {8{i_inst[31]}};
    assign o_immediate[30:20] = i_type[U] ? i_inst[30:20] : {11{i_inst[31]}};
    assign o_immediate[31] = i_inst[31];
endmodule
