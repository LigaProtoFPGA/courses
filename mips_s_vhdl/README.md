# Specification, Design and Simulation of Processors in VHDL: the MIPS_S case study

**Instructor:** Prof. Ney Laert Vilar Calazans
**Term:** 2026/2 — ProtoFPGA, UFSC Araranguá
**Language:** all material is in Portuguese (one supplementary text is in English)

A hands-on course on computer organization and architecture. It starts from the
specification document that defines the **MIPS_S** processor and ends at a working
VHDL implementation, simulated in ISE and/or Vivado.

MIPS_S ("MIPS Subset") is a multi-cycle, non-pipelined processor that implements 37
of the 168 instructions of the MIPS32 ISA. It is the base platform for most of the
league's ongoing hardware projects — the floating-point coprocessor, faster
multiply/divide units, caches, the pipelined version and the RISC-V_S port — so
understanding it is the entry point to all of them.

## What you will learn

**Architecture vs. organization.** What actually defines an instruction set
architecture, through six elements: programmer-visible registers, the instruction set,
instruction formats, addressing modes, the assembly language, and the memory access
model. Why dozens of different organizations can implement the same architecture.

**RISC and CISC.** Where the two design philosophies came from, how the CPU
performance equation makes the trade-off concrete (instructions per program vs. cycles
per instruction), and what each choice implies downstream — hardwired vs. microcoded
control, fixed vs. variable instruction length, register file size, load-store
discipline.

**The MIPS architecture in depth.** The R2000/MIPS32 instruction set format by format
and semantics by semantics; assemblers, linkers and loaders; the memory layout (text,
static data, dynamic data, stack); the procedure calling convention and stack frames;
exceptions and interrupts through coprocessor 0; memory-mapped I/O; and how to write
and run programs on the SPIM/MARS simulator.

**The MIPS_S organization.** How the 37 supported instructions map onto a multi-cycle
datapath and control unit: the five execution stages, the temporal barriers between
them, the multiplexers and control signals, and how each instruction class (arithmetic,
logic, shift, memory access, test, control flow) walks through the machine. The split
between the control block and the data block, and the signals that cross between them.

**RTL design in VHDL.** Reading a specification document and turning it into synthesizable
entities and architectures; the difference between the simulation-oriented organization
(MIPS_S_Sim) and the prototyping-oriented one (MIPS_S_Prt); running a testbench that
loads a program into memory and watching the processor execute it.

**Arithmetic hardware.** The four ways of representing integers (sign-magnitude, one's
complement, two's complement, bias) and what each is good for; serial multiplication
and division by successive shift-and-add, which is exactly what makes MULTU and DIVU
slow in MIPS_S (67 clock cycles each) — the starting point for the league's work on
parallel multipliers.

## Core material

Read roughly in this order. Files are numbered accordingly.

| File | What it is |
| --- | --- |
| [`00_OsSeisElementosDefinitorios-ISA_V2.pdf`](core_material/00_OsSeisElementosDefinitorios-ISA_V2.pdf) | The six defining elements of an architecture. Sets up the architecture/organization distinction that the whole course rests on. 16 slides. |
| `01_MIPS_AppA-comErrata_V7.pdf` — *available on request* | Appendix A of Hennessy & Patterson, written by James Larus (Microsoft): assemblers, linkers, the SPIM simulator, and a complete instruction-by-instruction reference for MIPS R2000 assembly. The course's lookup manual — Section A.1 for the concepts, A.10 (pp. A-33 to A-36) for addressing modes, assembler syntax, directives and the opcode map, pp. A-37 to A-60 for the full instruction reference. The instructor's errata is applied to this version. |
| [`02_Spec_ArqOrg_MIPS_S_V3.1_Port.pdf`](core_material/02_Spec_ArqOrg_MIPS_S_V3.1_Port.pdf) | **The specification document.** Defines what MIPS_S is: the supported subset, what was deliberately left out (pipeline, caches, DMA, interrupt controller, floating point), the register set, and the interface and internal signals of the organization. The reference you keep coming back to. |
| [`03_MIPS_S-Implementacao_V12.pdf`](core_material/03_MIPS_S-Implementacao_V12.pdf) | The implementation, stage by stage, from RTL description through to the VHDL entities and architectures of the control and data blocks. Includes the full list of the 37 supported instructions by class, and exercises. 41 slides. |
| [`04_Modulos-MultDiv.pdf`](core_material/04_Modulos-MultDiv.pdf) | Integer representations and serial multiplication/division — the hardware behind MULTU and DIVU. |

## Supplementary material

| File | What it is |
| --- | --- |
| [`01_RISCvsCISC_UPenn.pdf`](supplementary_material/01_RISCvsCISC_UPenn.pdf) | RISC vs. CISC lecture slides. © CIT 595, University of Pennsylvania. In English. |
| [`01_CISC_vs_RISC.doc`](supplementary_material/01_CISC_vs_RISC.doc) | Short companion text on the same topic. © American University in Dubai. |
| [`05_MIPS_IntroProgramming.pdf`](supplementary_material/05_MIPS_IntroProgramming.pdf) | Introduction to MIPS assembly programming — Unit 5 of the instructor's Hardware Description Languages course. Useful if you have never written assembly. |
| [`06_MIPS_S_Progr_PropExercises_V1.0.doc`](supplementary_material/06_MIPS_S_Progr_PropExercises_V1.0.doc) | Proposed programming exercises for MIPS_S. Best way to check you actually understood the instruction subset. |

### Material available on request

`01_MIPS_AppA-comErrata_V7.pdf` is Appendix A of *Computer Organization and Design* by
Hennessy & Patterson, published by Elsevier. As a chapter of a commercial publication it
is not redistributed here. It is part of the course and is provided to participants on
request — ask the league's coordination or the course instructor.

## Source code

The VHDL description of MIPS_S, the serial multiplier/divider, the testbench and a
test program that exercises every supported instruction are in [`hdl/`](hdl/). See
the README there for how to set up and run the simulation in ISE or Vivado.

## Suggested study path

1. Read `00` and the two RISC/CISC texts. You should be able to explain why MIPS is
   load-store and what that costs and buys.
2. Request `01` and read Section A.1, then A.10 pp. A-33 to A-36. Skim pp. A-37 onwards
   to see what a complete ISA specification looks like — no need to memorise it.
3. If assembly is new to you, work through `05` and write a few small programs in
   MARS or SPIM. Keep to the 37-instruction subset MIPS_S supports (listed in `03`).
4. Read `02` end to end. This is the contract the hardware has to satisfy.
5. Work through `03` alongside the VHDL sources in `hdl/`, matching each stage in the
   slides to the code. Run the testbench with the supplied test program, then write a
   program of your own and run that.
6. Read `04` and try the exercises in `06`.

## Requirements

- ISE and/or Vivado — see [`docs/software.md`](https://github.com/LigaProtoFPGA/docs/blob/main/software.md)
- MARS, to assemble the test programs
- Basic digital logic and VHDL, at the level of the league's introductory course

## Credits

Course material by Prof. Ney Laert Vilar Calazans, drawing on original material by
Profs. Ney Calazans, Fernando Moraes and Rafael Garibotti (PUCRS). Published here with
the author's permission, for educational use. Copyright remains with the authors.

Supplementary material is credited to its authors: the RISC vs. CISC slides are from
CIT 595, University of Pennsylvania, and the accompanying text is from the American
University in Dubai. Both are reproduced for educational use, with rights remaining
with their authors.

One item is not redistributed here; see
[Material available on request](#material-available-on-request).
