module branch_comparator (
    input wire [31:0] i_op_a,
    input wire [31:0] i_op_b,
    input wire i_cmp_sig,
    
    output wire o_lt, o_eq, o_gt
);
    wire [32:0] op_a = {i_cmp_sig & i_op_a[31], i_op_a[31:0]};
    wire [32:0] op_b = {i_cmp_sig & i_op_b[31], i_op_b[31:0]};
    wire [32:0] add_op_b = (~op_b) + 32'b1;
    wire [32:0] add_result = op_a + add_op_b;

    assign o_lt = add_result[32];
    assign o_eq =~| add_result[32:0];
    assign o_gt = !o_lt && !o_eq;
endmodule
