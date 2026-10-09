-- Debounce: espera o botao ficar estavel e gera UM pulso por aperto
library ieee;
use ieee.std_logic_1164.all;

entity debounce is
  generic ( ESTAVEL : integer := 1_000_000 );   -- 10 ms a 100 MHz
  port ( clk   : in  std_logic;
         botao : in  std_logic;
         pulso : out std_logic );
end debounce;

architecture rtl of debounce is
  signal s1, s2           : std_logic := '0';
  signal limpo, limpo_ant : std_logic := '0';
  signal cont             : integer range 0 to ESTAVEL - 1 := 0;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      s1 <= botao;                -- sincroniza o botao com o clock
      s2 <= s1;
      if s2 = limpo then
        cont <= 0;
      elsif cont = ESTAVEL - 1 then
        limpo <= s2;              -- ficou estavel por 10 ms: aceita
        cont  <= 0;
      else
        cont <= cont + 1;
      end if;
      limpo_ant <= limpo;
    end if;
  end process;

  pulso <= limpo and not limpo_ant;   -- '1' por um ciclo quando o botao e apertado
end rtl;
