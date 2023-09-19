module shifter (
    input wire [31:0] i_data,
    input wire [31:0] i_amount,
    
    output wire [31:0] o_data,
);
    wire [1:0] mux_inputs [5:0];
    wire mux_outputs [6:0];
    assign mux_outputs[0] = (i_amount > 32) ? 0 : i_data;

    generate
    for (i = 0; i <= 6; i = i + 1) begin

    end
    endgenerate
endmodule
