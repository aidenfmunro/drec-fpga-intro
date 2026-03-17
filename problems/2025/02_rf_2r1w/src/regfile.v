module regfile #(
    parameter DATA_WIDTH = 32,
    parameter REG_COUNT  = 32
) (
    input wire clk,
    input wire rst_n,
    
    input  wire [$clog2(REG_COUNT)-1:0] i_rd_addr1,
    input  wire [$clog2(REG_COUNT)-1:0] i_rd_addr2,
    output wire [DATA_WIDTH-1:0]        o_rd_data1,
    output wire [DATA_WIDTH-1:0]        o_rd_data2,
    input  wire                         i_wr_en,
    input  wire [$clog2(REG_COUNT)-1:0] i_wr_addr,
    input  wire [DATA_WIDTH-1:0]        i_wr_data
);

reg [DATA_WIDTH-1:0] mem [0:REG_COUNT-1];

integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < REG_COUNT; i++) begin
            mem[i] <= {DATA_WIDTH{1'b0}};
        end
    end else begin
        if (i_wr_en && (i_wr_addr != 0)) begin
            mem[i_wr_addr] <= i_wr_data;
        end
    end
end

assign o_rd_data1 = mem[i_rd_addr1];
assign o_rd_data2 = mem[i_rd_addr2];

endmodule
