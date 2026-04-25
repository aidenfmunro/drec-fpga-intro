module regfile #(
    parameter DATA_WIDTH = 32,
    parameter REG_COUNT  = 32
) (
    input wire clk,

    input  wire [$clog2(REG_COUNT)-1:0] i_rd_addr1,
    input  wire [$clog2(REG_COUNT)-1:0] i_rd_addr2,
    output reg  [DATA_WIDTH-1:0]        o_rd_data1,
    output reg  [DATA_WIDTH-1:0]        o_rd_data2,
    input  wire                         i_wr_en,
    input  wire [$clog2(REG_COUNT)-1:0] i_wr_addr,
    input  wire [DATA_WIDTH-1:0]        i_wr_data,
    output reg                          o_stall
);

reg [DATA_WIDTH-1:0] mem [0:REG_COUNT-1];

always @(posedge clk) begin
    if (i_wr_en && (i_wr_addr != 0)) begin
        mem[i_wr_addr] <= i_wr_data;
    end
end

always @(*) begin
    o_stall = 1'b0;

    if (i_wr_en && (i_wr_addr != 0) && (i_rd_addr1 == i_wr_addr)) begin
        o_rd_data1 = i_wr_data;
        o_stall = 1'b1;
    end else begin
        o_rd_data1 = (i_rd_addr1 == 0) ? 0 : mem[i_rd_addr1];
    end

    if (i_wr_en && (i_wr_addr != 0) && (i_rd_addr2 == i_wr_addr)) begin
        o_rd_data2 = i_wr_data;
        o_stall = 1'b1;
    end else begin
        o_rd_data2 = (i_rd_addr2 == 0) ? 0 : mem[i_rd_addr2];
    end
end

endmodule
