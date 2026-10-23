`timescale 1ns/1ps


module amplitude_measure_tb();

    logic        sys_clk;
    logic        sys_rst;
    logic [15:0] adc_data;
    //logic        adc_valid;
    logic [15:0] amplitude;
    logic        amp_valid;
	logic [15:0] offset;

    always #5 sys_clk = ~sys_clk;// 100MHz
    
    initial begin		// 复位
        sys_clk = 0;
        sys_rst = 0;
        #100;
        sys_rst = 1;
    end
	/*
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

    assign adc_valid = (valid_cnt == 103);*/

    initial begin
		adc_data <= 0;
		#150
		for(integer i = 0; i<100000; i=i+1) begin
			#10
			adc_data = 500+500*$sin(2*3.14159*i/50);
		end
	end

    amplitude_measure #(
		.SAMPLE_WINDOW(10_000)
	)amplitude_measure_inst(
        .sys_clk	(sys_clk),
        .sys_rst	(sys_rst),
        .adc_data	(adc_data),
        //.adc_valid	(adc_valid),
        .amplitude	(amplitude),
        .amp_valid	(amp_valid),
		.offset		(offset)
    );

endmodule