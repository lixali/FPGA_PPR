module lfsr(
    input clk,
    input reset,    // Active-high synchronous reset to 32'h1
    output [31:0] q
); 
    
    reg [31:0] q1;
        always@(posedge clk) begin
            if(reset) q1 <= 32'h1;
        else begin
            //q1 <= {q1[0],q1[31:23],q1[0]^q1[22],q1[21:3],q1[0]^q1[2],q1[0]^q1[1]};
            q1 <= {q1[31:1],q1[31]^q1[21]^q1[1]^q1[0]};
        end
        
    end
    assign q = q1;
 
endmodule
