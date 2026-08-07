module UART_rx #(parameter DIVISOR=325)( output reg data_out, output reg [7:0]data, output reg error,input clock, data_in, reset);
  wire pulse,final_reset;
  reg start_bit=0;
  reg idle_state=0;
  integer i;
  reg [4:0]count;
  reg sync;
  reg red_flag=0;
  reg[3:0] flag=4'b0000;
  reg [2:0]in1;
  reg threshold_update=0;
  reg [1:0]threshold;
  assign final_reset= start_bit | reset;
  baud_rate #(.DIVISOR(DIVISOR)) instance1(.clock(clock), .reset(final_reset), .pulse(pulse));
  always @(posedge clock) begin
    if(reset) begin
      count<=0;
      error<=0;
      idle_state<=1;
      start_bit<=0;
      red_flag<=0;
      sync<=0;
      data_out<=0;
      flag<=0;
      threshold_update<=0;
    end
    else begin
     data_out<=0;
     error<=0;
     if(idle_state==1 & data_in==0 & sync==0 & red_flag==0) begin
        start_bit<=1;
        idle_state<=0;
        sync<=1;
     end
     else if( idle_state==0 & sync==1 & red_flag==0) begin
        start_bit<=0;
        count<=count+ pulse;
        if(count<9) begin
         case (count)
          7: in1[0]<=data_in;
          8: in1[1]<=data_in;
          default: ;
         endcase
        end
        else if(threshold_update==0) begin // dont have to wait for next pulse to come to see threshold value as it would waste 325 pulses
         threshold<= data_in+ in1[1]+in1[0];
         threshold_update<=1;
        end
        else if(threshold_update==1) begin
         if (threshold>1) begin
          idle_state<=1;
          count<=0;
          sync<=0;
          threshold_update<=0;
          threshold<=0;
         end
         else begin
          count<=0;
          red_flag<=1;
          flag<= 4'b0000;
          threshold_update<=0;
          threshold<=0;
         end 
        end
     end
     else if(idle_state==0 & sync==1 & red_flag==1 & flag<8 ) begin
             count<= count+pulse;
             if (count<16) begin
               case(count)
                14:in1[0]<= data_in;
                15:in1[1]<= data_in;
                default: ;
               endcase
             end
             else if (threshold_update==0) begin
               threshold<= data_in+ in1[1]+in1[0];
               threshold_update<=1;
             end               
             else if(threshold_update==1) begin
                if(threshold>1) begin
                  data[flag]<= 1;
                  flag<=flag+1;
                  count<=0;
                  threshold_update<=0;
                  threshold<=0;
               end
               else begin
                  data[flag]<= 0;
                  flag<=flag+1;
                  count<=0;
                  threshold_update<=0;
                  threshold<=0;
               end
             end
     end
     else if ( idle_state==0 & sync==1 & red_flag==1 & flag==8 ) begin
             count<= count+pulse;
             if (count<16) begin
               case(count)
                14:in1[0]<= data_in;
                15:in1[1]<= data_in;
                default:;
               endcase
             end
             else if (threshold_update==0) begin
               threshold<= data_in+ in1[1]+in1[0];
               threshold_update<=1;
             end               
             else if(threshold_update==1) begin
                if(threshold>1) begin
                  data_out<= 1;
                  flag<=0;
                  idle_state<=1;
                  sync<=0;
                  red_flag<=0;
                  count<=0;
                  threshold_update<=0;
                  threshold<=0;
               end
               else begin
                  error<= 1;
                  idle_state<=1;
                  red_flag<=0;
                  flag<=0;
                  sync<=0;
                  count<=0;
                  threshold_update<=0;
                  threshold<=0;
               end
             end
     end
    end

  end
endmodule




              

            