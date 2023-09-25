module alu (
    input wire [31:0] i_op_a, i_op_b,
    input wire i_sub,
    input wire [1:0] i_bool_op,
    input wire [3:0] i_op_sel,
    input wire i_shift_dir,

    output wire [31:0] o_result
);
    wire [31:0] add_op_b = i_sub ? ((~i_op_b) + 32'b1) : i_op_b;
    wire [31:0] add_result = i_op_a + add_op_b;

    wire [5:0] shift_amount = i_op_b[5:0];
    wire [31:0] left_shift_result, right_shift_result;
    wire [31:0] shift_result = i_shift_dir ? right_shift_result : left_shift_result;

    shifter left_shifter (.i_data(i_op_a), .i_amount(shift_amount), .i_sext(), .o_data(left_shift_result));
    shifter right_shifter (.i_data(i_op_a), .i_amount(shift_amount), .i_sext(i_sub), .o_data(right_shift_result));
    defparam right_shifter.shift_dir = 1'b1;

    /*
    * 00 a xor b
    * 01 0
    * 10 a or b
    * 11 a and b
    */
    wire [31:0] bool_result = ((i_op_a ^ i_op_b) & {32{~i_bool_op[0]}}) | (i_op_a & i_op_b & {32{i_bool_op[1]}});

    assign o_result =   ({32{i_op_sel[0]}} & add_result) |
                        ({32{i_op_sel[2]}} & bool_result) |
                        ({32{i_op_sel[3]}} & shift_result);
endmodule
