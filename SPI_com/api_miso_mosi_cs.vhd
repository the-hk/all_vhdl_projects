

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity api_miso_mosi_cs is
generic(
c_clock 	: integer := 100_000_000;
sclk_freq 	: integer := 50_000_000 -- can be obtained 40 ns clk signal 

);
Port ( 
clk		: in std_logic  ;
sclk_o  : out std_logic ;	
miso_i  : in std_logic  ;
mosi_o  : out std_logic ;
cs_o    : out std_logic_vector (1 downto 0) 
);
end api_miso_mosi_cs;

architecture Behavioral of api_miso_mosi_cs is

constant sclk_limit		: integer := (c_clock/sclk_freq);

signal sclk_counter 	: integer range 0 to sclk_limit := 0;
signal odd_even 	    : integer := 0;
signal sclk_signal 		: std_logic := '0';
type state is (s_idle, s_miso, s_mosi, s_cs);

begin

process (clk) begin
if(rising_edge(clk)) then

	if(sclk_signal = '0') then
		if(sclk_limit = sclk_counter + 1) then
			sclk_signal <= '1';
			sclk_counter <= 0;
		else
			sclk_counter <= sclk_counter + 1;
		end if;
		
	else
		if(sclk_limit = sclk_counter + 1) then
			sclk_signal <= '0';
			sclk_counter <= 0;
		else
			sclk_counter <= sclk_counter + 1;
		end if;
	end if;
	case states is 
		when s_idle =>
			if
		when s_cs 	=>
			
		when miso_i =>
			
		when mosi_o =>
			
		
	end case;
	

end if;
end process;
sclk_o <= sclk_signal;
end Behavioral;
