-- Exercicio 3: o que cada linha faz na placa? (Nexys A7)
library ieee;
use ieee.std_logic_1164.all;

entity prever is
  port ( sw  : in  std_logic_vector(15 downto 0);
         led : out std_logic_vector(15 downto 0) );
end prever;

architecture rtl of prever is
begin
  led(0) <= not sw(0);         -- acende com a chave 0 DESLIGADA
  led(1) <= sw(1) and sw(2);   -- acende so com as chaves 1 e 2 ligadas
  led(2) <= sw(3) or sw(4);    -- acende com a chave 3 ou a 4 ligada
  led(3) <= '1';               -- sempre aceso
  led(15 downto 4) <= (others => '0');
end rtl;
