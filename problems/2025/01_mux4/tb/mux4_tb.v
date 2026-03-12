module mux4_tb;
    localparam WIDTH     = 8;
    localparam NUM_TESTS = 1000;

    reg  [1:0]            i_sel;
    reg  [1:0][WIDTH-1:0] i_data;
    wire [WIDTH-1:0]      o_data;

    mux4 #(
        .WIDTH(WIDTH)
    ) dut (
        .i_sel(i_sel),
        .i_data(i_data),
        .o_data(o_data)
    );

    integer i = 0;
    integer j = 0;

    initial begin
        for (i = 0; i < NUM_TESTS; i++) begin
            i_data = $urandom;
            i_sel  = $urandom;

            #1;

            if (o_data != i_data[i_sel]) begin
                $display("[FAIL]");
                $display("%0t i_data: %h, sel = %b, o_data = %h",
                          $time, i_data[i_sel], i_sel, o_data);
            end
        end

        $display("PASSED");
        $finish;
    end
endmodule
