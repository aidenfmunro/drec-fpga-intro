`timescale 1ns / 1ps

module tester #(
    parameter N = 12,
    parameter M = 32
);

integer err_cnt = 0;
integer run_cnt = 0;

reg  [N-1:0] in;
wire [M-1:0] out_beh, out_str;

sign_ext_behavioral #(
    .N(N),
    .M(M)
) dut_beh (
    .i_data(in),
    .o_data(out_beh)
);

sign_ext_structural #(
    .N(N),
    .M(M)
) dut_str (
    .i_data(in),
    .o_data(out_str)
);

task automatic check;
    input [N-1:0] input_val;
    reg   [M-1:0] expected_val;
    begin
        in = input_val;
        #10;

        expected_val = $signed(input_val);

        run_cnt++;

        if (out_beh !== expected_val || out_str !== expected_val) begin
            $display("[ERROR] Input: %h | Exp: %h | Beh: %h | Str: %h",
                        input_val, expected_val, out_beh, out_str);
            err_cnt++;
        end
    end
endtask

initial begin
        #1;
        $display("Starting test suite for N=%0d -> M=%0d...", N, M);

        // Edge cases
        check(0);
        check({1'b0, {(N-1){1'b1}} });
        check({1'b1, {(N-1){1'b0}} });
        check({N{1'b1}});

        repeat(5) check($urandom);

        if (err_cnt == 0)
            $display("-> N=%0d: PASSED (%0d tests)", N, run_cnt);
        else
            $display("-> N=%0d: FAILED (%0d errors)", N, err_cnt);
end

endmodule

module sign_ext_tb;

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, sign_ext_tb);
    end

    tester #(.N(12), .M(32)) test_12 ();
    tester #(.N(20), .M(32)) test_20 ();

endmodule
