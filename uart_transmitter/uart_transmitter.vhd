
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_transmitter is
generic(
c_clk_freq 		: integer := 100_000_000;
c_baudrate 		: integer := 9600;
c_stopbit   	: integer := 1

);
Port ( 
clk 			: in std_logic ;
start_i 		: in std_logic ;
data_i 			: in std_logic_vector (7 downto 0) ;
tx_o 			: out std_logic;
tx_done_tick	: out std_logic

);
end uart_transmitter;

architecture Behavioral of uart_transmitter is

constant c_timer_lim 		: integer :=c_clk_freq/c_baudrate;
constant c_timer_lim_stop 	: integer :=(c_clk_freq/c_baudrate)*c_stopbit;

type states is (s_idle, s_start, s_data, s_stop);
signal state 	: states := s_idle;
signal counter 	: integer range 0 to 7 :=0;
signal timer 	: integer range 0 to c_timer_lim_stop := 0;
signal shft_reg : std_logic_vector (7 downto 0):= (others =>'0');

begin
p_main : process (clk) begin
	if(rising_edge(clk)) then
		case state is
		
			when s_idle =>
				tx_o <= '1';
				tx_done_tick <= '0';
				if(start_i = '1') then
					state <= s_start;
				end if;
			when s_start =>
				tx_o <= '0';
				if(timer = c_timer_lim - 1) then
					timer 	<= 0;
					state <= s_data;
				else
					timer <= timer + 1;
				end if;
				
			when s_data =>
				
				if(timer = c_timer_lim - 1) then
					timer 	<= 0;
					state <= s_data;
					counter <= counter + 1;
				else
					if (counter = 8) then
						state <= s_stop;
						counter <= 0;
					else
						tx_o  <= data_i(counter);
						timer <= timer + 1;
					end if;
					
				end if;
				
			when s_stop =>
				if(timer = c_timer_lim_stop - 1) then
					timer 	<= 0;
					state <= s_idle;
					tx_done_tick <= '1';
				else
					tx_o  <= '1';
					timer <= timer + 1;
				end if;
		end case;
	end if;
end process;

end Behavioral;
