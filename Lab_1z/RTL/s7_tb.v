`timescale 100 us / 100us

module s7_tb
(
);
 parameter DISP_NUM       = 6;  //number of the 7s displays
 parameter CC_PER_D       = 10; //single display activity time in clocks cycles

 parameter CLK_F_HZ       = 1000; //clock freq in HZ
 parameter CLK_T          = 10000 / CLK_F_HZ;
 parameter CYCLES_PER_MS  = CLK_F_HZ / 1000;

 reg                            clk;
 reg                            rst;

//  reg  [(DISP_NUM*4) - 1:0]  bcd_in;

 wire [6:0]                     segments;
 wire [DISP_NUM-1:0]        segments_sel;

 wire [7:0]                     ascii;

//  integer                        i;

// s7_display #
// (
//   .DISP_NUM (DISP_NUM),
//   .CC_PER_D (CC_PER_D)
// )
// s7_display_i
// (
//     .clk          (clk),
//     .rst          (rst),
//     .i_bcd_data     (bcd_in),

//     .o_segments     (segments),
//     .o_segments_sel (segments_sel)
// );

s7_stopwatch #(
    .DISP_NUM(DISP_NUM),
    .CC_PER_D(CC_PER_D),
    .CYCLES_PER_MS(CYCLES_PER_MS)
) s7_stopwatch_i(
    .clk          (clk),
    .rst          (rst),
    .o_segments     (segments),
    .o_segments_sel (segments_sel)
);

assign ascii = segments_to_ascii(segments);

 initial
    begin
           $dumpfile("rtl.vcd");
           $dumpvars;
`ifndef __ICARUS__
           $fsdbDumpfile("rtl.fsdb");
`endif
           clk = 1'b1;
           rst = 1'b0;
        //    bcd_in  = {(DISP_NUM*4){1'b0}};

           #(CC_PER_D*CLK_T*DISP_NUM+CLK_T)
           rst = 1'b1;
           repeat (60*1000*CYCLES_PER_MS) @(posedge clk);
           #10000 $finish;
    end

    always #(CLK_T/2) clk = ~clk; //clock

    // always #(CC_PER_D*CLK_T*DISP_NUM) //stymulus bcd input code
    //     begin
    //         bcd_in[3:0] = bcd_in[3:0] + 1;

    //         for (i = 0 ; i < DISP_NUM ; i=i+1)
    //             begin
    //                 if (bcd_in[(i*4)+:4] > 9)
    //                     begin
    //                         bcd_in[((i+1)*4)+:4] = bcd_in[((i+1)*4)+:4] + 1;
    //                         bcd_in[(i*4)+:4] = 0;
    //                     end
    //             end
    //     end

    function [7:0] segments_to_ascii; //decode 7 segment code to ASCI for easy debug
        input [6:0] segments;
        begin
            case (segments)
                7'b0000001: segments_to_ascii = 8'h30;
                7'b1001111: segments_to_ascii = 8'h31;
                7'b0010010: segments_to_ascii = 8'h32;
                7'b0000110: segments_to_ascii = 8'h33;
                7'b1001100: segments_to_ascii = 8'h34;
                7'b0100100: segments_to_ascii = 8'h35;
                7'b0100000: segments_to_ascii = 8'h36;
                7'b0001111: segments_to_ascii = 8'h37;
                7'b0000000: segments_to_ascii = 8'h38;
                7'b0000100: segments_to_ascii = 8'h39;
                default   : segments_to_ascii = 8'h3f;
            endcase
        end
    endfunction

endmodule
