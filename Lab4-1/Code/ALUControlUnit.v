`include "opcodes.v"
`include "alu_op.v"

module ALUControlUnit(
input [1:0]alu_ctrl_op, //00:LOAD,STORE,JALR  01:ARITHMETIC  10:ARITHMETIC_IMM   11:Branch 
input [3:0] part_of_inst, // func7, func3
output reg[3:0] alu_op
    );
    
always @(*) begin 

        case(alu_ctrl_op) // according to opcode

            2'b01: begin //arithmetic
               
                    case(part_of_inst[2:0])
                       `FUNCT3_ADD: begin
                            if (part_of_inst[3]) //func7
                                alu_op = `OP_SUB; 
                            else
                                alu_op = `OP_ADD;
                        end
    
                        `FUNCT3_SLL: begin 
                            alu_op = `OP_SLL; 
                        end
    
                        `FUNCT3_XOR: begin 
                            alu_op = `OP_XOR; 
                        end
    
                        `FUNCT3_OR: begin 
                            alu_op = `OP_OR; 
                        end
    
                        `FUNCT3_AND: begin 
                            alu_op = `OP_AND; 
                        end 
    
                        `FUNCT3_SRL: begin 
                            alu_op = `OP_SRL; 
                        end
                      endcase
                    end 
    
            2'b10: begin //arithmetic imm
               
                    case(part_of_inst[2:0]) //func3 
                      
                       `FUNCT3_ADD: begin // `FUNCT3_SUB
                            alu_op = `OP_ADD;
                        end
    
                        `FUNCT3_SLL: begin 
                            alu_op = `OP_SLL; 
                        end
    
                        `FUNCT3_XOR: begin 
                            alu_op = `OP_XOR; 
                        end
    
                        `FUNCT3_OR: begin 
                            alu_op = `OP_OR; 
                        end
    
                        `FUNCT3_AND: begin 
                            alu_op = `OP_AND; 
                        end 
    
                        `FUNCT3_SRL: begin 
                            alu_op = `OP_SRL; 
                        end                
                      endcase
                    end 

            2'b00: begin
                alu_op = `OP_ADD;
            end

            2'b11: begin
                    case(part_of_inst[2:0])
                   
                        `FUNCT3_BEQ: begin 
                            alu_op = `OP_BEQ; 
                        end
    
                        `FUNCT3_BNE: begin 
                            alu_op = `OP_BNE; 
                        end
    
                        `FUNCT3_BLT: begin 
                            alu_op = `OP_BLT;
                        end
    
                        `FUNCT3_BGE: begin 
                            alu_op = `OP_BGE;
                        end  
                      endcase 
                    end 
                    
        endcase
    end 
    
endmodule
