`include "opcodes.v"

module Mux(mux_in1, mux_in2, select_signal, mux_out);
    input [31:0] mux_in1; 
    input [31:0] mux_in2; 
    input select_signal;
    output [31:0] mux_out;

    assign mux_out = (!select_signal) ? mux_in1 : mux_in2; 

endmodule 

