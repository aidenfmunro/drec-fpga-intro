`include "config.vh"

module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

wire clk0;
wire clk1 = CLK;

pll_30 core1 (
	.inclk0(CLK),
	.c0(clk0)
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
	RSTN_d <= RSTN;
end

system_top system_top(
    .clk0   (clk0   ),
    .clk1   (clk1   ),
    .rst_n  (rst_n  ),
    .o_stcp (STCP   ),
    .o_shcp (SHCP   ),
    .o_ds   (DS     ),
    .o_oe   (OE     )
);

endmodule
