`include "opcodes.v"

module MicroCounter(
   input reset,
   input clk,
   input [6:0] part_of_inst,
   input [1:0] addr_ctrl,
   output [3:0] curr_state
   );
   
    reg [3:0] internal_curr_state;
    reg [31:0] instruction_counter;
    
    wire [3:0] state_to_adder;
    wire [3:0] adder_to_mux;
    wire [3:0] jump_state_1;
    wire [3:0] jump_state_2;
    wire [3:0] next_state;
    wire [3:0] always1; 

    assign always1 = 1;
    assign curr_state = internal_curr_state;
    assign state_to_adder = internal_curr_state;
    
    Adder adder1(.A(always1), .B(state_to_adder), .result(adder_to_mux));

    ROM1 rom1(.opcode(part_of_inst), .next_state(jump_state_1));
    ROM2 rom2(.opcode(part_of_inst), .next_state(jump_state_2));
        
    Mux4_1_4bits mc_mux(.mux_in1(adder_to_mux), .mux_in2(jump_state_1), .mux_in3(jump_state_2), .mux_in4(always1), .select_signal(addr_ctrl), .mux_out(next_state));
   
    always @(posedge clk) begin
        if(reset) begin 
           internal_curr_state <= 4'b0000;
           instruction_counter <= 0;
        end
        else begin
            internal_curr_state <= next_state;
            
            if (next_state == 1) instruction_counter <= instruction_counter + 1;
        end
    end
    
endmodule


module Adder(
    input [3:0] A,
    input [3:0] B,
    output [3:0] result
    );

    assign result = A + B;

endmodule


module ROM1(
    input [6:0] opcode,
    output reg [3:0] next_state
    );

    always @(*) begin
        case(opcode)
            `ARITHMETIC: begin next_state = 3; end
                
            `ARITHMETIC_IMM: begin next_state = 5; end
                
            `LOAD: begin next_state = 5; end
                        
            `STORE: begin next_state = 5; end
                        
            `BRANCH: begin next_state = 9; end
                
            `JAL: begin next_state = 11; end
                
            `JALR: begin next_state = 12; end
                
            `ECALL: begin next_state = 13; end
        endcase
    end
endmodule

module ROM2(
    input [6:0] opcode,
    output reg [3:0] next_state
);

    always @(*) begin
        case(opcode)
            `ARITHMETIC_IMM: begin next_state = 4; end
                
            `LOAD: begin next_state = 6; end
                        
            `STORE: begin next_state = 8; end
        endcase
    end

endmodule

module Mux4_1_4bits(mux_in1, mux_in2, mux_in3, mux_in4, select_signal, mux_out);
    input [3:0] mux_in1; 
    input [3:0] mux_in2; 
    input [3:0] mux_in3; 
    input [3:0] mux_in4; 
    input [1:0] select_signal;
    output [3:0] mux_out;

    assign mux_out = (select_signal == 2'b00) ? mux_in1 : (select_signal == 2'b01 ? mux_in2 : (select_signal == 2'b10 ? mux_in3 : mux_in4));

endmodule 



/*
0-Idle
1-IF
2-ID   RF -> A,B PC+4 -> ALUOUT
3-EX_R  A(+)B -> ALUOUT
4-EX_I   A(+)IMM = ALUOUT
5-EX_B  bcond?        if! ALUOT -> PC
6-EX_JAL  ALUOUT -> RF    PC = PC+IMM
7-EX_JALR  ALUOUT -> RF   PC = A+IMM
8-WB_B PC = PC+IMM
9-MEM_L Load to MDR
10-MEM_S  Store  PC+4
11-WB_L MDR->RF PC+4
12-WB_R ALUOT->RF PC+4
13-ECALL
*/
