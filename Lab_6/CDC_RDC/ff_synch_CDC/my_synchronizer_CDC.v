module my_synchronizer_CDC #
(
  parameter CLK_a_F_HZ = 1'bx,
  parameter CLK_b_F_HZ = 1'bx
)
(
  input                       i_clk_a,
  input                       i_rst_a,

  input                       i_clk_b,
  input                       i_rst_b,

  input                       i_data_clk_a,

  output                      o_data_clk_b,
  output reg                  o_next_data_clk_a

);
  localparam Times = (CLK_a_F_HZ + CLK_b_F_HZ - 1) / CLK_b_F_HZ;
  localparam TimesBits = $clog2(Times);

 reg   r_data_clk_a;
 reg   r_data_clk_b_sync;
 reg   r_data_clk_b;

  //capture data in clock domain A
 always @(posedge i_clk_a or negedge i_rst_a)
  begin
    if (!i_rst_a)
        r_data_clk_a <= 1'b0;
    else if (o_next_data_clk_a)
        r_data_clk_a <= i_data_clk_a;
  end

  //capture data in clock domain B
  always @(posedge i_clk_b or negedge i_rst_b)
  begin
    if (!i_rst_b) begin
       r_data_clk_b_sync <= 1'b0;
       r_data_clk_b <= 1'b0;
    end else begin
       r_data_clk_b_sync <= r_data_clk_a;
       r_data_clk_b <= r_data_clk_b_sync;
    end
  end

  generate
    if (CLK_a_F_HZ <= CLK_b_F_HZ)
      always @* o_next_data_clk_a = 1;
    else begin
      reg [TimesBits-1:0] cnt;

      always @(posedge i_clk_a or negedge i_rst_a) begin
        if (!i_rst_a) begin
          cnt <= 0;
          o_next_data_clk_a <= 1'b1;
        end else begin
          cnt <= cnt == Times-1 ? 0 : cnt + 1'b1;
          o_next_data_clk_a <= cnt == Times-1;
        end
      end
    end
  endgenerate

 assign o_data_clk_b = r_data_clk_b;
endmodule