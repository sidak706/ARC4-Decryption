`timescale 1ps / 1ps
module tb_rtl_phase2();

// Your testbench goes here.

logic CLOCK_50; 
logic [3:0] KEY; 
logic [9:0] SW; 
logic [6:0] HEX0; 
logic [6:0] HEX1; 
logic [6:0] HEX2; 
logic [6:0] HEX3; 
logic [6:0] HEX4; 
logic [6:0] HEX5; 
logic [9:0] LEDR; 

phase2 dut(.*);

logic handshake_complete; 
logic rdy; 
logic en; 
logic [8:0] i;
logic [7:0] j;

logic [8:0] temp;
logic [7:0] jval;

logic [7:0] addr; 
logic wren; 

logic [2:0] state;
logic [3:0] state_ksa; 
logic [2:0] state_init; 

logic [7:0] rddata; 
logic [7:0] wrdata;

logic [7:0] mem [0:255]; 

logic [7:0] key_val; 

logic [23:0] key; 

assign handshake_complete = dut.INITZ.handshake_complete;
assign rdy = dut.rdy; 
assign en = dut.en; 

assign rdy_ksa = dut.rdy_ksa; 
assign en_ksa = dut.en_ksa; 

assign addr = dut.addr; 
assign state = dut.state; 

assign state_init = dut.INITZ.state; 

assign rddata = dut.q; 
assign wrdata = dut.wrdata; 
assign wren = dut.wren; 
assign i = dut.KSA.i;
assign j = dut.KSA.j;


assign state_ksa = dut.KSA.state; 
assign temp = dut.KSA.temp; 
assign mem = dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data;

assign key_val = dut.KSA.key_val; 

assign key = dut.KSA.key;

assign jval = dut.KSA.jval; 



integer x; 
initial begin
    CLOCK_50 = 1'b0;
    forever #(5) CLOCK_50 = ~CLOCK_50;
end


initial begin

    KEY[3] = 1'b1; 
    // SW = {10'b11_0011_1100}; // 0x33c
    SW = {10'b11_0011_1100}; // 0x33c
    #10;
    KEY[3] = 1'b0; 
    SW = 10'b1100111100; //'h33C
    #10
    KEY[3] = 1'b1; 
    #10

    wait(dut.INITZ.state == 2'd2);
    $display("INIT completed");

    
    #50
    // $finish;

    wait(dut.KSA.state == 4'd14);
    $display("KSA completed");

    #30

    for (x = 0; x < 256; x++) begin
        // $display(dut.INITZ.address); 
        $display("0x%h", dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[x]);
    end
    #40
    $finish; 
end


endmodule: tb_rtl_phase2