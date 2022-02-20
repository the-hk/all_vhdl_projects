
  --  Xilinx Single Port Read First RAM
  --  This code implements a parameterizable single-port read-first memory where when data
  --  is written to the memory, the output reflects the prior contents of the memory location.
  --  If the output data is not needed during writes or the last read value is desired to be
  --  retained, it is suggested to use No Change Mode example as it is more power efficient.
  --  If a reset or enable is not necessary, it may be tied off or removed from the code.
  --  Modify the parameters for the desired RAM characteristics.

library ieee;
use ieee.std_logic_1164.all;

package ram_pkg is
    function clogb2 (depth: in natural) return integer;
end ram_pkg;

package body ram_pkg is

function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
  	return ret_val;
end function;

end package body ram_pkg;


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ram_pkg.all;
USE std.textio.all;

entity block_ram is
generic (
    RAM_WIDTH : integer := 16;                      -- Specify RAM data width
    RAM_DEPTH : integer := 128;                    -- Specify RAM depth (number of entries)
    RAM_PERFORMANCE : string := "LOW_LATENCY";      -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    --INIT_FILE : string := "RAM_INIT.dat"            -- Specify name/location of RAM initialization file if using one (leave blank if not)
    C_RAM_TYPE : string := "block"
	);

port (
        addra : in std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);     -- Address bus, width determined from RAM_DEPTH
        dina  : in std_logic_vector(RAM_WIDTH-1 downto 0);		  		 -- RAM input data
        clka  : in std_logic;                       			  		 -- Clock
        wea   : in std_logic;                       			  		 -- Write enable
        douta : out std_logic_vector(RAM_WIDTH-1 downto 0)   			  -- RAM output data
    );

end block_ram;

architecture rtl of block_ram is

constant C_RAM_WIDTH : integer := RAM_WIDTH;
constant C_RAM_DEPTH : integer := RAM_DEPTH;
constant C_RAM_PERFORMANCE : string := RAM_PERFORMANCE;
--constant C_INIT_FILE : string := INIT_FILE;


signal douta_reg : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others => '0');

type ram_type is array (C_RAM_DEPTH-1 downto 0) of std_logic_vector (C_RAM_WIDTH-1 downto 0);          -- 2D Array Declaration for RAM signal

signal ram_data : std_logic_vector(C_RAM_WIDTH-1 downto 0) ;

-- Following code defines RAM

signal ram_name : ram_type := (others =>(others =>'0'));

attribute ram_style : string ;
attribute ram_style of ram_name : signal is C_RAM_TYPE;

begin

process(clka)
begin
if(rising_edge(clka)) then
    if(wea = '1') then
        ram_name(to_integer(unsigned(addra))) <= dina;
    end if;
    ram_data <= ram_name(to_integer(unsigned(addra)));
end if;
end process;

--  Following code generates LOW_LATENCY (no output register)
--  Following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing

no_output_register : if C_RAM_PERFORMANCE = "LOW_LATENCY" generate
    douta <= ram_data;
end generate;

--  Following code generates HIGH_PERFORMANCE (use output register)
--  Following is a 2 clock cycle read latency with improved clock-to-out timing


end rtl;