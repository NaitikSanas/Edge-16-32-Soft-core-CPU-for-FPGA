
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:51:23 01/11/2020 
-- Design Name: 
-- Module Name:    mux21 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux21 is
generic(
			bus_width : integer := 16 
        );
port (
      a, b, c : in std_logic_vector(bus_width-1 downto 0);
	   sel  : in std_logic_vector(1 downto 0);
		y    : out std_logic_Vector(bus_width-1 downto 0)
		);
end mux21;

architecture Behavioral of mux21 is

begin
with sel select y <=  a when "00", b when "01", c when "10", a when others;

end Behavioral;

