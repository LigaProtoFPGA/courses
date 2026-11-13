# =====================================================================
# aula5_funcoes.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 5 - "Funcoes, e de C para MIPS"
#
# O programa do encontro 4, reorganizado em tres funcoes. Em C:
#
#     int soma_vetor(int v[], int n) {
#         int s = 0;
#         for (int i = 0; i < n; i++) s = s + v[i];
#         return s;
#     }
#     int maior_vetor(int v[], int n) {
#         int m = v[0];
#         for (int i = 0; i < n; i++) if (v[i] > m) m = v[i];
#         return m;
#     }
#     void imprime(char *texto, int valor) {
#         printf("%s%d\n", texto, valor);
#     }
#     int main(void) {
#         int soma  = soma_vetor(vetor, 8);
#         int maior = maior_vetor(vetor, 8);
#         imprime("Soma = ", soma);
#         imprime("Maior = ", maior);
#         return 0;
#     }
#
# Convencao: argumentos em $a0, $a1...; resultado em $v0.
# =====================================================================

        .data
vetor:  .word  7, 3, 9, 2, 5, 8, 1, 6
msg1:   .asciiz "Soma = "
msg2:   .asciiz "Maior = "

        .text
        .globl main

main:
        la   $a0, vetor         # 1o argumento: endereco do vetor
        li   $a1, 8             # 2o argumento: n
        jal  soma_vetor         # chama; o resultado volta em $v0
        move $s0, $v0           # soma: guardada num registrador $s

        la   $a0, vetor
        li   $a1, 8
        jal  maior_vetor
        move $s1, $v0           # maior

        la   $a0, msg1          # imprime("Soma = ", soma)
        move $a1, $s0
        jal  imprime

        la   $a0, msg2          # imprime("Maior = ", maior)
        move $a1, $s1
        jal  imprime

        li   $v0, 10            # encerrar
        syscall

# ---------------------------------------------------------------------
# soma_vetor(endereco em $a0, n em $a1)  ->  soma em $v0
# ---------------------------------------------------------------------
soma_vetor:
        li   $v0, 0             # s = 0
        li   $t0, 0             # i = 0
sv_laco:
        slt  $t1, $t0, $a1      # i < n ?
        beq  $t1, $zero, sv_fim
        lw   $t2, 0($a0)        # v[i]
        add  $v0, $v0, $t2      # s = s + v[i]
        addi $t0, $t0, 1        # i++
        addi $a0, $a0, 4        # proxima palavra
        j    sv_laco
sv_fim:
        jr   $ra                # volta para quem chamou

# ---------------------------------------------------------------------
# maior_vetor(endereco em $a0, n em $a1)  ->  maior em $v0
# ---------------------------------------------------------------------
maior_vetor:
        lw   $v0, 0($a0)        # m = v[0]
        li   $t0, 0             # i = 0
mv_laco:
        slt  $t1, $t0, $a1      # i < n ?
        beq  $t1, $zero, mv_fim
        lw   $t2, 0($a0)        # v[i]
        slt  $t1, $v0, $t2      # m < v[i] ?
        beq  $t1, $zero, mv_pula
        move $v0, $t2           # m = v[i]
mv_pula:
        addi $t0, $t0, 1        # i++
        addi $a0, $a0, 4
        j    mv_laco
mv_fim:
        jr   $ra

# ---------------------------------------------------------------------
# imprime(texto em $a0, valor em $a1): mostra o texto, o valor e
# pula uma linha. Nao devolve nada.
# ---------------------------------------------------------------------
imprime:
        li   $v0, 4             # servico 4: o texto ($a0 ja aponta para ele)
        syscall
        li   $v0, 1             # servico 1: o valor
        move $a0, $a1
        syscall
        li   $v0, 11            # servico 11: um caractere
        li   $a0, 10            # 10 = nova linha
        syscall
        jr   $ra
