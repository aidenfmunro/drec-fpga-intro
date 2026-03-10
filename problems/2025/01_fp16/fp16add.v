module fp16add
(
    input  wire [15:0] i_x,
    input  wire [15:0] i_y,
    output reg  [15:0] o_z
);

wire s_x = i_x[15];
wire s_y = i_y[15];

wire [4:0] e_x = i_x [14:10];
wire [4:0] e_y = i_y [14:10];

wire [9:0] m_x = i_x [9:0];
wire [9:0] m_y = i_y [9:0];

wire [10:0] ext_m_x  = (e_x == 0) ? 11'b0 : {1'b1, m_x};
wire [10:0] ext_m_y  = (e_y == 0) ? 11'b0 : {1'b1, m_y};

reg [10:0] large_m, small_m;
reg [4:0]  large_e, small_e;
reg        large_s, small_s;

reg        op_sub;
reg [4:0]  e_diff;
reg [26:0] small_m_shifted;
reg        sticky;

always @(*) begin
    if (e_x > e_y || (e_x == e_y && m_x > m_y)) begin
        large_e = e_x;
        large_m = ext_m_x;
        large_s = s_x;
        small_e = e_y;
        small_m = ext_m_y;
        small_s = s_y;
    end
    else begin
        large_e = e_y;
        large_m = ext_m_y;
        large_s = s_y;
        small_e = e_x;
        small_m = ext_m_x;
        small_s = s_x;
    end

    op_sub = large_s ^ small_s;
    e_diff = large_e - small_e;

    small_m_shifted = {small_m, 16'b0} >> e_diff;

    if (e_diff >= 27) begin
        sticky = |small_m;
    end else begin
        sticky = |({small_m, 16'b0} & ((27'b1 << e_diff) - 1));
    end
end

reg [27:0] sum;
reg [27:0] large_aligned;
reg [27:0] small_aligned;

always @(*) begin
    large_aligned = {1'b0, large_m, 16'b0};
    small_aligned = ({1'b0, small_m, 16'b0} >> e_diff) | {27'b0, sticky};
    if (op_sub) begin
        sum = large_aligned - small_aligned;
    end
    else begin
        sum = large_aligned + small_aligned;
    end
end

reg [4:0] shift;
reg [26:0] norm_m;
reg signed [6:0] norm_e;

integer i;
reg found;

always @(*) begin
    norm_e = {2'b0, large_e};
    norm_m = sum[26:0];
    found = 1'b0;
    shift = 0;

    if (sum[27]) begin
        norm_m = sum[27:1];
        norm_e = norm_e + 1;
    end
    else if (sum == 0) begin
        norm_e = 0;
    end else begin
        shift = 0;
        for (i = 26; i > 0; i--) begin
            if (sum[i] == 1'b1 && !found) begin
                shift = 26 - i;
                found = 1'b1;
            end
        end

        norm_m = sum[26:0] << shift;
        norm_e = norm_e - shift;
    end
end

wire l = norm_m[16];
wire g = norm_m[15];
wire r = norm_m[14];
wire s = |norm_m[13:0];

wire rnd_inc = g & (l | r | s);

wire [11:0] round_m = {1'b0, norm_m[26:16]} + rnd_inc;

always @(*) begin
    reg [9:0] final_m;
    reg [4:0] final_e;

    if (round_m[11]) begin
         final_e = norm_e[4:0] + 1;
         final_m = round_m[10:1];
    end else begin
         final_e = norm_e[4:0];
         final_m = round_m[9:0];
    end

    if (norm_e <= 0 || sum == 0) begin
        // FTZ
        o_z = {large_s, 15'd0};
    end else if (norm_e >= 31) begin
        // Overflow: Infinity
        o_z = {large_s, 5'h1F, 10'd0};
    end else begin
        // Normal
        o_z = {large_s, final_e, final_m};
    end
end

endmodule
