module Decoder( 
	instr_op_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input	[6-1:0] instr_op_i;

output	[2-1:0] ALU_op_o;
output	[2-1:0] RegDst_o, MemtoReg_o;
output  [2-1:0] Branch_o;
output			ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o;

// Internal Signals

parameter R_TYPE = 6'b000000;
parameter ADDI = 6'b001000;
parameter LW = 6'b101011;
parameter SW = 6'b100011;
parameter BEQ = 6'b000101;
parameter BNE = 6'b000100;
parameter JUMP = 6'b000011;
parameter JAL = 6'b000010;

reg 	[2-1:0] ALU_op_tmp;
reg 	[2-1:0] RegDst_tmp, MemtoReg_tmp;
reg 	[2-1:0] Branch_tmp;
reg 	ALUSrc_tmp, RegWrite_tmp, Jump_tmp, MemRead_tmp, MemWrite_tmp;

assign 	ALU_op_o = ALU_op_tmp;
assign 	RegDst_o = RegDst_tmp;
assign 	MemtoReg_o = MemtoReg_tmp;
assign 	Branch_o = Branch_tmp;
assign 	ALUSrc_o = ALUSrc_tmp;
assign 	RegWrite_o = RegWrite_tmp;
assign 	Jump_o = Jump_tmp;
assign 	MemRead_o = MemRead_tmp;
assign 	MemWrite_o = MemWrite_tmp;
// Main function

always@(*)begin
	case (instr_op_i)
		R_TYPE: begin // R-type
			ALU_op_tmp = 2'b10;
			RegDst_tmp = 2'b01;
			MemtoReg_tmp = 2'b00;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b1;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		LW: begin // lw
			ALU_op_tmp = 2'b00;
			RegDst_tmp = 2'b00;
			MemtoReg_tmp = 2'b01;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b1;
			RegWrite_tmp = 1'b1;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b1;
			MemWrite_tmp = 1'b0;
		end
		SW: begin // sw
			ALU_op_tmp = 2'b00;
			RegDst_tmp = 2'bxx;
			MemtoReg_tmp = 2'bxx;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b1;
			RegWrite_tmp = 1'b0;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b1;
		end
		ADDI: begin // addi
			ALU_op_tmp = 2'b00;
			RegDst_tmp = 2'b00;
			MemtoReg_tmp = 2'b00;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b1;
			RegWrite_tmp = 1'b1;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		BEQ: begin // beq
			ALU_op_tmp = 2'b01;
			RegDst_tmp = 2'bxx;
			MemtoReg_tmp = 2'bxx;
			Branch_tmp = 2'b01;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b0;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		BNE: begin // bne
			ALU_op_tmp = 2'b11;
			RegDst_tmp = 2'bxx;
			MemtoReg_tmp = 2'bxx;
			Branch_tmp = 2'b10;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b0;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		JAL: begin // jal
			ALU_op_tmp = 2'b00;
			RegDst_tmp = 2'b10;
			MemtoReg_tmp = 2'b10;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b1;
			Jump_tmp = 1'b1;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		JUMP: begin // jump
			ALU_op_tmp = 2'bxx;
			RegDst_tmp = 2'bxx;
			MemtoReg_tmp = 2'bxx;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b0;
			Jump_tmp = 1'b1;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		default: begin
			ALU_op_tmp = 2'b00;
			RegDst_tmp = 2'b00;
			MemtoReg_tmp = 2'b00;
			Branch_tmp = 2'b00;
			ALUSrc_tmp = 1'b0;
			RegWrite_tmp = 1'b0;
			Jump_tmp = 1'b0;
			MemRead_tmp = 1'b0;
			MemWrite_tmp = 1'b0;
		end
		
	endcase
end
endmodule