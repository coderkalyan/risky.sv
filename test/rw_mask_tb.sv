module rw_mask_tb ();
    logic [31:0] i_addr, o_addr;
    logic [1:0] size;
    logic [31:0] mask;

    rw_mask dut (.i_addr(i_addr), .i_size(size), .o_addr(o_addr), .o_mask(mask));

    initial begin
        // alignment 0
        i_addr = 32'h100;

        size = 2'h0;
        #1;
        assert_addr(32'h100);
        assert_mask(32'h000000ff);
        size = 2'h1;
        #1;
        assert_addr(32'h100);
        assert_mask(32'h0000ffff);
        size = 2'h2;
        #1;
        assert_addr(32'h100);
        assert_mask(32'hffffffff);

        // alignment 1
        i_addr = 32'h101;

        size = 2'h0;
        #1;
        assert_addr(32'h100);
        assert_mask(32'h0000ff00);

        // alignment 2
        i_addr = 32'h102;

        size = 2'h0;
        #1;
        assert_addr(32'h100);
        assert_mask(32'h00ff0000);
        size = 2'h1;
        #1;
        assert_addr(32'h100);
        assert_mask(32'hffff0000);

        // alignment 3
        i_addr = 32'h103;

        size = 2'h0;
        #1;
        assert_addr(32'h100);
        assert_mask(32'hff000000);

        $display("test passed");
        $finish;
    end

    task assert_addr(input [31:0] expected);
    begin
        if (o_addr !== expected) begin
            $display("output addr: expected 0x%x, got 0x%x", expected, o_addr);
            $finish;
        end
    end
    endtask

    task assert_mask(input [31:0] expected);
    begin
        if (mask !== expected) begin
            $display("mask: expected 0x%x, got 0x%x", expected, mask);
            $finish;
        end
    end
    endtask
endmodule
