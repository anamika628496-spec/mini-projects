# Baud Rate Generator

Generates a single-cycle oversampling pulse at 16x the target UART baud rate, from a system clock — the timing reference for UART transmitter/receiver modules.

## Design

- System clock: 50MHz (example/target value)
- Baud rate: 9600
- Oversampling: 16x → required pulse rate = 9600 × 16 = 153,600 Hz
- Rollover value: 50,000,000 / 153,600 = 325.52 → 325 (integer)
- Counter width: 9 bits (2^9=512 > 325)
- Note: counting 0 to N-1 (i.e. threshold = 324, not 325) gives exactly 325 states/cycles per period — an off-by-one caught and fixed during development (see below)

`pulse` goes high for exactly one clock cycle every 325 clock cycles; `reset` (active-high) forces the counter to 0 and holds `pulse` low, taking priority over normal counting at all times.

## Files
- `baud_rate.v` — design
- `baud_rate_tb.v` — testbench

## Verification

Directed testbench covering:
1. Normal operation — pulse fires at the correct 325-cycle interval
2. Reset held high for an extended period
3. Back-to-back resets with short (1-2 cycle) gaps between them
4. Reset timed to land within the count=324→325 rollover window — confirms no conflict between external reset and internal rollover

Verified via `$monitor` text output and GTKWave waveform inspection of the internal `counter` signal. First pulse confirmed at exactly 325 clock cycles after reset release, matching hand calculation. Pulse confirmed exactly one cycle wide. Reset confirmed to correctly suppress pulse generation throughout multi-reset sequences.

**Screenshots**  zoomed views of (1) first pulse generation, (2) the multi-reset priority sequence, (3) final reset-vs-rollover edge case
## Bugs found and fixed during development

- Off-by-one in rollover threshold (325 → 324) — counting 0 to N inclusive produces N+1 states, not N

## Tools used
Icarus Verilog (simulation), GTKWave (waveform inspection)
