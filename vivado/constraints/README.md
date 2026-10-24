# Board Constraints

`zedboard_updown.xdc` maps the top-level `led[7:0]` ports to the eight ZedBoard user LEDs and assigns `LVCMOS33` I/O standards.

The XDC is specific to the top-level port names used by `led_wrapper.v`. If you change the top module or LED port naming, update the constraints accordingly. Confirm the target part and board revision before implementation.
