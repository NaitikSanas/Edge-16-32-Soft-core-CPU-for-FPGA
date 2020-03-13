library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
entity ALU_inst_executer is
port (
		inst_in : in std_logic_vector(31 downto 0);
		agb, alb, aeqb : in std_logic;
		tx_busy, rx_busy : in std_logic;
		clkp, clkn: in std_logic;
		EN, SEL, CMP_EN, buf_en, write_ext,ALE, Read_ext, mem_re, mem_we, rs, tx_en: out std_logic;
		OP_A, OP_B, WDST, RDST: out STD_LOGIC_VECTOR(4 DOWNTO 0);
	   FUNCT: out STD_LOGIC_VECTOR(3 DOWNTO 0);
	   sptr: out STD_LOGIC_VECTOR(11 DOWNTO 0);
	   addr_src: out STD_LOGIC_VECTOR(1 DOWNTO 0):="00";
	   mode: out STD_LOGIC_VECTOR(1 DOWNTO 0);
	   DSS: out STD_LOGIC_VECTOR(2 DOWNTO 0);
	   DATA_to_alu : out STD_LOGIC_VECTOR(15 DOWNTO 0);
	   pc: out STD_LOGIC_VECTOR(15 DOWNTO 0)
		
	--   clk_rate : out STD_LOGIC_VECTOR(19 DOWNTO 0)

);
end ALU_inst_executer;

architecture Behavioral of ALU_inst_executer is

constant hold, internal, D16, indirect: std_logic := '1';
constant released, external, D8, direct : std_logic := '0';

constant io_device: std_logic_vector(2 downto 0):= "000";
constant program: std_logic_vector(2 downto 0):= "001";
constant UART: std_logic_vector(2 downto 0):= "010";
constant memory: std_logic_vector(2 downto 0):= "011";
constant timer: std_logic_vector(2 downto 0):= "100";
constant PCount: std_logic_vector(2 downto 0):= "101";

constant direct_addr: std_logic_vector(1 downto 0):= "00";
constant imm: std_logic_vector(1 downto 0):= "01";
constant stack_pointer: std_logic_vector(1 downto 0):= "10";

signal inSubroute : boolean := false;

signal ihld : std_logic;
signal state, istate, state_store : integer range 0 to 3;

signal PCNT, returnPC : integer range 0 to 65535 := 0;
signal sp_ovfVector, sp_uflVector : integer range 0 to 65535;
signal sp, stack_size : integer range 0 to 4095 := 127;
signal RCM : std_logic;
signal dtype : std_logic;


signal inst: std_logic_vector(31 downto 0);

signal jmp_addr, imm_pc, PC_store: std_logic_vector(15 downto 0);
signal byte, word: std_logic_vector(15 downto 0);
signal opcode : std_logic_vector(5 downto 0);
signal R0, R1, R2 : std_logic_vector(4 downto 0);
signal fx : std_logic_vector(3 downto 0);
constant S_r0 : std_logic:= '0';
constant S_r2 : std_logic:= '1';
signal wsrc :std_logic;

--31 30 29 28 27 26| 25 24 23 22 21 | 20 19 18 17 16 |15 14 13, 12  11| 10 9 8 7 | 6 5 ,4 3 2 1
function inc (var : integer) return integer is
begin
 return var + 1;
end inc;

begin
sptr <= conv_std_logic_vector(sp, 12);
sel <= RCM;
pc <= conv_std_logic_vector(pcnt, 16);
opcode <= inst(31 downto 26);
R0 <= inst(25 downto 21);  
R1 <= inst(20 downto 16);
r2 <= inst(15 downto 11);
Fx <= inst(10 downto 7);
byte(7 downto 0) <=inst(20 downto 13);
word <= inst(20 downto 5);
jmp_addr <= inst(15 downto 0);
imm_pc <= inst(25 downto 10);

op_a <= r0;
op_b <= r1;
funct <= fx;
rdst <= r0;
with Dtype select data_to_alu <= word when '0', byte when '1', byte when others;
with WSrc select wdst <= r0 when S_r0, r2 when S_r2, r2 when others;

process(clkp)
begin
if rising_edge(clkp) then 
  if Ihld = released then
	 inst <= inst_in;
	 end if;
	 end if;
	
end process;
process(clkn)
begin	  
if rising_edge(clkn) then 
------------instruction execution--------------------    
------------------- data execution instruction ----------------------   
  if opcode = "000001" then  --function r0, r1, r2 function_type
  if state = 0 then
	    ihld <= hold;
		 en <= '1';
--		 op_a <= r0;
--       op_b <= r1;
		-- wdst <= r2;
		 wsrc <= s_r2;
		 state <= inc(state);
		 RCM <= internal;
   elsif state =1 then 
		 en <= '0';
		 state <= 0;
		 ihld <= released;
		 pcnt <= inc(pcnt);
    end if;
	 
 elsif opcode = "000010" then --imm_byte R0:write_register, #value
	if state = 0 then
		ihld <= hold;
		RCM <= external;
		DSS <= PROGRAM;
		dtype <= '1';
		en <= '1';
		--wdst <= r0;
		wsrc <= s_r0;
		state <= inc(state);
	elsif state = 1 then
		en <= '0';
		ihld <= released;
		pcnt <= inc(pcnt);
		state <= 0;
	end if;
		
 elsif opcode = "000011" then --imm_word R0 #VALUE 
   if state = 0 then
		ihld <= hold;
		RCM <= external;
		DSS <= PROGRAM;
		--wdst <= r0;
		wsrc <= s_r0;
		dtype <= '0';
		en <= '1';
		state <= inc(state);
	elsif state = 1 then
	  ihld <= released;
	  en <= '0';
	  pcnt <= inc(pcnt);
	  state <= 0;
	 end if;
	 
 elsif opcode = "000100" then --goto #Location_X
		pcnt <= conv_integer(imm_pc);
 
 elsif opcode = "000101" then --BEQ r0,r1, location
	if state = 0 then 
	   ihld <= hold; --hold instruction
		cmp_en <= '1'; --enable comparator
	   state <= inc(state); -- goto next state
	elsif state = 1 then
	   cmp_en <= '0'; --disable comparators	
		ihld <= released;--release inst
		state <= 0; 	
 	   if aeqb = '1' then --if r0 is equal to r1
	      pcnt <= conv_integer(jmp_addr);--load location to service rout		
		else 
		   pcnt <= inc(pcnt);--else increment 	
		end if;
	end if;
--------------------------memory operations------------------------------	
 elsif opcode = "000110" then --write_Dbuf Rx
	  if state = 0 then
	     ihld <= hold;
	     buf_en <= '1'; 
		  state <= inc(state);
	  elsif state = 1 then
	     ihld <= released;
	     buf_en <= '0';
		  state <= 0;
	     pcnt <= inc(pcnt);
	  end if;
	  
 elsif opcode = "000111" then --LADDR #value // load address latch 
	  if state = 0 then
	    ihld <= hold;
	    ale <= '1';
		 rs <= direct;
		 mode <= "01"; --load imm address
		 state <= inc(state);
	  elsif state = 1 then
	    ihld <= released;
	    ale <= '0';
		 state <= 0;
		 pcnt <= inc(pcnt);
		end if; 
		
 elsif opcode = "001000" then --INC_ADL // INCREMENT address latch 
	  if state = 0 then
	    ihld <= hold;
	    ale <= '1';
		 mode <= "10"; -- INC address
		 state <= inc(state);
	  elsif state = 1 then
	    ihld <= released;
	    ale <= '0';
		 state <= 0;
		 pcnt <= inc(pcnt);
		end if; 
		
 elsif opcode = "001001" then --dec_ADL // INCREMENT address latch 
	  if state = 0 then
	    ihld <= hold;
	    ale <= '1';
		 mode <= "11"; -- dec address
		 state <= inc(state);
	  elsif state = 1 then
	    ihld <= released;
	    ale <= '0';
		 state <= 0;
		 pcnt <= inc(pcnt);
		 END IF;
		 
 elsif opcode = "001010" then --intMem_load r0, #location //load data at specified imm location in internal memory
		if state = 0 then 
		  ihld <= hold;
		  ale <= '1';
		  rs <= direct;
		  DSS <= memory;
		  mode <= "01";
		  state <= inc(state);
		  
		elsif state = 1 then
		  ale <= '0';
		  state <= inc(state);
		  mem_re <= '1';
		  
      elsif state = 2 then 
        mem_re <= '0';
		  rcm <= external;
		  en <= '1';
		  state <=inc(state);
		  
		elsif state = 3 then 
		  en <= '0';
		  ihld <= released;
		  pcnt <= inc(pcnt);
		  state <= 0;
		end if;
		
 elsif opcode = "001011" then --intMem_write rx, #location 
     if state = 0 then 
        ihld <= hold;
		  --point to targer register
		  rs <= direct;
		  ale <= '1'; --enable address latch
		  
		  mode <= "01";--set mode to load address
		  state <= inc(state); --goto next state
		  
	 elsif state = 1 then
		  buf_en <= '0'; --disable buffer en
		  ale <= '0'; --disable addr latch 
		  mem_we <= '1'; --strobe write enable 
		  state <= inc(state);
		  
	elsif state = 2 then 
		  mem_we <= '0';
		  
		  ihld <= released;
		  pcnt <= inc(pcnt);
		  state <= 0;
	end if;
	
 elsif opcode = "001100" then --DbusR r0, #location//load data from io device from specified loacation	 
		if state = 0 then 
		  ihld <= hold;
		  ale <= '1';
		  rs <= direct;
		  DSS <= io_device;
		  mode <= "01";
		  state <= inc(state);
		  
		elsif state = 1 then
		  ale <= '0';
		  state <= inc(state);
		  mem_re <= '1';
		  
      elsif state = 2 then 
        mem_re <= '0';
		  rcm <= external;
		  en <= '1';
		  state <=inc(state);
		  
		elsif state = 3 then 
		  en <= '0';
		  ihld <= released;
		  pcnt <= inc(pcnt);
		  state <= 0;
		end if;
		
-----------stack instructions operation----------- 		
---Push inst:
      --preincrement address of SP
		--store content into memory
---pop inst:
      --read content from Current value of address of SP
		--post decrement of address of SP

--configure stack : define stack region
     		
      	
elsif opcode = "001101" then --IntMemRead_sequential Rx
		if state = 0 then 
		  ihld <= hold;
		  DSS <= memory; 
		  
		  state <= inc(state);
		 -- wdst <= r0; ---set register destination
		  wsrc <= s_r0;
		  mem_re <= '1'; --enable read
      elsif state = 1 then
		  mem_re<= '0';  --disable read
		  rcm <= external; --set RCM to external
		  en <= '1'; --enable execution engine
        state <= inc(state);
      elsif state = 2 then
		  ihld <= released;
        en <= '0';
		 
		  state <= 0;
		  pcnt <= inc(pcnt);
		 end if;
		 
elsif opcode = "001110" then --IntMemWrite_sequential Rx
    if state = 0 then 
		 ihld <= hold;
		 state <= inc(state);
		 mem_we <= '1';
	elsif state = 1 then
	   ihld <= released;
		state <= 0;
		mem_we <= '0';
		
		pcnt <= inc(pcnt);
    end if;
	 
 elsif opcode = "001111" then --LADDR Rx // load indirect address 
	  if state = 0 then
	    ihld <= hold;
	    ale <= '1';
		 rs <= indirect;
		 mode <= "01"; --load address
		 state <= inc(state);
	  elsif state = 1 then
	    ihld <= released;
	    ale <= '0';
		 state <= 0;
		 pcnt <= inc(pcnt);
		end if;
		
elsif opcode = "010000" then --continue 
   pcnt <= inc(pcnt);  
	
 elsif opcode = "010001" then --BGT r0,r1, location
	if state = 0 then 
	   ihld <= hold; --hold instruction
		cmp_en <= '1'; --enable comparator
	   state <= inc(state); -- goto next state
	elsif state = 1 then
	   cmp_en <= '0'; --disable comparators	
		ihld <= released;--release inst
		state <= 0; 	
 	   if agb = '1' then --if r0 is equal to r1
	      pcnt <= conv_integer(jmp_addr);--load location to service rout		
		else 
		   pcnt <= inc(pcnt);--else increment 	
		end if;
	end if;

 elsif opcode = "010010" then --BLT r0,r1, location
	if state = 0 then 
	   ihld <= hold; --hold instruction
		cmp_en <= '1'; --enable comparator
	   state <= inc(state); -- goto next state
	elsif state = 1 then
	   cmp_en <= '0'; --disable comparators	
		ihld <= released;--release inst
		state <= 0; 	
 	   if alb = '1' then --if r0 is equal to r1
	      pcnt <= conv_integer(jmp_addr);--load location to service rout		
		else 
		   pcnt <= inc(pcnt);--else increment 	
		end if;
	end if;

 elsif opcode = "010011" then --Uart_tX Rx
    if state = 0 then 
      ihld <= hold;
		if tx_busy = '0' then
		   tx_en <= '1';
			state <= inc(state);
		else tx_en <= '0';
		end if;
	elsif state = 1 then
		tx_en <= '0';
	   ihld <= released;
		pcnt <= inc(pcnt);
		state <= 0;
	end if;
	
 elsif opcode = "010100" then --Uart_rx Rx
    if state = 0 then 
      ihld <= hold;
		dss <= Uart;
		rcm <= external;
		
		if rx_busy = '0' then
		   en <= '1';
			state <= inc(state);
		end if;
		
	elsif state = 1 then
	   en <= '0';
	   ihld <= released;
		pcnt <= inc(pcnt);
		state <= 0;
	end if;

 elsif opcode = "010101" then --Load Rx	 
		if state = 0 then 
		  ihld <= hold;
		  DSS <= io_device;		  
		  rcm <= external;		  
		  read_ext <= '1';
		  wsrc <= s_r0;
		  
		  state <= inc(state);
		elsif state = 1 then 
		  read_ext <= '0';		  		  
		  en <= '1';
		  
		  state <= inc(state);
		elsif state = 2 then
		  en <= '0';
		  
		  ihld <= released;
		  pcnt <= inc(pcnt);
		  state <= 0;
		end if;	
		
elsif opcode= "010110" then --imm_store Rx location
    if state = 0 then
	    ihld <= hold;
		 write_ext <= '1';
		 addr_src <= imm; --immidiate addr
		 state <= inc(state);
		 
	elsif state = 1 then
	    write_Ext <= '0';
		 addr_src <= direct_addr; 
		 ihld <= released;
		 pcnt <= inc(pcnt);
		 state <= 0;
   end if;
	
elsif opcode= "010111" then --imm_load Rx location
    if state = 0 then
	    ihld <= hold;
		 read_ext <= '1';
		 addr_src <= imm;
		 state <= inc(state);
		 
	elsif state = 1 then
	    read_Ext <= '0';		 
		 en <= '1';
		 state <= inc(state);
		 
	elsif state = 2 then 
	    en <= '0';
		 addr_src <= direct_addr; 
		 ihld <= released;
		 pcnt <= inc(pcnt);
		 state <= 0;
   end if;
	
elsif opcode= "011000" then --load Rx location
    if state = 0 then
	    ihld <= hold;
		 read_ext <= '1';
		 state <= inc(state);
		 
	elsif state = 1 then
	    read_Ext <= '0';
		 en <= '1';
		 state <= inc(state);
		 
	elsif state = 2 then 
	    en <= '0';
		 ihld <= released;
		 pcnt <= inc(pcnt);
		 state <= 0;
   end if;

elsif opcode= "011001" then --store Rx location
    if state = 0 then
	    ihld <= hold;
		 write_ext <= '1';
		 state <= inc(state);
		 
	elsif state = 1 then
	    write_Ext <= '0';
		 ihld <= released;
		 pcnt <= inc(pcnt);
		 state <= 0;
   end if;

	   
	 
elsif opcode = "011010" then --call #function_address // calls function
    if state = 0 then 
	    ihld <= hold;
		 returnPC <= Pcnt + 1; --save PC return address value 
		 state <= inc(state);
	elsif state = 1 then 
	    pcnt <= conv_integer(imm_pc); --set pc to function lable address;
		 state <= 0;
		 ihld <= released;
	end if;
	
elsif opcode = "011011" then --return 
	     pcnt <= returnPC; --restore PC to normal execution value
	 
elsif opcode = "011100" then --push rx
   if state = 0 then
	    ihld <= hold;
	    ale <= '1';
		 mode <= "10"; -- INC address
		 state <= inc(state);
   elsif state = 1 then
	    state <= inc(state);
	    ale <= '0';
		 mem_we <= '1';
	elsif state = 2 then 
	    mem_we <= '0';
	    pcnt <= inc(pcnt); --set pc to function lable address;
		 state <= 0;
		 ihld <= released;	    
	end if;

elsif opcode ="011101" then --pop rx  
   if state = 0 then
       ihld <= hold;
		 mem_re <='1'; --strobe read to memory
		 
	    state <= inc(state);
		 
   elsif state = 1 then
		 mem_re <= '0';
		 rcm <= external;
		 wsrc <= s_r0;
		 en <= '1'; --copy data to register Rx
		 state <= inc(state);
	elsif state = 2 then
       en <= '0';	
		 ale <= '1';
		 mode <= "11";
	    state <= inc(state);
	elsif state = 3 then 
	    ale <= '0';
	    pcnt <= inc(pcnt); --set pc to function lable address;
		 state <= 0;
		 ihld <= released;	    
	end if;
	
       	
end if;
end if;

end process;



end Behavioral;

