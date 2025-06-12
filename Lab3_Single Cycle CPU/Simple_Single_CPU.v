
`include "ProgramCounter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Decoder.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Sign_Extend.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Shift_Left_Two_32.v"
`include "Data_Memory.v"



module Simple_Single_CPU(
        clk_i,
	rst_i
);
		
// I/O port
input         clk_i;
input         rst_i;

// Internal Signals
wire [32-1:0] pc_in;
wire [32-1:0] pc_out;
wire [32-1:0] pc_addr;
wire [32-1:0] instr;

// Control Signals
wire [2-1:0] ALU_op;
wire ALUSrc;
wire RegWrite;
wire [2-1:0] RegDst;
wire [2-1:0] Branch; // beq bne
wire Jump; // jump jal
wire MemRead;
wire MemWrite;
wire [2-1:0] MemtoReg;
wire [4-1:0] ALUCtrl;
wire Branch_Jump_Ctrl;
wire SLL;
wire SLLV;
wire JAL;
wire JR;

// Internal Signals
wire [5-1:0] MUX_RegDst_out;
wire [32-1:0] RSdata;
wire [32-1:0] RTdata;
wire [32-1:0] MUX_RS_out;
wire [32-1:0] Sign_Extend_out;
wire [32-1:0] MUX_ALUSrc_out;
wire [32-1:0] ALU_result;
wire ALU_zero;
wire [32-1:0] Shift_Left_Two_out;
wire [32-1:0] Data_Memory_out;
wire [32-1:0] MemtoReg_result;
wire [32-1:0] Branch_Jump;
wire [32-1:0] MUX_Branch_out;
wire [32-1:0] MUX_JUMP_out;


// Components
ProgramCounter PC(
        .clk_i(clk_i),      
        .rst_i(rst_i),     
        .pc_in_i(pc_in),   
        .pc_out_o(pc_out) 
);

Adder Adder(
        .src1_i(pc_out), 
        .src2_i(32'd4),     
        .sum_o(pc_addr)    
);

Instr_Memory IM(
        .pc_addr_i(pc_out),  
        .instr_o(instr)    
);

Decoder Decoder(
        .instr_op_i(instr[31:26]), 
        .ALU_op_o(ALU_op), 
        .ALUSrc_o(ALUSrc), 
        .RegWrite_o(RegWrite), 
        .RegDst_o(RegDst), 
        .Branch_o(Branch), 
        .Jump_o(Jump), 
        .MemRead_o(MemRead), 
        .MemWrite_o(MemWrite), 
        .MemtoReg_o(MemtoReg) 
);

assign JAL = (instr[31:26] == 6'b000010) ? 1 : 0;

MUX_3to1 #(.size(5)) MUX_RegDst(
        .data0_i(instr[20:16]), // rt
        .data1_i(instr[15:11]), // rd
        .data2_i(5'b11111),     // $ra
        .select_i(RegDst), 
        .data_o(MUX_RegDst_out) 
);

Reg_File Registers(
        .clk_i(clk_i),
        .rst_i(rst_i),     
        .RSaddr_i(instr[25:21]), // rs
        .RTaddr_i(instr[20:16]), // rt
        .RDaddr_i(MUX_RegDst_out), // MUX_output
        .RDdata_i(MemtoReg_result),
        .RegWrite_i(RegWrite),
        .RSdata_o(RSdata),  
        .RTdata_o(RTdata) 
);

Sign_Extend Sign_Extend(
        .data_i(instr[15:0]), 
        .data_o(Sign_Extend_out) 
);

ALU_Ctrl ALU_Ctrl(
        .funct_i(instr[5:0]), 
        .ALUOp_i(ALU_op), 
        .ALUCtrl_o(ALUCtrl) 
);

assign SLL = (instr[31:26] == 6'b000000 && 
             (instr[5:0] == 6'b000000 || instr[5:0] == 6'b000010)) ? 1 : 0;

MUX_2to1 #(.size(32)) MUX_RS(
        .data0_i(RSdata), 
        .data1_i({27'b0, instr[10:6]}), 
        .select_i(SLL), 
        .data_o(MUX_RS_out) 
);

MUX_2to1 #(.size(32)) MUX_ALUSrc(
        .data0_i(RTdata), 
        .data1_i(Sign_Extend_out), 
        .select_i(ALUSrc), 
        .data_o(MUX_ALUSrc_out) 
);

ALU ALU(
        .src1_i(MUX_RS_out), 
        .src2_i(MUX_ALUSrc_out), 
        .ctrl_i(ALUCtrl), 
        .result_o(ALU_result), 
        .zero_o(ALU_zero), 
        .overflow() 
);

assign Branch_Jump_Ctrl = (Branch[0] & ALU_zero
                        | Branch[1] & ~ALU_zero);
	
Data_Memory Data_Memory(
	.clk_i(clk_i), 
	.addr_i(ALU_result), 
	.data_i(RTdata), 
	.MemRead_i(MemRead), 
	.MemWrite_i(MemWrite), 
	.data_o(Data_Memory_out)
);

MUX_3to1 #(.size(32)) MUX_MemtoReg(
        .data0_i(ALU_result), 
        .data1_i(Data_Memory_out), 
        .data2_i(pc_addr), // for JAL
        .select_i(MemtoReg), 
        .data_o(MemtoReg_result)  //TODO jr
);

Shift_Left_Two_32 Shift_Left_Two(
        .data_i(Sign_Extend_out), 
        .data_o(Shift_Left_Two_out) 
);

Adder Adder_Branch(
        .src1_i(pc_addr), 
        .src2_i(Shift_Left_Two_out), 
        .sum_o(Branch_Jump) 
);

MUX_2to1 #(.size(32)) MUX_Branch(
        .data0_i(pc_addr), 
        .data1_i(Branch_Jump), 
        .select_i(Branch_Jump_Ctrl), 
        .data_o(MUX_Branch_out) 
);

MUX_2to1 #(.size(32)) MUX_Jump(
        .data0_i(MUX_Branch_out), 
        .data1_i({pc_addr[31:28], instr[25:0], 2'b00}), // Jump address
        .select_i(Jump), 
        .data_o(MUX_JUMP_out) 
);

assign JR = (instr[31:26] == 6'b000000 && instr[5:0] == 6'b001000) ? 1 : 0;

MUX_2to1 #(.size(32)) MUX_JR(
        .data0_i(MUX_JUMP_out), 
        .data1_i(RSdata), 
        .select_i(JR), 
        .data_o(pc_in) 
);

endmodule