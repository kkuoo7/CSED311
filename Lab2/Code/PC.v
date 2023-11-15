module PC(reset, clk, next_pc, current_pc); 
    input reset; 
    input clk; 
    input [31:0] next_pc; 
    output reg [31:0] current_pc;
    
    

    always @(posedge clk) begin
        if (!reset) begin
            current_pc <= next_pc;
        end
        else begin  // when reset is high
            current_pc <= 0;
        end 
    end


endmodule 
