// FP16 Multiplication (DAZ & FTZ) with RTTE

module fp16mul
(
    input  wire [15:0] i_x,
    input  wire [15:0] i_y,
    output wire [15:0] o_z
);

wire s_x = i_x[15];
wire s_y = i_y[15];

wire s_z = s_x[15] ^ s_y[15];

wire [4:0] e_x = i_x [14:10];
wire [4:0] e_y = i_y [14:10];

wire [9:0] m_x = i_x [9:0];
wire [9:0] m_y = i_y [9:0];

// DAZ
wire [10:0] ext_m_x  = (e_x == 0) ? 11'b0 : {1'b1, m_x};
wire [10:0] ext_m_y  = (e_y == 0) ? 11'b0 : {1'b1, m_y};

wire [21:0] m_prod = ext_m_x * ext_m_y;

wire norm = m_prod[21];
// Use 7 bit signed num to check for (over/under)flow

wire signed [6:0] e_sum = e_x + e_y - 5'b01111;
// Normalize

wire [21:0] m_prod_norm = norm ? m_prod >> 1 : m_prod;
wire signed [6:0] e_sum_norm = e_sum + norm;

wire l, g, t;

wire l = m_prod_norm[10];   // LSB
wire g = m_prod_norm[9];    // Guard bit
wire t = |m_prod_norm[8:0]; // Sticky bit

wire rnd_inc = g && (t || l);

wire [10:0] m_round = m_prod_norm[20:10] + rnd_inc;

always @(*) begin
    // FTZ
    if (e_x == 0 || e_y == 0 || e_sum_norm <= 0) begin
        o_z = {s_z, 15'b0};
    end
    else if (e_sum_norm >= 31 || (m_round[10] && e_sum_norm == 30)) begin
        o_z = {s_z, 5'b11111, 10'b0};
    end
    else begin
        if (m_round[10]) begin
            o_z = {s_z, e_sum_norm[4:0] + 5'b00001, m_round[9:0]};
        end
        else begin
            o_z = {s_z, e_sum_norm[4:0], m_round[9:0]};
        end
    end
end

endmodule
