
// _g is graph; _s is score
// node_offset is the number of nodes stored in the prior BRAM_score_table, it will be increasing 0, 10, 20 , 30, etc.
module diffusion_rw #(parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, nei_table_offset = 10, node_num = 10, node_offset = 0, max_steps = 7) ( 
	input conflict,
	input clk, 
	input [DATA_WIDTH-1:0] data_in_s,
	input [DATA_WIDTH-1:0] data_in_g,
	input [DATA_WIDTH-1:0] l_step,
	input rdy,

	output [DATA_WIDTH-1:0] data_out_s, // there is no data_out_g because this verilog module only read from BRAM_subgraph, never write into it; PS write the subgraph into BRAM_subgraph
	output [ADDR_WIDTH-1:0] address_g, 
	output [ADDR_WIDTH-1:0] address_s, 
	output write_enable_g,
	output write_enable_s,
	output finished //
	);
	
	integer node_count = 0;
	reg read_prev_score = 1'b1, finished_flag = 1'b0;
	reg read_nei_addr, read_nei, read_nei_score, write_nei_score;
	reg [DATA_WIDTH-1:0] curr_addr_s = 0, data_out_reg_s, degree, node_prev_score, node=1, nei_node, nei_node_score;
	reg [ADDR_WIDTH-1:0] address_reg_s, address_reg_g, first_neighbour_address, last_neighbour_address, nei_addr_now;
	reg write_enable_reg_s, write_enable_reg_g;

	assign address_s = (rdy == 1'b1)?  address_reg_s : {(ADDR_WIDTH){1'bz}};
	assign address_g = (rdy == 1'b1)?  address_reg_g : {(ADDR_WIDTH){1'bz}};
	assign data_out_s = (rdy == 1'b1)? data_out_reg_s: {(DATA_WIDTH){1'bz}};
	assign write_enable_s = (rdy == 1'b1)? write_enable_reg_s: {1'bz};
	assign write_enable_g = (rdy == 1'b1)? write_enable_reg_g: {1'bz};
	assign finished = (finished_flag == 1'b1)? 1'b1: {1'b0};
	
	
	always @(negedge clk) begin // start at the negative edge		
			
		if (l_step < max_steps && rdy == 1'b1 && conflict == 1'b0) begin
			if(read_prev_score == 1'b1 && clk == 1'b0) begin //
				if (node_count == 0) begin
					finished_flag = 1'b0; // the the beginning of the run, finished should be set to 0
				end 
				if (l_step % 2 == 0) begin		// address_reg_s needs to take "node_offset" into account because it is reading BRAM_score_table and it needs to go through scheduler				
					address_reg_s = (node-1+node_offset)*2; // node-1 because node start with 1; addrress_reg_s start with 0, the address_reg_s is alternating between "node*2" and "node*2+1" because prev score position is alternating
				end else begin
					address_reg_s = (node-1+node_offset)*2 + 1; 
				end 
				write_enable_reg_s = 1'b0;						
				address_reg_g = (node-1) * 2; // now address_reg_g is the address of first neighbour address 
				write_enable_reg_g = 1'b0;
				#(period *0.7) node_prev_score <= data_in_s; // period * 0.7 delay to read out current node prev score
				first_neighbour_address = data_in_g; // also read out current node's first neighbour address
				read_prev_score = 1'b0; 
				read_nei_addr = 1'b1;
				node = node + 1;         
			end else if (read_nei_addr == 1'b1 && clk == 1'b0) begin
				address_reg_g = (node-1) * 2 + 1'b1; // now address_reg_g is the address of last neighbour address 
				write_enable_reg_g = 1'b0;
				#(period *0.7) last_neighbour_address = data_in_g; // read out current node's last neighbour address 						
				degree = last_neighbour_address-first_neighbour_address+1;
				nei_addr_now = first_neighbour_address;
				read_nei_addr = 1'b0;
				read_nei = 1'b1;
			end else if (read_nei == 1'b1 && clk == 1'b0) begin
				write_enable_reg_g = 1'b0;
				address_reg_g = nei_addr_now;
				read_nei = 1'b0;
				read_nei_score = 1'b1;
				#(period*0.7) nei_node = data_in_g; // read out neighbour node                                    
			end else if (read_nei_score == 1'b1 && clk == 1'b0) begin	
				write_enable_reg_s = 1'b0;
				if (l_step % 2 == 0) begin		// address_reg_s needs to take "node_offset" into account 			
					address_reg_s = (node-1+node_offset)*2 + 1; // address_reg_s is alternating between "node*2+1" and "node*2" because latest score position is alternating
				end else begin
					address_reg_s = (node-1+node_offset)*2; 
				end
				#(period*0.7) nei_node_score = data_in_s; // read out the neighbour node's latest score			
				read_nei_score = 1'b0;
				write_nei_score = 1'b1;
			end else if (write_nei_score == 1'b1 && clk == 1'b0) begin
				write_enable_reg_s = 1'b1;
				// there is no need to set "address_reg_s" here , because it is the same address is previous read
				nei_node_score = nei_node_score + node_prev_score/degree; // s2 = s2+s1/degree; s1 is node's previous score, s2 is neighbour node's latest score
				data_out_reg_s = nei_node_score; // write the neighbour node updated score value to BRAM
				write_nei_score = 1'b0;
				if (nei_addr_now < last_neighbour_address) begin
					nei_addr_now = nei_addr_now + 1;
					read_nei = 1'b1;
				end else if (nei_addr_now == last_neighbour_address && node_count < node_num) begin
					node_count = node_count + 1;  
					read_prev_score = 1'b1;
					read_nei_score = 1'b0; // this line can be removed, it is redundant
				end
				
				if(nei_addr_now == last_neighbour_address &&  node_count == node_num) begin
					node_count = 0;
					node = 1; // node starts with 1
					finished_flag = 1'b1;
				end     
			end 	
		end

	end
	
endmodule
