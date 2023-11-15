`include "opcodes.v"
`include "alu_op.v"

module ALUControlUnit  (input [31:0] part_of_inst, output reg [3:0] alu_op);

    always @(*) begin 

        case(part_of_inst[6:0]) // according to opcode

            `ARITHMETIC: begin 
               
                case(part_of_inst[14:12]) // according to funct3    
                   `FUNCT3_ADD: begin // `FUNCT3_SUB
                        if (part_of_inst[31:25] == `FUNCT7_SUB) 
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

            `ARITHMETIC_IMM: begin
                case(part_of_inst[14:12]) // according to funct3 
                  
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

            `LOAD,
            `STORE,
            `JALR: begin
                alu_op = `OP_ADD;
            end

            `BRANCH: begin
                case(part_of_inst[14:12])
               
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

            default: begin 
            end 

        endcase
    end 
    
endmodule

// // FUNCT3
// `define FUNCT3_BEQ      3'b000
// `define FUNCT3_BNE      3'b001
// `define FUNCT3_BLT      3'b100
// `define FUNCT3_BGE      3'b101

// `define FUNCT3_LW       3'b010
// `define FUNCT3_SW       3'b010

// `define FUNCT3_ADD      3'b000
// `define FUNCT3_SUB      3'b000
// `define FUNCT3_SLL      3'b001
// `define FUNCT3_XOR      3'b100
// `define FUNCT3_OR       3'b110
// `define FUNCT3_AND      3'b111
// `define FUNCT3_SRL      3'b101

// // FUNCT7
// `define FUNCT7_SUB      7'b0100000
// `define FUNCT7_OTHERS   7'b0000000
