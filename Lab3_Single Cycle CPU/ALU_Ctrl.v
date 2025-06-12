module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o
        );
          
// I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;  
     
// Internal Signals
reg [4-1:0] tmp;
assign ALUCtrl_o = tmp;

parameter ADD_funct = 6'b100010;
parameter SUB_funct = 6'b100000;
parameter AND_funct = 6'b100101;
parameter OR_funct  = 6'b100100;
parameter NOR_funct = 6'b101010;
parameter SLT_funct = 6'b100111;
parameter SLL_funct = 6'b000000;
parameter SRL_funct = 6'b000010;
parameter SLLV_funct= 6'b000100;
parameter SRLV_funct= 6'b000110;
parameter JR_funct  = 6'b001000;

parameter ADD = 4'b0010;
parameter SUB = 4'b0110;
parameter AND = 4'b0000;
parameter OR  = 4'b0001;
parameter NOR = 4'b1100;
parameter SLT = 4'b0111;
parameter SLL = 4'b1000;
parameter SRL = 4'b1001;
parameter INVALID = 4'b1111;

// Main function
always @(*) begin
    case (ALUOp_i)
        2'b00:              tmp = ADD; // lw, sw, addi
        2'b01:              tmp = SUB; // beq
        2'b11:              tmp = SUB; // bne
        2'b10: begin // R-type
            case (funct_i)
                ADD_funct:  tmp = ADD;   // add
                SUB_funct:  tmp = SUB;   // sub
                AND_funct:  tmp = AND;   // and
                OR_funct:   tmp = OR;    // or
                NOR_funct:  tmp = NOR;   // nor
                SLT_funct:  tmp = SLT;   // slt
                SLL_funct:  tmp = SLL;   // sll
                SRL_funct:  tmp = SRL;   // srl
                SLLV_funct: tmp = SLL;  // sllv
                SRLV_funct: tmp = SRL;  // srlv
                default:    tmp = INVALID; // invalid
            endcase
        end
        default:            tmp = INVALID; // invalid ALUOp code
		
    endcase

end  

endmodule