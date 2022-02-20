library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity full_adder is
    Port ( smain1_i : in STD_LOGIC;
           smain2_i : in STD_LOGIC;
           carryInMain_i : in STD_LOGIC;
           sumMain_o : out STD_LOGIC;
           carryMain_o : out STD_LOGIC);
end full_adder;

architecture Behavioral of full_adder is

--COMPONENET DECLERATION
component half_adder is
port(
s1_i    : in STD_LOGIC;
s2_i    : in STD_LOGIC;
sum_o   : out STD_LOGIC;
carry_o : out STD_LOGIC
);
end component half_adder;

--SIGNALS
signal first_sum 		: std_logic :='0';
signal first_carry 		: std_logic :='0';
signal second_carry 	: std_logic :='0';

begin

--COMPONENET INSTANTIATION
first_half_adder : half_adder
port map(
s1_i 		=> smain1_i ,
s2_i		=> smain2_i ,
sum_o 		=> first_sum,
carry_o 	=> first_carry
);

second_half_adder : half_adder
port map(
s1_i 		=> first_sum,
s2_i 		=> carryInMain_i,
sum_o 		=> sumMain_o,
carry_o 	=> second_carry
);

carryMain_o <= second_carry or first_carry;

end Behavioral;