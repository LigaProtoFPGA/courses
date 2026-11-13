# =====================================================================
# aula6_contador_mars.asm  -  versao para TESTAR NO MARS
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 6 - "Do simulador ao silicio"
#
# E o mesmo programa do aula6_contador.asm. A unica diferenca esta nas
# tres funcoes de entrada e saida, no fim do arquivo: em vez de ler os
# botoes e as chaves e de acender os LEDs, elas usam o teclado e o
# painel Run I/O do MARS (syscall). Por isso este arquivo NAO roda no
# MIPS_S - serve so para testar a logica antes de ir para a placa.
#
# Codigos dos botoes (some para apertar varios ao mesmo tempo):
#     C = 1   U = 2   L = 4   R = 8   D = 16      0 = encerrar
# =====================================================================

        .data
txt_botao:  .asciiz "Botao (C=1 U=2 L=4 R=8 D=16, 0=sair): "
txt_chaves: .asciiz "Chaves (0 a 65535): "
txt_leds:   .asciiz "LEDs: "

        .text
        .globl main

main:
        lui   $s7, 0xFFFF       # $s7 = 0xFFFF0000: base dos enderecos de E/S
        addiu $s0, $zero, 0     # contador = 0
        addu  $a0, $s0, $zero
        jal   mostra_leds       # comeca com os LEDs apagados

laco:
        jal   espera_botao      # $v0 = qual botao foi apertado (ja solto)

        andi  $t0, $v0, 0x02    # BTNU?
        beq   $t0, $zero, nao_u
        addiu $s0, $s0, 1       # contador + 1
nao_u:
        andi  $t0, $v0, 0x10    # BTND?
        beq   $t0, $zero, nao_d
        addiu $s0, $s0, -1      # contador - 1
nao_d:
        andi  $t0, $v0, 0x04    # BTNL?
        beq   $t0, $zero, nao_l
        sll   $s0, $s0, 1       # contador x 2
nao_l:
        andi  $t0, $v0, 0x08    # BTNR?
        beq   $t0, $zero, nao_r
        srl   $s0, $s0, 1       # contador / 2
nao_r:
        andi  $t0, $v0, 0x01    # BTNC?
        beq   $t0, $zero, nao_c
        jal   le_chaves         # $v0 = valor das chaves
        addu  $s0, $v0, $zero   # contador = chaves
nao_c:
        andi  $s0, $s0, 0xFFFF  # so os 16 bits que cabem nos LEDs
        addu  $a0, $s0, $zero
        jal   mostra_leds
        j     laco              # o programa nunca termina: espera o proximo botao

# ---------------------------------------------------------------------
# AS TRES FUNCOES DE E/S - VERSAO MARS (teclado e Run I/O)
# Mesmos nomes, mesmos argumentos e mesmos resultados da versao placa.
# ---------------------------------------------------------------------

# espera_botao() -> $v0 = codigo do botao digitado (0 encerra)
espera_botao:
        li    $v0, 4
        la    $a0, txt_botao
        syscall
        li    $v0, 5            # le o codigo do botao
        syscall
        beq   $v0, $zero, eb_sair
        jr    $ra
eb_sair:
        li    $v0, 10
        syscall

# le_chaves() -> $v0 = valor digitado para as chaves
le_chaves:
        li    $v0, 4
        la    $a0, txt_chaves
        syscall
        li    $v0, 5
        syscall
        jr    $ra

# mostra_leds($a0): imprime os 16 bits de baixo de $a0, do LED15 ao LED0
mostra_leds:
        addu  $t2, $a0, $zero   # guarda o valor: $a0 vai ser usado no syscall
        li    $v0, 4
        la    $a0, txt_leds
        syscall
        li    $t1, 15           # bit 15 primeiro (LED da esquerda)
ml_laco:
        srlv  $t3, $t2, $t1     # traz o bit $t1 para a posicao 0
        andi  $t3, $t3, 1
        addiu $a0, $t3, 48      # 48 = codigo do caractere '0'
        li    $v0, 11           # servico 11: imprime um caractere
        syscall
        addiu $t1, $t1, -1
        bgez  $t1, ml_laco      # ate o bit 0
        li    $v0, 11
        li    $a0, 10           # nova linha
        syscall
        jr    $ra
