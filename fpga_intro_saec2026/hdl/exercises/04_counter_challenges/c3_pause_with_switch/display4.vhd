-- Mostra um numero de 0 a 9999 nos 4 digitos da direita do display (Nexys A7)
-- Segmentos e digitos acendem com 0. seg(6) = segmento a ... seg(0) = segmento g
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display4 is
  generic ( REFRESH : integer := 100_000 );       -- ciclos por digito (100.000 = 1 ms)
  port (
    clk    : in  std_logic;
    valor  : in  integer range 0 to 9999;
    pontos : in  std_logic_vector(3 downto 0);    -- '1' acende o ponto daquele digito
    seg    : out std_logic_vector(6 downto 0);
    dp     : out std_logic;
    an     : out std_logic_vector(7 downto 0)
  );
end display4;

architecture rtl of display4 is
  type digitos_t is array (0 to 3) of integer range 0 to 9;
  signal digitos      : digitos_t := (others => 0);
  signal shift        : unsigned(29 downto 0) := (others => '0');  -- 16 bits decimais + 14 bits binarios
  signal passo        : integer range 0 to 14 := 0;
  signal cont_refresh : integer range 0 to REFRESH - 1 := 0;
  signal sel          : integer range 0 to 3 := 0;
  signal atual        : integer range 0 to 9;
begin
  -- 1) binario -> decimal ("double dabble"), um bit por ciclo de clock
  process(clk)
    variable v : unsigned(29 downto 0);
  begin
    if rising_edge(clk) then
      if passo = 0 then
        shift <= resize(to_unsigned(valor, 14), 30);
        passo <= 1;
      else
        v := shift;
        for i in 0 to 3 loop
          if v(17 + 4*i downto 14 + 4*i) >= 5 then
            v(17 + 4*i downto 14 + 4*i) := v(17 + 4*i downto 14 + 4*i) + 3;
          end if;
        end loop;
        v := v(28 downto 0) & '0';
        shift <= v;
        if passo = 14 then
          for i in 0 to 3 loop
            digitos(i) <= to_integer(v(17 + 4*i downto 14 + 4*i));
          end loop;
          passo <= 0;
        else
          passo <= passo + 1;
        end if;
      end if;
    end if;
  end process;

  -- 2) multiplexacao: um digito aceso por vez, trocando a cada REFRESH ciclos
  process(clk)
  begin
    if rising_edge(clk) then
      if cont_refresh = REFRESH - 1 then
        cont_refresh <= 0;
        if sel = 3 then
          sel <= 0;
        else
          sel <= sel + 1;
        end if;
      else
        cont_refresh <= cont_refresh + 1;
      end if;
    end if;
  end process;

  with sel select an <=
    "11111110" when 0,        -- AN0: digito da direita
    "11111101" when 1,
    "11111011" when 2,
    "11110111" when others;   -- AN3; AN4 a AN7 ficam apagados

  atual <= digitos(sel);
  dp    <= not pontos(sel);

  -- 3) decodificador: digito -> segmentos "abcdefg" (0 = aceso)
  with atual select seg <=
    "0000001" when 0,
    "1001111" when 1,
    "0010010" when 2,
    "0000110" when 3,
    "1001100" when 4,
    "0100100" when 5,
    "0100000" when 6,
    "0001111" when 7,
    "0000000" when 8,
    "0000100" when others;    -- 9
end rtl;
