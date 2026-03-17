module clkdiv #(
    parameter SRC_FREQ  = 50_000_000,
    parameter DST_FREQ = 12_500_000
) (
    input  wire clk,
    input  wire rst_n,
    output wire out
);

localparam CNT_WIDTH = $clog2(SRC_FREQ/DST_FREQ);

reg [CNT_WIDTH-1:0] cnt;

assign out = &cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= {CNT_WIDTH{1'b0}};
    end else begin
        cnt <= cnt + 1'b1;
    end
end

endmodule
