# =====================================================================
# aula4_laco.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 4 - "Controle de fluxo"
#
# Este programa corresponde ao seguinte codigo em C:
#
#     int vetor[8] = {7, 3, 9, 2, 5, 8, 1, 6};
#
#     int main(void) {
#         int n     = 8;
#         int soma  = 0;
#         int maior = vetor[0];
#         for (int i = 0; i < n; i++) {
#             soma = soma + vetor[i];
#             if (vetor[i] > maior)
#                 maior = vetor[i];
#         }
#         printf("Soma = %d\nMaior = %d", soma, maior);
#         return 0;
#     }
#
# Os dois problemas que ficaram do encontro 3 - repeticao e decisao -
# resolvidos com quatro instrucoes: slt, beq, bne e j.
# =====================================================================

        .data
vetor:  .word  7, 3, 9, 2, 5, 8, 1, 6
msg1:   .asciiz "Soma = "
msg2:   .asciiz "\nMaior = "

        .text
        .globl main

main:
        la   $s0, vetor         # $s0 = endereco do elemento atual
        li   $s1, 8             # n = 8 (numero de elementos)
        li   $t0, 0             # i = 0
        li   $t1, 0             # soma = 0
        lw   $t2, 0($s0)        # maior = vetor[0]

laco:                           # --- teste do for: i < n ? --------------
        slt  $t3, $t0, $s1      # $t3 = 1 se i < n; senao, 0
        beq  $t3, $zero, fim    # se i >= n, sai do laco

        lw   $t4, 0($s0)        # $t4 = vetor[i]
        add  $t1, $t1, $t4      # soma = soma + vetor[i]

                                # --- if (vetor[i] > maior) -------------
        slt  $t3, $t2, $t4      # $t3 = 1 se maior < vetor[i]
        beq  $t3, $zero, pula   # se nao, pula a atualizacao
        move $t2, $t4           # maior = vetor[i]
pula:
        addi $t0, $t0, 1        # i++
        addi $s0, $s0, 4        # avanca para a proxima palavra
        j    laco               # volta ao teste

fim:                            # --- mostrar os resultados --------------
        li   $v0, 4
        la   $a0, msg1
        syscall                 # "Soma = "
        li   $v0, 1
        move $a0, $t1
        syscall                 # o valor da soma

        li   $v0, 4
        la   $a0, msg2
        syscall                 # nova linha e "Maior = "
        li   $v0, 1
        move $a0, $t2
        syscall                 # o valor do maior

        li   $v0, 10            # encerrar
        syscall
