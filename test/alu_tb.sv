module alu_tb ();
    logic [31:0] op_a, op_b, result;
    logic sub;
    logic [1:0] bool_op;
    logic [2:0] op_sel;

    alu dut (.i_op_a(op_a), .i_op_b(op_b), .i_sub(sub), .i_bool_op(bool_op), .i_op_sel(op_sel), .o_result(result));

    initial begin
        // addition
        sub = 1'b0; op_sel = 3'b001; bool_op = 2'bxx;

        op_a = 32'd5; op_b = 32'd6; #10;
        if (result !== (op_a + op_b))
            $error("addition failed: %d + %d, expected %d, got %d", op_a, op_b, op_a + op_b, result);

        op_a = 32'd0; op_b = 32'd0; #10;
        if (result !== (op_a + op_b))
            $error("addition failed: %d + %d, expected %d, got %d", op_a, op_b, op_a + op_b, result);

        op_a = 32'd1234; op_b = 32'd5678; #10;
        if (result !== (op_a + op_b))
            $error("addition failed: %d + %d, expected %d, got %d", op_a, op_b, op_a + op_b, result);

        op_a = 32'b10101010; op_b = 32'b01010101; #10;
        if (result !== (op_a + op_b))
            $error("addition failed: %d + %d, expected %d, got %d", op_a, op_b, op_a + op_b, result);

        // subtraction
        sub = 1'b1; op_sel = 3'b001;

        op_a = 32'd5; op_b = 32'd6; #10;
        if (result !== (op_a - op_b))
            $error("subtraction failed: %d - %d, expected %d, got %d", op_a, op_b, op_a - op_b, result);

        op_a = 32'd0; op_b = 32'd0; #10;
        if (result !== (op_a - op_b))
            $error("subtraction failed: %d - %d, expected %d, got %d", op_a, op_b, op_a - op_b, result);

        op_a = 32'd1234; op_b = 32'd5678; #10;
        if (result !== (op_a - op_b))
            $error("subtraction failed: %d - %d, expected %d, got %d", op_a, op_b, op_a - op_b, result);

        op_a = 32'b10101010; op_b = 32'b01010101; #10;
        if (result !== (op_a - op_b))
            $error("subtraction failed: %d - %d, expected %d, got %d", op_a, op_b, op_a - op_b, result);

        // xor
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b00;

        op_a = 32'd5; op_b = 32'd6; #10;
        if (result !== (op_a ^ op_b))
            $error("xor failed: %d ^ %d, expected %d, got %d", op_a, op_b, op_a ^ op_b, result);

        op_a = 32'd0; op_b = 32'd0; #10;
        if (result !== (op_a ^ op_b))
            $error("xor failed: %d ^ %d, expected %d, got %d", op_a, op_b, op_a ^ op_b, result);

        op_a = 32'd1234; op_b = 32'd5678; #10;
        if (result !== (op_a ^ op_b))
            $error("xor failed: %d ^ %d, expected %d, got %d", op_a, op_b, op_a ^ op_b, result);

        op_a = 32'b10101010; op_b = 32'b01010101; #10;
        if (result !== (op_a ^ op_b))
            $error("xor failed: %d ^ %d, expected %d, got %d", op_a, op_b, op_a ^ op_b, result);

        // or
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b10;

        op_a = 32'd5; op_b = 32'd6; #10;
        if (result !== (op_a | op_b))
            $error("or failed: %d | %d, expected %d, got %d", op_a, op_b, op_a | op_b, result);

        op_a = 32'd0; op_b = 32'd0; #10;
        if (result !== (op_a | op_b))
            $error("or failed: %d | %d, expected %d, got %d", op_a, op_b, op_a | op_b, result);

        op_a = 32'd1234; op_b = 32'd5678; #10;
        if (result !== (op_a | op_b))
            $error("or failed: %d | %d, expected %d, got %d", op_a, op_b, op_a | op_b, result);

        op_a = 32'b10101010; op_b = 32'b01010101; #10;
        if (result !== (op_a | op_b))
            $error("or failed: %d | %d, expected %d, got %d", op_a, op_b, op_a | op_b, result);

        // and
        sub = 1'bx; op_sel = 3'b100; bool_op = 2'b11;

        op_a = 32'd5; op_b = 32'd6; #10;
        if (result !== (op_a & op_b))
            $error("and failed: %d & %d, expected %d, got %d", op_a, op_b, op_a & op_b, result);

        op_a = 32'd0; op_b = 32'd0; #10;
        if (result !== (op_a & op_b))
            $error("and failed: %d & %d, expected %d, got %d", op_a, op_b, op_a & op_b, result);

        op_a = 32'd1234; op_b = 32'd5678; #10;
        if (result !== (op_a & op_b))
            $error("and failed: %d & %d, expected %d, got %d", op_a, op_b, op_a & op_b, result);

        op_a = 32'b10101010; op_b = 32'b01010101; #10;
        if (result !== (op_a & op_b))
            $error("and failed: %d & %d, expected %d, got %d", op_a, op_b, op_a & op_b, result);

        $finish;
    end
endmodule
