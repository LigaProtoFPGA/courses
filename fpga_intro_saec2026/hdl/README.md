# hdl — Nexys A7 projects

Every folder below is a self-contained Vivado project: its `.vhd` sources, its `.xdc`
constraints and, when there is one, a testbench in `sim/`. Shared modules such as
`display4.vhd` are copied into every folder that uses them, so any folder can be opened
on its own.

All projects target the **Digilent Nexys A7-100T** (part `xc7a100tcsg324-1`, 100 MHz clock).

## Demos

Programmed live on the board during the course.

| Slide | Folder | Top entity | What it does |
| --- | --- | --- | --- |
| 30 | `demos/1_counter` | `contador_top` | Counts from 0 to 9999, once per second |
| 37 | `demos/1_counter/slow_multiplexing` | `contador_top` | Same counter, but each digit stays lit for 0.2 s, so the display visibly lights up one digit at a time |
| 42 | `demos/2_reaction_time` | `reacao_top` | BTNU starts a round; after 2 s LED0 turns on; press BTNC as fast as you can. The display shows the reaction time in ms |
| 44 | `demos/3_basketball_game_clock` | `top_cron_basq_a7` | Basketball game clock with FIBA/NBA modes, quarters and time loading from the switches |

## Exercises and challenges

| Slides | Folder | Top entity | Notes |
| --- | --- | --- | --- |
| 20 | `exercises/01_switches_to_leds` | `leds` | Each switch drives its LED |
| 21–22 | `exercises/02_predict_the_leds` | `prever` | Guess what each line does, then check on the board |
| 8–9, 24–29 | `exercises/03_car_alarm` | `alarme` | `alarm = (P and L) or B`. `tb_alarme.vhd` checks the six instants from Exercise 4 |
| 39 | `exercises/04_counter_challenges/c1_change_speed` | `contador_top` | Counts 4 times per second (`LIMITE := 25_000_000`) |
| 40 | `exercises/04_counter_challenges/c2_count_down` | `contador_top` | Counts down from 9999 |
| 41 | `exercises/04_counter_challenges/c3_pause_with_switch` | `contador_top` | Counts only while SW0 is on |
| — | `exercises/bonus/countdown_timer` | `top_cron_dec_a7` | The league's other timer, ported the same way as the basketball clock. Hold the buttons for about 1 s |
| — | `exercises/bonus/simple_stopwatch` | `cronometro_top` | Simpler stopwatch: BTNC start, BTNU pause, BTND reset |

## Building a project

1. **Create Project** → RTL Project → select the **Nexys A7-100T** board.
2. **Add Sources**: every `.vhd` in the folder, except those in `sim/`.
3. **Add Constraints**: the `.xdc` in the folder.
4. Set the top entity listed above.
5. **Run Synthesis** → **Run Implementation** → **Generate Bitstream**.
6. **Open Hardware Manager** → Open Target → Auto Connect → **Program Device**.

The schematic on slide 24 comes from RTL Analysis → Open Elaborated Design → Schematic.

## Simulating

Add the testbench (`sim/*.vhd` or `tb_alarme.vhd`) as a simulation source, set it as the
simulation top, and run **Run Behavioral Simulation**. The basketball clock testbench
overrides `MAXCOUNT => 5` and the countdown timer testbench overrides `CLOCK_FREQ => 4`,
so time runs fast in simulation.

## Basketball game clock on the Nexys A7

The original was written for the Nexys 2 (50 MHz) in
[`vhdl_chronometers`](https://github.com/LigaProtoFPGA/vhdl_chronometers). The logic is
unchanged; only the clock frequency and the pins were adapted. Every changed line is
marked `-- Nexys A7`:

- `cron_basq_PI.vhd`: `CKS_por_CENTESIMO` 500000 → 1000000
- `Debounce.vhd`: `DIVISION_RATE` 4_000_000 → 8_000_000
- `DsplDrv.vhd`: 1 kHz display clock counter 25000 → 50000
- New top `top_cron_basq_a7.vhd`: connects the original top to the Nexys A7 pins, inverts
  the reset (CPU RESET is active-low) and turns off the four leftmost digits

| Input / output | Function |
| --- | --- |
| CPU RESET | Restart. Hold BTNU while releasing it for NBA mode (12-minute quarters); otherwise FIBA (10-minute quarters) |
| BTNC | Stop / resume |
| BTNR | Load the time set on the switches |
| BTNU | Next quarter |
| SW1–SW0 | Seconds: 0, 15, 30 or 45 |
| SW5–SW2 | Minutes |
| SW7–SW6 | Quarter |
| LED3–LED0 | Minutes, in binary |
| LED7–LED4 | Quarter, one LED per quarter |
| Display | seconds.hundredths |

The controls look unusual because the Nexys 2 only has 4 buttons, 8 switches and a 4-digit
display: seconds use just 2 switches (15 s steps), the mode is picked by holding a button
during reset, and BTNU has two jobs. On the Nexys A7 the whole clock uses 144 of 63,400
LUTs (0.23%) and 153 of 126,800 flip-flops (0.12%).

## Nexys A7 notes

- 7-segment segments (CA–CG, DP) and digit enables (AN0–AN7) are **active-low**. LEDs are active-high.
- Buttons BTNx read `1` when pressed; CPU_RESETN reads `0` when pressed.
- SW8 and SW9 use `LVCMOS18`; every other switch uses `LVCMOS33`.
- The projects only use the four rightmost display digits.
