-- =====================================================================
-- top_nexys_a7.vhd  -  o sistema inteiro na placa
-- Liga ProtoFPGA - Encontro 6 "Do simulador ao silicio"
--
-- Liga tres coisas: o clock/reset da placa, o MIPS_S_withBRAMs
-- (processador + memorias, com o programa do MARS dentro de memory.vhd)
-- e o periferico_es (botoes, chaves e LEDs).
-- Os nomes das portas sao os do arquivo Nexys-A7-100T-Master.xdc.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use work.p_MIPS_S.all;

entity top_nexys_a7 is
  port(
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;                     -- botao vermelho, ativo em 0
    BTNC, BTNU, BTNL, BTNR, BTND : in std_logic;
    SW         : in  std_logic_vector(15 downto 0);
    LED        : out std_logic_vector(15 downto 0)
  );
end top_nexys_a7;

architecture estrutura of top_nexys_a7 is
  signal clock, reset : std_logic := '0';
  signal ce, rw, bw   : std_logic;
  signal endereco, dado_cpu, dado_per, dado_ram : wires32;
  signal reset_cpu, suspend_ack : std_logic;
  signal botoes : std_logic_vector(4 downto 0);
begin

  -- 100 MHz / 2 = 50 MHz para o processador
  divide: process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      clock <= not clock;
    end if;
  end process;

  reset  <= not CPU_RESETN;
  botoes <= BTND & BTNR & BTNL & BTNU & BTNC;      -- bit4 .. bit0

  sistema: entity work.MIPS_S_withBRAMs
    port map(
      clock => clock, reset => reset,
      sel_CPU => '0', suspend => '0',             -- o processador manda
      ce_Per => '0', rw_Per => '1', bw_Per => '0',
      d_address_Per => (others => '0'),
      data_out_Per  => dado_per,                  -- o que o lw le fora da RAM
      reset_CPU => reset_cpu, suspend_ack => suspend_ack,
      ce_CPU => ce, rw_CPU => rw, bw_CPU => bw,
      d_address_CPU => endereco,
      data_out_CPU  => dado_cpu,
      data_out_RAM  => dado_ram
    );

  es: entity work.periferico_es
    port map(
      clock => clock, reset => reset,
      ce => ce, rw => rw, endereco => endereco,
      dado_cpu => dado_cpu, dado_per => dado_per,
      botoes => botoes, chaves => SW, leds => LED
    );
end estrutura;
