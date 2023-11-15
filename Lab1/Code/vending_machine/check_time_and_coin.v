`include "vending_machine_def.v"
`include "state_def.v"

module check_time_and_coin(i_input_coin, i_select_item, clk, return_flag, reset_n, i_trigger_return, balance_total, current_total, coin_value, wait_time, o_return_coin);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item; 
	input i_trigger_return;

	input [`kTotalBits-1:0] balance_total;
	input [`kTotalBits-1:0] current_total;
	input [31:0] coin_value [`kNumCoins-1:0];

	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;
	
	output reg [0:0] return_flag;

	integer i; 
	integer temp;

	// initiate values
	initial begin
		i <= 0; 
		temp <= 0;
		
		wait_time <= `kWaitTime;
		o_return_coin <= 0;
		
		return_flag <= 0;
	end


	// update coin return time
	always @(current_total) begin
		// TODO: update coin return time
		case(current_total)
			`INIT: begin 
				wait_time = `kWaitTime;
			end  

			`INSERT: begin 
				wait_time = `kWaitTime;
			end

			`SELECT: begin 
				wait_time = `kWaitTime;
			end

			default: begin 
			end   
		endcase
	end

	always @(posedge clk) begin // delete i_trigger_return 
		// TODO: o_return_coin		
		o_return_coin = 0;
    
		if (i_trigger_return || !wait_time) begin 				
			temp = 0;
			
			for(i = `kNumCoins - 1; i >= 0; i = i - 1) begin 	
				if(balance_total - temp >= coin_value[i]) begin 
				    o_return_coin[i] = 1'b1; 
				    temp = temp + coin_value[i];
				end 	
			end 
			return_flag = !return_flag;
		end 
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
			wait_time <= `kWaitTime;
			o_return_coin <= 0;
		end
		else begin
			// TODO: update all states.
			if (wait_time > 0) begin 
				wait_time <= wait_time - 'd1;
			end
		end
	end

endmodule




