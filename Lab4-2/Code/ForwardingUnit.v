module ForwardingUnit(input [4:0] ID_EX_rs1_field, 
                      input [4:0] ID_EX_rs2_field, 
                      input [4:0] EX_MEM_rd_field, 
                      input [4:0] MEM_WB_rd_field,
                      input EX_MEM_reg_write,
                      input MEM_WB_reg_write,
                      output [1:0] forwarding_unit_to_mux_A,
                      output [1:0] forwarding_unit_to_mux_B);
        
    // always @(*) begin 
        
    //     if (EX_MEM_reg_write && (ID_EX_rs1_field == EX_MEM_rd_field))
    //         forwarding_unit_to_mux_A = 2'b01;
        
    //     else if (MEM_WB_reg_write && (ID_EX_rs1_field == MEM_WB_rd_field))
    //         forwarding_unit_to_mux_A = 2'b10;
    //     else 
    //         forwarding_unit_to_mux_A = 2'b00;

    //     if (EX_MEM_reg_write && (ID_EX_rs2_field == EX_MEM_rd_field))
    //         forwarding_unit_to_mux_B = 2'b01;
        
    //     else if (MEM_WB_reg_write && (ID_EX_rs2_field == MEM_WB_rd_field))
    //         forwarding_unit_to_mux_B = 2'b10;
    //     else 
    //         forwarding_unit_to_mux_B = 2'b00;
    // end


    assign forwarding_unit_to_mux_A = (EX_MEM_reg_write && (ID_EX_rs1_field == EX_MEM_rd_field) && ID_EX_rs1_field !=0) ? 
                                        2'b01 : (MEM_WB_reg_write && (ID_EX_rs1_field == MEM_WB_rd_field) && ID_EX_rs1_field !=0) ? 
                                            2'b10 : 2'b00;

    assign forwarding_unit_to_mux_B = (EX_MEM_reg_write && (ID_EX_rs2_field == EX_MEM_rd_field) && ID_EX_rs2_field !=0) ? 
                                        2'b01 : (MEM_WB_reg_write && (ID_EX_rs2_field == MEM_WB_rd_field) && ID_EX_rs2_field !=0) ? 
                                            2'b10 : 2'b00;

endmodule