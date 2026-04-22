`include "config.vh"

module mmio_xbar (
    input  wire [29:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire [3:0]  i_mmio_mask,
    input  wire        i_mmio_wren,
    output wire [31:0] o_mmio_data,

    output reg [15:0]  o_hexd_data,
    output reg         o_hexd_wren
);

assign o_mmio_data = i_mmio_data;

always @(*) begin
    o_hexd_data = 16'bX;
    o_hexd_wren = 1'bX;

    if (i_mmio_addr == `XBAR_HEXD_ADDR0) begin
        o_hexd_data[3:0]   = i_mmio_data[3:0]   & {4{i_mmio_mask[0]}};
        o_hexd_data[7:4]   = i_mmio_data[7:4]   & {4{i_mmio_mask[1]}};
        o_hexd_data[11:8]  = i_mmio_data[11:8]  & {4{i_mmio_mask[2]}};
        o_hexd_data[15:12] = i_mmio_data[15:12] & {4{i_mmio_mask[3]}};

        o_hexd_wren = i_mmio_wren;
    end
end

endmodule
