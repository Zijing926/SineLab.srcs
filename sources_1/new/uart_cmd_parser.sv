`timescale 1ns / 1ps
module uart_cmd_parser (
    input  logic        sys_clk,
    input  logic        sys_rst,
    // UART RX port（connect uart_rx module）
    input  logic [7:0]  rx_data,
    input  logic        rx_valid,
    // 输出到DDS的频率控制信号
    output logic [13:0] freq_set  // 0~9999，和滑块范围一致
);
    // 状态定义：解析"set freq xxx\r\n"
    typedef enum logic [2:0] {
        IDLE,
        RECV_S,
        RECV_E,
        RECV_T,
        RECV_SPACE,
        RECV_NUM
    } state_t;
    state_t state;
    logic [13:0] num_buf;  // 数值缓存
    logic [3:0]  num_cnt;  // 数值位数计数

    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            state   <= IDLE;
            freq_set<= 14'd1000;  // 默认频率
            num_buf <= 0;
            num_cnt <= 0;
        end else if (rx_valid) begin
            case (state)
                IDLE: begin
                    if (rx_data == "s") begin
                        state <= RECV_S;
                    end
                end
                RECV_S: begin
                    if (rx_data == "e") state <= RECV_E;
                    else state <= IDLE;
                end
                RECV_E: begin
                    if (rx_data == "t") state <= RECV_T;
                    else state <= IDLE;
                end
                RECV_T: begin
                    if (rx_data == " ") state <= RECV_SPACE;
                    else state <= IDLE;
                end
                RECV_SPACE: begin
                    if (rx_data >= "0" && rx_data <= "9") begin
                        num_buf <= (rx_data - "0");
                        num_cnt <= 1;
                        state <= RECV_NUM;
                    end else begin
                        state <= IDLE;
                    end
                end
                RECV_NUM: begin
                    if (rx_data >= "0" && rx_data <= "9") begin
                        // 数值左移一位+新数字（等价于×10+新数）
                        num_buf <= num_buf * 10 + (rx_data - "0");
                        num_cnt <= num_cnt + 1;
                    end else if (rx_data == "\r") begin
                        // 收到回车，解析完成
                        if (num_buf <= 14'd9999) begin
                            freq_set <= num_buf;  // 更新频率
                        end
                        state <= IDLE;
                        num_buf <= 0;
                        num_cnt <= 0;
                    end else begin
                        state <= IDLE;
                        num_buf <= 0;
                        num_cnt <= 0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule