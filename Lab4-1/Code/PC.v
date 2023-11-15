module PC(input reset, 
    input clk, 
    input [31:0] next_pc, 
    input PC_stall,
    output reg [31:0] current_pc
    );
    
    always @(posedge clk) begin
        if (!reset && !PC_stall) begin
            current_pc <= next_pc;
        end
        else if (reset) begin
            current_pc <= 0;
        end
        else begin // PC_stall == 1
            current_pc <= current_pc; 
        end  
    end
    
endmodule
