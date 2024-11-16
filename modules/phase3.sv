module phase3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic [7:0] ct_addr, pt_addr; 
    logic [7:0] pt_wrdata;
    logic [7:0] ct_rddata, pt_rddata; 
    logic pt_wren; 

    logic en, rdy; 

    logic ct_wren; 
    logic [7:0] ct_wrdata; 
    assign ct_wren = 1'b0; 
    assign ct_wrdata = 8'b0; 

    enum {WAIT, ENABLE, UNENABLE} state; 

    always_ff @(posedge CLOCK_50) begin
        if(!KEY[3]) state <= WAIT; 
        else begin
            case(state)
            WAIT: begin
                en <= 1'b0;
                if(rdy == 1'b1) begin
                    en <= 1'b1; 
                    state <= UNENABLE;
                end
            end
            UNENABLE: begin
                en <= 1'b0;
            end
            endcase
        end
    end

    pt_mem pt(pt_addr, CLOCK_50, pt_wrdata, pt_wren, pt_rddata);
    ct_mem ct(ct_addr, CLOCK_50, ct_wrdata, ct_wren, ct_rddata);
    arc4 a4(CLOCK_50, KEY[3],
            en, rdy,
            {14'b0, SW}, 
            ct_addr, ct_rddata,
            pt_addr, pt_rddata, pt_wrdata, pt_wren);


endmodule: phase3
