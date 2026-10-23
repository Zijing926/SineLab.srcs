`timescale 1ns / 1ps

module tb_dds_controller();
//input interface
logic 			sys_clk;
logic 			sys_rst;
logic [13:0] 	freq;
logic [6:0]		amplitude;
//output interface
logic dds_valid;
logic [11:0] 	dds_data;

initial begin
	sys_clk = 1'b1;
	sys_rst <= 1'b0;
	freq <= 14'd0;
	#100
	sys_rst <= 1'b1;
	freq <= 14'd100;
	amplitude <= 50;
	#10_000
	amplitude <= 100;
	#10_000
	freq <= 14'd200;
	#10_000
	amplitude <= 0;
end

always #5 sys_clk = ~sys_clk;

dds_controller dds_controller_inst(
    .sys_clk(sys_clk),
    .sys_rst(sys_rst),	//active low
    .freq(freq),   	// 单位：kHz,最大9999
	.amplitude(amplitude),
	
    .dds_valid(dds_valid),
    .dds_data(dds_data)
);
endmodule
