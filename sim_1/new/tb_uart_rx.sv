`timescale 1ns / 1ns

module tb_uart_rx();
logic sys_clk,sys_rst;
logic rx;
logic [7:0] output_data;

uart_rx #(
    .CLK_FREQ   (100_000_000),
    .BAUD_RATE  (10_000_000)      
)uart_rx_inst(
    .sys_clk    (sys_clk),
    .sys_rst    (sys_rst),
    .rx         (rx),
    .output_data(output_data)
);

initial begin
    sys_rst <= 1'b0;
    #30;
    sys_rst <= 1'b1;
end

initial sys_clk <= 1'b1;
always #5 sys_clk <= ~sys_clk;

initial begin
    rx <= 1'b1;
    #200;
    rx <= 1'b0; //start bit
    #100;
    rx <= 1'b1; //1st bit
    #100;
    rx <= 1'b0; //2nd bit
    #100;
    rx <= 1'b1; //3rd bit
    #100;
    rx <= 1'b0; //4th bit
    #100;
    rx <= 1'b1; //5th bit
    #100;
    rx <= 1'b0; //6th bit
    #100;
    rx <= 1'b1; //7th bit
    #100;
    rx <= 1'b0; //8th bit
    #100;
    rx <= 1'b0; //stop bit
    #100;
    rx <= 1'b1;
    #400

    rx_bit(8'd6); 
    rx_bit(8'd7);
end

task rx_bit(
    input [7:0] data
    );
    integer i;
    for(i=0; i<10; i=i+1) begin
        case(i)
            0: rx <= 1'b0;
            1: rx <= data[0];
            2: rx <= data[1];
            3: rx <= data[2];
            4: rx <= data[3];
            5: rx <= data[4];
            6: rx <= data[5];
            7: rx <= data[6];
            8: rx <= data[7];
            9: rx <= 1'b1;
        endcase
        #(100);
    end
endtask
endmodule
