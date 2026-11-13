#!/usr/bin/env python3
"""
gera_memory.py - gera o memory.vhd do MIPS_S_withBRAMs a partir dos dumps do MARS
Liga ProtoFPGA - Encontro 6 "Do simulador ao silicio"

Faz o mesmo papel do le_mars: pega o codigo de maquina (.text) e os dados (.data)
que o MARS exporta e escreve esses valores nos INIT_xx das BRAMs de um memory.vhd
que serve de modelo (o do MIPS_S, que ja tem todas as entidades e portas certas).
So os valores dos INIT mudam; o resto do arquivo fica identico.

Uso:
    python3 gera_memory.py modelo_memory.vhd prog.txt data.txt memory.vhd
    python3 gera_memory.py --portavel prog.txt data.txt memory.vhd

Com --portavel, nao precisa de modelo: gera um memory.vhd com as mesmas entidades e
portas, mas descrito em VHDL comum (sem as primitivas RAMB16 do Spartan-3). O Vivado
reconhece essas memorias e as poe em BRAM do mesmo jeito. Use se a sintese reclamar
de RAMB16_S36 ou RAMB16_S9.

prog.txt e data.txt saem do MARS em File > Dump Memory, em qualquer um destes formatos:
  - "Hexadecimal Text": uma palavra por linha (ex.: 3c17ffff)
  - "Text/Data Segment Window": as linhas da janela do MARS (ex.: 0x00400000  0x3c17ffff ...)
data.txt e opcional: use "-" quando o programa nao tem .data.

Mapa do MIPS_S_withBRAMs:
  memoria de instrucoes: 0x00400000, 512 palavras, uma RAMB16_S36 (8 palavras por INIT_xx)
  memoria de dados: 0x10010000, modulos de 8 KB (mod0, mod1, ...), cada um com 4 RAMB16_S9;
    o block_k guarda o byte k de cada palavra (bits 8k+7..8k), 32 bytes por INIT_xx
  Em cada INIT_xx, o elemento de indice menor fica mais a direita.
"""
import re
import sys

TEXT_BASE = 0x00400000
DATA_BASE = 0x10010000
PROG_WORDS = 512
MOD_BYTES = 8192
MOD_WORDS = MOD_BYTES // 4


def le_dump(caminho, base):
    """Devolve a lista de palavras (int) a partir de 'base', aceitando os dois formatos."""
    palavras = {}
    with open(caminho, encoding="utf-8", errors="replace") as f:
        linhas = f.read().splitlines()
    sequencial = 0
    for linha in linhas:
        s = linha.strip()
        if not s:
            continue
        if re.fullmatch(r"[0-9a-fA-F]{8}", s):            # Hexadecimal Text
            palavras[sequencial] = int(s, 16)
            sequencial += 1
            continue
        campos = s.split()
        if not campos[0].lower().startswith("0x"):         # cabecalho da janela
            continue
        endereco = int(campos[0], 16)
        if base == TEXT_BASE:                              # janela Text: endereco, codigo, ...
            palavras[(endereco - base) // 4] = int(campos[1], 16)
        else:                                              # janela Data: endereco + 8 palavras
            for i, c in enumerate(campos[1:9]):
                if c.lower().startswith("0x"):
                    palavras[(endereco - base) // 4 + i] = int(c, 16)
    if not palavras:
        return []
    n = max(palavras) + 1
    return [palavras.get(i, 0) for i in range(n)]


def init_hex(valores, largura_bytes):
    """Uma linha INIT de 256 bits: o elemento 0 vai mais a direita."""
    return "".join(f"{v:0{2 * largura_bytes}x}" for v in reversed(valores))


def vhdl_portavel(prog, dados, n_mods=2):
    def lista(vals, digitos):
        itens = [f'{i} => x"{v:0{digitos}x}"' for i, v in enumerate(vals) if v]
        return ", ".join(itens + ["others => (others => '0')"])
    partes = [f"""-- memory.vhd gerado por gera_memory.py --portavel (Liga ProtoFPGA)
-- Mesmas entidades e portas do memory.vhd do le_mars, em VHDL sem primitivas.
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity program_memory is
    port( clock: in std_logic;
          address: in std_logic_vector(8 downto 0);
          instruction: out std_logic_vector(31 downto 0));
end program_memory;

architecture program_memory of program_memory is
    type rom_t is array(0 to 511) of std_logic_vector(31 downto 0);
    constant rom : rom_t := ({lista(prog, 8)});
begin
    process(clock)
    begin
        if rising_edge(clock) then
            instruction <= rom(to_integer(unsigned(address)));
        end if;
    end process;
end program_memory;
"""]
    for mod in range(n_mods):
        ini = mod * MOD_WORDS
        palavras = dados[ini: ini + MOD_WORDS]
        blocos = []
        for k in range(4):
            vals = [(w >> (8 * k)) & 0xFF for w in palavras]
            blocos.append(f"    signal mem{k} : ram_t := ({lista(vals, 2)});")
        partes.append(f"""
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity data_mem_mod{mod} is
    port( clock, ce, we, bw: in std_logic;
          address: in std_logic_vector(10 downto 0);
          byte_choice: in std_logic_vector(1 downto 0);
          data_in: in std_logic_vector(31 downto 0);
          data_out: out std_logic_vector(31 downto 0));
end data_mem_mod{mod};

architecture data_mem_mod{mod} of data_mem_mod{mod} is
    type ram_t is array(0 to 2047) of std_logic_vector(7 downto 0);
{chr(10).join(blocos)}
    signal we3, we2, we1, we0 : std_logic;
    signal d3, d2, d1, d0 : std_logic_vector(7 downto 0);
begin
    we3 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="11"))) else '0';
    we2 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="10"))) else '0';
    we1 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="01"))) else '0';
    we0 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="00"))) else '0';
    d3 <= data_in(7 downto 0) when bw='1' else data_in(31 downto 24);
    d2 <= data_in(7 downto 0) when bw='1' else data_in(23 downto 16);
    d1 <= data_in(7 downto 0) when bw='1' else data_in(15 downto 8);
    d0 <= data_in(7 downto 0);

    -- um processo por bloco de bytes, como as 4 BRAMs do original (escrita: write-first)
    p3: process(clock) begin if rising_edge(clock) then
        if we3='1' then mem3(to_integer(unsigned(address))) <= d3; data_out(31 downto 24) <= d3;
        else data_out(31 downto 24) <= mem3(to_integer(unsigned(address))); end if; end if; end process;
    p2: process(clock) begin if rising_edge(clock) then
        if we2='1' then mem2(to_integer(unsigned(address))) <= d2; data_out(23 downto 16) <= d2;
        else data_out(23 downto 16) <= mem2(to_integer(unsigned(address))); end if; end if; end process;
    p1: process(clock) begin if rising_edge(clock) then
        if we1='1' then mem1(to_integer(unsigned(address))) <= d1; data_out(15 downto 8) <= d1;
        else data_out(15 downto 8) <= mem1(to_integer(unsigned(address))); end if; end if; end process;
    p0: process(clock) begin if rising_edge(clock) then
        if we0='1' then mem0(to_integer(unsigned(address))) <= d0; data_out(7 downto 0) <= d0;
        else data_out(7 downto 0) <= mem0(to_integer(unsigned(address))); end if; end if; end process;
end data_mem_mod{mod};
""")
    return "".join(partes)


def main():
    if len(sys.argv) == 5 and sys.argv[1] == "--portavel":
        _, _, prog_txt, data_txt, saida = sys.argv
        prog = le_dump(prog_txt, TEXT_BASE)
        dados = [] if data_txt == "-" else le_dump(data_txt, DATA_BASE)
        if len(prog) > PROG_WORDS:
            sys.exit(f"erro: o programa tem {len(prog)} palavras; a memoria de instrucoes so tem {PROG_WORDS}")
        if len(dados) > 2 * MOD_WORDS:
            sys.exit(f"erro: os dados tem {len(dados) * 4} bytes; a memoria de dados so tem {2 * MOD_BYTES}")
        prog += [0] * (PROG_WORDS - len(prog))
        dados += [0] * (2 * MOD_WORDS - len(dados))
        with open(saida, "w", encoding="utf-8") as f:
            f.write(vhdl_portavel(prog, dados))
        print(f"{saida}: versao portavel; {sum(1 for w in prog if w)} instrucoes")
        return
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    modelo, prog_txt, data_txt, saida = sys.argv[1:]

    prog = le_dump(prog_txt, TEXT_BASE)
    dados = [] if data_txt == "-" else le_dump(data_txt, DATA_BASE)
    if len(prog) > PROG_WORDS:
        sys.exit(f"erro: o programa tem {len(prog)} palavras; a memoria de instrucoes so tem {PROG_WORDS}")
    prog += [0] * (PROG_WORDS - len(prog))

    with open(modelo, encoding="utf-8", errors="replace") as f:
        linhas = f.read().split("\n")

    n_mods = sum(1 for l in linhas if re.match(r"\s*entity\s+data_mem_mod\d+\s+is", l, re.I))
    if len(dados) > n_mods * MOD_WORDS:
        sys.exit(f"erro: os dados tem {len(dados) * 4} bytes; o modelo so tem {n_mods * MOD_BYTES}")
    dados += [0] * (n_mods * MOD_WORDS - len(dados))

    entidade, bloco = None, None
    trocas = 0
    for i, l in enumerate(linhas):
        m = re.match(r"\s*entity\s+(\w+)\s+is", l, re.I)
        if m:
            entidade, bloco = m.group(1).lower(), None
            continue
        m = re.match(r"\s*block_(\d)\s*:", l)
        if m:
            bloco = int(m.group(1))
            continue
        m = re.match(r'(\s*INIT_([0-9A-Fa-f]{2})\s*=>\s*X")([0-9A-Fa-f]{64})(".*)', l)
        if not m or l.lstrip().startswith("--"):
            continue
        linha_init = int(m.group(2), 16)
        if entidade == "program_memory":
            novo = init_hex(prog[8 * linha_init: 8 * linha_init + 8], 4)
        elif entidade and entidade.startswith("data_mem_mod") and bloco is not None:
            mod = int(entidade[len("data_mem_mod"):])
            ini = mod * MOD_WORDS + 32 * linha_init
            novo = init_hex([(w >> (8 * bloco)) & 0xFF for w in dados[ini: ini + 32]], 1)
        else:
            continue
        linhas[i] = m.group(1) + novo + m.group(4)
        trocas += 1

    with open(saida, "w", encoding="utf-8") as f:
        f.write("\n".join(linhas))
    usadas = sum(1 for w in prog if w)
    print(f"{saida}: {trocas} linhas INIT escritas; {usadas} instrucoes; "
          f"{len([w for w in dados if w])} palavras de dados diferentes de zero")


if __name__ == "__main__":
    main()
