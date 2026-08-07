module UART_top_tb;
  reg clock, reset, load;
  reg [7:0] tx_data;
  wire tx_out, tx_busy;
  wire [7:0] rx_data;
  wire rx_data_out, rx_error;

  parameter CLK_PERIOD = 10;
  parameter DIVISOR    = 4;

  UART_tx #(.DIVISOR(DIVISOR)) TX_INST (
    .clock(clock), .reset(reset), .load(load), .data(tx_data),
    .out(tx_out), .busy(tx_busy)
  );

  UART_rx #(.DIVISOR(DIVISOR)) RX_INST (
    .clock(clock), .reset(reset),
    .data_in(tx_out),
    .data(rx_data), .data_out(rx_data_out), .error(rx_error)
  );

  always #(CLK_PERIOD/2) clock = ~clock;

  task send_and_verify(input [7:0] byte_val);
    begin
      tx_data = byte_val;
      load = 1;
      #(CLK_PERIOD);
      load = 0;
      wait(rx_data_out || rx_error);
      if (rx_data_out && (rx_data === byte_val))
        $display("PASS @ %0t: sent %b, received %b correctly", $time, byte_val, rx_data);
      else
        $display("FAIL @ %0t: sent %b, got rx_data=%b rx_error=%b", $time, byte_val, rx_data, rx_error);
      @(posedge clock);
    end
  endtask

  initial begin
    $dumpfile("UART_top_tb.vcd");
    $dumpvars(0, UART_top_tb);
    clock=0; reset=0; load=0; tx_data=0;
    #10 reset=1; #10 reset=0; #20;

    send_and_verify(8'b10110010);
    send_and_verify(8'b11001100);
    send_and_verify(8'b01010101);
    send_and_verify(8'b11111111);
    send_and_verify(8'b00000000);

    #100 $finish;
  end
endmodule