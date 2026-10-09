library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cron_basq_PI_tb is
end cron_basq_PI_tb;

architecture tb of cron_basq_PI_tb is
    signal clock : std_logic := '0';
    signal reset, para_continua, modo_novoquarto, carga : std_logic;
    signal c_quarto     : std_logic_vector(1 downto 0);
    signal c_minutos    : std_logic_vector(3 downto 0);
    signal c_segundos   : std_logic_vector(5 downto 0);
    signal c_centesimos : std_logic_vector(6 downto 0);
    signal quarto       : std_logic_vector(1 downto 0);
    signal minutos      : std_logic_vector(3 downto 0);
    signal segundos     : std_logic_vector(5 downto 0);
    signal centesimos   : std_logic_vector(6 downto 0);
begin
    -- esse tb testa so o basico: carrega um tempo e conta
    -- (nao testa troca de quarto nem o fim de jogo no Q4)
    clock <= not clock after 10 ns;        -- periodo 20ns

    reset           <= '1', '0' after 73 ns;
    modo_novoquarto <= '0';                -- solto no reset -> modo FIBA

    -- o que vai ser carregado: Q2, 2 min, 0 seg, 2 cent
    c_quarto     <= "01";
    c_minutos    <= "0010";
    c_segundos   <= "000000";
    c_centesimos <= "0000010";

    -- CARGA enquanto parado (idle, depois do reset)
    carga         <= '0', '1' after 120 ns, '0' after 140 ns;
    -- START depois da carga
    para_continua <= '0', '1' after 200 ns, '0' after 220 ns;

    uut : entity work.cron_basq_PI
        generic map ( MAXCOUNT => 5 )      -- baixo so pra contar rapido na sim
        port map (
            clock=>clock, reset=>reset,
            para_continua=>para_continua, modo_novoquarto=>modo_novoquarto, carga=>carga,
            c_quarto=>c_quarto, c_minutos=>c_minutos,
            c_segundos=>c_segundos, c_centesimos=>c_centesimos,
            quarto=>quarto, minutos=>minutos,
            segundos=>segundos, centesimos=>centesimos);
end tb;