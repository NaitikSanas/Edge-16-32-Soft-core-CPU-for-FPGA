library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Register_file is
port (
		DATA0, DATA1 : in std_logic_Vector(15 downto 0);
		WDest, op_a, op_b, RDST: in std_logic_Vector(4 downto 0);
		clk, en, SEL : in std_logic;
		a, b, DOUT: OUT std_logic_Vector(15 downto 0)

);
end Register_file;

architecture Behavioral of Register_file is

SIGNAL DIN : STD_LOGIC_VECTOR(15 DOWNTO 0):="0000000000000000";
type reg_array is array(0 to 31) of std_logic_vector(15 downto 0);
signal r0, r1, r2, r3, r4, r5, r6, r7, r8 , r9, r10, r11, r12, r13,r14, r15 : std_logic_vector(15 downto 0);
signal reg_file : reg_array;
signal wdst, rdest, opa, opb, cmpa, cmpb : integer range 0 to 31;
begin
WITH SEL SELECT DIN <= DATA0 WHEN '1', DATA1 WHEN '0', "0000000000000000" WHEN OTHERS;
--wdst  <= conv_integer(wdest);
--rdest <= conv_integer(rdst);
--opa   <= conv_integer(op_a);
--opb   <= conv_integer(op_b);
--
--a <= reg_file(opa);
--b <= reg_file(opb);
--
--dout <= reg_file(rdest);

with op_a(3 downto 0) select a <= r0 when "0000",
							 r1 when  "0001",
							 r2 when  "0010",
							 r3 when  "0011",
							 r4 when  "0100",
							 r5 when  "0101",
							 r6 when  "0110",
							 r7 when  "0111",
							 r8 when  "1000",
							 r9 when  "1001",
							 r10 when "1010",
							 r11 when "1011",
							 r12 when "1100",
							 r13 when "1101",
							 r14 when "1110",
							 r15 when "1111",
							 "0000000000000000" when others;
							 
with op_b(3 downto 0) select b <= r0 when "0000",
							 r1 when "0001",
							 r2 when "0010",
							 r3 when "0011",
							 r4 when "0100",
							 r5 when "0101",
							 r6 when "0110",
							 r7 when "0111",
							 r8 when "1000",
							 r9 when "1001",
							 r10 when "1010",
							 r11 when "1011",
							 r12 when "1100",
							 r13 when "1101",
							 r14 when "1110",
							 r15 when "1111",
							 "0000000000000000" when others;
							
with rdst(3 downto 0) select dout <= r0 when "0000",
							 r1 when "0001",
							 r2 when "0010",
							 r3 when "0011",
							 r4 when "0100",
							 r5 when "0101",
							 r6 when "0110",
							 r7 when "0111",
							 r8 when "1000",
							 r9 when "1001",
							 r10 when "1010",
							 r11 when "1011",
							 r12 when "1100",
							 r13 when "1101",
							 r14 when "1110",
							 r15 when "1111",
							 "0000000000000000" when others;
							 
process(clk, en)
begin
if en = '1' then
   if rising_edge(clk) then 
--	    reg_file(wdst) <= din;
		 
		 if wdest = "00000" then r0 <= din;
		 elsif wdest = "00001" then r1 <= din;
		 elsif wdest = "00010" then r2 <= din;
		 elsif wdest = "00011" then r3 <= din;
		 elsif wdest = "00100" then r4 <= din;
		 elsif wdest = "00101" then r5 <= din;
		 elsif wdest = "00110" then r6 <= din;
		 elsif wdest = "00111" then r7 <= din;
		 elsif wdest = "01000" then r8 <= din;
		 elsif wdest = "01001" then r9 <= din;
		 elsif wdest = "01010" then r10 <= din;
		 elsif wdest = "01011" then r11 <= din;
		 elsif wdest = "01100" then r12 <= din;
		 elsif wdest = "01101" then r13 <= din;
		 elsif wdest = "01110" then r14 <= din;
		 elsif wdest = "01111" then r15 <= din;
		 end if;
		 
   end if;
end if;

end process;

end Behavioral;

