module fp16add_pipe4 (
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
    s1_large_m <= c1_large_m;
    s1_small_m <= c1_small_m;
    s1_large_e <= c1_large_e;
    s1_e_diff  <= c1_e_diff;
    s1_large_s <= c1_large_s;
    s1_op_sub  <= c1_op_sub;
end

// S1: alignment shift & sticky bit

reg        c2_sticky;
reg [27:0] c2_small_aligned;
reg [27:0] c2_large_aligned;

always @(*) begin
    if (s1_e_diff >= 27) begin
        c2_sticky = |s1_small_m;
    end else begin
        c2_sticky = |({s1_small_m, 16'b0} & ((27'b1 << s1_e_diff) - 1));
    end

    c2_large_aligned = {1'b0, s1_large_m, 16'b0};
    c2_small_aligned = ({1'b0, s1_small_m, 16'b0} >> s1_e_diff) | {27'b0, c2_sticky};
end

reg [27:0] s2_large_aligned, s2_small_aligned;
reg [4:0]  s2_large_e;
reg        s2_large_s, s2_op_sub;

always @(posedge clk) begin
        s2_large_aligned <= c2_large_aligned;
        s2_small_aligned <= c2_small_aligned;
        s2_large_e <= s1_large_e;
        s2_large_s <= s1_large_s;
        s2_op_sub  <= s1_op_sub;
end

// S2: mantissa add

reg [27:0] c3_sum;

always @(*) begin
    if (s2_op_sub) c3_sum = s2_large_aligned - s2_small_aligned;
    else           c3_sum = s2_large_aligned + s2_small_aligned;
end

reg [27:0] s3_sum;
reg [4:0]  s3_large_e;
reg        s3_large_s;

always @(posedge clk) begin
        s3_sum <= c3_sum;
        s3_large_e <= s2_large_e;
        s3_large_s <= s2_large_s;
end


// S3: LZD & norm shift

reg [4:0]        c4_shift;
reg [26:0]       c4_norm_m;
reg signed [7:0] c4_norm_e;

always @(*) begin
    casez (s3_sum[27:0])
        28'b1_????_????_????_????_????_????_???: c4_shift = 5'd0;
        28'b0_1???_????_????_????_????_????_???: c4_shift = 5'd0;
        28'b0_01??_????_????_????_????_????_???: c4_shift = 5'd1;
        28'b0_001?_????_????_????_????_????_???: c4_shift = 5'd2;
        28'b0_0001_????_????_????_????_????_???: c4_shift = 5'd3;
        28'b0_0000_1???_????_????_????_????_???: c4_shift = 5'd4;
        28'b0_0000_01??_????_????_????_????_???: c4_shift = 5'd5;
        28'b0_0000_001?_????_????_????_????_???: c4_shift = 5'd6;
        28'b0_0000_0001_????_????_????_????_???: c4_shift = 5'd7;
        28'b0_0000_0000_1???_????_????_????_???: c4_shift = 5'd8;
        28'b0_0000_0000_01??_????_????_????_???: c4_shift = 5'd9;
        28'b0_0000_0000_001?_????_????_????_???: c4_shift = 5'd10;
        28'b0_0000_0000_0001_????_????_????_???: c4_shift = 5'd11;
        28'b0_0000_0000_0000_1???_????_????_???: c4_shift = 5'd12;
        28'b0_0000_0000_0000_01??_????_????_???: c4_shift = 5'd13;
        28'b0_0000_0000_0000_001?_????_????_???: c4_shift = 5'd14;
        28'b0_0000_0000_0000_0001_????_????_???: c4_shift = 5'd15;
        28'b0_0000_0000_0000_0000_1???_????_???: c4_shift = 5'd16;
        28'b0_0000_0000_0000_0000_01??_????_???: c4_shift = 5'd17;
        28'b0_0000_0000_0000_0000_001?_????_???: c4_shift = 5'd18;
        28'b0_0000_0000_0000_0000_0001_????_???: c4_shift = 5'd19;
        28'b0_0000_0000_0000_0000_0000_1???_???: c4_shift = 5'd20;
        28'b0_0000_0000_0000_0000_0000_01??_???: c4_shift = 5'd21;
        28'b0_0000_0000_0000_0000_0000_001?_???: c4_shift = 5'd22;
        28'b0_0000_0000_0000_0000_0000_0001_???: c4_shift = 5'd23;
        28'b0_0000_0000_0000_0000_0000_0000_1??: c4_shift = 5'd24;
        28'b0_0000_0000_0000_0000_0000_0000_01?: c4_shift = 5'd25;
        28'b0_0000_0000_0000_0000_0000_0000_001: c4_shift = 5'd26;
        default:                                 c4_shift = 5'd0;
    endcase

    c4_norm_e = {3'b0, s3_large_e};

    if (s3_sum[27]) begin
        c4_norm_m = s3_sum[27:1];
        c4_norm_e = c4_norm_e + 8'd1;
    end else if (s3_sum == 0) begin
        c4_norm_m = 27'd0;
        c4_norm_e = 8'd0;
    end else begin
        c4_norm_m = s3_sum[26:0] << c4_shift;
        c4_norm_e = c4_norm_e - {3'b0, c4_shift};
    end
end

reg [26:0]       s4_norm_m;
reg signed [7:0] s4_norm_e;
reg              s4_large_s;
reg              s4_is_zero;

always @(posedge clk) begin
    s4_norm_m  <= c4_norm_m;
    s4_norm_e  <= c4_norm_e;
    s4_large_s <= s3_large_s;
    s4_is_zero <= (s3_sum == 0);
end

// S4: rounding & final output

reg [11:0] c5_round_m;
reg [9:0]  c5_final_m;
reg [4:0]  c5_final_e;
reg [15:0] c5_z;

wire l = s4_norm_m[16];
wire g = s4_norm_m[15];
wire r = s4_norm_m[14];
wire s = |s4_norm_m[13:0];
wire rnd_inc = g & (l | r | s);

always @(*) begin
    begin : rounding

        c5_round_m = {1'b0, s4_norm_m[26:16]} + {11'b0, rnd_inc};

        if (c5_round_m[11]) begin
                c5_final_e = s4_norm_e[4:0] + 5'd1;
                c5_final_m = c5_round_m[10:1];
        end else begin
                c5_final_e = s4_norm_e[4:0];
                c5_final_m = c5_round_m[9:0];
        end

        if (s4_norm_e <= 0 || s4_is_zero) begin
            c5_z = {s4_large_s, 15'd0}; // FTZ
        end else if (s4_norm_e >= 31) begin
            c5_z = {s4_large_s, 5'h1F, 10'd0}; // Infinity
        end else begin
            c5_z = {s4_large_s, c5_final_e, c5_final_m}; // Normal
        end
    end
end

assign o_z = c5_z;

endmodule
