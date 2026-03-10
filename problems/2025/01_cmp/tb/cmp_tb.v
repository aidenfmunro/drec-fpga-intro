`timescale 1ns / 1ps

module cmp_tb;

reg  [31:0] rs1;
reg  [31:0] rs2;
reg  [2:0]  op;

wire        tkn; 

`include "cmp_ops.vh"

cmp dut (
    .i_rs1(rs1),
    .i_rs2(rs2),
    .i_op(op),
    .o_tkn(tkn)
);

integer run_cnt = 0;
integer err_cnt = 0;

task automatic check (
    input reg [31:0] i_rs1,
    input reg [31:0] i_rs2,
    input reg [2:0]  i_op,
    input reg        expected_tkn
); 
begin
    rs1 = i_rs1;
    rs2 = i_rs1;
    op  = i_op;

    #1;

    run_cnt++;

    if (tkn != expected_tkn) begin
        $display("[FAIL]: a(%h), b(%h), op(%b), taken(%b), exp(%b)", 
                  rs1, rs2, op, tkn, expected_tkn);
        err_cnt++;
    end
end
endtask

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, cmp_tb);


    check(32'd10,  32'd10,  CMP_BEQ, 1'b1);
    check(32'd10,  32'd5,   CMP_BEQ, 1'b0);

    check(32'd10,  32'd10,  CMP_BNE, 1'b0);
    check(32'd10,  32'd5,   CMP_BNE, 1'b1);

    check(-32'sd5, 32'd10,  CMP_BLT, 1'b1);
    check(32'd10,  -32'sd5, CMP_BLT, 1'b0);
    check(32'd10,  32'd10,  CMP_BLT, 1'b0);

    check(32'd10,  -32'sd5, CMP_BGE, 1'b1);
    check(-32'sd5, 32'd10,  CMP_BGE, 1'b0);
    check(-32'sd5, -32'sd5, CMP_BGE, 1'b1);

    check(-32'sd5, 32'd10,  CMP_BLTU, 1'b0);
    check(32'd5,   32'd10,  CMP_BLTU, 1'b1);

    check(-32'sd5, 32'd10,  CMP_BGEU, 1'b1);
    check(32'd5,   32'd10,  CMP_BGEU, 1'b0);
    check(32'd10,  32'd10,  CMP_BGEU, 1'b1);

    if (err_cnt == 0) begin
        $display("-> PASSED (%0d tests run)", run_cnt);
    end else begin
        $display("-> FAILED (%0d errors out of %0d tests)", err_cnt, run_cnt);
    end

    $finish; 
end

endmodule


