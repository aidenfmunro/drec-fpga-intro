module shiftreg #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,

    input  wire             i_shift_en,
    input  wire             i_load_en,

    input  wire [WIDTH-1:0] i_data,
    output wire             o_data
);

reg [WIDTH-1:0] mem;

assign o_data = mem[WIDTH-1];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem <= {WIDTH{1'b0}};
    end else begin
        if (i_load_en) begin
            mem <= i_data;
        end else if (i_shift_en) begin
            mem <= mem << 1;
        end
    end
end

endmodule
