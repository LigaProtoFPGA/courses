# courses

Full course material from the courses and short courses taught at **ProtoFPGA**,
the academic league for rapid prototyping of complex hardware at UFSC — Araranguá.
Each course lives in its own folder and is self-contained: slides, reference texts,
source code and everything a participant needs to study on their own. Short,
task-oriented guides (how to install a tool, how to run one specific Vivado command)
belong in [`tutorials`](https://github.com/LigaProtoFPGA/tutorials) instead.

> Most course material is written in Portuguese, since that is the language it is
> taught in. Repository documentation is in English.

## Courses

| Course | Instructor | Term | Folder | Recordings |
| --- | --- | --- | --- | --- |
| Specification, Design and Simulation of Processors in VHDL: the MIPS_S case study | Prof. Ney Calazans | 2026/2 | [`mips_s_vhdl/`](mips_s_vhdl/) | [YouTube playlist](https://www.youtube.com/playlist?list=PLTsfe7KykBVs) |

## Recorded lectures

Lectures are recorded and published on YouTube. The course listed above has already
finished, and its playlist holds the complete set of sessions — anyone can follow the
material from start to finish at their own pace, using the slides and source code in
the corresponding folder alongside the videos.

## Folder layout

```
<course-name>/
├── README.md                # what the course covers and how to study it
├── core_material/           # the course's own slides and reference texts
├── supplementary_material/  # background reading and exercise sets
└── hdl/                     # VHDL/Verilog sources, testbenches, test programs
```

## Rights

Course material is published here with the permission of its authors, for educational
use. Copyright remains with them.

Third-party material used in a course — book chapters, lecture slides from other
institutions, vendor documentation — is not redistributed. Each course README lists
those items and how participants can obtain them.
