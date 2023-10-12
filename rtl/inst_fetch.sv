module inst_fetch #(
    parameter RESET_VECTOR = 32'h80000000
) (
    input wire i_clk,
    input wire i_rst_n,

    input wire i_stall,
    input wire i_jump,
    input wire [31:0] i_jdest,
    output wire [31:0] o_raddr,
    output wire o_re,
    input wire [31:0] i_rdata,

    output logic [31:0] o_pc,
    output logic [31:0] o_inst
);
    logic [31:0] pc, next_pc;

    // advance, jump, or stall
    always_comb begin
        priority casez ({i_stall, i_jump})
            2'b00: next_pc = pc + 4;
            2'b01: next_pc = i_jdest;
            2'b1?: next_pc = pc;
        endcase
    end

    always_ff @(posedge i_clk, negedge i_rst_n) begin
        if (!i_rst_n)
            pc <= RESET_VECTOR;
        else
            pc <= next_pc;
    end

    assign o_raddr = pc;
    assign o_re = !i_stall;
    assign o_inst = i_rdata;
    assign o_pc = pc;
endmodule
