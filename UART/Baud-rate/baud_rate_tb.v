module baud_rate_tb;
 wire pulse;
 reg clock, reset;
 initial begin
  $dumpfile("baud_rate.vcd");
  $dumpvars(0, baud_rate_tb);
  $monitor("time=%0t, clock=%b, reset=%b, pulse=%b", $time, clock, reset, pulse);
  clock=1'b0;
  reset=1'b1;
  #10 reset=0;
  #3270 reset=1;
  #30 reset=0;
  #10 reset=1;
  #10 reset=0;
  #3250 reset=1;
  #5 reset=0;
  #15 reset=1;
  #5 reset=0;
  #9830 $finish;
 end
 always begin
  #5 clock= ~clock;
 end
 baud_rate U0(.clock(clock), .reset(reset), .pulse(pulse));
endmodule