module phase1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);


    logic en; 
    logic rdy; 
    logic [7:0] addr; 
    logic [7:0] wrdata;
    logic wren; 
    logic [7:0] q;

    s_mem s(addr, CLOCK_50, wrdata, wren, q);


    init INITZ(CLOCK_50, KEY[3],
            en, rdy,
            addr, wrdata, wren);

endmodule: phase1
