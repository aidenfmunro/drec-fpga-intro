module timer (
    input  wire        clk,
    input  wire        rst_n,
    output wire [15:0] o_data
);

reg [11:0] cnt;

assign o_data = {cnt[11:4], 4'b0, cnt[3:0]};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt[11:8] <= 4'd6;
        cnt[7:4]  <= 4'd0;
        cnt[3:0]  <= 4'd0;
    end else begin
        if (cnt[3:0] != 4'b0) begin
            cnt[3:0] <= cnt[3:0] - 1'b1;
        end else begin
            if (cnt != 4'b0) begin
                cnt[3:0] <= 4'd9;

                if (cnt[7:4] != 4'b0) begin
                    cnt[7:4] <= cnt[7:4] - 1'b1;
                end else begin
                    cnt[7:4] <= 4'd9;

                    if (cnt[11:8] != 4'b0) begin
                        cnt[11:8] <= cnt[11:8] - 1'b1;
                    end
                end
            end
        end 
    end
end

endmodule
