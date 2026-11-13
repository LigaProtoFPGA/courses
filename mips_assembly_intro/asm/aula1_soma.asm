# =====================================================================
# aula1_soma.asm
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 1 - "Do C ao binario"
#
# Este programa corresponde ao seguinte codigo em C:
#
#     int main(void) {
#         int a     = 12;
#         int b     = 5;
#         int soma  = a + b;        /* 17 */
#         int dobro = soma + soma;  /* 34 */
#         return 0;
#     }
#
# Nada e impresso na tela. O resultado e observado nos registradores.
# =====================================================================

        .text                   # daqui em diante vem codigo (instrucoes)
        .globl main             # torna o rotulo "main" visivel ao simulador

main:
        li   $t0, 12            # a = 12         -> $t0 recebe 12
        li   $t1, 5             # b = 5          -> $t1 recebe 5
        add  $t2, $t0, $t1      # soma = a + b   -> $t2 = $t0 + $t1
        add  $t3, $t2, $t2      # dobro = soma + soma -> $t3 = $t2 + $t2

        li   $v0, 10            # formula de encerramento: pede ao
        syscall                 # simulador para terminar o programa
                                # (sera explicada na Aula 3)
