module PC(reset, clk, next_pc, pc_write_enable, current_pc); 
    input reset; 
    input clk; 
    input [31:0] next_pc; 
    input pc_write_enable;
    output reg [31:0] current_pc;
    
    
    always @(posedge clk) begin
        if (reset) begin
            current_pc <= 0;
        end
        else begin  // when reset is high 
            if (pc_write_enable) begin
                current_pc <= next_pc;
            end 
            else begin 
                current_pc <= current_pc;
            end 
        end
    end


endmodule 
