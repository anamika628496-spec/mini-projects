module traffic_controller_tb;
 reg clock, reset;
 wire [3:0]state;
 wire red, yellow, green;
 initial begin
  $dumpfile("traffic_light.vcd");
  $dumpvars(0, traffic_controller_tb);


  $monitor (" time= %0t,clock=%b, reset=%b, state=%b, red=%b,green=%b, yellow=%b",  $time,clock,reset,state, red, green, yellow);
  reset=1; 
  clock=0;
  #10 reset=0;
  #110 reset=1;
  #10 reset=0;
  #50 reset=1;
  #10 reset=0;
  #80 reset=1;
  #40 reset=0;
  #15 reset=1;
  #10 reset=0;
  #85 reset=1;
  #10 reset=0;
  #20 $finish;
 end
 always begin
  #5 clock=~clock;
 end
 traffic_controller U0 ( .clock(clock), .reset(reset), .state(state), .red(red), .yellow(yellow), .green(green) );
endmodule 
  