`timescale 1ns / 1ns


module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200      
)(
    input logic sys_clk, sys_rst,
    input logic rx,                     //input data
    output logic [7:0] output_data,     //output data
    output logic       effective_flag  //effective_flag = 1 only when (stop bit == 1)
);
//local parameter
localparam int CLK_CNT_MAX = CLK_FREQ / BAUD_RATE; // 868
//state define
typedef enum{
    IDLE,
    START,      //start bit detect
    DATA,       //data bit receive
    STOP        //stop bit detect
} state_type;

//signal declaraion
state_type state, n_state;
logic [10:0]    clk_cnt;        //clk_cnt starts to count when transmitting data(state != IDLE)
logic           data_flag;      //data_flag turns to '1' when clk_cnt == CLK_CNT_HALF
logic [3:0]     bit_cnt;    
logic [7:0]     rx_data;        //Temporarily store the output data
logic           finish_flag;    


//state register
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst) 
        state <= IDLE;
    else
        state <= n_state;
end

always_comb begin
    case(state)
        IDLE:
            if(rx == 1'b0)
                n_state = START; //detecting the posedge of start bit
			else
				n_state = IDLE;
        START:
            if(clk_cnt == CLK_CNT_MAX - 1)
                n_state = DATA;
			else
				n_state = START;
        DATA:
            if((clk_cnt == CLK_CNT_MAX - 1) && (bit_cnt == 4'd8))
                n_state = STOP;
			else
				n_state = DATA;
        STOP:
            if(clk_cnt == CLK_CNT_MAX - 1)
                n_state = IDLE;
			else
				n_state = STOP;
        default: n_state = IDLE;
    endcase
end

//clk_cnt: clock counter.
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        clk_cnt <= 1'b0;
    else if(state == IDLE)
        clk_cnt <= 1'b0;
    else if(clk_cnt == CLK_CNT_MAX-1)
        clk_cnt <= 1'b0;
    else
        clk_cnt <= clk_cnt + 1;
end

//data_flag: data_flag turns to '1' when clk_cnt == CLK_CNT_HALF
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        data_flag <= 1'b0;
    else if(state != DATA)
        data_flag <= 1'b0;
    else if(clk_cnt == CLK_CNT_MAX/2 - 1)
        data_flag <= 1'b1;
    else
        data_flag <= 1'b0;
end

//rx_data: Temporarily store the output data
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        rx_data <= 8'd0;
    else if(data_flag == 1'b1)
        rx_data <= {rx, rx_data[7:1]};
end

//bit_cnt: bit counter.
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        bit_cnt <= 1'b0;
    else if(state != DATA)
        bit_cnt <= 1'b0;
    else if((bit_cnt == 4'd8) && (clk_cnt == CLK_CNT_MAX - 1))
        bit_cnt <= 1'b0;
    else if(data_flag == 1'b1)
        bit_cnt <= bit_cnt + 1; 
end

//finish_flag: pulse when finishing receiving 1 Byte of data
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        finish_flag <= 1'b0;
    else if ((state == STOP) && (clk_cnt == CLK_CNT_MAX/2 - 1))
        finish_flag <= 1'b1;
    else
        finish_flag <= 1'b0;
end

//effective_flag: pulse when (stop bit==1).
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        effective_flag <= 1'b0;
    else if((state == STOP) && (rx == 1))
        effective_flag <= finish_flag;
end 

//output_data: 
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
        output_data <= 8'h0;
    else if (effective_flag == 1'b1)
        output_data <= rx_data;
end


endmodule
