# =====================================================================
# aula6_contador.asm  -  versao para a PLACA (MIPS_S na Nexys A7)
# Curso Introdutorio de Programacao de Baixo Nivel - Liga ProtoFPGA
# Aula 6 - "Do simulador ao silicio"
#
# Um contador de 16 bits mostrado nos 16 LEDs da placa e controlado
# pelos 5 botoes:
#     BTNU (cima)     soma 1
#     BTND (baixo)    subtrai 1
#     BTNL (esquerda) desloca 1 bit para a esquerda (x 2)
#     BTNR (direita)  desloca 1 bit para a direita (/ 2)
#     BTNC (centro)   carrega o valor das 16 chaves (SW15..SW0)
#
# So usa instrucoes do MIPS_S: nada de syscall, add, sub ou mul.
# A entrada e a saida sao feitas por enderecos de memoria (E/S
# mapeada em memoria), atendidos pelo periferico em VHDL:
#     0xFFFF0000  leitura: botoes   (bit 0 = C, 1 = U, 2 = L, 3 = R, 4 = D)
#     0xFFFF0004  leitura: chaves   (bits 15..0)
#     0xFFFF0008  escrita: LEDs     (bits 15..0)
# =====================================================================

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
# espera_botao() -> $v0 = botoes apertados
# Fica lendo os botoes ate algum ser apertado e guarda qual foi. Um botao
# e uma peca mecanica: ao apertar e ao soltar, o contato "trepida" por
# alguns milissegundos, e o processador (que le milhoes de vezes por
# segundo) veria varios apertos. Por isso a funcao espera um tempinho
# depois de apertar e depois de soltar. Funcao folha: so usa $t.
# ---------------------------------------------------------------------
espera_botao:
eb_aperta:
        lw    $t0, 0($s7)       # le os botoes
        beq   $t0, $zero, eb_aperta   # nenhum apertado: continua lendo
        addu  $v0, $t0, $zero   # guarda quais estavam apertados
        lui   $t1, 0x0004       # $t1 = 0x40000 = 262144 voltas de espera
eb_tempo1:
        addiu $t1, $t1, -1      # 2 instrucoes x 4 ciclos x 262144 voltas
        bne   $t1, $zero, eb_tempo1   # = cerca de 42 ms a 50 MHz
eb_solta:
        lw    $t0, 0($s7)
        bne   $t0, $zero, eb_solta    # espera soltar todos
        lui   $t1, 0x0004
eb_tempo2:
        addiu $t1, $t1, -1      # mais 42 ms, para a trepidacao ao soltar
        bne   $t1, $zero, eb_tempo2
        jr    $ra

# ---------------------------------------------------------------------
# le_chaves() -> $v0 = valor das 16 chaves
# ---------------------------------------------------------------------
le_chaves:
        lw    $v0, 4($s7)
        jr    $ra

# ---------------------------------------------------------------------
# mostra_leds($a0): acende os LEDs com os 16 bits de baixo de $a0
# ---------------------------------------------------------------------
mostra_leds:
        sw    $a0, 8($s7)
        jr    $ra
