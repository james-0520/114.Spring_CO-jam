module MUX_3to1(
               data0_i,
               data1_i,
               data2_i,
               select_i,
               data_o
               );

parameter size = 0;
			
// I/O ports               
input   [size-1:0] data0_i;          
input   [size-1:0] data1_i;
input   [size-1:0] data2_i;
input   [2-1:0]    select_i;

output  [size-1:0] data_o; 

// Internal Signals
reg [size-1:0] tmp;
assign data_o = tmp;

// Main function
always@(*)begin
    case(select_i)
        2'b00: tmp = data0_i;
        2'b01: tmp = data1_i;
        2'b10: tmp = data2_i;
        2'b01: tmp = 32'b0;
    endcase
end

endmodule      
          
          
          
          