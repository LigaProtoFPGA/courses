-- ============================================================
-- top_cron_dec_a7 -> adaptacao do cronometro regressivo para a Nexys A7
--
-- So liga o cron_dec original aos pinos da Nexys A7.
-- Mudancas em relacao a Nexys 2: clock de 100 MHz (constantes ajustadas
-- em Contador.vhd e DsplDrv.vhd), reset no CPU RESET (ativo em 0) e
-- os 4 digitos da esquerda do display apagados.
--
-- Botoes: BTNR = carga, BTNC = conta. Chaves SW6..SW0 = minutos (0 a 99).
-- LED0 acende quando a contagem termina.
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_cron_dec_a7 is
    port (
        CLK100MHZ  : in  std_logic;
        CPU_RESETN : in  std_logic;                      -- ativo em 0
        BTNR       : in  std_logic;                      -- carga
        BTNC       : in  std_logic;                      -- conta
        SW         : in  std_logic_vector (6 downto 0);
        LED        : out std_logic_vector (0 downto 0);
        dec_ddp    : out std_logic_vector (7 downto 0);
        an         : out std_logic_vector (7 downto 0)
    );
end top_cron_dec_a7;

architecture Behavioral of top_cron_dec_a7 is
    signal reset : std_logic;
begin
    reset <= not CPU_RESETN;

    i_cron : entity work.cron_dec
        port map(
            clock   => CLK100MHZ,
            reset   => reset,
            carga   => BTNR,
            conta   => BTNC,
            chaves  => SW,
            parado  => LED(0),
            an      => an(3 downto 0),
            dec_ddp => dec_ddp);

    an(7 downto 4) <= "1111";
end Behavioral;
