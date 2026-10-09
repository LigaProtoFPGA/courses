# From Code to Chip: a hands-on introduction to FPGAs

**Instructors:** members of ProtoFPGA, UFSC Araranguá  
**Taught at:** SAEC 2026, October 8, 2026 (one morning, about 4 hours)  
**Recording:** [YouTube](VIDEO_URL)

An introductory mini-course for people who have never touched an FPGA. It starts from
binary numbers and logic gates, goes through the full Vivado flow from VHDL to bitstream,
and ends with real projects running on a **Digilent Nexys A7-100T**: a counter on the
7-segment display, a reaction-time game and a basketball game clock built by the league.
The last part shows that a processor is just another circuit, using MIPS_S as the example.

No prerequisites. Students follow the exercises on paper and watch the projects being
programmed live on the board.

> Course material is in Portuguese, including the comments in the VHDL sources.

## Core material

| File | Author | What it is |
| --- | --- | --- |
| [`01_Minicurso_FPGA_SAEC2026.pdf`](core_material/01_Minicurso_FPGA_SAEC2026.pdf) | ProtoFPGA | The slides used in class: what an FPGA is (LUTs, flip-flops, parallelism), from code to board (entity/architecture, XDC, Vivado, testbenches), the 7-segment counter, the basketball game clock as a state machine, and a first look at MIPS_S and MIPS assembly. Eight exercises with answers. 59 slides. |

## Source code

Every project shown in class, plus the exercises and challenges from the slides, is in
[`hdl/`](hdl/). Each folder is a self-contained Vivado project for the Nexys A7. The README
there lists the top entity of each one and explains how to build and simulate them.

## Requirements

- Vivado — see [`docs/setup/software.md`](https://github.com/LigaProtoFPGA/docs/blob/main/setup/software.md)
- A Digilent Nexys A7-100T board to run the projects. Everything except programming the
  board can be done in simulation.

## Credits

Course material by the members of ProtoFPGA, under the supervision of Prof. Ney Calazans
and Prof. Rodrigo. `Debounce.vhd` and `DsplDrv.vhd` are by Prof. Ney Laert Vilar Calazans.
The basketball game clock and the countdown timer were written by league members for
[`vhdl_chronometers`](https://github.com/LigaProtoFPGA/vhdl_chronometers) and ported
here from the Nexys 2 to the Nexys A7. Pin assignments come from Digilent's official
Nexys A7 master XDC.
