`timescale 1ns / 1ps

module sign_ext_tb;

localparam N1 = 12;
localparam M1 = 32;

localparam N2 = 20;
localparam M2 = 32;

integer errors_cnt    = 0;
integer tests_run_cnt = 0;

reg  [N1-1:0] in1;
wire [M1-1:0] out1_beh, out1_str;

sign_ext_behavioral #(
    .N(N1),
    .M(M1)
) dut1_beh (
    .i_data(in1),
    .o_data(out1_beh)
);

sign_ext_structural #(
    .N(N1),
    .M(M1)
) dut1_str (
    .i_data(in1),
    .o_data(out1_str)
);

reg  [N2-1:0] in2;
wire [M2-1:0] out2_beh, out2_str;

sign_ext_behavioral #(
    .N(N2),
    .M(M2)
) dut2_beh (
    .i_data(in2),
    .o_data(out2_beh)
);

sign_ext_structural #(
    .N(N2),
    .M(M2)
) dut2_str (
    .i_data(in2),
    .o_data(out2_str)
);

task automatic check_case1;
    input [N1-1:0] input_val;
    reg   [M1-1:0] expected_val;
    begin
        in1 = input_val;
        #10;

        expected_val = $signed(input_val);

        tests_run_cnt++;

        if (out1_beh !== expected_val || out1_str !== expected_val) begin
            $display("[ERROR CASE 1] Input: %h | Exp: %h | Beh: %h | Str: %h",
                        input_val, expected_val, out1_beh, out1_str);
            errors_cnt++;
        end
    end
endtask

task automatic check_case2;
    input [N2-1:0] input_val;
    reg   [M2-1:0] expected_val;
    begin
        in2 = input_val;
        #10;

        expected_val = $signed(input_val);

        tests_run_cnt++;

        if (out2_beh !== expected_val || out2_str !== expected_val) begin
            $display("[ERROR CASE 2] Input: %h | Exp: %h | Beh: %h | Str: %h",
                        input_val, expected_val, out2_beh, out2_str);
            errors_cnt++;
        end
    end
endtask

initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, sign_ext_tb);

    $display("<-- START SIMULATION -->\n");

    $display("Testing N=12 -> M=32... ");
    check_case1(12'h000); // Edge cases first
    check_case1(12'h7FF);
    check_case1(12'h800);
    check_case1(12'hFFF);
    check_case1(12'h001);

    repeat(5) check_case1($urandom);

    $display("\nTesting N=20 -> M=32...");
    check_case2(20'h00000); // Edge cases first
    check_case2(20'h7FFFF);
    check_case2(20'h80000);
    check_case2(20'hFFFFF);

    repeat(5) check_case2($urandom);

    $display("\n<-- RESULTS -->\n");
    $display("Tests Run: %0d", tests_run_cnt);
    $display(":    %0d", errors_cnt);

    if (errors_cnt == 0)
        $display("\nAll tests passed!\n");
    else
        $display("\nSome tests have failed...\n");

    $finish;
end

endmodule
