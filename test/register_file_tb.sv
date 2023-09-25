module register_file_tb ();
    logic clk;
    logic [31:0] write_data, read_data1, read_data2;
    logic [4:0] write_index, read_index1, read_index2;
    logic write_enable;

    register_file dut (
        .clk(clk),
        .i_write_data(write_data), .i_write_index(write_index), .i_write_enable(write_enable),
        .i_read_index1(read_index1), .o_read_data1(read_data1),
        .i_read_index2(read_index2), .o_read_data2(read_data2));

    initial begin
        $dumpfile("register_file_tb.vcd");
        clk = 0;

        // check that values are saved correctly
        write_index = 5'd1;
        write_data = 32'hDEADBEEF;
        write_enable = 1'b1;
        @ (negedge clk);
        write_index = 5'd31;
        write_data = 32'hDECAFBAD;
        @ (negedge clk);
        write_enable = 1'b0;
        read_index1 = 5'd1;
        read_index2 = 5'd31;
        @ (negedge clk);
        if (read_data1 !== 32'hDEADBEEF) begin
            $display("[save values] r1: expected 0xDEADBEEF, got 0x%x", dut.q[1]);
            $finish;
        end
        if (read_data2 !== 32'hDECAFBAD) begin
            $display("[save values] r31: expected 0xDECAFBAD, got 0x%x", read_data2);
            $finish;
        end

        // check that r0 isn't saved
        write_enable = 1'b0;
        @ (negedge clk);
        read_index1 = 5'd0;
        read_index2 = 5'd0;
        @ (negedge clk);
        if (read_data1 !== 32'h0) begin
            $display("[save values] r0: expected 0x0, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'h0) begin
            $display("[save values] r0: expected 0x0, got 0x%x", read_data2);
            $finish;
        end
        write_enable = 1'b1;
        write_index = 5'd0;
        write_data = 32'h0xBEEF;
        @ (negedge clk);
        if (read_data1 !== 32'h0) begin
            $display("[save values] r0: expected 0x0, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'h0) begin
            $display("[save values] r0: expected 0x0, got 0x%x", read_data2);
            $finish;
        end

        // check if data is held when we = 0
        write_index = 5'd1;
        write_data = 32'h0;
        write_enable = 1'b1;
        @ (negedge clk);
        read_index1 = 5'd1;
        read_index2 = 5'd1;
        @ (negedge clk);
        if (read_data1 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data2);
            $finish;
        end
        write_enable = 1'b0;
        write_data = 32'hBEEF;
        @ (negedge clk);
        if (read_data1 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data2);
            $finish;
        end
        write_enable = 1'b1;
        @ (negedge clk);
        if (read_data1 !== 32'hbeef) begin
            $display("[save values] r1: expected 0xbeef, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'hbeef) begin
            $display("[save values] r1: expected 0xbeef, got 0x%x", read_data2);
            $finish;
        end
        write_enable = 1'b0;
        write_data = 32'hdead;
        @ (negedge clk);
        if (read_data1 !== 32'hbeef) begin
            $display("[save values] r1: expected 0xbeef, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'hbeef) begin
            $display("[save values] r1: expected 0xbeef, got 0x%x", read_data2);
            $finish;
        end
        write_enable = 1'b1;
        @ (negedge clk);
        if (read_data1 !== 32'hdead) begin
            $display("[save values] r1: expected 0xdead, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'hdead) begin
            $display("[save values] r1: expected 0xdead, got 0x%x", read_data2);
            $finish;
        end

        // check that write data is propogated
        // after 1 clock cycle
        write_enable = 1'b1;
        write_data = 32'h0;
        write_index = 5'd1;
        @ (negedge clk);
        write_index = 5'd2;
        @ (negedge clk);
        write_enable = 1'b0;
        read_index1 = 5'd1;
        read_index2 = 5'd2;
        @ (negedge clk);
        if (read_data1 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data1);
            $finish;
        end
        if (read_data2 !== 32'h0) begin
            $display("[save values] r1: expected 0x0, got 0x%x", read_data2);
            $finish;
        end
        write_index = 5'd1;
        write_data = 32'hbeef;
        write_enable = 1'b1;
        @ (negedge clk);
        if (read_data1 !== 32'hbeef) begin
            $display("[save values] r1: expected 0xbeef, got 0x%x", read_data1);
            $finish;
        end
        write_index = 5'd2;
        @ (negedge clk);
        if (read_data2 !== 32'hbeef) begin
            $display("[save values] r2: expected 0xbeef, got 0x%x", read_data1);
            $finish;
        end

        $display("test passed");
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
endmodule
