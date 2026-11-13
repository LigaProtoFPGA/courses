# =====================================================================
# criar_projeto.tcl - cria o projeto no Vivado e gera o bitstream
# Liga ProtoFPGA - Encontro 6 "Do simulador ao silicio"
#
# No Vivado: Tools > Run Tcl Script... e escolha este arquivo.
# Ele gera o bitstream do programa escolhido abaixo (padrao: aula6_contador).
# Para outro programa, no Tcl Console do Vivado:
#     set programa meu_programa
#     source <caminho>/criar_projeto.tcl
# Ou no terminal:
#     vivado -mode batch -source criar_projeto.tcl -tclargs meu_programa
# =====================================================================

set raiz [file dirname [file normalize [info script]]]
if {![info exists programa]} {
    if {[info exists argc] && $argc > 0} { set programa [lindex $argv 0] } else { set programa aula6_contador }
}
# Nexys A7-100T. Para a Nexys A7-50T, troque por xc7a50ticsg324-1L
set parte xc7a100tcsg324-1

set memoria $raiz/memorias/$programa/memory.vhd
if {![file exists $memoria]} { error "nao achei $memoria" }

create_project -force $programa $raiz/vivado/$programa -part $parte
add_files [glob $raiz/src/*.vhd]
add_files $memoria
add_files -fileset constrs_1 $raiz/constraints/nexys_a7_100t.xdc
set_property top top_nexys_a7 [current_fileset]
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

file mkdir $raiz/bitstreams
set bit [glob $raiz/vivado/$programa/$programa.runs/impl_1/*.bit]
file copy -force $bit $raiz/bitstreams/$programa.bit
puts "\n==> pronto: $raiz/bitstreams/$programa.bit\n"
