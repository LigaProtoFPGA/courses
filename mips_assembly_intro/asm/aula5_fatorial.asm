# =====================================================================
# aula5_fatorial.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 5 - "Funcoes, e de C para MIPS"
#
# A funcao que chama a si mesma. Em C (Apendice A, Secao A.6):
#
#     int fact(int n) {
#         if (n == 0) return 1;
#         return n * fact(n - 1);
#     }
#     int main(void) {
#         int n = 5;
#         printf("fact(%d) = %d", n, fact(n));
#         return 0;
#     }
#
# Cada chamada de fact guarda na PILHA o que precisa reencontrar
# depois: o endereco de retorno ($ra) e o seu proprio n ($a0).
# =====================================================================

        .data
msg1:   .asciiz "fact("
msg2:   .asciiz ") = "

        .text
        .globl main

main:
        li   $s1, 5             # n = 5 (troque para testar outros valores)
        move $a0, $s1           # argumento: n
        jal  fact               # $v0 = fact(n)
        move $s0, $v0

        li   $v0, 4             # imprime "fact(n) = resultado"
        la   $a0, msg1
        syscall
        li   $v0, 1
        move $a0, $s1
        syscall
        li   $v0, 4
        la   $a0, msg2
        syscall
        li   $v0, 1
        move $a0, $s0
        syscall

        li   $v0, 10
        syscall

# ---------------------------------------------------------------------
# fact(n em $a0)  ->  n! em $v0
# ---------------------------------------------------------------------
fact:
        addi $sp, $sp, -8       # PROLOGO: abre espaco para 2 palavras
        sw   $ra, 4($sp)        #   guarda o endereco de retorno
        sw   $a0, 0($sp)        #   guarda n

        bne  $a0, $zero, geral  # n != 0 -> caso geral
        li   $v0, 1             # caso base: fact(0) = 1
        j    sai

geral:
        addi $a0, $a0, -1       # argumento: n - 1
        jal  fact               # $v0 = fact(n - 1)  -- $ra e $a0 mudam!
        lw   $a0, 0($sp)        # recupera o n desta chamada
        mul  $v0, $a0, $v0      # $v0 = n * fact(n - 1)

sai:
        lw   $ra, 4($sp)        # EPILOGO: recupera o endereco de retorno
        addi $sp, $sp, 8        #   devolve o espaco
        jr   $ra
