----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.09.2021 22:04:47
-- Design Name: 
-- Module Name: debounce_fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity debounce_fsm is
generic(
c_clk_freq : integer 	:= 100_000_000; 
c_debtime  : integer 	:= 1000;  
c_initval  : std_logic 	:= '0' 
);
Port ( 
clk 	: in std_logic ;
sig_i 	: in std_logic ;
sig_o 	: out std_logic 
);
end debounce_fsm;

architecture Behavioral of debounce_fsm is

constant c_timerlim : integer 	:= c_clk_freq/c_debtime; 
-- calculation should be like that if in 1 second there is 100 million clock cycle what should be the clock cycle for 1ms 
	
signal timer 		: integer range 0 to c_timerlim :=0; 
signal timer_en 	: std_logic := '0'; 
signal timer_tick 	: std_logic := '0'; 


type t_state is (idle_state, zero_state, zero2one_state, one_state, one2zero_state);
signal state : t_state := idle_state; 

begin
process(clk) begin

	if(rising_edge(clk)) then
	
		case state is
			when idle_state =>
				
				if (c_initval = '0') then
					state <= zero_state	;
				else
					state <= one_state	;
				end if;
			when zero_state =>	
				sig_o 	<= '0' ;	
				if(sig_i = '1') then
					state <= zero2one_state;
				end if;
			when zero2one_state =>
				sig_o 		<= '0';
				timer_en 	<= '1';
				if(timer_tick = '1') then
					state 		<= one_state ;
					timer_en 	<= '0';
				end if;
				if (sig_i = '0') then
					state 		<= zero_state; 
					timer_en 	<= '0';
				end if;			
			when one_state 	=>
				sig_o 	<= '1' ;	
				if(sig_i = '0') then
					state <= one2zero_state;
				end if;
			when one2zero_state =>
				sig_o 		<= '1';
				timer_en 	<= '1';
				if(timer_tick = '1') then
					state 		<= zero_state ;
					timer_en 	<= '0';
				end if;
				if (sig_i = '1') then
					state 		<= one_state; 
					timer_en 	<= '0';
				end if;	
			
		end case;	
	
	end if;

end process;

p_timer : process (clk) begin


if(rising_edge(clk)) then

	if (timer_en = '1') then 
		if (timer >= c_timerlim-1) then
			timer_tick <= '1';
			timer <= 0;
		else
			timer_tick <= '0';
			timer <= timer + 1;	
		end if;
		
	else

		timer 		<= 0;
		timer_tick 	<= '0';
	
	end if;
	

end if;
	

end process;

end Behavioral;
