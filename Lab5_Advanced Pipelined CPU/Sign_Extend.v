module Sign_Extend(
    data_i,
    data_o
    );
               
// TO DO
//I/O ports
input   [16-1:0] data_i;

output  [32-1:0] data_o;

//Internal Signals
reg     [32-1:0] data_o;
reg     [32-1:0] sign;

//Sign extended
always @(*) begin
    data_o[15:0] <= data_i;
    sign <= (data_i[15] == 1'b0)? 16'b0000000000000000:16'b1111111111111111;
    data_o[31:16] = sign;
end
          
endmodule        
     