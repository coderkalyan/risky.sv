module register_file (
    input wire clk,
    input wire [4:0] i_write_index,
    input wire [31:0] i_write_data,
    input wire i_write_enable,

    input wire [4:0] i_read_index1,
    output wire [31:0] o_read_data1,

    input wire [4:0] i_read_index2,
    output wire [31:0] o_read_data2
);
    logic [31:0] q [30:0]; // 31x 32-bit registers (0 register doesn't need to exist)
    
    always @(posedge clk) begin
        if (i_write_enable && (i_write_index !== 5'b0)) begin
            q[i_write_index - 1] <= i_write_data;
        end
    end

    assign o_read_data1 = (i_read_index1 !== 5'd0) ? q[i_read_index1 - 1] : 32'b0;
    assign o_read_data2 = (i_read_index2 !== 5'b0) ? q[i_read_index2 - 1] : 32'b0;
endmodule
