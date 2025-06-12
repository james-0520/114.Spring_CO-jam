module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o,
          shift_content
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;
output     shift_content;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;
reg        shift_content;

// Main function
/* your code here */
always @(*) begin
    // Default
    ALUCtrl_o = 4'b1111;
    shift_content = 1'b0;

    case (ALUOp_i)
        2'b10: begin
            case (funct_i)
                6'b100010: ALUCtrl_o = 4'b0000; // add
                6'b100000: ALUCtrl_o = 4'b0001; // sub
                6'b100101: ALUCtrl_o = 4'b0010; // and
                6'b100100: ALUCtrl_o = 4'b0011; // or
                6'b101010: ALUCtrl_o = 4'b0100; // nor
                6'b100111: ALUCtrl_o = 4'b0101; // slt
                6'b000000: begin ALUCtrl_o = 4'b0110; shift_content = 1'b1; end // sll
                6'b000010: begin ALUCtrl_o = 4'b0111; shift_content = 1'b1; end // srl
                6'b000100: begin ALUCtrl_o = 4'b1000; shift_content = 1'b0; end // sllv
                6'b000110: begin ALUCtrl_o = 4'b1001; shift_content = 1'b0; end // srlv
                6'b001000: ALUCtrl_o = 4'b1000; // jr
            endcase
        end
        2'b00: ALUCtrl_o = 4'b0000; // addi, lw, sw
        2'b01: ALUCtrl_o = 4'b0001; // beq
    endcase
end  

endmodule