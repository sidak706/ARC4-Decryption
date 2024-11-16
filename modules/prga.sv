module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // your code here
logic [8:0] i, j, k, k2, pad_val; // Might need to make pad_val 8 bits instead of 9
logic [8:0] message_length;
logic [7:0] temp, temp2;
logic [7:0] jval; 
logic [7:0] pad [0:255];
// logic [8:0] cipher_text;
logic [7:0] combined; 

logic [7:0] ct_val; 

logic [7:0] pad_addr; 

logic valid ;

logic handshake_complete;
assign handshake_complete = en & rdy;

enum {CTLOADADDR, CTLOADRD, LOADMSGL, IDLE, EXEC,
LOADADDRI, COOLI, JUPDATE, LOADADDRJ, COOLJ, 
JREAD, LOADADDRIA, ASSIGNWI, ASSIGNWJ, IWRITE, LOADADDRJA, JWRITE, 
COOLC, GETCOMBINED, PADWRITE, COOLPADCT, RDPADCT,
ASSIGNWPT, PTWRITE, DONE} state; 

always_comb begin
    if(state == JWRITE || state == IWRITE) begin
        s_wren = 1'b1; 
    end
    else s_wren = 1'b0; 

    if(state == PTWRITE || state == COOLI) begin // Asserting pt_wren in COOLI allows pt[0] = message_length to happen
        pt_wren = 1'b1; 
    end
    else pt_wren = 1'b0; 
 
end


/*Before enabling ready, set up message_length. Then start execution of algo*/

always_ff @(posedge clk) begin
    if(!rst_n) begin
        i = 9'b0_0000_0000; 
        j <= 9'b0_0000_0000; 
        k <= 9'b0_0000_0001; 
        s_addr <= 8'b0000_0000; 
        s_wrdata <= 8'b0000_0000; 
        message_length <= 9'b0_0000_0000;

        rdy <= 1'b0; 
        state <= CTLOADADDR; 
    end

    // else begin
        case(state) 
        CTLOADADDR: begin
            ct_addr <= 8'b0000_0000; 
            state <= CTLOADRD; 
        end
        CTLOADRD: begin
            state <= LOADMSGL; 
        end

        LOADMSGL: begin
            message_length <= ct_rddata; 
            // message_length <= 8'd73; // NEED TO FIX!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
            state <= IDLE; 
        end

        IDLE: begin
            i = 9'b0_0000_0000; 
            j <= 9'b0_0000_0000; 
            k <= 9'b0_0000_0001; 
            k2 <= 9'b0_0000_0001;
            rdy <= 1'b1; 
            pt_addr <= 8'b0000_0000; 
            pt_wrdata <= message_length; 
            valid <= 1'b1; 
            if(handshake_complete) begin
                state <= EXEC; 
                rdy <= 1'b0; 
            end
        end

        EXEC: begin
            if(k <= message_length) begin
                i = (i + 1) % 256;
                s_addr <= i; // 1) Go to addr i
                pad_addr <= k; 
                // state <= LOADADDRI;
                state <= COOLI;  
            end

            else begin
                if(k2 <= message_length && valid) begin
                    pad_addr <= k2; 
                    pt_addr <= k2; 
                    ct_addr <= k2; 
                    state <= COOLPADCT; 
                end
                else begin
                    rdy <= 1'b1; 
                    state <= DONE; 
                end
            end
        end

        // LOADADDRI: begin
        //     state <= COOLI; 
        // end

        COOLI: begin
            state <= JUPDATE;  
        end

        JUPDATE: begin
            temp <= s_rddata; // 2) Read value of s[i] & store it in temp 
            j <= (j + s_rddata) % 256; // Compute j
            state <= LOADADDRJ; 
        end

        LOADADDRJ: begin
            s_addr <= j; // 3) Go to addr j
            state <= COOLJ; 
        end

        COOLJ: begin
            state <= JREAD; 
        end

        JREAD: begin
            jval <= s_rddata; // 4) Read value of s[j] and store it in jval
            // s_wrdata <= s_rddata; 
            state <= LOADADDRIA;
        end

        LOADADDRIA: begin
            s_addr <= i; 
            state <= ASSIGNWI;
        end

        ASSIGNWI: begin
            s_wrdata <= jval; 
            state <= IWRITE; 
        end 

        IWRITE: begin
            state <= LOADADDRJA; 
        end

        LOADADDRJA: begin
            s_addr <= j; 
            state <= ASSIGNWJ; 
        end

        ASSIGNWJ: begin
            s_wrdata <= temp; 
            state <= JWRITE; 
        end

        JWRITE: begin
            // Put states for pad[k]
            // s[i] = jval
            // s[j] = temp
            s_addr <= (jval + temp) % 256;
            state <= COOLC; // Cool down period for combined addr
        end

        COOLC: begin
            state <= GETCOMBINED;
        end

        GETCOMBINED: begin
            combined <= s_rddata; 
            state <= PADWRITE; 
        end

        PADWRITE: begin
            pad[pad_addr] <= combined;
            k <= k + 9'b0_0000_0001;  
            state <= EXEC; 
        end


        COOLPADCT: begin
            state <= RDPADCT; 
        end

        RDPADCT: begin
            pad_val <= pad[pad_addr]; 
            ct_val <= ct_rddata; 
            state <= ASSIGNWPT; 
        end

        ASSIGNWPT: begin
            pt_wrdata <= pad_val ^ ct_val; 
            if(pt_wrdata < 8'b0010_0000 || pt_wrdata > 8'b0111_1110) valid <= 1'b0; 
            state <= PTWRITE; 
        end

        PTWRITE: begin
            k2 <= k2 + 9'b0_0000_0001;
            state <= EXEC; 
        end

        DONE: begin
            // rdy <= 1'b0; 
            rdy <= 1'b1; 
            state <= IDLE; 
            valid <= 1'b1; 
        end

        endcase
    // end
end


endmodule: prga
