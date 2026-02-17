module sign_ext_structural #(
    parameter N = 8,
    parameter M = 16
) (
    input  wire [N-1:0] i_data,
    output wire [M-1:0] o_data
);

generate
    for (genvar i = 0; i < N; i = i + 1) begin : gen_copy
        assign o_data[i] = i_data[i];
    end

    for (genvar i = N; i < M; i = i + 1) begin : gen_sign
        assign o_data[i] = i_data[N-1];
    end
endgenerate

endmodule
