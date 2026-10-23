`timescale 1ns / 1ps

module uart_byte_tx(
    input logic         sys_clk,
	input logic 		sys_rst,
    input logic [7:0]   data_in,		//parallel data input
    input logic         we,
    output logic        data_out,		//serial data output
    output logic        busy
    );
    parameter   WAIT_DIV = 868; //100MHz/115200 bps This is a constant that can be changed
    localparam WAIT_LEN = $clog2(WAIT_DIV); //ceiling log2()
    
    typedef enum
    {
        STATE_IDLE,
        STATE_SEND
    } state_type;
    state_type              state,n_state;          //state of the state machine
    logic       [9:0]       data_reg,n_data_reg;    //the value to be stored
    logic [WAIT_LEN-1:0]    wait_cnt,n_wait_cnt;    //the value of the waiting time counter
    logic       [3:0]       bit_cnt,n_bit_cnt;      //the number of bits sent
    
    assign data_out = data_reg[0];  
    
    always_comb begin
        busy    =   1'b0;
        n_state =   state;
        n_wait_cnt = wait_cnt;
        n_bit_cnt = bit_cnt;
        n_data_reg = data_reg;
        if (state == STATE_IDLE) begin
            if (we) begin
                n_state = STATE_SEND;
                n_data_reg = {1'b1, data_in, 1'b0}; //UART sends data from the lowest bit
            end
        end
        else if (state == STATE_SEND) begin
            busy = 1'b1;
            if (wait_cnt == WAIT_DIV - 1) begin
                if(bit_cnt == 4'd9) begin
                    n_state = STATE_IDLE;
                    n_wait_cnt = 0;
                    n_bit_cnt = 4'd0;
                end
                else begin
                    n_data_reg = {1'b1,data_reg[9:1]};  
                    n_wait_cnt = 0;
                    n_bit_cnt = bit_cnt + 1'b1;
                end
            end
            else begin
                n_wait_cnt = wait_cnt + 1'b1;
            end
        end
    end
    
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            state   <= STATE_IDLE;
            wait_cnt <= 0;
            bit_cnt <= 4'd0;
            data_reg <= 10'b11_1111_1111;
        end else begin
            state <= n_state;
            wait_cnt <= n_wait_cnt;
            bit_cnt <= n_bit_cnt;
            data_reg <= n_data_reg;
        end
    end
endmodule

