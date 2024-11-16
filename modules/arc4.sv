module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
    logic [7:0] addr, wrdata, q; 
    logic wren; 

    logic [7:0] addr_i, wrdata_i; 
    logic en_in, rdy_in, wren_i; 

    logic [7:0] addr_k, wrdata_k; 
    logic en_ksa, rdy_ksa, wren_k;

    logic [7:0] saddr_p, swrdata_p;
    logic swren_p;

    logic [7:0] ctaddr_p;

    logic [7:0] ptaddr_p, ptwrdata_p; 
    logic ptwren_p; 

    logic en_p; 

    logic handshake_complete; 
    assign handshake_complete = en & rdy; 
    s_mem s(addr, clk, wrdata, wren, q);

    init i(clk, rst_n, en_in, rdy_in, addr_i, wrdata_i, wren_i);

    ksa k(.clk(clk), .rst_n(rst_n),
    .en(en_ksa), .rdy(rdy_ksa),
    .key(key),
    .addr(addr_k), .rddata(q), .wrdata(wrdata_k), .wren(wren_k));

    prga p(.clk(clk), .rst_n(rst_n),
            .en(en_p), .rdy(rdy_p),
            .key(key),
            .s_addr(saddr_p), .s_rddata(q), .s_wrdata(swrdata_p), .s_wren(swren_p),
            .ct_addr(ct_addr), .ct_rddata(ct_rddata),
            .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    //    0              1         2       3             4         5               6            7           8        9     10        11          12
    enum {WAITHANDSHAKE, WAIT, WAIT_KSA, UNENABLE, ENABLE_KSA, TRANSITION, UNENABLE_KSA, ENABLE_PRGA, TRANSITIONP, WAIT_P, ENABLE_P, UNENABLE_P, TRANSITIONC} state;

    // assign en = rdy; 
    /*INIT->KSA->PRGA. Transition states wait for rdy to go from 0 to 1*/
    always_ff @( posedge clk ) begin
        if(!rst_n) begin
            rdy <= 1'b1; 
            state <= WAITHANDSHAKE; 
        end
        case(state)
        WAITHANDSHAKE: begin
            if(handshake_complete) begin
                rdy <= 1'b0; 
                state <= WAIT; 
            end
        end
        WAIT: begin
            en_ksa <= 1'b0;
            if(rdy_in == 1'b1) begin
                en_in <= 1'b1;
                state <= UNENABLE; 
            end
        end
        UNENABLE: begin
            en_in <= 1'b0; 
            state <= TRANSITION; 
        end

        TRANSITION: begin
            if (rdy_in == 1'b1) begin
                state <= WAIT_KSA;
                // rst_ksa <= 1'b0; 
            end
        end

        WAIT_KSA: begin
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
            state <= TRANSITIONP; 
        end

        TRANSITIONP: begin
            if(rdy_ksa == 1'b1) begin
                state <= WAIT_P; 
            end
        end

        WAIT_P: begin
            if(rdy_p == 1'b1) begin
                state <= ENABLE_P; 
            end
        end

        ENABLE_P: begin
            en_p <= 1'b1; 
            state <= UNENABLE_P; 
        end

        UNENABLE_P: begin
            en_p <= 1'b0; 
            state <= TRANSITIONC; 
        end

        TRANSITIONC: begin
            if(rdy_p == 1'b1) begin
                rdy <= 1'b1; 
                state <= WAITHANDSHAKE; 
            end
        end
        default: state <= WAIT; 
        endcase
    end


    // Controlling which part of the code can control the addresses
    always_comb begin 
        if(state == WAIT || state == TRANSITION || state == UNENABLE || state == WAIT_KSA) begin
            addr = addr_i;
            wrdata = wrdata_i;
            wren = wren_i;
        end
        else if(state == ENABLE_KSA || state == UNENABLE_KSA || state == TRANSITIONP || state == WAIT_P) begin
            addr = addr_k;
            wrdata = wrdata_k;
            wren = wren_k;
        end
        else begin
            addr = saddr_p; 
            wrdata = swrdata_p; 
            wren = swren_p; 
        end

    end

    // your code here
endmodule: arc4