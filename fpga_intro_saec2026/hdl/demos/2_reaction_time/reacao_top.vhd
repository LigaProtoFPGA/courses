-- Desafio 4 (demonstracao): medir o tempo de reacao (Nexys A7)
-- BTNU comeca uma rodada. Depois de 2 s o LED0 acende; aperte BTNC o mais rapido possivel.
-- O display mostra o tempo de reacao em milissegundos.
library ieee;
use ieee.std_logic_1164.all;

entity reacao_top is
  port (
    CLK100MHZ : in  std_logic;
    BTNC      : in  std_logic;                     -- reagir
    BTNU      : in  std_logic;                     -- nova rodada
    LED       : out std_logic_vector(0 downto 0);  -- LED0
    seg       : out std_logic_vector(6 downto 0);
    dp        : out std_logic;
    an        : out std_logic_vector(7 downto 0)
  );
end reacao_top;

architecture rtl of reacao_top is
  constant CICLOS_MS : integer := 100_000;          -- 1 ms a 100 MHz
  constant ESPERA_MS : integer := 2000;             -- 2 s com o LED apagado

  type estado_t is (ESPERA, ACESO, MOSTRA);
  signal estado : estado_t := MOSTRA;

  signal div_ms        : integer range 0 to CICLOS_MS - 1 := 0;
  signal tick_ms       : std_logic := '0';
  signal ms            : integer range 0 to 9999 := 0;
  signal reagiu, nova  : std_logic;
begin
  u_btnc : entity work.debounce port map ( clk => CLK100MHZ, botao => BTNC, pulso => reagiu );
  u_btnu : entity work.debounce port map ( clk => CLK100MHZ, botao => BTNU, pulso => nova );

  -- pulso a cada 1 ms
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if div_ms = CICLOS_MS - 1 then
        div_ms  <= 0;
        tick_ms <= '1';
      else
        div_ms  <= div_ms + 1;
        tick_ms <= '0';
      end if;
    end if;
  end process;

  -- maquina de estados
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      case estado is
        when ESPERA =>                       -- LED apagado por 2 s
          if tick_ms = '1' then
            if ms = ESPERA_MS - 1 then
              ms     <= 0;
              estado <= ACESO;
            else
              ms <= ms + 1;
            end if;
          end if;

        when ACESO =>                        -- LED aceso, contando milissegundos
          if reagiu = '1' then
            estado <= MOSTRA;
          elsif tick_ms = '1' and ms < 9999 then
            ms <= ms + 1;
          end if;

        when MOSTRA =>                       -- display mostra o tempo
          if nova = '1' then
            ms     <= 0;
            estado <= ESPERA;
          end if;
      end case;
    end if;
  end process;

  LED(0) <= '1' when estado = ACESO else '0';

  u_display : entity work.display4
    port map ( clk => CLK100MHZ,
               valor => ms,
               pontos => "0000", seg => seg, dp => dp, an => an );
end rtl;
