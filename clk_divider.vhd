library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity clock_divider is
port (
		clk: in std_logic;
		clk_out, display_clk, UART_CLK, tclk : out std_logic := '0'
		);
end clock_divider;

architecture Behavioral of clock_divider is
signal count: integer range 0 to 100_000_000;
signal  cnt: integer range 0 to 200_000_000;
CONSTANT  threshold : integer range 0 to 1048575:= 1000000;
signal dclk,clk_outx, temp0, temp1,temp2, Pclk : std_logic;

begin
UART_CLK <= TEMP1;
display_Clk <= dclk;

process(clk)
begin

if rising_edge(clk) then

if count = 500_000 then
count <= 0;
else 
count <= count + 1;
end if;

if count > 0 and count < 250_000 then  
CLK_OUT<= '1'; 

else 
CLK_OUT <= '0';
end if;


if cnt = 200_000_000 then 
   cnt <= 0;
	else cnt <= cnt + 1;
	end if;
	
if cnt > 0 and cnt < 100_000_000 then 
tclk <= '1';
else tclk <= '0';
end if;

dclk <= not dclk;  --50 MHz

end if;

end process;

MHz25:PROCESS(DCLK)
BEGIN
IF RISING_EDGE(DCLK) THEN

TEMP0 <= NOT TEMP0;

END IF;
END PROCESS;

MHz125 : PROCESS(TEMP0)
BEGIN
IF RISING_EDGE(TEMP0) THEN
TEMP1<= NOT TEMP1;
END IF; 
END PROCESS;
end Behavioral;

