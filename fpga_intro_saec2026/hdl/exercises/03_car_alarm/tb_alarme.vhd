-- Testbench do alarme: os 6 instantes do Exercicio 4 (so simulacao)
library ieee;
use ieee.std_logic_1164.all;

entity tb_alarme is
end tb_alarme;

architecture sim of tb_alarme is
  signal p, l, b, saida : std_logic := '0';
  type vetor6 is array (1 to 6) of std_logic;
  constant VP : vetor6 := ('0','1','1','1','0','0');
  constant VL : vetor6 := ('0','0','1','1','1','0');
  constant VB : vetor6 := ('0','0','0','1','0','1');
  constant ESPERADO : vetor6 := ('0','0','1','1','0','1');
begin
  uut : entity work.alarme port map ( p => p, l => l, b => b, saida => saida );

  process
  begin
    for i in 1 to 6 loop
      p <= VP(i); l <= VL(i); b <= VB(i);
      wait for 10 ns;
      assert saida = ESPERADO(i)
        report "Instante " & integer'image(i) & ": saida errada" severity error;
    end loop;
    report "Simulacao terminou" severity note;
    wait;
  end process;
end sim;
