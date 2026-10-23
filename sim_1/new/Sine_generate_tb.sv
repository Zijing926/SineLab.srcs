`timescale 1ns / 1ps

module Sine_generate_tb();

    // 时钟和复位
    logic sys_clk;
    logic sys_rst;
    
    // 按键输入
    logic BTNL, BTNR, BTNU, BTND;
    
    // 数码管输出
    logic [7:0] an;
    logic [7:0] seg;
    
    // 实例化被测模块
    Sine_generate uut (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNU(BTNU),
        .BTND(BTND),
        .an(an),
        .seg(seg)
    );
    
    // 100MHz 时钟生成
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk;  // 5ns 周期 = 100MHz
    end
    
    // 测试向量
    initial begin
        // 初始化
        sys_rst = 0;
        BTNL = 0;
        BTNR = 0;
        BTNU = 0;
        BTND = 0;
        
        // 打印表头
        $display("========================================");
        $display("Time(ns) | Freq(kHz) | Amp(%) | DDS_Data");
        $display("========================================");
        
        // 复位释放
        #100;
        sys_rst = 1;
        #100;
        
        // 测试1：初始状态检查
        #1000;
        $display("%0t | %0d | %0d | %0d", 
                 $time, uut.freq, uut.amplitude, uut.dds_data);
        
        // 测试2：频率增加
        repeat(5) begin
            press_button(BTNR);
            #1000;
            $display("%0t | %0d | %0d | %0d", 
                     $time, uut.freq, uut.amplitude, uut.dds_data);
        end
        
        // 测试3：频率减少
        repeat(3) begin
            press_button(BTNL);
            #1000;
            $display("%0t | %0d | %0d | %0d", 
                     $time, uut.freq, uut.amplitude, uut.dds_data);
        end
        
        // 测试4：振幅增加
        repeat(5) begin
            press_button(BTNU);
            #1000;
            $display("%0t | %0d | %0d | %0d", 
                     $time, uut.freq, uut.amplitude, uut.dds_data);
        end
        
        // 测试5：振幅减少
        repeat(3) begin
            press_button(BTND);
            #1000;
            $display("%0t | %0d | %0d | %0d", 
                     $time, uut.freq, uut.amplitude, uut.dds_data);
        end
        
        // 测试6：边界测试
        // 频率最小
        repeat(10) press_button(BTNL);
        #1000;
        $display("%0t | %0d | %0d | %0d (Min Freq)", 
                 $time, uut.freq, uut.amplitude, uut.dds_data);
        
        // 频率最大
        repeat(20) press_button(BTNR);
        #1000;
        $display("%0t | %0d | %0d | %0d (Max Freq)", 
                 $time, uut.freq, uut.amplitude, uut.dds_data);
        
        // 振幅最小
        repeat(10) press_button(BTND);
        #1000;
        $display("%0t | %0d | %0d | %0d (Min Amp)", 
                 $time, uut.freq, uut.amplitude, uut.dds_data);
        
        // 振幅最大
        repeat(20) press_button(BTNU);
        #1000;
        $display("%0t | %0d | %0d | %0d (Max Amp)", 
                 $time, uut.freq, uut.amplitude, uut.dds_data);
        
        $display("========================================");
        $display("Test Completed!");
        $finish;
    end
    
    // 任务：模拟按键按下（产生一个时钟周期的高脉冲）
    task press_button(input logic btn);
        begin
            btn = 1;
            #100;
            btn = 0;
        end
    endtask


endmodule