`timescale 1ns / 1ps

module uart_rx_tb;

reg clk   = 1'b0;
reg rst_n = 1'b1;

localparam FREQ = 50000000;
localparam RATE = 115200;

wire tx2rx;

wire o_rdy;
reg i_vld;
reg [7:0] i_data;
wire [7:0] o_data;
wire o_vld;

uart_rx #(
    .FREQ(FREQ),
    .RATE(RATE)
) dut_rx (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_rx   (tx2rx),
    .o_data (o_data),
    .o_vld  (o_vld)
);

uart_tx #(
    .FREQ(FREQ),
    .RATE(RATE)
) dut_tx (
    .clk    (clk),
    .rst_n  (rst_n),
    .i_data (i_data),
    .i_vld  (i_vld),
    .o_tx   (tx2rx),
    .o_rdy  (o_rdy)
);

always begin
    #10 clk = ~clk;
end

task write;
    input reg [7:0] data;
    begin
        wait (o_rdy);
        i_vld  <= 1'b1;
        @(posedge clk);
        i_data <= data;
        @(posedge clk);
        i_vld <= 1'b0;
        wait (o_vld);
        if (data != o_data) begin
            $display("got: %b, exp: %b", o_data, data);
        end
    end
endtask

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_rx_tb);

    rst_n <= 1'b0;
    @(posedge clk);
    rst_n <= 1'b1;

    repeat (100) write($urandom);

    $display("All tests passed!");
    $finish();
end

endmodule
