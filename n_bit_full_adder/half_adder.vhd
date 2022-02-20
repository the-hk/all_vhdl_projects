library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity half_adder is
    Port ( s1_i : in STD_LOGIC;
           s2_i : in STD_LOGIC;
           sum_o : out STD_LOGIC;
           carry_o : out STD_LOGIC);
end half_adder;

architecture Behavioral of half_adder is

begin

carry_o <=s1_i and s2_i;
sum_o <=s1_i xor s2_i;


end Behavioral;
