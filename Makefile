register_file_test:
	iverilog -g2005-sv -c cmd/register_file.txt test/register_file_tb.sv -o build/register_file_tb
	./build/register_file_tb

decode_stage_test:
	iverilog -g2005-sv -c cmd/decode_stage.txt test/decode_stage_tb.sv -o build/decode_stage_tb
	./build/decode_stage_tb

alu_test:
	iverilog -g2005-sv -c cmd/alu.txt test/alu_tb.sv -o build/alu_tb
	./build/alu_tb
