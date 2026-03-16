module sync_fifo #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [DATA_WIDTH-1:0] i_wr_data,
    input  wire                  i_wr_en,
    output wire                  o_wr_full,

    output wire [DATA_WIDTH-1:0] o_rd_data,
    input  wire                  i_rd_en,
    output wire                  o_rd_empty
);

localparam DEPTH = 2 ** ADDR_WIDTH;

reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

reg [ADDR_WIDTH:0] rd_ptr, wr_ptr;
wire [ADDR_WIDTH-1:0] rd_addr, wr_addr;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= {(ADDR_WIDTH + 1){1'b0}};
        wr_ptr <= {(ADDR_WIDTH + 1){1'b0}};
    end
    if (i_rd_en) begin
        rd_ptr <= rd_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
    end
    if (i_wr_en) begin
        wr_ptr <= wr_ptr + {{ADDR_WIDTH{1'b0}}, 1'b1};
    end
end

always @(posedge clk) begin
    if (i_wr_en) begin
        mem[wr_addr] <= i_wr_data;
    end
end

assign rd_addr = rd_ptr[ADDR_WIDTH-1:0];
assign wr_addr = wr_ptr[ADDR_WIDTH-1:0];

assign o_wr_full  = (rd_addr == wr_addr) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
assign o_rd_empty = (rd_addr == wr_addr) && (wr_ptr[ADDR_WIDTH] == rd_ptr[ADDR_WIDTH]);

assign o_rd_data = mem[rd_addr];

endmodule
