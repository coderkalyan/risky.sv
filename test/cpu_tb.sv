module cpu_tb ();
    logic clk;
    logic rst_n;
    logic [31:0] pc, inst;
    // logic [31:0] inst_raddr, inst_rdata;
    logic inst_re;
    logic [31:0] mem_addr, mem_wdata, mem_wmask, mem_rdata;
    logic mem_we;

    sim_pdmem dmem (
        .i_clk(clk),
        .i_addr(mem_addr),
        .i_write_data(mem_wdata),
        .i_write_mask(mem_wmask),
        .i_write_enable(mem_we),
        .o_read_data(mem_rdata)
    );
    cpu #(.RESET_VECTOR(32'h0)) dut (
        .i_clk(clk), .i_rst_n(rst_n),
        // .o_inst_raddr(inst_raddr), .o_inst_re(inst_re), .i_inst_rdata(inst_rdata),
        .o_inst_raddr(pc), .o_inst_re(inst_re), .i_inst_rdata(inst),
        .o_mem_addr(mem_addr),
        .o_mem_wdata(mem_wdata), .o_mem_wmask(mem_wmask), .o_mem_we(mem_we),
        .o_mem_rdata(mem_rdata)
    );

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        @(negedge clk);
        rst_n = 1'b1;
        assert_pc(32'h0);

        // add r1, r5, r24
        $display("add r1, r5, r24");
        reg_set(5, 32'd3);
        reg_set(24, 32'd5);
        inst = 32'h018280b3; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        assert_eq(dut.id_inst, 32'h018280b3);
        assert_eq(dut.id_pc, 32'h0);
        assert_eq(dut.rs1, 32'd5);
        assert_eq(dut.rs2, 32'd24);
        assert_eq(dut.rs1_data, 32'd3);
        assert_eq(dut.rs2_data, 32'd5);
        assert_pc(32'h4);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.ex_rs1_data, 32'd3);
        assert_eq(dut.ex_rs2_data, 32'd5);
        assert_eq(dut.alu_result, 32'd8);
        assert_pc(32'h8);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.mem_alu_result, 32'd8);
        assert_eq(dut.mem_wb_sel, 3'b001);
        assert_eq(dut.mem_wb_we, 1'b1);
        assert_pc(32'hc);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.wb_data, 32'd8);
        assert_eq(dut.wb_rd, 32'd1);
        assert_pc(32'h10);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'd8);
        assert_pc(32'h14);

        // sra r1, r2, r3
        $display("sra r1, r2, r3");
        reg_set(2, 32'hFFFFFF8A);
        reg_set(3, 32'd4);
        inst = 32'h403150b3;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h28);
        assert_reg(1, 32'hFFFFFFF8);

        // addi r3, r18, 1234
        $display("addi r3, r18, 1234");
        reg_set(18, 32'd12);
        inst = 32'h4d290193;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        assert_eq(dut.rs1_data, 32'd12);
        assert_eq(dut.imm, 32'd1234);
        assert_eq(dut.alu_op_sel, 4'b0001);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.op_a, 32'd12);
        assert_eq(dut.op_b, 32'd1234);
        assert_eq(dut.alu_result, 1246);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.mem_alu_result, 32'd1246);
        @(posedge clk);
        @(negedge clk);
        assert_eq(dut.wb_rd, 5'd3);
        assert_eq(dut.wb_data, 32'd1246);
        @(posedge clk);
        @(negedge clk);
        assert_pc(32'h3c);
        assert_reg(3, 32'd1246);

        // lw r1, 0(r0)
        $display("lw r1, 0(r0)");
        mem_set(0, 32'hdeadbeef);
        inst = 32'h00002083; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h50);
        assert_reg(1, 32'hdeadbeef);

        // lb r1, 3(r0)
        $display("lb r1, 3(r0)");
        inst = 32'h00300083; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h3e800093;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h64);
        assert_reg(1, 32'hffffffde);

        // lhu r1, 2(r2)
        $display("lhu r1, 2(r2)");
        reg_set(2, 32'd16);
        mem_set(16, 32'hcafeb0ba);
        inst = 32'h00215083; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h78);
        assert_reg(1, 32'h0000cafe);

        // lh r1, 2(r2)
        $display("lh r1, 2(r2)");
        reg_set(2, 32'd16);
        mem_set(16, 32'hcafeb0ba);
        inst = 32'h00211083; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h8c);
        assert_reg(1, 32'hffffcafe);

        // sw r1, 0(r2)
        $display("sw r1, 0(r2)");
        reg_set(2, 32'd8);
        reg_set(1, 32'hcafeb0ba);
        assert_reg(1, 32'hcafeb0ba);
        mem_set(8, 32'hdeadbeef);
        inst = 32'h00112023; #1;
        assert_mem(8, 32'hdeadbeef);
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'hcafeb0ba);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'ha0);
        assert_mem(8, 32'hcafeb0ba);

        // sh r1, 2(r2)
        $display("sh r1, 2(r2)");
        reg_set(2, 32'd8);
        reg_set(1, 32'h0000b0ba);
        inst = 32'h00111123; #1;
        assert_mem(8, 32'hcafeb0ba);
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'hb4);
        assert_mem(8, 32'hb0bab0ba);

        // beq r1, r0, 0
        $display("beq r1, r0, 0");
        reg_set(1, 32'h0);
        inst = 32'h00008063; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (2) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h04);
        repeat (2) begin
            @(posedge clk);
            @(negedge clk);
        end

        // beq r1, r0, 0
        $display("beq r1, r0, 0");
        reg_set(1, 32'hcafe);
        inst = 32'h00008063; #1;
        @(posedge clk);
        @(negedge clk);
        inst = 32'h00000013; #1;
        repeat (4) begin
            @(posedge clk);
            @(negedge clk);
        end
        assert_pc(32'h28);

        // jal r1, 16
        $display("jal r1, 16");
        reg_set(1, 32'hcafe);
        inst = 32'h010000ef; #1;
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'h2c);
        assert_pc(32'h38);

        // jalr r1, r2, 4
        $display("jalr r1, r2, 4");
        reg_set(1, 32'hcafe);
        reg_set(2, 32'h4c);
        inst = 32'h004100e7; #1;
        @(posedge clk);
        @(negedge clk);
        assert_reg(1, 32'h3c);
        assert_pc(32'h50);

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
        dut.rf.q[index - 1] = value;
    end
    endtask

    task assert_reg(input [4:0] index, input [31:0] expected);
    begin
        if (dut.rf.q[index - 1] !== expected) begin
            $display("r%d: expected %d, got %d\n", index, expected, dut.rf.q[index - 1]);
            $finish;
        end
    end
    endtask

    task mem_set(input [10:0] index, input [31:0] value);
    begin
        dmem.q[index] = value;
    end
    endtask

    task assert_mem(input [10:0] index, input [31:0] expected);
    begin
        if (dmem.q[index] !== expected) begin
            $display("0x%x: expected 0x%x, got 0x%x", index, expected, dmem.q[index]);
            $finish;
        end
    end
    endtask
endmodule
