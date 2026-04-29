`define PIPE 1

module fpga_top (
    input  wire CLK,

    input  wire [15:0] i_x,
    input  wire [15:0] i_y,

    output reg  [15:0] o_z
);

reg  [15:0] x;
reg  [15:0] y;
wire [15:0] z;

always @(posedge CLK) begin
    x <= i_x;
    y <= i_y;
end

fp16add_pipe4 fp16add_pipe (
    .clk(CLK),
    .i_x(x),
    .i_y(y),
    .o_z(z)
);

always @(posedge CLK) begin
    o_z <= z;
end

endmodule
