module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

// your code here

logic [8:0] i; // Iterator

enum {IDLE, EXEC, DONE} state; 

logic handshake_complete; 
assign handshake_complete = rdy & en; 


always_comb begin
    if(i >= 9'b1_0000_0000 || state == IDLE || state == DONE) begin
        wren = 1'b0; 
    end
    else wren = 1'b1; 
end

always_ff @( posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i <= 9'b0; 
        // s <= 8'b0; 
        rdy <= 1'b0; 
        // wren <= 1'b0; 
        addr <= 8'b0000_0000; 
        wrdata <= 8'b0000_0000; 
        state <= IDLE; 
    end

    else begin
        case(state) 
        IDLE: begin
            i <= 9'b0_0000_0000; 
            rdy <= 1'b1; // Assert rdy to accept enable signal

            if(handshake_complete) begin // If request is recieved, begin execution
                state <= EXEC; 
                rdy <= 1'b0; 
            end 

            addr <= 8'b0000_0000; // Start from addr 0
            wrdata <= 8'b0000_0000; // Initial data to write is 0
        end

        EXEC: begin
            if(i <= 9'b0_1111_1111) begin
                addr <= addr + 8'b0000_0001; 
                wrdata <= wrdata + 8'b0000_0001; 
                i <= i + 9'b0_0000_0001; 
                // wren <= 1'b1; 
            end
            else if(i >= 9'b1_0000_0000) begin
                state <= DONE; 
            end
        end

        DONE: begin
            i <= 9'b0; 
            rdy <= 1'b1; 
            wrdata <= 8'b0000_0000; 
        end

        default: begin
            i <= 9'b0_0000_0000; 
            rdy <= 1'b0; // Assert rdy to accept enable signal
            wrdata <= 8'b0000_0000; // Initial data to write is 0
        end
        endcase
    end
    
end

endmodule: init