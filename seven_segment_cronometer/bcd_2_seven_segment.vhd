
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bcd_2_seven_segment is
Port ( 

bcd_i 		: in std_logic_vector (3 downto 0);
sevenseg_o 	: out std_logic_vector (7 downto 0)

);
end bcd_2_seven_segment;

architecture Behavioral of bcd_2_seven_segment is
	
begin
with bcd_i select
	sevenseg_o <= 	"00000011" when "0000",
					"10011111" when "0001",
					"00100101" when "0010",
					"00001101" when "0011",
					"10011001" when "0100",
					"01001001" when "0101",
					"01000001" when "0110",
					"00011111" when "0111",
					"00000001" when "1000",
					"00001001" when "1001",
					"11111111" when others;
				  

end Behavioral;
