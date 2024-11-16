module phase2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic en; 
    logic rdy; 
    logic [7:0] addr;
    logic [7:0] addr_i;
    logic [7:0] addr_k; 
    logic [7:0] wrdata;
    logic [7:0] wrdata_i;
    logic [7:0] wrdata_k;
    logic wren;
    logic wren_i;
    logic wren_k; 
    logic [7:0] q;

    logic en_ksa; 
    logic rdy_ksa; 

    logic rst_ksa; 

    logic rdy_counter; 

    

    // enum {err, init, ksa} state;
    //    0     1         2       3             4         5
    enum {WAIT, WAIT_KSA, UNENABLE, ENABLE_KSA, TRANSITION, UNENABLE_KSA} state;

    // assign en = rdy; 
    always_ff @( posedge CLOCK_50 ) begin
        if(!KEY[3]) state <= WAIT;
        case(state)
        WAIT: begin
            rst_ksa <= 1'b1; 
            en_ksa <= 1'b0;
            if(rdy == 1'b1) begin
                en <= 1'b1;
                state <= UNENABLE; 
            end
        end
        UNENABLE: begin
            en <= 1'b0; 
            state <= TRANSITION; 
        end

        TRANSITION: begin
            if (rdy == 1'b1) begin
                state <= WAIT_KSA;
                rst_ksa <= 1'b0; 
            end
        end

        WAIT_KSA: begin
            rst_ksa <= 1'b1; 
            if (rdy_ksa == 1'b1) begin
                state <= ENABLE_KSA;
            end
        end

        ENABLE_KSA: begin
            en_ksa <= 1;
            state <= UNENABLE_KSA;
        end

        UNENABLE_KSA: begin
            en_ksa <= 0;
        end
        default: state <= WAIT; 
        endcase
    end

    always_comb begin 
        if(state == WAIT || state == TRANSITION || state == UNENABLE || state == WAIT_KSA) begin
            addr = addr_i;
            wrdata = wrdata_i;
            wren = wren_i;
        end
        else begin
            addr = addr_k;
            wrdata = wrdata_k;
            wren = wren_k;
        end

    end


    init INITZ(.clk(CLOCK_50), .rst_n(KEY[3]),
            .en(en), .rdy(rdy),
            .addr(addr_i), .wrdata(wrdata_i), .wren(wren_i));


    s_mem s(addr, CLOCK_50, wrdata, wren, q);


    ksa KSA(.clk(CLOCK_50), .rst_n(KEY[3]),
    .en(en_ksa), .rdy(rdy_ksa),
    .key({14'b0, SW}),
    .addr(addr_k), .rddata(q), .wrdata(wrdata_k), .wren(wren_k));

endmodule: phase2