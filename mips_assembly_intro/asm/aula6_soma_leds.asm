# =====================================================================
# aula6_soma_leds.asm  -  o programa do encontro 4, portado para o MIPS_S
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 6 - "Do simulador ao silicio"  (resposta da atividade A4)
#
# Soma os elementos do vetor e acha o maior, como o aula4_laco.asm.
# O que mudou para caber no MIPS_S:
#   - add  virou addu, e addi virou addiu (o MIPS_S nao tem add nem addi);
#   - os syscall de impressao sairam: o resultado vai para os LEDs;
#   - no fim, em vez do servico 10, o programa alterna o que mostra
#     a cada botao apertado: soma -> maior -> soma -> ...
# =====================================================================

        .data
vetor:  .word  7, 3, 9, 2, 5, 8, 1, 6

        .text
        .globl main

main:
        la    $s0, vetor        # endereco do elemento atual
        addiu $s1, $zero, 8     # n = 8
        addiu $t0, $zero, 0     # i = 0
        addiu $t1, $zero, 0     # soma = 0
        lw    $t2, 0($s0)       # maior = vetor[0]

laco:   slt   $t3, $t0, $s1     # i < n ?
        beq   $t3, $zero, fim
        lw    $t4, 0($s0)       # vetor[i]
        addu  $t1, $t1, $t4     # soma += vetor[i]       (era add)
        slt   $t3, $t2, $t4     # maior < vetor[i] ?
        beq   $t3, $zero, pula
        addu  $t2, $t4, $zero   # maior = vetor[i]       (move vira addu)
pula:   addiu $t0, $t0, 1       # i++                    (era addi)
        addiu $s0, $s0, 4
        j     laco

fim:    addu  $s2, $t1, $zero   # $s2 = soma  = 41 (0000000000101001)
        addu  $s3, $t2, $zero   # $s3 = maior =  9 (0000000000001001)
        lui   $s7, 0xFFFF       # base da E/S

mostra: sw    $s2, 8($s7)       # LEDs = soma
        jal   espera_botao
        sw    $s3, 8($s7)       # LEDs = maior
        jal   espera_botao
        j     mostra

# espera_botao: a mesma do aula6_contador.asm
espera_botao:
eb_aperta:
        lw    $t0, 0($s7)
        beq   $t0, $zero, eb_aperta
        addu  $v0, $t0, $zero
        lui   $t1, 0x0004
eb_tempo1:
        addiu $t1, $t1, -1
        bne   $t1, $zero, eb_tempo1
eb_solta:
        lw    $t0, 0($s7)
        bne   $t0, $zero, eb_solta
        lui   $t1, 0x0004
eb_tempo2:
        addiu $t1, $t1, -1
        bne   $t1, $zero, eb_tempo2
        jr    $ra
