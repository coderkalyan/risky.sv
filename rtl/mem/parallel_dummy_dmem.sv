// dummy implementation of a parallel-access dmem
module sim_pdmem (
    input wire i_clk,
    input wire [31:0] i_addr,
    input wire [31:0] i_write_data,
    input wire [31:0] i_write_mask,
    input wire i_write_enable,
    output wire [31:0] o_read_data
);
    // 2K words of memory
    logic [31:0] q [2047:0];
    // logic [31:0] q [0:0];
    always @(posedge i_clk) begin
        if (i_write_enable) begin
            q[i_addr] <= (i_write_data & i_write_mask) | (q[i_addr] & ~i_write_mask);
        end
    end

    assign o_read_data = q[i_addr];
endmodule
