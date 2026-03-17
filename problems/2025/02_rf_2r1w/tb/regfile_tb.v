`timescale 1ns / 1ps

module regfile_tb;

localparam DATA_WIDTH = 32;
localparam REG_COUNT  = 32;
localparam ADDR_WIDTH = $clog2(REG_COUNT);
localparam CLK_PERIOD = 10;

reg                   clk   = 1'b0;
reg                   rst_n = 1'b1;

reg  [ADDR_WIDTH-1:0] i_rd_addr1;
reg  [ADDR_WIDTH-1:0] i_rd_addr2;
wire [DATA_WIDTH-1:0] o_rd_data1;
wire [DATA_WIDTH-1:0] o_rd_data2;

reg                   i_wr_en;
reg  [ADDR_WIDTH-1:0] i_wr_addr;
reg  [DATA_WIDTH-1:0] i_wr_data;

regfile #(
    .DATA_WIDTH(DATA_WIDTH),
    .REG_COUNT(REG_COUNT)
) dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_rd_addr1 (i_rd_addr1),
    .i_rd_addr2(i_rd_addr2),
    .o_rd_data1(o_rd_data1),
    .o_rd_data2(o_rd_data2),
    .i_wr_en(i_wr_en),
    .i_wr_addr(i_wr_addr),
    .i_wr_data(i_wr_data)
);

always begin
    #(CLK_PERIOD/2) clk <= ~clk;
end

task write_reg (
    input reg [ADDR_WIDTH-1:0] addr, 
    input reg [DATA_WIDTH-1:0] data
);
    begin
        @(posedge clk);
        i_wr_en   = 1'b1;
        i_wr_addr = addr;
        i_wr_data = data;
        @(posedge clk);
        i_wr_en   = 1'b0;
    end
endtask

task check_reg (
    input reg [ADDR_WIDTH-1:0] addr, 
    input reg [DATA_WIDTH-1:0] expected
);
begin
        i_rd_addr1 = addr;
        #1;
        if (o_rd_data1 !== expected) begin
            $display("[FAIL] Time: %0t | Reg: %0d | Expected: %h, Got: %h", 
                     $realtime, addr, expected, o_rd_data1);
        end else begin
            $display("[PASS] Time: %0t | Reg: %0d | Data: %h", 
                     $realtime, addr, o_rd_data1);
        end
    end
endtask

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, regfile_tb);

    rst_n      <= 0;
    i_rd_addr1 <= 0;
    i_rd_addr2 <= 0;
    i_wr_en    <= 0;
    i_wr_addr  <= 0;
    i_wr_data  <= 0;

    repeat (2) @(posedge clk);

    rst_n = 1;

    write_reg(5'd0, 32'hDEADBEEF);
    check_reg(5'd0, 32'h00000000);

    write_reg(5'd1, 32'h11111111);
    write_reg(5'd2, 32'h22222222);
    write_reg(5'd15, 32'hFFFFFFFF);
    write_reg(5'd31, 32'hA5A5A5A5);

    check_reg(5'd1,  32'h11111111);
    check_reg(5'd2,  32'h22222222);
    check_reg(5'd15, 32'hFFFFFFFF);
    check_reg(5'd31, 32'hA5A5A5A5);

    i_rd_addr1 = 5'd1;
    i_rd_addr2 = 5'd2;
    #1;
    if (o_rd_data1 == 32'h11111111 && o_rd_data2 == 32'h22222222)
        $display("[PASS] Dual Read");
    else
        $display("[FAIL] Dual Read");

    @(posedge clk);

    i_wr_en    <= 1'b1;
    i_wr_addr  <= 5'd5;
    i_wr_data  <= 33'h55555555;
    i_rd_addr1 <= 5'd5;
    #1;
    if (o_rd_data1 == 32'h00000000)
        $display("[PASS] Read during write");
    else
        $display("[FAIL] Read %h", o_rd_data1);
        
    @(posedge clk);
    i_wr_en = 0;
    @(posedge clk);

    $finish;
end

endmodule
