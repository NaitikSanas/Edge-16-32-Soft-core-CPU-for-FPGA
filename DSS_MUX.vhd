library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dss_mux is
port (
a : in std_logic_vector(15 downto 0);
b : in std_logic_vector(15 downto 0);
c : in std_logic_vector(15 downto 0);
d : in std_logic_vector(15 downto 0);
e : in std_logic_vector(15 downto 0);
f : in std_logic_vector(15 downto 0);
g : in std_logic_vector(15 downto 0);
h : in std_logic_vector(15 downto 0);

sel: in std_logic_Vector(2 downto 0);
y : out std_logic_vector(15 downto 0)
);
end dss_mux;

architecture Behavioral of dss_mux is
CONSTANT ZERO : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";

begin
WITH SEL SELECT Y <= A WHEN "000", 
							B WHEN "001", 
							C when "010", 
							D when "011", 
							e when "100",
							f when "101",
							g when "110",
							h when "111",
							ZERO WHEN OTHERS;
end Behavioral;

