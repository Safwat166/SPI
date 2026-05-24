module counter(
    input   wire            clk , 
    input   wire            rst_n ,
    input   wire            ss_n ,
    output  reg     [3:0]   edge_cnt    //size 4-bits so i can sample 10 bits from MOSI
);

/*---------------------------------------------------------------
-- edge counter
---------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            edge_cnt <= 'b0 ;
        end
        else if(!ss_n) begin
            edge_cnt <= edge_cnt + 1 ;
        end
        else begin
            edge_cnt <= 'b0 ;
        end
    end
endmodule