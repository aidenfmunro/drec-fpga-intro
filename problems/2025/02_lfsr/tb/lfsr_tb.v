module lfsr_tb;

localparam CLK_PERIOD = 10;
localparam WIDTH = 8;

reg clk = 1'b0;
reg rst_n = 1'b1;

wire [WIDTH-1:0] data;
reg [WIDTH-1:0] seed = 8'b00000001;
reg [WIDTH-1:0] taps = 8'b10101000;

lfsr #(
    .WIDTH(WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_seed(seed),
    .i_taps(taps),
    .o_data(data)
);

always begin
    #(CLK_PERIOD/2) clk <= ~clk;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, lfsr_tb);
end

initial begin
    rst_n <= 1'b0;
    @(posedge clk);
    rst_n <= 1'b1;

    repeat (100) @(posedge clk);

    $finish();
end

endmodule
