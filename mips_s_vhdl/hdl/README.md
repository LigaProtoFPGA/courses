# hdl — MIPS_S VHDL sources

The simulatable MIPS_S processor, its testbench and a test program that exercises
every instruction in the supported subset. Revised on 2026-07-23 to drop the
deprecated `IEEE.std_logic_unsigned` / `IEEE.std_logic_arith` libraries in favour of
`IEEE.numeric_std`; the new version was validated with regression tests.

## Files

| File | Contents |
| --- | --- |
| `MIPS_S_Sim.vhd` | The processor. Contains the `p_MIPS_S` package and the entity/architecture pairs for `reg32bits`, `reg_bank`, `alu`, `datapath`, `control_unit` and the top-level `MIPS_S`. |
| `mult_div.vhd` | The serial `multiplier` and `divider` units, used by MULTU and DIVU. |
| `MIPS_S_Sim_tb.vhd` | Testbench (`CPU_tb`). Includes the `aux_functions` package and the `RAM_mem` model. Uses two separate memories, so the simulated system is Harvard: 16 KB instruction memory, 16 KB data memory plus 16 KB simulating peripheral memory. Holds the CPU in reset until the program has been loaded. |
| `Allinsts_MIPS_S.asm` | Test program covering all instructions of the architecture — exhaustive over the instruction set, though not over every case per instruction. |
| `Allinsts_MIPS_S.txt` | MARS text-segment dump of the program above. **This** is the file the testbench actually reads. |
| `Wave-Allinst.wcfg` | Saved waveform configuration, so the relevant signals come up already grouped. |

## Running the simulation

1. Create a project in ISE or Vivado and add `MIPS_S_Sim.vhd`, `mult_div.vhd` and
   `MIPS_S_Sim_tb.vhd` as sources. Set `CPU_tb` as the simulation top.
2. **Put `Allinsts_MIPS_S.txt` in the simulator's working directory.** The testbench
   opens it by relative name:
   ```vhdl
   file ARQ : TEXT open READ_MODE is "Allinsts_MIPS_S.txt";
   ```
   If the file is not found the simulation fails at time 0. This is why the files here
   are kept flat rather than split into `src/`, `tb/` and `sw/`.
3. Load `Wave-Allinst.wcfg` if you want the pre-arranged signal groups. Its embedded
   database path points at the instructor's machine and can be ignored.
4. Run for **13.76 µs** at a 50 MHz clock to execute the whole test program, or
   **15.86 µs** if you use a testbench variant that also exercises the `suspend` pins.

## Modifying the test program

Write your program in **MARS**, staying within the 37-instruction MIPS32
subset MIPS_S supports (the list is in `../core_material/03_MIPS_S-Implementacao_V12.pdf`).
Then export the text segment in the same format as `Allinsts_MIPS_S.txt` and point the
testbench at it.

## Notes

- Little endian.
- This is the simulation-oriented organization, **MIPS_S_Sim**. A slightly different
  prototyping-oriented organization, MIPS_S_Prt, exists and will be documented separately.
- Suspend testing is commented out in the testbench; uncomment the two lines flagged in
  its header comments to enable it.
