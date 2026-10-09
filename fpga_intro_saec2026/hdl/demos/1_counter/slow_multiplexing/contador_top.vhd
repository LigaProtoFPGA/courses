-- Projeto 2: contador de 0 a 9999 no display de 7 segmentos (Nexys A7)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_top is
  port (
    CLK100MHZ : in  std_logic;
    seg       : out std_logic_vector(6 downto 0);  -- segmentos a..g, acendem com 0
    dp        : out std_logic;
    an        : out std_logic_vector(7 downto 0)   -- digitos, acendem com 0
  );
end contador_top;

architecture rtl of contador_top is
  -- DESAFIO 1: mude este valor para mudar a velocidade
  constant LIMITE : integer := 100_000_000;   -- 1 contagem por segundo

  signal divisor  : integer range 0 to LIMITE - 1 := 0;
  signal tick     : std_logic := '0';
  signal contagem : integer range 0 to 9999 := 0;
begin
  -- 1) divisor de clock: um pulso (tick) a cada LIMITE ciclos
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if divisor = LIMITE - 1 then
        divisor <= 0;
        tick    <= '1';
      else
        divisor <= divisor + 1;
        tick    <= '0';
      end if;
    end if;
  end process;

  -- 2) contador
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if tick = '1' then
        if contagem = 9999 then
          contagem <= 0;
        else
          contagem <= contagem + 1;
        end if;
      end if;
    end if;
  end process;

  -- 3) display: converte para decimal e acende os 4 digitos da direita
  u_display : entity work.display4
    port map ( clk => CLK100MHZ, valor => contagem, pontos => "0000",
               seg => seg, dp => dp, an => an );
end rtl;
