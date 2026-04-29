`include "alu_ops.vh"
`include "opcodes.vh"
`include "imm_types.vh"

module control (
<<<<<<< Updated upstream
    input wire clk,
=======
>>>>>>> Stashed changes
    input  wire [31:0] i_instr,
    input  wire [4:0]  i_rd,
    input  wire        i_flush,
    output reg  [1:0]  o_alu_sel1,
    output reg  [1:0]  o_alu_sel2,
    output reg  [3:0]  o_alu_op,
    output reg  [2:0]  o_cmp_op,
    output wire        o_branch,
    output wire        o_jump,
    output reg         o_pc_sel,
    output reg         o_wb_sel1,
    output reg         o_wb_sel2,
<<<<<<< Updated upstream
    input  wire        i_wb_en_d,
=======
    input  wire        i_bypass_en,
>>>>>>> Stashed changes
    output wire        o_wb_en,
    output wire        o_wr_en,
    output wire        o_bypass_sel1,
    output wire        o_bypass_sel2
);

localparam [1:0] IMM   = 0;
localparam [1:0] SRC1  = 1;
localparam [1:0] ZERO  = 2;

localparam [1:0] SRC2  = 1;
localparam [1:0] PC    = 2;

localparam [0:0] WB_ALU    = 0;
localparam [0:0] WB_PC_INC = 1;

localparam [0:0] WB_RES    = 0;
localparam [0:0] WB_LSU    = 1;

// 32-bit: [1:0] = 2'b11;
wire [4:0] rs1 = i_instr[19:15];
wire [4:0] rs2 = i_instr[24:20];
wire [4:0] opcode = i_instr[6:2];
wire [2:0] funct3 = i_instr[14:12];

always @(*) begin
    case (opcode)
        `OP:     {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {SRC1,  SRC2, WB_ALU,    WB_RES };
        `OP_IMM: {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {SRC1,  IMM,  WB_ALU,    WB_RES };
        `STORE:  {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {2'bX,  2'bX, 1'bX,      1'bX   };
        `LOAD:   {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {SRC1,  IMM,  2'bX,      WB_LSU };
        `BRANCH: {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {2'bX,  2'bX, 1'bX,      1'bX   };
        `JALR:   {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {SRC1,  IMM,  WB_PC_INC, WB_RES };
        `JAL:    {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {IMM,   PC,   WB_PC_INC, WB_RES };
        `AUIPC:  {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {IMM,   PC,   WB_ALU,    WB_RES };
        `LUI:    {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {ZERO,  IMM,  WB_ALU,    WB_RES };
        default:
                 {o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {2'bX,  2'bX, 1'bX,      1'bX   };
    endcase
end

assign o_jump   = (opcode == `JAL || opcode == `JALR) && !i_flush;
assign o_branch = (opcode == `BRANCH) && !i_flush;

always @(*) begin
    case (opcode)
        `JALR:   o_pc_sel = 1'b0;
        `JAL:    o_pc_sel = 1'b1;
        `BRANCH: o_pc_sel = 1'b1;
        default:
                 o_pc_sel = 1'b1;
    endcase
end

always @(*) begin
    if (opcode == `BRANCH) begin
        o_cmp_op = funct3;
    end else begin
        o_cmp_op = 3'bX;
    end
end

always @(*) begin
    o_alu_op = `ALU_ADD; // default to add

    if (opcode == `OP) begin
        o_alu_op = {i_instr[30], funct3};
    end else if (opcode == `OP_IMM) begin
        case (funct3)
            3'b101: o_alu_op = {i_instr[30], funct3}; // srai, srli
            default:
                    o_alu_op = {1'b0, funct3};
        endcase
    end
end

assign o_wr_en = (opcode == `STORE) && !i_flush;
assign o_wb_en = ((opcode != `STORE) && (opcode != `BRANCH)) && !i_flush;

<<<<<<< Updated upstream
assign o_bypass_sel1 = (i_rd == rs1) && (i_rd != 5'b0) && i_wb_en_d;
assign o_bypass_sel2 = (i_rd == rs2) && (i_rd != 5'b0) && i_wb_en_d;
=======
assign o_bypass_sel1 = (i_rd == rs1) && (i_rd != 5'b0) && i_bypass_en;
assign o_bypass_sel2 = (i_rd == rs2) && (i_rd != 5'b0) && i_bypass_en;
>>>>>>> Stashed changes

endmodule
