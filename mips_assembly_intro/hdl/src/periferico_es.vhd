-- =====================================================================
-- periferico_es.vhd  -  E/S mapeada em memoria para o MIPS_S na Nexys A7
-- Liga ProtoFPGA - Encontro 6 "Do simulador ao silicio"
--
-- O processador nao sabe o que e um botao ou um LED: ele so faz lw e sw.
-- Este bloco "atende" tres enderecos fora da memoria de dados:
--   0xFFFF0000  leitura : botoes  (bit0=C, 1=U, 2=L, 3=R, 4=D)
--   0xFFFF0004  leitura : chaves  (bits 15..0 = SW15..SW0)
--   0xFFFF0008  escrita : LEDs    (bits 15..0 = LED15..LED0)
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use work.p_MIPS_S.all;

entity periferico_es is
  port(
    clock, reset  : in  std_logic;
    -- barramento de dados que sai do MIPS_S_withBRAMs
    ce, rw        : in  std_logic;              -- rw='1' le, rw='0' escreve
    endereco      : in  wires32;
    dado_cpu      : in  wires32;                -- valor do sw
    dado_per      : out wires32;                -- valor que o lw recebe
    -- pinos da placa
    botoes        : in  std_logic_vector(4 downto 0);
    chaves        : in  std_logic_vector(15 downto 0);
    leds          : out std_logic_vector(15 downto 0)
  );
end periferico_es;

architecture comportamento of periferico_es is
  signal b1, b2 : std_logic_vector(4 downto 0);   -- 2 flip-flops por sinal
  signal c1, c2 : std_logic_vector(15 downto 0);  -- (sincronizacao)
  signal reg_leds : std_logic_vector(15 downto 0);
begin

  -- botoes e chaves mudam a qualquer momento; passar por 2 flip-flops
  -- evita que o processador leia um valor "no meio da troca"
  sincroniza: process(clock)
  begin
    if rising_edge(clock) then
      b1 <= botoes;  b2 <= b1;
      c1 <= chaves;  c2 <= c1;
    end if;
  end process;

  -- lw: escolhe o que devolver conforme o endereco
  dado_per <= x"000000" & "000" & b2 when endereco = x"FFFF0000" else
              x"0000" & c2           when endereco = x"FFFF0004" else
              (others => '0');

  -- sw em 0xFFFF0008: guarda os 16 bits de baixo no registrador dos LEDs
  -- (borda de descida, como as memorias do MIPS_S_withBRAMs)
  escreve_leds: process(clock, reset)
  begin
    if reset = '1' then
      reg_leds <= (others => '0');
    elsif falling_edge(clock) then
      if ce = '1' and rw = '0' and endereco = x"FFFF0008" then
        reg_leds <= dado_cpu(15 downto 0);
      end if;
    end if;
  end process;

  leds <= reg_leds;
end comportamento;
