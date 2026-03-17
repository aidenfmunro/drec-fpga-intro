// 8-bit LSFR Fibonacci configuration P(x) = x^8 + x^5 + x^4 + 1

module lsfr #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    output wire [WIDTH-1:0] o_data
);

reg [WIDTH-1:0] mem;

assign o_data = mem;

wire q = o_data[7] ^ o_data[4] ^ o_data[3];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem <= {{WIDTH-1{1'b0}}, 1'b1};
    end else begin
        mem <= {mem[WIDTH-2:0], q};
    end
end

endmodule
