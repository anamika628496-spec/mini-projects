/*module tff( input t, q, clock, output q_plus);
  always @(posedge clock)
   begin
    if(t) begin
     q_plus<= q;
    end
    else begin
     q_plus<= ~q;
    end
   end 
endmodule*/

module tff( input t, clock, output reg q=0);
  always @(posedge clock)
   begin
    if(t) begin
     q<= ~q;
    end
   end 
endmodule
    
    
