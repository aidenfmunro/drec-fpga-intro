`include "imm_types.vh"
`include "opcodes.vh"

module sign_ext (
    input  wire [31:0] i_instr,
    output reg  [31:0] o_imm
);

reg [2:0] imm_sel;
wire [4:0] opcode = i_instr[6:2];

always @(*) begin
    case (opcode)
        `OP:     imm_sel = 3'bX;
        `OP_IMM: imm_sel = `IMM_I;
        `STORE:  imm_sel = `IMM_S;
        `LOAD:   imm_sel = `IMM_I;
        `BRANCH: imm_sel = `IMM_B;
        `JALR:   imm_sel = `IMM_I;
        `JAL:    imm_sel = `IMM_J;
        `AUIPC:  imm_sel = `IMM_U;
        `LUI:    imm_sel = `IMM_U;
        default:
                 imm_sel = 3'bX;
    endcase
end

wire s_bit = i_instr[31];

always @(*) begin
    case (imm_sel)
        `IMM_U: o_imm = {i_instr[31:12], 12'b0};
        `IMM_B: o_imm = {{20{s_bit}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};
        `IMM_J: o_imm = {{12{s_bit}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
        `IMM_I: o_imm = {{21{s_bit}}, i_instr[30:20]};
        `IMM_S: o_imm = {{21{s_bit}}, i_instr[30:25], i_instr[11:7]};
        default:
                o_imm = 32'bX;
    endcase
end

endmodule
