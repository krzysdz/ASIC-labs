module s7_stopwatch #(
    parameter DISPLAYS_NUM = 6,
    parameter MULTIPLEX_CLK_COUNT = 10,
    parameter CYCLES_PER_MS = 1
)(
    input i_clk,
    input i_rst,
    output [6:0]              o_segments,
    output [DISPLAYS_NUM-1:0] o_segments_sel
);
    wire [23:0] bcd_time;

    stopwatch #(
        .CYCLES_PER_MS(CYCLES_PER_MS)
    ) stopwatch_i(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .o_bcd_time(bcd_time)
    );
    s7_display #(
        .DISPLAYS_NUM(DISPLAYS_NUM),
        .MULTIPLEX_CLK_COUNT(MULTIPLEX_CLK_COUNT)
    ) display_i(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_bcd_data(bcd_time),
        .o_segments(o_segments),
        .o_segments_sel(o_segments_sel)
    );
endmodule
