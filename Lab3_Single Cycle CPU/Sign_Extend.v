module Sign_Extend(
    data_i,
    data_o
    );
               
// I/O ports
input   [16-1:0] data_i;

output  [32-1:0] data_o;

// Internal Signals
reg [32-1:0] tmp;
assign data_o = tmp;

// Main function
always @(*) begin
    tmp[15:0] = data_i; // Assign the lower 16 bits
    tmp[31:16] = (data_i[15] == 1'b1) ? 16'hFFFF : 16'h0000; // Sign extend
end
          
endmodule      
     