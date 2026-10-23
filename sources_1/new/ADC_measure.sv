`timescale 1ns / 1ps

module ADC_measure #(
	parameter GATE_CNT = 20_000_000
)(
	//system parameter
    input logic sys_clk,     // 100 MHz
    input logic sys_rst,     // active low
	//ADC input
	input logic vauxp3,
	input logic vauxn3,
	
    output logic [15:0] freq,
	output logic [15:0] amplitude,
	output logic [2:0] 	led
);

logic [15:0] adc_data;
logic adc_valid;

logic amp_valid;
logic freq_valid;

logic busy_out;			//useless

//ADC
logic [4:0] channel_out;
logic eoc_out;				//end of eonversion
logic den_in;				//adc enable

always_ff @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst) begin
        den_in <= 1'b0;
    end else begin
        den_in <= eoc_out;            // one clock delay
    end
end

xadc_wiz_0 xadc_wiz_0_inst (
  .di_in(16'b0),              // input data bus for the DRP
  .daddr_in({2'b00,channel_out}),        // address bus for the DRP
  .den_in(den_in),            // enable signal for the DRP
  .dwe_in(1'b0),            // write enable for the DRP
  .drdy_out(adc_valid),        // output wire drdy_out
  .do_out(adc_data),            // output data bus for the DRP
  .dclk_in(sys_clk),          // Clock input for the DRP
  .reset_in(~sys_rst),        // input wire reset_in
  .vp_in(0),              
  .vn_in(0),             
  .vauxp3(vauxp3),
  .vauxn3(vauxn3),
  .channel_out(channel_out),  // channel selection outputs
  .eoc_out(eoc_out),          // End of conversion.
  .alarm_out(),      // output wire alarm_out
  .busy_out(busy_out)        // ADC busy signal. High during an ADC conversion. 
);

//amplitude
logic [15:0] 	offset;
amplitude_measure #(
	.SAMPLE_WINDOW(GATE_CNT)
)amplitude_measure_inst(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.adc_data(adc_data),
	
	.amplitude(amplitude),
	.amp_valid(amp_valid),
	.offset(offset)
);
// frequency
freq_measure #(
    .GATE_CNT(GATE_CNT)
) freq_measure_inst (
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),
    .measured_data(adc_data),
	.offset(offset),
	
    .freq_khz(freq),
    .freq_valid(freq_valid)
);

// LED shows status of ADC, freq_valid and amp_valid
// adc status 
logic adc_vld_led;
always_ff @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst)
		adc_vld_led <= 0;
	else if (adc_valid)
        adc_vld_led <= ~adc_vld_led;
end
//frequency status blink
logic freq_vld_led;
always_ff @(posedge sys_clk) begin
    if(!sys_rst)
		freq_vld_led <= 0;
    else if (freq_valid)
        freq_vld_led <= ~freq_vld_led;
end
//amplitude status blink
logic amp_vld_led;
always_ff @(posedge sys_clk) begin
	if(~sys_rst)
		amp_vld_led <= 0;
	else if (amp_valid)
        amp_vld_led <= ~amp_vld_led;
end

always_ff @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst)
        led <= 3'b000;	//led off
	else begin
        led[2] <= adc_vld_led;   // ADC is outputing data
        led[1] <= freq_vld_led;  // frequency measure finished
        led[0] <= amp_vld_led;   // amplitude measure finished
    end
end

endmodule
