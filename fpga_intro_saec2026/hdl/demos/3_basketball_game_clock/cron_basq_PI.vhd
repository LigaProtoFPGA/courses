-- ============================================================
-- cron_basq_PI  -> logica do cronometro
--
-- display, conversoes BCD e debounce estao no TOP
--
-- entra: clock, reset, os botoes de controle e os switches de carga
--        (carga e para_continua vem debounceados do top; modo_novoquarto vem cru)
-- sai:   quarto, minutos, segundos, centesimos crus em binario (o top converte)
--
-- clock: 50MHz -> 1 ciclo = 20ns, e 500000 ciclos = 1 centesimo
-- ============================================================

package cron_pkg is -- package pra interface obrigatoria funcionar, nao achei outro jeito de fazer..
    constant CKS_por_CENTESIMO : integer := 1000000; -- Nexys A7: 100MHz * 0,01s (era 500000 na Nexys 2)
end package cron_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cron_pkg.all;   -- <-- traz o CKS_por_CENTESIMO pra dentro

entity cron_basq_PI is
    generic (MAXCOUNT : integer := CKS_por_CENTESIMO);  -- ciclos de clock por centesimo
             -- na placa fica 500000, no tb coloquei 5 para simular rapido
    port (
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;

        -- botoes vindos do top
        para_continua   : in STD_LOGIC;  -- pausa / volta a contar (debounceado)
        modo_novoquarto : in STD_LOGIC;  -- no reset escolhe o modo; fora do reset avanca o quarto (cru, ver top)
        carga           : in STD_LOGIC;  -- carrega o tempo dos switches (debounceado)

        -- switches com o tempo a carregar (so olha quando carga='1')
        c_quarto     : in STD_LOGIC_VECTOR (1 downto 0); 
        c_minutos    : in STD_LOGIC_VECTOR (3 downto 0);  
        c_segundos   : in STD_LOGIC_VECTOR (5 downto 0);  
        c_centesimos : in STD_LOGIC_VECTOR (6 downto 0);

        -- saidas cruas em binario (o top converte pra BCD)
        quarto     : out STD_LOGIC_VECTOR (1 downto 0); -- top vira 1-hot nos 4 LEDs
        minutos    : out STD_LOGIC_VECTOR (3 downto 0); -- 4 LEDs em binario
        segundos   : out STD_LOGIC_VECTOR (5 downto 0); -- 2 displays (ROM BCD no top)
        centesimos : out STD_LOGIC_VECTOR (6 downto 0)  -- 2 displays (ROM BCD no top)
    );
end cron_basq_PI;

architecture Behavioral of cron_basq_PI is

    -- estados da fsm (o mode_set fica num process separado)
    type STATES is (mode_set, idle, count, stopped);
    signal scurrent, snext : STATES;

    -- contadores
    signal mins   : STD_LOGIC_VECTOR (3 downto 0);
    signal secs   : STD_LOGIC_VECTOR (5 downto 0);
    signal cent   : STD_LOGIC_VECTOR (6 downto 0);
    signal quarts : STD_LOGIC_VECTOR (1 downto 0); -- 00->Q1 01->Q2 10->Q3 11->Q4

    -- flags internas
    signal fim_quarto     : STD_LOGIC; -- '1' quando zera tudo (00min 00s 00cent)
    signal mode_selection : STD_LOGIC; -- '1'=FIBA, '0'=NBA (definido no reset)
    signal fim_jogo       : STD_LOGIC; -- '1' quando o Q4 acaba, trava o modo_novoquarto

begin

    -- --------------------------------------------------------
    -- guarda o estado atual na subida do clock; reset joga pro mode_set
    -- --------------------------------------------------------
    control : process(clock, reset)
    begin
        if reset = '1' then
            scurrent <= mode_set;
        elsif clock'event and clock = '1' then
            scurrent <= snext;
        end if;
    end process;

    -- --------------------------------------------------------
    -- mode_set num process separado -> recomendacao do prof rodrigo
    -- le o modo_novoquarto no reset pra escolher NBA ou FIBA
    -- --------------------------------------------------------
    process_mode_set : process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                if modo_novoquarto = '1' then
                    mode_selection <= '0';   -- apertado = NBA (12)
                else
                    mode_selection <= '1';   -- solto = FIBA (10) <- default
                end if;
            end if;
        end if;
    end process;

    -- --------------------------------------------------------
    -- parte combinacional: decide o snext a partir do estado atual
    -- --------------------------------------------------------
    combinational : process(scurrent, reset, secs, mins, cent,
                            para_continua, modo_novoquarto, carga, fim_quarto)
    begin
        case scurrent is

            when mode_set =>
                -- fica aqui enquanto o reset ta em '1'; soltou, vai pro idle
                if reset = '1' then
                    snext <= mode_set;
                else
                    snext <= idle;
                end if;

            when idle =>
                -- para_continua comeca a contar, mas so se o quarto nao acabou
                if para_continua = '1' and fim_quarto = '0' then
                    snext <= count;
                else
                    snext <= idle;
                end if;

            when count =>
                -- para_continua pausa, e fim_quarto tbm para
                if para_continua = '1' or fim_quarto = '1' then
                    snext <= stopped;
                else
                    snext <= count;
                end if;

            when stopped =>
                -- para_continua volta a contar se ainda tem quarto
                -- se acabou o quarto, volta pro idle
                if para_continua = '1' and fim_quarto = '0' then
                    snext <= count;
                elsif fim_quarto = '1' then
                    snext <= idle;
                else
                    snext <= stopped;
                end if;

        end case;
    end process;

    -- --------------------------------------------------------
    -- contagem regressiva: cent -> secs -> mins
    -- a cada 500000 clocks (1 centesimo) tira 1 do cent
    -- cent zerou tira do secs, secs zerou tira do mins
    -- mins zerou acabou o quarto (fim_quarto)
    -- --------------------------------------------------------
	 counter : process(reset, clock, mode_selection)  -- mode_selection na lista pq o reset le ele pra escolher mins 10 ou 12, estava dando warning
        variable clk_cnt : integer range 0 to MAXCOUNT;
    begin
        if reset = '1' then
            fim_jogo <= '0';                     
            if mode_selection = '1' then mins <= "1010";   -- FIBA 10
            else                         mins <= "1100";    -- NBA 12
            end if;
            secs <= "000000"; cent <= "0000000"; quarts <= "00";
            clk_cnt := 0;

        elsif rising_edge(clock) then

            -- carga: so com o cronometro parado (idle OU stopped, nunca contando)
            if carga = '1' and scurrent /= count then
                mins <= c_minutos; secs <= c_segundos;
                cent <= c_centesimos; quarts <= c_quarto;
					 fim_jogo <= '0'; 
                clk_cnt := 0;

            -- novo quarto: parado, fim de quarto e jogo ainda rolando
            elsif modo_novoquarto = '1' and scurrent = idle
                  and fim_quarto = '1' and fim_jogo = '0' then
                if quarts < "11" then
                    quarts <= std_logic_vector(unsigned(quarts) + 1);
                    if mode_selection = '1' then mins <= "1010";
                    else                         mins <= "1100"; end if;
                    secs <= "000000"; cent <= "0000000"; clk_cnt := 0;
                else
                    fim_jogo <= '1';   -- acabou o Q4, modo_novoquarto nao faz mais nada
                end if;

            -- contagem: so no count e so enquanto o quarto nao acabou
            elsif scurrent = count and fim_quarto = '0' then
                if clk_cnt = MAXCOUNT - 1 then
                    clk_cnt := 0;                          -- passou 1 centesimo
                    if unsigned(cent) > 0 then
                        cent <= std_logic_vector(unsigned(cent) - 1);
                    else
                        cent <= "1100011";                
                        if unsigned(secs) > 0 then
                            secs <= std_logic_vector(unsigned(secs) - 1);
                        else
                            secs <= "111011";             
                            if unsigned(mins) > 0 then
                                mins <= std_logic_vector(unsigned(mins) - 1);
                            end if;
                        end if;
                    end if;
                else
                    clk_cnt := clk_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- liga os sinais internos nas saidas
    quarto     <= quarts;
    minutos    <= mins;
    segundos   <= secs;
    centesimos <= cent;

    fim_quarto <= '1' when (unsigned(mins) = 0 and unsigned(secs) = 0
                            and unsigned(cent) = 0) else '0';

end Behavioral;