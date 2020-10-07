module clk_divider2_tb();

    reg clk = 1'b1;
    wire out_clk;
    parameter period=10;
    always begin
      #(period/2) clk = ~clk;

    end

    clock_divider clock_divider2_ins1(
    .clk(clk),
    .arst(1'b0),
    .div_num(32'h0000000a),
    .clk_div(out_clk)
    );   
endmodule
