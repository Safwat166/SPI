module spi (
    input   wire    MOSI ,
    input   wire    SS_n ,
    input   wire    clk ,
    input   wire    rst_n ,
    output  wire    MISO
) ;

/*-----------------------------------------
-- internal signals
-----------------------------------------*/
    wire     [3:0]   edge_cnt ;
    wire             dser_en ;
    wire     [3:0]   reg_mosi ;
    wire     [9:0]   rx_data ;
    wire             rx_valid ;
    wire     [7:0]   tx_data ;
    wire             tx_valid ;
    
/*-----------------------------------------
-- FSM instance
-----------------------------------------*/
    fsm f1 (
        .ss_n(SS_n),
        .mosi(MOSI),
        .edge_cnt(edge_cnt),
        .clk(clk),
        .rst_n(rst_n),
        .reg_mosi(reg_mosi),
        .dser_en(dser_en)
    ) ;

/*-----------------------------------------
-- counter instance
-----------------------------------------*/
    counter     c1 (
        .clk(clk),
        .rst_n(rst_n),
        .ss_n(SS_n),
        .edge_cnt(edge_cnt)
    );

/*-----------------------------------------
-- deserielizer instance
-----------------------------------------*/
    deserielizer    d1 (
        .mosi(MOSI) ,
        .reg_mosi(reg_mosi) ,
        .dser_en(dser_en) ,
        .edge_cnt(edge_cnt) ,
        .clk(clk) ,
        .rst_n(rst_n) ,
        .rx_data(rx_data) ,
        .rx_valid(rx_valid)
    );

/*-----------------------------------------
-- tdm instance
-----------------------------------------*/
    tdm    t1 (
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .clk(clk),
        .rst_n(rst_n),
        .miso(MISO)
    );

/*-----------------------------------------
-- ram instance
-----------------------------------------*/
    ram   #(.MEM_DEPTH(256) , .ADDR_SIZE(8))    r1 (
        .clk(clk) ,
        .rst_n(rst_n) ,
        .din(rx_data) ,
        .rx_valid(rx_valid) ,
        .tx_valid(tx_valid) ,
        .dout(tx_data)
    );

endmodule