`timescale 1ps/1ps
module tb_rtl_phase1();

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

integer i; 


phase1 dut(.*); 

logic handshake_complete; 
logic ready; 
logic [1:0] state; 
logic [7:0] addr; 
logic [7:0] wrdata; 
logic wren; 

logic [2:0] state; 

assign handshake_complete = dut.INITZ.handshake_complete; 
assign rdy = dut.INITZ.rdy; 
assign state = dut.INITZ.state; 

assign addr = dut.addr; 
assign wrdata = dut.wrdata;
assign wren = dut.wren; 

initial begin
    CLOCK_50 = 1'b0;
    forever #(5) CLOCK_50 = ~CLOCK_50;
end

initial begin
    KEY[3] = 1'b0; 
    #10
    KEY[3] = 1'b1; 
    #10
    dut.en = 1'b1; 
    wait(dut.INITZ.handshake_complete)
    #10
    dut.en = 1'b0; 

    #10

    #10

    wait(state == 2'b10)
    #10

    for (i = 0; i < 256; i++) begin
        $display(dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
    end
    #50
    $finish;
end

endmodule: tb_rtl_phase1
