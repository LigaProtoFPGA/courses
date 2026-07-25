# hdl — MIPS_S VHDL sources

The simulatable MIPS_S processor, its testbench, and a test program that exercises every
instruction in the supported subset.

## Files

| File | Contents |
| --- | --- |
| `MIPS_S_Sim.vhd` | The processor. Contains the `p_MIPS_S` package and the entity/architecture pairs for `reg32bits`, `reg_bank`, `alu`, `datapath`, `control_unit` and the top-level `MIPS_S`. |
| `mult_div.vhd` | The serial multiplier and divider, used by MULTU and DIVU. |
| `MIPS_S_Sim_tb.vhd` | Testbench (`CPU_tb`). Includes the `aux_functions` package and the `RAM_mem` model. Instruction and data memories are separate, so the simulated system is Harvard. Holds the CPU in reset until the program has been loaded. |
| `Allinsts_MIPS_S.asm` | Test program covering every instruction of the architecture — exhaustive over the instruction set, though not over every case per instruction. |
| `Allinsts_MIPS_S.txt` | MARS text-segment dump of the program above. **This** is the file the testbench reads. |
| `Wave-Allinst.wcfg` | Saved waveform configuration, with the relevant signals already grouped. The database path inside it points at the machine where it was saved and can be ignored. |

## Running the simulation

1. Create a project in ISE or Vivado and add `MIPS_S_Sim.vhd`, `mult_div.vhd` and
   `MIPS_S_Sim_tb.vhd` as sources. Set `CPU_tb` as the simulation top.

2. **Put `Allinsts_MIPS_S.txt` in the simulator's working directory.** The testbench
   opens it by relative name:

   ```vhdl
   file ARQ : TEXT open READ_MODE is "Allinsts_MIPS_S.txt";
   ```

   If the file is not found, the simulation fails at time 0. This is why the files here
   are kept flat rather than split into `src/`, `tb/` and `sw/`.

3. Run for **16 µs**. The testbench clock is 50 MHz, and the full test program completes
   within that time.

## Modifying the test program

Write your program in MARS, keeping to the instruction subset MIPS_S supports — the list
is in [`../core_material/03_MIPS_S-Implementacao_V12.pdf`](../core_material/03_MIPS_S-Implementacao_V12.pdf).
Export the text segment in the same format as `Allinsts_MIPS_S.txt` and point the
testbench at it.

The processor and the memory model are **little endian**.
