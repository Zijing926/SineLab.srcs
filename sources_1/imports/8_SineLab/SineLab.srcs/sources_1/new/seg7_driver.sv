`timescale 1ns / 1ps

module seg7_driver(
    input logic sys_clk,    //100MHz
    input logic sys_rst,    
    input logic [31:0] data,    //bcd code
    input logic [7:0] dp_en,    //decimal point enable, active high
    
    output logic [7:0] an,      //bit selection, active low
    output logic [7:0] seg      //segment selection, active low
    );
    
    localparam CLK_DIV = 16;    //2^16 = 65536, 
    
    logic [CLK_DIV-1:0] clk_cnt;    
    logic [2:0] seg_index;      //The current index of the scanned segment
    logic [3:0] bcd_data;       //The current number to be displayed
    logic [6:0] seg_pattern;
    
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if(sys_rst == 0)
            clk_cnt <= 0;
        else
            clk_cnt <= clk_cnt + 1;
    end
    //位扫描索引
    always_ff @(posedge sys_clk or negedge sys_rst) begin
        if(sys_rst == 0)
            seg_index <= 0;
        else if (clk_cnt == 0)
            seg_index <= seg_index + 1;
    end
    //位选
    always_comb begin
        an = 8'hff;     //all leds off by default
        an[seg_index] = 1'b0;   //
    end
    //取BCD数据
    always_comb begin
        case(seg_index)
            3'd0:bcd_data = data[3:0];  //
            3'd1:bcd_data = data[7:4];
            3'd2:bcd_data = data[11:8];
            3'd3:bcd_data = data[15:12];
            3'd4:bcd_data = data[19:16];
            3'd5:bcd_data = data[23:20];
            3'd6:bcd_data = data[27:24];
            3'd7:bcd_data = data[31:28];
            default: bcd_data = 4'h0;
        endcase
    end
    
    always_comb begin
        case(bcd_data)
            4'h0:seg_pattern = 7'b0000001;  //0
            4'h1:seg_pattern = 7'b1001111;  //1
            4'h2:seg_pattern = 7'b0010010;  //2
            4'h3:seg_pattern = 7'b0000110;  //3
            4'h4:seg_pattern = 7'b1001100;  //4
            4'h5:seg_pattern = 7'b0100100;  //5
            4'h6:seg_pattern = 7'b0100000;  //6
            4'h7:seg_pattern = 7'b0001111;  //7
            4'h8:seg_pattern = 7'b0000000;  //8
            4'h9:seg_pattern = 7'b0000100;  //9
            4'ha:seg_pattern = 7'b0001000;  //A
            4'hb:seg_pattern = 7'b1100000;  //b
            4'hc:seg_pattern = 7'b0110001;  //C
            4'hd:seg_pattern = 7'b1000010;  //d
            4'he:seg_pattern = 7'b0110000;  //E
            4'hf:seg_pattern = 7'b0111000;  //F
            default:seg_pattern = 7'b1111111;   //all off
        endcase
    end
    
    always_comb begin
        seg[0] = seg_pattern[6];  // a
        seg[1] = seg_pattern[5];  // b
        seg[2] = seg_pattern[4];  // c
        seg[3] = seg_pattern[3];  // d
        seg[4] = seg_pattern[2];  // e
        seg[5] = seg_pattern[1];  // f
        seg[6] = seg_pattern[0];  // g
        seg[7] = ~dp_en[seg_index]; //decimal point, active low
    end
endmodule
