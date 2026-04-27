`include "config.vh"

module mem_xbar #(
    parameter MMIO_START = 30'h0000,
    parameter MMIO_LIMIT = 30'h03FF,
    parameter DATA_START = 30'h0400,
    parameter DATA_LIMIT = 30'h3FFF
) (
    input  wire        clk,
    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire [3:0]  i_mask,
    output reg  [31:0] o_data,
    output wire [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output wire [3:0]  o_dmem_mask,
    output             o_dmem_wren,
    input  wire [31:0] i_dmem_data,
    output wire [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output wire        o_mmio_wren,
    output wire [3:0]  o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

wire dmem_sel = (i_addr >= DATA_START) && (i_addr <= DATA_LIMIT);
wire mmio_sel = (i_addr >= MMIO_START) && (i_addr <= MMIO_LIMIT);

assign o_dmem_addr = i_addr;
assign o_mmio_addr = i_addr;

assign o_dmem_data = i_data;
assign o_mmio_data = i_data;

assign o_dmem_mask = i_mask;
assign o_mmio_mask = i_mask;

assign o_dmem_wren = dmem_sel && i_wren;
assign o_mmio_wren = mmio_sel && i_wren;

reg dmem_sel_d;
reg mmio_sel_d;

always @(posedge clk) begin
    dmem_sel_d <= dmem_sel;
    mmio_sel_d <= mmio_sel;
end

always @(*) begin
    o_data = 32'bX;

    if (dmem_sel_d)
        o_data = i_dmem_data;
    if (mmio_sel_d)
        o_data = i_mmio_data;
end

endmodule
