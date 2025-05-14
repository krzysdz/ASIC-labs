module uart_top #
(
  parameter BAUD_RATE    = 115_200,             // Baud rate
  parameter CLOCK_RATE   = 50_000_000
) (
    input i_clk,
    input i_rst,
    input [7:0] i_data_in,
    input i_send_data,
    output [7:0] o_rx_data,
    output o_rx_data_rdy,
    output o_frm_err,
    output o_transmission
);
    wire tx_rx;

    uart_tx #(
        .BAUD_RATE  (BAUD_RATE),
        .CLOCK_RATE (CLOCK_RATE)
    ) uart_tx_i (
        .i_clk          (i_clk),
        .i_rst          (i_rst),
        .i_data_in      (i_data_in),
        .i_send_data    (i_send_data),
        .o_transmission (o_transmission),
        .o_tx_out       (tx_rx)
    );

    uart_rx #(
        .BAUD_RATE  (BAUD_RATE),
        .CLOCK_RATE (CLOCK_RATE)
    ) uart_rx_i (
        .i_clk         (i_clk),
        .i_rst         (i_rst),
        .i_rx_in       (tx_rx),
        .o_rx_in_i_clk (),
        .o_rx_data     (o_rx_data),
        .o_rx_data_rdy (o_rx_data_rdy),
        .o_frm_err     (o_frm_err)
    );
endmodule
