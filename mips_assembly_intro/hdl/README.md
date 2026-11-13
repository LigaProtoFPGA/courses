# hdl — MIPS_S on the Nexys A7

The system programmed live on the board in lesson 6: the **MIPS_S** processor with its
instruction and data memories, plus a small memory-mapped I/O peripheral that connects
it to the buttons, switches and LEDs. The program inside the memories is
`aula6_contador.asm`, a 16-bit counter shown on the LEDs.

Target: **Digilent Nexys A7-100T** (part `xc7a100tcsg324-1`). The board clock is 100 MHz;
the processor runs at 50 MHz.

## Files

| File | Contents |
| --- | --- |
| `src/MIPS_S_Prt.vhd` | The processor (prototypable version), by Ney Calazans and Fernando Moraes. |
| `src/mult_div.vhd` | Serial multiplier and divider, used by MULTU and DIVU. |
| `src/MIPS_S_withBRAMs.vhd` | Processing subsystem: MIPS_S plus a 512-word instruction memory and an 8 KB data memory in BRAM. |
| `src/periferico_es.vhd` | The I/O peripheral. A multiplexer answers `lw` at `0xFFFF0000` (buttons) and `0xFFFF0004` (switches); a register stores `sw` to `0xFFFF0008` (LEDs). Inputs go through two flip-flops for synchronization. |
| `src/top_nexys_a7.vhd` | Top entity `top_nexys_a7`: divides the clock by 2, inverts CPU RESET (active-low) and wires the subsystem to the peripheral. |
| `constraints/nexys_a7_100t.xdc` | The lines used by the top, copied unchanged from Digilent's Nexys A7-100T master XDC. |
| `asm/aula6_contador.asm` | The board program. Uses only MIPS_S instructions: no `syscall`, `add`, `sub` or `mul`. |
| `memorias/aula6_contador/prog.txt` | MARS text-segment dump of the program above (**File → Dump Memory**, Hexadecimal Text). |
| `memorias/aula6_contador/memory.vhd` | The memories with that program inside, generated from `prog.txt` by `gera_memory.py`. |
| `ferramentas/gera_memory.py` | Turns MARS dumps into a `memory.vhd`. See its header for usage. |
| `criar_projeto.tcl` | Creates the Vivado project and generates the bitstream in one go. |

The same program with MARS-based I/O, for testing the logic in the simulator first, is
[`../asm/aula6_contador_mars.asm`](../asm/aula6_contador_mars.asm). Only the three I/O
functions differ.

## The counter

| Input | Effect on the counter |
| --- | --- |
| BTNU | +1 |
| BTND | −1 |
| BTNL | shift left (× 2) |
| BTNR | shift right (÷ 2) |
| BTNC | load the value on SW15–SW0 |
| CPU RESET | back to 0 |

The program never ends: with no operating system, there is nowhere to return to.

## Memory-mapped I/O

| Address | Access | Contents |
| --- | --- | --- |
| `0xFFFF0000` | `lw` | Buttons: bit 0 = C, 1 = U, 2 = L, 3 = R, 4 = D |
| `0xFFFF0004` | `lw` | Switches, bits 15–0 |
| `0xFFFF0008` | `sw` | LEDs, bits 15–0 |

## Building the bitstream

In Vivado, **Tools → Run Tcl Script…** and pick `criar_projeto.tcl`. It creates the project
under `vivado/`, runs synthesis and implementation, and copies the bitstream to
`bitstreams/aula6_contador.bit`. Both folders are generated and are not versioned.

From a terminal:

```
vivado -mode batch -source criar_projeto.tcl -tclargs aula6_contador
```

Then **Open Hardware Manager** → Open Target → Auto Connect → **Program Device**.

For a Nexys A7-50T, change `parte` in the script to `xc7a50ticsg324-1L`.

## Running your own program

1. Write the program in MARS using only the MIPS_S subset — see the slide
   "O que escrever no lugar" in lesson 6: `add` → `addu`, `addi` → `addiu`,
   `sub` → `subu`, `mul` → `multu` + `mflo`, and `lw`/`sw` at the I/O addresses instead
   of `syscall`. When in doubt, check MARS's **Basic** column: that is what goes to the board.
2. **File → Dump Memory**: dump `.text` to `prog.txt` and, if the program has data,
   `.data` to `data.txt`.
3. Generate the memories:

   ```
   python3 ferramentas/gera_memory.py --portavel prog.txt data.txt memorias/<name>/memory.vhd
   ```

   Use `-` in place of `data.txt` when there is no `.data`.
4. Build with `-tclargs <name>` (or `set programa <name>` in the Tcl console before
   sourcing the script).

The instruction memory holds 512 words, starting at `0x00400000`; data starts at
`0x10010000`.
