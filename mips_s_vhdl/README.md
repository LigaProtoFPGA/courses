# Specification, Design and Simulation of Processors in VHDL: the MIPS_S case study

**Instructor:** Prof. Ney Laert Vilar Calazans — ProtoFPGA, UFSC Araranguá

A course on computer organization and architecture, taught through a single case study.
It starts from the specification document that defines the **MIPS_S** processor and ends
at its VHDL implementation, simulated in ISE or Vivado.

MIPS_S is a multi-cycle, non-pipelined processor implementing 37 of the instructions of
the MIPS32 architecture. Caches, DMA, pipelining and floating point are deliberately
outside its scope — the specification says so explicitly and explains why.

> Course material is in Portuguese, except one supplementary text in English.

## Core material

Read in the order the file numbers suggest.

| File | Author | What it is |
| --- | --- | --- |
| `00_OsSeisElementosDefinitorios-ISA_V2.pdf` | Ney Calazans | The six elements that define an instruction set architecture: the programmer-visible registers, the instruction set, the instruction formats, the addressing modes, the assembly language and the memory model. 16 slides. |
| `01_MIPS_AppA-comErrata_V7.pdf` *(available on request)* | James Larus | Appendix A of Hennessy & Patterson: assemblers, linkers, and a complete instruction-by-instruction reference for MIPS assembly. The lookup manual for the course. This version carries the instructor's errata. |
| `02_Spec_ArqOrg_MIPS_S_V3.1_Port.pdf` | Ney Calazans | **The specification.** Defines MIPS_S: the instruction subset and its functional classes, the register file, the memory access structure and endianness, an organization for the processor, the ALU operations, the cycle count per instruction, the control block, and a program that exercises every instruction. 15 pages. |
| `03_MIPS_S-Implementacao_V12.pdf` | Fernando Moraes, revised by Ney Calazans | The implementation, from the RTL description through to the VHDL entities and architectures of the control and data blocks. Includes the list of supported instructions by class, and exercises. 41 slides. |
| `04_Modulos-MultDiv.pdf` | Fernando Moraes, Ney Calazans | Serial multiplication and division — the hardware behind the MULTU and DIVU instructions. 14 slides. |

## Supplementary material

| File | Author | What it is |
| --- | --- | --- |
| `01_RISCvsCISC_UPenn.pdf` | CIT 595, University of Pennsylvania | RISC vs. CISC, and the performance trade-off between the two. In English. 3 slides. |
| `01_CISC_vs_RISC.doc` | American University in Dubai | Short companion text on the same topic. |
| `05_MIPS_IntroProgramming.pdf` | Ney Calazans | Introduction to MIPS assembly programming — Unit 5 of the instructor's Hardware Description Languages course. Start here if you have never written assembly. 28 slides. |
| `06_MIPS_S_Progr_PropExercises_V1.0.doc` | Ney Calazans | Proposed programming exercises for MIPS_S. |

## Source code

The VHDL description of MIPS_S, the serial multiplier and divider, the testbench and a
test program covering every supported instruction are in [`hdl/`](hdl/). The README
there explains how to run the simulation.

## Requirements

- ISE or Vivado — see [`docs/software.md`](https://github.com/LigaProtoFPGA/docs/blob/main/software.md)
- MARS, to assemble test programs. The specification warns that sign extension is
  handled differently by other MIPS simulators, so results may not match.
- Basic digital logic and VHDL
  
## Material available on request

`01_MIPS_AppA-comErrata_V7.pdf` is Appendix A of *Computer Organization and Design* by
Hennessy & Patterson, published by Elsevier. As a chapter of a commercial publication it
is not redistributed here. It is provided to course participants on request — ask the
league's coordination or the instructor.

## Credits

Course material by Prof. Ney Laert Vilar Calazans, drawing on original material by
Profs. Ney Calazans, Fernando Moraes and Rafael Garibotti (PUCRS). Published here with
the author's permission, for educational use. Copyright remains with the authors.

Supplementary material is credited to its authors above and is reproduced for
educational use, with rights remaining with them.
