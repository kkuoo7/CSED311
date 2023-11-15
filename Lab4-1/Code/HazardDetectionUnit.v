module HazardDetectionUnit (input ID_EX_mem_read,
                            input [4:0] ID_EX_rd_field,
                            input [4:0] IF_ID_rs1_field,
                            input [4:0] IF_ID_rs2_field,
                            input [4:0] EX_MEM_rd_field,
                            input [4:0] MEM_WB_rd_field,
                            input is_ecall,
                            output reg PC_stall,
                            output reg IF_ID__stall,
                            output reg control_unit_stall);

    always @(*) begin 
        
        if(is_ecall &&  (ID_EX_rd_field == 'd17 || EX_MEM_rd_field == 'd17)) begin 
                PC_stall = 1;
                IF_ID__stall = 1;
                control_unit_stall = 1;
        end 
        else begin
         if (ID_EX_mem_read && ((ID_EX_rd_field == IF_ID_rs1_field && IF_ID_rs1_field != 0) 
                                || (ID_EX_rd_field == IF_ID_rs2_field && IF_ID_rs2_field != 0)))
            begin
                PC_stall = 1;
                IF_ID__stall = 1;
                control_unit_stall = 1;
            end
         else begin
                PC_stall = 0;
                IF_ID__stall = 0;
                control_unit_stall = 0;
         end  
        end
    end
    
    
    
endmodule