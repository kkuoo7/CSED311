`include "vending_machine_def.v"
`include "state_def.v"

module calculate_current_state(i_input_coin, i_select_item, return_flag, item_price, coin_value, current_total,
input_total, output_total, return_total, balance_total, current_total_nxt, wait_time, i_trigger_return, o_return_coin, o_available_item, o_output_item);

	input [`kNumCoins-1:0] i_input_coin, o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;

	input i_trigger_return;
	
	input [0:0] return_flag;

	output reg [`kNumItems-1:0] o_available_item, o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total, current_total_nxt;
	output [`kTotalBits-1:0] balance_total;
	
	integer i;	
	reg is_select_possible; 


	initial begin 
		current_total_nxt <= `INIT; 

		input_total <= 0; 
		output_total <= 0; 
		return_total <= 0;

		i <= 0;
		is_select_possible <= 1'b0;
	end


	assign balance_total = input_total - output_total - return_total;


	// combinational logic for the next states
	// TODO: current_total_nxt
	// You don't have to worry about concurrent activations in each input vector (or array).
	// Calculate the next current_total state.
	always @(i_select_item or i_input_coin) begin

		case(current_total)
			`INIT: begin 
				if (i_input_coin) begin 
					current_total_nxt = `INSERT;
				end 
				else begin 
					current_total_nxt = `INIT;
				end
			end

			`IDLE: begin
				if (i_input_coin) begin 
					current_total_nxt = `INSERT; 
				end

				else if (i_select_item) begin 
					is_select_possible = 1'b0;

					for (i = 0; i < `kNumItems; i = i + 1) begin 
						if (i_select_item[i] && (balance_total >= item_price[i])) begin 
							is_select_possible = 1'b1;
						end else;
					end

					if (is_select_possible) begin 
						current_total_nxt = `SELECT;
					end
					else
					 begin 
						current_total_nxt = `IDLE;
					end
				end
				
				else begin 
					current_total_nxt = `IDLE;
				end 
			end 

			`INSERT: begin
				current_total_nxt = `IDLE;
			end

			`SELECT: begin 
			     if (i_input_coin) current_total_nxt = `INSERT; 
				else current_total_nxt = `IDLE;
			end
		endcase	
	end 



	
	// Combinational logic for the output logic 
	always @(current_total or return_flag) begin
		
		case(current_total)
			`INIT: begin
				o_available_item = 0;
				o_output_item = 0;

				input_total = 0;
				output_total = 0; 
				return_total = 0;
			end

			`IDLE: begin
				for (i = 0; i < `kNumItems; i = i + 1) begin 
					if (item_price[i] <= balance_total) begin 
						o_available_item[i] = 1'b1;
					end 
					else begin 
						o_available_item[i] = 1'b0;
					end 
				end
				
			
                for (i = 0; i < `kNumCoins; i = i + 1) begin 
                    if (o_return_coin[i] == 1) begin 
                        return_total = return_total + coin_value[i];
                    end
                end             
             end 
			
			`INSERT: begin
				for (i = 0; i < `kNumCoins; i = i + 1) begin 
					if (i_input_coin[i] == 1) input_total = input_total + coin_value[i];
				end 		
			end 

			`SELECT: begin
				for (i = 0; i < `kNumItems; i = i + 1) begin 
					if (i_select_item[i]) begin 
						output_total = output_total + item_price[i];
						o_output_item[i] = 1'b1;
					end
					else begin 
					   o_output_item[i] = 1'b0;
					end  
				end 
			end 
			
		endcase
		
	end
 
endmodule 