`include "opcodes.v"

module MicroCode(
   input alu_bcond,
   input [31:0] x17,
   input [3:0] curr_state,
   output pc_write_not_cond, //output
   output pc_write,     //output
   output i_or_d, //output
   output mem_read, //output
   output mem_write, //output
   output mem_to_reg, //output
   output ir_write, //output
   output pc_source, //output
   output alu_src_a, //output
   output [1:0] alu_src_b, //output
   output reg_write, //output
   output ALUOp, //output
   output halt, //output
   output [1:0] addr_ctrl
   );
    
//signal 
   assign pc_write_not_cond = (curr_state == 9 && alu_bcond == 0) ? 1 : 0;
   assign pc_write = (curr_state == 11 || curr_state == 12 || curr_state == 10 || curr_state == 8 || curr_state == 7 || curr_state == 4 || curr_state == 13) ? 1 : 0;
   assign i_or_d = (curr_state == 6 || curr_state == 8) ? 1 : 0;
   assign mem_read = (curr_state == 1 || curr_state == 6) ? 1 : 0;
   assign mem_write = (curr_state == 8) ? 1 : 0;
   assign mem_to_reg  = (curr_state == 7) ? 1 : 0;
   assign ir_write = (curr_state == 1) ? 1 : 0;
   assign pc_source = (curr_state == 9) ? 1 : 0;
   assign alu_src_a = (curr_state == 3 || curr_state == 5 || curr_state == 9 || curr_state == 12) ? 1 : 0; //1: 3,4,5,7 
   assign alu_src_b = (curr_state == 3 || curr_state == 9) ? 2'b00 : ((curr_state == 2 || curr_state == 8 || curr_state == 7 ||  curr_state == 4 || curr_state == 13) ? 2'b01 : ((curr_state == 5 || curr_state == 11 || curr_state == 12 || curr_state == 10) ? 2'b10 : 2'b11));//0: 3,5   1: 2,10,11,12    2: 4,6,7,8
   assign reg_write = (curr_state ==4 || curr_state == 7 || curr_state == 11 || curr_state == 12) ? 1 : 0; //12,11,6,7
   assign ALUOp = (curr_state == 2 || curr_state == 11 || curr_state == 12 || curr_state == 10 || curr_state == 8 || curr_state == 7 || curr_state == 4) ? 1 : 0;// 1 : always add (pc+4, pc+imm) 0: depends on opcode  //1,12,11,10,6,7,8
   assign halt = (curr_state == 13 && x17 == 10) ? 1 : 0; //output

//addr ctrl logic
   assign addr_ctrl = (curr_state == 0 || curr_state == 1 || curr_state == 3 || curr_state == 6 || (curr_state == 9 && alu_bcond)) ? 2'b00 :
      (curr_state == 2 ? 2'b01 :
      (curr_state == 4 || curr_state == 7 || curr_state == 8 || (curr_state == 9 && !alu_bcond) || curr_state == 10 || curr_state == 11 || curr_state == 12 || curr_state == 13 ? 2'b11 :
      2'b10));

//0: 0,1,3,6,9(if bcond)   1:2    2:5   3:4,7,8,9(if!bcond),10,11,12,13


endmodule


/*
0-Idle
1-IF
2-ID   RF -> A,B PC+4 -> ALUOUT
3-EX_R  A(+)B -> ALUOUT
4-EX_I   A(+)IMM = ALUOUT
5-EX_B  bcond?        if! ALUOT -> PC
6-EX_JAL  ALUOUT -> RF    PC = PC+IMM
7-EX_JALR  ALUOUT -> RF   PC = A+IMM
8-WB_B PC = PC+IMM
9-MEM_L Load to MDR
10-MEM_S  Store  PC+4
11-WB_L MDR->RF PC+4
12-WB_R ALUOT->RF PC+4
13-ECALL
*/
