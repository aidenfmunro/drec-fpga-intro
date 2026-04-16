module control (
    input wire [31:0] i_instr,
    output reg [1:0]  o_alu_sel1,
    output reg [1:0]  o_alu_sel2,
    output reg [3:0]  o_alu_op,
    output reg [2:0]  o_cmp_op,
    output wire       o_branch,
    output wire       o_jump,
    output reg [1:0]  o_wb_sel,
    output wire       o_wb_en,
    output wire       o_wr_en
);

localparam [1:0] U_IMM = 0;
localparam [1:0] B_IMM = 1;
localparam [1:0] J_IMM = 2;
localparam [1:0] SRC1  = 3;

localparam [1:0] SRC2  = 0;
localparam [1:0] I_IMM = 1;
localparam [1:0] S_IMM = 2;
localparam [1:0] PC    = 3;

localparam [1:0] WB_U_IMM  = 0;
localparam [1:0] WB_ALU    = 1;
localparam [1:0] WB_LSU    = 2;
localparam [1:0] WB_PC_INC = 3;

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
        OP:     {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SRC1,  SRC2,  WB_ALU   };
        OP_IMM: {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SRC1,  I_IMM, WB_ALU   };
        STORE:  {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SRC1,  S_IMM, 2'bX     };
        LOAD:   {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SRC1,  I_IMM, WB_LSU   };
        BRANCH: {o_alu_sel1, o_alu_sel2, o_wb_sel} = {B_IMM, PC,    WB_ALU   };
        JALR:   {o_alu_sel1, o_alu_sel2, o_wb_sel} = {SRC1,  I_IMM, WB_PC_INC};
        JAL:    {o_alu_sel1, o_alu_sel2, o_wb_sel} = {J_IMM, PC,    WB_PC_INC};
        AUIPC:  {o_alu_sel1, o_alu_sel2, o_wb_sel} = {U_IMM, PC,    WB_ALU   };
        LUI:    {o_alu_sel1, o_alu_sel2, o_wb_sel} = {2'bX,  2'bX,  WB_U_IMM };
        default:
                {o_alu_sel1, o_alu_sel2, o_wb_sel} = {2'bX, 2'bX, 2'bX};
    endcase
end

assign o_jump   = (opcode == JAL || opcode == JALR);
assign o_branch = (opcode == BRANCH);

always @(*) begin
    if (opcode == BRANCH) begin
        o_cmp_op = funct3;
    end else begin
        o_cmp_op = 3'bX;
    end
end

always @(*) begin
    o_alu_op = 4'b0; // default to add

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
