module uart_rx #(
    parameter FREQ = 50000000,
    parameter RATE = 115200
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       i_rx,
    output reg [7:0]  o_data,
    output wire       o_vld
);

reg rx_d, RX_d;

always @(posedge clk) begin
    RX_d <= i_rx;
    rx_d <= RX_d;
end

wire rx_fall = ~RX_d && rx_d;
wire load = (state == IDLE) && rx_fall;

wire en;

counter #(
    .CNT_WIDTH($clog2(FREQ/RATE)),
    .CNT_LOAD (FREQ/RATE/2),
    .CNT_MAX  (FREQ/RATE-1)
) counter (
    .clk   (clk),
    .rst_n (rst_n),
    .i_load(load),
    .o_en  (en)
);

localparam IDLE  = 4'd0;
localparam START = 4'd1;
localparam BIT0  = 4'd8;
localparam BIT1  = 4'd9;
localparam BIT2  = 4'd10;
localparam BIT3  = 4'd11;
localparam BIT4  = 4'd12;
localparam BIT5  = 4'd13;
localparam BIT6  = 4'd14;
localparam BIT7  = 4'd15;
localparam STOP  = 4'd2;

reg [3:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        IDLE:    next_state = rx_fall ? START : state;
        START:   next_state = en      ? BIT0  : state;
        BIT0:    next_state = en      ? BIT1  : state;
        BIT1:    next_state = en      ? BIT2  : state;
        BIT2:    next_state = en      ? BIT3  : state;
        BIT3:    next_state = en      ? BIT4  : state;
        BIT4:    next_state = en      ? BIT5  : state;
        BIT5:    next_state = en      ? BIT6  : state;
        BIT6:    next_state = en      ? BIT7  : state;
        BIT7:    next_state = en      ? STOP  : state;
        STOP:    next_state = en      ? IDLE  : state;
        default: next_state = IDLE;
    endcase
end

wire shift_en = (state >= BIT0 && state <= BIT7) && en;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_data <= 8'b0;
    end else begin
        if (shift_en)
            o_data <= {rx_d, o_data[7:1]};
    end
end

assign o_vld = (state == STOP) && en && i_rx;

endmodule
