module decode_stage_tb ();
    logic clk;
    logic [31:0] inst, write_data;
    logic write_enable;
    logic [31:0] read1, read2, imm;

    decode_stage dut (
        .i_clk(clk), .i_inst(inst), .i_write_data(write_data), .i_write_enable(write_enable),
        .o_read1(read1), .o_read2(read2), .o_imm(imm)
    );

    // test one instruction from each of the 6 formats, since we don't care
    // about any of the execute stage (just that the chunks are decoded in the
    // right position)
    initial begin
        clk = 1'b0;
        // we're not writing, this is actually part of the write-back stage
        // instead, we'll pre-populate the register file before each test
        write_data = 32'h0;
        write_enable = 1'b0;
        @(posedge clk);

        // add r1, r5, r24
        @(negedge clk);
        inst = 32'h018280b3;
        dut.file.q[4] = 32'd5;
        dut.file.q[23] = 32'd62;
        @(posedge clk);
        if (dut.rs1 !== 5'd5) begin
            $display("rs1: expected %d, got %d", 5'd5, dut.rs1);
            $stop;
        end
        if (dut.rs2 !== 5'd24) begin
            $display("rs2: expected %d, got %d", 5'd24, dut.rs2);
            $stop;
        end
        if (dut.rd !== 5'd1) begin
            $display("rd: expected %d, got %d", 5'd1, dut.rd);
            $stop;
        end
        if (read1 !== 32'd5) begin
            $display("r5: expected 0x%x, got 0x%x", 32'd5, read1);
            $stop;
        end
        if (read2 !== 32'd62) begin
            $display("r24: expected 0x%x, got 0x%x", 32'd62, read2);
            $stop;
        end

        // addi r3, r18, 1234
        @(negedge clk);
        inst = 32'h4d290193;
        dut.file.q[17] = 32'd12;
        @(posedge clk);
        if (dut.rs1 !== 5'd18) begin
            $display("rs1: expected %d, got %d", 5'd18, dut.rs1);
            $stop;
        end
        if (dut.rd !== 5'd3) begin
            $display("rd: expected %d, got %d", 5'd3, dut.rd);
            $stop;
        end
        if (read1 !== 32'd12) begin
            $display("r18: expected 0x%x, got 0x%x", 32'd12, read1);
            $stop;
        end
        if (imm !== 32'd1234) begin
            $display("imm: expected 0x%x, got 0x%x", 32'd1234, imm);
            $stop;
        end

        // sw r4, 16(r2)
        @(negedge clk);
        inst = 32'h00412823;
        dut.file.q[1] = 32'd8;
        dut.file.q[3] = 32'h80808080;
        @(posedge clk);
        if (dut.rs1 !== 5'd2) begin
            $display("rs1: expected %d, got %d", 5'd2, dut.rs1);
            $stop;
        end
        if (dut.rs2 !== 5'd4) begin
            $display("rs2: expected %d, got %d", 5'd4, dut.rs2);
            $stop;
        end
        if (read1 !== 32'd8) begin
            $display("r2: expected 0x%x, got 0x%x", 32'd12, read1);
            $stop;
        end
        if (read2 !== 32'h80808080) begin
            $display("r4: expected 0x%x, got 0x%x", 32'h80808080, read2);
            $stop;
        end
        if (imm !== 32'd16) begin
            $display("imm: expected 0x%x, got 0x%x", 32'd16, imm);
            $stop;
        end

        // beq r0, r1, -16
        @(negedge clk);
        inst = 32'hfe1008e3;
        dut.file.q[0] = 32'd0;
        @(posedge clk);
        if (dut.rs1 !== 5'd0) begin
            $display("rs1: expected %d, got %d", 5'd0, dut.rs1);
            $stop;
        end
        if (dut.rs2 !== 5'd1) begin
            $display("rs2: expected %d, got %d", 5'd1, dut.rs2);
            $stop;
        end
        if (read1 !== 32'd0) begin
            $display("r0: expected 0x%x, got 0x%x", 32'd0, read1);
            $stop;
        end
        if (read2 !== 32'd0) begin
            $display("r1: expected 0x%x, got 0x%x", 32'd0, read2);
            $stop;
        end
        if (imm !== -32'd16) begin
            $display("imm: expected 0x%x, got 0x%x", -32'd16, imm);
            $stop;
        end

        // lui r1, 0xa0a0a0a0a
        @(negedge clk);
        inst = 32'ha0a0a0b7;
        @(posedge clk);
        if (dut.rd !== 5'd1) begin
            $display("rd: expected %d, got %d", 5'd1, dut.rd);
            $stop;
        end
        if (imm !== 32'ha0a0a000) begin
            $display("imm: expected 0x%x, got 0x%x", 32'ha0a0a000, imm);
            $stop;
        end

        // jal r1, 0x0bbb0
        @(negedge clk);
        inst = 32'h3b10b0ef;
        @(posedge clk);
        if (dut.rd !== 5'd1) begin
            $display("rd: expected %d, got %d", 5'd1, dut.rd);
            $stop;
        end
        if (imm !== 32'h0bbb0) begin
            $display("imm: expected 0x%x, got 0x%x", 32'h0bbb0, imm);
            $stop;
        end

        $display("test passed");
        $finish;
    end

    always
        #5 clk = ~clk;
endmodule

task assert_eq;
endtask
