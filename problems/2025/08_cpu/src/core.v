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
    input  wire [31:0]  i_mem_data,
    output wire         o_instr_stall
);

wire branch;
wire jump;
wire cmp_taken;
wire pc_sel;
wire taken = (branch && cmp_taken) || jump;


wire [1:0] ctrl2alu_sel1;
wire [1:0] ctrl2alu_sel2;
wire ctrl2wb_sel1;
wire ctrl2wb_sel2;
wire [3:0] ctrl2alu_op;
wire [2:0] ctrl2cmp_op;
wire       ctrl2lsu_wr_en;
wire [2:0] ctrl2se_imm_sel;
wire [31:0] imm;

wire [31:0] alu_rs1;
wire [31:0] alu_rs2;
wire [31:0] alu_res;

wire [4:0] rs1 = i_instr_data[19:15];
wire [4:0] rs2 = i_instr_data[24:20];
wire [4:0] rd  = i_instr_data[11:7];
reg [4:0]  rd_d;


wire [31:0] src1;
wire [31:0] src2;

wire [2:0] funct3 = i_instr_data[14:12];

wire [31:0] dst;
wire        dst_en;
reg         dst_en_d;


wire [31:0] lsu_data;

reg  [29:0] pc;
wire [29:0] pc_next;
wire [29:0] pc_inc = pc + 1;
reg [29:0] pc_inc_d;


assign o_instr_addr = pc_next;

wire [31:0] pc_chosen;

mux2 #(
    .WIDTH(32)
) jump_offset (
    .i_sel  (pc_sel),
    .i_data0(src1),
    .i_data1({pc, 2'b0}),
    .o_data (pc_chosen)
);

wire [31:0] pc_target = pc_chosen + imm;

mux2 #(
    .WIDTH(30)
) pc_taken (
    .i_sel  (taken),
    .i_data0(pc_inc),
    .i_data1(pc_target[31:2]),
    .o_data (pc_next)
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= 0;
    end else begin
        pc <= pc_next;
    end
end


sign_ext sign_ext (
    .i_instr  (i_instr_data),
    .i_imm_sel(ctrl2se_imm_sel),
    .o_imm    (imm)
);

regfile #(
    .DATA_WIDTH(32),
    .REG_COUNT (32)
) regfile (
    .clk(clk),
    .i_rd_addr1(rs1),
    .i_rd_addr2(rs2),
    .o_rd_data1(src1),
    .o_rd_data2(src2),
    .i_wr_en   (dst_en_d),
    .i_wr_addr (rd_d),
    .i_wr_data (dst),
    .o_stall   (o_instr_stall)
);


mux3 #(
    .WIDTH(32)
) mux_alu_1 (
    .i_sel  (ctrl2alu_sel1),
    .i_data0(imm),
    .i_data1(src1),
    .i_data2(0),
    .o_data (alu_rs1)
);

mux3 #(
    .WIDTH(32)
) mux_alu_2 (
    .i_sel  (ctrl2alu_sel2),
    .i_data0(imm),
    .i_data1(src2),
    .i_data2({pc, 2'b0}),
    .o_data (alu_rs2)
);

reg ctrl2wb_sel1_d;
reg ctrl2wb_sel2_d;
reg [31:0] alu_res_d;

always @(posedge clk) begin
    ctrl2wb_sel1_d <= ctrl2wb_sel1;
    ctrl2wb_sel2_d <= ctrl2wb_sel2;
    alu_res_d      <= alu_res;
    rd_d           <= rd;
    pc_inc_d       <= pc_inc;
    dst_en_d       <= dst_en;
end

wire [31:0] wb1_res;

mux2 #(
    .WIDTH(32)
) mux_wb_1 (
    .i_sel  (ctrl2wb_sel1_d),
    .i_data0(alu_res_d),
    .i_data1(lsu_data),
    .o_data (wb1_res)
);

mux2 #(
    .WIDTH(32)
) mux_wb_2 (
    .i_sel  (ctrl2wb_sel2_d),
    .i_data0(wb1_res),
    .i_data1({pc_inc_d, 2'b0}),
    .o_data (dst)
);

control control (
    .i_instr   (i_instr_data),
    .o_imm_sel (ctrl2se_imm_sel),
    .o_alu_sel1(ctrl2alu_sel1),
    .o_alu_sel2(ctrl2alu_sel2),
    .o_alu_op  (ctrl2alu_op),
    .o_cmp_op  (ctrl2cmp_op),
    .o_branch  (branch),
    .o_jump    (jump),
    .o_pc_sel  (pc_sel),
    .o_wb_sel1 (ctrl2wb_sel1),
    .o_wb_sel2 (ctrl2wb_sel2),
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
    .clk(clk),
    .i_addr    (src1),
    .i_offset  (imm),
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
