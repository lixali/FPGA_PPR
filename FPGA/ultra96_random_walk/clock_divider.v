module clock_divider(
    input clk,
    input arst,
    input [31:0] div_num,
    output clk_div
    );   
wire [31:0] N;
parameter period = 10;
//integer cnt = 5;
reg [31:0] cnt = 0;
reg clk_a = 1'b0;
reg clk_b = 1'b0;
reg first = 1'b0;
wire clk_c;

assign N = div_num;
always@(posedge clk or posedge arst)
begin
    if(arst)
        cnt <= 0;
    else if(cnt == N-1)
        cnt <= 0;
    else
        #(period/10) cnt <= cnt + 1;    
end
 
always@(posedge clk or posedge arst)
begin
    if(arst) begin
        clk_a<= 0;
    end else if((cnt == (N-1)/2 && N[0] == 1'b1) || cnt == 0 || first == 1'b0) begin
        clk_a <= ~clk_a;
		first <= 1'b1;
	end else if ((cnt == N/2 && N[0] == 1'b0) || cnt == 0 || first == 1'b0) begin
        clk_a <= ~clk_a;
		first <= 1'b1;	
    end else begin
        clk_a <= clk_a;
	end
end
 
/*****************method1**********************/

always@(negedge clk or posedge arst)
begin
    if(arst)
        clk_b <= 0;
    else 
        clk_b <= clk_a;
end

/******************method2********************/
/*
always@(negedge clk or posedge arst)
begin
    if(arst)
        clk_b<= 0;
    else if(cnt == (N-1)/2 || cnt == N-1)
        clk_b<= ~clk_b;
    else
        clk_b<= clk_b;    
end
*/
//********************************************/
 
assign clk_c = clk_a | clk_b;
//N[0]=1 means that it is odd number 
assign clk_div = N[0] ? clk_c : clk_a;
 
endmodule
