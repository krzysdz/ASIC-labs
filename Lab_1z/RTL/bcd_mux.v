module bcd_mux #
(
    parameter DISP_NUM        = 4,
    parameter CC_PER_D = 10
)
(
    input                           clk,
    input                           rst,
    input  [(DISP_NUM*4) - 1:0] i_bcd_data,

    output [3:0]                    o_bcd_muxed,
    output [DISP_NUM-1:0]       o_bcd_sel
);

   reg  [clogb2(CC_PER_D)-1:0] sel_counter_r;
   wire [clogb2(CC_PER_D)-1:0] sel_counter;
   wire                                   allow_display_count;

   always @ (posedge clk, negedge rst)
        if (!rst) sel_counter_r <= 0;
         else
            begin
                if (sel_counter_r == (CC_PER_D-1)) sel_counter_r <= 0;
                else sel_counter_r <= sel_counter_r + 1;
            end

   assign allow_display_count = (sel_counter_r == (CC_PER_D-1)) ? 1 : 0;

   reg  [clogb2(DISP_NUM)-1:0] display_count_r;
   wire [0:3]                      bcd_out;

   wire [clogb2(DISP_NUM)-1:0] c_display_count;
   assign c_display_count = (display_count_r == DISP_NUM-1) ? 0 : (display_count_r + 1);

   always @ (posedge clk, negedge rst)
        if (!rst) display_count_r <= 0;
        else if (allow_display_count) display_count_r <= c_display_count;


   assign bcd_out = i_bcd_data[4*(DISP_NUM - display_count_r - 1)+:4];

   assign o_bcd_muxed = bcd_out;

   assign o_bcd_sel = {{(DISP_NUM-1){1'b0}},1'b1} << display_count_r;

   `include "RTL/clogb2.v"
endmodule
