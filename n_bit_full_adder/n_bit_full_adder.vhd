library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity n_bit_full_adderr is
generic(
N : integer range 0 to 255 :=8
);

Port ( 
smain1_i : in STD_LOGIC_VECTOR (N-1 downto 0 );
smain2_i : in STD_LOGIC_VECTOR (N-1 downto 0 );
carryInMain_i : in STD_LOGIC;
sumMain_o : out STD_LOGIC_VECTOR(N-1 downto 0 );
carryMain_o : out STD_LOGIC
);
end n_bit_full_adderr;

architecture Behavioral of n_bit_full_adderr is
--COMPONENET INSTANTIATION
component full_adder is
port(
smain1_i 		: in STD_LOGIC;
smain2_i 		: in STD_LOGIC;
carryInMain_i 	: in STD_LOGIC;
sumMain_o 		: out STD_LOGIC;
carryMain_o 	: out STD_LOGIC
);
end component full_adder;

--signal
signal temp : std_logic_vector (N downto 0) := (others=>'0');

begin
temp(0)			<= carryInMain_i;
carryMain_o 	<= temp(N);

full_adder_gen : for k in 0 to N-1 generate

full_addder_k :full_adder
port map(
smain1_i 		=> smain1_i(k),  
smain2_i 		=> smain2_i(k),
carryInMain_i 	=> temp(k),
sumMain_o		=> sumMain_o(k),
carryMain_o		=> temp(k+1)
);

end generate;


end Behavioral;