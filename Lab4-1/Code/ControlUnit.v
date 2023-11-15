`include "opcodes.v"

module ControlUnit(input [6:0] part_of_inst,
    output mem_read,
    output mem_to_reg,
    output mem_write,
    output alu_src,
    output write_enable,
    output pc_to_reg,
    output [1:0] alu_op,
    output is_ecall
    );
    
    
    assign mem_read = (part_of_inst == `LOAD) ? 1 : 0;
    assign mem_to_reg = (part_of_inst == `LOAD) ? 1 : 0;
    assign mem_write = (part_of_inst == `STORE) ? 1 : 0;
    assign alu_src = (part_of_inst != `ARITHMETIC) ? 1 : 0;
    assign write_enable = (part_of_inst != `STORE) ? 1 : 0;
    assign pc_to_reg = 0;
    assign alu_op = (part_of_inst == `BRANCH) ? 2'b11 : (part_of_inst == `ARITHMETIC_IMM) ? 2'b10 : (part_of_inst == `ARITHMETIC) ? 2'b01 : 2'b00;
    //00:LOAD,STORE,JALR  01:ARITHMETIC  10:ARITHMETIC_IMM   11:Branch 
    assign is_ecall = (part_of_inst == `ECALL) ? 1 : 0;
    
endmodule
