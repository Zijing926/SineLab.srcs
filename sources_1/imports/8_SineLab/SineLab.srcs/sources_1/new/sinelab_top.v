`timescale 1ns / 1ps

module sinlab_top #(
	parameter GATE_CNT = 20_000_000
)(
	//system parameter
    input logic sys_clk,     // 100 MHz
    input logic sys_rst,     // active low
	//ADC input
	input logic vauxp3,
	input logic vauxn3,
	// key input（push high）, to control the frequency and amplitude of DDS
    input  	logic BTNL,        // BTNL - frequency - 10
    input  	logic BTNR,        // BTNR - frequency + 10
    input  	logic BTNU,        // BTNU - amplitude + 10
    input  	logic BTND,        // BTND - amplitude - 10
	
	input	logic [1:0] switch,	
	//switch[0]: switch from adc data to dds data;  switch[1]: measure the dds output/external output， not used yet
    output logic [7:0] an,
    output logic [7:0] seg,
	output logic [2:0] led,
	output logic 		UART_TX
);
	logic [15:0] adc_freq;
	logic [15:0] adc_amplitude;
	
	logic [15:0] generate_freq;
	logic [15:0] generate_amplitude;
	
	logic [31:0] sel_data;	//bin form
	logic [31:0] disp_data;	//bcd form
	
	//AD convertor
	ADC_measure #(
		.GATE_CNT(20_000_000)
	)ADC_measure_inst(
		//system parameter
		.sys_clk(sys_clk),     // 100 MHz
		.sys_rst(sys_rst),     // active low
		//ADC input
		.vauxp3(vauxp3),
		.vauxn3(vauxn3),
		
		.freq(adc_freq),
		.amplitude(adc_amplitude),
		.led(led)
	);
	//Generate sine wave
	Sine_generate Sine_generate_inst(
		.sys_clk(sys_clk),      // 100MHz
		.sys_rst(sys_rst),      // active low
		// key input（push high）
		.BTNL(BTNL),        	// BTNL - frequency - 10
		.BTNR(BTNR),        	// BTNR - frequency + 10
		.BTNU(BTNU),        	// BTNU - amplitude + 10
		.BTND(BTND),        	// BTND - amplitude - 10

		.freq(generate_freq),
		.amplitude(generate_amplitude)
	);
	//switch[0] = 0: digital tube shows the amp and freq of input wave(VAUX3). The unit of amp is mv.
	//switch[0] = 1: digital tube shows the amp and freq of output sinewave. amp ranges from 0 to 100.
	selector selector_inst(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),  				//active low
	.switch(switch[0]),
	.candidate_data_1({adc_freq, adc_amplitude}),
	.candidate_data_2({generate_freq, generate_amplitude}),
	
	.sel_data(sel_data)		//[31:0] sel_data: bin form
    );
	
	//bin to bcd
	bin2bcd bin2bcd_freq(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.bin(sel_data[31:16]),
		
		.bcd(disp_data[31:16])
	);
	
	bin2bcd bin2bcd_amp(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.bin(sel_data[15:0]),
		
		.bcd(disp_data[15:0])
	);	
	
	//digital tube display
	seg7_driver seg7_driver_inst(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.data(disp_data),
		.dp_en(8'b0000_0000),
		
		.an(an),
		.seg(seg)
	);
	//UART
	uart_interface uart_interface_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .disp_data(disp_data),
    .uart_tx(UART_TX)
	);
endmodule
