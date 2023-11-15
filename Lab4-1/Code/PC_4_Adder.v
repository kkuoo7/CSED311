module PC_4_Adder(input [31:0] next_pc, 
    output [31:0] current_pc
    );
    
    assign next_pc = current_pc + 4;
    
endmodule
