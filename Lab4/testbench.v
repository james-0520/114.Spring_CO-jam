`timescale 1ns / 1ps

`define CYCLE_TIME 5	
`define MAX_COUNT 17	
`include "Pipe_CPU.v"
module TestBench;

//Internal Signals
reg         CLK;
reg         RST;
reg         halt_flag;
integer     error_count;
integer     count;
integer     i;
//integer     handle;

reg [32-1:0] correct [0:64];

//Greate tested modle  
Pipe_CPU cpu(
    .clk_i(CLK),
    .rst_i(RST)
    );
 
//Main function

always #(`CYCLE_TIME/2) CLK = ~CLK;	

initial begin
    //handle = $fopen("P4_Result.dat");
    CLK = 0;
    RST = 0;
    count = 0;
    halt_flag = 0;
    error_count = 0;
   
    // instruction memory
    for(i=0; i<32; i=i+1)
    begin
        cpu.IM.instruction_file[i] = 32'b0;
    end

    $readmemb("./testcase/lab4_test.txt", cpu.IM.instruction_file); 
    $readmemh("./testcase/lab4_test_correct.txt", correct); 


    // data memory
    for(i=0; i<128; i=i+1)
    begin
        cpu.DM.Mem[i] = 8'b0;
    end
    
    #(`CYCLE_TIME)      RST = 1;
    #(`CYCLE_TIME*200)   $finish;
    //#(`CYCLE_TIME*20)	$fclose(handle); $stop;
end

//Print result to "CO_P4_Result.dat"
always@(posedge CLK) begin
    if (cpu.IM.instr_o == 32'hFFFFFFFF) begin
        halt_flag <= 1;
    end

    if (halt_flag) begin

        for (i = 0; i < 32; i = i + 1) begin
            if (cpu.DM.memory[i] !== correct[i]) begin
                $display("***************************************************");
                $display("* Memory Error! [Memory %2d]                       *", i);
                $display("* Correct result: %h                        *", correct[i]);
                $display("* Your result:    %h                        *", cpu.DM.memory[i]);
                $display("***************************************************");
                error_count = error_count + 1;
            end
        end

        for (i = 32; i < 64; i = i + 1) begin
            if (cpu.RF.Reg_File[i-32] !== correct[i]) begin
                $display("***************************************************");
                $display("* Register Error! [Register %2d]                   *", i-32);
                $display("* Correct result: %h                        *", correct[i]);
                $display("* Your result:    %h                        *", cpu.RF.Reg_File[i-32]);
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