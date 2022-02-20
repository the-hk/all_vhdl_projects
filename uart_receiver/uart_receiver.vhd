
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity uart_receiver is
generic(
c_clk_freq 		: integer := 100_000_000;
c_baudrate 		: integer := 115_200
);
Port ( 
clk 			: in std_logic ;
rx_i 			: in std_logic;
dout_o 			: out std_logic_vector (7 downto 0) ;
rx_i_done_tick	: out std_logic

);
end uart_receiver;

architecture Behavioral of uart_receiver is
constant c_timer_lim 		: integer :=c_clk_freq/c_baudrate;

type states is (s_idle, s_start, s_data, s_stop);

signal state 	: states := s_idle;
signal counter 	: integer range 0 to 7 :=0;
signal timer 	: integer range 0 to c_timer_lim := 0;
signal shft_reg : std_logic_vector (7 downto 0):= (others =>'0');

begin

p_main : process (clk) begin
	if(rising_edge(clk)) then
		case state is
		
			when s_idle =>
				rx_i_done_tick <= '0';
				counter <= 0;
				timer   <= 0;
				if(rx_i = '0') then
					state <= s_start;
				end if;
				
			when s_start =>
				if(timer=c_timer_lim/2-1) then
					state <= s_data;
					timer <= 0;
				else
					timer <= timer + 1;
				end if;
			
			when s_data =>
				if(timer=c_timer_lim-1) then
					timer <= 0;
					counter <= counter  + 1 ;
					if (counter = 8) then
						state <= s_stop;
						counter <= 0;
					else
						shft_reg <= rx_i & (shft_reg(7 downto 1)); 
					end if;
					
				else
					timer <= timer + 1;
				end if;
			
				
			when s_stop =>
				
				if(timer=c_timer_lim-1) then
					rx_i_done_tick <= '1';
					state <= s_idle;
					timer <= 0;
				else
					timer <= timer + 1;
				end if;
		end case;
	end if;
end process;
dout_o <= shft_reg;


end Behavioral;
