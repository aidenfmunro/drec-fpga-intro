`timescale 1ns/1ps

module shiftreg_tb;

localparam WIDTH = 8;

reg clk   = 1'b0;
reg rst_n = 1'b1;

reg [WIDTH-1:0] i_data; 
wire o_data;

reg i_load_en = 1'b0;
reg i_shift_en = 1'b0;

shiftreg #(
    .WIDTH(WIDTH)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_load_en(i_load_en),
    .i_shift_en(i_shift_en),
    .i_data(i_data),
    .o_data(o_data)
);

always begin
    #10 clk <= ~clk;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, shiftreg_tb);
end

integer err_cnt;
integer i;
initial begin
    i_data <= $urandom;

    rst_n <= 1'b0;
    #20;
    rst_n <= 1'b1;
    #20;

    i_load_en <= 1'b1;

    repeat (2) @(posedge clk);

    i_load_en <= 1'b0;
    i_shift_en <= 1'b1;

    @(posedge clk);

    for (i = 0; i < WIDTH - 1; i++) begin
        if (o_data !== i_data[WIDTH-1-i]) begin
            $display("[FAIL] %t", $realtime);
            err_cnt += 1;
        end

        @(posedge clk);
    end

    if (err_cnt != 0 ) begin
        $display("[PASS]");
    end

    $finish();
end

endmodule
