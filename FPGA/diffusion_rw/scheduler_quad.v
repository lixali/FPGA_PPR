module scheduler_quad #(parameter ADDR_WIDTH = 13, DATA_WIDTH = 32, lower_addr = 0, upper_addr = 4) ( 
    input clk,
    input [DATA_WIDTH-1:0] data_mem,

    input [ADDR_WIDTH-1:0] addrA,
    input [ADDR_WIDTH-1:0] addrB,
    input [ADDR_WIDTH-1:0] addrC,
    input [ADDR_WIDTH-1:0] addrD,

    input [DATA_WIDTH-1:0] dataA,
    input [DATA_WIDTH-1:0] dataB,
    input [DATA_WIDTH-1:0] dataC,
    input [DATA_WIDTH-1:0] dataD,

    input write_enA,
    input write_enB,
    input write_enC,
    input write_enD,

    output [DATA_WIDTH-1:0] data, // goes out to bram memory
    output [ADDR_WIDTH-1:0] addr, // addr goes out to bram memory
    output [DATA_WIDTH-1:0] dataMA, // goes out to verilog M module
    output [DATA_WIDTH-1:0] dataMB,
    output [DATA_WIDTH-1:0] dataMC,
    output [DATA_WIDTH-1:0] dataMD,

    output write_mem_enA,
    output write_mem_enB,
    output write_mem_enC,
    output write_mem_enD,

    output reg conflict_b,
    output reg conflict_c,
    output reg conflict_d //

    );


    wire conflict_AB, conflict_AC, conflict_AD, conflict_BC, conflict_BD, conflict_CD;
    reg selA = 1'b0, selB = 1'b0, selC = 1'b0, selD = 1'b0;

	assign dataMA = (selA == 1'b1)? data_mem: {(DATA_WIDTH){1'bz}};
    assign data = (selA == 1'b1)? dataA: {(DATA_WIDTH){1'bz}};
    assign addr = (selA == 1'b1)? addrA-lower_addr: {(ADDR_WIDTH){1'bz}};
    assign write_mem_enA = (selA == 1'b1)? write_enA: {1'bz};

	assign dataMB = (selB == 1'b1)? data_mem: {(DATA_WIDTH){1'bz}};
    assign data = (selB == 1'b1)? dataB: {(DATA_WIDTH){1'bz}};
    assign addr = (selB == 1'b1)? addrB-lower_addr: {(ADDR_WIDTH){1'bz}};
    assign write_mem_enB = (selB == 1'b1)? write_enB: {1'bz};

	assign dataMC = (selC == 1'b1)? data_mem: {(DATA_WIDTH){1'bz}};
    assign data = (selC == 1'b1)? dataA: {(DATA_WIDTH){1'bz}};
    assign addr = (selC == 1'b1)? addrC-lower_addr: {(ADDR_WIDTH){1'bz}};
    assign write_mem_enC = (selC == 1'b1)? write_enC: {1'bz};

	assign dataMD = (selD == 1'b1)? data_mem: {(DATA_WIDTH){1'bz}};
    assign data = (selD == 1'b1)? dataD: {(DATA_WIDTH){1'bz}};
    assign addr = (selD == 1'b1)? addrD-lower_addr: {(ADDR_WIDTH){1'bz}};
    assign write_mem_enD = (selD == 1'b1)? write_enD: {1'bz};


    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_AB (
        .clk(clk),
        .addrA(addrA),
        .addrB(addrB), 
        .conflict(conflict_AB)
    );
    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_AC (
        .clk(clk),
        .addrA(addrA),
        .addrB(addrC), 
        .conflict(conflict_AC)
    );

    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_AD (
        .clk(clk),
        .addrA(addrA),
        .addrB(addrD), 
        .conflict(conflict_AD)
    );

    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_BC (
        .clk(clk),
        .addrA(addrB),
        .addrB(addrC), 
        .conflict(conflict_BC)
    );

    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_BD (
        .clk(clk),
        .addrA(addrB),
        .addrB(addrD), 
        .conflict(conflict_BD)
    );

    conflict_block #(.ADDR_WIDTH(13), .lower_addr(lower_addr), .upper_addr(upper_addr)) conflict_ins_CD (
        .clk(clk),
        .addrA(addrC),
        .addrB(addrD), 
        .conflict(conflict_CD)
    );


    //reg first_second_half_reg;    
    always @(negedge clk) begin

        if (lower_addr <= addrA <= upper_addr || lower_addr <= addrB <= upper_addr || lower_addr <= addrC <= upper_addr || lower_addr <= addrD <= upper_addr) begin

            // there is conflict, priority M1 > M2 > M3 > M4
            if (conflict_AB == 1'b1 || conflict_AC == 1'b1 || conflict_AD == 1'b1 || conflict_BC == 1'b1 || conflict_BD == 1'b1 || conflict_CD == 1'b1) begin
                
                if (lower_addr <= addrA <= upper_addr) begin
                    selA = 1'b1;
                    selB = 1'b0;
                    selC = 1'b0;
                    selD = 1'b0;
                end else if (lower_addr <= addrB <= upper_addr) begin
                    selA = 1'b0;
                    selB = 1'b1;
                    selC = 1'b0;
                    selD = 1'b0;
                end else if (lower_addr <= addrC <= upper_addr) begin
                    selA = 1'b0;
                    selB = 1'b0;
                    selC = 1'b1;
                    selD = 1'b0;
                end else if (lower_addr <= addrD <= upper_addr) begin
                    selA = 1'b0;
                    selB = 1'b0;
                    selC = 1'b0;
                    selD = 1'b1;

                end


            end 

        end else begin // if not even one addr is within address boundary, no one is selected
            selA = 1'b0;
            selB = 1'b0;
            selC = 1'b0;
            selD = 1'b0;
        end 

        conflict_b <= conflict_AB;
        conflict_c <= conflict_AC | conflict_BC;
        conflict_d <= conflict_AD | conflict_BD | conflict_CD;               

    end


endmodule