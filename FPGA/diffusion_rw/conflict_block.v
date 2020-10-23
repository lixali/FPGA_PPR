module conflict_block #(parameter ADDR_WIDTH = 13, lower_addr = 0, upper_addr = 4) ( 
    input clk,
    input [ADDR_WIDTH-1:0] addrA,
    input [ADDR_WIDTH-1:0] addrB, 
    output reg conflict //
    );

    always @(negedge clk) begin // start at the negative edge
        if ( lower_addr <= addrA <= upper_addr && lower_addr <= addrB <= upper_addr) begin
            conflict <= 1'b1;
        end else begin
            conflict <= 1'b0;
        end

    end
    

endmodule 
