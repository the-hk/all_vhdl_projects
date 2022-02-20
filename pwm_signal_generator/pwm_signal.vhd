
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity pwm_signal is
generic(
c_clk_freq : integer := 100_000_000;
c_sig_freq : integer := 1000;
c_sec_freq : integer := 100

);
Port ( 
clk			   : in std_logic; 
duty_cycle_inc : in std_logic; 
duty_cycle_dec : in std_logic; 
signal_o 	   : out std_logic
);
end pwm_signal;

architecture Behavioral of pwm_signal is
---------------------------------------------------
-----------------CONSTANT--------------------------
---------------------------------------------------
constant lim_per 		: integer := c_clk_freq/c_sig_freq;
constant lim_for_1_sec 	: integer := c_clk_freq/c_sec_freq;


---------------------------------------------------
-----------------SIGNAL----------------------------
---------------------------------------------------
signal timer_for_1_sec 		: integer range 0 to lim_for_1_sec :=0;
signal timer_for_duty_cyc	: integer range 0 to lim_per :=0;
signal duty_cycle			: integer range 0 to 100 := 0;
signal real_limit 			: integer := 0;
signal signal_o_prev 		: std_logic := '0';
signal signal_o_carrier	 	: std_logic := '1';
signal temp_store	 		: integer := 0;
signal temp_minus_sig 		: integer := 0;


begin
process(clk) begin
	if(rising_edge(clk)) then
		if(duty_cycle_inc = '1') then	
			if(timer_for_1_sec = lim_for_1_sec-1) then
				duty_cycle <= duty_cycle + 1 ;
				timer_for_1_sec <= 0;
			else
				timer_for_1_sec <= timer_for_1_sec + 1;
			end if;	
			if(duty_cycle = 100) then
				duty_cycle <= 0;
			end if;
		end if;	
	end if;
end process;

p_duty_cycle : process(clk) begin

	if(rising_edge(clk)) then
		real_limit <= (lim_per/100)*duty_cycle;
		temp_store <= real_limit;
		
		if(signal_o_carrier = '1') then
		-- at this condition duty cycle time it signal_o should be one
			if(timer_for_duty_cyc = real_limit-1) then
				signal_o_carrier <= '0'; 
				timer_for_duty_cyc <= 0;
			else
				signal_o_carrier <= '1'; 
				timer_for_duty_cyc <= timer_for_duty_cyc + 1;
			end if;
		else
		-- at this condition rest of the time would be "0"
			temp_minus_sig <= (lim_per-temp_store);
			if(timer_for_duty_cyc = (lim_per-temp_store-1)) then
				signal_o_carrier <= '1';
				timer_for_duty_cyc <= 0;
			else
				signal_o_carrier <= '0';
				timer_for_duty_cyc <= timer_for_duty_cyc + 1;
			end if;
		end if;
		
		if(timer_for_duty_cyc > lim_per) then
			timer_for_duty_cyc <= 0;
		end if;
		
	end if;

end process;
signal_o <= signal_o_carrier;
end Behavioral;

