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

        // addi r3, r18, 1234
        reg_set(18, 32'd12);
        inst = 32'h4d290193; #1;
        assert_eq(dut.alu.i_op_a, 32'd12);
        assert_eq(dut.alu.i_op_b, 32'd1234);
        assert_eq(dut.alu.add_result, 32'd1246);
        @(posedge clk);
        @(negedge clk);
        assert_reg(3, 32'd1246);

        // lw r1, 0(r0)
        mem_set(0, 32'hdeadbeef);
        inst = 32'h00002083; #1;
        assert_eq(dut.alu.i_op_a, 32'd0);
        assert_eq(dut.alu.i_op_b, 32'd0);
        assert_eq(dut.alu_result, 32'd0);
        assert_eq(dut.dmem.i_addr, 32'd0);
        assert_eq(dut.aligned_read, 32'hdeadbeef);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'hdeadbeef);

        // lb r1, 3(r0)
        inst = 32'h00300083; #1;
        assert_eq(dut.mem_addr, 32'd0);
        assert_eq(dut.mem_mask, 32'hff000000);
        assert_eq(dut.raw_read, 32'hdeadbeef);
        assert_eq(dut.masked_read, 32'hde000000);
        assert_eq(dut.aligned_read, 32'hffffffde);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'hffffffde);

        // lhu r1, 2(r2)
        reg_set(2, 32'd16);
        mem_set(16, 32'hcafeb0ba);
        inst = 32'h00215083; #1;
        assert_eq(dut.alu.i_op_a, 32'd16);
        assert_eq(dut.alu.i_op_b, 32'd2);
        assert_eq(dut.sub, 1'b0);
        assert_eq(dut.op_sel, 4'b0001);
        assert_eq(dut.alu_result, 32'd18);
        assert_eq(dut.mem_mask, 32'hffff0000);
        assert_eq(dut.raw_read, 32'hcafeb0ba);
        assert_eq(dut.masked_read, 32'hcafe0000);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'h0000cafe);

        // lh r1, 2(r2)
        reg_set(2, 32'd16);
        mem_set(16, 32'hcafeb0ba);
        inst = 32'h00211083; #1;
        assert_eq(dut.alu.i_op_a, 32'd16);
        assert_eq(dut.alu.i_op_b, 32'd2);
        assert_eq(dut.sub, 1'b0);
        assert_eq(dut.op_sel, 4'b0001);
        assert_eq(dut.alu_result, 32'd18);
        assert_eq(dut.mem_mask, 32'hffff0000);
        assert_eq(dut.raw_read, 32'hcafeb0ba);
        assert_eq(dut.masked_read, 32'hcafe0000);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'hffffcafe);

        // sw r1, 0(r2)
        reg_set(2, 32'd8);
        reg_set(1, 32'hcafeb0ba);
        mem_set(8, 32'hdeadbeef);
        inst = 32'h00112023; #1;
        assert_eq(dut.alu.i_op_a, 32'd8);
        assert_eq(dut.alu.i_op_b, 32'd0);
        assert_eq(dut.alu_result, 32'd8);
        assert_eq(dut.mem_mask, 32'hffffffff);
        assert_eq(dut.dmem.i_write_mask, 32'hffffffff);
        assert_eq(dut.dmem.i_addr, 32'd8);
        assert_eq(dut.dmem.i_write_data, 32'hcafeb0ba);
        assert_eq(dut.dmem.i_write_enable, 1'b1);
        assert_mem(8, 32'hdeadbeef);
        @(posedge clk);
        @(negedge clk);
        assert_mem(8, 32'hcafeb0ba);

        // sh r1, 2(r2)
        reg_set(2, 32'd8);
        reg_set(1, 32'h0000b0ba);
        inst = 32'h00111123; #1;
        assert_eq(dut.alu_result, 32'd10);
        assert_eq(dut.dmem.i_addr, 32'd8);
        assert_eq(dut.dmem.i_write_data, 32'hb0ba0000);
        assert_eq(dut.dmem.i_write_mask, 32'hffff0000);
        assert_eq(dut.dmem.i_write_enable, 1'b1);
        assert_mem(8, 32'hcafeb0ba);
        @(posedge clk);
        @(negedge clk);
        assert_mem(8, 32'hb0bab0ba);
        
        $display("test passed");
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

    task mem_set(input [10:0] index, input [31:0] value);
    begin
        dut.dmem.q[index] = value;
    end
    endtask

    task assert_mem(input [10:0] index, input [31:0] expected);
    begin
        if (dut.dmem.q[index] !== expected) begin
            $display("0x%x: expected 0x%x, got 0x%x", index, expected, dut.dmem.q[index]);
            $finish;
        end
    end
    endtask
endmodule
