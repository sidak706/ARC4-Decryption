`timescale 1ps / 1ps
module tb_rtl_phase5();

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

phase5 dut(.*); 

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


assign key_valid = dut.dc.key_valid; 
assign key_crack = dut.dc.key; 

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

endmodule: tb_rtl_phase5
