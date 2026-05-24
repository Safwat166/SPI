module tdm (
    input   wire    [7:0]    tx_data ,
    input   wire             tx_valid ,
    input   wire             clk ,
    input   wire             rst_n ,
    output  reg              miso
) ;
    reg     [2:0]       cnt ;
    reg                 flag ;
    reg     [7:0]       tx_data_reg ;

/*-------------------------------------------------------
-- register tx_data
-------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx_data_reg <= 0 ;
        end

        else if(tx_valid) begin
            tx_data_reg <= tx_data ;
        end
    end

 /*-------------------------------------------------------
-- counter
-------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0 ;
            flag <= 0 ;
        end

        else if(tx_valid) begin
            cnt <= 0 ;
            flag <= 1 ;
        end

        else if(flag) begin
            cnt <= cnt + 1 ;
            if(cnt == 6) begin
                flag <= 0 ;
            end
        end
    end

/*-------------------------------------------------------
-- mux
-------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            miso <= 0 ;
        end
        else begin
            case(cnt)
                0 : miso <= tx_data_reg[7] ;
                1 : miso <= tx_data_reg[6] ;
                2 : miso <= tx_data_reg[5] ;
                3 : miso <= tx_data_reg[4] ;
                4 : miso <= tx_data_reg[3] ;
                5 : miso <= tx_data_reg[2] ;
                6 : miso <= tx_data_reg[1] ;
                7 : miso <= tx_data_reg[0] ;
                default : miso <= 1'b0 ;
            endcase
        end
    end
/*-----------------------------------------------------------------
-- kind note : miso will get sampled after 2 clock 
   cycles from which tx_valid get high because i 
   registered inputs of mux and registered miso
-----------------------------------------------------------------*/
endmodule