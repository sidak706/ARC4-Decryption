module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    // your code here

logic [7:0] j;
logic [8:0] i; 
logic [7:0] jval; 

logic [7:0] temp;
enum {IDLE, EXEC, COOLI, JUPDATE, ADDRJ, COOLJ, JREAD, ADDRI, ASSIGNWI, IWRITE, ADDRJW, ASSIGNWJ, JWRITE, DONE} state; 

logic handshake_complete; 
assign handshake_complete = rdy & en; 

logic [7:0] key_val; 

/*This always block is used to assert wren in IWRITE and JWRITE and to assign the correct part 
of key to key_val based on the value of i % 3 (used for the calculation of j in JUPDATE*/
always_comb begin
    if(state == IWRITE || state == JWRITE) begin
        wren = 1'b1; 
    end
    else wren = 1'b0; 

    case(i % 3)
    8'd0: key_val = key[23:16];
    8'd1: key_val = key[15:8];
    8'd2: key_val = key[7:0];
    default: key_val = key[23:16]; 
    endcase
end

/*IDLE, EXEC and DONE are the mandatory states since IDLE waits for handshake to be completed, EXEC drives the for loop, 
and DONE confirms the termination of the FSM.
COOLI, COOLJ states are required since each time we update the addr, it takes 1 cycle for it to be reflected. Hence,
these states are simply temporary states which allow for the correct value to reflected in addr before using it. 
JUPDATE is used to store the value of s[i] and update the value of j using the formula given. 
ADDRJ is used to assign j to addr. This state then transitions to COOLJ for the above described purpose. 
JREAD is used to read the value at addr j. rddata takes 2 cycles to update hence we transition to ADDRJ, then COOLJ before 
actually reading the value of rddata.
ADDRI is used to assign i to addr. 
ASSIGNWI is used to assign the value of jval to wrdata (essentially performing s[i] = j). We then transition to IWRITE
where wren is asserted. 2 states are required to write data to RAM since wrdata also takes 1 cycle to complete. 
ADDRJW, ASSIGNWJ, and JWRITE serve the same purpose, only for j instead of i. 
The only extra step in JWRITE is incrementing the value of i to ensure that the loop progresses.*/

always_ff @( posedge clk or negedge rst_n) begin
    // handshake_complete <= rdy & en; 
    if(!rst_n) begin
        i <= 9'b0_0000_0000; 
        rdy <= 1'b0; 
        addr <= 8'b0000_0000; // Start from addr 0
        wrdata <= 8'b0000_0000; // Initial data to write is 0
        temp = 8'b0000_0000;
        state <= IDLE; 
        j <= 8'b0; 
        // wren <= 1'b0; 
    end

    else begin
        case(state)
        IDLE: begin
            // wren <= 1'b0;
            i <= 9'b0_0000_0000; 
            rdy <= 1'b1; 
            addr <= 8'b0000_0000; // Start from addr 0
            wrdata <= 8'b0000_0000; // Initial data to write is 0
            temp <= 8'b0000_0000;
            if(handshake_complete) begin // If request is recieved, begin execution
                state <= EXEC; 
                rdy <= 1'b0; 
                // wren <= 1'b1; // Turning it on here performs s[0] = 0
            end 
        end

        EXEC: begin
            // wren <= 1'b0;
            if(i <= 9'b0_1111_1111) begin 
                addr <= i; 
                state <= COOLI; 
            end

            else if(i >= 9'b1_0000_0000) begin
                rdy <= 1'b1;
                state <= DONE; 
            end
        end
        
        COOLI: begin
            state <= JUPDATE;  
        end

        JUPDATE: begin
            temp <= rddata;
            j <= (j + rddata + key_val) % 256; // Should be 3 bytes
            state <= ADDRJ; 
        end

        ADDRJ: begin
            addr <= j; 
            state <= COOLJ; 
        end

        COOLJ: begin
            state <= JREAD; 
        end

        JREAD: begin
            jval <= rddata;  //jval = s[j]?
            state <= ADDRI; 
        end

        ADDRI: begin
            addr <= i; 
            state <= ASSIGNWI; 
        end

        ASSIGNWI: begin // (Assign wrdata i)
            wrdata <= jval;
            state <= IWRITE; 
        end

        IWRITE: begin
            state <= ADDRJW; 
        end

        ADDRJW: begin
            addr <= j; 
            state <= ASSIGNWJ; 
        end

        ASSIGNWJ: begin
            wrdata <= temp; 
            state <= JWRITE; 
        end

        JWRITE: begin
            wrdata <= temp; 
            state <= EXEC; 
            i <= i + 9'b0_0000_0001;
        end

        DONE: begin
            // wren <= 0;
            i <= 9'b0_0000_0000; 
            rdy <= 1'b0; 
            addr <= 8'b0000_0000;
            wrdata <= 8'b0000_0000; 
            temp <= 8'b0000_0000;
            state <= DONE; // NEED TO CONFIRM THIS BEHAVIOUR
        end

        default: begin
            // wren <= 0;
            i <= 9'b0_0000_0000; 
            rdy <= 1'b0; 
            addr <= 8'b0000_0000;
            wrdata <= 8'b0000_0000;
            temp <= 8'b0000_0000;
            state <= IDLE; 
        end
        endcase
    end
end


endmodule: ksa
