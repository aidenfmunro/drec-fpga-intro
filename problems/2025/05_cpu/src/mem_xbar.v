`include "config.vh"

module mem_xbar #(
    parameter MMIO_START = 30'h0400,
    parameter MMIO_LIMIT = 30'h3FFF,
    parameter DATA_START = 30'h0000,
    parameter DATA_LIMIT = 30'h03FF
) (
    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire [3:0]  i_mask,
    output wire [31:0] o_data,
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

assign dmem_sel = (DATA_START >= i_addr) && (i_addr <= DATA_LIMIT);
assign mmio_sel = (MMIO_START >= i_addr) && (i_addr <= MMIO_LIMIT);

assign o_dmem_addr = i_addr;
assign o_mmio_addr = i_addr;

assign o_dmem_data = i_data;
assign o_mmio_data = i_data;

assign o_dmem_mask = i_mask;
assign o_mmio_mask = i_mask;

assign o_dmem_wren = dmem_sel && i_wren;
assign o_mmio_wren = mmio_sel && i_wren;

assign o_data = dmem_sel ? i_dmem_data :
                mmio_sel ? i_mmio_data : 32'b0;

endmodule
