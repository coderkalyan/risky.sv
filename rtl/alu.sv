module alu (
    input wire [31:0] i_op_a, i_op_b,
    input wire i_sub,
    input wire [1:0] i_bool_op,
    input wire [2:0] i_op_sel,

    output wire [31:0] o_result
);
    wire [31:0] add_op_b = i_sub ? ((~i_op_b) + 32'b1) : i_op_b;
    wire [31:0] add_result = i_op_a + add_op_b;

    /*
    * 00 a xor b
    * 01 0
    * 10 a or b
    * 11 a and b
    */
    wire [31:0] bool_result = ((i_op_a ^ i_op_b) & {32{~i_bool_op[0]}}) | (i_op_a & i_op_b & {32{i_bool_op[1]}});

    assign o_result =   ({32{i_op_sel[0]}} & add_result) |
                        ({32{i_op_sel[2]}} & bool_result);
endmodule
