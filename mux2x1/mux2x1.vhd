library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux2x1 is
port(
a_i 		: in std_logic;
b_i 		: in std_logic;
select1_i 	: in std_logic;

c_i 		: in std_logic;
d_i 		: in std_logic;
select2_i 	: in std_logic;

e_i 		: in std_logic;
f_i 		: in std_logic;
select3_i 	: in std_logic;

signal_1_o 	: out std_logic;
signal_2_o 	: out std_logic;
signal_3_o 	: out std_logic
);
end mux2x1;

architecture Behavioral of mux2x1 is

signal temp1 : std_logic :='0';
signal temp2 : std_logic :='0';

begin
----------------------------------------
--GATE LEVEL COMBINATIONAL DESIGN-------
----------------------------------------

temp1 		<= select1_i and a_i;
temp2 		<= not (select1_i) and b_i;   
signal_1_o 	<= temp1 or temp2;

----------------------------------------
--CONCURRET ASSIGNMENT COMBINATIONAL DESIGN
----------------------------------------

signal_2_o <= c_i when select2_i = '0' else
			  d_i;
			  
----------------------------------------
--PROCESS COMBINATIONAL DESIGN
----------------------------------------
why_i_put_label : process(select3_i, e_i, f_i) 

begin
	if (select3_i = '0') then
		signal_3_o <= e_i;
	else
		signal_3_o <= f_i;
	end if;
 
end process why_i_put_label; 			  
			  
			  

end Behavioral;
