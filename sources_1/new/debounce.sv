`timescale 1ns / 1ps

module debounce #(
    parameter CNT_MAX = 20'd999_999  // 10ms @100MHz
)(
    input  logic       sys_clk,
    input  logic       sys_rst,
    input  logic       btn_in,
    output logic       btn_out
);

    logic [19:0] cnt;  

    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)
            cnt <= 1'b0;
        else if (!btn_in)           // 按键松开（低电平）时，计数器清零
            cnt <= 1'b0;
        else if (cnt < CNT_MAX)     // 按键按下（高电平）且未计满时，继续计数
            cnt <= cnt + 1'b1;
        // 计满后保持，防止溢出
    end

    // 在计满的前一个周期输出脉冲（持续1个时钟周期）
    assign btn_out = (cnt == CNT_MAX - 1'b1);

endmodule