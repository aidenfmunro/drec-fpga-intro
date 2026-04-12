`include "config.vh"

module mmio_xbar (
    input  wire [29:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire [3:0]  i_mmio_mask,
    input  wire        i_mmio_wren,
    output wire [31:0] o_mmio_data,

    output wire [15:0] o_hexd_data,
    output wire        o_hexd_wren
);

assign o_mmio_data = i_mmio_data;

assign hexd_sel = (i_addr == XBAR_HEXD_ADDR0);

assign o_hexd_data = hexd_sel ? i_mmio_data[15:0] : 16'b0;
assign o_hexd_wren = hexd_sel ? i_mmio_wren : 1'b0;

endmodule
