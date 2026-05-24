module fsm (
    input       wire             ss_n ,
    input       wire             mosi ,
    input       wire     [3:0]   edge_cnt ,
    input       wire             clk ,
    input       wire             rst_n ,
    output      reg      [3:0]   reg_mosi ,
    output      reg              dser_en 
) ;

/*---------------------------------------------------------------
-- states
---------------------------------------------------------------*/
    typedef enum logic [2:0] {
                IDLE       = 3'b000 ,
                CHK_CMD    = 3'b001 ,
                WRITE      = 3'b010 ,
                READ_ADD   = 3'b011 ,
                READ_DATA  = 3'b100 
    } state;

    // parameter   IDLE       = 3'b000 ,
    //             CHK_CMD    = 3'b001 ,
    //             WRITE      = 3'b010 ,
    //             READ_ADD   = 3'b011 ,
    //             READ_DATA  = 3'b100 ;
                
    // (*fsm_encoding = "one_hot"*)
    //(*fsm_encoding = "sequential"*)
    //(*fsm_encoding = "gray"*)

    state   next_state , current_state ;

/*--------------------------------------------------------------------------
-- signal to allow spi slave to differitiate between 
    read and address operation for write and read so
    i will store first 3 bits also i will send them to deserielizer 
    because deserielizer is waiting 4 clock cycle to turn on (deser_en = 1)
    so all this time deserielizer won't be able to accept first 3  bits
---------------------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_mosi <= 'b0 ;
        end
        else if(!ss_n) begin
            case(edge_cnt)
                0 : reg_mosi[3] <= mosi ;  //start bit
                1 : reg_mosi[2] <= mosi ;  //first bit
                2 : reg_mosi[1] <= mosi ;  //second bit
                3 : reg_mosi[0] <= mosi ;  //third bit
            endcase
        end
    end
/*---------------------------------------------------------------
-- current state logic
---------------------------------------------------------------*/
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= IDLE ;
        end

        else begin
            current_state <= next_state ;
        end
    end

/*---------------------------------------------------------------
-- next state logic and output logic
---------------------------------------------------------------*/
    always @ (*) begin
        dser_en = 0 ;

        case(current_state)
            IDLE : begin
                if(!ss_n) begin
                    next_state = CHK_CMD ;
                end
                else begin
                    next_state = IDLE ;
                end
            end

            CHK_CMD : begin
                if(!ss_n && (edge_cnt == 3)) begin
                    case(reg_mosi[3:1])
                        'b000 : next_state = WRITE ;
                        'b001 : next_state = WRITE ;
                        'b110 : next_state = READ_ADD ;
                        'b111 : next_state = READ_DATA ;
                        default : next_state = IDLE ;
                    endcase

                end

                else begin
                    next_state = CHK_CMD ;   //waiting 3 clock cycles
                end
            end

            WRITE : begin
                dser_en = 1 ;
                if(!ss_n) begin
                    next_state = WRITE ;
                end

                else begin
                    next_state = IDLE ;
                end
            end

            READ_ADD : begin
                dser_en = 1 ;
                if(!ss_n) begin
                    next_state = READ_ADD ;
                end

                else begin
                    next_state = IDLE ;
                end
            end

            READ_DATA : begin
                dser_en = 1 ;
                if(!ss_n) begin
                    next_state = READ_DATA ;
                end

                else begin
                    next_state = IDLE ;
                end
            end

            default : next_state = IDLE ;
        endcase
    end

endmodule