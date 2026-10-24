# Vivado Block Design Notes

The original design uses a Zynq-7000 Processing System connected through an AXI Interconnect to the custom `axi4lite_updown_counter` peripheral. A Processor System Reset block supplies reset signals to the interconnect and peripheral. The peripheral output is exported as `reg1_out[31:0]` and connected by `led_wrapper.v` to the ZedBoard's eight user LEDs using the lower eight bits.

The repository includes `../../docs/block_design.png` as a reference image of the original block design.

## Components visible in the design

- ZYNQ7 Processing System (`processing_system7_0`)
- AXI Interconnect (`ps7_0_axi_periph`)
- Processor System Reset (`rst_ps7_0_50M`)
- Custom AXI4-Lite counter peripheral (`axi4lite_updown_counter_v1_0`)
- Exported counter output bus (`reg1_out[31:0]`)

## Not included

The generated `design_1_wrapper.v`, Vivado `.xpr`, IP packaging metadata, generated Processing System configuration, synthesis/implementation runs, and cache files are not included. The screenshot is documentation, not a Tcl script that can regenerate the block design. To recreate the design, create/configure the Zynq Processing System for the target ZedBoard, add the AXI interconnect and reset IP, package or instantiate the custom RTL peripheral, connect the AXI and clock/reset interfaces, and regenerate the HDL wrapper.

Use the matching Vivado version and board files where possible. Verify all clocks, resets, address assignments, and AXI interface connections before synthesis.
