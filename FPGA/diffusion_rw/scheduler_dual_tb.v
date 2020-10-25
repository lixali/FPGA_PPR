module scheduler_dual_tb #(parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, lower_addr = 0, upper_addr = 4) ( 
	);

	reg clk;
	reg [ADDR_WIDTH-1:0] m1_address_s, m2_address_s;
	reg m1_write_enable_s, m2_write_enable_s;
	reg [DATA_WIDTH-1:0] mem1_data_in_s, m1_data_out_s, m2_data_out_s;

	wire [DATA_WIDTH-1:0] mem1_data_out_s, m1_data_in_s, m2_data_in_s;
	wire [ADDR_WIDTH-1:0] mem1_address_s;
	wire conflict_b1;

	integer i;

	scheduler_dual #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .lower_addr(lower_addr), .upper_addr(upper_addr)) scheduler1( 
	.clk(clk),
	.data_mem(mem1_data_in_s), // input from BRAM memory

	.addrA(m1_address_s),
	.addrB(m2_address_s),

	.dataA(m1_data_out_s),
	.dataB(m2_data_out_s),

	.write_enA(m1_write_enable_s),
	.write_enB(m2_write_enable_s),

	.data(mem1_data_out_s), // goes out to bram memory
	.addr(mem1_address_s), // addr goes out to bram memory
	.dataMA(m1_data_in_s), // goes out to verilog M module
	.dataMB(m2_data_in_s),


	.write_mem_enA(mem1_write_en),
	.write_mem_enB(mem2_write_en),


	.conflict_b(conflict_b1) //

	);



	initial begin 
		clk = 0;
		for(i=0; i< 100; i=i+1) begin
			# (period/2) clk = ~clk;
		end

	end

	initial begin
		m1_address_s = 1;
		m2_address_s = 100;
		
		# period;
		m2_address_s = 2;

		m1_write_enable_s = 0;
		m2_write_enable_s = 1;


		mem1_data_in_s = 10;


		# (period*1);
		m1_write_enable_s = 1;
		m2_write_enable_s = 0;	
		m1_data_out_s = 100;	

	end



endmodule