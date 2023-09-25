module shifter_left_tb ();
    logic [31:0] data_in, data_out;
    logic [5:0] amount;
    logic sign_extend;

    shifter dut (.i_data(data_in), .i_amount(amount), .i_sext(sign_extend), .o_data(data_out));

    initial begin
        data_in = 32'h0A0A0A0A;
        amount = 6'd4;
        sign_extend = 1'bx;
        #10;
        assert(data_out == 32'hA0A0A0A0);

        for (integer i = 0; i < 32; i = i + 1) begin
            integer value;
            value = 32'hAA55AA55;
            data_in = value;
            amount = i;
            sign_extend = 1'bx;
            #10;
            assert(data_out == (value << i));
        end
    end
endmodule

module shifter_right_tb ();
    logic [31:0] data_in, data_out;
    logic [5:0] amount;
    logic sign_extend;

    shifter dut (.i_data(data_in), .i_amount(amount), .i_sext(sign_extend), .o_data(data_out));
    //defparam dut.shift_dir = SHIFT_RIGHT;
    defparam dut.shift_dir = 1'b1;

    initial begin
        data_in = 32'h0A0A0A0A;
        amount = 6'd4;
        sign_extend = 1'b0;
        #10;
        assert(data_out == 32'h00A0A0A0);

        data_in = 32'hFA0A0A0A;
        amount = 6'd4;
        sign_extend = 1'b0;
        #10;
        assert(data_out == 32'h0FA0A0A0);

        for (integer i = 0; i < 32; i = i + 1) begin
            integer value;
            value = 32'hAA55AA55;
            data_in = value;
            amount = i;
            sign_extend = 1'b0;
            #10;
            assert(data_out == (value >> i));
        end

        data_in = 32'h0A0A0A0A;
        amount = 6'd4;
        sign_extend = 1'b1;
        #10;
        assert(data_out == 32'h00A0A0A0);

        data_in = 32'hFA0A0A0A;
        amount = 6'd4;
        sign_extend = 1'b1;
        #10;
        assert(data_out == 32'hFFA0A0A0);

        for (integer i = 0; i < 32; i = i + 1) begin
            integer signed value;
            integer unsigned cmp;

            value = 32'hAA55AA55;
            data_in = value;
            amount = i;
            sign_extend = 1'b1;
            #10;
            cmp = value >>> i;
            assert(data_out == cmp);
        end

        for (integer i = 0; i < 32; i = i + 1) begin
            integer signed value;
            integer unsigned cmp;

            value = 32'h0A55AA55;
            data_in = value;
            amount = i;
            sign_extend = 1'b1;
            #10;
            cmp = value >>> i;
            assert(data_out == cmp);
        end
    end
endmodule
