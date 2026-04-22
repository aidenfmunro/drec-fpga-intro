`include "config.vh"

module core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  i_instr_data,
    output wire [29:0]  o_instr_addr,
    output wire [29:0]  o_mem_addr,
    output wire [31:0]  o_mem_data,
    output wire         o_mem_we,
    output wire [3:0]   o_mem_mask,
    input  wire [31:0]  i_mem_data
);

wire branch;
wire jump;
wire cmp_taken;
wire taken = (branch && cmp_taken) || jump;

wire [1:0] ctrl2alu_sel1;
wire [1:0] ctrl2alu_sel2;
wire [1:0] ctrl2alu_sel_wb;
wire [3:0] ctrl2alu_op;
wire [2:0] ctrl2cmp_op;
wire       ctrl2lsu_wr_en;

wire [31:0] alu_rs1;
wire [31:0] alu_rs2;
wire [31:0] alu_res;

wire [19:15] rs1 = i_instr_data[19:15];
wire [24:20] rs2 = i_instr_data[24:20];
wire [11:7]  rd  = i_instr_data[11:7];

wire [31:0] src1;
wire [31:0] src2;

wire s_bit = i_instr_data[31];

wire [31:0] imm_u = {i_instr_data[31:12], 12'b0};
wire [31:0] imm_b = {{20{s_bit}}, i_instr_data[7], i_instr_data[30:25], i_instr_data[11:8], 1'b0};
wire [31:0] imm_j = {{12{s_bit}}, i_instr_data[19:12], i_instr_data[20], i_instr_data[30:21], 1'b0};
wire [31:0] imm_i = {{21{s_bit}}, i_instr_data[30:20]};
wire [31:0] imm_s = {{21{s_bit}}, i_instr_data[30:25], i_instr_data[11:7]};

wire [2:0] funct3 = i_instr_data[14:12];

wire [31:0] dst;
wire        dst_en;

wire [31:0] lsu_data;

reg  [29:0] pc;
wire [29:0] pc_inc;

assign o_instr_addr = pc;

assign pc_inc = pc + 1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc      <= 0;
    end else begin
        if (taken) begin
            pc <= alu_res[31:2];
        end else begin
            pc <= pc_inc;
        end
    end
end

regfile #(
    .DATA_WIDTH(32),
    .REG_COUNT (32)
) regfile (
    .clk(clk),
    .i_rd_addr1(rs1),
    .i_rd_addr2(rs2),
    .o_rd_data1(src1),
    .o_rd_data2(src2),
    .i_wr_en   (dst_en),
    .i_wr_addr (rd),
    .i_wr_data (dst)
);


mux4 #(
    .WIDTH(32)
) mux1 (
    .i_sel  (ctrl2alu_sel1),
    .i_data0(imm_u),
    .i_data1(imm_b),
    .i_data2(imm_j),
    .i_data3 (src1),
    .o_data  (alu_rs1)
);

mux4 #(
    .WIDTH(32)
) mux2 (
    .i_sel  (ctrl2alu_sel2),
    .i_data0(src2),
    .i_data1(imm_i),
    .i_data2(imm_s),
    .i_data3({pc, 2'b0}),
    .o_data (alu_rs2)
);

mux4 #(
    .WIDTH(32)
) mux_wb (
    .i_sel  (ctrl2alu_sel_wb),
    .i_data0(imm_u),
    .i_data1(alu_res),
    .i_data2(lsu_data),
    .i_data3({pc_inc, 2'b0}),
    .o_data (dst)
);

control control (
    .i_instr   (i_instr_data),
    .o_alu_sel1(ctrl2alu_sel1),
    .o_alu_sel2(ctrl2alu_sel2),
    .o_alu_op  (ctrl2alu_op),
    .o_cmp_op  (ctrl2cmp_op),
    .o_branch  (branch),
    .o_jump    (jump),
    .o_wb_sel  (ctrl2alu_sel_wb),
    .o_wb_en   (dst_en),
    .o_wr_en   (ctrl2lsu_wr_en)
);

alu alu (
    .i_rs1(alu_rs1),
    .i_rs2(alu_rs2),
    .i_op (ctrl2alu_op),
    .o_rd (alu_res)
);

cmp cmp (
    .i_rs1(src1),
    .i_rs2(src2),
    .i_op (ctrl2cmp_op),
    .o_tkn(cmp_taken)
);

lsu lsu (
    .i_addr(alu_res[31:2]), // which addr?
    .i_data    (src2),
    .i_funct3  (funct3),
    .i_wr_en   (ctrl2lsu_wr_en),
    .o_mem_addr(o_mem_addr),
    .o_mem_data(o_mem_data),
    .o_mem_we  (o_mem_we),
    .o_mem_mask(o_mem_mask),
    .i_mem_data(i_mem_data),
    .o_data    (lsu_data)
);

endmodule
