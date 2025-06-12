module ALU(
	src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o,
	overflow
	);
     
// I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;
output           overflow;

// Internal signals
parameter ADD = 4'b0010;
parameter SUB = 4'b0110;
parameter AND = 4'b0000;
parameter OR  = 4'b0001;
parameter NOR = 4'b1100;
parameter SLT = 4'b0111;
parameter SLL = 4'b1000;
parameter SRL = 4'b1001;
parameter INVALID = 4'b1111;

reg [32-1:0] result_temp;
assign result_o = result_temp;

reg [32-1:0] zero_temp;
assign zero_o = zero_temp;


// Main function

always @(ctrl_i or src1_i or src2_i) begin

	case (ctrl_i)
		ADD: result_temp = src1_i[31:0] + src2_i[31:0];
		SUB: result_temp = src1_i - src2_i;
		AND: result_temp = src1_i & src2_i;
		OR:  result_temp = src1_i | src2_i;
		NOR: result_temp = ~(src1_i | src2_i);
		SLT: result_temp = (src1_i < src2_i) ? 1 : 0;
		SLL: result_temp = src2_i << src1_i; // rd = rt << shamt(rs)
		SRL: result_temp = src2_i >> src1_i;
		default: result_temp = 32'b1; 
	endcase

		zero_temp = (result_temp == 32'b0) ? 1 : 0; 

end
endmodule
