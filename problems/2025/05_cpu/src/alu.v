`include "alu_ops.vh"

module alu (
    input  wire [31:0] i_rs1,
    input  wire [31:0] i_rs2,
    input  wire [3:0]  i_op,
    output reg  [31:0] o_rd
);

always @(*) begin
    case (i_op)
        `ALU_ADD:  o_rd = i_rs1 + i_rs2;
        `ALU_SUB:  o_rd = i_rs1 - i_rs2;
        `ALU_SLL:  o_rd = i_rs1 << i_rs2[4:0];
        `ALU_SRL:  o_rd = i_rs1 >> i_rs2[4:0];
        `ALU_SRA:  o_rd = $signed(i_rs1) >>> i_rs2[4:0];
        `ALU_SLT:  o_rd = ($signed(i_rs1) < $signed(i_rs2)) ? 32'd1 : 32'd0;
        `ALU_SLTU: o_rd = (i_rs1 < i_rs2) ? 32'd1 : 32'd0;
        `ALU_XOR:  o_rd = i_rs1 ^ i_rs2;
        `ALU_OR:   o_rd = i_rs1 | i_rs2;
        `ALU_AND:  o_rd = i_rs1 & i_rs2;

        default:  o_rd = 32'dX;
    endcase
end

endmodule
