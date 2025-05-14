module s7_display #
(
    parameter DISP_NUM = 4,
    parameter CC_PER_D = 10
)
(
    input                           clk,
    input                           rst,
    input  [(DISP_NUM*4) - 1:0] i_bcd_data,

    output [6:0]                    o_segments,
    output [DISP_NUM-1:0]       o_segments_sel
);

 wire [3:0]              bcd_muxed;
 wire [DISP_NUM-1:0] bcd_sel;
 wire [6:0]              segments;

 bcd_mux #
 (
   .DISP_NUM        (DISP_NUM),
   .CC_PER_D (CC_PER_D)
 )
 bcd_mux_i
 (
   .clk         (clk),
   .rst         (rst),
   .i_bcd_data    (i_bcd_data),

   .o_bcd_muxed   (bcd_muxed),
   .o_bcd_sel     (bcd_sel)
 );

 decoder decoder_i
 (
   .i_bcd           (bcd_muxed),
   .o_segments      (segments)
 );

 assign o_segments = segments;
 assign o_segments_sel = bcd_sel;

 endmodule