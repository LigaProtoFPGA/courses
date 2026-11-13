# =====================================================================
# aula2_campos.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 2 - "Registradores e o formato da instrucao"
#
# Nada e impresso na tela. O que interessa aqui e observado em dois
# lugares: no painel de registradores e na coluna Code da janela
# Text Segment, onde cada instrucao aparece como numero de 32 bits.
# =====================================================================

        .text                   # daqui em diante vem codigo
        .globl main             # torna "main" visivel ao simulador

main:
        # --- Formato I: operacao, um registrador de origem,
        #     um registrador de destino e um numero de 16 bits
        li   $t0, 12            # $t0 = 12
        li   $t1, 5             # $t1 = 5

        # --- Formato R: todas estas tem op = 0.
        #     O que muda de uma para outra e o campo funct.
        add  $t2, $t0, $t1      # 12 + 5         = 17
        sub  $t3, $t0, $t1      # 12 - 5         = 7
        and  $t4, $t0, $t1      # 1100 E  0101   = 0100 = 4
        or   $t5, $t0, $t1      # 1100 OU 0101   = 1101 = 13

        # --- Formato I com imediato negativo (complemento de dois)
        addi $s0, $t2, -1       # 17 + (-1)      = 16

        # --- Um numero que nao cabe em 16 bits.
        #     Conte quantas linhas aparecem na coluna Basic.
        li   $s1, 100000        # $s1 = 100000

        # --- O registrador que vale sempre zero.
        #     A linha abaixo tenta escrever 7 nele. Confira o resultado.
        li   $zero, 7

        li   $v0, 10            # formula de encerramento
        syscall
