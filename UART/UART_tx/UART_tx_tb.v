`default_nettype none /*produce a much clearer error like load's undeclared instead of silently creating a wire.*/
module UART_tx_tb;
 wire out;
 wire busy;
 reg clock;
 reg load;
 reg reset;
 reg [7:0] data;
 initial begin
  $dumpfile("UART_tx.vcd");
  $dumpvars(0, UART_tx_tb);
  $monitor("time=%0t, clock=%b, reset=%b, load=%b, busy=%b, out=%b, data=%b",$time, clock, reset, load, busy, out, data);
  clock=1'b0;
  reset=1'b0;
  load=1'b0;
  data={8{1'b0}};
  #10 reset=1;
  #10 reset=0;
  #10 load=1; data=8'b10101010;
  #10 load=0;
  #10 load=1; data=8'b11100011;
  #10 load=0;
  #545000 load=1; data=8'b11001100;
  #10 load=0;
  #545000 load=1; data=8'b11001111;
  #10 load=0;
  #520000 reset=1;
  #10 reset=0;
  #20 load=1; data=8'b11110000;
  #10 load=0;
  #62000 reset=1;
  #40 reset=0;
  #10 reset=1;
  #10 reset=0;
  #20 load=1; reset=1; data=8'b10000001;
  #52000 $finish;
 end
 always begin
  #5 clock=~clock;
 end
 UART_tx U0(.clock(clock), .load(load), .data(data), .reset(reset), .out(out), .busy(busy));
endmodule
