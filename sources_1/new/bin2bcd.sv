`timescale 1ns / 1ps

module bin2bcd (
    input  logic        sys_clk,
    input  logic        sys_rst,
    input  logic [15:0] bin,   // 0~9999 需 14bit
    output logic [15:0] bcd    // 4 digit BCD
);

    logic [31:0] shift;
	logic [31:0] shift_next;  // ✅ 临时变量
    logic [4:0]  cnt;
    logic        busy;
	
    // ✅ 组合逻辑：计算调整后的移位值
    always_comb begin
        shift_next = shift;
        if (shift_next[31:28] >= 5) shift_next[31:28] = shift_next[31:28] + 3;
        if (shift_next[27:24] >= 5) shift_next[27:24] = shift_next[27:24] + 3;
        if (shift_next[23:20] >= 5) shift_next[23:20] = shift_next[23:20] + 3;
        if (shift_next[19:16] >= 5) shift_next[19:16] = shift_next[19:16] + 3;
        shift_next = shift_next << 1;  // 调整后再移位
    end
	
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            shift <= 0;
            bcd   <= 0;
            cnt   <= 0;
            busy  <= 0;
        end else begin
            if (!busy) begin
                shift <= {16'b0, bin}; // [31:16]=BCD, [15:0]=BIN
                cnt   <= 0;
                busy  <= 1;
            end else if (cnt < 16) begin
                shift <= shift_next;
                cnt   <= cnt + 1;
            end else begin
                bcd  <= shift[31:16];
                busy <= 0;
            end
        end
    end

endmodule