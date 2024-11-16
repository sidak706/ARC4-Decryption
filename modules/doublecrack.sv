module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic handshake_complete; 
    logic rst_crack;
    logic rdy_crack, en_crack; 

    logic [7:0] pt_addr; 
    logic [7:0] pt_wrdata; 
    logic [7:0] pt_rddata; 
    logic pt_wren; 
    logic rst_arc;

    logic [7:0] ct_addr1, ct_addr_arc; 

    logic en_arc; 

    logic [23:0] key1;
    logic [23:0] key2;

    logic [7:0] ct_rddata2;  

    assign handshake_complete = en & rdy; 


    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);

    logic [7:0] message_length1; 
    logic [7:0] message_length2; 

    logic rdy_crack1; 
    logic rdy_crack2; 

    logic en_crack1; 
    logic en_crack2; 

    logic [7:0] ct_addr2; 

    logic [7:0] ct_wrdata2; 

    crack c1(clk, rst_crack, en_crack1, rdy_crack1, key1, key_valid1, ct_addr1, ct_rddata, 8'd0, message_length1);
    crack c2(clk, rst_crack, en_crack2, rdy_crack2, key2, key_valid2, ct_addr2, ct_rddata2, 8'd1, message_length2);

    arc4 a4(clk, rst_arc,
            en_arc, rdy_arc,
            key,
            ct_addr_arc, ct_rddata,
            pt_addr, pt_rddata, pt_wrdata, pt_wren);

    enum {WAITHANDSHAKE, RSTCRACK, DERESTCRACK, WAITCRACK, 
    UNENABLE, WAITVALID, EXEC, UNRESET_ARC, WAIT_ARC, 
    UNENABLE_ARC, TRANSITIONARC, DONE} state; 

    always_ff @( posedge clk ) begin
        if(!rst_n) begin
            rdy <= 1'b1; 
            rst_crack <= 1'b1; 
            state <= WAITHANDSHAKE; 
            key_valid <= 1'b0; 
        end
        case(state)
        WAITHANDSHAKE: begin
            if(handshake_complete) begin
                state <= RSTCRACK;
            end
        end

        RSTCRACK: begin
            rst_crack <= 1'b0; 
            state <= DERESTCRACK; 
        end

        DERESTCRACK: begin
            rst_crack <= 1'b1; 
            state <= WAITCRACK;
        end

        WAITCRACK: begin
            en_crack1 <= 1'b0; 
            en_crack2 <= 1'b0; 
            if(rdy_crack1 == 1'b1) begin
                en_crack1 <= 1'b1;
                state <= UNENABLE; 
            end 
        end

        UNENABLE: begin
            en_crack1 <= 1'b0; 
            if(rdy_crack2 == 1'b1) begin
                en_crack2 <= 1'b1;
                state <= WAITVALID;
            end
        end

        WAITVALID: begin
            en_crack2 <= 1'b0; 
            if(key_valid1 || key_valid2) begin
                state <= EXEC; 
            end
        end

        EXEC: begin
            if(key_valid1) begin
                key <= key1; 
            end

            else if(key_valid2) begin
                key <= key2; 
            end 
            rst_arc <= 1'b0; 
            state <= UNRESET_ARC; 
        end

        UNRESET_ARC: begin
            rst_arc <= 1'b1; 
            state <= WAIT_ARC; 
        end

        WAIT_ARC: begin
            en_arc <= 1'b0; 
            if(rdy_arc == 1'b1) begin
                en_arc <= 1'b1; 
                state <= UNENABLE_ARC; 
            end
        end

        UNENABLE_ARC: begin
            en_arc <= 1'b0; 
            state <= TRANSITIONARC; 
        end

        TRANSITIONARC: begin
            if(rdy_arc == 1'b1) begin
                state <= DONE; 
            end
        end

        DONE: begin
            key_valid <= 1'b1; 
        end

        endcase
    end

    always_comb begin
        if(state == WAITHANDSHAKE || state == RSTCRACK || state == DERESTCRACK || state == WAITCRACK || state == UNENABLE || state == WAITVALID) begin
            ct_addr = ct_addr1; 
        end
        else begin
            ct_addr = ct_addr_arc; 
        end
    end
    

    assign ct_wren2 = 1'b0; 
    assign ct_wrdata2 = 8'b0; 
    ct_mem ct2(ct_addr2, clk, ct_wrdata2, ct_wren2, ct_rddata2);

endmodule: doublecrack
