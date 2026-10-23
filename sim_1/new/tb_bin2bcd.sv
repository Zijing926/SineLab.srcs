`timescale 1ns / 1ps

module tb_bin2bcd;

    logic sys_clk, sys_rst;
    logic [13:0] bin;
    logic [15:0] bcd;

    // 例化被测模块
    bin2bcd dut (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .bin(bin),
        .bcd(bcd)
    );

    // 100MHz 时钟
    always #5 sys_clk = ~sys_clk;

	initial begin
		sys_clk = 0; sys_rst = 0; bin = 0;
		#20 sys_rst = 1;

		bin = 14'd1234;  wait(dut.busy); wait(!dut.busy);
		$display("1234 -> %0d", bcd); // 1234

		bin = 14'd9999;  wait(dut.busy); wait(!dut.busy);
		$display("9999 -> %0d", bcd); // 9999

		bin = 14'd0;     wait(dut.busy); wait(!dut.busy);
		$display("0 -> %0d", bcd); // 0

		$finish;
	end

endmodule