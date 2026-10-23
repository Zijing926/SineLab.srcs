`timescale 1ns / 1ps

module amplitude_measure #(
	parameter SAMPLE_WINDOW = 100_000	//The time of SAMPLE_WINDOW = 10*SAMPLE_WINDOW ns
)(
    input  	logic        	sys_clk,
    input  	logic        	sys_rst,
    input  	logic [15:0]	adc_data,
	
    output 	logic [15:0]	amplitude,	//unit: mV,
    output 	logic        	amp_valid,
	output 	logic [15:0] 	offset
);

    logic [15:0] max_val;
    logic [15:0] min_val;
	logic [31:0] sample_cnt;
	logic [12:0] diff;
	logic [16:0] offset_raw;
	
	//sample_cnt:sampling gate counter
	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if (sys_rst == 0)
			sample_cnt <= 0;
		else
			sample_cnt <= (sample_cnt == SAMPLE_WINDOW) ? 0 : sample_cnt + 1;
	end
	
	//refresh max_val and min_val
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (sys_rst == 0) begin
			offset_raw <= 0;
            max_val   <= 0; 	
            min_val   <= 16'h7FFF; 	// 32767
        end else if(sample_cnt<SAMPLE_WINDOW)begin
            if (adc_data > max_val)
                max_val <= adc_data;	//refresh max_val
            if (adc_data < min_val)
                min_val <= adc_data;	//refresh min_val
        end else if(sample_cnt==SAMPLE_WINDOW) begin	//reset max_val and min_val
			offset_raw <= (max_val + min_val) >> 1;
			max_val   <= 0; 	
			min_val   <= 16'h7FFF; 	// 32767			
		end
    end
	assign offset = offset_raw;
	// offset is the average value of max_val and min_val

	//calculate amplitude
	logic [31:0] amplitude_temp;	//intermediate varilable
	assign diff = ((max_val>>4) - (min_val>>4)) >>> 1;
	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if(sys_rst == 0) begin
			amplitude_temp <= 0;
			amp_valid <= 1'b0;
		end else if (sample_cnt == SAMPLE_WINDOW) begin
            amplitude_temp <= diff * 1000 / 4095;	//mV = (code × 1000) / 4095
            amp_valid <= 1'b1;		
		end else
			amp_valid <= 1'b0;
	end
	assign amplitude = (amplitude_temp>1000) ? 10'd1000 : amplitude_temp[9:0];
endmodule
