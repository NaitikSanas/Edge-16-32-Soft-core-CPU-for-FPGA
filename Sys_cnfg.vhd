library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sys_cnfg is
port (
      clk, reset : in std_logic;
      dout : out std_logic_vector(7 downto 0) --data out bus
);
end Sys_cnfg;

architecture Behavioral of Sys_cnfg is
COMPONENT CPU_edge
	PORT(
		CLK:IN STD_LOGIC;
		rx:IN STD_LOGIC;
		tx:out STD_LOGIC;
		 buf_en : OUT STD_LOGIC;
		 inst_in :IN STD_LOGIC_VECTOR(31 DOWNTO 0);	
		pcntr : out  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		
		W_EN, R_EN, ref_clk : OUT STD_LOGIC;
		DOUT: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
end component;

	COMPONENT ROM
	PORT(
		address : IN std_logic_vector(15 downto 0);          
		data : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;


signal inst : std_logic_vector(31 downto 0);

signal pcntr,data: std_logic_vector(15 downto 0);
--signal sptr: std_logic_vector(11 downto 0);
signal we , ref_clk, buf_en: std_logic;
begin	

  program_ROM: ROM PORT MAP(
		address =>pcntr,
		data =>  inst
	);
	core0: CPU_edge PORT MAP(
		CLK => clk,
	  rx => '0',
	--	tx => tx ,
		inst_in => inst,
		pcntr => pcntr ,
      DATA_IN =>"0000000000000000" ,
    W_EN => we,
	 ref_clk => ref_clk,
	--	R_EN => ,
		DOUT => data, 
		buf_en => buf_en
	--	ADDRESS_BUS => 
	);


process(ref_clk, we)
begin
if buf_en = '1' then	
if rising_edge(ref_clk) then
   dout <= data(7 downto 0);
end if;
end if;
end process;
end Behavioral;

