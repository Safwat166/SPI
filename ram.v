module ram #(
    parameter MEM_DEPTH = 256 ,
    parameter ADDR_SIZE = 8 
) (
    input   wire            clk ,
    input   wire            rst_n ,
    input   wire    [9:0]   din ,
    input   wire            rx_valid ,
    output  reg             tx_valid ,
    output  reg     [7:0]   dout
);

/*--------------------------------------------------------------
-- memory
--------------------------------------------------------------*/
    reg    [ADDR_SIZE-1 : 0]    mem     [MEM_DEPTH-1 : 0] ;

/*--------------------------------------------------------------
-- internal register
--------------------------------------------------------------*/
    reg    [ADDR_SIZE-1 : 0]    internal_reg ;

/*--------------------------------------------------------------
-- always block
--------------------------------------------------------------*/
    always @ (posedge clk) begin    // i made it sync reset to map on memory for fpga
        if(!rst_n) begin
            dout <= 'b0 ;
            tx_valid <= 1'b0 ;
            internal_reg <= 'b0 ;
        end

        else begin  
            tx_valid <= 0 ;
            if(rx_valid) begin
                case(din[9:8])
                    'b00 : begin
                        internal_reg <= din[7:0] ;
                        tx_valid <= 1'b0;
                    end
                    'b01 : begin
                        mem[internal_reg] <= din[7:0] ;
                        tx_valid <= 1'b0;
                    end
                    'b10 : begin
                        internal_reg <= din[7:0] ;
                        tx_valid <= 1'b0;
                    end
                    'b11 : begin
                        tx_valid <= 1'b1 ;
                        dout <= mem[internal_reg] ;
                    end
                endcase 
            end        
        end
    end
endmodule