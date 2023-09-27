module alu_tb ();
    logic [31:0] op_a, op_b, result;
    logic sub;
    logic [1:0] bool_op;
    logic [3:0] op_sel;
    logic shift_dir, cmp_sig;
    logic [2:0] cmp;

    alu dut (
        .i_op_a(op_a),
        .i_op_b(op_b),
        .i_sub(sub),
        .i_bool_op(bool_op),
        .i_op_sel(op_sel),
        .i_shift_dir(shift_dir),
        .i_cmp_sig(cmp_sig),
        .o_result(result),
        .o_lt(cmp[1]), .o_eq(cmp[2]), .o_gt(cmp[0])
    );

    task assert_add(input [31:0] a, input [31:0] b);
    begin
        logic [31:0] rslt;
        rslt = a + b;
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("add failed: %d < %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_sub(input [31:0] a, input [31:0] b);
    begin
        logic [31:0] rslt;
        rslt = a - b;
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("sub failed: %d < %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_xor(input [31:0] a, input [31:0] b);
    begin
        logic [31:0] rslt;
        rslt = a ^ b;
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("xor failed: %d ^ %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_or(input [31:0] a, input [31:0] b);
    begin
        logic [31:0] rslt;
        rslt = a | b;
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("or failed: %d | %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_and(input [31:0] a, input [31:0] b);
    begin
        logic [31:0] rslt;
        rslt = a & b;
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("and failed: %d & %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_ult(input [31:0] a, input [31:0] b, input [31:0] rslt);
    begin
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("ult failed: %d < %d, expected %d, got %d", op_a, op_b, rslt, result);
            $finish;
        end
    end
    endtask

    task assert_slt(input [31:0] a, input [31:0] b, input [31:0] rslt);
    begin
        op_a = a; op_b = b; #10;
        if (result !== rslt) begin
            $display("slt failed: %d < %d, expected %d, got %d", $signed(op_a), $signed(op_b), rslt, result);
            $finish;
        end
    end
    endtask

    initial begin
        // addition
        sub = 1'b0; op_sel = 3'b001; bool_op = 2'bxx; cmp_sig = 1'bx;
        assert_add(32'd5, 32'd6);
        assert_add(32'd0, 32'd0);
        assert_add(32'd1234, 32'd5678);
        assert_add(32'b10101010, 32'd01010101);

        // subtraction
        sub = 1'b1; op_sel = 3'b001;
        assert_sub(32'd5, 32'd6);
        assert_sub(32'd0, 32'd0);
        assert_sub(32'd1234, 32'd5678);
        assert_sub(32'b10101010, 32'd01010101);

        // xor
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b00;
        assert_xor(32'd5, 32'd6);
        assert_xor(32'd0, 32'd0);
        assert_xor(32'd1234, 32'd5678);
        assert_xor(32'b10101010, 32'd01010101);

        // or
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b10;
        assert_or(32'd5, 32'd6);
        assert_or(32'd0, 32'd0);
        assert_or(32'd1234, 32'd5678);
        assert_or(32'b10101010, 32'd01010101);

        // and
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b11;
        assert_and(32'd5, 32'd6);
        assert_and(32'd0, 32'd0);
        assert_and(32'd1234, 32'd5678);
        assert_and(32'b10101010, 32'd01010101);

        // lsl
        sub = 1'bx; op_sel = 4'b1000; shift_dir = 1'b0;
        op_a = 32'h0000FFFF; op_b = 6'd8; #10;
        if (result !== 32'h00FFFF00) begin
            $display("lsl failed: %d << %d, expected %d, got %d", op_a, op_b, op_a << op_b, result);
            $stop;
        end

        // lsr
        sub = 1'b0; op_sel = 4'b1000; shift_dir = 1'b1;
        op_a = 32'h0000FFFF; op_b = 6'd8; #10;
        if (result !== 32'h000000FF) begin
            $display("lsr failed: %d >> %d, expected %d, got %d", op_a, op_b, op_a >> op_b, result);
            $stop;
        end

        // asr
        sub = 1'b1; op_sel = 4'b1000; shift_dir = 1'b1;
        op_a = 32'hF000FFFF; op_b = 6'd8; #10;
        if (result !== 32'hFFF000FF) begin
            $display("asr failed: %d >>> %d, expected %d, got %d", op_a, op_b, op_a >>> op_b, result);
            $stop;
        end

        bool_op = 2'bxx; shift_dir = 1'bx;

        // ult
        sub = 1'b1; op_sel = 4'b0010; cmp_sig = 1'b0;
        assert_ult(32'd5, 32'd8, 32'b1);
        assert_ult(32'd8, 32'd5, 32'b0);
        assert_ult(32'd8, 32'd8, 32'b0);
        assert_ult(32'd8, 32'h80000000, 32'b1);

        // slt
        sub = 1'b1; op_sel = 4'b0010; cmp_sig = 1'b1;
        assert_slt(32'd5, 32'd8, 32'b1);
        assert_slt(32'd8, 32'd5, 32'b0);
        assert_slt(32'd5, -32'd8, 32'b0);
        assert_slt(-32'd8, 32'd5, 32'b1);
        assert_slt(32'd8, 32'd8, 32'b0);
        assert_slt(32'd8, 32'h80000000, 32'b0);

        $display("test passed");
        $finish;
    end
endmodule
