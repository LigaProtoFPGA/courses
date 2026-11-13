# =====================================================================
# aula3_vetor.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 3 - "Memoria"
#
# Este programa corresponde ao seguinte codigo em C:
#
#     int vetor[5] = {7, 3, 9, 2, 5};
#     int soma;
#
#     int main(void) {
#         soma = vetor[0] + vetor[1] + vetor[2] + vetor[3] + vetor[4];
#         printf("Soma = %d", soma);
#         return 0;
#     }
#
# Pela primeira vez no curso, o programa escreve alguma coisa na tela:
# o resultado aparece no painel Run I/O, embaixo da janela do MARS.
# =====================================================================

        .data                   # daqui em diante vem DADOS, nao codigo
vetor:  .word  7, 3, 9, 2, 5    # cinco palavras, uma depois da outra
soma:   .word  0                # uma palavra para guardar o resultado
msg:    .asciiz "Soma = "       # um texto, terminado por um byte zero

        .text                   # daqui em diante vem codigo
        .globl main

main:
        la   $s0, vetor         # $s0 = ENDERECO do vetor (nao o valor!)

        lw   $t0, 0($s0)        # $t0 = vetor[0]  (endereco $s0 + 0)
        lw   $t1, 4($s0)        # $t1 = vetor[1]  (endereco $s0 + 4)
        add  $t2, $t0, $t1      # soma parcial

        lw   $t1, 8($s0)        # vetor[2]        (endereco $s0 + 8)
        add  $t2, $t2, $t1

        lw   $t1, 12($s0)       # vetor[3]        (endereco $s0 + 12)
        add  $t2, $t2, $t1

        lw   $t1, 16($s0)       # vetor[4]        (endereco $s0 + 16)
        add  $t2, $t2, $t1

        sw   $t2, 20($s0)       # guarda o resultado na memoria:
                                # "soma" fica logo depois do vetor,
                                # 5 palavras x 4 bytes = 20 bytes adiante

        # --- Mostrar o resultado: duas chamadas de sistema -----------
        li   $v0, 4             # servico 4: imprimir texto
        la   $a0, msg           # $a0 = ENDERECO do texto
        syscall

        li   $v0, 1             # servico 1: imprimir inteiro
        lw   $a0, 20($s0)       # $a0 = VALOR guardado em "soma"
        syscall

        li   $v0, 10            # servico 10: encerrar o programa
        syscall
