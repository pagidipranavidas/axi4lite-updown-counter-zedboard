# AXI4-Lite Up/Down Counter — Custom RTL on ZedBoard

A custom Verilog RTL AXI4-Lite slave peripheral implementing an up/down counter, integrated with a Zynq-7000 Processing System and demonstrated on a Digilent ZedBoard.

**Project status:** Completed 14 August 2025  
**Context:** ISRO SDSC SHAR internship project  
**HDL / tools:** Verilog HDL, AMD/Xilinx Vivado Design Suite 2018.3  
**Target board:** Digilent ZedBoard (Zynq-7000)

> This repository preserves the uploaded RTL, testbench, and board constraints. The generated Vivado project, Processing System configuration files, and `design_1_wrapper` source are not included; see `vivado/block_design/README.md` before attempting to recreate the complete hardware design.

## Overview

The design exposes a custom AXI4-Lite slave peripheral to the Zynq Processing System. Software can access a control register through the memory-mapped interface, while the counter value is exposed on a 32-bit output. The top-level `led_wrapper` connects the lower eight bits of that output to the ZedBoard user LEDs.

The counter starts from zero after reset, runs when the enable bit is set, counts upward to `0xFF`, then reverses direction and counts downward to zero before reversing again.

## Architecture

```text
    PS[Zynq-7000 Processing System] -->|AXI GP / AXI4-Lite| IC[AXI Interconnect]
    IC -->|S_AXI| CNT[Custom AXI4-Lite Up/Down Counter]
    CNT -->|reg1_out[7:0]| LED[ZedBoard User LEDs]
```

The first three blocks are shown in the Vivado block-design screenshot. The LED wrapper connects the peripheral output to the board-level LED pins.

## Repository layout

```text
axi4lite-updown-counter-zedboard/
├── README.md
├── .gitignore
├── rtl/
│   ├── axi4lite_updown_counter.v
│   └── led_wrapper.v
├── tb/
│   └── tb_axi4lite_updown_counter.v
├── vivado/
│   ├── block_design/README.md
│   └── constraints/zedboard_updown.xdc
└── docs/
    ├── block_design.png
    ├── simulation_waveform.png
    └── zedboard_led_demo.png
```

## RTL modules

### `axi4lite_updown_counter.v`

- Parameterized AXI data and address widths (default: 32-bit data and 4-bit address).
- AXI4-Lite write-address, write-data, write-response, read-address, and read-data channel signals.
- Control register `slv_reg0` with enable at bit 0 and direction at bit 1 (`0` = up, `1` = down).
- Counter register `slv_reg1`, exposed through `reg1_out`.
- Automatic direction reversal at counter values `0xFF` and `0x00`.

### `led_wrapper.v`

Wraps the generated `design_1_wrapper` and connects `reg1_out[7:0]` to the eight top-level LED outputs. The generated `design_1_wrapper` is not included in this repository; see the block-design notes.

## Register map

The RTL decodes the word-aligned address using `S_AXI_AWADDR[3:2]` and `S_AXI_ARADDR[3:2]`.

| Byte offset | Read behavior | Write behavior | Notes |
|---|---|---|---|
| `0x00` | Returns `slv_reg0` | Writes `slv_reg0` | Control register; bit 0 enables counting and bit 1 selects direction |
| `0x04` | Returns `slv_reg1` | Writes `slv_reg1_shadow` | The shadow register is not used by the counter logic in this RTL |
| Other decoded offsets | Returns `32'hDEADBEEF` | No register update | The RTL does not implement a dedicated error response for these offsets |

On reset, the control register is assigned `32'h00000001` and the counter is cleared to zero. Therefore, the counter is enabled and initially set to count upward after reset. The direction changes automatically at the configured limits.

## Simulation

The testbench `tb/tb_axi4lite_updown_counter.v` generates a 100 MHz clock (10 ns period), applies reset, writes `0x1` to the control register at address `0x0`, waits, reads address `0x4`, and prints the returned data.

The waveform screenshot in `docs/simulation_waveform.png` is included as visual evidence from the original simulation. Run the testbench in a Verilog simulator compatible with the source files. The testbench instantiates the peripheral RTL directly; it does not instantiate the Zynq Processing System.

## Recreating the Vivado design

See [`vivado/block_design/README.md`](vivado/block_design/README.md) for the block-design components and what is not included. The supplied XDC maps the eight `led` output bits to the ZedBoard LED pins. The full Vivado project and generated Processing System wrapper must be recreated in Vivado using the appropriate board settings and the block-design reference image.

## Implementation notes

This repository is intended to document the original internship implementation, not to claim that the RTL is a fully AXI4-Lite-compliant reusable production IP. Before reusing it in another design, review and verify at least:

- independent acceptance of AXI write-address and write-data channels;
- application of `S_AXI_WSTRB` byte enables;
- reset assignments and multiple procedural assignments to `slv_reg0`;
- read/write response timing and back-pressure behavior;
- register behavior for unsupported addresses;
- testbench coverage for reset, up/down transitions, rollover, and back-pressure.

These are review items identified from the source and are not claims that the original project tested each case.

## Attribution and permission

The custom RTL and project materials are published by the author with permission to share the source. Board, device, and vendor names are used to identify the target platform and tools. This repository does not include AMD/Xilinx generated IP source or a complete Vivado project export.

No separate open-source license is currently provided. Unless a license is added, reuse of the repository contents is not automatically granted merely because the repository is publicly viewable.
