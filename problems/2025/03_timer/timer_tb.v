module timer_tb;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #10 clk <= ~clk;
end

wire [15:0] data;

timer timer (
    .clk(clk),
    .rst_n(rst_n),
    .o_data(data)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, timer_tb);
    
    rst_n <= 1'b0;
    #10
    rst_n <= 1'b1;
    #10000

    $finish();
end

endmodule
