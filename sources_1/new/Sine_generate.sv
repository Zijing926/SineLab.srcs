`timescale 1ns / 1ps

module Sine_generate(
    input  logic sys_clk,      // 100MHz
    input  logic sys_rst,      // active low
    
    // key input（push high）
    input  logic BTNL,        // BTNL - frequency - 10
    input  logic BTNR,        // BTNR - frequency + 10
    input  logic BTNU,        // BTNU - amplitude + 10
    input  logic BTND,        // BTND - amplitude - 10

	output logic [15:0] freq,		// Actual falue of frequency（max 9999，14bit，unit: khz）
	output logic [15:0] amplitude	// amplitude, 0~100%
);
		
    // The pulse generated after debounce
    logic btn_l_pulse, btn_r_pulse;
    logic btn_u_pulse, btn_d_pulse;
    
    // ================== key debounce ==================
    // Nexys A7 key：push high    debounce module btn_in is active high
    debounce deb_l (.sys_clk(sys_clk), .sys_rst(sys_rst), .btn_in(BTNL), .btn_out(btn_l_pulse));
    debounce deb_r (.sys_clk(sys_clk), .sys_rst(sys_rst), .btn_in(BTNR), .btn_out(btn_r_pulse));
    debounce deb_u (.sys_clk(sys_clk), .sys_rst(sys_rst), .btn_in(BTNU), .btn_out(btn_u_pulse));
    debounce deb_d (.sys_clk(sys_clk), .sys_rst(sys_rst), .btn_in(BTND), .btn_out(btn_d_pulse));
	
    // ================== frequency control ==================
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)
            freq <= 16'd0010;  // original frequency value = 10kHz
        else if (btn_l_pulse) begin		//frequency - 1(khz)
            if (freq >= 16'd2)			//in case of overflow
                freq <= freq - 1;	
            else
                freq <= 16'h0001;
        end
        else if (btn_r_pulse) begin		//frequency + 1(khz)
            if (freq <= 16'd9998)  		//in case of overflow
                freq <= freq + 1;
            else
                freq <= 16'd9999;   	// max value
        end
    end
    // ================== amplitude control ==================
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)
            amplitude <= 16'd50;  // initial amplitude 50%
        else if (btn_u_pulse) begin
            // amplitude + 10
            if (amplitude <= 16'd99)
                amplitude <= amplitude + 1;
            else
                amplitude <= 16'd100;
        end
        else if (btn_d_pulse) begin
            // amplitude - 10
            if (amplitude >= 16'd1)
                amplitude <= amplitude - 1;
            else
                amplitude <= 16'd0;
        end
    end
	//dds	
	logic dds_valid;
	logic [12:0] dds_data;	//max 4096
	dds_controller dds_controller_inst(
		.sys_clk(sys_clk),
		.sys_rst(sys_rst),
		.freq(freq),
		.amplitude(amplitude),
		
		.dds_valid(dds_valid),
		.dds_data(dds_data)
	);

endmodule