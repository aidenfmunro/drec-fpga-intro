module hex_display #(
    parameter CNT_WIDTH = 14
)(
   input  wire        clk,
   input  wire        rst_n,
   input  wire [15:0] i_data,
   input  wire [3:0]  i_dots,
   output wire [3:0]  o_anodes,
   output reg  [7:0]  o_segments
);

reg [CNT_WIDTH-1:0] cnt;
wire          [1:0] pos = cnt[CNT_WIDTH-1:CNT_WIDTH-2];

reg [3:0] digit;

always @(*) begin
    case (pos)
        2'b00:  digit = i_data[3:0];
        2'b01:  digit = i_data[7:4];
        2'b10:  digit = i_data[11:8];
        2'b11:  digit = i_data[15:12];
    endcase
end

always @(posedge clk or negedge rst_n)
   cnt <= !rst_n ? {CNT_WIDTH{1'b0}} : (cnt + 1'b1);

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
    case (digit)
        16'd0:  o_segments[7:1] = 7'b1111110;
        16'd1:  o_segments[7:1] = 7'b0110000;
        16'd2:  o_segments[7:1] = 7'b1101101;
        16'd3:  o_segments[7:1] = 7'b1111001;
        16'd4:  o_segments[7:1] = 7'b0110011;
        16'd5:  o_segments[7:1] = 7'b1011011;
        16'd6:  o_segments[7:1] = 7'b1011111;
        16'd7:  o_segments[7:1] = 7'b1110000;
        16'd8:  o_segments[7:1] = 7'b1111111;
        16'd9:  o_segments[7:1] = 7'b1111011;
        16'd10: o_segments[7:1] = 7'b1110111;
        16'd11: o_segments[7:1] = 7'b0011111;
        16'd12: o_segments[7:1] = 7'b1001110;
        16'd13: o_segments[7:1] = 7'b0111101;
        16'd14: o_segments[7:1] = 7'b1001111;
        16'd15: o_segments[7:1] = 7'b1000111;
    endcase

    o_segments[0] = i_dots[pos];
end

endmodule
