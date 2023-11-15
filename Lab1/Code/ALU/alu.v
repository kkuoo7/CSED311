module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
    output reg [data_width - 1: 0] C,
    output reg OverflowFlag);

// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

`include "alu_func.v"

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION..
*/

// wire Z;  

always @(A, B, FuncCode) begin 
	case(FuncCode)
		`FUNC_ADD: begin 
			C = A + B; 

			if (A[15] == B[15]) begin 
				if (A[15] != C[15]) OverflowFlag = 1; 
				else OverflowFlag = 0;
			end 
			else 
				OverflowFlag = 0; 
		end 

		`FUNC_SUB: begin
			C = A - B; 

			if (A[15] != B[15]) begin 
				if (A[15] != C[15]) OverflowFlag = 1; 
				else OverflowFlag = 0;
			end
			else 
				OverflowFlag = 0;
		end

		`FUNC_ID: begin 
			C = A; 
			OverflowFlag = 0;
		end

		`FUNC_NOT: begin 
			C = ~A; 
			OverflowFlag = 0;
		end

		`FUNC_AND: begin 
			C = A & B; 
			OverflowFlag = 0;
		end

		`FUNC_OR: begin 
			C = A | B; 
			OverflowFlag = 0;
		end   

		`FUNC_NAND: begin 
			C = ~(A & B);
			OverflowFlag = 0;
		end

		`FUNC_NOR: begin 
			C = ~(A | B);
			OverflowFlag = 0;
		end  

		`FUNC_XOR: begin 
			C = A ^ B;
			OverflowFlag = 0;
		end 

		`FUNC_XNOR: begin 
			C = A ^~ B;
			OverflowFlag = 0;
		end

		`FUNC_LLS: begin 
			C = A << 1; 
			OverflowFlag = 0;
		end 

		`FUNC_LRS: begin 
			C = A >> 1; 
			OverflowFlag = 0;
		end

		`FUNC_ALS: begin 
			C = (A <<< 1); // same as LLS 
			OverflowFlag = 0;
		end

		`FUNC_ARS: begin 
			C = $signed(A) >>> 1; // fill with signed bit 
			OverflowFlag = 0;
		end

		`FUNC_TCP: begin 
			C = ~A + 1;
			OverflowFlag = 0;
		end 

		`FUNC_ZERO: begin 
			C = 0;
			OverflowFlag = 0;
		end 

		default: begin 
		end
	
	endcase
end 

endmodule

