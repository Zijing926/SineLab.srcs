`timescale 1ns / 1ps

module freq_measure #(
	parameter GATE_CNT = 100_000			// The time of gate=10*GATE_CNT ns
)(
    input  	logic        sys_clk,
    input  	logic        sys_rst,
    input  	logic [15:0] measured_data,
	input	logic [15:0] offset,

    output 	logic [15:0] freq_khz,
    output 	logic        freq_valid
);
	localparam SYS_CLK_FREQ = 100_000_000;
	localparam CALC_LATENCY = 100;
    // 提取方波
    logic adc_square, adc_square_d;
    assign adc_square = (measured_data > offset);
	
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst)
            adc_square_d <= 1'b0;
        else
            adc_square_d <= adc_square;
    end

    logic sig_edge;	//detect the symbol change of adc_sig
    assign sig_edge = adc_square ^ adc_square_d;
	//generate the gate signal
    logic [31:0] 	gate_cnt;
    logic        	gate_en;
	logic 			calc_en;
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            gate_cnt <= 32'd0;
            gate_en  <= 1'b0;
			calc_en	<= 1'b0;
        end
        else if (gate_cnt < GATE_CNT - CALC_LATENCY) begin
            gate_cnt <= gate_cnt + 1'b1;
            gate_en  <= 1'b1;
			calc_en <= 1'b0;
        end
        else if (gate_cnt < GATE_CNT) begin
			gate_cnt <= gate_cnt + 1'b1;
			gate_en <= 1'b0;
			calc_en <= 1'b1;
		end else begin
			gate_cnt <= 32'd0;
            gate_en <= 1'b0;
			calc_en <= 1'b0; 
        end
    end

    // 双计数
    logic [31:0] cnt_sig;
    logic [31:0] cnt_clk;
	
	logic [63:0] temp;
	logic [13:0] freq_khz_next;
	
	always_comb begin
		if(calc_en && cnt_clk!=0) begin
			temp = (SYS_CLK_FREQ * cnt_sig) / (cnt_clk << 1);
			freq_khz_next = temp/ 1000;// temp 单位 Hz → kHz, maintain one decimal
		end
	end	
	
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if (!sys_rst) begin
            cnt_sig  <= 32'd0;
            cnt_clk  <= 32'd0;
        end
        else if (gate_en) begin
            cnt_clk <= cnt_clk + 1'b1;
            if (sig_edge)
                cnt_sig <= cnt_sig + 1'b1;
        end
        else if (gate_cnt == GATE_CNT) begin
            cnt_sig <= 32'd0;
            cnt_clk <= 32'd0;
		end
    end
    // ---------- output ----------
	always_ff @(posedge sys_clk or negedge sys_rst) begin
		if (!sys_rst) begin
			freq_khz <= 0;
			freq_valid 	<= 0;
		end
		else if (gate_cnt == GATE_CNT) begin
			freq_khz <= (freq_khz_next>14'd9999)?14'd9999:freq_khz_next[13:0];
			freq_valid <= 1;
		end
		else
			freq_valid <= 0;
	end
endmodule