// period, seed node number, number of random walks, number of steps are all pre-defined as parameters here
// nei_addr_table_offset value is determined by number of seed nodes; nei_table_offset is determined by number of number of seeds nodes plus number of nodes in the dictionary * 2 (* 2 because of first and last neighbour's address) ,
// counter_table_offset is determined by number of seeds nodes plus number of nodes in the dictionary * 2 plus nei_table size; The following number are just picked for testing purpose for now
// cyles means the number of clock cycles that are needed to go through all states in the Finite State Machines(FSM) once 
module bram_random_walk #(parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, 
                        DEPTH = 8192, nei_addr_table_offset = 10, nei_table_offset = 100, 
                        counter_table_offset = 1000, seed_num = 10, m_rw = 100,
                        max_steps = 6, node_num = 100, cycles = 9) ( // these parameter can be changed later if needed
    input ready, // if ready is 1'b1, this module will start reading/writing BRAM; 
    input clk, // clk is from PS, 
    output [31:0] data_out,
	output [12:0] address, // 8K BRAM block
	output write_enable, // if write_enable is 1'b1, it is write-ready; If it is 1'b0, it is read-ready
	input [31:0] data_in,
	input lfsr_reset // at the beginning, lfsr_reset needs to be 1'b1 in order to make lfsr initial value to be 32'b111
    );
    
    reg  write_enable_reg;
    reg [DATA_WIDTH-1:0] data_out_reg;
    
    wire inner_clk, step_clk, rw_clk;  // 3 divided clocks
    reg inner_clk_prev = 1'b0, step_clk_prev = 1'b0, rw_clk_prev = 1'b0;
	reg oper_flag = 1'b0;
	reg [ADDR_WIDTH-1:0] address_reg=13'h0000;
    reg [ADDR_WIDTH-1:0] z, y; // z is the address of counter for each node (at different steps with different starting nodes; y is intermediate variable to calculate z) 
    reg [DATA_WIDTH-1:0] steps, curr_node, start_node, curr_counter = 32'h0;
    reg [DATA_WIDTH-1:0] first_neighbour_address, last_neighbour_address, next_node;
    wire [DATA_WIDTH-1:0] counter_randomness; // output of linear feeback shift register
	integer i, rw_count = 0, seed_count = 0, read_write_count = 0;
    integer curr_m_rw = 0; // current number of random walks, ranging from 1 to maximum random walks (m_rw)
    integer steps_count = 0; // current steps count, ranging from 0 to maximum steps - 1 (max_steps-1)
    reg [DATA_WIDTH-1:0] clk_div1 = 32'h00000001 * cycles, clk_div2 = 32'h00000001 * max_steps * cycles, clk_div3 = 32'h00000001*max_steps * m_rw * cycles;
	integer rw_flag=0, steps_flag=0, inner_flag=0;


	assign address = (ready == 1'b1)?  address_reg : {(ADDR_WIDTH){1'bz}};
	assign data_out = (ready == 1'b1)? data_out_reg: {(DATA_WIDTH){1'bz}};
	assign write_enable = (ready == 1'b1)? write_enable_reg: {1'bz};
	
    // clock divider for to generate inner_clk, inner_clk is a clock that increment steps_count
    clock_divider clk_divier1( 
        .clk(clk),
		.arst(1'b0),
        .div_num(clk_div1),
        .clk_div(inner_clk)
    );

    // clock divider for to generate steps_clk, step_clk is a clock that reset steps_count back to 0
    clock_divider clk_divier2(
        .clk(clk),
		.arst(1'b0),
        .div_num(clk_div2),
        .clk_div(step_clk)
    );

    // clock divider for to generate rw_clk, step_clk is a clock that reset curr_m_rw back to 1
    clock_divider clk_divier3(
        .clk(clk),
		.arst(1'b0),
        .div_num(clk_div3),
        .clk_div(rw_clk)
    );

    lfsr lfsr_ins1( // instantiation of linear feedback shift register to generate random number
    .clk(clk),
    .reset(lfsr_reset),    // Active-high synchronous reset to 32'h111; only set it high at the beginning of test bench and then remain low the whole time
    .q(counter_randomness)
	); 

    always @(posedge clk) begin // these 3 _prev variables are used to detect the rising edge of step_clk, rw_clk and inner_clk
        #(period) step_clk_prev = step_clk; // these 3 _prev variable are used in the following always block
        rw_clk_prev = rw_clk;
		inner_clk_prev = inner_clk;
    end

    always @(negedge clk) begin // start at the negative edge
		
		if(rw_flag == 0 && (rw_clk_prev != rw_clk && rw_clk == 1'b1)) begin // check if it is rising edge of rw_clk
			rw_flag = 1;
			read_write_count = 0;
		end
		
		if(steps_flag == 0 && (step_clk_prev != step_clk && step_clk == 1'b1)) begin // check if it is rising edge of steps_clk
			steps_flag = 1;
		end		
		
		if(inner_flag == 0 && (inner_clk_prev != inner_clk && inner_clk == 1'b1)) begin // check if it is rising edge of inner_clk
			inner_flag = 1;
		end				
		
	
        if (seed_count < seed_num) begin
		
			if (rw_flag == 1 && clk == 1'b0) begin
				seed_count <= seed_count+1;
				curr_m_rw <= 1;
			end 
			
            if (curr_m_rw <= m_rw) begin
			
				if (read_write_count == 0 && steps_flag == 1 && clk == 1'b0) begin
					steps_count = 0;
					curr_m_rw = curr_m_rw+1;
				end
				
                if (steps_count < max_steps) begin
                    if(read_write_count == 0 && rw_flag == 1 && clk == 1'b0) begin // this cycle reads the seed node (which is also the start node)
						address_reg <= seed_count; 
						write_enable_reg <= 1'b0;						
						#(period *0.7) start_node <= data_in; // period * 0.7 delay to read out start_node ( or seed_node)
						rw_flag <= 0;
					end else if (read_write_count == 1 && steps_flag == 1 && clk == 1'b0) begin
						curr_node = start_node;  
						steps_flag = 0;                        
					end else if (read_write_count == 2 && inner_flag == 1 && clk == 1'b0) begin
						steps_count = steps_count + 1;
						inner_flag = 0;                            
					end else if (read_write_count == 3 && inner_flag == 0 && clk == 1'b0) begin
                        write_enable_reg = 1'b0;
                        y = (start_node - 1) * max_steps + steps_count;  // y = (start_node-1) * max_steps + curr_steps
                        z = curr_node*(max_steps*node_num) + y + counter_table_offset; // z = x * col + y + counter_table_offset; col is (number of nodes in subgraph * max_steps)
                        address_reg = z; // z is the address of counter for each node (at different steps with different starting nodes)
                        #(period*0.7) curr_counter = data_in;	 // read the counter value from BRAM			
					end else if (read_write_count == 4 && inner_flag == 0 && clk == 1'b0) begin
                        write_enable_reg = 1'b0;
                        address_reg = curr_node*2 + nei_addr_table_offset;
                        #(period*0.7) first_neighbour_address = data_in; // read out the address of curr_node's first neighbour					
					end else if (read_write_count == 5 && inner_flag == 0 && clk == 1'b0) begin	
                        write_enable_reg = 1'b0;
                        address_reg = curr_node*2 + 1'b1 + nei_addr_table_offset;
                        #(period*0.7) last_neighbour_address = data_in; // read out the address_reg of curr_node's last neighbour					
					end else if (read_write_count == 6 && inner_flag == 0 && clk == 1'b0) begin
                        write_enable_reg = 1'b0;
                        address_reg = (counter_randomness % (last_neighbour_address-first_neighbour_address+1)) + first_neighbour_address; // randomly pick the one of neighbour's address
                        #(period*0.7) next_node = data_in; // read out next node
                        curr_node = next_node;
					end else if (read_write_count == 7 && inner_flag == 0 && clk == 1'b0) begin
                        write_enable_reg = 1'b1;
						address_reg = z; // address is z updating the counter value
                        curr_counter = curr_counter+1; // counter value +=1
                        data_out_reg = curr_counter; // write the counter value to BRAM
					end else if (read_write_count == 8 && inner_flag == 0 && clk == 1'b0) begin
						oper_flag = 1'b0;
					end 	
                end
            end
			read_write_count = read_write_count + 1;

        end
		if(read_write_count == 9) begin
			read_write_count = 0;
		end

	end

endmodule
