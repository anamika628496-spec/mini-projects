module UART_rx #(parameter DIVISOR=325) (
  input clock, reset, data_in,
  output reg [7:0] data,
  output reg data_out, error
);
  localparam IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state;
  reg [3:0] sample_count;
  reg [2:0] bit_count;
  reg s0, s1;
  wire pulse;

  reg  start_detect;
  wire rx_baud_reset = reset | start_detect;
  baud_rate #(.DIVISOR(DIVISOR)) inst(.clock(clock), .reset(rx_baud_reset), .pulse(pulse));

  always @(posedge clock) begin
    if (reset) begin
      state <= IDLE; sample_count <= 0; bit_count <= 0;
      data <= 0; data_out <= 0; error <= 0; start_detect <= 0;
    end else begin
      data_out <= 0;         // default every cycle - overridden below if needed
      error    <= 0;
      start_detect <= 0;

      case (state)
        IDLE: begin
          if (!data_in) begin
            start_detect <= 1;   // resync the baud counter right now
            state <= START;
          end
        end

        START: if (pulse) begin
          sample_count <= sample_count + 1;
          case (sample_count)
            7: s0 <= data_in;
            8: s1 <= data_in;
            9: begin
              sample_count <= 0;
              if (s0 + s1 + data_in < 2) state <= DATA;   // confirmed real start bit
              else                        state <= IDLE;   // false alarm
            end
          endcase
        end

        DATA: if (pulse) begin
          sample_count <= sample_count + 1;
          case (sample_count)
            7: s0 <= data_in;
            8: s1 <= data_in;
            9: begin
              data[bit_count] <= (s0 + s1 + data_in >= 2);
              sample_count <= 0;
              if (bit_count == 7) state <= STOP;
              else bit_count <= bit_count + 1;
            end
          endcase
        end

        STOP: if (pulse) begin
          sample_count <= sample_count + 1;
          case (sample_count)
            7: s0 <= data_in;
            8: s1 <= data_in;
            9: begin
              if (s0 + s1 + data_in >= 2) data_out <= 1;
              else                        error <= 1;
              state <= IDLE;
              sample_count <= 0;
            end
          endcase
        end
      endcase
    end
  end
endmodule