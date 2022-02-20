library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity bcd_increment is
generic(
c_decimal_digit_lim : integer :=5;
c_unit_digit_lim  : integer :=9

);
Port ( 
clk 		: in std_logic;
increment 	: in std_logic;
reset 		: in std_logic;

output_of_inc_dec : out std_logic_vector (3 downto 0);
output_of_inc_unit : out std_logic_vector (3 downto 0)

);
end bcd_increment;

architecture Behavioral of bcd_increment is
signal temp_unit 	: std_logic_vector (3 downto 0):=(others=>'0');
signal temp_decimal : std_logic_vector (3 downto 0):=(others=>'0');

begin
process(clk) begin

if(rising_edge(clk)) then
	if(increment = '1' ) then
		if(temp_unit = c_unit_digit_lim) then
		-- increment should be execute on decimal digit
			
			if(temp_decimal = c_decimal_digit_lim) then
			-- increment should be execute on other side
				temp_unit	 <= x"0";
				temp_decimal <= x"0";
				
			else
			-- increment should be execute on decimal digit
				temp_unit	 <= x"0";
				temp_decimal <= temp_decimal + 1;
			end if;
		else
		-- increment should be execute on unit digit
			temp_unit <= temp_unit + 1;
		end if;
		
		
	end if;
	if(reset = '1' ) then
		temp_unit   	<= x"0";
		temp_decimal	<= x"0";
	end if; 
	
end if;
end process;

output_of_inc_dec  <= temp_decimal;
output_of_inc_unit <= temp_unit;

end Behavioral;
