module baud_rate #(parameter DIVISOR= 325)( input clock, input reset, output reg pulse);
 reg [8:0] counter;
 always @ (posedge clock or posedge reset) begin
  if (reset==1'b1) begin
    pulse<=1'b0;
    counter<=0;
  end
  else if(counter==DIVISOR-1) begin
   pulse<=1'b1;
   counter<=0;
  end
  else begin
   pulse<=1'b0;
   counter<=counter+ 1'b1;
  end
 end
endmodule