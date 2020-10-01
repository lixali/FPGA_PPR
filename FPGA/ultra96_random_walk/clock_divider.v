module clock_divider (
    input clk,
    input clk_div,
    output o_clk
    );

    reg curr_div = 32'h00000000;
    always @ (posedge clk or negedge clk) begin
        if (curr_div == clk_div) begin
            curr_div = 0;
            o_clk = ~o_clk;
        end
        curr_div = curr_div + 1; 
    end
endmodule
