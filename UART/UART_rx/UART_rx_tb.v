module UART_rx_tb;
 reg clock, reset, data_in;
 reg got_data_out, got_error;
 wire data_out, error;
 wire [7:0]data;
 parameter CLK_PERIOD =10;
 parameter DIVISOR= 4;
 parameter TICK_TIME= DIVISOR*CLK_PERIOD;
 parameter BIT_TIME=16* DIVISOR* CLK_PERIOD;
 UART_rx #( .DIVISOR(DIVISOR)) U0 (.clock(clock), .reset(reset), .data_in(data_in), .error(error), .data_out(data_out), .data(data));
 always #(CLK_PERIOD/2) clock=~clock;
 always@ (posedge clock) begin
  if (reset) begin
    got_data_out<=0;
    got_error<=0;
  end else begin
    if(data_out) got_data_out<=1;
    if(error) got_error<=1;
  end
 end
 task correct_send_byte( input [7:0] byte_send);
  integer j;
  begin
    data_in=0;
    got_data_out=0;
    got_error=0;
    #(BIT_TIME);
    for(j=0;j<8;j=j+1) begin
        data_in=byte_send[j];
        #(BIT_TIME);
    end
    data_in=1;
    #(BIT_TIME);
  end
 endtask
 task check_data(input [7:0]expected);
  integer j;
  begin 
    if (data==expected) 
        $display("Perfect data points, got %b", data);
    else
      $display("Nope, you got duped....incorrect data. You needed %b but you got %b", expected, data);
  end
 endtask
 task check_data_sent_success(input expected);
  begin 
    @(posedge clock);
    #1;
    if(got_data_out==expected) begin
        $display(" 'God's plannn'....data_out according to plan@ %0t...yayyy girlieee", $time);
    end
    else begin
        $display(" Love you honey but this data_out is not working out @ %0t....oh no gurliee", $time);
    end
  end
  endtask
  task check_error_sent_success(input expected);
  begin
    @(posedge clock);
    #1; 
    if(got_error==expected) begin
        $display("It is working..error as you expected...don't touch it @ %0t...", $time);
    end
    else begin
        $display(" Turn on the music coz this mess needs sorting ...erroneous error..@ %0t....<3", $time);
    end
  end
  endtask
 task  send_data_third_bit_glitched_byte(input [7:0]byte_send);
  integer j;
  begin
    data_in=0;
    got_data_out=0;
    got_error=0;
    #(BIT_TIME);
    for(j=0;j<2;j=j+1) begin
        data_in=byte_send[j];
        #(BIT_TIME);
    end
    data_in= byte_send[2];
    #(7*TICK_TIME+(TICK_TIME/2));
    data_in= ~byte_send[2];
    #(BIT_TIME-((7)*TICK_TIME)-(TICK_TIME/2));
    for(j=3;j<8;j=j+1) begin
        data_in=byte_send[j];
        #(BIT_TIME);
    end
    data_in=1;
    #(BIT_TIME);

  end 
 endtask
 task  send_start_bit_glitched_byte( input [7:0] byte_send);
  integer j;
  begin
    data_in= 0;
    got_data_out=0;
    got_error=0;
    #(7*TICK_TIME+(TICK_TIME/2));
    data_in= 1;
    #(BIT_TIME-((7)*TICK_TIME)-(TICK_TIME/2));
    for(j=0;j<8;j=j+1) begin
        data_in=byte_send[j];
        #(BIT_TIME);
    end
    data_in=1;
    #(BIT_TIME);
  end 
 endtask
 task  send_stop_bit_glitched(input [7:0]byte_send);
  integer j;
  begin
    data_in=0;
    got_data_out=0;
    got_error=0;
    #(BIT_TIME);
    for(j=0;j<8;j=j+1) begin
        data_in=byte_send[j];
        #(BIT_TIME);
    end
    data_in= 1;
    #(7*TICK_TIME + (TICK_TIME/2));
    data_in= 0;
    #(BIT_TIME-((7)*TICK_TIME)-(TICK_TIME/2));
    data_in=1;
  end 
 endtask
 initial begin
  $dumpfile("UART_rx_tb.vcd");
  $dumpvars(0, UART_rx_tb);
  clock = 0; reset = 0; data_in=1;
  #10 reset=1;
  #10 reset=0;
  #20 ;

  correct_send_byte(8'b10110010);
  check_error_sent_success(0);
  check_data_sent_success(1);
  check_data(8'b10110010);
  #30;
  correct_send_byte(8'b00000000);
  check_error_sent_success(0);
  check_data_sent_success(1);
  check_data(8'b00000000);
  
  correct_send_byte(8'b11111111);
  check_error_sent_success(0);
  check_data_sent_success(1); 
  check_data(8'b11111111);
  #40;
  
  send_data_third_bit_glitched_byte(8'b11001100);
  check_error_sent_success(0);
  check_data_sent_success(1);
  check_data(8'b11001100);

  send_stop_bit_glitched(8'b10101010);
  check_error_sent_success(1);
  check_data_sent_success(0); 
  check_data(8'b10101010);
  
  correct_send_byte(8'b10111010);
  check_error_sent_success(0);
  check_data_sent_success(1); 
  check_data(8'b10111010);

    fork
      begin
        correct_send_byte(8'b11110010);
      end
      begin
        #((5 * BIT_TIME) + (2 * TICK_TIME)); 
        reset=1;
        #20 reset = 0;
      end
    join
    #50;
    check_error_sent_success(0); 
    check_data_sent_success(0);
    
  correct_send_byte(8'b11110010);
  send_start_bit_glitched_byte(8'b00101000);
  check_error_sent_success(0);
  check_data_sent_success(0); 
  check_data(8'b00101000);
  # 30 $finish;
 end
endmodule


    





