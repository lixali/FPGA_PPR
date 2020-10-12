
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2020 12:47:28 AM
// Design Name: 
// Module Name: bram_random_walk_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module bram_random_walk_testbench();
 
   reg clk ;
   wire [31:0] data_out_test_pin;
   
bram_random_walk bram_random_walk_instance (

    .clk(clk),
    .data_out_test_pin(data_out_test_pin)

);
   initial begin
$monitor("value of clk = %b", clk);
      clk = 1'b0;
      
      /*
      forever begin
        #5;
        clk = ~clk;
      end
      */
      

   
   end

       always 
         #5 clk = ~clk;
  
   

endmodule


