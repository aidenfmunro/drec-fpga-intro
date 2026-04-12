module mux4 #(
    parameter WIDTH = 8
) (
    input  wire [1:0]            i_sel,
    input  wire [1:0][WIDTH-1:0] i_data,
    output wire [WIDTH-1:0]      o_data
);

assign o_data = i_data[i_sel];

endmodule
