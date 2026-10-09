library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
entity cron_dec is

generic (
        CLOCK_FREQ : integer := 50000000 -- Nexys A7: 100MHz (era 25000000 para 50MHz)
    );

	port (
		clock: in STD_LOGIC;
		reset: in STD_LOGIC;
		carga: in STD_LOGIC;
		conta: in STD_LOGIC;
		chaves: in STD_LOGIC_VECTOR (6 downto 0); -- so preciso de 7, mais seria desnecessario  0 - 99
		parado: out STD_LOGIC;
		an: out STD_LOGIC_VECTOR (3 downto 0);
		dec_ddp: out STD_LOGIC_VECTOR (7 downto 0)
	);

end cron_dec;

architecture cron_dec of cron_dec is

type STATES is (S0, S1, S2); -- tipo enumerado
signal scurrent, snext: STATES;

signal mins : integer range 0 to 99; -- minutos de 0 a 99 -- mantemos o inteiro pq em hexa ele converte certo no tb
signal secs : integer range 0 to 59; -- segundos de 0 a 59 

signal ck_1Hz: std_logic;
signal d0, d1, d2, d3: STD_LOGIC_VECTOR (5 downto 0);

signal Minutos_BCD, Segundos_BCD: STD_LOGIC_VECTOR (7 downto 0);

type ROM is array (0 to 99) of std_logic_vector (7 downto 0);
constant conv_to_BCD : ROM:=(
 "00000000", "00000001", "00000010", "00000011", "00000100",
 "00000101", "00000110", "00000111", "00001000", "00001001",
 "00010000", "00010001", "00010010", "00010011", "00010100",
 "00010101", "00010110", "00010111", "00011000", "00011001",
 "00100000", "00100001", "00100010", "00100011", "00100100",
 "00100101", "00100110", "00100111", "00101000", "00101001",
 "00110000", "00110001", "00110010", "00110011", "00110100",
 "00110101", "00110110", "00110111", "00111000", "00111001",
 "01000000", "01000001", "01000010", "01000011", "01000100",
 "01000101", "01000110", "01000111", "01001000", "01001001",
 "01010000", "01010001", "01010010", "01010011", "01010100",
 "01010101", "01010110", "01010111", "01011000", "01011001",
 "01100000", "01100001", "01100010", "01100011", "01100100",
 "01100101", "01100110", "01100111", "01101000", "01101001",
 "01110000", "01110001", "01110010", "01110011", "01110100",
 "01110101", "01110110", "01110111", "01111000", "01111001",
 "10000000", "10000001", "10000010", "10000011", "10000100",
 "10000101", "10000110", "10000111", "10001000", "10001001",
 "10010000", "10010001", "10010010", "10010011", "10010100",
 "10010101", "10010110", "10010111", "10011000", "10011001");

begin

Ck1Hz_gen:  -- process gerador do clock de 1hz
	process (reset, clock)
	variable count_25M: integer range 0 to CLOCK_FREQ;
	
	begin
		if reset='1' then
			count_25M := 0;
			ck_1Hz <= '0';
		elsif (clock'event and clock='1') then
			count_25M := count_25M + 1;
			if (count_25M = CLOCK_FREQ - 1) then
				count_25M := 0;
				ck_1Hz <= not ck_1Hz;
			end if;
		end if;
	end process;

control: process(ck_1Hz, reset)
 begin
	 if reset='1'
	 then scurrent <= S0; parado <='0';
	 
	 elsif ck_1Hz'event and ck_1Hz='1'
	 then scurrent <= snext; if snext = S1 then parado <= '0'; elsif mins = 0 and secs = 1 then parado <=  '1'; end if; -- mudei aqui passei o parado pra ca
 end if;
 end process;
 
combinational: process(scurrent, secs, mins, carga, conta) 
 begin
	 case scurrent is
	 
		 when S0 => -- idle
		 
		 -- aqui nao zera o parado pq fala pra so zerar dps de carregar um novo valor, fica aqui ate load ser apertado
		 
			if carga ='0' then snext<=S0; else snext <= S1; end if;
			
		 when S1 =>  -- load
			
			-- process separado funciona com isso, quando for s1, faz a carga do valor das chaves
			
			if conta= '0' then snext<=S1; else snext <= S2; end if;
			
		 when S2 =>  -- count 
		 
			-- aqui o process counter pega o valor do mins e comeca a decrementar ate 0, quando for 0 acende led e volta pra idle
			
			if secs= 0 and mins= 0  then snext<=S0; else snext <= S2; end if;
			
	end case;
 end process;

counter: process(reset, ck_1Hz) -- chaves com valor em bin tem q ser transferido pra int e decrementar 1 a cada ciclo de clock
begin
	
	if reset = '1' then 
		mins <= 0;
		secs <= 0;
		
	elsif rising_edge(ck_1Hz) then 
	
		if scurrent = S1 then mins <= to_integer(unsigned(chaves)); secs <= 0;
	
		elsif scurrent = S2 then
		
			if secs > 0 then secs <= secs - 1; 
		
			elsif secs = 0 and mins > 0 then secs <= 59; mins <= mins - 1;
		
		end if;
	end if;
end if;	
	
end process; 

-- instanciação das ROMs
Segundos_BCD <= conv_to_BCD(secs);
Minutos_BCD <= conv_to_BCD(mins);

-- display driver
d0 <= '1' & Segundos_BCD(3 downto 0) & '1';
d1 <= '1' & Segundos_BCD(7 downto 4) & '1';
d2 <= '1' & Minutos_BCD(3 downto 0) & '1';
d3 <= '1' & Minutos_BCD(7 downto 4) & '1';


display_driver : entity work.dspl_drv port map (
		clock => clock,
		reset => reset,
		d3 => d3,
		d2 => d2,
		d1 => d1,
		d0 => d0,
		an => an,
		dec_ddp => dec_ddp
);

end cron_dec;

