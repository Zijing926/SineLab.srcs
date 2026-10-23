`timescale 1ns / 1ps

module freq_measure_tb();
	logic sys_clk, sys_rst;
	logic [15:0] 	adc_data;
	logic 			adc_valid;
	logic [13:0] 	freq_khz;
	logic 			freq_valid;
	
	always #5 sys_clk = ~sys_clk;// 100MHz
    
    initial begin		// 复位
        sys_clk = 0;
        sys_rst = 0;
        #100;
        sys_rst = 1;
    end

    // adc_valid：每 1040 ns 一个脉冲
    logic [15:0] valid_cnt;

    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (sys_rst == 0)
            valid_cnt <= 0;
        else if (valid_cnt == 103)
            valid_cnt <= 0;
        else
            valid_cnt <= valid_cnt + 1;
    end

    assign adc_valid = (valid_cnt == 103);

	// 生成 10 kHz 三角波
	logic [15:0] triangle;
	logic dir;

	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if (sys_rst == 0) begin
			triangle <= 800;
			dir <= 1;
		end
		else if (adc_valid) begin
			if (dir) begin
				triangle <= triangle + 16;
				if (triangle >= 1600)
					dir <= 0;
			end
			else begin
				triangle <= triangle - 16;
				if (triangle <= 800)
					dir <= 1;
			end
			adc_data <= triangle;
		end
	end
	
	freq_measure#(
		.GATE_CNT(100_000)
	)freq_measure_inst(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.adc_data(adc_data),
		.adc_valid(adc_valid),
		.offset(1200),
		
		.freq_khz(freq_khz),
		.freq_valid(freq_valid)
	);
endmodule
