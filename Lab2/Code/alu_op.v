// macro for alu_op 

`define OP_ADD  4'b0000 // 0
`define OP_SUB  4'b0001 // 1
`define OP_SLL  4'b0010 // 2
`define OP_XOR  4'b0011 // 3
`define OP_OR   4'b0100 // 4
`define OP_AND  4'b0101 // 5
`define OP_SRL  4'b0110 // 6
`define OP_BEQ  4'b0111 // 7
`define OP_BNE  4'b1000 // 8
`define OP_BLT  4'b1001 // 9
`define OP_BGE  4'b1010 // 10