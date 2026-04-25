`include "cmp_ops.vh"

module cmp (
    input wire [31:0] i_rs1,
    input wire [31:0] i_rs2,
    input wire [2:0]  i_op,
    output reg o_tkn
);

always @(*) begin
    case (i_op)
        `CMP_BEQ:  o_tkn = (i_rs1 == i_rs2);
        `CMP_BNE:  o_tkn = (i_rs1 != i_rs2);
        `CMP_BLT:  o_tkn = ($signed(i_rs1) < $signed(i_rs2));
        `CMP_BGE:  o_tkn = ($signed(i_rs1) >= $signed(i_rs2));
        `CMP_BLTU: o_tkn = (i_rs1 < i_rs2);
        `CMP_BGEU: o_tkn = (i_rs1 >= i_rs2);

        default: o_tkn = 1'b1;
    endcase
end

endmodule
