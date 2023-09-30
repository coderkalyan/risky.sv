`ifndef _defs_vh_
`define _defs_vh_

`define OPCODE_ARITH 7'b0110011
`define OPCODE_ARIMM 7'b0010011
`define OPCODE_LOAD  7'b0000011
`define OPCODE_STORE 7'b0100011
`define OPCODE_BRANCH 7'b1100011
`define OPCODE_JAL 7'b1101111
`define OPCODE_JALR 7'b1100111
`define OPCODE_AUIPC 7'b0010111
`define OPCODE_LUI 7'b0110111
`define OPCODE_ENV 7'b1110011

`define FUNC_ADD 3'b000
`define FUNC_AND 3'b111
`define FUNC_OR 3'b110
`define FUNC_XOR 3'b100
`define FUNC_SL 3'b001
`define FUNC_SR 3'b101
`define FUNC_SLT 3'b010
`define FUNC_SLTU 3'b011

`endif
