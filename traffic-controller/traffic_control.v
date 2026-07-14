module traffic_controller(clock, reset, state, red, yellow, green);
 input reset, clock;
 output reg [3:0] state;
 output red, yellow, green;
 reg [3:0] count;
 localparam RED=0, YELLOW=1, GREEN=2;
 assign red= (state==RED);
 assign green=(state==GREEN);
 assign yellow= (state==YELLOW);
 
 always @(posedge clock or posedge reset) begin
  if (reset) begin
   count<=0;
   state<= RED;
     end
  else if (count==4) begin
   state<= YELLOW;
   count<=count+1'b1;
     end
  else if (count==7) begin 
   state<=GREEN;
   count<=count+1'b1;
  end
  else if (count==9) begin
   state<=RED;
   count<=0;
  end
  else begin
  count<=count+1'b1;
  end
 end
endmodule
   
 
  