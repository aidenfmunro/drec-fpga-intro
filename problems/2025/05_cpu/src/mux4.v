module mux4 #(
    parameter WIDTH = 8
) (
    input  wire [1:0]       i_sel,
    input  wire [WIDTH-1:0] i_data0,
    input  wire [WIDTH-1:0] i_data1,
    input  wire [WIDTH-1:0] i_data2,
    input  wire [WIDTH-1:0] i_data3,
    output reg  [WIDTH-1:0] o_data
);

always @(*) begin
    case (i_sel)
        2'b00: o_data = i_data0;
        2'b01: o_data = i_data1;
        2'b10: o_data = i_data2;
        2'b11: o_data = i_data3;
        default: o_data = {WIDTH{1'bx}};
    endcase
end

endmodule
