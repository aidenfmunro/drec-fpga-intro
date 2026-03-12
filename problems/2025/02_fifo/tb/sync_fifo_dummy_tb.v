`timescale 1ns/1ps

module sync_fifo_dummy_tb;

localparam DATA_WIDTH = 8;
localparam ADDR_WIDTH = 4;

wire clk, rst_n;
wire [DATA_WIDTH-1:0] wr_data, rd_data;
wire wr_en, rd_en;
wire rd_empty, wr_full;

sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_wr_data  (wr_data),
    .i_wr_en    (wr_en),
    .o_wr_full  (wr_full),
    .o_rd_data  (rd_data),
    .i_rd_en    (rd_en),
    .o_rd_empty (rd_empty)
);

endmodule;
