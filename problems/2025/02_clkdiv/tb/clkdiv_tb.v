`timescale 1ns/1ps

module clkdiv_tb;

parameter SRC_FREQ = 100_000_000;
parameter DST_FREQ =  25_000_000;

localparam CLK_PERIOD = 1000_000_000 / SRC_FREQ;

reg clk_src;
reg rst_n;
wire clk_dst;

initial clk_src = 1'b0;
always #(CLK_PERIOD/2) clk_src = ~clk_src;

clkdiv #(
    .SRC_FREQ(SRC_FREQ),
    .DST_FREQ(DST_FREQ)
) dut (
    .clk(clk_src),
    .rst_n(rst_n),
    .out(clk_dst)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, clkdiv_tb);

    rst_n = 1'b0;
    #(CLK_PERIOD * 2);
    rst_n = 1'b1;

    repeat ( (SRC_FREQ/DST_FREQ) * 4 ) @(posedge clk_src);

    $finish;
end












endmodule
