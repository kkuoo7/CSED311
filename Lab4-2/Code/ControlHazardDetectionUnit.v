`include "opcodes.v"

module ControlHazardDetectionUnit(
    input ID_EX_is_jal,
    input ID_EX_is_jalr,
    input ID_EX_is_branch,
    input ID_EX_predict_branch_taken,// 1:0 taken/not taken
    input ID_EX_actual_branch_taken,// 1:0 taken/not taken
    input [31:0] ID_EX_branch_target,
    input [31:0] ID_EX_branch_predict_target,
    output kill, //stop IF,ID
    output hash_colision
);
    wire jump_error;
    
    assign jump_error = ((ID_EX_is_jal && !ID_EX_predict_branch_taken) || ID_EX_is_jalr) ? 1 : ((ID_EX_is_branch && (ID_EX_predict_branch_taken != ID_EX_actual_branch_taken)) ? 1 : 0);
    assign hash_colision = ID_EX_actual_branch_taken&&ID_EX_predict_branch_taken&&(ID_EX_branch_target != ID_EX_branch_predict_target);
    assign kill = jump_error||hash_colision;
    
endmodule





    
    
