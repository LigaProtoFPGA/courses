# =====================================================================
# aula2_transbordo.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 2 - "Registradores e o formato da instrucao"
#
# Dois jeitos de somar os mesmos numeros. Antes de executar, escreva
# o que espera encontrar em $t2 e em $t3. Execute com Step.
#
# Dica: para ver os valores em hexadecimal, marque
# Settings -> Values displayed in hexadecimal.
# =====================================================================

        .text
        .globl main

main:
        li   $t0, 0x7FFFFFFF    # o maior inteiro positivo de 32 bits
        li   $t1, 1

        addu $t2, $t0, $t1      # soma sem verificar transbordo
        add  $t3, $t0, $t1      # soma que verifica transbordo

        li   $v0, 10            # encerramento (sera que chega aqui?)
        syscall
