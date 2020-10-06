//test commet added
module bram_random_walk(
	input ready,
    input clk, // clk is from PS, 
	//output [31:0] data_out_test_pin,
    output [31:0] data_out,
	output [12:0] address,
	output write_enable,
	input [31:0] data_in
    );
    parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, DEPTH = 8192, nei_addr_table_offset = 10, nei_table_offset = 100, score_table_offset = 1000;
    parameter alpha = 1, seed_num = 10, m_rw = 100, max_steps = 7, node_num = 100; // hyper parameters for the random walk
    
    reg  write_enable_reg;
    reg [DATA_WIDTH-1:0] data_out_reg;
    //wire [DATA_WIDTH-1:0] data_out;
    // nei_addr_table_offset value is determined by number of seed nodes; nei_table_offset is determined by number of number of seeds nodes plus number of nodes in the dictionary * 2 (* 2 because of first and last neighbour's address) ,
    // score_table_offset is determined by number of seeds nodes plus number of nodes in the dictionary * 2 plus nei_table size; The following number are just picked for testing purpose for now
    wire counter_node_operation_clk, step_clk, rw_clk;
    //wire seed_clk,
    reg step_clk_prev, rw_clk_prev;
	reg oper_flag = 1'b0;
    reg [ADDR_WIDTH-1:0] address_reg=13'h0000, z;
    reg [DATA_WIDTH-1:0] steps, steps_s, curr_node, start_node, curr_counter = 32'h0, counter_randomness = 32'h0, start_node_degree, curr_node_degree , self_degree;
    reg [DATA_WIDTH-1:0] y, first_neighbour_address, last_neighbour_address, first_neighbour_address_d, last_neighbour_address_d, next_node;
    integer i, rw_count = 0, seed_count = 0, read_count = 0;
    integer get_degree_counter = 0, operation_count_d=0, curr_m_rw = 0;
    integer steps_count = 0, steps_count_s = 0;//integer score_table_size =
    reg [DATA_WIDTH-1:0] curr_node_s = 32'h00000001, curr_node_d = 32'h00000001;
    reg [DATA_WIDTH-1:0] start_node_s = 32'h00000001;

    reg [DATA_WIDTH-1:0] clk_div1 = 32'h00000001 * 5, clk_div2 = 32'h00000001 * max_steps * 5, clk_div3 = 32'h00000001*max_steps * m_rw * 5;
    //reg o_clk1, o_clk2, o_clk3, o_clk4, o_clk5, o_clk6;


	assign address = (ready == 1'b1)?  address_reg : {(ADDR_WIDTH){1'bz}};
	assign data_out = (ready == 1'b1)? data_out_reg: {(DATA_WIDTH){1'bz}};
	assign write_enable = (ready == 1'b1)? write_enable_reg: {1'bz};
	
    clock_divider clk_divier1(
        .clk(clk),
        .clk_div(clk_div1),
        .o_clk(counter_node_operation_clk)
    );

    clock_divider clk_divier2(
        .clk(clk),
        .clk_div(clk_div2),
        .o_clk(step_clk)
    );

    clock_divider clk_divier3(
        .clk(clk),
        .clk_div(clk_div3),
        .o_clk(rw_clk)
    );




    always @(posedge clk) begin
        #(period/2) step_clk_prev = step_clk; // a period/2 delay to make sure that _clk and _clk_prev are different and it can be used to detect rising edge
        rw_clk_prev = rw_clk;
    end

    /////// using 3 clocks to update parameters for the counter values starts here ///////
    always @(posedge counter_node_operation_clk) begin
        if ((step_clk_prev == step_clk) || (step_clk_prev != step_clk && step_clk == 1'b0)) begin // take effect except step_clk rising edge (so skip to next rising of counter_node_operation_clk)
            steps_count = steps_count + 1'b1;
            counter_randomness = counter_randomness + 1'b1;
			oper_flag = 1'b1;
        end 
    end

    always @(posedge step_clk) begin
        //if (((rw_clk_prev == rw_clk) || (rw_clk_prev != rw_clk && rw_clk == 1'b0))) begin // step_clk rising edge take effect
		#(period/2) curr_node = start_node; // period/2 delay to assign start_node to curr_node, because of period/3 delay to read out start_node from data_out port 
        if (oper_flag == 1'b1 && ((rw_clk_prev == rw_clk) || (rw_clk_prev != rw_clk && rw_clk == 1'b0))) begin   
			steps_count = 0;
            curr_m_rw = curr_m_rw+1;
        end
    end
    // ??? double check in waveform
    always @(posedge rw_clk) begin // double check in here. Rationale is that because there is a read operation in here, it operation at nogative edge
		if (oper_flag == 1'b0 || oper_flag == 1'b1) begin
		address_reg = seed_count;
		oper_flag = 1'b0;
		write_enable_reg = 1'b0;
		#(period/3) start_node = data_in; // read out the start node, period/3 delay (careful about place and route delay ) is to insure that the data at port data_out is correct.... 
		curr_m_rw = 1;
		seed_count = seed_count+1;
		end
    end
    /////// using 3 clocks to update parameters for the counter values ends here ///////


    always @(negedge clk) begin // start at the negative edge
        if (seed_count < seed_num && oper_flag == 1'b1) begin
            if (curr_m_rw <= m_rw) begin
                if (steps_count < max_steps) begin
                    if(read_count == 0) begin
                        write_enable_reg = 1'b0;
                        y = (start_node - 1) * max_steps + steps_count;  // there is a read cycle here, data_in is the seed_
                        z = curr_node*(max_steps*node_num) + y + nei_table_offset; // double check if this adddress offset is correct?
                        address_reg = z;
                        read_count = read_count+1;
                        #(period) curr_counter = data_in; // read the counter value
                    end else if (read_count == 1) begin
                        write_enable_reg = 1'b0;
                        address_reg = curr_node*2 + nei_addr_table_offset;
                        read_count = read_count+1;
                        #(period) first_neighbour_address = data_in; // read out the address of curr_node's first neighbour
                    end else if (read_count == 2) begin
                        write_enable_reg = 1'b0;
                        address_reg = curr_node*2 + 1'b1 + nei_addr_table_offset;
                        read_count = read_count+1;
                        #(period/10 * 8) last_neighbour_address = data_in; // read out the address_reg of curr_node's last neighbour
                    end else if (read_count == 3) begin
                        write_enable_reg = 1'b0;
                        address_reg = (counter_randomness % (last_neighbour_address-first_neighbour_address+1)) + first_neighbour_address; // randomly pick the one of neighbour's address
                        read_count = read_count+1;
                        //write_enable_reg = ~write_enable_reg;
                        #(period) next_node = data_in; // read out next node
                        curr_node = next_node;
                    end else if (read_count == 4) begin
                        write_enable_reg = 1'b1;
						address_reg = z; // address is still z for updating the counter value
                        read_count = 0; // reset
                        curr_counter = curr_counter+1; // counter value +=1
                        data_out_reg = curr_counter; // write the counter value to BRAM
                    end
					
                end
            end
        end 
	end

endmodule
