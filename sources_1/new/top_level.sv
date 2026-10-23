`timescale 1ns / 1ps

module top_level (
    // system signals
    input logic sys_clk,          // 100MHz
    input logic sys_rst,          // active low
    
    // switch for display selection
    input logic sw_display_sel,   // 1: DDS display, 0: ADC display
    
    // key inputs
    input logic BTNL,             // frequency -
    input logic BTNR,             // frequency +
    input logic BTNU,             // amplitude +
    input logic BTND,             // amplitude -
    
    // ADC inputs
    input logic vauxp3,
    input logic vauxn3,
    
    // outputs
    output logic [7:0] an,        // 数码管位选
    output logic [7:0] seg,       // 数码管段选
    output logic [3:0] led        // LED指示灯
);

    // ================== DDS 模块 ==================
    logic [13:0] dds_freq;        // DDS频率（kHz）
    logic [6:0]  dds_amplitude;   // DDS振幅（%）
    logic [12:0] dds_data;        // DDS输出数据
    logic dds_valid;              // DDS有效信号
    
    // DDS模块实例化
    Sine_generate dds_inst (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNU(BTNU),
        .BTND(BTND),
        .an(),                    // 不使用DDS的数码管输出
        .seg()                    // 不使用DDS的数码管输出
    );
    
    // 从DDS模块获取内部信号
    assign dds_freq = dds_inst.freq;
    assign dds_amplitude = dds_inst.amplitude;
    assign dds_data = dds_inst.dds_data;
    assign dds_valid = dds_inst.dds_valid;
    
    // ================== ADC 测量模块 ==================
    logic [13:0] adc_freq;        // ADC测量频率（kHz）
    logic [15:0] adc_amplitude;   // ADC测量振幅
    logic adc_freq_valid;         // 频率测量有效
    logic adc_amp_valid;          // 振幅测量有效
    logic [15:0] adc_data;        // ADC原始数据
    logic adc_valid;              // ADC数据有效
    
    // ADC测量模块实例化
    sinlab_top #(
        .GATE_CNT(20_000_000),
        .SAMPLE_WINDOW(20'd500_000)
    ) adc_inst (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .vauxp3(vauxp3),
        .vauxn3(vauxn3),
        .an(),                    // 不使用ADC的数码管输出
        .seg(),                   // 不使用ADC的数码管输出
        .led(led)                 // LED输出
    );
    
    // 从ADC模块获取内部信号
    assign adc_freq = adc_inst.freq;
    assign adc_amplitude = adc_inst.amplitude;
    assign adc_freq_valid = adc_inst.freq_valid;
    assign adc_amp_valid = adc_inst.amp_valid;
    assign adc_data = adc_inst.adc_data;
    assign adc_valid = adc_inst.adc_valid;
    
    // ================== BCD 转换模块 ==================
    // DDS数据显示用BCD
    logic [15:0] dds_freq_bcd;
    logic [15:0] dds_amp_bcd;
    
    // ADC数据显示用BCD
    logic [15:0] adc_freq_bcd;
    logic [15:0] adc_amp_bcd;
    
    // DDS频率BCD转换
    bin2bcd bin2bcd_dds_freq (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .bin(dds_freq),
        .bcd(dds_freq_bcd)
    );
    
    // DDS振幅BCD转换（百分比）
    bin2bcd bin2bcd_dds_amp (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .bin(dds_amplitude),
        .bcd(dds_amp_bcd)
    );
    
    // ADC频率BCD转换
    bin2bcd bin2bcd_adc_freq (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .bin(adc_freq),
        .bcd(adc_freq_bcd)
    );
    
    // ADC振幅BCD转换
    bin2bcd bin2bcd_adc_amp (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .bin(adc_amplitude[15:0]),  // 取低16位
        .bcd(adc_amp_bcd)
    );
    
    // ================== 显示数据选择 ==================
    logic [31:0] display_data;     // 32位显示数据
    
    always_comb begin
        if (sw_display_sel) begin
            // switch=1: 显示DDS数据
            display_data = {dds_freq_bcd, dds_amp_bcd};
        end else begin
            // switch=0: 显示ADC数据
            display_data = {adc_freq_bcd, adc_amp_bcd};
        end
    end
    
    // ================== 数码管驱动 ==================
    seg7_driver seg7_inst (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .data(display_data),       // 根据开关选择显示数据
        .dp_en(8'b0),              // 小数点使能
        .an(an),
        .seg(seg)
    );
    
    // ================== 状态指示 ==================
    // 当显示DDS数据时，LED[3]显示DDS有效状态
    // 当显示ADC数据时，LED显示ADC模块的状态
    // 已经在ADC模块中处理了LED输出
    
endmodule