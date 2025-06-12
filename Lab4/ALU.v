module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o,
    cout,
    overflow
	);
     
// I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;
output           cout;
output           overflow;

// Internal signals
reg    [32-1:0]  result_o;
wire             zero_o;
wire             cout;
wire             overflow;

// Parameter
assign zero_o = (result_o == 0);
assign overflow = ~((ctrl_i == 4'b0001) ^ (src1_i[31] ^ src2_i[31])) &
    (src1_i[31] ^ result_o[31]) & (ctrl_i == 4'b0001 | ctrl_i == 4'b0000);

wire [32:0] add_result = {1'b0, src1_i} + {1'b0, src2_i};
wire [32:0] sub_result = {1'b0, src1_i} - {1'b0, src2_i};

assign cout = (ctrl_i == 4'b0000) ? add_result[32] :
              (ctrl_i == 4'b0001) ? sub_result[32] : 1'b0;
              
// Main function
/* your code here */
always @(*) begin
    case (ctrl_i)
        4'b0000: result_o <= src1_i + src2_i;                  // ADD (add, addi, lw, sw)
        4'b0001: result_o <= src1_i - src2_i;                  // SUB (sub, beq)
        4'b0010: result_o <= src1_i & src2_i;                  // AND
        4'b0011: result_o <= src1_i | src2_i;                  // OR
        4'b0100: result_o <= ~(src1_i | src2_i);               // NOR
        4'b0101: result_o <= (src1_i < src2_i) ? 1 : 0;        // SLT

        4'b1000: result_o <= src2_i << src1_i[4:0];            // SLLV (use shift amount from src1_i)
        4'b1001: result_o <= src2_i >> src1_i[4:0];            // SRLV

        4'b1010: result_o <= 0;                                // JR (nothing to compute here)
        
		default: result_o <= 0;                                // Undefined control signal
    endcase

end

endmodule





                    
                    