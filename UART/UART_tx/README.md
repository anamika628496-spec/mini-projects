# UART Transmitter (TX)

A UART transmitter built in Verilog, sending data one bit at a time using standard 8-N-1 framing (1 start bit, 8 data bits, no parity, 1 stop bit). Built on top of a baud rate generator I made earlier, which handles 16x oversampling timing.

## How it works

The whole thing runs off a single clocked always block, with a clear priority order: reset comes first (it should always win, no matter what else is happening), then load (but only if the module isn't already busy sending something), and then the actual bit-by-bit shifting, which only happens on the baud generator's pulse.

I specifically avoided using the baud pulse as a separate clock — instead it's just a condition (`if(pulse)`) inside the main clock's always block. Using a derived signal as a clock can create a second, unintended clock domain, which brings its own timing headaches, so this keeps everything in one clean clock domain.

## Files

- `UART_tx.v` — the actual transmitter
- `baud_rate.v` — the baud rate generator, reused here
- `UART_tx_tb.v` — testbench, running at the real timing (DIVISOR=325)
- `UART_tx_tb_fast.v` — same tests, but with DIVISOR overridden to a small number so simulations run in a few seconds instead of forever

## Interface

| Signal | Direction | Width | What it does |
|---|---|---|---|
| clock | input | 1 | system clock |
| reset | input | 1 | active-high reset |
| load | input | 1 | pulse high to start sending `data`; ignored if already busy |
| data | input | [7:0] | the byte to send |
| out | output | 1 | the actual serial line (idle-high) |
| busy | output | 1 | high while a byte is being sent |

## About the DIVISOR parameter

Both `baud_rate.v` and `UART_tx.v` default to DIVISOR=325 (the real, correct timing). I didn't want to keep manually editing that number back and forth every time I wanted a faster simulation, so I made it a parameter instead — the default stays correct, and I only override it where I actually instantiate the module in the fast testbench:

```verilog
// real testbench - no override, uses the default 325
UART_tx U0 (.clock(clock), .load(load), .data(data), .reset(reset), .out(out), .busy(busy));

// fast testbench - override applied only here
UART_tx #(.DIVISOR(4)) U0 (.clock(clock), .load(load), .data(data), .reset(reset), .out(out), .busy(busy));
```

## What I tested

- Normal load + full transmit cycle
- Trying to load new data while it's already busy sending (should be ignored)
- Reset with nothing loaded
- Reset in the middle of sending
- Reset and load hitting at the exact same time (reset should win)
- A few resets back to back

Checked all of this with `$monitor` output and in GTKWave. Waveform screenshots are in `/waveforms`.

**Real-timing testbench (DIVISOR=325):**

![description here](waveforms/PLACEHOLDER_real_1.png)
![description here](waveforms/PLACEHOLDER_real_2.png)
![description here](waveforms/PLACEHOLDER_real_3.png)
![description here](waveforms/PLACEHOLDER_real_4.png)
![description here](waveforms/PLACEHOLDER_real_5.png)

**Fast testbench (DIVISOR overridden):**

![description here](waveforms/PLACEHOLDER_fast_1.png)
![description here](waveforms/PLACEHOLDER_fast_2.png)
![description here](waveforms/PLACEHOLDER_fast_3.png)

## Bugs I ran into along the way

- Had `count` being driven by two separate always blocks at once — not allowed, had to consolidate into one
- Forgot to guard the load condition with `busy==0` at first, which meant a new load could interrupt a transmission mid-frame
- My "transmission complete" check was originally sitting as an unreachable branch that never actually got hit — had to move it inside the part that handles the last bit
- The stop bit wasn't actually getting sent because of how I'd nested that same completion check — fixed by making the bit output happen unconditionally, and only checking for "is this the last bit" afterward, separately

## Tools
Icarus Verilog + GTKWave
