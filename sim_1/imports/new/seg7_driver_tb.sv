`timescale 1ns / 1ps

module seg7_driver_tb();
    logic sys_clk;
    logic sys_rst;
    logic [31:0] data;
    logic [7:0] dp_en;
    logic [7:0] an;
    logic [7:0] seg;
    
    seg7_driver seg7_driver_inst(
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .data(data),
        .dp_en(dp_en),
        .an(an),
        .seg(seg)
    );
    
    always #5 sys_clk = ~sys_clk;
    
    initial begin
        sys_rst <= 1;
        sys_clk = 1;
        data = 0;
        #100
        sys_rst <= 0;
        data <= 32'h12345678;
        dp_en <= 8'b00010000;
        #5000
        data <= 32'habcdef12;
        dp_en <= 8'b10000000;
    end
endmodule
