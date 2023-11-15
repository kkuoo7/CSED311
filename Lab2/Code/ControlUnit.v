`include "opcodes.v"

module ControlUnit (input [6:0] part_of_inst, // opcode 
                    input bcond, 
                    output is_jal,
                    output is_jalr, 
                    output branch, 
                    output mem_read, 
                    output mem_to_reg, 
                    output mem_write, 
                    output alu_src, 
                    output write_enable, 
                    output pc_to_reg, 
                    output is_ecall);


    assign is_jal = (part_of_inst == `JAL) ? 1 : 0; 
    assign is_jalr = (part_of_inst == `JALR) ? 1 : 0; 
    assign branch = (part_of_inst == `BRANCH) ? 1 : 0; 
    assign mem_read = (part_of_inst == `LOAD) ? 1 : 0; 
    assign mem_to_reg = (part_of_inst == `LOAD) ? 1 : 0;
    assign mem_write = (part_of_inst == `STORE) ? 1 : 0; 
    assign alu_src = (part_of_inst != `ARITHMETIC && part_of_inst != `BRANCH) ? 1 : 0;
    assign write_enable = (part_of_inst != `STORE && part_of_inst != `BRANCH) ? 1 : 0;
    assign pc_to_reg = (part_of_inst == `JAL || part_of_inst == `JALR) ? 1 : 0;
    
    assign is_ecall = (part_of_inst == `ECALL) ? 1 : 0; 

endmodule
