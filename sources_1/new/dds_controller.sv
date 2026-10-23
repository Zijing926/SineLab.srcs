`timescale 1ns / 1ps

module dds_controller(
    input  logic        sys_clk,
    input  logic        sys_rst,
    input  logic [13:0] freq,
    input  logic [6:0]  amplitude,
    
    output logic        dds_valid,
    output logic [12:0] dds_data		//MAX:4096
);

    logic [31:0] freq_word;
    logic [15:0] dds_raw;
    logic [23:0] unsigned_scaled;
    logic [11:0] dds_unsigned;  // 先变成无符号

    assign freq_word = 32'd42950 * freq;

    dds_compiler_0 dds_inst (
        .aclk(sys_clk),
        .s_axis_config_tvalid(sys_rst),
        .s_axis_config_tdata(freq_word),
        .m_axis_data_tvalid(dds_valid),
        .m_axis_data_tdata(dds_raw)
    );

    // ✅ 关键修正：先转有符号，再加偏置
    assign dds_unsigned = $signed(dds_raw[11:0]) + 12'sd2048;

    // ✅ 百分比缩放（无符号乘法）
    assign unsigned_scaled = dds_unsigned * amplitude;

    // ✅ 除以 100，回到 12 位
    assign dds_data = unsigned_scaled[23:0] / 7'd100;

endmodule