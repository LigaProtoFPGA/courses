library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity tb_cron_dec is
end tb_cron_dec;
architecture tb_cron_dec of tb_cron_dec is
signal clock : std_logic := '1';
signal reset, carga, conta, parado : std_logic;
signal chaves: std_logic_vector(6 downto 0);
begin
clock <= not clock after 10 ns;
reset <= '1', '0' after 73 ns;
carga <= '0', '1' after 133 ns, '0' after 425 ns;
conta <= '0', '1' after 543 ns, '0' after 925 ns;
chaves <= "0000101";
uut : entity work.cron_dec
generic map ( CLOCK_FREQ => 4 ) -- para simulação utilizar um divisor menor que 25.000.000
port map (
clock => clock,
reset => reset,
carga => carga,
conta => conta,
chaves => chaves,
parado => parado,
an => open, -- Não é necessário na simulação ver an e dec_ddp, sua interpretação
dec_ddp => open); -- em binário é difícil. Usem a palavra chave open do VHDL
end tb_cron_dec; -- para deixar estes pinos em aberto, ou seja, desconectados