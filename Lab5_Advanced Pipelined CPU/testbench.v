`timescale 1ns / 1ps

`define CYCLE_TIME 5		
`include "Pipe_CPU_PRO.v"
module TestBench;

// Internal Signals
reg         CLK;
reg         RST;
reg         halt_flag;
reg         halt_delay;
reg         halt;
integer     error_count;
integer     count;
integer     i;


reg [32-1:0] correct [0:64-1];

// Greate tested modle  
Pipe_CPU_PRO CPU(
    .clk_i(CLK),
    .rst_i(RST)
    );
 
// Main function

always #(`CYCLE_TIME/2) CLK = ~CLK;	

initial begin
    CLK = 0;
    RST = 0;
    count = 0;
    halt_flag = 0;
    halt_delay = 0;
    halt = 0;
    error_count = 0;
   
    // Initialize instruction memory
    for(i=0; i<32; i=i+1)
    begin
        CPU.IM.instruction_file[i] = 32'b0;
    end

    $readmemb("./testcase/lab5_test.txt", CPU.IM.instruction_file); 
    $readmemh("./testcase/lab5_test_correct.txt", correct); 
    $dumpfile("lab5.vcd");
        $dumpvars;

    // Initialize data memory
    for(i=0; i<128; i=i+1)
    begin
        CPU.DM.Mem[i] = 8'b0;
    end
    
    #(`CYCLE_TIME)      RST = 1;
    #(`CYCLE_TIME*200)   $finish;
end

always@(posedge CLK) begin
    if (CPU.IM.instr_o == 32'hFFFFFFFF) begin
        halt_flag <= 1;
        halt_delay <= 5;
    end

    if (halt_flag && halt_delay > 0) begin
        halt_delay <= halt_delay - 1;
    end
    
    if (halt_flag && halt_delay == 0) begin
        halt <= 1; 
    end

    if (halt) begin

        for (i = 0; i < 32; i = i + 1) begin
            if (CPU.DM.memory[i] !== correct[i]) begin
                $display("***************************************************");
                $display("* Memory Error! [Memory %2d]                       *", i);
                $display("* Correct result: %h                        *", correct[i]);
                $display("* Your result:    %h                        *", CPU.DM.memory[i]);
                $display("***************************************************");
                error_count = error_count + 1;
            end
        end

        for (i = 32; i < 64; i = i + 1) begin
            if (CPU.RF.Reg_File[i-32] !== correct[i]) begin
                $display("***************************************************");
                $display("* Register Error! [Register %2d]                   *", i-32);
                $display("* Correct result: %h                        *", correct[i]);
                $display("* Your result:    %h                        *", CPU.RF.Reg_File[i-32]);
                $display("***************************************************");
                error_count = error_count + 1;
            end
        end

        if (error_count == 0) begin
            $display("***************************************************");
            $display("*           Congratulation. ALL PASS !            *");
            $display("***************************************************");
        end
        else begin
            $display("***************************************************");
            $display("*               You have %2d error !              *", error_count);
            $display("***************************************************");
        end

        $finish;
    end
	count = count + 1;
end
  
endmodule