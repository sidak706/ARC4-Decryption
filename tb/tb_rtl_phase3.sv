`timescale 1ps / 1ps
module tb_rtl_phase3();

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

phase3 dut(.*); 

logic [2:0] state; 
logic [3:0] state_arc; 
logic [5:0] state_p; 
logic [7:0] mem [0:255]; 

logic en_top;
logic rdy_top;

logic en_init;
logic rdy_init; 

logic en_ksa; 
logic rdy_ksa; 

logic en_prg; 
logic rdy_prg; 


logic [7:0] pad [0:255];
logic [7:0] ct [0:255]; 
logic [7:0] pt [0:255];

logic [8:0] i, j, k, k2, pad_val;
logic [8:0] message_length;
logic [7:0] temp, temp2;
logic [7:0] jval; 
logic [7:0] combined; 

logic [7:0] ct_addr;
logic [7:0] ct_rddata;

logic [7:0] s_addr;
logic [7:0] s_rddata;
logic [7:0] s_wrdata; 
logic s_wren; 

logic [7:0] ct_val; 

logic [7:0] pad_addr; 

logic [7:0] addr; 
logic [7:0] wren; 

assign i = dut.a4.p.i; 
assign j = dut.a4.p.j; 
assign k = dut.a4.p.k; 
assign k2 = dut.a4.p.k2; 
assign pad_val = dut.a4.p.pad_val; 
assign message_length = dut.a4.p.message_length; 
assign temp = dut.a4.p.temp; 
assign temp2 = dut.a4.p.temp2; 
assign jval = dut.a4.p.jval; 
assign combined = dut.a4.p.combined; 
assign ct_val = dut.a4.p.ct_val; 
assign pad_addr = dut.a4.p.pad_addr; 
assign s_addr = dut.a4.p.s_addr; 
assign s_rddata = dut.a4.p.s_rddata; 
assign s_wrdata = dut.a4.p.s_wrdata; 
assign s_wren = dut.a4.p.s_wren;
assign ct_addr = dut.ct_addr; 


assign addr = dut.a4.addr; 
assign wren = dut.a4.wren; 


assign state = dut.state; 
assign state_arc = dut.a4.state; 
assign state_p = dut.a4.p.state; 

assign en_top = dut.en; 
assign rdy_top = dut.rdy; 

assign en_init = dut.a4.i.en;
assign rdy_init = dut.a4.i.rdy; 

assign en_ksa = dut.a4.k.en; 
assign rdy_ksa = dut.a4.k.rdy; 

assign en_prg = dut.a4.p.en; 
assign rdy_prg = dut.a4.p.rdy; 

assign pad = dut.a4.p.pad;

assign ct = dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data;
assign pt = dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data;
assign mem = dut.a4.s.altsyncram_component.m_default.altsyncram_inst.mem_data;

integer x; 

// initial begin
//     $readmemh("C:\\CPEN311\\lab-3-lab3-l1c-70\\task3\\test1.memh", ct);
// end

initial begin
    CLOCK_50 = 1'b0;
    forever #(5) CLOCK_50 = ~CLOCK_50;
end

initial begin
    KEY[3] = 1'b0; 
    SW = {10'b00_0001_1000}; // 000018
    #10
    KEY[3] = 1'b1; 
    #10
    wait(state_p == 6'd24); 
    #50

    for(x = 0; x < 256; x++) begin
        $display(pt[x]);
    end

    #20

    $finish;
end

endmodule: tb_rtl_phase3
