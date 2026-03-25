module fpga_top(
    input  wire CLK,   // CLOCK
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam WIDTH = 16;

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0] anodes;
wire  [7:0] segments;

wire [WIDTH-1:0] data;
reg [WIDTH-1:0] num;

wire clk_rnd;

clkdiv #(
    .SRC_FREQ(50_000_000),
    .DST_FREQ(1)
) clkdiv (
    .clk(CLK),
    .rst_n(rst_n),
    .out(clk_rnd)
);

lfsr #(
    .WIDTH(WIDTH)
) lfsr (
    .clk(clk_rnd),
    .rst_n(rst_n),
    .i_seed(16'h0001),
    .i_taps(16'h3330),
    .o_data(data)
);

always @(posedge CLK) begin
    num <= data;
end

hex_display hex_display(CLK, rst_n, num, 4'b0000, anodes, segments);

ctrl_74hc595 ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
