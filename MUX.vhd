library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
port (
a : in std_logic_vector(31 downto 0);
b : in std_logic_vector(31 downto 0);
c : in std_logic_vector(31 downto 0);
d : in std_logic_vector(31 downto 0);
sel: in std_logic_Vector(1 downto 0);
y : out std_logic_vector(31 downto 0)
);
end mux;

architecture Behavioral of mux is
CONSTANT ZERO : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";

begin
WITH SEL SELECT Y <= A WHEN "00", B WHEN "01", C when "10", D when "11",  ZERO WHEN OTHERS;
end Behavioral;

