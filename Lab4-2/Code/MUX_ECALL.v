module MUX_ECALL(mux_in1, mux_in2, select_signal, mux_out);
    input [4:0] mux_in1; 
    input [4:0] mux_in2; 
    input select_signal;
    output [4:0] mux_out;

    assign mux_out = (select_signal) ? mux_in2 : mux_in1; 

endmodule 
