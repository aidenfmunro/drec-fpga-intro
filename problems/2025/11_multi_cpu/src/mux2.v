module mux2 #(
    parameter WIDTH = 32
) (
    input  wire             i_sel,
    input  wire [WIDTH-1:0] i_data0,
    input  wire [WIDTH-1:0] i_data1,
    output wire [WIDTH-1:0] o_data
);

assign o_data = i_sel ? i_data1 : i_data0;

endmodule
