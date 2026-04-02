module fpga_top(
    input  wire CLK,
    input  wire RSTN,
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE,
    input  wire RXD,
    output wire TXD,
    output wire [11:0] LED
);

localparam FREQ = 50_000_000;
localparam RATE = 2_000_000;

assign LED[0] = RXD;
assign LED[4] = TXD;
assign LED[6] = ~RXD; // debug
assign {LED[11:7], LED[5], LED[3:1]} = ~9'b0;

// RSTN synchronizer
reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [7:0] rx_data;
reg [15:0] hex_data;
wire rx_vld;

uart_rx #(
    .FREQ(FREQ),
    .RATE(RATE)
) u_uart_rx (
    .clk    (CLK),
    .rst_n  (rst_n),
    .i_rx   (RXD),
    .o_data (rx_data),
    .o_vld  (rx_vld)
);

wire [3:0]  anodes;
wire [7:0]  segments;

ctrl_74hc595 ctrl (
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

hex_display u_hex_display (
    .clk        (CLK),
    .rst_n      (rst_n),
    .i_data     (hex_data),
    .i_dots     (4'b0),
    .o_anodes   (anodes),
    .o_segments (segments)
);

always @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        hex_data <= 16'hA000;
    end else if (rx_vld) begin
        hex_data <= {hex_data[7:0], rx_data};
    end
end

endmodule
