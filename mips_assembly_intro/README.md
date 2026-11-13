# Introductory Course on Low-Level Programming: MIPS assembly, from C to silicon

**Instructors:** members of ProtoFPGA, UFSC Araranguá  
**Taught:** 2026/2, six weekly one-hour lessons, followed by a final project  
**Audience:** first-year Computer Engineering students. No prerequisites.  
**Recordings:** [YouTube playlist](https://www.youtube.com/watch?v=orurjjp3e6g&list=PLGEc7FHy_kM8)

A first course in assembly programming. It starts from a short C program and walks it
down to the 32-bit numbers the processor actually reads, then teaches participants to
write that middle layer — MIPS assembly — themselves: registers and instruction formats,
memory, control flow, and functions with the stack. Lessons 1 to 5 run entirely in the
**MARS** simulator, using the full MIPS32 instruction set and MARS system calls. Lesson 6
closes the arc: a program written in MARS runs on **MIPS_S**, a 37-instruction MIPS
implemented in an FPGA on a **Digilent Nexys A7-100T** board.

Each lesson also points, in about two minutes, to the digital-circuits block that the
instruction being studied drives — the ALU for `add`, the address decoder for `lw`, the
PC multiplexer for `beq` — linking the course to the Digital Circuits class students take
at the same time.

> Course material is in Portuguese, including the comments in the assembly and VHDL
> sources.

## Core material

The slides used in class, one file per lesson.

| File | What it is |
| --- | --- |
| [`01_Do_C_ao_Binario.pdf`](core_material/01_Do_C_ao_Binario.pdf) | The same program written four ways: C, assembly, basic assembly and machine code. Who does each translation (compiler, assembler, processor), pseudoinstructions and directives, reading an instruction destination-first, and the four columns of MARS's Text Segment window. 17 slides. |
| [`02_Registradores_e_Formato_da_Instrucao.pdf`](core_material/02_Registradores_e_Formato_da_Instrucao.pdf) | The 32 registers and their conventions, and why there are exactly 32 (a 5-bit field). R, I and J formats, opening `add` and `addiu` field by field, the `funct` field as the ALU's control bits. Two's complement, sign extension and overflow. 20 slides. |
| [`03_Memoria.pdf`](core_material/03_Memoria.pdf) | Addresses, words and alignment; a value versus the address of a value. Memory regions (`.text`, `.data`, stack), `la`, `lw` and `sw`, walking an array, and system calls for printing results. 21 slides. |
| [`04_Controle_de_Fluxo.pdf`](core_material/04_Controle_de_Fluxo.pdf) | `j`, `beq`, `bne` and `slt`. Translating `if`/`else`, `while` and `for`, why the condition is inverted in assembly, walking an array in a loop, and how branch targets are encoded. Launches the final project. 21 slides. |
| [`05_Funcoes_e_de_C_para_MIPS.pdf`](core_material/05_Funcoes_e_de_C_para_MIPS.pdf) | `jal` and `jr`, arguments in `$a0`–`$a3` and results in `$v0`, `$t` versus `$s` registers, the stack and the stack frame, recursion with `fact`, and what each line of C costs in MIPS. 22 slides. |
| [`06_Do_Simulador_ao_Silicio.pdf`](core_material/06_Do_Simulador_ao_Silicio.pdf) | The FPGA board, a first look at VHDL, and MIPS_S: what its 37-instruction subset leaves out and why, what to write instead, memory-mapped I/O with `lw` and `sw`, and the counter program running on the board. 16 slides. |

## Exercises

| File | What it is |
| --- | --- |
| [`01_Atividade.pdf`](exercises/01_Atividade.pdf) | Lesson 1 activity sheet: the in-class activity in pairs (observe, predict, modify, explain), the challenge of the week and review exercises. |
| [`01_Gabarito.pdf`](exercises/01_Gabarito.pdf) | Answers to the lesson 1 activity sheet. Try the exercises before opening it. |
| [`02_Atividade.pdf`](exercises/02_Atividade.pdf) | Lesson 2: reading instruction fields in MARS's Code column, two's complement and overflow with `add` versus `addu`. Ends with a reference sheet (registers, formats, opcodes) used in the following lessons. |
| [`02_Gabarito.pdf`](exercises/02_Gabarito.pdf) | Answers to the lesson 2 activity sheet. |
| [`03_Atividade.pdf`](exercises/03_Atividade.pdf) | Lesson 3: addresses and alignment, `la`, `lw` and `sw` on an array, reading the Data Segment window. |
| [`03_Gabarito.pdf`](exercises/03_Gabarito.pdf) | Answers to the lesson 3 activity sheet. |
| [`04_Atividade.pdf`](exercises/04_Atividade.pdf) | Lesson 4: translating `if`, `while` and `for` with `beq`, `bne` and `slt`, and computing branch targets. |
| [`04_Gabarito.pdf`](exercises/04_Gabarito.pdf) | Answers to the lesson 4 activity sheet. |
| [`05_Atividade.pdf`](exercises/05_Atividade.pdf) | Lesson 5: `jal` and `jr`, the calling convention, the stack frame and the recursive `fact`. |
| [`05_Gabarito.pdf`](exercises/05_Gabarito.pdf) | Answers to the lesson 5 activity sheet. |
| [`06_Atividade.pdf`](exercises/06_Atividade.pdf) | Lesson 6, all in MARS: find what MIPS_S lacks in the lesson 4 program, predict the counter's LEDs, multiply by 3 without `mul`, and port the lesson 4 program to show its sum on the LEDs. Reference sheet with the 37 MIPS_S instructions, the replacement table and the I/O addresses. |
| [`06_Gabarito.pdf`](exercises/06_Gabarito.pdf) | Answers to the lesson 6 activity sheet. |

Each sheet has three parts: the in-class activity in pairs, an optional challenge and review
exercises for home. Answer sheets were handed out after each lesson.

## Final project

[`Projeto_Final_Assembly_MIPS.pdf`](final_project/Projeto_Final_Assembly_MIPS.pdf) — guidelines,
requirements and topics. In pairs, each with a different topic, participants write a MIPS
assembly program that runs in MARS, has at least one loop and one function that follows
the calling convention, prints its result with explanatory text, and is published in a
public GitHub repository with a `README.md` following the template in the document. Ten
topics of similar difficulty, from an accumulating calculator to a guessing game, each
with a mandatory test case.

## Source code

- [`asm/`](asm/) — the MARS programs used in class, one or two per lesson, each with the
  equivalent C code in its header.
- [`hdl/`](hdl/) — the complete Vivado project for lesson 6: MIPS_S with its memories, the
  I/O peripheral, the board program and a script that builds the bitstream. The README
  there explains how to build it and how to run your own program on the board.

## Requirements

- **MARS** (MIPS Assembler and Runtime Simulator), which needs Java. The course uses MARS
  rather than SPIM, since SPIM handles sign extension differently and results may not match.
- For lesson 6 only: Vivado — see [`docs/setup/software.md`](https://github.com/LigaProtoFPGA/docs/blob/main/setup/software.md) —
  and a Digilent Nexys A7-100T board.

## Further reading

Appendix A of *Computer Organization and Design*, by Patterson & Hennessy (written by
James Larus), is the reference text throughout the course: the register table (Fig. A.6.1),
memory layout (A.5), system calls (Fig. A.9.1), calling convention and the `fact` example
(A.6), and the exercises in A.12 used as final-project topics. A copy with the instructor's
errata is in [`../mips_s_vhdl/core_material/`](../mips_s_vhdl/core_material/01_MIPS_AppA-comErrata_V7.pdf).

## Credits

Course material by the members of ProtoFPGA. The MIPS_S processor, its multiplier/divider
and the `MIPS_S_withBRAMs` subsystem are by Profs. Ney Laert Vilar Calazans and Fernando
Moraes; see also [`mips_s_vhdl/`](../mips_s_vhdl/) for the course on how MIPS_S is specified
and built. Pin assignments come from Digilent's official Nexys A7 master XDC.
