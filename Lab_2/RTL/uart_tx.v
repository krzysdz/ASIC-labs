module uart_tx #
(
  parameter BAUD_RATE    = 115_200,             // Baud rate
  parameter CLOCK_RATE   = 50_000_000
) (
    input i_clk,
    input i_rst,
    input [7:0] i_data_in,
    input i_send_data,
    output o_transmission,
    output reg o_tx_out
);
    localparam IDLE = 2'd0;
    localparam WAIT_START = 2'd1;
    localparam START = 2'd2;
    localparam TRANSMITTING = 2'd3;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [7:0] data;
    reg [2:0] bit_cnt;
    wire baud_en;

    uart_baud_gen # (
        .BAUD_RATE      (BAUD_RATE),
        .CLOCK_RATE     (CLOCK_RATE),
        .OVERSAMPLE_MUL (1)
    ) uart_baud_gen_tx_i0 (
        .i_clk         (i_clk),
        .i_rst         (i_rst),
        .o_baud_en (baud_en)
    );

    always @(posedge i_clk, negedge i_rst) begin
        if (!i_rst) begin
            state <= IDLE;
            data <= 0;
            bit_cnt <= 0;
        end else begin
            state <= next_state;
            if (baud_en) begin
                if (state == START) bit_cnt <= 0;
                else if (state == TRANSMITTING) bit_cnt <= bit_cnt + 1;
            end
            if (state == IDLE && i_send_data) data <= i_data_in;
        end
    end

    always @(*) begin
    case (state)
        IDLE: next_state = i_send_data ? (baud_en ? START : WAIT_START) : IDLE;
        WAIT_START: next_state = baud_en ? START : WAIT_START;
        START: next_state = baud_en ? TRANSMITTING : START;
        TRANSMITTING: next_state = (baud_en && bit_cnt == 3'd7) ? IDLE : TRANSMITTING;
        default: next_state = IDLE;
    endcase
    end

    always @(*) begin
        case (state)
            IDLE: o_tx_out = 1;
            WAIT_START: o_tx_out = 1;
            START: o_tx_out = 0;
            TRANSMITTING: o_tx_out = data[bit_cnt];
            default: o_tx_out = 1;
        endcase
    end

    assign o_transmission = state != IDLE;
endmodule
