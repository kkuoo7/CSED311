`include "opcodes.v"

module BranchPredictorGshare(
    input reset,
    input clk,
    input [31:0] current_pc,
    input [31:0] ID_EX_pc,
    input [31:0] ID_EX_branch_target,
    input ID_EX_is_jal,
    input ID_EX_is_branch,
    input ID_EX_actual_branch_taken,
    input [6:0] opcode,
    output [31:0] btb_next_pc,
    output predict_branch_taken);


reg [59:0] Branch_table [31:0]; // valid 1bit tag 25bit BHT 2bit Branch target 32bit.
reg [4:0] Branch_histroy_shift_Reg;

wire [4:0] index;
wire [24:0] tag;
wire [59:0] Table_entry;
wire Table_hit;

wire [4:0] Update_index;
wire [24:0] Update_tag;
wire Update_Table_hit;


assign index = current_pc[6:2] ^ Branch_histroy_shift_Reg;
assign tag = current_pc[31:7];
assign Table_entry = Branch_table[index];

assign Update_index = ID_EX_pc[6:2] ^ Branch_histroy_shift_Reg;
assign Update_tag = ID_EX_pc[31:7];
assign Update_Table_hit = (Branch_table[Update_index][59] && (Branch_table[Update_index][58:34] == Update_tag))? 1 : 0;


always @(posedge clk)begin
    if(reset) begin
        Branch_table [0] <= 0; Branch_table [1] <= 0; Branch_table [2] <= 0; Branch_table [3] <= 0; 
        Branch_table [4] <= 0; Branch_table [5] <= 0; Branch_table [6] <= 0; Branch_table [7] <= 0; 
        Branch_table [8] <= 0; Branch_table [9] <= 0; Branch_table [10] <= 0; Branch_table [11] <= 0; 
        Branch_table [12] <= 0; Branch_table [13] <= 0; Branch_table [14] <= 0; Branch_table [15] <= 0; 
        Branch_table [16] <= 0; Branch_table [17] <= 0; Branch_table [18] <= 0; Branch_table [19] <= 0; 
        Branch_table [20] <= 0; Branch_table [21] <= 0; Branch_table [22] <= 0; Branch_table [23] <= 0; 
        Branch_table [24] <= 0; Branch_table [25] <= 0; Branch_table [26] <= 0; Branch_table [27] <= 0; 
        Branch_table [28] <= 0; Branch_table [29] <= 0; Branch_table [30] <= 0; Branch_table [31] <= 0;
        Branch_histroy_shift_Reg <= 0;
    end
    else begin
        if(ID_EX_is_branch || ID_EX_is_jal) begin
            if(Update_Table_hit) begin
                if(ID_EX_actual_branch_taken) begin
                    case(Branch_table[Update_index][33:32])
                    2'b11: Branch_table[Update_index][33:32] <= 2'b11;
                    2'b10: Branch_table[Update_index][33:32] <= 2'b11;
                    2'b01: Branch_table[Update_index][33:32] <= 2'b10;
                    2'b00: Branch_table[Update_index][33:32] <= 2'b01;
                    endcase
                end
                else begin
                    case(Branch_table[Update_index][33:32])
                    2'b11: Branch_table[Update_index][33:32] <= 2'b10;
                    2'b10: Branch_table[Update_index][33:32] <= 2'b01;
                    2'b01: Branch_table[Update_index][33:32] <= 2'b00;
                    2'b00: Branch_table[Update_index][33:32] <= 2'b00;
                    endcase
                end
            end
            else begin 
                    Branch_table[Update_index][59] <= 1'b1; //valid 1
                    Branch_table[Update_index][58:34] <= ID_EX_pc[31:7]; //set tag
                    if(ID_EX_actual_branch_taken) begin 
                        Branch_table[Update_index][33:32] <= 2'b11;
                    end // because of jal 11.
                    else begin 
                        Branch_table[Update_index][33:32] <= 2'b00;
                    end
                    Branch_table[Update_index][31:0] <= ID_EX_branch_target; //BTB
            end

            if(ID_EX_is_jal) begin 
                // Branch_histroy_shift_Reg <= Branch_histroy_shift_Reg<<1 + 1;
                Branch_histroy_shift_Reg <= {Branch_histroy_shift_Reg[3:0], 1'b1};
            end
            else begin 
                if(ID_EX_actual_branch_taken) begin 
                // Branch_histroy_shift_Reg <= Branch_histroy_shift_Reg<<1 + 1;
                Branch_histroy_shift_Reg <= {Branch_histroy_shift_Reg[3:0], 1'b1};
                end
                else begin 
                // Branch_histroy_shift_Reg <= Branch_histroy_shift_Reg<<1;
                Branch_histroy_shift_Reg <= {Branch_histroy_shift_Reg[3:0], 1'b0};
                end
            end
        end
        else begin end
    end
end


assign Table_hit = (Table_entry[59] && (Table_entry[58:34] == tag))? 1 : 0;
assign predict_branch_taken = (Table_entry[33] && Table_hit) && (opcode == `BRANCH || opcode == `JAL);
assign btb_next_pc = (predict_branch_taken) ? (Table_entry[31:0]) : (current_pc + 4);

endmodule
