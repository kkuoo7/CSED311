module NextPCLogic(
    input kill, 
    input hash_colision,
    input ID_EX_predict_branch_taken, 
    input ID_EX_is_jalr, 
    input [31:0] ID_EX_pc, 
    input [31:0] ID_EX_imm, 
    input [31:0] btb_next_pc, 
    input [31:0] jalr_next_pc, 
    output reg [31:0] next_pc
);

always @(*) begin 
if(hash_colision) next_pc = ID_EX_pc + ID_EX_imm;
else begin
        if (kill) begin
             if (ID_EX_is_jalr) begin 
                 next_pc = jalr_next_pc; 
             end  
             else begin
                     if (ID_EX_predict_branch_taken) begin 
                         next_pc = ID_EX_pc + 4;
                     end
                     else begin 
                         next_pc = ID_EX_pc + ID_EX_imm;
                     end
                end
            
    end
    else begin
        next_pc = btb_next_pc; 
    end 
end    
    
end 

endmodule