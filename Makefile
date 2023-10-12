register_file_test:
	iverilog -g2005-sv -c cmd/register_file.txt test/register_file_tb.sv -o build/register_file_tb
	./build/register_file_tb

decode_stage_test:
	iverilog -g2005-sv -c cmd/decode_stage.txt test/decode_stage_tb.sv -o build/decode_stage_tb
	./build/decode_stage_tb

alu_test:
	iverilog -g2005-sv -c cmd/alu.txt test/alu_tb.sv -o build/alu_tb
	./build/alu_tb

rw_mask_test:
	iverilog -g2005-sv rtl/mem/rw_mask.sv test/rw_mask_tb.sv -o build/rw_mask_tb
	./build/rw_mask_tb

cpu_test:
	iverilog -g2005-sv rtl/types.sv -c cmd/cpu.txt test/cpu_tb.sv -o build/cpu_tb
	./build/cpu_tb

test: register_file_test decode_stage_test alu_test rw_mask_test cpu_test
