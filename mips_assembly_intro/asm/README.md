# asm — MARS programs used in class

The assembly programs opened in the MARS simulator during the lessons. Lessons 1 to 5 use
the full MIPS32 instruction set and the MARS system calls, without restrictions. The
board version of the lesson 6 program, restricted to the MIPS_S subset, is in
[`../hdl/asm/`](../hdl/asm/).

## Files

| Lesson | File | What it does | Output |
| --- | --- | --- | --- |
| 1 | `aula1_soma.asm` | `a = 12`, `b = 5`, `soma = a + b`, `dobro = soma + soma`. Prints nothing: the result is read in the register panel. | `$t2` = 17, `$t3` = 34 |
| 2 | `aula2_campos.asm` | One instruction of each kind seen in class (`add`, `sub`, `and`, `or`, `addi` with a negative immediate), a constant too large for 16 bits, and a write to `$zero`. Meant to be read in the **Code** column. | `$t2`–`$t5` = 17, 7, 4, 13; `$s0` = 16; `$s1` = 100000; `$zero` = 0 |
| 2 | `aula2_transbordo.asm` | Adds 1 to the largest 32-bit integer twice: with `addu` and with `add`. | `$t2` = −2147483648, then *arithmetic overflow* |
| 3 | `aula3_vetor.asm` | Sums a 5-element array with `la`, `lw` and `sw`, stores the result in memory and prints it with system calls. | `Soma = 26` |
| 4 | `aula4_laco.asm` | Sum and largest element of an 8-element array in a single `for` loop with an `if` inside. | `Soma = 41`, `Maior = 9` |
| 5 | `aula5_funcoes.asm` | The lesson 4 program split into three functions: `soma_vetor`, `maior_vetor` and `imprime`. | `Soma = 41`, `Maior = 9` |
| 5 | `aula5_fatorial.asm` | Recursive factorial (`fact`, from Appendix A), saving `$ra` and `n` on the stack. | `fact(5) = 120` |
| 6 | `aula6_contador_mars.asm` | The lesson 6 counter with its three I/O functions rewritten for MARS: button codes and switch values are typed in Run I/O, and the LEDs are printed as 16 bits. Used to test the logic before going to the board. | `LEDs: 0000000000000101` … |
| 6 | `aula6_soma_leds.asm` | The lesson 4 program ported to MIPS_S (answer to activity A4): only MIPS_S instructions, the sum written to the LED address `0xFFFF0008`, and the largest element shown alternately at each button press. In MARS, see the result in the Data Segment window, region `0xffff0000 (MMIO)`. | `Mem[0xffff0008]` = 41 (`0x29`) |
| 6 | `desafio_calculadora_mars.asm` | Answer to the lesson 6 challenge: a 16-bit calculator on the LEDs using `multu`, `divu`, `mflo` and `mfhi`, with the MARS I/O functions. | C 100 → U 23 → L 2 → R 7 → D 2: 100, 123, 246, 1, 65535 |

Every program was assembled and run in MARS 4.5; the outputs above are what MARS shows.

## Running a program

1. Open the `.asm` file in MARS (**File → Open**).
2. **Assemble** (F3). Assemble again after every edit — MARS runs the last assembled
   version, not the one shown in the editor.
3. **Run** (F5) to run it all, or **Step** (F7) to run one instruction at a time and
   watch the registers change. **Backstep** (F8) undoes the last step.

The slides write immediates in decimal. To make the **Basic** column match, uncheck
**Settings → Values displayed in hexadecimal**.

In `aula6_contador_mars.asm`, the button codes are C = 1, U = 2, L = 4, R = 8 and D = 16;
type 0 to end the program.
