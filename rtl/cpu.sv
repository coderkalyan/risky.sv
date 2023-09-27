module cpu (
    input wire i_clk,
);
    decode_stage decoder (
        .i_clk(i_clk),
        .i_inst(inst),
    );
endmodule
