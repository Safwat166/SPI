module spi_tb ();
/*-----------------------------------------
-- signals
-----------------------------------------*/
    reg             MOSI_tb ;
    reg             SS_n_tb ;
    reg             clk_tb ;
    reg             rst_n_tb ;
    wire            MISO_tb ;
    
    bit     [7:0]   address_reg ;
    bit     [7:0]   data_reg ;
    integer         i ;
    integer         k ;
    integer         cnt ;
/*-----------------------------------------
-- instance
-----------------------------------------*/
    spi    DUT    (
        .MOSI(MOSI_tb) ,
        .SS_n(SS_n_tb) ,
        .clk(clk_tb) ,
        .rst_n(rst_n_tb) ,
        .MISO(MISO_tb)
    );

/*-----------------------------------------
-- clock generation
-----------------------------------------*/
    initial begin
        clk_tb = 0 ;
        forever begin
            #5  clk_tb = ~clk_tb ;
        end
    end

/*-----------------------------------------
-- initial block
-----------------------------------------*/
    initial begin
        $readmemb("mem.dat" , DUT.r1.mem) ;
        cnt = 0 ;
        $fsdbDumpfile("waves.fsdb") ;
        $fsdbDumpvars(0, spi_tb) ;

        //reset functionality
        rst_n_tb = 0 ;
        MOSI_tb = 0 ;
        SS_n_tb = 1 ;
        @(negedge clk_tb) ;

        for(k = 0 ; k<1000 ; k = k + 1) begin

            //write adderess operation
            rst_n_tb = 1 ;
            SS_n_tb = 0 ;   // start communication
            for(i = 0 ; i < 3 ; i = i+1) begin  //specify operation
                MOSI_tb = 1'b0 ;
                @(negedge clk_tb) ;
            end 
            
            for(i = 0 ; i<8 ; i = i+1) begin
                MOSI_tb = $random ;
                address_reg[7-i] = MOSI_tb ;
                @(negedge clk_tb) ;
            end
            SS_n_tb = 1 ; //end communication
            repeat(2) @(negedge clk_tb) ;
            

            //write data operation
            rst_n_tb = 1 ;
            SS_n_tb = 0 ;   // start communication
            for(i = 0 ; i < 3 ; i = i+1) begin  //specify operation
                if(i == 0)       MOSI_tb = 0 ;
                else if(i == 1)  MOSI_tb = 0 ;
                else if(i == 2)  MOSI_tb = 1 ;
                @(negedge clk_tb) ;
            end 

            for(i = 0 ; i<8 ; i = i+1) begin
                MOSI_tb = $random ;
                data_reg[7-i] = MOSI_tb ;
                @(negedge clk_tb) ;
            end
            SS_n_tb = 1 ; //end communication
            repeat(2) @(negedge clk_tb) ;


            //read address operation
            rst_n_tb = 1 ;
            SS_n_tb = 0 ;   // start communication
            for(i = 0 ; i < 3 ; i = i+1) begin  //specify operation
                if(i == 0)   MOSI_tb = 1 ;
                else if(i == 1)  MOSI_tb = 1 ;
                else if(i == 2)  MOSI_tb = 0 ;
                @(negedge clk_tb) ;
            end 

            for(i = 0 ; i<8 ; i = i+1) begin
                MOSI_tb = address_reg[7-i] ;
                @(negedge clk_tb) ;
            end
            SS_n_tb = 1 ; //end communication
            repeat(2) @(negedge clk_tb) ;        

            //read data operation
            rst_n_tb = 1 ;
            SS_n_tb = 0 ;   // start communication
            for(i = 0 ; i < 3 ; i = i+1) begin  //specify operation
                if(i == 0)   MOSI_tb = 1 ;
                else if(i == 1)  MOSI_tb = 1 ;
                else if(i == 2)  MOSI_tb = 1 ;
                @(negedge clk_tb) ;
            end 

            for(i = 0 ; i<8 ; i = i+1) begin
                MOSI_tb = $random ;  //dummy bits in read data operation
                @(negedge clk_tb) ;
            end
            SS_n_tb = 1 ; //end communication
            repeat(11) @(negedge clk_tb) ;  

            //comparing mechanism
            if(DUT.tx_data != data_reg) begin
                $display("failed operation") ;
            end
            else begin
                cnt = cnt + 1 ;
            end
        end    

        $display("successfull operation : %0d/1000" , cnt) ;

        #5 ;
        $stop ;
    end
endmodule 
