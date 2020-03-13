library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity ROM is
port (
address : in std_logic_vector(15 downto 0);
data : out std_logic_vector(31 downto 0)
);
end ROM;

architecture Behavioral of ROM is
type PROM is array(0 to 15) of std_logic_vector(31 downto 0);

constant program :PROM := (
"00001000000000000010000000000000",
"00001000001000001110000000000000",
"00001000010000000000000000000000",
"00011000000000000000000000000000",
"00000100000000000000011000000000",
"00000100010000100001010010000000",
"00010100010000010000000000001000",
"00010000000000000000110000000000",
"00001000010000000000000000000000",
"00011000000000000000000000000000",
"00000100000000000000011010000000",
"00000100010000100001010010000000",
"00010100010000010000000000000010",
"00010000000000000010010000000000",
"00000000000000000000000000000000",
"00000000000000000000000000000000"


);
begin


process(address)
begin
data <= Program(conv_integer(address(3 downto 0)));
end process;
end Behavioral;