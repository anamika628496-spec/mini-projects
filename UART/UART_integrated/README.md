# UART Integration Test

Wires the transmitter and receiver together directly - TX's serial output feeds straight into RX's input, no testbench-driven timing in between. This is the real proof that the two halves actually agree on framing and baud timing when connected, not just that each one works in isolation.

## Files
- `UART_top_tb.v` - top-level testbench instantiating both TX and RX
- `UART_tx.v`, `UART_rx.v`, `baud_rate.v` - the individual modules, unchanged

## How it works
`tx_out` is wired directly to `rx_data_in`. The testbench only talks to TX (load a byte) and only checks RX (did the same byte come out the other end). Both instances share the same `DIVISOR` parameter, so they run at the same baud rate. If there is ever a mismatch, the two halves would desync even though each is individually correct.

## What's tested
A handful of different byte values sent through the real link end to end, using `wait(rx_data_out || rx_error)` so the check happens exactly when RX finishes, not on a guessed delay.

## Result
All sent bytes correctly received on the other side - confirms TX and RX are timing-compatible and the individually-verified modules work correctly together, not just apart.

## Tools
Icarus Verilog + GTKWave
