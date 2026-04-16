`include "config.vh"

module mmio_xbar (
    input  wire [29:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire [3:0]  i_mmio_mask,
    input  wire        i_mmio_wren,
    output wire [31:0] o_mmio_data,

    output reg [15:0]  o_hexd_data,
    output wire        o_hexd_wren
);

assign o_mmio_data = i_mmio_data;

assign hexd_sel = (i_mmio_addr == `XBAR_HEXD_ADDR0);

always @(*) begin
    if (hexd_sel) begin
        if (i_mmio_mask[0])
            o_hexd_data[3:0]   = i_mmio_data[3:0];
        if (i_mmio_mask[1])
            o_hexd_data[7:4]   = i_mmio_data[7:4];
        if (i_mmio_mask[2])
            o_hexd_data[11:8]  = i_mmio_data[11:8];
        if (i_mmio_mask[3])
            o_hexd_data[15:12] = i_mmio_data[15:12];
    end
end

assign o_hexd_wren = hexd_sel ? i_mmio_wren : 1'b0;

endmodule
