module my_synchronizer_RDC2 #
(
)
(
  input                       i_rst, //global async reset

  input                       i_clk_a,

  input                       i_clk_b,

  input                       i_data_clk_a,

  output                      o_data_clk_b


);

  reg  r_data_clk_a;
  reg  r_data_clk_b_sync;
  reg  r_data_clk_b;

  reg [1:0] r_rst_a;
  wire rst_a;
  assign rst_a = r_rst_a[0];
  always @(posedge i_clk_a or negedge i_rst) begin
    if (!i_rst) r_rst_a <= 2'b0;
    else r_rst_a <= {1'b1, r_rst_a[1]};
  end

  //capture data in clock domain A
  always @(posedge i_clk_a or negedge rst_a)
  begin
    if (!rst_a)
        r_data_clk_a <= 1'b0;
    else
        r_data_clk_a <= i_data_clk_a;
  end

  reg [1:0] r_rst_b;
  wire rst_b;
  assign rst_b = r_rst_b[0];
  always @(posedge i_clk_b or negedge i_rst) begin
    if (!i_rst) r_rst_b <= 2'b0;
    else r_rst_b <= {1'b1, r_rst_b[1]};
  end

  //capture data in clock domain B
  always @(posedge i_clk_b or negedge rst_b)
  begin
    if (!rst_b) begin
        r_data_clk_b_sync <= 1'b0;
        r_data_clk_b <= 1'b0;
    end else begin
        r_data_clk_b_sync <= r_data_clk_a;
        r_data_clk_b <= r_data_clk_b_sync;
    end
  end

  assign o_data_clk_b = r_data_clk_b;
endmodule
