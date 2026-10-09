-- ============================================================
-- top_cron_basq_a7 -> adaptacao do cronometro de basquete para a Nexys A7
--
-- So liga o top original (top_cron_basq) aos pinos da Nexys A7.
-- Mudancas em relacao a Nexys 2:
--   * clock de 100 MHz (constantes ajustadas em cron_basq_PI, Debounce e DsplDrv)
--   * reset no botao CPU RESET, que e ativo em 0 (por isso o "not")
--   * o display da A7 tem 8 digitos: os 4 da esquerda ficam apagados
--
-- Botoes: BTNC = para/continua, BTNR = carga, BTNU = modo/novo quarto
-- Chaves: SW1..SW0 = segundos, SW5..SW2 = minutos, SW7..SW6 = quarto
-- LEDs:   LED3..LED0 = minutos, LED7..LED4 = quarto
-- ============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_cron_basq_a7 is
    port (
        CLK100MHZ  : in  std_logic;
        CPU_RESETN : in  std_logic;                      -- ativo em 0
        BTNC       : in  std_logic;                      -- para / continua
        BTNR       : in  std_logic;                      -- carga
        BTNU       : in  std_logic;                      -- modo (no reset) / novo quarto
        SW         : in  std_logic_vector (7 downto 0);
        LED        : out std_logic_vector (7 downto 0);
        dec_ddp    : out std_logic_vector (7 downto 0);  -- a b c d e f g, ponto
        an         : out std_logic_vector (7 downto 0)
    );
end top_cron_basq_a7;

architecture Behavioral of top_cron_basq_a7 is
    signal reset : std_logic;
begin
    reset <= not CPU_RESETN;

    i_top : entity work.top_cron_basq
        port map(
            clock           => CLK100MHZ,
            reset           => reset,
            carga           => BTNR,
            para_continua   => BTNC,
            modo_novoquarto => BTNU,
            c_quartos       => SW(7 downto 6),
            c_minutos       => SW(5 downto 2),
            c_segundos      => SW(1 downto 0),
            dec_ddp         => dec_ddp,
            an              => an(3 downto 0),
            quartos         => LED(7 downto 4),
            mins            => LED(3 downto 0));

    an(7 downto 4) <= "1111";   -- digitos da esquerda apagados
end Behavioral;
