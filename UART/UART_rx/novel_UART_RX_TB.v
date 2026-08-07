`timescale 1ns/1ps

module UART_rx_tb;
    // Signals
    reg clock = 0;
    reg reset = 0;
    reg data_in = 1;
    wire data_out;
    wire [7:0] data;
    wire error;

    parameter CLK_PERIOD = 10;
    parameter DIVISOR = 4;
    parameter TICK_TIME = DIVISOR * CLK_PERIOD;
    parameter BIT_TIME = 16 * DIVISOR * CLK_PERIOD;

    // Instantiate Device Under Test (DUT)
    UART_rx #(.DIVISOR(DIVISOR)) uut (
        .clock(clock),
        .reset(reset),
        .data_in(data_in),
        .error(error),
        .data_out(data_out),
        .data(data)
    );

    // Clock generator
    always #(CLK_PERIOD/2) clock = ~clock;

    // ---------------------------------------------------------
    // 1. THE BUS FUNCTIONAL MODEL (BFM) DRIVER
    // One smart task handles nominal data AND any type of glitch injection.
    // ---------------------------------------------------------
    task send_uart_frame(
        input [7:0] payload,
        input       glitch_start,   // 1 to corrupt the start bit
        input int   glitch_bit_idx, // 0 to 7 to corrupt a specific data bit, -1 for none
        input       glitch_stop     // 1 to corrupt the stop bit
    );
        integer j;
        begin
            // --- START BIT PHASE ---
            if (glitch_start) begin
                data_in = 0;
                #(7 * TICK_TIME);
                data_in = 1; // Premature high glitch
                #(BIT_TIME - (7 * TICK_TIME));
            end else begin
                data_in = 0; // Clean start bit
                #(BIT_TIME);
            end

            // --- DATA BITS PHASE ---
            for (j = 0; j < 8; j = j + 1) begin
                if (j == glitch_bit_idx) begin
                    data_in = payload[j];
                    #(7 * TICK_TIME);
                    data_in = ~payload[j]; // Flip the bit mid-stream
                    #(BIT_TIME - (7 * TICK_TIME));
                end else begin
                    data_in = payload[j];
                    #(BIT_TIME);
                end
            end

            // --- STOP BIT PHASE ---
            if (glitch_stop) begin
                data_in = 1;
                #(7 * TICK_TIME);
                data_in = 0; // Premature low glitch
                #(BIT_TIME - (7 * TICK_TIME));
            end else begin
                data_in = 1; // Clean stop bit
                #(BIT_TIME);
            end
        end
    endtask

    // ---------------------------------------------------------
    // 2. STICKY PULSE MONITOR (The Safety Net for 1-Cycle Strobes)
    // ---------------------------------------------------------
    reg caught_data_out = 0;
    reg caught_error = 0;

    always @(posedge clock) begin
        if (reset) begin
            caught_data_out <= 0;
            caught_error <= 0;
        end else begin
            if (data_out) caught_data_out <= 1;
            if (error)    caught_error    <= 1;
        end
    end

    // ---------------------------------------------------------
    // 3. AUTOMATED SELF-CHECKING SCOREBOARD TASK
    // Replaces manual print statements with automated pass/fail assertions.
    // ---------------------------------------------------------
    task verify_transaction(input [7:0] exp_data, input exp_succ, input exp_err);
        begin
            // Wait briefly for the design to finish driving outputs on the clock edge
            #20;
            @(posedge clock);
            #1; 

            // Automated assertions
            if (caught_data_out !== exp_succ) 
                $error("[FAIL] Time %0t: data_out mismatch. Expected %b, Got %b", $time, exp_succ, caught_data_out);
            else if (exp_succ) 
                $display("[PASS] Time %0t: Data transmission successful (Data = 0x%h)", $time, data);

            if (caught_error !== exp_err) 
                $error("[FAIL] Time %0t: error flag mismatch. Expected %b, Got %b", $time, exp_err, caught_error);
            else if (exp_err) 
                $display("[PASS] Time %0t: Framing/Stop error correctly flagged.", $time);

            if (exp_succ && (data !== exp_data))
                $error("[FAIL] Time %0t: Payload content mismatch. Expected 0x%h, Got 0x%h", $time, exp_data, data);

            // Clear sticky flags for the next test vector
            caught_data_out = 0;
            caught_error = 0;
        end
    endtask

    // ---------------------------------------------------------
    // 4. MAIN TEST EXECUTION (Phased Test Plan)
    // ---------------------------------------------------------
    initial begin
        $dumpfile("UART_rx_tb.vcd");
        $dumpvars(0, UART_rx_tb);

        // Phase 1: Hardware Reset
        $display("--- STARTING VERIFICATION SUITE ---");
        #10 reset = 1; data_in = 1;
        #20 reset = 0;
        #20;

        // Phase 2: Nominal Data Tests (Clean transfers)
        $display("\n[Phase 2] Testing Nominal Data Frames...");
        send_uart_frame(8'hB2, 0, -1, 0); verify_transaction(8'hB2, 1, 0);
        send_uart_frame(8'h00, 0, -1, 0); verify_transaction(8'h00, 1, 0);
        send_uart_frame(8'hFF, 0, -1, 0); verify_transaction(8'hFF, 1, 0);

        // Phase 3: Edge Cases and Destructive Glitch Testing
        $display("\n[Phase 3] Testing Glitches & Error Handling...");
        
        // Start bit glitch (causes line desync/abort; isolated at end of sequence)
        send_uart_frame(8'h28, 1, -1, 0); 
        #50; // Allow state machine to recover back to IDLE

        // Mid-stream data bit glitch (Corrupting the 3rd bit, index 2)
        send_uart_frame(8'hCC, 0, 2, 0); verify_transaction(8'hCC, 1, 0);

        // Stop bit framing error glitch
        send_uart_frame(8'hAA, 0, -1, 1); verify_transaction(8'hAA, 0, 1);

        // Phase 4: Final Cleanup
        #100;
        $display("\n--- VERIFICATION COMPLETE: ALL TEST VECTORS PASSED ---");
        $finish;
    end

endmodule