-- Exercicio 2: alarme do carro
-- toca se a porta estiver aberta (p) E o alarme ligado (l), OU se o botao de panico (b) for apertado
library ieee;
use ieee.std_logic_1164.all;

entity alarme is
  port ( p, l, b : in  std_logic;
         saida   : out std_logic );
end alarme;

architecture rtl of alarme is
begin
  saida <= (p and l) or b;
end rtl;
