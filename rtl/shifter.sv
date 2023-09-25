module shifter #(
    parameter shift_dir = 1'b0
) (
    input wire [31:0] i_data,
    input wire [5:0] i_amount,
    input wire i_sext,
    
    output wire [31:0] o_data
);
    wire [31:0] mux_inputs [5:0][1:0];
    wire [31:0] mux_outputs [6:0];
    assign mux_outputs[0] = (i_amount > 32) ? 0 : i_data;

    generate
    genvar i;
    for (i = 0; i <= 5; i = i + 1) begin
        integer place = 5 - i;
        integer shift_amount = 1 << place;

        assign mux_inputs[i][0] = mux_outputs[i];
        if (shift_dir == 1'b0) begin
            assign mux_inputs[i][1] = mux_outputs[i] << shift_amount;
        end
        else begin
            wire signed [31:0] signed_output = mux_outputs[i];
            wire [31:0] srl = mux_outputs[i] >> shift_amount;
            wire [31:0] sra = signed_output >>> shift_amount;
            assign mux_inputs[i][1] = i_sext ? sra : srl;
        end

        assign mux_outputs[i + 1] = i_amount[place] ? mux_inputs[i][1] : mux_inputs[i][0];
    end
    endgenerate

    assign o_data = mux_outputs[6];
endmodule
