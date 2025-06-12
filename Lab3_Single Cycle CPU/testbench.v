`timescale 1ns / 1ps
`include "Simple_Single_CPU.v"
`define CYCLE_TIME 5

module testbench;
    reg Clk, Start;
    reg halt_flag;
    integer error_count;
    integer i;

    reg [31:0] correct [0:64];

    Simple_Single_CPU CPU(Clk, Start);

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);
        Clk = 0;
        Start = 0;
        halt_flag = 0;
        error_count = 0;

        $readmemb("testcase/CO_P3_test_data.txt", CPU.IM.Instr_Mem);
        $readmemh("testcase/CO_P3_test_correct_data.txt", correct);

        #(`CYCLE_TIME) Start = 1;
        #(`CYCLE_TIME * 200) $stop;
    end

    always@(posedge Clk) begin
        
        if (halt_flag) begin
            if (CPU.PC.pc_out_o !== correct[0]) begin
                $display("***************************************************");
                $display("* PC Error!                                       *");
                $display("* Correct result: %h                        *", correct[0]);
                $display("* Your result:    %h                        *", CPU.PC.pc_out_o);
                $display("***************************************************");
                error_count = 1;
            end

            for (i = 1; i < 33; i = i + 1) begin
                if (CPU.Data_Memory.memory[i-1] !== correct[i]) begin
                    $display("***************************************************");
                    $display("* Memory Error! [Memory %2d]                       *", i-1);
                    $display("* Correct result: %h                        *", correct[i]);
                    $display("* Your result:    %h                        *", CPU.Data_Memory.memory[i-1]);
                    $display("***************************************************");
                    error_count = error_count + 1;
                end
            end

            for (i = 33; i < 65; i = i + 1) begin
                if (CPU.Registers.REGISTER_BANK[i-33] !== correct[i]) begin
                    $display("***************************************************");
                    $display("* Register Error! [Register %2d]                   *", i-33);
                    $display("* Correct result: %h                        *", correct[i]);
                    $display("* Your result:    %h                        *", CPU.Registers.REGISTER_BANK[i-33]);
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

        if (CPU.IM.instr_o === 32'hFFFFFFFF) begin
            halt_flag <= 1;
        end
    end

    always #(`CYCLE_TIME / 2) Clk = ~Clk;

endmodule
