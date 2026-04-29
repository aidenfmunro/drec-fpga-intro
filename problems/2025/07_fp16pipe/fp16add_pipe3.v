module fp16add_pipe3 (
    input  wire        clk,
    input  wire [15:0] i_x,
    input  wire [15:0] i_y,
    output wire [15:0] o_z
);

// S0: extract, compare, & exp diff

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

reg [10:0] s1_large_m, s1_small_m;
reg [4:0]  s1_large_e, s1_e_diff;
reg        s1_large_s, s1_op_sub;

always @(posedge clk) begin

        s1_large_m <= c1_large_m; s1_small_m <= c1_small_m;
        s1_large_e <= c1_large_e; s1_e_diff  <= c1_e_diff;
        s1_large_s <= c1_large_s; s1_op_sub  <= c1_op_sub;
end

// S1: Alignment Shift & Mantissa Add/Sub

reg        c2_sticky;
reg [27:0] c2_small_aligned;
reg [27:0] c2_large_aligned;
reg [27:0] c2_sum;

always @(*) begin
    if (s1_e_diff >= 27) begin
        c2_sticky = |s1_small_m;
    end else begin
        c2_sticky = |({s1_small_m, 16'b0} & ((27'b1 << s1_e_diff) - 1));
    end

    c2_large_aligned = {1'b0, s1_large_m, 16'b0};
    c2_small_aligned = ({1'b0, s1_small_m, 16'b0} >> s1_e_diff) | {27'b0, c2_sticky};

    if (s1_op_sub) c2_sum = c2_large_aligned - c2_small_aligned;
    else           c2_sum = c2_large_aligned + c2_small_aligned;
end

reg [27:0] s2_sum;
reg [4:0]  s2_large_e;
reg        s2_large_s;

always @(posedge clk) begin
    s2_sum <= c2_sum;
    s2_large_e <= s1_large_e;
    s2_large_s <= s1_large_s;
end

// S2: LZD

reg [4:0]        c3_shift;
reg [26:0]       c3_norm_m;
reg signed [7:0] c3_norm_e;

always @(*) begin
    casez (s2_sum[27:0])
        28'b1_????_????_????_????_????_????_???: c3_shift = 5'd0;  // Bit 27
        28'b0_1???_????_????_????_????_????_???: c3_shift = 5'd0;  // Bit 26
        28'b0_01??_????_????_????_????_????_???: c3_shift = 5'd1;  // Bit 25
        28'b0_001?_????_????_????_????_????_???: c3_shift = 5'd2;  // Bit 24
        28'b0_0001_????_????_????_????_????_???: c3_shift = 5'd3;  // Bit 23
        28'b0_0000_1???_????_????_????_????_???: c3_shift = 5'd4;  // Bit 22
        28'b0_0000_01??_????_????_????_????_???: c3_shift = 5'd5;  // Bit 21
        28'b0_0000_001?_????_????_????_????_???: c3_shift = 5'd6;  // Bit 20
        28'b0_0000_0001_????_????_????_????_???: c3_shift = 5'd7;  // Bit 19
        28'b0_0000_0000_1???_????_????_????_???: c3_shift = 5'd8;  // Bit 18
        28'b0_0000_0000_01??_????_????_????_???: c3_shift = 5'd9;  // Bit 17
        28'b0_0000_0000_001?_????_????_????_???: c3_shift = 5'd10; // Bit 16
        28'b0_0000_0000_0001_????_????_????_???: c3_shift = 5'd11; // Bit 15
        28'b0_0000_0000_0000_1???_????_????_???: c3_shift = 5'd12; // Bit 14
        28'b0_0000_0000_0000_01??_????_????_???: c3_shift = 5'd13; // Bit 13
        28'b0_0000_0000_0000_001?_????_????_???: c3_shift = 5'd14; // Bit 12
        28'b0_0000_0000_0000_0001_????_????_???: c3_shift = 5'd15; // Bit 11
        28'b0_0000_0000_0000_0000_1???_????_???: c3_shift = 5'd16; // Bit 10
        28'b0_0000_0000_0000_0000_01??_????_???: c3_shift = 5'd17; // Bit 9
        28'b0_0000_0000_0000_0000_001?_????_???: c3_shift = 5'd18; // Bit 8
        28'b0_0000_0000_0000_0000_0001_????_???: c3_shift = 5'd19; // Bit 7
        28'b0_0000_0000_0000_0000_0000_1???_???: c3_shift = 5'd20; // Bit 6
        28'b0_0000_0000_0000_0000_0000_01??_???: c3_shift = 5'd21; // Bit 5
        28'b0_0000_0000_0000_0000_0000_001?_???: c3_shift = 5'd22; // Bit 4
        28'b0_0000_0000_0000_0000_0000_0001_???: c3_shift = 5'd23; // Bit 3
        28'b0_0000_0000_0000_0000_0000_0000_1??: c3_shift = 5'd24; // Bit 2
        28'b0_0000_0000_0000_0000_0000_0000_01?: c3_shift = 5'd25; // Bit 1
        28'b0_0000_0000_0000_0000_0000_0000_001: c3_shift = 5'd26; // Bit 0
        default:                                 c3_shift = 5'd0;  // All zeros
    endcase

    c3_norm_e = {3'b0, s2_large_e};

    if (s2_sum[27]) begin
        c3_norm_m = s2_sum[27:1];
        c3_norm_e = c3_norm_e + 8'd1;
    end else if (s2_sum == 0) begin
        c3_norm_m = 27'd0;
        c3_norm_e = 8'd0;
    end else begin
        c3_norm_m = s2_sum[26:0] << c3_shift;
        c3_norm_e = c3_norm_e - {3'b0, c3_shift};
    end
end

reg [26:0]       s3_norm_m;
reg signed [7:0] s3_norm_e;
reg              s3_large_s;
reg              s3_is_zero;

always @(posedge clk ) begin
    s3_norm_m  <= c3_norm_m;
    s3_norm_e  <= c3_norm_e;
    s3_large_s <= s2_large_s;
    s3_is_zero <= (s2_sum == 0);
end

// S3: rounding & final output

reg [11:0] c4_round_m;
reg [9:0]  c4_final_m;
reg [4:0]  c4_final_e;
reg [15:0] c4_z;

wire l = s3_norm_m[16];
wire g = s3_norm_m[15];
wire r = s3_norm_m[14];
wire s = |s3_norm_m[13:0];
wire rnd_inc = g & (l | r | s);

always @(*) begin
    begin : rounding

        c4_round_m = {1'b0, s3_norm_m[26:16]} + {11'b0, rnd_inc};

        if (c4_round_m[11]) begin
                c4_final_e = s3_norm_e[4:0] + 5'd1;
                c4_final_m = c4_round_m[10:1];
        end else begin
                c4_final_e = s3_norm_e[4:0];
                c4_final_m = c4_round_m[9:0];
        end

        if (s3_norm_e <= 0 || s3_is_zero) begin
            c4_z = {s3_large_s, 15'd0}; // FTZ
        end else if (s3_norm_e >= 31) begin
            c4_z = {s3_large_s, 5'h1F, 10'd0}; // Infinity
        end else begin
            c4_z = {s3_large_s, c4_final_e, c4_final_m}; // Normal
        end
    end
end

assign o_z = c4_z;

endmodule
