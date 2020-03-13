
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:59:57 09/26/2019 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.NUMERIC_STD.all;
--use IEEE.std_logic_signed.all;
					
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
PORT (
		A, B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		FUNCT : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		R : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		
);
end ALU;

architecture Behavioral of ALU is
SIGNAL X, Y :STD_LOGIC_VECTOR(15 DOWNTO 0);
begin
--ADD_R <= A + B;
--SUB_R <= A - B;
--OR_R <= A OR B;
--AND_R <= A AND B;
--XOR_R <= A XOR B;

WITH FUNCT SELECT R <= A +B WHEN "0000",
							  A - B WHEN "0001",
						     --A / B WHEN "0010",
						     A OR B WHEN "0011",
							  
						     A AND B WHEN "0100",
						     A XOR B WHEN "0101",
						     A NAND B WHEN "0110",
						     A NOR B WHEN "0111",
							  
						     NOT A WHEN "1000",
						     A + 1 WHEN "1001",
						     A - 1 WHEN "1010",
							  (not a) + 1 when "1011", --apply 2s complement function
							  A(14 downto 0) &'0' WHEN "1100",
							  '0'& A(15 downto 1) WHEN "1101",
							  "0000000000000000" WHEN OTHERS;
										
end Behavioral;