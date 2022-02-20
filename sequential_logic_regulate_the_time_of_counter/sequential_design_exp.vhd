
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity sequential_design_exp is
GENERIC(
c_clkFrequency : integer := 100_000_000	
);
Port ( 
clk 	: in std_logic;
sw 		: in std_logic_vector (1 downto 0);
led 	: out std_logic_vector (7 downto 0)
);
end sequential_design_exp;

architecture Behavioral of sequential_design_exp is

constant timer2secLim 		: integer := c_clkFrequency/100;
constant timer1secLim 		: integer := c_clkFrequency/200;
constant timer500msecLim 	: integer := c_clkFrequency/400;
constant timer250msecLim 	: integer := c_clkFrequency/800;

signal timerLim 			: integer range 0 to timer2secLim :=0;
signal timer 				: integer range 0 to timer2secLim :=0;
signal counter  			: std_logic_vector (7 downto 0) := (others=>'0');

begin 

--COMBINATIONAL LOGIC ASSIGNMENT
timerLim <= timer2secLim	when sw = "00" else
			timer1secLim	when sw = "01" else
			timer500msecLim when sw = "10" else
			timer250msecLim;
			
process (clk) begin

	if (rising_edge(clk)) then
		
		if (timer >= timerLim-1) then
			counter <= counter +1;
			timer <= 0 ;	
		else
			timer <= timer +1;
				
		end if;
	
	end if;

end process;
			
led <= counter;

end Behavioral;
