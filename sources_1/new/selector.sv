`timescale 1ns / 1ps


module selector(
	input 	logic sys_clk,
	input 	logic sys_rst,  				//active low
	input 	logic switch,
	input 	logic [31:0] candidate_data_1,
	input 	logic [31:0] candidate_data_2,
	
	output 	logic [31:0] sel_data
    );

	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if(!sys_rst)
			sel_data <= 32'h0;
		else case(switch)
			1'b0:	sel_data <= candidate_data_1;
			1'b1:	sel_data <= candidate_data_2;
			default: sel_data <= 32'h0;
		endcase
	end
	
endmodule