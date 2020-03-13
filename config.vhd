LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CPU_edge IS
PORT(
		CLK:IN STD_LOGIC;
		rx:IN STD_LOGIC;
		tx:out STD_LOGIC;
		inst_in :IN STD_LOGIC_VECTOR(31 DOWNTO 0);	
		pcntr : out  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		
		W_EN, R_EN, ref_clk, buf_en : OUT STD_LOGIC;
		DOUT: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		ADDRESS_BUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END CPU_edge;

ARCHITECTURE BEHAVIORAL OF CPU_edge IS
	COMPONENT ALU_inst_executer
	PORT(
		inst_in : IN std_logic_vector(31 downto 0);

		agb : IN std_logic;
		alb : IN std_logic;
		aeqb : IN std_logic;
		tx_busy : IN std_logic;
		rx_busy : IN std_logic;
		clkp : IN std_logic;
		clkn : IN std_logic;          
		EN : OUT std_logic;
		SEL : OUT std_logic;
		CMP_EN : OUT std_logic;
		buf_en : OUT std_logic;
		write_ext : OUT std_logic;
		ALE : OUT std_logic;
		Read_ext : OUT std_logic;
		mem_re : OUT std_logic;
		mem_we : OUT std_logic;
		rs : OUT std_logic;
		tx_en : OUT std_logic;
		OP_A : OUT std_logic_vector(4 downto 0);
		OP_B : OUT std_logic_vector(4 downto 0);
		WDST : OUT std_logic_vector(4 downto 0);
		RDST : OUT std_logic_vector(4 downto 0);
		FUNCT : OUT std_logic_vector(3 downto 0);
		sptr : OUT std_logic_vector(11 downto 0);
		mode, addr_src : OUT std_logic_vector(1 downto 0);
		DSS : OUT std_logic_vector(2 downto 0);
		DATA_to_alu : OUT std_logic_vector(15 downto 0);
		pc : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;


	COMPONENT EXECUTION_ENGINE
	PORT(
	  CLK, EN, SEL, CMP_EN: IN STD_LOGIC;
	  OP_A, OP_B, WDST, RDST: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	  FUNCT: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	  DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  DATA_OUT: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	  aeqb, agb, alb: OUT STD_LOGIC
	  
);
	END COMPONENT;


	COMPONENT ROM
	PORT(
		ADDRESS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);          
		DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;



	COMPONENT CLOCK_DIVIDER
      port (clk: in std_logic;	
		clk_out, display_clk, UART_CLK, tclk : out std_logic := '0'
		);
  	END COMPONENT;


COMPONENT ADDRES_LATCH
	PORT(
		clk, en :in std_logic;
		mode : IN std_logic_vector(1 downto 0);
		RS : in std_logic;
		set_addr0 : IN std_logic_vector(15 downto 0);
		set_addr1: IN std_logic_vector(15 downto 0);
		address : out std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	

	
	COMPONENT MEMORY
	PORT(
		DIN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		WP : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		RP : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		WCLK : IN STD_LOGIC;
		RCLK : IN STD_LOGIC;
		WE : IN STD_LOGIC;
		RE : IN STD_LOGIC;          
		DOUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;



	COMPONENT dss_mux
	PORT(
		a : IN std_logic_vector(15 downto 0);
		b : IN std_logic_vector(15 downto 0);
		c : IN std_logic_vector(15 downto 0);
		d : IN std_logic_vector(15 downto 0);
		e : IN std_logic_vector(15 downto 0);
		f : IN std_logic_vector(15 downto 0);
		g : IN std_logic_vector(15 downto 0);
		h : IN std_logic_vector(15 downto 0);
		sel : IN std_logic_vector(2 downto 0);          
		y : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	COMPONENT mux21
	generic(bus_width:integer:=16);
	port (
      a, b, c : in std_logic_vector(bus_width-1 downto 0);
	   sel  : in std_logic_vector(1 downto 0);
		y    : out std_logic_Vector(bus_width-1 downto 0)
		);
	END COMPONENT;

component CLK_PLL
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic
 );
end component;

	COMPONENT uart
	PORT(
		clk : IN std_logic;
		reset_n : IN std_logic;
		tx_ena : IN std_logic;
		tx_data : IN std_logic_vector(7 downto 0);
		rx : IN std_logic;          
		rx_busy : OUT std_logic;
		rx_error : OUT std_logic;
		rx_data : OUT std_logic_vector(7 downto 0);
		tx_busy : OUT std_logic;
		tx : OUT std_logic
		);
	END COMPONENT;
component Edge_DCM
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  CLK_OUT3          : out    std_logic
 );
end component;

-- INST_TAG_END ------ End INSTANTIATION Template ------------

SIGNAL uart_clk, EN, RCM, CMP_EN, SYS_CLK, ALE, TX_EN, RX_BUSY, RX_ERROR, TX_BUSY, WE, RE : STD_LOGIC;
signal clkp, clkn, aeqb ,alb, agb, mem_en ,rs, mem_re, mem_we, imm_addr, addr_src : std_logic; 
SIGNAL OPA, OPB, WDST, RDST, CMPR0, CMPR1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL FUNCT : STD_LOGIC_VECTOR(3 DOWNTO 0);	
SIGNAL sp : STD_LOGIC_VECTOR(15 DOWNTO 0);	
SIGNAL  RX_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL STATUS, MODE, BFI, tctrl, asrc : STD_LOGIC_VECTOR(1 DOWNTO 0);	
SIGNAL DSS : STD_LOGIC_VECTOR(2 DOWNTO 0);	
SIGNAL DIN, DBUF, DATA_TO_EE, UART_RXD, DATA_FROM_MEMORY, ad, bd, cd, dd :STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL INSTRUCTION, timer_data, pc32 :STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PC, SADDR, ADDRESS, Immaddr, tempaddr, finalAddress  :STD_LOGIC_VECTOR(15 DOWNTO 0):= "0000000000000000";
CONSTANT ZERO : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";

BEGIN

ref_clk <= clkp;
	address_source:mux21 port map(
	 a => address, b=> instruction(15 downto 0), c => sp, y => finaladdress, sel=> asrc); 

	ADDRESS_BUS <= finalADDRESS;
W_EN <= WE;
R_EN <= RE;
------------clock configuration------------
clkp <= sys_clk;
clkn <= not sys_clk;

--sys_clk <= clk;
---uart_clk <= uclk;


CPU_CLOCK_DIVIDER: CLOCK_DIVIDER PORT MAP(
		CLK => CLK,
		CLK_OUT => SYS_CLK, uart_clk => uart_clk);

--Egde_DCM0: edge_dcm
--  port map
--   (-- Clock in ports
--    CLK_IN1 => clk,
--    -- Clock out ports
--    CLK_OUT1 => clkp,
--    CLK_OUT2 => clkn,
--	 clk_out3 => uart_clk);
--------------------------------------------
 DATA_MEMORY: MEMORY PORT MAP(
		DIN => DBUF ,
		WP => finalADDRESS(11 DOWNTO 0),
		RP => finalADDRESS(11 DOWNTO 0),
		WCLK =>clkp,
		RCLK =>clkp ,
		WE => mem_WE ,
		RE => mem_RE,
		DOUT => DATA_FROM_MEMORY 
	);

 
	UART_SIO: uart PORT MAP(
		clk => uart_clk,
		reset_n => '1',
		tx_ena => tx_en ,
		tx_data => dbuf(7 downto 0),
		rx => rx,
		rx_busy => rx_busy,
		--rx_error => ,
		rx_data => rx_data(7 downto 0),
		tx_busy => tx_busy,
		tx => tx
	);



	--pc32 <= "0000000000000000"&pc;
	DSS_Sel: dss_mux PORT MAP(
		a => data_in,
		b => din,
		c => rx_data,
		d => data_from_memory,
		e => zero,
		f => pc ,
		g => zero ,
		h => zero ,
		sel => DSS ,
		y => data_to_ee
	);


  ADDRESS_HOLDING_LATCH: ADDRES_LATCH PORT MAP(
		CLK => clkp,
		EN => ALE,
		MODE => MODE ,
		rs => rs,
		SET_ADDR0 => INSTRUCTION(15 DOWNTO 0),
		SET_ADDR1 => dbuf(15 DOWNTO 0),
		ADDRESS => ADDRESS
	);



--	PROGRAM_ROM: ROM PORT MAP(
--		ADDRESS =>PC,
--		DATA => INSTRUCTION 
--	);
instruction <= inst_in;
pcntr <= pc;
DATA_EXECUTION_ENGINE: EXECUTION_ENGINE PORT MAP(
	   clk => clkp,
		EN => EN ,
		SEL => RCM ,
		CMP_EN => CMP_EN ,
		OP_A => OPA ,
		OP_B => OPB ,
		WDST => WDST,
		RDST => RDST,
		FUNCT => FUNCT,
		
		DATA_IN => DATA_TO_EE,
		DATA_OUT => DBUF,
		aeqb => aeqb,
		agb => agb,
		alb => alb
	);


	CONTROL_ENGINE: ALU_INST_EXECUTER PORT MAP(
		INST_IN => INSTRUCTION ,
		CLKp =>  clkp,
		sptr => sp(11 downto 0),
		addr_src => asrc,
		CLKn =>  clkn,
		
		tx_en => tx_en,
		tx_busy => tx_busy,
		rx_busy => rx_busy,
		aeqb => aeqb,
		agb => agb,
		alb => alb,
		MODE => MODE,
		ALE => ALE,
		DSS => DSS,
		rs => rs,
		mem_re => mem_re,
		mem_we => mem_we,
		read_ext => re,
		write_ext => we,
--		CLK => SYSwCLK ,
		EN =>EN ,
		BUF_EN =>BUF_EN ,
		SEL => RCM,
		CMP_EN =>CMP_EN ,
		OP_A => OPA,
		OP_B => OPB,
		WDST => WDST,
		RDST => RDST,
		FUNCT => FUNCT,
		DATA_TO_ALU => DIN,
		PC => PC
	);
dout <= dbuf;
--PROCESS( clkp, BUF_EN)
--BEGIN
--
--IF BUF_EN = '1' THEN
--IF RISING_EDGE(clkp) THEN 
--		DOUT <= DBUF;
--END IF;
--END IF;

--END PROCESS;
END BEHAVIORAL;

