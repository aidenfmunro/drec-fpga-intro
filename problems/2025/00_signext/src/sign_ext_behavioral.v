module sign_ext_behavioral #(
    parameter N = 8,
    parameter M = 16
) (
    input  wire [N-1:0] i_data,
    output wire [M-1:0] o_data
);

assign o_data = {{(M-N){i_data[N-1]}}, i_data};

endmodule
