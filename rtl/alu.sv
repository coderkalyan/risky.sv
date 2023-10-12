import types::alu_op_t;

module alu (
    input wire [31:0] i_op_a, i_op_b,
    input wire i_sub,
    input wire [1:0] i_bool_op,
    input wire [3:0] i_op_sel,
    input wire i_shift_dir,
    input wire i_cmp_sig,

    // output wire [31:0] o_result
    output logic [31:0] o_result
);
    // typedef enum {ALU_OP_ADD, ALU_OP_LT, ALU_OP_BOOL, ALU_OP_SHIFT} alu_op_t;

    // sign-extend to 33 bits, allows consolidating the comparison operations
    // i.e. slt a < b -> a - b < 0
    wire [32:0] op_a = {i_cmp_sig & i_op_a[31], i_op_a[31:0]};
    wire [32:0] op_b = {i_cmp_sig & i_op_b[31], i_op_b[31:0]};
    wire [32:0] add_op_b = i_sub ? ((~op_b) + 32'b1) : op_b;
    wire [32:0] add_result = op_a + add_op_b;

    wire lt = add_result[32];

    wire [5:0] shift_amount = i_op_b[5:0];
    wire [31:0] left_shift_result, right_shift_result;
    wire [31:0] shift_result = i_shift_dir ? right_shift_result : left_shift_result;

    shifter #(.shift_dir(1'b0)) left_shifter (.i_data(i_op_a), .i_amount(shift_amount), .i_sext(1'b0), .o_data(left_shift_result));
    shifter #(.shift_dir(1'b1)) right_shifter (.i_data(i_op_a), .i_amount(shift_amount), .i_sext(i_sub), .o_data(right_shift_result));

    /*
    * 00 a xor b
    * 01 0
    * 10 a or b
    * 11 a and b
    */
    wire [31:0] bool_result = ((i_op_a ^ i_op_b) & {32{~i_bool_op[0]}}) | (i_op_a & i_op_b & {32{i_bool_op[1]}});

    always_comb begin
        case (i_op_sel)
            (1 << ALU_OP_ADD): o_result = add_result[31:0];
            (1 << ALU_OP_LT): o_result = {31'b0, lt};
            (1 << ALU_OP_BOOL): o_result = bool_result;
            (1 << ALU_OP_SHIFT): o_result = shift_result;
        endcase
    end
    // assign o_result = ({32{i_op_sel[0]}} & add_result[31:0]) |
    //                   ({31'b0, i_op_sel[1] & lt}) |
    //                   ({32{i_op_sel[2]}} & bool_result) |
    //                   ({32{i_op_sel[3]}} & shift_result);
endmodule
