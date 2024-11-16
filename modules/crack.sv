module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata, 
             input logic [7:0] start_val, output logic [7:0] message_length_output
         /* any other ports you need to add */);

    logic en_arc, rst_arc, rdy_arc;
    logic [7:0] pt_addr, pt_rddata, pt_wrdata;
    logic pt_wren;

    logic [7:0] pt_addr_arc, pt_wrdata_arc;
    logic pt_wren_arc;

    logic [7:0] pt_addr_crack, pt_wrdata_crack;
    logic pt_wren_crack;

    // logic [7:0] ct_addr_arc, ct_rddata_arc;
    logic [7:0] message_length;
    logic handshake_complete;

    logic [8:0] i; 
    logic valid; 


    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);

    arc4 a4(clk, rst_arc, 
            en_arc, rdy_arc, 
            key, 
            ct_addr, ct_rddata, 
            pt_addr_arc, pt_rddata, pt_wrdata_arc, pt_wren_arc);

    assign handshake_complete = en & rdy;

    assign message_length_output = message_length; 

    enum {WAITHANDSHAKE, RESET_ARC, WAIT_ARC, 
    UNENABLE_ARC, TRANSITIONARC, RDY_CRACK, 
    WAITCRACKHANDSHAKE, EXEC, COOLPT, READPT, DONE, UNRESET_ARC, COOLCRACK, COOL2} state;
    
    always_ff @(posedge clk) begin
        if(ct_addr == 8'b0) message_length = ct_rddata; 

        if(!rst_n) begin
            rdy <= 1'b1; 
            key <= start_val; 
            en_arc <= 1'b0; 
            i <= 9'b1; 
            state <= WAITHANDSHAKE; 
            key_valid <= 1'b0; 
            // ct_addr_crack <= 8'b0; 
        end
        else begin
            
            case(state)
            WAITHANDSHAKE: begin
                if(handshake_complete) begin
                    rdy <= 1'b0; 
                    state <= RESET_ARC; 
                end
            end
            RESET_ARC: begin
                rst_arc <= 1'b0; // Assert arc rst 
                valid <= 1'b1; 
                i <= 9'b1; 
                state <= UNRESET_ARC; 
            end
            UNRESET_ARC: begin
                rst_arc <= 1'b1; 
                state <= WAIT_ARC; 
            end

            WAIT_ARC: begin
                en_arc <= 1'b0; 
                // rst_arc <= 1'b1; 
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
                    // ct_addr_crack <= 8'b0; 
                    state <= RDY_CRACK;
                end
            end
            RDY_CRACK: begin
                rdy <= 1'b1; 
                pt_addr_crack <= 8'd1; 
                state <= EXEC; 
            end

            EXEC: begin
                // if((i <= 9'b0_1111_1111) & (valid == 1'b1)) begin
                // message_length = ct_rddata; 
                if((i <= message_length) && (valid == 1'b1)) begin
                    pt_addr_crack <= i[7:0]; 
                    state <= COOLPT; 
                end

                else begin
                    if(!valid) begin
                        key <= key + 24'd2; // Increment key by 2, reset arc, and start the process again
                        // i <= 9'b0; 
                        state <= RESET_ARC; 
                    end
                    else begin
                        state <= DONE; 
                    end
                end
            end

            COOLPT: begin
                state <= READPT; 
            end

            READPT: begin
//                0010_0000
                if(pt_rddata < 8'b0010_0000 || pt_rddata > 8'b0111_1110) begin // If invalid entry, turn off valid flag and return to exec
                    valid = 1'b0; 
                end
                state <= EXEC; 
                i <= i + 9'b0_0000_0001; // Increment i
            end

            DONE: begin
                key_valid <= 1'b1; // Set key_valid to 1 if in this state
            end

            endcase
        end

    end

//    enum {WAITHANDSHAKE, RESET_ARC, WAIT_ARC, UNENABLE_ARC, TRANSITIONARC, RDY_CRACK, WAITCRACKHANDSHAKE, EXEC, COOLPT, READPT, DONE} state;


    always_comb begin
        if(state == WAITHANDSHAKE || state == RESET_ARC || state == WAIT_ARC || state == UNENABLE_ARC || state == TRANSITIONARC) begin
            pt_addr = pt_addr_arc; 
            pt_wrdata = pt_wrdata_arc; 
            pt_wren = pt_wren_arc; 

            // ct_addr = ct_addr_arc;
        end
        else begin
            pt_addr = pt_addr_crack; 
            pt_wrdata = pt_wrdata_crack; 
            // pt_wren = pt_wren_crack; 
            pt_wren = 1'b0; 

            // ct_addr = ct_addr_crack; 
        end 
    end

endmodule: crack
