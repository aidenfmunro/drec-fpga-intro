`timescale 1ns/1ps

module sync_fifo_stub;

parameter ADDR_WIDTH = 4;
parameter DATA_WIDTH = 32;

reg                   clk;
reg                   rst_n;

reg  [DATA_WIDTH-1:0] i_wr_data;
reg                   i_wr_en;
wire                  o_wr_full;

wire [DATA_WIDTH-1:0] o_rd_data;
reg                   i_rd_en;
wire                  o_rd_empty;

sync_fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_wr_data(i_wr_data),
    .i_wr_en(i_wr_en),
    .o_wr_full(o_wr_full),
    .o_rd_data(o_rd_data),
    .i_rd_en(i_rd_en),
    .o_rd_empty(o_rd_empty)
);

endmodule
