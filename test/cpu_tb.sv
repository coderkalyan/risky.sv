module cpu_tb ();
    logic clk;
    logic rst_n;
    logic [31:0] pc, inst;

    cpu dut (.i_clk(clk), .i_rst_n(rst_n), .o_pc(pc), .i_inst(inst));

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        @(negedge clk);
        rst_n = 1'b1;
        assert_pc(32'h0);

        // add r1, r5, r24
        reg_set(5, 32'd3);
        reg_set(24, 32'd5);
        inst = 32'h018280b3; #1;
        assert_eq(dut.rs1, 32'd3);
        assert_eq(dut.rs2, 32'd5);
        assert_eq(dut.alu_result, 32'd8);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'd8);

        // sra r1, r2, r3
        reg_set(2, 32'hFFFFFF8A);
        reg_set(3, 32'd4);
        inst = 32'h403150b3;
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'hFFFFFFF8);

        $finish;
    end

    always
        #5 clk = ~clk;

    task assert_pc(input [31:0] expected);
    begin
        if (pc !== expected) begin
            $display("program counter: expected 0x%x, got 0x%x", expected, pc);
            $finish;
        end
    end
    endtask

    task assert_eq(input [31:0] value, input [31:0] expected);
    begin
        if (value !== expected) begin
            $display("expected 0x%x, got 0x%x", expected, value);
            $finish;
        end
    end
    endtask

    task reg_set(input [4:0] index, input [31:0] value);
    begin
        dut.decoder.file.q[index - 1] = value;
    end
    endtask

    task assert_reg(input [4:0] index, input [31:0] expected);
    begin
        if (dut.decoder.file.q[index - 1] !== expected) begin
            $display("r%d: expected %d, got %d\n", index, expected, dut.decoder.file.q[index - 1]);
            $finish;
        end
    end
    endtask
endmodule
