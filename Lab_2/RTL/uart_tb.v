`timescale 1ns / 1ps

module uart_tb
(
);

 parameter SYMULATION_RES      = 1_000_000_000; //Symultion resolution

 parameter CLK_F_HZ            = 50_000_000;    //Clock freq in HZ
 parameter CLK_T               = SYMULATION_RES / CLK_F_HZ;

 parameter BAUD_RATE           = 115_200;       //UART Baud Rate
 parameter BAUD_RATE_T         = SYMULATION_RES / BAUD_RATE;

 parameter BYTE_TO_SEND_NUM    = 9;             //Number of Bytes to send

   reg clk;
   reg rst;

   reg [(BYTE_TO_SEND_NUM * 8)-1 : 0] bytes_to_send;

   wire [7:0] byte_to_send;
   reg        send_data;

   wire [7:0] data_out;
   wire       data_rdy;
   wire       transmission;

   integer byte_num;
   integer i;

   uart_top #(
      .BAUD_RATE  (BAUD_RATE),
      .CLOCK_RATE (CLK_F_HZ)
   ) uart_top_i (
      .i_clk          (clk),
      .i_rst          (rst),
      .i_data_in      (byte_to_send),
      .i_send_data    (send_data),
      .o_rx_data      (data_out),
      .o_rx_data_rdy  (data_rdy),
      .o_frm_err      (),
      .o_transmission (transmission)
   );

   assign byte_to_send = bytes_to_send[byte_num*8 +: 8];

   initial  //Data to send preparation
      begin
         bytes_to_send = { 8'h57,
                           8'h65,
                           8'h6C,
                           8'h6C,
                           8'h20,
                           8'h44,
                           8'h6F,
                           8'h6E,
                           8'h65 };
      end

   initial //Main Inital
      begin
         clk = 1'b1;
         rst = 1'b0;
         byte_num = 0;
         send_data = 0;

         #4000
         rst = 1'b1;

         for (i = 0; i < BYTE_TO_SEND_NUM; i = i + 1) begin
            while (transmission) @(posedge clk);
            send_data = 1;
            @(posedge transmission);
            send_data = 0;
            byte_num = i + 1;
         end
         while (transmission) @(posedge clk);
         $finish;
      end

   always #(CLK_T/2) clk = ~clk; //clock

   always @ (posedge data_rdy) //data monitor
      begin
         $display("Data received on UART interface:");
         $display("Data received (hex, ASCII) = %h at time: %t", data_out, $time);
      end
endmodule
