// LFSR Fibonacci Style

module lfsr #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] i_seed,
    input  wire [WIDTH-1:0] i_taps,
    output wire [WIDTH-1:0] o_data
);

reg [WIDTH-1:0] mem;

assign o_data = mem;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem <= i_seed;
    end else begin
        mem <= {mem[WIDTH-2:0], ^(mem & i_taps)};
    end
end

endmodule
