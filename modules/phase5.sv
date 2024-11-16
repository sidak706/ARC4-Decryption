module phase5(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    `define BLANK 7'b1111111 
    `define ZERO 7'b1000000
    `define ONE 7'b1111001 
    `define TWO 7'b0100100
    `define THREE 7'b0110000
    `define FOUR 7'b0011001
    `define FIVE 7'b0010010
    `define SIX 7'b0000010
    `define SEVEN 7'b1111000
    `define EIGHT 7'b0000000
    `define NINE 7'b0010000
    `define A 7'b0001000
    `define B 7'b0000011
    `define C 7'b1000110
    `define D 7'b0100001
    `define E 7'b0000110
    `define F 7'b0001110
    `define DEBUG 7'b0111111


    logic [7:0] ct_addr, ct_rddata, ct_wrdata; 
    logic ct_wren; 

    logic en; 
    logic rdy; 
    logic [23:0] key_crack; 
    logic key_valid; 


    doublecrack dc(CLOCK_50, KEY[3],
             en, rdy,
             key_crack, key_valid,
             ct_addr, ct_rddata);

    ct_mem ct(ct_addr, CLOCK_50, ct_wrdata, ct_wren, ct_rddata);
    // initial $readmemh("C:\\CPEN311\\lab-3-lab3-l1c-70\\task3\\test2.memh", ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

    enum {WAIT, UNENABLE, DISPLAY} state; 

    assign ct_wren = 1'b0; 
    assign ct_wrdata = 8'b0; 


    always_comb begin
        if(state == DISPLAY) begin
            case (key_crack[3:0])
                4'b0000: HEX0 = `ZERO;
                4'b0001: HEX0 = `ONE; 
                4'b0010: HEX0 = `TWO; 
                4'b0011: HEX0 = `THREE; 
                4'b0100: HEX0 = `FOUR; 
                4'b0101: HEX0 = `FIVE; 
                4'b0110: HEX0 = `SIX; 
                4'b0111: HEX0 = `SEVEN; 
                4'b1000: HEX0 = `EIGHT;  
                4'b1001: HEX0 = `NINE; 
                4'b1010: HEX0 = `A; 
                4'b1011: HEX0 = `B; 
                4'b1100: HEX0 = `C;
                4'b1101: HEX0 = `D; 
                4'b1110: HEX0 = `E;
                4'b1111: HEX0 = `F; 
                // {HEX2, HEX1, HEX3, HEX4, HEX5} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX0 = `BLANK; 
            endcase
            case (key_crack[7:4])
                4'b0000: HEX1 = `ZERO;
                4'b0001: HEX1 = `ONE; 
                4'b0010: HEX1 = `TWO; 
                4'b0011: HEX1 = `THREE; 
                4'b0100: HEX1 = `FOUR; 
                4'b0101: HEX1 = `FIVE; 
                4'b0110: HEX1 = `SIX; 
                4'b0111: HEX1 = `SEVEN; 
                4'b1000: HEX1 = `EIGHT;  
                4'b1001: HEX1 = `NINE; 
                4'b1010: HEX1 = `A; 
                4'b1011: HEX1 = `B; 
                4'b1100: HEX1 = `C;
                4'b1101: HEX1 = `D; 
                4'b1110: HEX1 = `E;
                4'b1111: HEX1 = `F; 
                // {HEX0, HEX2, HEX3, HEX4, HEX5} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX1 = `BLANK; 
            endcase

            case (key_crack[11:8])
                4'b0000: HEX2 = `ZERO;
                4'b0001: HEX2 = `ONE; 
                4'b0010: HEX2 = `TWO; 
                4'b0011: HEX2 = `THREE; 
                4'b0100: HEX2 = `FOUR; 
                4'b0101: HEX2 = `FIVE; 
                4'b0110: HEX2 = `SIX; 
                4'b0111: HEX2 = `SEVEN; 
                4'b1000: HEX2 = `EIGHT;  
                4'b1001: HEX2 = `NINE; 
                4'b1010: HEX2 = `A; 
                4'b1011: HEX2 = `B; 
                4'b1100: HEX2 = `C;
                4'b1101: HEX2 = `D; 
                4'b1110: HEX2 = `E;
                4'b1111: HEX2 = `F; 
                // {HEX0, HEX1, HEX3, HEX4, HEX5} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX2 = `BLANK; 
            endcase

            case (key_crack[15:12])
                4'b0000: HEX3 = `ZERO;
                4'b0001: HEX3 = `ONE; 
                4'b0010: HEX3 = `TWO; 
                4'b0011: HEX3 = `THREE; 
                4'b0100: HEX3 = `FOUR; 
                4'b0101: HEX3 = `FIVE; 
                4'b0110: HEX3 = `SIX; 
                4'b0111: HEX3 = `SEVEN; 
                4'b1000: HEX3 = `EIGHT;  
                4'b1001: HEX3 = `NINE; 
                4'b1010: HEX3 = `A; 
                4'b1011: HEX3 = `B; 
                4'b1100: HEX3 = `C;
                4'b1101: HEX3 = `D; 
                4'b1110: HEX3 = `E;
                4'b1111: HEX3 = `F; 
                // {HEX0, HEX1, HEX2, HEX4, HEX5} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX3 = `BLANK; 
            endcase

            case (key_crack[19:16])
                4'b0000: HEX4 = `ZERO;
                4'b0001: HEX4 = `ONE; 
                4'b0010: HEX4 = `TWO; 
                4'b0011: HEX4 = `THREE; 
                4'b0100: HEX4 = `FOUR; 
                4'b0101: HEX4 = `FIVE; 
                4'b0110: HEX4 = `SIX; 
                4'b0111: HEX4 = `SEVEN; 
                4'b1000: HEX4 = `EIGHT;  
                4'b1001: HEX4 = `NINE; 
                4'b1010: HEX4 = `A; 
                4'b1011: HEX4 = `B; 
                4'b1100: HEX4 = `C;
                4'b1101: HEX4 = `D; 
                4'b1110: HEX4 = `E;
                4'b1111: HEX4 = `F; 
                // {HEX0, HEX1, HEX3, HEX2, HEX5} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX4 = `BLANK; 
            endcase

            case (key_crack[23:20])
                4'b0000: HEX5 = `ZERO;
                4'b0001: HEX5 = `ONE; 
                4'b0010: HEX5 = `TWO; 
                4'b0011: HEX5 = `THREE; 
                4'b0100: HEX5 = `FOUR; 
                4'b0101: HEX5 = `FIVE; 
                4'b0110: HEX5 = `SIX; 
                4'b0111: HEX5 = `SEVEN; 
                4'b1000: HEX5 = `EIGHT;  
                4'b1001: HEX5 = `NINE; 
                4'b1010: HEX5 = `A; 
                4'b1011: HEX5 = `B; 
                4'b1100: HEX5 = `C;
                4'b1101: HEX5 = `D; 
                4'b1110: HEX5 = `E;
                4'b1111: HEX5 = `F; 
                // {HEX0, HEX1, HEX3, HEX4, HEX2} = {`BLANK, `BLANK, `BLANK, `BLANK, `BLANK}; 
                default: HEX5 = `BLANK; 
            endcase
        end

        else begin
            HEX0 = `BLANK;  
            HEX1 = `BLANK;  
            HEX2 = `BLANK;  
            HEX3 = `BLANK;  
            HEX4 = `BLANK;  
            HEX5 = `BLANK;  
        end
        
    end


    always_ff @( posedge CLOCK_50 ) begin
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
                if(key_valid) begin
                    state <= DISPLAY; 
                end
            end

            DISPLAY: begin
                state <= DISPLAY; 
            end
            endcase
        end
    end


endmodule: phase5
