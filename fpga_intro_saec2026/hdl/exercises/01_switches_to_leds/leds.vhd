-- Projeto 1: cada chave acende o LED correspondente (Nexys A7)
library ieee;
use ieee.std_logic_1164.all;

entity leds is
  port ( sw  : in  std_logic_vector(15 downto 0);
         led : out std_logic_vector(15 downto 0) );
end leds;

architecture rtl of leds is
begin
  led <= sw;
  -- demonstracao: troque a linha acima por
  -- led <= not sw;
end rtl;
