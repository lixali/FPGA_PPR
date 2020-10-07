module lfsr_tb();

    reg reset, clk;
    wire [31:0] out_number;
    integer count ;
    initial begin
        reset = 1'b0;
        count = 0;
        clk = 1'b1;

        #5 reset = 1'b1;
        #15 reset = 1'b0;

        count = count + 1;
           

    end

    always
        #5 clk = ~clk;

lfsr lfsr_ins1(
    .clk(clk),
    .reset(reset),    // Active-high synchronous reset to 32'h1
    .q(out_number)
);

 
endmodule
