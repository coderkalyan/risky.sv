module rw_mask (
    input wire [31:0] i_addr,
    input wire [1:0] i_size,
    output wire [31:0] o_addr,
    output wire [31:0] o_mask
);
    assign o_addr = i_addr & ~32'h3;
    wire [31:0] size_mask = (i_size === 2'h0) ? 32'h000000ff :
                            (i_size === 2'h1) ? 32'h0000ffff :
                            (i_size === 2'h2) ? 32'hffffffff : 32'hx;
    wire [4:0] byte_index = i_addr & 32'h3;
    assign o_mask = size_mask << (byte_index << 3);
endmodule
