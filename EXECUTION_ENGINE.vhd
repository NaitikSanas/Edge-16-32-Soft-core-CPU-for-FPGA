----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:00 09/26/2019 
-- Design Name: 
-- Module Name:    EXECUTION_ENGINE - Behavioral 
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

entity EXECUTION_ENGINE is
PORT(
	  CLK, EN, SEL, CMP_EN: IN STD_LOGIC;
	  OP_A, OP_B, WDST, RDST: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	  FUNCT: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	  DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	  aeqb, agb, alb: OUT STD_LOGIC
	  	


);
end EXECUTION_ENGINE;

architecture Behavioral of EXECUTION_ENGINE is
	COMPONENT ALU
	PORT(
		A : IN std_logic_vector(15 downto 0);
		B : IN std_logic_vector(15 downto 0);
		FUNCT : IN std_logic_vector(3 downto 0);          
		R : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	
	COMPONENT Register_file
	port (
		DATA0, DATA1 : in std_logic_Vector(15 downto 0);
		WDest, op_a, op_b, RDST: in std_logic_Vector(4 downto 0);
		clk, en, SEL : in std_logic;
		a, b, DOUT: OUT std_logic_Vector(15 downto 0)

);
	END COMPONENT;


	COMPONENT COMPARATOR
	PORT(
		A, B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK, EN : IN STD_LOGIC;
		aeqb, agb, alb : OUT STD_LOGIC			
		);
	END COMPONENT;




SIGNAL A, B, RESULT, CMP_OPA, CMP_OPB: std_logic_vector(15 downto 0);
SIGNAL CLOCK : STD_LOGIC;
--SIGNAL STATUS: std_logic_vector(1 downto 0);
begin
	CLOCK <=  CLK;
	COMPARATOR_UNIT: COMPARATOR PORT MAP(
		A => a,
		B => b,
		CLK => CLOCK,
		EN => CMP_EN ,
		aeqb => aeqb,
		agb => agb,
		alb => alb
	);

	ALU32_BLOCK: ALU PORT MAP(
		A => A ,
		B => B,
		FUNCT => FUNCT ,
		R => RESULT
	);
	

	Register_file_32X32: Register_file PORT MAP(
		DATA0 => RESULT,
		DATA1 => DATA_IN,
		WDest => WDST,

		op_a => OP_A,
		op_b => OP_B,
		RDST => RDST,
		DOUT => DATA_OUT,
		clk => CLOCK,
		en => EN,
		SEL => SEL,
		a => A,
		b => B
	);



end Behavioral;

