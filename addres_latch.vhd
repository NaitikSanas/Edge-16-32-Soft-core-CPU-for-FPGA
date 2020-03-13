library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity addres_latch is
port(
		clk, en :in std_logic;
		mode : IN std_logic_vector(1 downto 0);
		RS : in std_logic;
		set_addr0 : IN std_logic_vector(15 downto 0);
		set_addr1: IN std_logic_vector(15 downto 0);
		address : out std_logic_vector(15 downto 0)
);
end addres_latch;

architecture Behavioral of addres_latch is
SIGNAL TEMP, addr: std_logic_vector(15 downto 0):="0000000000000000";
begin
ADDRESS <= TEMP;
with rs select addr <= set_Addr1 when '1', set_addr0 when '0', set_addr0 when others;
process(clk, EN)
begin
if en = '1' then
 if rising_edge(clk) then
	if mode = "01" then
	   temp <= addr;
		
	elsif mode = "10" then
	  TEMP <= TEMP + 1;
	elsif mode = "11" then
	   TEMP <=TEMP- 1;
	end if;
 end if;
end if;
end process;
end Behavioral;

