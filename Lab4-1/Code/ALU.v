`include "alu_op.v"

`include "alu_op.v"

module ALU(input [3:0] alu_op,
           input [31:0] alu_in_1,
           input [31:0] alu_in_2,
           output reg [31:0] alu_result, 
           output reg alu_bcond);


    always @(*) begin
        case(alu_op)

            `OP_ADD: begin
                alu_result = alu_in_1 + alu_in_2; 
                alu_bcond = 0;
            end

            `OP_SUB: begin
                alu_result = alu_in_1 - alu_in_2;
                alu_bcond = 0;
            end
             

            `OP_SLL: begin
                alu_result = alu_in_1 << alu_in_2;
                alu_bcond = 0;
            end
             

            `OP_XOR: begin
                alu_result = alu_in_1 ^ alu_in_2;
                alu_bcond = 0;
            end
             

            `OP_OR: begin
                alu_result = alu_in_1 | alu_in_2;
                alu_bcond = 0;
            end
             

            `OP_AND: begin
                alu_result = alu_in_1 & alu_in_2;
                alu_bcond = 0;
            end
             

            `OP_SRL: begin
                alu_result = alu_in_1 >> alu_in_2;
                alu_bcond = 0;
            end
            

            `OP_BEQ: begin 
                alu_result = alu_in_1 - alu_in_2; 
                
                if (alu_result == 0)
                    alu_bcond = 1;
                else 
                    alu_bcond = 0;
            end

            `OP_BNE: begin 
                alu_result = alu_in_1 - alu_in_2; 

                if (alu_result != 0)
                    alu_bcond = 1;
                else 
                    alu_bcond = 0;
            end

            `OP_BLT: begin 
                alu_result = alu_in_1 - alu_in_2; 

                if ($signed(alu_result) < 0) 
                    alu_bcond = 1;
                else 
                    alu_bcond = 0;
            end

            `OP_BGE: begin 
                alu_result = alu_in_1 - alu_in_2; 

                if ($signed(alu_result) >= 0)
                    alu_bcond = 1;
                else 
                    alu_bcond = 0;
            end

            default: begin
            end     
        endcase
    end 
endmodule 
  