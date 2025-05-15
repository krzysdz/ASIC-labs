module stopwatch #(
    parameter CYCLES_PER_MS = 1
) (
    input i_clk,
    input i_rst,
    output [23:0] o_bcd_time
);
    reg [3:0] ms_1_r;
    reg [3:0] ms_10_r;
    reg [3:0] ms_100_r;
    reg [3:0] s_1_r;
    reg [3:0] s_10_r;
    reg [3:0] m_1_r;
    assign o_bcd_time = {m_1_r, s_10_r, s_1_r, ms_100_r, ms_10_r, ms_1_r};

    wire sub_ms_wrap;
    wire ms_1_wrap;
    wire ms_10_wrap;
    wire ms_100_wrap;
    wire s_1_wrap;
    wire s_10_wrap;
    wire m_1_wrap;

    generate
    if (CYCLES_PER_MS > 1) begin : g_sub_ms
        reg [$clog2(CYCLES_PER_MS)-1:0] sub_ms_r;
        assign sub_ms_wrap = sub_ms_r == CYCLES_PER_MS-1;

        always @(posedge i_clk, negedge i_rst)
            if (!i_rst) sub_ms_r <= 0;
            else sub_ms_r <= sub_ms_wrap ? 0 : (sub_ms_r + 1);
    end else
        assign sub_ms_wrap = 1;
    endgenerate
    assign ms_1_wrap = ms_1_r == 4'd9 && sub_ms_wrap;
    assign ms_10_wrap = ms_10_r == 4'd9 && ms_1_wrap;
    assign ms_100_wrap = ms_100_r == 4'd9 && ms_10_wrap;
    assign s_1_wrap = s_1_r == 4'd9 && ms_100_wrap;
    assign s_10_wrap = s_10_r == 4'd5 && s_1_wrap;
    assign m_1_wrap = m_1_r == 4'd9 && s_10_wrap;

    always @(posedge i_clk, negedge i_rst) begin
        if (!i_rst) begin
            ms_1_r <= 0;
            ms_10_r <= 0;
            ms_100_r <= 0;
            s_1_r <= 0;
            s_10_r <= 0;
            m_1_r <= 0;
        end else begin
            if (sub_ms_wrap) ms_1_r <= ms_1_wrap ? 0 : (ms_1_r + 1);
            if (ms_1_wrap) ms_10_r <= ms_10_wrap ? 0 : (ms_10_r + 1);
            if (ms_10_wrap) ms_100_r <= ms_100_wrap ? 0 : (ms_100_r + 1);
            if (ms_100_wrap) s_1_r <= s_1_wrap ? 0 : (s_1_r + 1);
            if (s_1_wrap) s_10_r <= s_10_wrap ? 0 : (s_10_r + 1);
            if (s_10_wrap) m_1_r <= m_1_wrap ? 0 : (m_1_r + 1);
        end
    end
endmodule

// module cnt_max #(
//     parameter int WIDTH = 3,
//     parameter int MAX = 9
// ) (
//     input logic i_clk,
//     input logic i_rst,
//     input logic en,
//     output logic [WIDTH-1:0] val,
//     output logic overflow
// );
//     always_ff @(posedge i_clk) begin
//         if (i_rst)
//             val <= 0;
//         else
//             if (en)
//                 val <= val == MAX ? 0 : val + 1;
//     end
//     assign overflow = val == MAX && en;
// endmodule

