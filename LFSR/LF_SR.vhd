
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity LF_SR is
generic(
c_datawidth : integer := 10
);
Port (
clk        : in std_logic ;
load_i     : in std_logic ;
enable_i   : in std_logic ;
poly_i     : in std_logic_vector (c_datawidth-1 downto 0 );
number_o   : out std_logic_vector (c_datawidth-1 downto 0 )
);
end LF_SR;

architecture Behavioral of LF_SR is
signal load_next 	: std_logic :='0';
signal polynomial 	: std_logic_vector (c_datawidth-1 downto 0 ) := (c_datawidth-1=>'1',others=>'0');
signal datareg 		: std_logic_vector (c_datawidth-1 downto 0 ) := (c_datawidth-1=>'1',others=>'0');
begin
p_main : process(clk) 
	variable tmp : std_logic;
begin

	if(rising_edge(clk)) then
		load_next <= load_i ;
		if(load_i = '1' and load_next = '0') then
			polynomial <= poly_i;
		end if;
		
		if(enable_i  = '1') then 
			datareg(c_datawidth-1 downto  1)  <= datareg(c_datawidth-2 downto 0);
			for i in 0 to c_datawidth-1 loop
				tmp := (datareg(i) and polynomial(i)) xor tmp;
			end loop; 			
			datareg(0) <= tmp;
		end if;
	end if;

end process;
number_o <= datareg;
end Behavioral;
