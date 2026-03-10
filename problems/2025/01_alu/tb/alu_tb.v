`timescale 1ns / 1ps

module alu_tb;

reg  [31:0] rs1;
reg  [31:0] rs2;
reg  [3:0]  op;

wire [31:0] rd;

`include "alu_ops.vh"

alu dut (
    .i_rs1(rs1),
    .i_rs2(rs2),
    .i_op(op),
    .o_rd(rd)
);

integer run_cnt = 0;
integer err_cnt = 0;

task automatic check (
    input reg [31:0] i_rs1,
    input reg [31:0] i_rs2,
    input reg [3:0]  i_op,
    input reg [31:0] expected_rd
);

begin
    rs1  = i_rs1;
    rs2  = i_rs2;
    op = i_op;

    #1;

    run_cnt++;

    if (rd !== expected_rd) begin
        $display("[FAIL]: rs1(%h), rs2(%h), ctrl(%b), rd(%h), exp_rd(%h)",
                 rs1, rs2, op, rd, expected_rd);
        err_cnt++;
    end
end
endtask

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, alu_tb);

    check(32'd10,   32'd15,   ALU_ADD,  32'd25);
    check(-32'sd5,  32'd5,    ALU_ADD,  32'd0);

    check(32'd20,   32'd5,    ALU_SUB,  32'd15);
    check(32'd10,   32'd15,   ALU_SUB,  -32'sd5);

    check(32'h1,    32'd4,    ALU_SLL,  32'h10);

    check(-32'sd5,  32'd10,   ALU_SLT,  32'd1);
    check(32'd10,   -32'sd5,  ALU_SLT,  32'd0);

    check(-32'sd5,  32'd10,   ALU_SLTU, 32'd0);
    check(32'd5,    32'd10,   ALU_SLTU, 32'd1);

    check(32'h0F,   32'h55,   ALU_XOR,  32'h5A);

    check(32'hF0000000, 32'd4, ALU_SRL, 32'h0F000000);

    check(32'hF0000000, 32'd4, ALU_SRA, 32'hFF000000);

    check(32'h0F,   32'hF0,   ALU_OR,   32'hFF);

    check(32'h0F,   32'h55,   ALU_AND,  32'h05);

    if (err_cnt == 0)
        $display("PASSED (%0d tests)", run_cnt);
    else
        $display("FAILED (%0d errors)", err_cnt);

    $finish;
end

endmodule
