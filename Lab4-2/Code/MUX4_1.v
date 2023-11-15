module Mux4_1(mux_in1, mux_in2, mux_in3, mux_in4, select_signal, mux_out);
    input [31:0] mux_in1; 
    input [31:0] mux_in2; 
    input [31:0] mux_in3; 
    input [31:0] mux_in4; 

    input [1:0] select_signal;
    output [31:0] mux_out;

    assign mux_out = (select_signal == 2'b00) ? mux_in1 : (select_signal == 2'b01 ? mux_in2 : (select_signal == 2'b10 ? mux_in3 : mux_in4));

endmodule 