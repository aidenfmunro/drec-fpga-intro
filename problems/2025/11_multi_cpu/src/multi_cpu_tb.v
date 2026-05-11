`timescale 1ns/1ps

module multi_cpu_tb;

reg clk0 = 1'b0;
reg clk1 = 1'b0;
reg rst_n = 1'b0;

wire stcp;
wire shcp;
wire ds;
wire oe;

always #5 clk0 <= ~clk0;
always #4 clk1 <= ~clk1;

system_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .o_stcp(stcp),
    .o_shcp(shcp),
    .o_ds(ds),
    .o_oe(oe)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, multi_cpu_tb);

    repeat (5) @(posedge clk);
    rst_n <= 1'b1;

    repeat (20000) @(posedge clk);
    $finish;
end

always @(posedge dut.clk_core1) begin
    if (dut.hexd_wren)
        $display("%0t core1 displayed 0x%04h", $time, dut.hexd_data);
end

endmodule
