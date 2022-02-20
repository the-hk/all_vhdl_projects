
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top_module is
generic(
c_clk_freq : integer :=100_000_000
);
Port (	
clk		 	: in std_logic;
start_i 	: in std_logic;
reset_i 	: in std_logic;
seven_seg_o : out std_logic_vector(7 downto 0);
anodes_o 	: out std_logic_vector(7 downto 0)
 );
end top_module;

architecture Behavioral of top_module is
----------------------------------------
-----------COMPONENT 1------------------
----------------------------------------
component bcd_increment is
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
end component bcd_increment;

----------------------------------------
-----------COMPONENT 2------------------
----------------------------------------

component bcd_2_seven_segment is
Port ( 
bcd_i 		: in std_logic_vector (3 downto 0);
sevenseg_o 	: out std_logic_vector (7 downto 0)
);
end component bcd_2_seven_segment;

----------------------------------------
-----------COMPONENT 3------------------
----------------------------------------

component debouncer is
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
end component debouncer;
----------------------------------------
-----------constant-----------------------
----------------------------------------
constant c_debtime  	: integer := 1000;  
constant c_timer_lim 	: integer := c_clk_freq/c_debtime;
constant c_salise_lim 	: integer := c_clk_freq/100;
constant c_saniye_lim 	: integer := 99;

----------------------------------------
-----------SIGNAL-----------------------
----------------------------------------
signal counter 				   				: integer range 0 to 7 :=0;
signal debounced_signal_reset 				: std_logic := '0';
signal debounced_signal_start 				: std_logic := '0';

signal temp_second_increment 				: std_logic := '0';
signal temp_sallies_increment 				: std_logic := '0';
signal temp_minute_increment				: std_logic := '0';

signal sevenseg_output_sallies_unit 		: std_logic_vector (7 downto 0) := (others => '1');
signal sevenseg_output_sallies_dec  		: std_logic_vector (7 downto 0) := (others => '1');

signal temp_output_of_inc_dec 				: std_logic_vector (3 downto 0) := (others => '0');
signal temp_output_of_inc_unit				: std_logic_vector (3 downto 0) := (others => '0');

signal second_temp_output_of_inc_dec 		: std_logic_vector (3 downto 0) := (others => '0');
signal second_temp_output_of_inc_unit		: std_logic_vector (3 downto 0) := (others => '0');
signal sevenseg_output_second_dec			: std_logic_vector (7 downto 0) := (others => '1');

signal minute_temp_output_of_inc_dec		: std_logic_vector (3 downto 0) := (others => '0');
signal minute_temp_output_of_inc_unit		: std_logic_vector (3 downto 0) := (others => '0');
signal sevenseg_output_minute_dec			: std_logic_vector (7 downto 0) := (others => '1');
signal sevenseg_output_minute_unit			: std_logic_vector (7 downto 0) := (others => '1');
signal sevenseg_output_second_unit			: std_logic_vector (7 downto 0) := (others => '1');

signal temp_anode_signals 					: std_logic_vector (7 downto 0) := "11111110";
signal start_deb_prev 						: std_logic 					:='0';
signal continue 							: std_logic 					:='0';

signal timer 								: integer range 0 to c_timer_lim 	:= 0;
signal salise_counter 						: integer range 0 to c_salise_lim 	:= 0;
signal saniye_counter 						: integer range 0 to 59 			:= 0;
signal minute_counter 						: integer range 0 to 59 			:= 0;



begin
-----------------------------------------------------
-- for reset button debounce component instantiation
-----------------------------------------------------
i_debouncer_reset : debouncer 
generic map(
c_clk_freq => c_clk_freq     ,
c_debtime  => 1000         ,
c_initval  => '0'

)
port map(
clk 	=> clk ,
sig_i 	=> reset_i , 
sig_o   => debounced_signal_reset 
);
-----------------------------------------------------
-- for start button debounce component instantiation
-----------------------------------------------------
i_debouncer_start : debouncer 
generic map(
c_clk_freq => c_clk_freq     ,
c_debtime  => 1000         ,
c_initval  => '0'

)
port map(
clk 	=> clk ,
sig_i 	=> start_i , 
sig_o   => debounced_signal_start 
);
---------------------------------
-- bcd increment for sallise
---------------------------------
i_sallies_inc : bcd_increment
generic map(
c_decimal_digit_lim => 9,
c_unit_digit_lim  	=> 9
)
Port map( 
clk 		=> clk ,
increment 	=> temp_sallies_increment , 
reset 		=> debounced_signal_reset,

output_of_inc_dec  => temp_output_of_inc_dec,
output_of_inc_unit => temp_output_of_inc_unit
);

---------------------------------
-- bcd_2_seven_segment for sallise
---------------------------------
i_sallies_dec_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> temp_output_of_inc_dec,
sevenseg_o 	=> sevenseg_output_sallies_dec
);

i_sallies_unit_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> temp_output_of_inc_unit,
sevenseg_o 	=> sevenseg_output_sallies_unit
);
---------------------------------
-- bcd increment for second
---------------------------------
i_second_inc : bcd_increment
generic map(
c_decimal_digit_lim => 5,
c_unit_digit_lim  	=> 9
)
Port map( 
clk 		=> clk ,
increment 	=> temp_second_increment , 
reset 		=> debounced_signal_reset ,

output_of_inc_dec  => second_temp_output_of_inc_dec,
output_of_inc_unit => second_temp_output_of_inc_unit
);
---------------------------------
-- bcd_2_seven_segment for second
---------------------------------
i_second_dec_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> second_temp_output_of_inc_dec,
sevenseg_o 	=> sevenseg_output_second_dec
);

i_second_unit_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> second_temp_output_of_inc_unit,
sevenseg_o 	=> sevenseg_output_second_unit
);
---------------------------------
-- bcd_2_seven_segment for minute
---------------------------------
i_minute_inc : bcd_increment
generic map(
c_decimal_digit_lim => 5,
c_unit_digit_lim  	=> 9
)
Port map( 
clk 		=> clk ,
increment 	=> temp_minute_increment , 
reset 		=> debounced_signal_reset,

output_of_inc_dec  => minute_temp_output_of_inc_dec,
output_of_inc_unit => minute_temp_output_of_inc_unit
);


i_minute_dec_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> minute_temp_output_of_inc_dec,
sevenseg_o 	=> sevenseg_output_minute_dec
);

i_minute_unit_seven_segment : bcd_2_seven_segment
Port map( 
bcd_i 		=> minute_temp_output_of_inc_unit,
sevenseg_o 	=> sevenseg_output_minute_unit
);

p_main : process (clk) begin

	if(rising_edge(clk)) then
		start_deb_prev <= debounced_signal_start ;
		
		if(start_deb_prev = '0' and debounced_signal_start = '1' ) then
		-- toggle process
			continue <= not continue;
		end if;
		temp_minute_increment 	<='0';
		temp_second_increment 	<='0';
		temp_sallies_increment	<='0';
		
		if(continue='1') then
			if(salise_counter = c_salise_lim-1) then
				salise_counter <= 0;
				temp_sallies_increment <= '1';
				saniye_counter <= saniye_counter + 1 ; 
			else
				salise_counter <= salise_counter + 1;
			end if;
			
			if(saniye_counter = c_saniye_lim) then
				saniye_counter 			<= 0 ;
				temp_second_increment 	<='1';
				minute_counter 			<= minute_counter + 1; 
			end if;
			
			if(minute_counter = c_saniye_lim) then
				minute_counter			<= 0 ;
				temp_minute_increment 	<='1';
			end if;
		end if;
		
	end if;

end process;



p_anode : process (clk) begin

	if(rising_edge(clk)) then
		
		if(timer = c_timer_lim - 1) then
			if(counter = 0) then
				-- first anode is activated
				temp_anode_signals <= "11111110";
				timer 	<=0;
				counter <= counter + 1 ;
			elsif(counter = 1) then
				-- second anode is activated
				temp_anode_signals <= "11111101";
				timer 	<=0;
				counter <= counter + 1 ;
			elsif(counter = 2) then
				-- third anode is activated
				temp_anode_signals <= "11111011";
				timer 	<=0;
				counter <= counter + 1 ;
			elsif(counter = 3) then
				-- forth anode is activated
				temp_anode_signals <= "11110111";
				timer 	<=0;
				counter <= counter + 1 ;
			elsif(counter = 4) then
				-- fifth anode is activated
				temp_anode_signals <= "11101111";
				timer 	<=0;
				counter <= counter + 1 ;
			elsif(counter = 5) then
				-- sixth anode is activated
				temp_anode_signals <= "11011111";
				counter <= 0;
				timer 	<=0;
			else
				temp_anode_signals <= "11111110";
				timer 	<=0;
				counter <= 0;
			end if;
			
		else
			timer <= timer + 1;
		end if;
	
	end if;

end process;

anodes_o <= temp_anode_signals;

p_cathode : process(clk) begin

	if(rising_edge(clk)) then
		if(temp_anode_signals(0) = '0')then
		seven_seg_o <= sevenseg_output_sallies_unit;
		elsif (temp_anode_signals(1)='0')then
		seven_seg_o <= sevenseg_output_sallies_dec;
		elsif (temp_anode_signals(2)='0')then
		seven_seg_o <= sevenseg_output_second_unit;
		elsif (temp_anode_signals(3)='0')then
		seven_seg_o <=sevenseg_output_second_dec;
		elsif (temp_anode_signals(4)='0')then
		seven_seg_o <=sevenseg_output_minute_unit;
		elsif (temp_anode_signals(5)='0')then
		seven_seg_o <=sevenseg_output_second_dec;
		else
		seven_seg_o <= (others => '1');
		end if;
	end if;


end process;

end Behavioral;
