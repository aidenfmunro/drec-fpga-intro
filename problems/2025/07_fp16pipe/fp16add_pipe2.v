module fp16add_pipe2 (
    input  wire        clk,
    input  wire [15:0] i_x,
    input  wire [15:0] i_y,
    output wire [15:0] o_z
);

wire s_x = i_x[15];
wire s_y = i_y[15];
wire [4:0] e_x = i_x[14:10];
wire [4:0] e_y = i_y[14:10];
wire [9:0] m_x = i_x[9:0];
wire [9:0] m_y = i_y[9:0];

wire [10:0] ext_m_x = (e_x == 0) ? 11'd0 : {1'b1, m_x};
wire [10:0] ext_m_y = (e_y == 0) ? 11'd0 : {1'b1, m_y};

reg [10:0] c1_large_m, c1_small_m;
reg [4:0]  c1_large_e, c1_small_e;
reg        c1_large_s, c1_small_s;

always @(*) begin
    if ((e_x > e_y) || (e_x == e_y && m_x > m_y)) begin
        c1_large_e = e_x; c1_large_m = ext_m_x; c1_large_s = s_x;
        c1_small_e = e_y; c1_small_m = ext_m_y; c1_small_s = s_y;
    end else begin
        c1_large_e = e_y; c1_large_m = ext_m_y; c1_large_s = s_y;
        c1_small_e = e_x; c1_small_m = ext_m_x; c1_small_s = s_x;
    end
end

wire [4:0] c1_e_diff = c1_large_e - c1_small_e;
wire       c1_op_sub = c1_large_s ^ c1_small_s;

reg c1_sticky;

always @(*) begin
    if (c1_e_diff >= 27) begin
        c1_sticky = |c1_small_m;
    end else begin
        c1_sticky = |({c1_small_m, 16'b0} & ((27'b1 << c1_e_diff) - 1));
    end
end

reg [4:0]  s1_large_e;
reg        s1_large_s, s1_op_sub;
reg [10:0] s1_large_m, s1_small_m;
reg [4:0]  s1_e_diff;
reg s1_sticky;

always @(posedge clk) begin
    s1_e_diff  <= c1_e_diff;
    s1_small_m <= c1_small_m;
    s1_large_m <= c1_large_m;
    s1_sticky  <= c1_sticky;
    s1_large_e <= c1_large_e;
    s1_large_s <= c1_large_s;
    s1_op_sub  <= c1_op_sub;
end

wire [27:0] c2_small_aligned = ({1'b0, s1_small_m, 16'b0} >> s1_e_diff) | {27'b0, s1_sticky};
wire [27:0] c2_large_aligned = {1'b0, s1_large_m, 16'b0};

reg [27:0] c2_sum;
reg [4:0]  c2_shift;

always @(*) begin

    if (s1_op_sub)
        c2_sum = c2_large_aligned - c2_small_aligned;
    else
        c2_sum = c2_large_aligned + c2_small_aligned;

    casez (c2_sum[27:0])
        28'b1_????_????_????_????_????_????_???: c2_shift = 5'd0;
        28'b0_1???_????_????_????_????_????_???: c2_shift = 5'd0;
        28'b0_01??_????_????_????_????_????_???: c2_shift = 5'd1;
        28'b0_001?_????_????_????_????_????_???: c2_shift = 5'd2;
        28'b0_0001_????_????_????_????_????_???: c2_shift = 5'd3;
        28'b0_0000_1???_????_????_????_????_???: c2_shift = 5'd4;
        28'b0_0000_01??_????_????_????_????_???: c2_shift = 5'd5;
        28'b0_0000_001?_????_????_????_????_???: c2_shift = 5'd6;
        28'b0_0000_0001_????_????_????_????_???: c2_shift = 5'd7;
        28'b0_0000_0000_1???_????_????_????_???: c2_shift = 5'd8;
        28'b0_0000_0000_01??_????_????_????_???: c2_shift = 5'd9;
        28'b0_0000_0000_001?_????_????_????_???: c2_shift = 5'd10;
        28'b0_0000_0000_0001_????_????_????_???: c2_shift = 5'd11;
        28'b0_0000_0000_0000_1???_????_????_???: c2_shift = 5'd12;
        28'b0_0000_0000_0000_01??_????_????_???: c2_shift = 5'd13;
        28'b0_0000_0000_0000_001?_????_????_???: c2_shift = 5'd14;
        28'b0_0000_0000_0000_0001_????_????_???: c2_shift = 5'd15;
        28'b0_0000_0000_0000_0000_1???_????_???: c2_shift = 5'd16;
        28'b0_0000_0000_0000_0000_01??_????_???: c2_shift = 5'd17;
        28'b0_0000_0000_0000_0000_001?_????_???: c2_shift = 5'd18;
        28'b0_0000_0000_0000_0000_0001_????_???: c2_shift = 5'd19;
        28'b0_0000_0000_0000_0000_0000_1???_???: c2_shift = 5'd20;
        28'b0_0000_0000_0000_0000_0000_01??_???: c2_shift = 5'd21;
        28'b0_0000_0000_0000_0000_0000_001?_???: c2_shift = 5'd22;
        28'b0_0000_0000_0000_0000_0000_0001_???: c2_shift = 5'd23;
        28'b0_0000_0000_0000_0000_0000_0000_1??: c2_shift = 5'd24;
        28'b0_0000_0000_0000_0000_0000_0000_01?: c2_shift = 5'd25;
        28'b0_0000_0000_0000_0000_0000_0000_001: c2_shift = 5'd26;
        default:                                 c2_shift = 5'd0;
    endcase
end

reg [27:0] s2_sum;
reg [4:0]  s2_shift;
reg [4:0]  s2_large_e;
reg        s2_large_s;
reg        s2_is_zero;

always @(posedge clk) begin
    s2_sum     <= c2_sum;
    s2_shift   <= c2_shift;
    s2_large_e <= s1_large_e;
    s2_large_s <= s1_large_s;
    s2_is_zero <= (c2_sum == 0);
end

reg [26:0]       c3_norm_m;
reg signed [7:0] c3_norm_e;
reg [11:0]       c3_round_m;
reg [9:0]        c3_final_m;
reg [4:0]        c3_final_e;
reg [15:0]       c3_z;

wire l = c3_norm_m[16];
wire g = c3_norm_m[15];
wire r = c3_norm_m[14];
wire s = |c3_norm_m[13:0];
wire rnd_inc = g & (l | r | s);

always @(*) begin
    c3_norm_e = {3'b0, s2_large_e};

    // 1. Normalization Shift
    if (s2_sum[27]) begin
        c3_norm_m = s2_sum[27:1];
        c3_norm_e = c3_norm_e + 8'd1;
    end else if (s2_is_zero) begin
        c3_norm_m = 27'd0;
        c3_norm_e = 8'd0;
    end else begin
        c3_norm_m = s2_sum[26:0] << s2_shift;
        c3_norm_e = c3_norm_e - {3'b0, s2_shift};
    end

    begin : rounding
        c3_round_m = {1'b0, c3_norm_m[26:16]} + {11'b0, rnd_inc};

        if (c3_round_m[11]) begin
                c3_final_e = c3_norm_e[4:0] + 5'd1;
                c3_final_m = c3_round_m[10:1];
        end else begin
                c3_final_e = c3_norm_e[4:0];
                c3_final_m = c3_round_m[9:0];
        end

        if (c3_norm_e <= 0 || s2_is_zero) begin
            c3_z = {s2_large_s, 15'd0}; // FTZ
        end else if (c3_norm_e >= 31) begin
            c3_z = {s2_large_s, 5'h1F, 10'd0}; // Infinity
        end else begin
            c3_z = {s2_large_s, c3_final_e, c3_final_m}; // Normal
        end
    end
end

assign o_z = c3_z;

endmodule
