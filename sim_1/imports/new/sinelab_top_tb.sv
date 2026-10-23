`timescale 1ns / 1ps

module sinelab_top_tb();

	logic sys_clk, sys_rst;
	logic [7:0] an;
	logic [7:0] seg;
	logic [2:0] led;
	initial begin
		sys_clk = 0;
		sys_rst = 0;
		#200
		sys_rst = 1;
	end
	always #5 sys_clk=~sys_clk;
	sinlab_top #(
		.GATE_CNT(100_000),
		.SAMPLE_WINDOW(512)
	)dut(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.vn_in(0),
		.vp_in(0),
		
		.an(an),
		.seg(seg),
		.led(led)
	);
	
    // 5. 监控输出（调试神器）
    // 监控 LED 状态
    always @(posedge sys_clk) begin
        if (led[0]) $display("[%0t] ADC Valid Pulse!", $time);
        if (led[1]) $display("[%0t] FREQ Valid! Freq = %0d", $time, dut.freq);
        if (led[2]) $display("[%0t] AMP Valid! Amp = %0d", $time, dut.amplitude);
    end

    // 解码数码管显示的数字
    logic [31:0] disp_num;
    assign disp_num = {dut.freq[15:0], dut.amplitude[15:0]};

    always @(posedge sys_clk) begin
        if (led[1]) begin // 频率更新时打印
            $display("======================================");
            $display("Time: %0t ns", $time);
            $display("Frequency: %0d Hz", dut.freq);
            $display("Amplitude: %0d (Raw)", dut.amplitude);
            $display("Display Data: %h", disp_num);
            $display("======================================");
        end
    end
endmodule
