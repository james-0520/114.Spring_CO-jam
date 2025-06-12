// use ChatGPT

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Forwarding_Unit.v"
`include "Hazard_Detection.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shifter.v"

`timescale 1ns / 1ps

module Pipe_CPU_PRO(
    clk_i,
    rst_i
);

//========================================
//  I/O port
//========================================
input clk_i;
input rst_i;


//=====================================================================
//  Internal signal  (宣告所有 pipeline 之間要傳遞的 wire)
//=====================================================================

// ---- IF stage ------------------------------------------------------
wire [31:0] pc_current, pc_next, pc_plus4, pc_branch, pc_jump;
wire        pc_write;            // 由 Hazard_Detection 產生
wire [31:0] instr_if;

// IF/ID pipeline latch -------------
wire [31:0] IFID_pc4, IFID_instr;
wire        IFID_write, IFID_flush;

// ---- ID stage ------------------------------------------------------
wire [ 1:0]  id_reg_dst, id_alu_op, id_branch, id_mem_to_reg;
wire         id_alu_src, id_reg_write, id_mem_read, id_mem_write, id_jump;
wire [31:0]  id_rs_data, id_rt_data, id_sign_ext, id_branch_addr;
wire         id_jump_reg;

wire [4:0]   id_rs, id_rt, id_rd;   // index
assign id_rs = IFID_instr[25:21];
assign id_rt = IFID_instr[20:16];
assign id_rd = IFID_instr[15:11];
assign id_jump_reg = (IFID_instr[31:26]==6'b000000 && IFID_instr[5:0]==6'b001000);

// ---- ID/EX pipeline latch ----------------
wire [31:0] IDEX_pc4, IDEX_rs_data, IDEX_rt_data, IDEX_sign_ext, IDEX_shifted;
wire [4:0]  IDEX_rs, IDEX_rt, IDEX_rd;
wire [1:0]  IDEX_reg_dst, IDEX_alu_op, IDEX_branch, IDEX_mem_to_reg;
wire        IDEX_alu_src, IDEX_reg_write, IDEX_mem_read, IDEX_mem_write;
wire        IDEX_jump_reg, IDEX_shift_content, IDEX_flush;

// 為 Hazard / Forwarding 提供訊號
wire [4:0]  IDEX_rt_for_hazard = IDEX_rt;   // load 指令的目的暫存器
wire        IDEX_is_load       = IDEX_mem_read;

// ---- EX stage ------------------------------------------------------
wire [3:0]  ex_alu_ctrl;
wire [31:0] ex_alu_src1, ex_alu_src2, ex_alu_result, ex_shifter_result;
wire        ex_zero;
wire [1:0]  forward_a, forward_b;   // 由 Forwarding_Unit 給
wire [4:0]  ex_dest_reg;           // 寫回 register index after MUX(RegDst)

// EX/MEM pipeline latch --------------
wire [31:0] EXMEM_alu_result, EXMEM_rt_data, EXMEM_branch_addr;
wire        EXMEM_zero;
wire [4:0]  EXMEM_rd;
wire [1:0]  EXMEM_branch, EXMEM_mem_to_reg;
wire        EXMEM_reg_write, EXMEM_mem_read, EXMEM_mem_write;
wire        EXMEM_flush;

// ---- MEM stage -----------------------------------------------------
wire [31:0] mem_data_out;
wire        branch_taken;

assign branch_taken =
       (EXMEM_branch[0] &  EXMEM_zero) |
       (EXMEM_branch[1] & ~EXMEM_zero);

// MEM/WB pipeline latch -------------
wire [31:0] MEMWB_mem_out, MEMWB_alu_out;
wire [4:0]  MEMWB_rd;
wire [1:0]  MEMWB_mem_to_reg;
wire        MEMWB_reg_write;

// ---- WB stage ------------------------------------------------------
wire [31:0] wb_write_data;


//=====================================================================
//  Hazard-Detection  &  Forwarding units
//=====================================================================

Hazard_Detection HDU(
    .memread   (IDEX_is_load),
    .instr_i   (IFID_instr),
    .idex_regt (IDEX_rt_for_hazard),
    .branch    (branch_taken),
    .pcwrite   (pc_write),
    .ifid_write(IFID_write),
    .ifid_flush(IFID_flush),
    .idex_flush(IDEX_flush),
    .exmem_flush(EXMEM_flush)
);

Forwarding_Unit FU(
    .regwrite_mem(EXMEM_reg_write),
    .regwrite_wb (MEMWB_reg_write),
    .idex_regs   (IDEX_rs),
    .idex_regt   (IDEX_rt),
    .exmem_regd  (EXMEM_rd),
    .memwb_regd  (MEMWB_rd),
    .forwarda    (forward_a),
    .forwardb    (forward_b)
);


//=====================================================================
//  IF  stage
//=====================================================================

// --- Program Counter ---
ProgramCounter PC(
    .clk_i (clk_i),
    .rst_i (rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_current),
    .pc_write(pc_write)        // 0 = stall; 1 = normal count
);

// --- PC+4 ---
Adder Adder_PC_4(
    .src1_i(pc_current),
    .src2_i(32'd4),
    .sum_o (pc_plus4)
);

// --- Instruction memory ---
Instruction_Memory IM(
    .addr_i (pc_current),
    .instr_o(instr_if)
);

// --- IF/ID pipeline register (帶 stall / flush) ---
Pipe_Reg #(.size(64)) IF_ID(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_i ({pc_plus4, instr_if}),
    .data_o ({IFID_pc4, IFID_instr}),
    .write(IFID_write),
    .flush(IFID_flush)
);


//=====================================================================
//  ID  stage
//=====================================================================

// --- Main decoder ---
Decoder DEC(
    .instr_op_i (IFID_instr[31:26]),
    .ALUOp_o    (id_alu_op),
    .ALUSrc_o   (id_alu_src),
    .RegWrite_o (id_reg_write),
    .RegDst_o   (id_reg_dst),
    .Branch_o   (id_branch),
    .MemRead_o  (id_mem_read),
    .MemWrite_o (id_mem_write),
    .MemtoReg_o (id_mem_to_reg)
);

// --- Register File ---
Reg_File RF(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .RSaddr_i   (id_rs),
    .RTaddr_i   (id_rt),
    .RDaddr_i   (MEMWB_rd),
    .RDdata_i   (wb_write_data),
    .RegWrite_i (MEMWB_reg_write & ~id_jump_reg),
    .RSdata_o   (id_rs_data),
    .RTdata_o   (id_rt_data)
);

// --- Immediate sign-extend & left-shift(<<2) ---
Sign_Extend SE(
    .data_i(IFID_instr[15:0]),
    .data_o(id_sign_ext)
);



// --- ID/EX  pipeline register ---
Pipe_Reg #(.size(32+32+32+5+5+5+13+32)) ID_EX(   // 14 control bits packed
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_i ({
               IFID_pc4,              // 32
               id_rs_data,            // 32
               id_rt_data,            // 32
               id_rs, id_rt, id_rd,   // 15
               /* control signals below (packed) */
               id_reg_write,          // 1
               id_mem_to_reg,         // 2
               id_mem_read,           // 1
               id_mem_write,          // 1
               id_branch,             // 2
               id_reg_dst,            // 2
               id_alu_op,             // 2
               id_alu_src,            // 1
               id_jump_reg,           // 1
               id_sign_ext           // 32
              }),
    .data_o ({
               IDEX_pc4,
               IDEX_rs_data,
               IDEX_rt_data,
               IDEX_rs, IDEX_rt, IDEX_rd,
               /* control */ 
               IDEX_reg_write,
               IDEX_mem_to_reg,
               IDEX_mem_read,
               IDEX_mem_write,
               IDEX_branch,
               IDEX_reg_dst,
               IDEX_alu_op,
               IDEX_alu_src,
               IDEX_jump_reg,
               IDEX_sign_ext
              }),
    .write(1'b1),
    .flush(IDEX_flush)
);


//=====================================================================
//  EX  stage
//=====================================================================

// ---- ALU control unit ----

ALU_Ctrl AC(
    .funct_i    (IDEX_sign_ext[5:0]),        // 對 R-type 有用
    .ALUOp_i    (IDEX_alu_op),
    .ALUCtrl_o  (ex_alu_ctrl),
    .shift_content(IDEX_shift_content)
);

Shift_Left_Two_32 SLT2(
    .data_i(IDEX_sign_ext),
    .data_o(IDEX_shifted)
);

Adder Adder_PC_Branch(
    .src1_i(IDEX_pc4),
    .src2_i(IDEX_shifted),
    .sum_o(id_branch_addr)
);

// ---- 寫入目標暫存器選擇 (RegDst) ----
wire [4:0] mux_regdst_out;
MUX_3to1 #(.size(5)) MUX_RegDst(
    .data0_i(IDEX_rt),
    .data1_i(IDEX_rd),
    .data2_i(5'd31),             // $ra
    .select_i(IDEX_reg_dst),
    .data_o(mux_regdst_out)
);
assign ex_dest_reg = mux_regdst_out;

// ---- ALU operand forward mux (A) ----
wire [31:0] alu_src1_pre;
MUX_3to1 #(.size(32)) MUX_ForwardA(
    .data0_i(IDEX_rs_data),
    .data1_i(wb_write_data),     // from WB
    .data2_i(EXMEM_alu_result),  // from MEM
    .select_i(forward_a),
    .data_o(alu_src1_pre)
);

// ---- ALU operand forward mux (B) ----
wire [31:0] alu_src2_pre;
MUX_3to1 #(.size(32)) MUX_ForwardB(
    .data0_i(IDEX_rt_data),
    .data1_i(wb_write_data),
    .data2_i(EXMEM_alu_result),
    .select_i(forward_b),
    .data_o(alu_src2_pre)
);

// ---- ALUSrc mux ----
MUX_2to1 #(.size(32)) MUX_ALUSrc(
    .data0_i(alu_src2_pre),
    .data1_i(IDEX_sign_ext),
    .select_i(IDEX_alu_src),
    .data_o(ex_alu_src2)
);
assign ex_alu_src1 = alu_src1_pre;

// ---- Shifter (若是 shift 指令) ----
Shifter SHFT(
    .data_i    (ex_alu_src2),
    .shamt     (IDEX_sign_ext[10:6]),
    .ctrl_i    (ex_alu_ctrl),
    .data_o    (ex_shifter_result)
);

// ---- 真正 ALU ----
ALU ALU(
    .src1_i  (ex_alu_src1),
    .src2_i  (ex_alu_src2),
    .ctrl_i  (ex_alu_ctrl),
    .result_o(ex_alu_result),
    .zero_o  (ex_zero)
);

// ---- ALU / Shifter result 選擇 ----
wire [31:0] ex_final_alu_result;
MUX_2to1 #(.size(32)) MUX_ShiftOrALU(
    .data0_i(ex_alu_result),
    .data1_i(ex_shifter_result),
    .select_i(IDEX_shift_content),
    .data_o(ex_final_alu_result)
);

// ---- EX/MEM pipeline latch ----
Pipe_Reg #(.size(32+32+32+5+8)) EX_MEM(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_i ({
               ex_final_alu_result,   // 32
               alu_src2_pre,          // 寫入 memory 的資料 (原 RT)
               id_branch_addr,          // 寫入暫存器的 index (RD)
               ex_dest_reg,           // 5
               /* control */
               IDEX_reg_write,        // 1
               IDEX_mem_to_reg,       // 2
               IDEX_mem_read,         // 1
               IDEX_mem_write,        // 1
               IDEX_branch,           // 2
               ex_zero               // 1
               //EXMEM_flush            // 1  (預先給一位佔位 flush 給下一級用)
              }),
    .data_o ({
               EXMEM_alu_result,
               EXMEM_rt_data,
               EXMEM_branch_addr,
               EXMEM_rd,
               EXMEM_reg_write,
               EXMEM_mem_to_reg,
               EXMEM_mem_read,
               EXMEM_mem_write,
               EXMEM_branch,
               EXMEM_zero
              }),
    .write(1'b1),
    .flush(EXMEM_flush)
);


//=====================================================================
//  MEM stage
//=====================================================================

// ---- Data memory ----
Data_Memory DM(
    .clk_i     (clk_i),
    .addr_i    (EXMEM_alu_result),
    .data_i    (EXMEM_rt_data),
    .MemRead_i (EXMEM_mem_read),
    .MemWrite_i(EXMEM_mem_write),
    .data_o    (mem_data_out)
);


wire [31:0] pc_branch_mux;
MUX_2to1 #(.size(32)) MUX_Branch(
    .data0_i(pc_plus4),
    .data1_i(EXMEM_branch_addr),
    .select_i(branch_taken),
    .data_o (pc_branch_mux)
);

MUX_2to1 #(.size(32)) MUX_Jump(
    .data0_i(pc_branch_mux),
    .data1_i({IFID_pc4[31:28], IFID_instr[25:0], 2'b00}),
    .select_i(1'b0),
    .data_o (pc_jump)
);

MUX_2to1 #(.size(32)) MUX_JumpReg(
    .data0_i(pc_jump),
    .data1_i(id_rs_data),
    .select_i(id_jump_reg),
    .data_o (pc_next)
);

// ---- MEM/WB pipeline latch ----
Pipe_Reg #(.size(32+32+5+1+2)) MEM_WB(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .data_i ({
               mem_data_out,          // 32
               EXMEM_alu_result,      // 32
               EXMEM_rd,              // 5
               EXMEM_reg_write,       // 1
               EXMEM_mem_to_reg       // 2
              }),
    .data_o ({
               MEMWB_mem_out,
               MEMWB_alu_out,
               MEMWB_rd,
               MEMWB_reg_write,
               MEMWB_mem_to_reg
              }),
    .write(1'b1),
    .flush(1'b0)
);


//=====================================================================
//  WB stage
//=====================================================================

MUX_3to1 #(.size(32)) MUX_MemToReg(
    .data0_i(MEMWB_alu_out),
    .data1_i(MEMWB_mem_out),
    .data2_i(IFID_pc4),          // JAL link addr
    .select_i(MEMWB_mem_to_reg),
    .data_o (wb_write_data)
);


//=====================================================================
//  End of module
//=====================================================================
endmodule
