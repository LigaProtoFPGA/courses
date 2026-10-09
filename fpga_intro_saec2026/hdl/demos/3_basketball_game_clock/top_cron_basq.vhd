-- ============================================================
-- top_cron_basq -> modulo de cima, instancia e liga os fios
--
-- a logica do cronometro ta na PI (cron_basq_PI).
-- aqui fica o que depende da placa: debounce, conversao BCD e display.
--
-- entradas fisicas da placa:
--   clock, reset, carga, para_continua, modo_novoquarto
--   c_quartos(1:0), c_minutos(3:0), c_segundos(1:0)
--   obs: c_segundos chega com so 2 bits, a conversao pro valor aqui
--        "00"->0s  "01"->15s  "10"->30s  "11"->45s
--
-- saidas fisicas da placa:
--   dec_ddp(7:0)  -> segmentos do display
--   an(3:0)       -> anodos do display multiplexado
--   quartos(3:0)  -> 4 LEDs em 1-hot (um por quarto)
--   mins(3:0)     -> 4 LEDs em binario (minutos)
--
-- clock = 50MHz 
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_cron_basq is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;

        -- botoes de controle
        carga           : in  std_logic;
        para_continua   : in  std_logic;
        modo_novoquarto : in  std_logic;

        -- switches de carga de tempo
        c_quartos    : in  std_logic_vector (1 downto 0);  -- quarto a carregar
        c_minutos    : in  std_logic_vector (3 downto 0);  -- minutos a carregar
        c_segundos   : in  std_logic_vector (1 downto 0);  -- 2 chaves, convertido aqui
   --     c_centesimos : in  std_logic_vector (6 downto 0);  -- nao existe nessa placa, entra 0 fixo

        -- display multiplexado
        dec_ddp : out std_logic_vector (7 downto 0);  -- segmentos 
        an      : out std_logic_vector (3 downto 0);  -- anodos

        -- LEDs
        quartos : out std_logic_vector (3 downto 0);  -- 1-hot: bit0=Q1 bit1=Q2 bit2=Q3 bit3=Q4
        mins    : out std_logic_vector (3 downto 0)   -- minutos em binario
    );
end top_cron_basq;

architecture Behavioral of top_cron_basq is

    -- fios entre o debounce e a PI
    signal carga_db         : std_logic;
    signal para_continua_db : std_logic;

    -- saidas cruas da PI (binario, antes do BCD)
    signal pi_quarto     : std_logic_vector (1 downto 0);
    signal pi_minutos    : std_logic_vector (3 downto 0);
    signal pi_segundos   : std_logic_vector (5 downto 0);
    signal pi_centesimos : std_logic_vector (6 downto 0);

    -- c_segundos depois de converter (2 chaves -> 6 bits)
    signal c_segundos_conv : std_logic_vector (5 downto 0);

    -- sinais BCD de segundos e centesimos
    signal segundos_BCD   : std_logic_vector (7 downto 0);
    signal centesimos_BCD : std_logic_vector (7 downto 0);

    signal d0_s, d1_s, d2_s, d3_s : std_logic_vector (5 downto 0);

    type ROM is array (0 to 127) of std_logic_vector (7 downto 0);
    constant conv_to_BCD : ROM:=(
    "00000000", "00000001", "00000010", "00000011", "00000100", -- 00-04
    "00000101", "00000110", "00000111", "00001000", "00001001", -- 05-09
    "00010000", "00010001", "00010010", "00010011", "00010100", -- 10-19
    "00010101", "00010110", "00010111", "00011000", "00011001",
    "00100000", "00100001", "00100010", "00100011", "00100100", -- 20-29
    "00100101", "00100110", "00100111", "00101000", "00101001",
    "00110000", "00110001", "00110010", "00110011", "00110100", -- 30-39
    "00110101", "00110110", "00110111", "00111000", "00111001",
    "01000000", "01000001", "01000010", "01000011", "01000100", -- 40-49
    "01000101", "01000110", "01000111", "01001000", "01001001",
    "01010000", "01010001", "01010010", "01010011", "01010100", -- 50-59
    "01010101", "01010110", "01010111", "01011000", "01011001",
    "01100000", "01100001", "01100010", "01100011", "01100100", -- 60-69
    "01100101", "01100110", "01100111", "01101000", "01101001",
    "01110000", "01110001", "01110010", "01110011", "01110100", -- 70-79
    "01110101", "01110110", "01110111", "01111000", "01111001",
    "10000000", "10000001", "10000010", "10000011", "10000100", -- 80-89
    "10000101", "10000110", "10000111", "10001000", "10001001",
    "10010000", "10010001", "10010010", "10010011", "10010100", -- 90-99
    "10010101", "10010110", "10010111", "10011000", "10011001",
    "00000000", "00000000", "00000000", "00000000", "00000000", -- 100-109 (nao usa)
    "00000000", "00000000", "00000000", "00000000", "00000000",
    "00000000", "00000000", "00000000", "00000000", "00000000", -- 110-119
    "00000000", "00000000", "00000000", "00000000", "00000000",
    "00000000", "00000000", "00000000", "00000000", "00000000", -- 120-127
    "00000000", "00000000", "00000000");

begin

    -- debounce dos botoes (so carga e para_continua)
    -- modo_novoquarto NAO passa por debounce de proposito:
    --   o debounce segura a saida em '0' durante o reset, e o FF de modo
    --   precisa ler o botao bem no reset. entao ele entra cru na PI.
    i_deb_carga : entity work.Debounce
        port map(clock => clock,
                 reset => reset,
                 key    => carga,      -- fio cru, vindo do botao da placa
                 debkey => carga_db);  -- pulso limpo, vai pra PI

    i_deb_pc : entity work.Debounce
        port map(clock=>clock, reset=>reset, key=>para_continua, debkey=>para_continua_db);

    -- converte c_segundos (2 chaves) pro valor real:
    -- "00"->0s "01"->15s "10"->30s "11"->45s
    with c_segundos select
    c_segundos_conv <= "000000" when "00",  -- 0s
                       "001111" when "01",  -- 15
                       "011110" when "10",  -- 30
                       "101101" when others; -- 45

    -- instancia a cron_basq_PI ligando os fios
    i_cron : entity work.cron_basq_PI
        port map(
            clock=>clock, reset=>reset,
            para_continua=>para_continua_db,
            modo_novoquarto=>modo_novoquarto,   -- cru de proposito (ver comentario do debounce)
            carga=>carga_db,
            c_quarto=>c_quartos, c_minutos=>c_minutos,
            c_segundos=>c_segundos_conv, c_centesimos => "0000000",  -- cent sempre carrega 0
            quarto=>pi_quarto, minutos=>pi_minutos,
            segundos=>pi_segundos, centesimos=>pi_centesimos);

    -- converte o quarto (2 bits) pra 1-hot nos 4 LEDs
    with pi_quarto select
    quartos <= "0001" when "00",  -- Q1 = LD4
               "0010" when "01",  -- Q2
               "0100" when "10",  -- Q3
               "1000" when others; -- Q4

    -- binario -> BCD (ROM) e monta os 4 digitos do display
	 segundos_BCD   <= conv_to_BCD(CONV_INTEGER(pi_segundos));
    centesimos_BCD <= conv_to_BCD(CONV_INTEGER(pi_centesimos));

    d3_s <= '1' & segundos_BCD(7 downto 4)   & '1';  -- dezena seg
    d2_s <= '1' & segundos_BCD(3 downto 0)   & '1';  -- unidade seg
    d1_s <= '1' & centesimos_BCD(7 downto 4) & '1';  -- dezena cent
    d0_s <= '1' & centesimos_BCD(3 downto 0) & '1';  -- unidade cent

    i_dspl : entity work.dspl_drv
        port map(
            clock=>clock, reset=>reset,
            d3=>d3_s, d2=>d2_s, d1=>d1_s, d0=>d0_s,
            an=>an, dec_ddp=>dec_ddp);

    -- minutos vai direto nos LEDs, ja ta em binario
    mins <= pi_minutos;

end Behavioral;