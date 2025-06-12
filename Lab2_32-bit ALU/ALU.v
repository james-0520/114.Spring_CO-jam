`timescale 1ns/1ps
`include "ALU_1bit.v"
module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output reg   [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow            (output)
	);

/* Write down your code HERE */
	wire [32-1:0] result_temp;
	wire [32-1:0] cout_temp;
	
	ALU_1bit ALU_0(
		.src1(src1[0]),
		.src2(src2[0]),
		.less(1'b0),
		.Ainvert(ALU_control[3]),
		.Binvert(ALU_control[2]),
		.operation(ALU_control[1:0]),
		.cin(ALU_control[2]),
		.result(result_temp[0]),
		.cout(cout_temp[0])
	);
	
	generate
	// ALU_1bit
	genvar i;
	for (i = 1; i < 31; i = i + 1) begin: ALU_1bit 
	ALU_1bit ALU_1bit_inst(
			.src1(src1[i]),
			.src2(src2[i]),
			.less(1'b0),
			.Ainvert(ALU_control[3]),
			.Binvert(ALU_control[2]),
			.operation(ALU_control[1:0]),
			.cin(cout_temp[i-1]),
			.result(result_temp[i]),
			.cout(cout_temp[i])
		);
	end
	endgenerate

	ALU_1bit ALU_31(
		.src1(src1[31]),
		.src2(src2[31]),
		.less(1'b0),
		.Ainvert(ALU_control[3]),
		.Binvert(ALU_control[2]),
		.operation(ALU_control[1:0]),
		.cin(cout_temp[30]),
		.result(result_temp[31]),
		.cout(cout_temp[31]) 
	);

	always @(*) begin 
		result = result_temp;
		if (rst_n == 0) begin // neg reset
			result = 32'd0;
			zero = 1'b0;
			cout = 1'b0;
			overflow = 1'b0;
		end else begin
			if(ALU_control[1:0] == 2'b10) begin // add sub
				cout = cout_temp[31];
				overflow = cout_temp[31] ^ cout_temp[30];
			end else begin // other operation
				if (ALU_control[1:0] == 2'b11) begin
					if (result[31] == 1'b1) begin // A - B < 0
						result = 32'd1;
					end else begin 
						result = 32'd0;
					end
					cout = 1'b0;
					overflow = 1'b0;
				end 
			end
		end
		if (result == 32'd0) begin
			zero = 1'b1;
		end else begin
			zero = 1'b0;
		end
	end
endmodule

