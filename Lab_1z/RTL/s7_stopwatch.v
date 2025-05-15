module s7_stopwatch #(
    parameter DISP_NUM = 6,
    parameter CC_PER_D = 10,
    parameter CYCLES_PER_MS = 1
)(
    input clk,
    input rst,
    output [6:0]              o_segments,
    output [DISP_NUM-1:0] o_segments_sel
);
    wire [23:0] bcd_time;

    stopwatch #(
        .CYCLES_PER_MS(CYCLES_PER_MS)
    ) stopwatch_i(
        .i_clk(clk),
        .i_rst(rst),
        .o_bcd_time(bcd_time)
    );
    s7_display #(
        .DISP_NUM(DISP_NUM),
        .CC_PER_D(CC_PER_D)
    ) display_i(
        .clk(clk),
        .rst(rst),
        .i_bcd_data(bcd_time),
        .o_segments(o_segments),
        .o_segments_sel(o_segments_sel)
    );
endmodule
