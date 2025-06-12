module Decoder( 
	instr_op_i, 
	ALUOp_o, 
	ALUSrc_o,
	RegWrite_o,	
	RegDst_o,
	Branch_o,
	MemRead_o, 
	MemWrite_o, 
	MemtoReg_o,
	BranchType_o
);
     
// TO DO


// parameter
parameter 	R_TYPE 	= 6'b000000;	// add sub and or nor slt sll srl jr 
parameter	ADDI 	= 6'b001000;	// addi
parameter	LW		= 6'b101011;	// lw
parameter	SW 		= 6'b100011;	// sw
parameter	BEQ 	= 6'b000101;	// beq
parameter	BNE 	= 6'b000100;	// bne


// I/O ports
input	[6-1:0] instr_op_i;

output	[2-1:0] ALUOp_o;
output	[2-1:0] RegDst_o, MemtoReg_o;
output  [2-1:0] Branch_o;
output			ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o, BranchType_o;

// Internal Signals
reg	[2-1:0] ALUOp_o;
reg	[2-1:0] RegDst_o, MemtoReg_o;
reg [2-1:0] Branch_o;
reg			ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o, BranchType_o;

// Main function
/* your code here */
always@(*)begin
	case(instr_op_i)

		R_TYPE: 
		begin 
			ALUOp_o 	<= 2'b10; // USER DEFINED
			ALUSrc_o 	<= 1'b0;
			RegDst_o 	<= 2'b01;
			RegWrite_o 	<= 1'b1;
			Branch_o 	<= 2'b00;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b0;
			MemtoReg_o 	<= 2'b00;
		end

		// I-type
		ADDI:
		begin 
			ALUOp_o 	<= 2'b00;
			ALUSrc_o 	<= 1'b1;
			RegDst_o 	<= 2'b00;
			RegWrite_o 	<= 1'b1;
			Branch_o 	<= 2'b00;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b0;
			MemtoReg_o 	<= 2'b00;
		end
		LW: 
		begin 
			ALUOp_o 	<= 2'b00;
			ALUSrc_o 	<= 1'b1;
			RegDst_o 	<= 2'b00;
			RegWrite_o 	<= 1'b1;
			Branch_o 	<= 2'b00;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b1;
			MemWrite_o 	<= 1'b0;
			MemtoReg_o 	<= 2'b01;
		end
		SW: 
		begin 
			ALUOp_o 	<= 2'b00;
			ALUSrc_o 	<= 1'b1;
			// RegDst_o <= 2'bxx;	
			RegWrite_o 	<= 1'b0;
			Branch_o 	<= 2'b00;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b1;
			// MemtoReg_o <= 2'bxx;
		end
		BEQ: 
		begin
			ALUOp_o 	<= 2'b01;
			ALUSrc_o 	<= 1'b0;
			// RegDst_o <= 2'b00;	   
			RegWrite_o 	<= 1'b0;	   
			Branch_o 	<= 2'b01;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b0;
			// MemtoReg_o <= 2'bxx;
		end

		BNE: 
		begin
			ALUOp_o 	<= 2'b01;
			ALUSrc_o 	<= 1'b0;
			// RegDst_o <= 2'b00;	   
			RegWrite_o 	<= 1'b0;	   
			Branch_o 	<= 2'b10;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b0;
			// MemtoReg_o <= 2'bxx;
		end

		default:  
		begin
			ALUOp_o 	<= 2'b00;
			ALUSrc_o 	<= 1'b0;
			RegDst_o 	<= 2'b00;
			RegWrite_o 	<= 1'b0;	
			Branch_o 	<= 2'b00;
			Jump_o 		<= 1'b0;
			MemRead_o 	<= 1'b0;
			MemWrite_o 	<= 1'b0;
			MemtoReg_o 	<= 2'b00;
		end
	endcase
end

endmodule