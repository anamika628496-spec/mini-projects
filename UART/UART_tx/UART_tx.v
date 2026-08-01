module UART_tx #(parameter DIVISOR=325)( input clock,input load, input [7:0] data, input reset, output reg out, output reg busy);
 wire pulse;
 reg [9:0] byte;
 reg[3:0] count=0;
 reg[3:0] flag=0;
 baud_rate #(.DIVISOR(DIVISOR))instance1(.clock(clock), .reset(reset), .pulse(pulse));
 always @ (posedge clock or posedge reset) begin
  if (reset== 1'b1) begin
   busy<=1'b0;
   out<=1'b1;
   count<=0;
   byte<={10{1'b0}};
   flag<=0;
  end
  else if (load==1'b1 && busy==1'b0) begin
   busy<=1'b1;
   out<=1'b1;
   count<=0;
   byte<={1'b1,data,1'b0}; // here u need to make sure 1 and 0 to be length defined
   flag<=0;
  end
  else if( pulse==1'b1 && busy==1'b1) begin
   if (count==15) begin
    out<= byte[flag];
    if (flag==9) begin
     busy<=1'b0;
     flag<=1'b0;
     count<=0;
     byte<={10{1'b0}};
    end else begin
     flag<=flag+1'b1;
     count<=1'b0;
    end
   end else begin
    count<=count+1'b1;
   end
  end
 end
endmodule


