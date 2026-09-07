# Second-Order Fixed-Point Exponential Filter

VHDL implementation of a second-order exponential digital filter for sampled signals.

The filter processes signed fixed-point data using the Q16.16 format and supports a configurable coefficient `K`. The architecture is designed as a synchronous sequential circuit and processes one input sample per clock cycle.

## Key features

- Signed fixed-point arithmetic in Q16.16 format (32-bit data path).
- Configurable 3-bit coefficient `K`.
- Synchronous reset and automatic reinitialization when `K` changes.
- Special pass-through behavior for `K = 0`.
- Structural implementation of adders, subtractors, multiplexers, and comparators.
- Behavioral and Post-Place-and-Route timing simulation.
- Testbench with clock generation, input stimuli, and assertions.

## Interface

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `CLK` | Input | 1 bit | System clock (50 MHz in testbench) |
| `RST` | Input | 1 bit | Active-high reset |
| `X` | Input | 32 bits | Input sample, signed Q16.16 |
| `K` | Input | 3 bits | Filter coefficient |
| `Y` | Output | 32 bits | Output sample, signed Q16.16 |

## Architecture overview

The design is divided into the following main modules:

- `Term_generator`: combinational logic that calculates the filter terms.
- `Term_summer`: structural adder that sums the terms.
- `State_register`: sequential logic that stores inputs, outputs, and internal states.
- `Comparator`: detects coefficient changes and the special case `K = 0`.

Additional parametrized components include full adders, ripple-carry adders, subtractors, and multiplexers.

## Repository structure

```text
.
├── README.md
├── RelazioneHajjiouiMohammed.pdf
├── src/
│   └── *.vhd
├── tb/
│   └── filter_tb.vhd
```

## How to use

1. Clone or download the repository.
2. Open Vivado and create a new project (or open the provided project, if included).
3. Add the VHDL sources from `src/` and the testbench from `tb/`.
4. Run behavioral simulation, then synthesis and implementation if targeting an FPGA.

## Documentation

The complete technical description, including equations, design choices, and simulation results, is available in the project report:

[Read the complete project report (PDF)](RelazioneHajjiouiMohammed.pdf)

## Author

**Mohammed Hajjioui**  
Computer Engineering graduate, Politecnico di Milano.

## License

This project is published for educational and portfolio purposes.
