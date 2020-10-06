
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
   parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, DEPTH = 8192;
   reg clk;
   wire clk_random_walk;
   wire [12:0] address;
   reg [12:0] address_reg;
   wire [31:0] data_in, data_out;
   reg [31:0] data_in_reg, data_out_reg;
   wire write_enable;
   reg write_enable_reg;
   integer i,j;
   reg mask = 1'b0;
   reg initialize = 1'b1, ready;

   initial begin
	$monitor("value of clk = %b", clk);
	
    clk = 1'b1;
	data_in_reg = 32'h00000000;
    #(period/2) address_reg = 13'h0000;
	  
	for (i=0;i<8192; i=i+1) begin
		    #(period*2) address_reg = address_reg +1'b1; // address adds 1 every 2 periods because write and read will access the same address
            //address <= address_reg;
			data_in_reg = data_in_reg+1'b1; 
			//data_in = data_in_reg;
	
	end
      

   
   end
   
    initial begin
        #(period/2) write_enable_reg = 1; // offset 90 degree
        for (j=0; j< 8192; j = j+1) begin
            #(period) write_enable_reg = ~write_enable_reg; // write enable signal period is 2x of clock's because there will be 1 write and 1 read
			//write_enable = write_enable_reg;
	    end        
    end   
	
	initial begin
		#(period * 17000) mask = 1'b1;
	
	end

    always begin
        #(period/2) clk = ~clk;
		ready = 1'b1 & mask;
	end
		 
    assign clk_random_walk = clk & mask;
	assign data_in = (ready == 1'b0)? data_in_reg : {(DATA_WIDTH){1'bz}};
	//assign data_out = (ready == 1'b0)? data_out_reg : {(DATA_WIDTH){1'bz}};
	assign write_enable = (ready == 1'b0)? write_enable_reg : {1'bz};
	assign address = (ready == 1'b0)? address_reg : {(ADDR_WIDTH){1'bz}};
	
	bram_random_walk bram_random_walk_instance (
        .ready(ready),
		.clk(clk_random_walk),
		//.data_out_test_pin(data_out_test_pin),
		.data_out(data_in),
		.address(address),
		.write_enable(write_enable),
		.data_in(data_out)
	);  

    bram bram_test (
        .i_clk(clk), // bram operate at the rising edge of the clk
        .i_addr(address),
        .i_write(write_enable), // 1'b1 is write operation; 1'b0 is read opeartion
        .i_data(data_in),
        .o_data(data_out)); 

endmodule


