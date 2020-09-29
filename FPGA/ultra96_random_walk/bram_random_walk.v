`timescale 1ns / 1ps

module bram_random_walk();

    reg clk, write_enable;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    // nei_addr_table_offset value is determined by number of seed nodes; nei_table_offset is determined by number of number of seeds nodes plus number of nodes in the dictionary * 2 (* 2 because of first and last neighbour's address) ,
    // score_table_offset is determined by number of seeds nodes plus number of nodes in the dictionary * 2 plus nei_table size; The following number are just picked for testing purpose for now 
    parameter period = 10, ADDR_WIDTH = 13, DATA_WIDTH = 32, DEPTH = 8192, nei_addr_table_offset = 10, nei_table_offset = 100, score_table_offset = 1000;
    parameter alpha = 0.95, seed_num = 10, m_rw = 100, max_steps = 7, node_num = 100; // hyper parameters for the random walk
    reg step_clk, rw_clk, seed_clk, score_nodenum_clk, score_timestep_clk,divide_degree_clk,score_node_operation_clk;
    reg [ADDR_WIDTH-1:0] address, z;
    reg [DATA_WIDTH-1:0] steps, steps_s, curr_node, start_node, curr_counter, counter_randomness, curr_score_s, curr_score_d, start_node_degree, curr_node_degree , self_degree;
    reg [DATA_WIDTH-1:0] y, first_neighbour_address, last_neighbour_address, first_neighbour_address_d, last_neighbour_address_d, next_node;
    integer i, rw_count, seed_count, read_count;
    integer get_degree_counter = 0, score_iter = 0, operation_count_d=0, get_degree_score_d = 0; 
    integer steps_count_s = 0, max_score_table_iter = (node_num+1)*(node_num+1)*max_steps*5;//integer score_table_size = 
    reg [DATA_WIDTH-1:0] curr_node_s = 32'h00000001, curr_node_d = 32'h00000001;
    reg [DATA_WIDTH-1:0] start_node_s = 32'h00000001;

    always begin
        #(period/2) clk = ~clk;  // timescale is 1ns so #5 provides 100MHz clock
        counter_randomness = counter_randomness + 1'b1;
    end

    always begin
        #(period/2 * max_steps) step_clk = ~step_clk;  
        rw_count += 1;
        counter_randomness = counter_randomness + 1'b1;

    end

    always begin
        #(period/2 * max_steps * m_rw * 5) rw_clk = ~rw_clk;  // times 5 is because there are 5 operations in the counter update for each node
        counter_randomness = counter_randomness + 1'b1;

    end

    always begin // 5 operations (4 read and 1 write)
        #(period/2 * 5) score_node_operation_clk = ~score_node_operation_clk;  // 
    end   

    always begin
        #(period/2 *  node_num * 5) score_nodenum_clk = ~score_nodenum_clk;  // 
    end   

    always begin
        #(period/2 *  node_num * max_steps * 5) score_timestep_clk = ~score_timestep_clk;  // 
    end     

    always begin // this clock is for dividing the node's own degree; there are 4 operations (3 read and 1 write) for each node 
        #(period/2 *  4) divide_degree_clk = ~divide_degree_clk;  // each node has 4 operation (3 read and 1 write); therefore, curr_
    end       

    always @(posedge rw_clk) begin // double check on waveform whether it should start on pos or neg edge
        #(period) start_node = data_out;
        seed_count += 1;
    end 

    always @(posedge step_clk) begin 
        curr_node = start_node;
        steps = steps + 1'b1;
    end 

    always @(posedge score_node_operation_clk) begin 
        start_node_s =  start_node_s + 32'h00000001;  
    end    

    always @(posedge score_nodenum_clk) begin 
        start_node_s =  32'h00000001;  // node starts at 1; currently there is no 0 node yet
        steps_count_s += 1;
    end    

    always @(posedge score_timestep_clk) begin 
        steps_count_s =  0;
        curr_node_s = curr_node_s + 1'b1;
    end  

    always @(posedge divide_degree_clk) begin 
        curr_node_d = curr_node_d + 1'b1;
    end  

    always @(negedge clk) begin // start at the negative edge
        if (seed_count < seed_num) begin
            y = (start_node - 1) * max_steps + steps;  // there is a read cycle here, data_out is the seed_ 
            z = curr_node*(max_steps*node_num) + y + nei_table_offset; // double check if this adddress offset is correct?
            if(read_count == 0) begin
                write_enable = 1'b0;
                address = z;
                read_count += 1;
                #(period) curr_counter = data_out; // read the counter value    
            end else if (read_count == 1) begin
                write_enable = 1'b0;
                address = curr_node*2 + nei_addr_table_offset;
                read_count += 1;
                #(period) first_neighbour_address = data_out; // read out the address of curr_node's first neighbour
            end else if (read_count == 2) begin
                write_enable = 1'b0;
                address = curr_node*2 + 1'b1 + nei_addr_table_offset;
                read_count += 1;
                #(period) last_neighbour_address = data_out; // read out the address of curr_node's last neighbour            
            end else if (read_count == 3) begin
                write_enable = 1'b0;
                address = (counter_randomness % (last_neighbour_address-first_neighbour_address+1)) + first_neighbour_address; // randomly pick the one of neighbour's address
                read_count += 1;
                write_enable = ~write_enable;
                #(period) next_node = data_out; // read out next node    
                curr_node = next_node;       
            end else if (read_count == 4) begin
                write_enable = 1'b1;
                read_count = 0; // reset
                curr_counter += 1; // counter value +=1 
                write_enable = 1'b1;
                data_in = curr_counter; // write the counter value to BRAM
            
            end
        // the following loop will be calculating the score value and write into BRAM;
        // the _s naming in the following loop means that it is for calculating the score table (for the purpose of distinguish from the above variable naming)
        end else if (seed_count >= seed_num && score_iter <= max_score_table_iter)begin 
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
                            address = curr_node_s*2 + nei_addr_table_offset;
                            #(period) first_neighbour_address = data_out; // read out the address of curr_node's first neighbour
                        end else if (get_degree_counter == 1) begin
                            write_enable = 1'b0; // make sure it will do a read operation
                            get_degree_counter += 1;
                            address = curr_node_s*2 + 1'b1 + nei_addr_table_offset;
                            #(period) last_neighbour_address = data_out; // read out the address of curr_node's first neighbour
                            start_node_degree = last_neighbour_address - first_neighbour_address+1;
                        end else if (get_degree_counter == 2) begin
                            write_enable = 1'b0; 
                            get_degree_counter += 1;
                            y = (start_node_s - 1'b1) * max_steps + steps_s;   
                            z = curr_node_s*(max_steps*node_num) + y + nei_table_offset;
                            address = z;
                            #(period) curr_counter = data_out; // read the counter value  

                        end else if (get_degree_counter == 3) begin
                            write_enable = 1'b0;
                            get_degree_counter += 1;
                            address = curr_node_s + score_table_offset;
                            #(period) curr_score_s = data_out; // read current node's score

                        end else if (get_degree_counter == 4) begin
                            get_degree_counter = 0; // reset to go back to 1st read opeation
                            write_enable = 1'b1;
                            curr_score_s = curr_score_s + (alpha ** steps_count_s)*curr_counter*start_node_degree;
                            data_in = curr_score_s; // write the updated score into BRAM
                        end  
                        score_iter += 1;
                    end
                end

            end
        // the following variable with _d (divided by node's own degree) are used to differential the above _s (score table) naming 
        end else if(operation_count_d < node_num*4)begin // each node has 4 operattions (3 read and 1 write), thereore times 4
            if (curr_node_d <= node_num) begin
                if (get_degree_score_d == 0) begin 
                    get_degree_score_d += 1;
                    write_enable = 1'b0; 
                    address = curr_node_d*2 + nei_addr_table_offset;
                    #(period/2) first_neighbour_address_d = data_out;
                end else if (get_degree_score_d == 1) begin
                    get_degree_score_d += 1;
                    write_enable = 1'b0; 
                    address = curr_node_d*2+ 1'b1 + nei_addr_table_offset;
                    #(period/2) last_neighbour_address_d = data_out;
                    curr_node_degree = last_neighbour_address_d - first_neighbour_address_d + 1;
                end else if (get_degree_score_d == 2) begin
                    get_degree_score_d += 1;
                    write_enable = 1'b0; 
                    address = curr_node_d + score_table_offset;
                    #(period/2) curr_score_d = data_out;                    
                end else if (get_degree_score_d == 3) begin
                    get_degree_score_d = 0; //reset back to 0 so that it will go back to read operation for the next node 
                    write_enable = 1'b1; 
                    address = curr_node_d + score_table_offset;
                    curr_score_d = curr_score_d / curr_node_degree;
                    data_in = curr_score_d;                    
                end

            end
            operation_count_d += 1;
        end
    end
    
    bram bram_test (
        .i_clk(clk), // bram operate at the rising edge of the clk
        .i_addr(address),
        .i_write(write_enable), // 1'b1 is write operation; 1'b0 is read opeartion 
        .i_data(data_in),
        .o_data(data_out));
       
endmodule
