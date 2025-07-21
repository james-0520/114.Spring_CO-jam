module Shift_Left_Two_32(
    data_i,
    data_o
    );

//I/O ports                    
input [32-1:0] data_i;

output [32-1:0] data_o;

//shift left 2
reg [32-1:0] data_o;
always @(*) begin
    data_o[31:2] <= data_i[29:0];
    data_o[1:0] <= 2'b0;
end
     
endmodule
