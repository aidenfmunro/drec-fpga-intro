`include "config.vh"

module system_top #(
    parameter CORE_ID = 0
)(
    input  wire clk0,
    input  wire clk1,

    input  wire rst_n,

    output wire o_stcp,
    output wire o_shcp,
    output wire o_ds,
    output wire o_oe
);

wire [3:0]  anodes;
wire [7:0]  segments;
wire [15:0] hexd_data;
wire        hexd_wren;

wire [29:0] cpu0_mmio_addr;
wire [31:0] cpu0_mmio_wdata;
wire [3:0]  cpu0_mmio_mask;
wire        cpu0_mmio_wren;
wire        cpu0_mmio_rden;
wire [31:0] cpu0_mmio_rdata;

wire [29:0] cpu1_mmio_addr;
wire [31:0] cpu1_mmio_wdata;
wire [3:0]  cpu1_mmio_mask;
wire        cpu1_mmio_wren;
wire        cpu1_mmio_rden;
wire [31:0] cpu1_mmio_rdata;

wire [31:0] fifo_wdata;
wire [31:0] fifo_rdata;
wire        fifo_wrreq;
wire        fifo_rdreq;
wire        fifo_full;
wire        fifo_empty;

cpu_top cpu0_top (
    .clk(clk0),
    .rst_n(rst_n),
    .o_mmio_addr(cpu0_mmio_addr),
    .o_mmio_data(cpu0_mmio_wdata),
    .o_mmio_mask(cpu0_mmio_mask),
    .o_mmio_wren(cpu0_mmio_wren),
    .o_mmio_rden(cpu0_mmio_rden),
    .i_mmio_data(cpu0_mmio_rdata)
);

cpu_top cpu1_top (
    .clk(clk1),
    .rst_n(rst_n),
    .o_mmio_addr(cpu1_mmio_addr),
    .o_mmio_data(cpu1_mmio_wdata),
    .o_mmio_mask(cpu1_mmio_mask),
    .o_mmio_wren(cpu1_mmio_wren),
    .o_mmio_rden(cpu1_mmio_rden),
    .i_mmio_data(cpu1_mmio_rdata)
);

mmio_xbar #(
    .CORE_ID(0)
) mmio_xbar_core0 (
    .clk         (clk0),
    .rst_n       (rst_n),
    .i_mmio_addr (cpu0_mmio_addr),
    .i_mmio_data (cpu0_mmio_wdata),
    .i_mmio_mask (cpu0_mmio_mask),
    .i_mmio_wren (cpu0_mmio_wren),
    .i_mmio_rden (cpu0_mmio_rden),
    .o_mmio_data (cpu0_mmio_rdata),
    .o_hexd_data (),
    .o_hexd_wren (),
    .i_fifo_data (32'b0),
    .i_fifo_full (fifo_full),
    .i_fifo_empty(fifo_empty),
    .o_fifo_data (fifo_wdata),
    .o_fifo_wrreq(fifo_wrreq),
    .o_fifo_rdreq()
);

mmio_xbar #(
    .CORE_ID(1)
) mmio_xbar_core1 (
    .clk         (clk1),
    .rst_n       (rst_n),
    .i_mmio_addr (cpu1_mmio_addr),
    .i_mmio_data (cpu1_mmio_wdata),
    .i_mmio_mask (cpu1_mmio_mask),
    .i_mmio_wren (cpu1_mmio_wren),
    .i_mmio_rden (cpu1_mmio_rden),
    .o_mmio_data (cpu1_mmio_rdata),
    .o_hexd_data (hexd_data),
    .o_hexd_wren (hexd_wren),
    .i_fifo_data (fifo_rdata),
    .i_fifo_full (fifo_full),
    .i_fifo_empty(fifo_empty),
    .o_fifo_data (),
    .o_fifo_wrreq(),
    .o_fifo_rdreq(fifo_rdreq)
);

async_fifo fifo (
    .wrclk  (clk0),
    .rdclk  (clk1),
    .data   (fifo_wdata),
    .wrreq  (fifo_wrreq),
    .rdreq  (fifo_rdreq),
    .q      (fifo_rdata),
    .wrfull (fifo_full),
    .rdempty(fifo_empty)
);

reg [15:0] hexd_data_reg;

always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n)
        hexd_data_reg <= 16'b0;
    else if (hexd_wren)
        hexd_data_reg <= hexd_data;
end

hex_display hex_display(
    .clk(clk1),
    .rst_n(rst_n),
    .i_data(hexd_data_reg),
    .i_dots(4'b0),
    .o_anodes(anodes),
    .o_segments(segments)
);

ctrl_74hc595 ctrl_74hc595(
    .clk(clk1),
    .rst_n(rst_n),
    .i_data({segments, anodes}),
    .o_stcp(o_stcp),
    .o_shcp(o_shcp),
    .o_ds(o_ds),
    .o_oe(o_oe)
);

endmodule
