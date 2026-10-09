-- Projeto 3: cronometro com maquina de estados (Nexys A7)
-- Mostra SS.cc (segundos e centesimos). BTNC = start, BTNU = pause, BTND = reset.
library ieee;
use ieee.std_logic_1164.all;

entity cronometro_top is
  port (
    CLK100MHZ : in  std_logic;
    BTNC      : in  std_logic;   -- start
    BTNU      : in  std_logic;   -- pause
    BTND      : in  std_logic;   -- reset
    seg       : out std_logic_vector(6 downto 0);
    dp        : out std_logic;
    an        : out std_logic_vector(7 downto 0)
  );
end cronometro_top;

architecture rtl of cronometro_top is
  constant LIMITE : integer := 1_000_000;          -- 10 ms = 1 centesimo de segundo

  type estado_t is (PARADO, CONTANDO, PAUSADO);
  signal estado : estado_t := PARADO;

  signal divisor  : integer range 0 to LIMITE - 1 := 0;
  signal tick     : std_logic := '0';
  signal contagem : integer range 0 to 9999 := 0;  -- em centesimos
  signal p_start, p_pause, p_reset : std_logic;
begin
  u_start : entity work.debounce port map ( clk => CLK100MHZ, botao => BTNC, pulso => p_start );
  u_pause : entity work.debounce port map ( clk => CLK100MHZ, botao => BTNU, pulso => p_pause );
  u_reset : entity work.debounce port map ( clk => CLK100MHZ, botao => BTND, pulso => p_reset );

  -- divisor de clock: um tick a cada 10 ms
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if divisor = LIMITE - 1 then
        divisor <= 0;
        tick    <= '1';
      else
        divisor <= divisor + 1;
        tick    <= '0';
      end if;
    end if;
  end process;

  -- maquina de estados
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if p_reset = '1' then                 -- reset vale em qualquer estado
        estado   <= PARADO;
        contagem <= 0;
      else
        case estado is
          when PARADO =>
            if p_start = '1' then
              estado <= CONTANDO;
            end if;

          when CONTANDO =>
            if p_pause = '1' then
              estado <= PAUSADO;
            elsif tick = '1' then
              if contagem = 9999 then
                contagem <= 0;
              else
                contagem <= contagem + 1;
              end if;
            end if;

          when PAUSADO =>
            if p_pause = '1' or p_start = '1' then
              estado <= CONTANDO;
            end if;
        end case;
      end if;
    end if;
  end process;

  -- ponto aceso no digito 2: SS.cc
  u_display : entity work.display4
    port map ( clk => CLK100MHZ, valor => contagem, pontos => "0100",
               seg => seg, dp => dp, an => an );
end rtl;
