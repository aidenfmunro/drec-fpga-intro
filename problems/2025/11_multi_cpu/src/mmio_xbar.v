`include "config.vh"

module mmio_xbar #(
    parameter integer CORE_ID = 0
) (
    input wire clk,
    input wire rst_n,
    input wire [29:0] i_mmio_addr,
    input wire [31:0] i_mmio_data,
    input wire [3:0] i_mmio_mask,
    input wire i_mmio_wren,
    input wire i_mmio_rden,
    output wire [31:0] o_mmio_data,

    output reg [15:0] o_hexd_data,
    output reg o_hexd_wren,

    input wire [31:0] i_fifo_data,
    input wire i_fifo_full,
    input wire i_fifo_empty,
    output reg [31:0] o_fifo_data,
    output wire o_fifo_wrreq,
    output wire o_fifo_rdreq
);

reg [31:0] mmio_rdata;
assign o_mmio_data = mmio_rdata;

assign o_fifo_wrreq = (CORE_ID == 0) &&
                      i_mmio_wren &&
                      (i_mmio_addr == `XBAR_FIFO_DATA_ADDR) &&
                      !i_fifo_full;

assign o_fifo_rdreq = (CORE_ID == 1) &&
                      i_mmio_rden &&
                      (i_mmio_addr == `XBAR_FIFO_DATA_ADDR) &&
                      !i_fifo_empty;

always @(*) begin
    o_fifo_data = 32'b0;
    o_hexd_data = 16'b0;
    o_hexd_wren = 1'b0;

    if ((CORE_ID == 0) && (i_mmio_addr == `XBAR_FIFO_DATA_ADDR)) begin
        o_fifo_data = i_mmio_data;
    end

    if ((CORE_ID == 1) && (i_mmio_addr == `XBAR_HEXD_ADDR0)) begin
        o_hexd_data[3:0]   = i_mmio_data[3:0]   & {4{i_mmio_mask[0]}};
        o_hexd_data[7:4]   = i_mmio_data[7:4]   & {4{i_mmio_mask[1]}};
        o_hexd_data[11:8]  = i_mmio_data[11:8]  & {4{i_mmio_mask[2]}};
        o_hexd_data[15:12] = i_mmio_data[15:12] & {4{i_mmio_mask[3]}};
        o_hexd_wren = i_mmio_wren;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mmio_rdata <= 32'b0;
    end else if (i_mmio_rden) begin
        case (i_mmio_addr)
            `XBAR_FIFO_DATA_ADDR:
                mmio_rdata <= ((CORE_ID == 1) && !i_fifo_empty) ? i_fifo_data : 32'b0;
            `XBAR_FIFO_FULL_ADDR:
                mmio_rdata <= (CORE_ID == 0) ? {31'b0, i_fifo_full} : 32'b0;
            `XBAR_FIFO_EMPTY_ADDR:
                mmio_rdata <= (CORE_ID == 1) ? {31'b0, i_fifo_empty} : 32'b0;
            `XBAR_CORE_ID_ADDR:
                mmio_rdata <= CORE_ID;
            default:
                mmio_rdata <= 32'b0;
        endcase
    end
end

endmodule
