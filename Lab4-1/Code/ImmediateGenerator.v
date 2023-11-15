`include "opcodes.v"

module ImmediateGenerator(
    input [31:0] part_of_inst,
    output reg[31:0] imm_gen_out
    );
    
    wire [6:0] opcode;
    assign opcode = part_of_inst[6:0];
    
    wire [2:0] funct3;
    assign funct3 = part_of_inst[14:12];
    
    wire [2:0] optype;
    //000 etc, 001 I-ALU,010 I-Shift,011 S-type, 
   //100 SB-type, 101 JAL,110 JALR,111 Load

   //find op type
    always @(*) begin
        case(opcode)
            `ARITHMETIC_IMM: begin 
                if(funct3 == `FUNCT3_SLL || funct3 == `FUNCT3_SRL) begin // shift
                    imm_gen_out = {{27{1'b0}}, part_of_inst[24:20]};
                end 
                else begin 
                    imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:20]};
                end
            end

            `LOAD: begin 
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:20]}; 
            end
            
            `STORE: begin 
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:25], part_of_inst[11:7]};
            end
            
            `BRANCH: begin
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0};
            end 
           
            `JAL: begin
                imm_gen_out = {{12{part_of_inst[31]}}, part_of_inst[19:12], part_of_inst[20], part_of_inst[30:21], 1'b0};
            end 
           
            `JALR: begin
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:20]};
            end 
            
            default: imm_gen_out = 0;
        endcase
    end;
endmodule
