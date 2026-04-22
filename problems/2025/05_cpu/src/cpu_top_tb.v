`timescale 1ns/1ps

module cpu_top_tb;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 clk <= ~clk;
end

initial begin
    @(posedge clk)
    @(posedge clk)
    rst_n <= 1'b1;
end

wire [29:0] o_mmio_addr;
wire [31:0] o_mmio_data;
wire  [3:0] o_mmio_mask;
wire        o_mmio_wren;
wire [31:0] i_mmio_data = 32'bX;

cpu_top cpu_top(
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .o_mmio_addr    (o_mmio_addr),
    .o_mmio_data    (o_mmio_data),
    .o_mmio_mask    (o_mmio_mask),
    .o_mmio_wren    (o_mmio_wren),
    .i_mmio_data    (i_mmio_data)
);

wire [15:0] hexd_data;
wire        hexd_wren;

mmio_xbar mmio_xbar(
    .i_mmio_addr(o_mmio_addr    ),
    .i_mmio_data(o_mmio_data    ),
    .i_mmio_mask(o_mmio_mask    ),
    .i_mmio_wren(o_mmio_wren    ),
    .o_mmio_data(),

    .o_hexd_data(hexd_data      ),
    .o_hexd_wren(hexd_wren      )
);

always @(posedge clk) begin
    if (o_mmio_wren) begin
        $display("[%t] %m: mmio: [0x%h] <- %h (%b)", $realtime,
                {o_mmio_addr, 2'b0}, o_mmio_data, o_mmio_mask);
        $display("%h, %b", hexd_data, hexd_wren);
    end
end

initial begin
    $dumpvars;
    #1500 $finish;
end

endmodule
