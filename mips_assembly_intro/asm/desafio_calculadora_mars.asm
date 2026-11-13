# =====================================================================
# desafio_calculadora_mars.asm  -  resposta do desafio (Parte B)
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 6 - "Do simulador ao silicio"
#
# Calculadora de 16 bits: a cada botao, le as chaves e faz uma conta
# com o acumulador, mostrado nos LEDs.
#     BTNC  acumulador = chaves
#     BTNU  acumulador = acumulador + chaves        (addu)
#     BTND  acumulador = acumulador - chaves        (subu)
#     BTNL  acumulador = acumulador x chaves        (multu + mflo)
#     BTNR  acumulador = resto de acumulador / chaves (divu + mfhi)
# Versao MARS: as tres funcoes de E/S sao as do aula6_contador_mars.asm.
# Para a placa, troque-as pelas do aula6_contador.asm.
# =====================================================================

        .data
txt_botao:  .asciiz "Botao (C=1 U=2 L=4 R=8 D=16, 0=sair): "
txt_chaves: .asciiz "Chaves (0 a 65535): "
txt_leds:   .asciiz "LEDs: "

        .text
        .globl main

main:
        lui   $s7, 0xFFFF       # base da E/S (usada pela versao placa)
        addiu $s0, $zero, 0     # acumulador = 0
        addu  $a0, $s0, $zero
        jal   mostra_leds

laco:
        jal   espera_botao
        addu  $s1, $v0, $zero   # $s1 = botao: precisa sobreviver ao jal seguinte
        jal   le_chaves
        addu  $s2, $v0, $zero   # $s2 = chaves

        andi  $t0, $s1, 0x01    # BTNC: carrega
        beq   $t0, $zero, nao_c
        addu  $s0, $s2, $zero
nao_c:
        andi  $t0, $s1, 0x02    # BTNU: soma
        beq   $t0, $zero, nao_u
        addu  $s0, $s0, $s2
nao_u:
        andi  $t0, $s1, 0x10    # BTND: subtrai
        beq   $t0, $zero, nao_d
        subu  $s0, $s0, $s2
nao_d:
        andi  $t0, $s1, 0x04    # BTNL: multiplica
        beq   $t0, $zero, nao_l
        multu $s0, $s2
        mflo  $s0               # os 32 bits de baixo do produto
nao_l:
        andi  $t0, $s1, 0x08    # BTNR: resto da divisao
        beq   $t0, $zero, nao_r
        beq   $s2, $zero, nao_r # dividir por zero: nao faz nada
        divu  $s0, $s2
        mfhi  $s0               # o resto fica em hi
nao_r:
        andi  $s0, $s0, 0xFFFF
        addu  $a0, $s0, $zero
        jal   mostra_leds
        j     laco

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
        li    $v0, 11
        syscall
        addiu $t1, $t1, -1
        bgez  $t1, ml_laco
        li    $a0, 10           # nova linha
        li    $v0, 11
        syscall
        jr    $ra
