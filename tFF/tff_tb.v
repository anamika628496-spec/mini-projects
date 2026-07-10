/*module tff_tb( input reg clock, t, q, output q_plus);
  initial begin
   $monitor ('t=%b, q=%b, q_plus=%b', t,q,q_bar);
   t=0,q=0,clock=0;
   #10 t=1;
   #5  t=0;
   #5  q=1;
   #5  $finidh;
  end
  always @ (posedge clock) begin
   #5 clock=~clock;
  end
  tff U0 ( .clock(clock), .t(t), .q(q), .q_plus(q_plus) );
endmodule */

module tff_tb;
  reg clock, t;
  wire q;
  
  initial begin
   $dumpfile("tff.vcd");
   $dumpvars(0, tff_tb);


   $monitor (" time= %0t,clock=%b, t=%b, q=%b", $time,clock,t,q);
   t=1; 
   clock=0;
   #20 t=0;
   #10  t=1;
   #10  t=0;
   #5  $finish;
  end
  always begin
   #5 clock=~clock;
  end
  tff U0 ( .clock(clock), .t(t), .q(q) );
endmodule 