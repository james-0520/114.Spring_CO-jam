module Shifter(
    data_i,
    shamt,
    ctrl_i,
    data_o
    );
               
//I/O ports
input  [32-1:0]  data_i;
input  [5-1:0]	 shamt;
input  [4-1:0]   ctrl_i;

output [32-1:0]  data_o;

//Internal Signals
reg     [32-1:0] data_o;

// Main function
/* your code here */
always @(*) begin
    case(ctrl_i)
        4'b0110:
        begin
            data_o <= data_i << shamt; // sll
        end 
        4'b0111:
        begin
            data_o <= data_i >> shamt; // srl
        end 
        
        default: data_o <= 0; 
    endcase
end
          
endmodule      
     