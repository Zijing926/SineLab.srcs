`timescale 1ns / 1ps

module uart_interface#(
    parameter CLK_FREQ = 100_000_000
)(
    input  logic        sys_clk,
    input  logic        sys_rst,
    input  logic [31:0] disp_data,   // BCD: Freq[31:16], Amp[15:0]
    output logic        uart_tx
);
	
    // 1. 1Hz 触发
    logic [31:0] tick_cnt;
    logic        tick_1s;

    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            tick_cnt <= 0;
            tick_1s  <= 0;
        end else begin
            tick_1s <= 0;
            if (tick_cnt == CLK_FREQ - 1) begin
                tick_cnt <= 0;
                tick_1s  <= 1;
            end else begin
                tick_cnt <= tick_cnt + 1;
            end
        end
    end

    // 2. UART 字节发送
    logic        uart_we;
    logic [7:0]  uart_data;
    logic        uart_busy;

    uart_byte_tx uart_tx_inst (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .data_in(uart_data),
        .we(uart_we),
        .data_out(uart_tx),
        .busy(uart_busy)
    );

    // 3. 发送状态机
    typedef enum logic [4:0] {
        IDLE,
        SEND_F, SEND_EQ,
        F1, F2, F3, F4, SEND_KHZ, SEND_SPACE,
        SEND_A, SEND_EQ2,
        A1, A2, A3, A4, SEND_MV,
        SEND_CR, SEND_LF
    } state_t;

    state_t state;

	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if (!sys_rst) begin
			state     <= IDLE;
			uart_we   <= 0;
			uart_data <= 0;
		end else if (!uart_busy) begin   // ✅ 只有 UART 空闲时才允许状态跳转
			case (state)
				IDLE: begin
					uart_we <= 0;
					if (tick_1s)
						state <= SEND_F;
				end

				SEND_F: begin
					uart_data <= "F";
					uart_we   <= 1;
					state     <= SEND_EQ;
				end

				SEND_EQ: begin
					uart_data <= "=";
					uart_we   <= 1;
					state     <= F1;
				end

				F1: begin
					uart_data <= 8'h30 + disp_data[31:28];
					uart_we   <= 1;
					state     <= F2;
				end

				F2: begin
					uart_data <= 8'h30 + disp_data[27:24];
					uart_we   <= 1;
					state     <= F3;
				end

				F3: begin
					uart_data <= 8'h30 + disp_data[23:20];
					uart_we   <= 1;
					state     <= F4;
				end

				F4: begin
					uart_data <= 8'h30 + disp_data[19:16];
					uart_we   <= 1;
					state     <= SEND_KHZ;
				end

				SEND_KHZ: begin
					uart_data <= "k";
					uart_we   <= 1;
					state     <= SEND_SPACE;
				end

				SEND_SPACE: begin
					uart_data <= " ";
					uart_we   <= 1;
					state     <= SEND_A;
				end

				SEND_A: begin
					uart_data <= "A";
					uart_we   <= 1;
					state     <= SEND_EQ2;
				end

				SEND_EQ2: begin
					uart_data <= "=";
					uart_we   <= 1;
					state     <= A1;
				end

				A1: begin
					uart_data <= 8'h30 + disp_data[15:12];
					uart_we   <= 1;
					state     <= A2;
				end

				A2: begin
					uart_data <= 8'h30 + disp_data[11:8];
					uart_we   <= 1;
					state     <= A3;
				end

				A3: begin
					uart_data <= 8'h30 + disp_data[7:4];
					uart_we   <= 1;
					state     <= A4;
				end

				A4: begin
					uart_data <= 8'h30 + disp_data[3:0];
					uart_we   <= 1;
					state     <= SEND_MV;
				end

				SEND_MV: begin
					uart_data <= "m";
					uart_we   <= 1;
					state     <= SEND_CR;
				end

				SEND_CR: begin
					uart_data <= 8'h0D;
					uart_we   <= 1;
					state     <= SEND_LF;
				end

				SEND_LF: begin
					uart_data <= 8'h0A;
					uart_we   <= 1;
					state     <= IDLE;
				end
			endcase
		end
	end

endmodule