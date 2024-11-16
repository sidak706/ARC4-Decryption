`timescale 1ps / 1ps
module tb_rtl_phase4();

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

phase4 dut(.*); 

logic [23:0] key_crack; 
logic key_valid; 

logic rdy_crack; 
logic en_crack; 

logic [3:0] cstate; 
logic [3:0] state_arc; 
logic [5:0] state_p; 
logic [2:0] init_state; 

logic [3:0] ksa_state; 

logic en_arc; 
logic rdy_arc; 

logic rdy_p; 
logic en_p; 
logic rst_p; 
logic [5:0] p_state; 
logic [7:0] message_length;

logic [7:0] ct_rddata; 
logic [8:0] i; 
logic valid; 

logic [7:0] pt [0:255];


assign cstate = dut.c.state; 
assign rdy_crack = dut.c.rdy;
assign en_crack = dut.en;  

assign state_arc = dut.c.a4.state; 
assign en_arc = dut.c.a4.en; 
assign rdy_arc = dut.c.a4.rdy; 

assign en_p = dut.c.a4.p.en; 
assign rdy_p = dut.c.a4.p.rdy; 
assign rst_p = dut.c.a4.p.rst_n; 

assign init_state = dut.c.a4.i.state; 
assign ksa_state = dut.c.a4.k.state; 
assign p_state = dut.c.a4.p.state; 

assign key_valid = dut.c.key_valid; 
assign key_crack = dut.c.key; 

assign i = dut.c.i; 
assign valid = dut.c.valid; 

assign message_length = dut.c.message_length;

assign ct_rddata = dut.c.ct_rddata; 

assign pt = dut.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data;



initial begin
    CLOCK_50 = 1'b0;
    forever #(5) CLOCK_50 = ~CLOCK_50;
end

initial begin
    KEY[3] = 1'b0; 
    #10
    KEY[3] = 1'b1; 
    #10

    wait(key_valid == 1'b1)
    #50
    $display("%0d", key_crack); 


    $finish; 

end

endmodule: tb_rtl_phase4
