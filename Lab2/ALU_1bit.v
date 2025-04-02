`timescale 1ns/1ps
`include "MUX_2to1.v"
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output reg          result,     //1 bit result    (output)
	output reg          cout        //1 bit carry out (output)
	);
		
/* Write down your code HERE */
	reg A_data, B_data;
	reg And, Or, Add;
	wire temp;

	MUX_4to1 mmt(
		.src1(And),
		.src2(Or),
		.src3(Add),
		.src4(Add),
		.select(operation),
		.result(temp)
	);
	always @(*) begin
		// A B invert
		if (Ainvert == 0) begin
			A_data = src1;
		end else begin
			A_data = ~src1;
		end

		if (Binvert == 0) begin
			B_data = src2;
		end else begin
			B_data = ~src2;
		end
	end
	always @(*) begin
		// MUX
		And	= A_data & B_data;
		Or  = A_data | B_data;
		{cout, Add} = A_data + B_data + cin;
		result = temp;
	end
endmodule
