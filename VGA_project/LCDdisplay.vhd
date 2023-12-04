---------------------------------------------------------------------
-- LCDdisplay.vhd  Demo VGA configuration module.
---------------------------------------------------------------------
-- 	Author: Jacob Beck, Cebron Williams
--            Copyright 2007 Digilent, Inc.
---------------------------------------------------------------------
--
-- This project is compatible with Xilinx ISE or Xilinx WebPack tools.
--
-- Inputs: 
--		MAX10_CLK1_50  - System Clock
-- Outputs:
--		DB		- Vector of the Data control lines
--		RS		- Register select
--		RW 	- Read/Write
--		EN 	- Enable
--
-- This module displays the message "Hello from Digilent" on the LCD
-- display Spartan 3E Starter Kit board. The message shifts in from
-- the right and stops in the middle of the LCD display momentarily,
-- then shifts out of the screen. This message will repeat indefinetely.
------------------------------------------------------------------------
-- Revision History:
--	 02/05/2007(JacobB): created
--  12/02/2023(Cebron Williams): Make compatible with DE-10 Lite
------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LCDdisplay is
		Port ( DB : out std_logic_vector(7 downto 4); -- RUn the (3 downto 0 ) section first to assign fitter locations
				 --DB : out std_logic_vector(3 downto 0);
				 RS : out std_logic;
				 RW : out std_logic;
				 EN : out std_logic;
				 MAX10_CLK1_50 : in std_logic);
end LCDdisplay;

architecture Behavioral of LCDdisplay is
signal clkCount : std_logic_vector(6 downto 0):= "0000000";								--MAX10_CLK1_50 divider count
signal count : std_logic_vector (25 downto 0):= "00000000000000000000000000";		--Delay count
signal write_count : std_logic_vector (5 downto 0):= "000000";							--Delay write count
signal delayOK	: std_logic:= '0';																--1 when delay time as been reached, 0 otherwise
signal write_count_go : std_logic:= '0';														--Signal starts the delay write count
signal write_delay_ok : std_logic:= '0';														--1 when delay write time has been reached, 0 otherwise
signal oneUSClk : std_logic;																		--1 micro second clock signal
signal activateW : std_logic:= '0';																--Signal that starts the write machine
signal ShiftCount : std_logic_vector(3 downto 0):= "0000";								--Delay count for shifting
-- Main state machine
type main_state is ( PowerOn,
							FourBitOp1,
							FourBitOp1_Delay,
							FourBitOp2,
							FourBitOp2_Delay,
							FunctionSet,
							FunctionSet_Delay,
							EntryModeSet,
							EntryModeSet_Delay,
							DisplaySet,
							DisplaySet_Delay,
							DisplayClear,
							DisplayClear_Delay,
							ReturnHome,
							ReturnHome_Delay,
							CharWrite,
							Char_Delay,
							ShiftIn,
							Shift_Delay,
							Pause,
							ShiftOut,
							Shift_Delay2
							);
signal current_state : main_state:= PowerOn;									--Initial main state
-- The write state machine
type write_state is ( Idle,
							 Write,
							 Enable,
							 Disable,
							 DisableWait,
							 Enable2,
							 WriteWait
							 );
signal current_write_state : write_state:= Idle;							--Initial write state
--type LCD_CMDS_T is array(integer range <>) of std_logic_vector(5 downto 0);
type LCD_CMDS_T is array(0 to 60) of std_logic_vector(5 downto 0);
--Array of all commands required for the LCD display
constant LCD_CMDS : LCD_CMDS_T := ( 0 => "00"&X"0", --PowerOn
												1 => "00"&X"3", --Four Bit Op1
												2 => "00"&X"2", --Four Bit Op2
												3 => "00"&X"2",
												4 => "00"&X"8", --FunctionSet
												5 => "00"&X"0",
												6 => "00"&X"6", --EntryMode
												7 => "00"&X"0",
											   8 => "00"&X"C", --DisplaySet C
											   9 => "00"&X"0",
											  10 => "00"&X"1", --DisplayClear
											  11 => "00"&X"0",
											  12 => "00"&X"2", --ReturnHome
											  13 => "00"&X"9",
											  14 => "00"&X"0", --Go to Address 0x10
											  
											  15 => "10"&X"4",
											  16 => "10"&X"5", --"E"
											  
											  17 => "10"&X"6",
											  18 => "10"&X"E", --"n"
											  
											  19 => "10"&X"7",
											  20 => "10"&X"4", --"t"
											  
											  21 => "10"&X"6",
											  22 => "10"&X"5", --"e"
											  
											  23 => "10"&X"7",
											  24 => "10"&X"2", --"r"
											  
											  25 => "10"&X"F",
											  26 => "10"&X"E", --space
											  
											  27 => "10"&X"6",
											  28 => "10"&X"4", --"d"
											  
											  29 => "10"&X"6",
											  30 => "10"&X"9", --"i"
											  
											  31 => "10"&X"6",
											  32 => "10"&X"7", --"g"
											  
											  33 => "10"&X"6",
											  34 => "10"&X"9", --"i"
											  
											  35 => "10"&X"7",
											  36 => "10"&X"4", --"t"
											  
											  37 => "10"&X"7",
											  38 => "10"&X"3", --"s"
											  
											  39 => "00"&X"D",
											  40 => "00"&X"1", --Go to Address 0x50
											  
											  41 => "10"&X"4",
											  42 => "10"&X"8", --"H"
											  
											  43 => "10"&X"6",
											  44 => "10"&X"F", --"o"
											  
											  
											  45 => "10"&X"6", 
											  46 => "10"&X"C", --"l"
											  
											  47 => "10"&X"6", 
											  48 => "10"&X"4", --"d"
											  
											  49 => "10"&X"2", 
											  50 => "10"&X"0", --"space"
											  
											  51 => "10"&X"4", 
											  52 => "10"&X"B", --"K"
											  
											  53 => "10"&X"4", 
											  54 => "10"&X"5", --"E"
											  
											  55 => "10"&X"5", 
											  56 => "10"&X"9", --"Y"
											  
											  57 => "10"&X"3", 
											  58 => "10"&X"1", --"1"
											  
											  59 => "00"&X"1",
											  60 => "00"&X"8" --Shift Left
											  );
											  
signal lcd_cmd_ptr : integer range 0 to LCD_CMDS'HIGH + 1 := 0;--Current pointer to the LCD_CMDS array

begin
--This process produces a 1 micro-second clock
process (MAX10_CLK1_50, oneUSClk)
begin
	if (MAX10_CLK1_50 = '1' and MAX10_CLK1_50'event) then
			clkCount <= clkCount + 1;
	end if;
end process;
oneUSClk <= clkCount(6);
--This process drives the delay counter
process (oneUSClk, delayOK, current_state)
begin
	if (oneUSClk = '1' and oneUSClk'event) then
		if delayOK = '1' then
			count <= "00000000000000000000000000";
		else
			count <= count + 1;
		end if;
	end if;
end process;
--This process drives the write delay counter
process (oneUSCLK, write_delay_ok, write_count_go)
begin
	if (oneUSClk = '1' and oneUSClk'event) then
		if write_count_go = '1' then	--Signal to start the write delay counter
			if write_delay_ok = '1' then
				write_count <= "000000";
			else
				write_count <= write_count + 1;
			end if;
		else
			write_count <= "000000";
		end if;
	end if;
end process;
--This process drives the lcd_cmd_ptr based on the current_state
process (lcd_cmd_ptr, oneUSClk)
begin
	if (oneUSClk = '1' and oneUSClk'event) then
		if (current_state = FourBitOp1 or current_state = FourBitOp2 or
			current_state = FunctionSet or current_state = EntryModeSet or
			current_state = DisplaySet or current_state = ReturnHome or
			current_state = CharWrite or current_write_state = Disable) then 
			lcd_cmd_ptr <= lcd_cmd_ptr + 1;
		elsif current_state = PowerOn then
			lcd_cmd_ptr <= 0;
		elsif current_state = ShiftIn or current_state = ShiftOut then
			lcd_cmd_ptr <= 59;                                                              --originally 53   (54-1)                                   
		elsif current_state = DisplayClear then
			lcd_cmd_ptr <= 9;
		else
			lcd_cmd_ptr <= lcd_cmd_ptr;
		end if;
	end if;
end process;
--This process drives write_delay_ok based on the write state and the delay required
process( oneUSClk )
begin
	if oneUSClk = '1' and oneUSClk'event then
		if ((current_write_state = Enable and  write_count =    "000001") or			--Delay 1 us
			(current_write_state = DisableWait and write_count = "000001") or			--Delay 1 us
			(current_write_state = Enable2 and write_count =     "000001") or			--Delay 1 us
			(current_write_state = WriteWait and write_count =   "011110")) then		--Delay 30 us
			write_delay_ok <= '1';
		else
				write_delay_ok <= '0';
		end if;
	end if;
end process;
--This process drives delay_ok based on the current state and the delay required
process ( oneUSClk )
begin
	if oneUSClk = '1' and oneUSClk'event then
			if ((current_state = PowerOn and count =        "00000000000111010100110000") or			--Delay 15 ms
			(current_state = FourBitOp1_Delay and count =   "00000000000100001001000000") or			--Delay 4.2 ms
			(current_state = FourBitOp2_Delay and count =   "00000000000000000010100000") or			--Delay 40 us
			(current_state = FunctionSet_Delay and count =  "00000000000000000001100100") or			--Delay 50 us
			(current_state = EntryModeSet_Delay and count = "00000000000000000001100100") or 		--Delay 50 us
			(current_state = DisplaySet_Delay and count =   "00000000000000000001100100") or			--Delay 50 us
			(current_state = DisplayClear_Delay and count = "00000000110011100110100000") or 		--Delay 1.7 ms
			(current_state = ReturnHome_Delay and count =   "00000000000000000001100100") or			--Delay 50 us
			(current_state = Char_Delay and count =         "00000000000000000001100100") or			--Delay 50 us
			(current_state = Shift_Delay and count =        "00000000011110000001100100") or			--Delay 61.49 ms
			(current_state = Pause and count =              "11111111111111111111111111") or			--Delay for about 1s
			(current_state = Shift_Delay2 and count =       "00000000011110000001100100")) then		--Delay 61.49 ms
			delayOk <= '1';	
			else
				delayOk <= '0';
		end if;
	end if;
end process;
--This process is the main state machine that drives the LCD display
process ( oneUSClk )
begin
	if oneUSClk = '1' and oneUSClk'event then
	case current_state is
	when PowerOn =>			--Power on state
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= FourBitOp1;
		else
			current_state <= PowerOn;
		end if;
	when FourBitOp1 =>		--First sequence to set up the four bit interface with the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';	
		current_state <= FourBitOp1_Delay;
	when FourBitOp1_Delay =>	--Hold time for first sequence
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= FourBitOp2;
		else
			current_state <= FourBitOp1_Delay;
		end if;
	when FourBitOp2 =>		--Second sequence to set up the four bit interface with the LCD display 
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';	
		current_state <= FourBitOp2_Delay;				
	when FourBitOp2_Delay =>	--Hold time for second sequence
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= FunctionSet;
		else
			current_state <= FourBitOp2_Delay;
		end if;
	when FunctionSet =>		--Issue function set command to LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';	
		current_state <= FunctionSet_Delay;
	when FunctionSet_Delay =>	--Hold time for function set
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= EntryModeSet;
		else
			current_state <= FunctionSet_Delay;
		end if;
	when EntryModeSet =>		--Issue Entry Mode command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';	
		current_state <= EntryModeSet_Delay;
	when EntryModeSet_Delay =>	--Hold time for Entry Mode
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= DisplaySet;
		else
			current_state <= EntryModeSet_Delay;
		end if;
	when DisplaySet =>		--Issue Display Set command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';	
		current_state <= DisplaySet_Delay;
	when DisplaySet_Delay =>	--Hold time for Display Set
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= DisplayClear;
		else
			current_state <= DisplaySet_Delay;
		end if;
	when DisplayClear =>		--Issue Display Clear command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';	
		current_state <= DisplayClear_Delay;
		

		
		
		
	when DisplayClear_Delay =>		--Hold time for Display Clear
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= ReturnHome;
		else
			current_state <= DisplayClear_Delay;
		end if;
	when ReturnHome =>		--Issue Return Home command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';	
		current_state <= ReturnHome_Delay;
	when ReturnHome_Delay =>		--Hold time for Return Home
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			current_state <= CharWrite;
		else
			current_state <= ReturnHome_Delay;
		end if;
		
		
	when CharWrite =>		--Issue the Write command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';
		current_state <= Char_Delay;
		
		
	when Char_Delay =>		--Hold time for write
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
		
			if lcd_cmd_ptr > 57 then		--Check if last character has been written                            (originally 51 (54-3))
				current_state <= ShiftIn;
			else
				current_state <= CharWrite;
			end if;
		else
			current_state <= Char_Delay;
		end if;
		
		
	when ShiftIn =>		--Issue the Shift left command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';
		ShiftCount <= Shiftcount + 1;
		current_state <= Shift_Delay;
	when Shift_Delay =>		--Hold time for shift
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			if ShiftCount = "1101" then	--Check if 13 shifts have occured
				current_state <= Pause;
				ShiftCount <= "0000";
			else
				current_state <= ShiftIn;
			end if;
		end if;
	when Pause =>		--Delay so that message on LCD display can be read
		if delayOk = '1' then
			current_state <= ShiftOut;
		else
			current_state <= Pause;
		end if;
	when ShiftOut =>		--Issue the shift left command to the LCD display
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '1';
		ShiftCount <= Shiftcount + 1;
		current_state <= Shift_Delay2;
	when Shift_Delay2 =>		--Hold time for shift
		RS <= LCD_CMDS(lcd_cmd_ptr)(5);
		RW <= LCD_CMDS(lcd_cmd_ptr)(4);
		DB <= LCD_CMDS(lcd_cmd_ptr)(3 downto 0);
		activateW <= '0';
		if delayOK = '1' then
			if ShiftCount = "1111" then	--Check if 15 shifts have occured
				current_state <= DisplayClear;
				ShiftCount <= "0000";
			else
				current_state <= ShiftOut;
			end if;
		end if;
	end case;
	end if;
end process;
--This process is the write state machine
process ( oneUSClk )
begin
	if oneUSClk = '1' and oneUSClk'event then
	case current_write_state is
				--Waiting for the write command from the instuction state machine
				when Idle =>
					EN <= '0';
					write_count_go <= '0';
					if activateW = '1' then
						current_write_state <= Write;
					else
						current_write_state <= Idle;
					end if;
				--Start of the write sequence
				--The write delay counter is started at this point
				when Write =>
					EN <= '0';
					write_count_go <= '1';
					current_write_state <= Enable;			
				--Enable signal is driven high after proper delay time is reached
				when Enable =>
					if write_delay_ok = '1' then
						EN <= '0';
						current_write_state <= Disable;
					else
						current_write_state <= Enable;
						EN <= '1';
					end if;
				--Enable signal is disabled and the LCD pointer is incremented, changing the data lines
				when Disable =>
					EN <= '0';
					current_write_state <= DisableWait;
				--Add one clock cycle delay to stabilze the Enbale signal
				when DisableWait =>
					EN <= '0';
					if write_delay_ok = '1' then
						current_write_state <= Enable2;
					else
						current_write_state <= DisableWait;
					end if;
				--Enable signal is driven high after proper delay time is reached
				when Enable2 =>
					if write_delay_ok = '1' then
						EN <= '0';
						current_write_state <= WriteWait;
					else
						EN <= '1';
						current_write_state <= Enable2;
					end if;
				--Enable signal is driven low after the proper delay time is reached
				--This is the end of the write sequence
				when WriteWait =>
					EN <= '0';
					if write_delay_ok = '1' then
						current_write_state <= Idle;
					else
						current_write_state <= WriteWait;
					end if;
				end case;
			end if;
		end process;	

end Behavioral;
