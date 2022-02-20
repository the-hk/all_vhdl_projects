
library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use work.ram_pkg.all;

entity top is
generic(
	c_clk_freq 		: integer := 100_000_000;
	c_baudrate 		: integer := 115_200 ;
	c_stopbit   	: integer := 2;

    RAM_WIDTH 		: integer := 16;                      -- Specify RAM data width
    RAM_DEPTH 		: integer := 128;                    -- Specify RAM depth (number of entries)
    RAM_PERFORMANCE : string := "LOW_LATENCY";      -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    C_RAM_TYPE 		: string := "block"
);
Port ( 
clk 	: in std_logic ;
rx_i	: in std_logic ;
tx_o 	: out std_logic 

);
end top;

architecture Behavioral of top is

-------------------------------------------------
-----------------COMPONENT-----------------------
-------------------------------------------------
component block_ram is
generic (
    RAM_WIDTH 		: integer := 16;                      -- Specify RAM data width
    RAM_DEPTH 		: integer := 128;                    -- Specify RAM depth (number of entries)
    RAM_PERFORMANCE : string := "LOW_LATENCY";      -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    C_RAM_TYPE 		: string := "block"
	);

port (
        addra : in std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);     -- Address bus, width determined from RAM_DEPTH
        dina  : in std_logic_vector(RAM_WIDTH-1 downto 0);		  		 -- RAM input data
        clka  : in std_logic;                       			  		 -- Clock
        wea   : in std_logic;                       			  		 -- Write enable
        douta : out std_logic_vector(RAM_WIDTH-1 downto 0)   			  -- RAM output data
    );

end component block_ram;

component uart_receiver is
generic(
c_clk_freq 		: integer := 100_000_000;
c_baudrate 		: integer := 115_200
);
Port ( 
clk 			: in std_logic ;
rx_i 			: in std_logic;
dout_o 			: out std_logic_vector (7 downto 0) ;
rx_i_done_tick	: out std_logic

);
end component uart_receiver;


component uart_transmitter is
generic(
c_clk_freq 		: integer := 100_000_000;
c_baudrate 		: integer := 115_200;
c_stopbit   	: integer := 1

);
Port ( 
clk 			: in std_logic ;
start_i 		: in std_logic ;
data_i 			: in std_logic_vector (7 downto 0) ;
tx_o 			: out std_logic;
tx_done_tick	: out std_logic

);
end component uart_transmitter;

constant c_timer_lim 	: integer := (c_clk_freq/c_baudrate)*8;
-------------------------------------------------
----------------------type-----------------------
-------------------------------------------------
type states is (s_idle, s_write, s_read, s_transmit);
signal state 	: states := s_idle;
-------------------------------------------------
-----------------SIGNALs-------------------------
-------------------------------------------------

signal dout_o 			: std_logic_vector (7 downto 0) 	:= (others => '0');
signal data_i 			: std_logic_vector (7 downto 0) 	:= (others => '0');
signal buff1 			: std_logic_vector (7 downto 0) 	:= (others => '0');
signal buff2 			: std_logic_vector (7 downto 0) 	:= (others => '0');
signal dataBuffers 		: std_logic_vector (31 downto 0) 	:= (others => '0');

signal rx_i_done_tick 	: std_logic ;
signal tx_done_tick 	: std_logic ;
signal start_i 			: std_logic := '0';
signal wea	 			: std_logic := '0';
signal counter	 		: integer range 0 to 2 := 0;
signal timer	 		: integer range 0 to c_timer_lim := 0;

 

-------------------------------------------------
------------BRAM_SIGNAL--------------------------
-------------------------------------------------

signal addra : std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0) ;
signal dina  : std_logic_vector(RAM_WIDTH-1 downto 0) ;	  	                    			  	                			  	
signal douta : std_logic_vector(RAM_WIDTH-1 downto 0) ;        		


begin

i_uart_receiver : uart_receiver 
generic map(
c_clk_freq 		=> c_clk_freq ,
c_baudrate 		=> c_baudrate
)
Port map( 
clk 			=> clk             ,
rx_i 			=> rx_i            ,
dout_o 			=> dout_o          ,
rx_i_done_tick	=> rx_i_done_tick  

);

i_uart_transmitter : uart_transmitter 
generic map(
c_clk_freq 		=> c_clk_freq   ,
c_baudrate 		=> c_baudrate   ,
c_stopbit   	=> c_stopbit 

)
Port map( 
clk 			=> clk			,
start_i 		=> start_i      ,
data_i 			=> data_i       ,
tx_o 			=> tx_o         ,
tx_done_tick	=> tx_done_tick

);



bram128x16 : block_ram 
generic map(
    RAM_WIDTH 		=> RAM_WIDTH 		 ,
    RAM_DEPTH 		=> RAM_DEPTH 		 ,
    RAM_PERFORMANCE => RAM_PERFORMANCE   ,
    C_RAM_TYPE 		=> C_RAM_TYPE 		
	)

port map(
        addra       => addra ,
        dina        => dina,
        clka        => clk ,
        wea         => wea,
        douta       => douta
    );

p_main : process(clk) begin

if(rising_edge(clk)) then

	case state is
		when s_idle 	=>
			wea 	<= '0';
			start_i <= '0';
			if(rx_i_done_tick = '1') then
				dataBuffers(7 downto 0) 		<= dout_o;
				dataBuffers(8*4-1 downto 8*1) 	<= dataBuffers(8*3-1 downto 8*0);
				if(dataBuffers(8*4-1 downto 8*3) = x"0a") then	-- write
					addra 	<= dataBuffers(8*3-2 downto 8*2);
					dina 	<= dataBuffers(8*2-1 downto 8*0);
					state <= s_write ;
				end if;
				
				if(dataBuffers(8*4-1 downto 8*3) = x"0b") then 	-- read
					start_i <= '1';
					addra 	<= dataBuffers(8*3-2 downto 8*2);
					state <= s_read ;
				end if;
				
			end if;
		when s_write 	=>
			wea 	<= '1';
			--dataBuffers <= x"00000000";
			state 	<= s_idle;
			
		when s_read 	=>
			data_i <= douta(8*2-1 downto 8*1);
			if(tx_done_tick = '1') then 
				state 	<= s_transmit;
			end if;	
		when s_transmit =>
				data_i <= douta(8*1-1 downto 8*0);
				state 	<= s_idle;

	end case;

end if;

end process;

end Behavioral;
