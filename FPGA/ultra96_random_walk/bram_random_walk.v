`timescale 1ns / 1ps

module bram_random_walk(
    input reg clk, write_enable, 
    input reg [DATA_WIDTH-1:0] data_in;
    output reg [DATA_WIDTH-1:0] data_out;
);
    parameter ADDR_WIDTH = 13, DATA_WIDTH = 32, DEPTH = 8192, seed_offset = 10, nei_table_offset = 30, score_table_offset = 100;
    parameter alpha = 1, seed_num = 10, m_rw = 100, max_steps = 7, node_num = 100; // hyper parameters for the random walk

    reg step_clk, rw_clk, seed_clk;
    reg [ADDR_WIDTH-1:0] address, z;
    reg [DATA_WIDTH-1:0] steps, steps_s, curr_node, counter_randomness, curr_score_s, start_node_degree, self_degree;
    wire [DATA_WIDTH-1:0] y;
    integer i, rw_count, seed_count, read_count;
    integer get_degree_counter = 0; 
    integer steps_count_s = 0;
    integer score_table_size = 
    reg [DATA_WIDTH-1:0] curr_node_s = 8'h00000001;
    reg [DATA_WIDTH-1:0] start_node_s = 8'h00000001;

    always begin
        #(period/2) clk = ~clk;  // timescale is 1ns so #5 provides 100MHz clock
        counter_randomness = counter_randomness + 1'b1;
    end

    always begin
        #(period/2 * max_steps) step_clk = ~step_clk;  // timescale is 1ns so #5 provides 100MHz clock
        rw_count += 1;
        counter_randomness = counter_randomness + 1'b1;

    end

    always begin
        #(period/2 * max_steps * m_rw) rw_clk = ~rw_clk;  // timescale is 1ns so #5 provides 100MHz clock
        counter_randomness = counter_randomness + 1'b1;

    end

    always @(negedge rw_clk) begin // start at the negative edge
        #(period) start_node = data_out;
        seed_count += 1;
    end 

    always @(posedge step_clk) begin 
        curr_node = start_node;
        steps = steps + 1'b1;
    end 


    always @(negedge clk) begin // start at the negative edge
        if (seed_count < seed_num) begin
            y = (start_node - 1) * max_steps + steps  // there is a read cycle here, data_out is the seed_ 
            z = curr_node*(max_steps*node_num) + y + nei_table_offset; // double check if this adddress offset is correct?
            if(write_enable == 0 and read_count == 0) begin
                address = z;
                read_count += 1;
                #(period) curr_counter = data_out; // read the counter value    
            end else if (write_enable == 0 and read_count == 1) begin
                address = curr_node*2 + seed_offset;
                read_count += 1;
                #(period) first_neighbour_address = data_out; // read out the address of curr_node's first neighbour
            end else if (write_enable == 0 and read_count == 2) begin
                address = curr_node*2 + 1'b1 + seed_offset;
                read_count += 1;
                #(period) last_neighbour_address = data_out; // read out the address of curr_node's last neighbour            
            end else if (write_enable == 0 and read_count == 3) begin
                address = (counter_randomness % (last_neighbour_address-first_neighbour_address)) + first_neighbour_address; // randomly pick the one of neighbour's address
                read_count += 1;
                write_enable = ~write_enable;
                #(period) next_node = data_out; // read out next node    
                curr_node = next_node;       
            end else if (write_enable == 1 or read_count > 3) begin
                read_count = 0 // reset
                curr_counter += 1; // counter value +=1 
                write_enable = 1'b1;
                data_in = curr_counter; // write the counter value to BRAM
            
            end
        // the following loop will be calculating the score value and write into BRAM;
        // the _s naming in the following loop means that it is for calculating the score table (for the purpose of distinguish from the above variable naming)
        end else if (seed_count >= seed_num )begin 
            if (curr_node_s <= node_num) begin
                if (steps_count_s < max_steps) begin
                    if (start_node_s <= node_num) begin
                        // the following first 2 read will get the first & last address of start_node's neighbour (in order to calculate the start_node's degree); 
                        // the 3rd read will get the counter value
                        // the 4th read will get the current score table value
                        // the 5th is a write opeation, it will score += (alpha ^ i) * current_counter_value * degree
                        if (get_degree_counter == 0) begin 
                            write_enable = 1'b0; // make sure it will do a read operation
                            get_degree_counter += 1;
                            address = curr_node_s*2 + seed_offset;
                            #(period) first_neighbour_address = data_out; // read out the address of curr_node's first neighbour
                        end else if (get_degree_counter == 1) begin
                            write_enable = 1'b0; // make sure it will do a read operation
                            get_degree_counter += 1;
                            address = curr_node_s*2 + 1'b1 + seed_offset;
                            #(period) last_neighbour_address = data_out; // read out the address of curr_node's first neighbour
                            start_node_degree = last_neighbour_address - first_neighbour_address;
                        end else if (get_degree_counter == 2) begin
                            write_enable = 1'b0; 
                            get_degree_counter += 1;
                            y = (start_node_s - 1) * max_steps + steps_s;   
                            z = curr_node_s*(max_steps*node_num) + y + nei_table_offset;
                            address = z;
                            #(period) curr_counter = data_out; // read the counter value  

                        end else if (get_degree_count == 3) begin
                            write_ebable = 1'b0;
                            get_degree_counter += 1;
                            address = curr_node_s + score_table_offset;
                            #(period) curr_score_s = data_out; // read out the address of curr_node's first neighbour

                        end else if (get_degree_count == 4) begin
                            get_degree_count = 0; // reset to go back to 1st read opeation
                            write_enable = 1'b1;
                            curr_score_s = curr_score_s + (alpha ** steps_count_s)*curr_counter*start_node_degree;
                            data_in = curr_score_s; // write the updated score into BRAM
                        end  
                        start_node_s = start_node_s + 1'b1;
                    end
                    steps_count_s += 1;
                end
                curr_node_s = curr_node_s + 1'b1;

            
    end
    
    bram bram_test (
        .i_clk(clk), // bram operate at the rising edge of the clk
        .i_addr(address),
        .i_write(write_enable), // 1'b1 is write operation; 1'b0 is read opeartion 
        .i_data(data_in),
        .o_data(data_out));
       
endmodule