`include "alu_ops.vh"
`include "imm_types.vh"

module control (
    input  wire [31:0] i_instr,
    output reg [2:0]   o_imm_sel,
    output reg [1:0]   o_alu_sel1,
    output reg [1:0]   o_alu_sel2,
    output reg [3:0]   o_alu_op,
    output reg [2:0]   o_cmp_op,
    output wire        o_branch,
    output wire        o_jump,
    output reg         o_pc_sel,
    output reg         o_wb_sel1,
    output reg         o_wb_sel2,
    output wire        o_wb_en,
    output wire        o_wr_en
);

localparam [1:0] IMM   = 0;
localparam [1:0] SRC1  = 1;
localparam [1:0] ZERO  = 2;

localparam [1:0] SRC2  = 1;
localparam [1:0] PC    = 2;

localparam [0:0] WB_ALU    = 0;
localparam [0:0] WB_LSU    = 1;

localparam [0:0] WB_RES    = 0;
localparam [0:0] WB_PC_INC = 1;

// 32-bit: [1:0] = 2'b11;
wire [4:0] opcode = i_instr[6:2];
wire [2:0] funct3 = i_instr[14:12];

localparam [4:0] OP     = 5'b01100;
localparam [4:0] OP_IMM = 5'b00100;
localparam [4:0] STORE  = 5'b01000;
localparam [4:0] LOAD   = 5'b00000;
localparam [4:0] BRANCH = 5'b11000;
localparam [4:0] JALR   = 5'b11001;
localparam [4:0] JAL    = 5'b11011;
localparam [4:0] AUIPC  = 5'b00101;
localparam [4:0] LUI    = 5'b01101;

always @(*) begin
    case (opcode)
        OP:     {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {3'bX,   SRC1,  SRC2, WB_ALU, WB_RES };
        OP_IMM: {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_I, SRC1,  IMM,  WB_ALU, WB_RES };
        STORE:  {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_S, 2'bX,  2'bX, 1'bX,   1'bX   };
        LOAD:   {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_I, SRC1,  IMM,  WB_LSU, WB_RES };
        BRANCH: {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_B, 2'bX,  2'bX, 1'bX,   1'bX   };
        JALR:   {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_I, SRC1,  IMM,  1'bX, WB_PC_INC};
        JAL:    {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_J, IMM,   PC,   1'bX, WB_PC_INC};
        AUIPC:  {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_U, IMM,   PC,   WB_ALU, WB_RES };
        LUI:    {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {`IMM_U, ZERO,  IMM,  WB_ALU, WB_RES };
        default:
                {o_imm_sel, o_alu_sel1, o_alu_sel2, o_wb_sel1, o_wb_sel2} = {2'bX,   2'bX,  2'bX, 1'bX,   1'bX   };
    endcase
end

assign o_jump   = (opcode == JAL || opcode == JALR);
assign o_branch = (opcode == BRANCH);

always @(*) begin
    case (opcode)
        JALR:   o_pc_sel = 1'b0;
        JAL:    o_pc_sel = 1'b1;
        BRANCH: o_pc_sel = 1'b1;
        default:
                o_pc_sel = 1'b1;
    endcase
end

always @(*) begin
    if (opcode == BRANCH) begin
        o_cmp_op = funct3;
    end else begin
        o_cmp_op = 3'bX;
    end
end

always @(*) begin
    o_alu_op = `ALU_ADD; // default to add

    if (opcode == OP) begin
        o_alu_op = {i_instr[30], funct3};
    end else if (opcode == OP_IMM) begin
        case (funct3)
            3'b101: o_alu_op = {i_instr[30], funct3}; // srai, srli
            default:
                    o_alu_op = {1'b0, funct3};
        endcase
    end
end

assign o_wr_en = (opcode == STORE);
assign o_wb_en = (opcode != STORE) && (opcode != BRANCH);

endmodule
