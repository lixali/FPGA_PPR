`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/27/2020 04:21:35 PM
// Design Name:
// Module Name: bram_testbench
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




module bram_basic_testbench();
    parameter period = 10; // 100MHz clock
    parameter ADDR_WIDTH = 13;
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 8192;

    reg clk;
    reg [ADDR_WIDTH-1:0] address;
    reg write_enable;    
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    integer i;

    initial begin
        clk = 1;
        data_in = 32'h0000;
        #(period/2) address = 13'h0000;
       
        for (i=0; i< DEPTH; i = i+1) begin
            #(period*2) address = address +1'b1; // address adds 1 every 2 periods because write and read will access the same address
            data_in = data_in+1'b1;
        end

    end
   
    initial begin
        #(period/2) write_enable = 1; // offset 90 degree
        for (i=0; i< DEPTH; i = i+1) begin
            #(period) write_enable = ~write_enable; // write enable signal period is 2x of clock's because there will be 1 write and 1 read
        end        
    end
    always begin
        #(period/2) clk = ~clk;  // timescale is 1ns so #5 provides 100MHz clock
    end


    bram bram_test (
        .i_clk(clk),
        .i_addr(address),
        .i_write(write_enable),
        .i_data(data_in),
        .o_data(data_out));

endmodule
