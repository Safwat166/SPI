module deserielizer (
    input       wire            mosi ,
    input       wire    [3:0]   reg_mosi ,
    input       wire            dser_en ,
    input       wire    [3:0]   edge_cnt ,
    input       wire            clk ,
    input       wire            rst_n ,
    output      reg     [9:0]   rx_data ,
    output      reg             rx_valid
) ;

/*--------------------------------------------------------
-- always block
--------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_data  <= 'b0 ;
            rx_valid <= 'b0 ;
        end

        else begin
            rx_valid <= 1'b0 ;
            if(dser_en && edge_cnt != 11) begin
                rx_data[9:7] <= reg_mosi[2:0] ;    //registered first 3 bits excluding start bit
                rx_data[6:0] <= {rx_data[6:0] , mosi} ;
            end
            
            if(edge_cnt == 11) begin
                rx_valid <= 1'b1 ;
            end
        end
    end
endmodule 