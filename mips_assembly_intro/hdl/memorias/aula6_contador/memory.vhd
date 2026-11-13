-- memory.vhd gerado por gera_memory.py --portavel (Liga ProtoFPGA)
-- Mesmas entidades e portas do memory.vhd do le_mars, em VHDL sem primitivas.
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity program_memory is
    port( clock: in std_logic;
          address: in std_logic_vector(8 downto 0);
          instruction: out std_logic_vector(31 downto 0));
end program_memory;

architecture program_memory of program_memory is
    type rom_t is array(0 to 511) of std_logic_vector(31 downto 0);
    constant rom : rom_t := (0 => x"3c17ffff", 1 => x"24100000", 2 => x"02002021", 3 => x"0c100027", 4 => x"0c100019", 5 => x"30480002", 6 => x"11000001", 7 => x"26100001", 8 => x"30480010", 9 => x"11000001", 10 => x"2610ffff", 11 => x"30480004", 12 => x"11000001", 13 => x"00108040", 14 => x"30480008", 15 => x"11000001", 16 => x"00108042", 17 => x"30480001", 18 => x"11000002", 19 => x"0c100025", 20 => x"00408021", 21 => x"3210ffff", 22 => x"02002021", 23 => x"0c100027", 24 => x"08100004", 25 => x"8ee80000", 26 => x"1100fffe", 27 => x"01001021", 28 => x"3c090004", 29 => x"2529ffff", 30 => x"1520fffe", 31 => x"8ee80000", 32 => x"1500fffe", 33 => x"3c090004", 34 => x"2529ffff", 35 => x"1520fffe", 36 => x"03e00008", 37 => x"8ee20004", 38 => x"03e00008", 39 => x"aee40008", 40 => x"03e00008", others => (others => '0'));
begin
    process(clock)
    begin
        if rising_edge(clock) then
            instruction <= rom(to_integer(unsigned(address)));
        end if;
    end process;
end program_memory;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity data_mem_mod0 is
    port( clock, ce, we, bw: in std_logic;
          address: in std_logic_vector(10 downto 0);
          byte_choice: in std_logic_vector(1 downto 0);
          data_in: in std_logic_vector(31 downto 0);
          data_out: out std_logic_vector(31 downto 0));
end data_mem_mod0;

architecture data_mem_mod0 of data_mem_mod0 is
    type ram_t is array(0 to 2047) of std_logic_vector(7 downto 0);
    signal mem0 : ram_t := (others => (others => '0'));
    signal mem1 : ram_t := (others => (others => '0'));
    signal mem2 : ram_t := (others => (others => '0'));
    signal mem3 : ram_t := (others => (others => '0'));
    signal we3, we2, we1, we0 : std_logic;
    signal d3, d2, d1, d0 : std_logic_vector(7 downto 0);
begin
    we3 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="11"))) else '0';
    we2 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="10"))) else '0';
    we1 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="01"))) else '0';
    we0 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="00"))) else '0';
    d3 <= data_in(7 downto 0) when bw='1' else data_in(31 downto 24);
    d2 <= data_in(7 downto 0) when bw='1' else data_in(23 downto 16);
    d1 <= data_in(7 downto 0) when bw='1' else data_in(15 downto 8);
    d0 <= data_in(7 downto 0);

    -- um processo por bloco de bytes, como as 4 BRAMs do original (escrita: write-first)
    p3: process(clock) begin if rising_edge(clock) then
        if we3='1' then mem3(to_integer(unsigned(address))) <= d3; data_out(31 downto 24) <= d3;
        else data_out(31 downto 24) <= mem3(to_integer(unsigned(address))); end if; end if; end process;
    p2: process(clock) begin if rising_edge(clock) then
        if we2='1' then mem2(to_integer(unsigned(address))) <= d2; data_out(23 downto 16) <= d2;
        else data_out(23 downto 16) <= mem2(to_integer(unsigned(address))); end if; end if; end process;
    p1: process(clock) begin if rising_edge(clock) then
        if we1='1' then mem1(to_integer(unsigned(address))) <= d1; data_out(15 downto 8) <= d1;
        else data_out(15 downto 8) <= mem1(to_integer(unsigned(address))); end if; end if; end process;
    p0: process(clock) begin if rising_edge(clock) then
        if we0='1' then mem0(to_integer(unsigned(address))) <= d0; data_out(7 downto 0) <= d0;
        else data_out(7 downto 0) <= mem0(to_integer(unsigned(address))); end if; end if; end process;
end data_mem_mod0;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity data_mem_mod1 is
    port( clock, ce, we, bw: in std_logic;
          address: in std_logic_vector(10 downto 0);
          byte_choice: in std_logic_vector(1 downto 0);
          data_in: in std_logic_vector(31 downto 0);
          data_out: out std_logic_vector(31 downto 0));
end data_mem_mod1;

architecture data_mem_mod1 of data_mem_mod1 is
    type ram_t is array(0 to 2047) of std_logic_vector(7 downto 0);
    signal mem0 : ram_t := (others => (others => '0'));
    signal mem1 : ram_t := (others => (others => '0'));
    signal mem2 : ram_t := (others => (others => '0'));
    signal mem3 : ram_t := (others => (others => '0'));
    signal we3, we2, we1, we0 : std_logic;
    signal d3, d2, d1, d0 : std_logic_vector(7 downto 0);
begin
    we3 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="11"))) else '0';
    we2 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="10"))) else '0';
    we1 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="01"))) else '0';
    we0 <= '1' when (ce='1' and we='0' and ((bw='0') or (bw='1' and byte_choice="00"))) else '0';
    d3 <= data_in(7 downto 0) when bw='1' else data_in(31 downto 24);
    d2 <= data_in(7 downto 0) when bw='1' else data_in(23 downto 16);
    d1 <= data_in(7 downto 0) when bw='1' else data_in(15 downto 8);
    d0 <= data_in(7 downto 0);

    -- um processo por bloco de bytes, como as 4 BRAMs do original (escrita: write-first)
    p3: process(clock) begin if rising_edge(clock) then
        if we3='1' then mem3(to_integer(unsigned(address))) <= d3; data_out(31 downto 24) <= d3;
        else data_out(31 downto 24) <= mem3(to_integer(unsigned(address))); end if; end if; end process;
    p2: process(clock) begin if rising_edge(clock) then
        if we2='1' then mem2(to_integer(unsigned(address))) <= d2; data_out(23 downto 16) <= d2;
        else data_out(23 downto 16) <= mem2(to_integer(unsigned(address))); end if; end if; end process;
    p1: process(clock) begin if rising_edge(clock) then
        if we1='1' then mem1(to_integer(unsigned(address))) <= d1; data_out(15 downto 8) <= d1;
        else data_out(15 downto 8) <= mem1(to_integer(unsigned(address))); end if; end if; end process;
    p0: process(clock) begin if rising_edge(clock) then
        if we0='1' then mem0(to_integer(unsigned(address))) <= d0; data_out(7 downto 0) <= d0;
        else data_out(7 downto 0) <= mem0(to_integer(unsigned(address))); end if; end if; end process;
end data_mem_mod1;
