--Original codes can be found here: https://digilent.com/reference/pmod/pmodkypd/start?redirect=1
--and here: https://www.fpga4student.com/2017/09/seven-segment-led-display-controller-basys3-fpga.html


--Both codes have been drastically modified to fit this specific scenario. Key changes:
--The Diligent PMOD application code only displayed on one of the anodes, while I modified the code to be compatible with all anodes by implementing a refresh rate
--The Seven segment display orginally counted a number, but I modified it to take the input from the PMOD keypad (DispVal) instead. 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity DisplayController is
    Port ( 
			  DispVal : in  STD_LOGIC_VECTOR (3 downto 0);   --4-bit output from the PMOD Decoder
			    anode : out std_logic_vector(3 downto 0);    --controls the display digits 
               segOut : out  STD_LOGIC_VECTOR (6 downto 0);  --controls which digit to display
             trigger  : out std_logic; --will be used for debug
             clk_100M : in std_logic);
               
end DisplayController;

architecture Behavioral of DisplayController is
    --------------------------------------------------------------
    signal displayed_number: std_logic_vector(15 downto 0);   --Hex number converted from the PMOD 4 bit input. This number will be used in calculation
    --------------------------------------------------------------
    
    signal DispVal_16: std_logic_vector(15 downto 0);
    signal LED_BCD : std_logic_vector(3 downto 0);            --value to the LED (could be DispVal?)
	signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);   -- creating 10.5ms refresh period
    signal anode_active: std_logic_vector(1 downto 0);        -- the other 2-bit for creating 4 LED-activating signals
    -- loops         0    ->  1  ->  2  ->  3
    -- activates    LED1    LED2   LED3   LED4
    
    
    signal DispVal_16_reg : std_logic_vector(15 downto 0);
    
    
    --states controlled by trigger
    --each time the trigger is activated, DispVal sends data to displayed_number_final
    
    
    --fsm for trigger
    type state_type is (state_0, state_1);
    signal state: state_type;
    
begin
	
	
	--extend the DispVal to 16 bits to support 16 bits
	DispVal_16 <= "000000000000" & DispVal;
	displayed_number <= DispVal_16;
	
	--planned shift register mechanicsm
	--1. stores the value to another variable
	--2. When a user presses another button, trigger something
	--3. the trigger causes the something to place previous input digit on the second anode
	

	-- Creating the refresh rate of 10.5ms
	process(clk_100M) begin
	   if (rising_edge(clk_100M)) then
	       refresh_counter <= refresh_counter + '1';
	   end if;
	end process;

	--enable the anodes to cycle through
	anode_active <= refresh_counter(19 downto 18);
	process(anode_active) begin
		LED_BCD <= DispVal; --takes input from decoder to signal 
	   case anode_active is
	       when "00" =>
	           anode <= "0111"; -- All anodes will cycle through
	           LED_BCD <= displayed_number(15 downto 12);--ones
	       when "01" =>
	           anode <= "1011";
	           LED_BCD <= displayed_number(11 downto 8); --tens
	       when "10" =>
	           anode <= "1101";
	           LED_BCD <= displayed_number(7 downto 4);  --hundreds
	       when "11" =>
	           anode <= "1110";
	           LED_BCD <= displayed_number(3 downto 0);  --thousands
	       when others =>
	           anode <= "1111";
	   end case;
	end process;

	
	
    --decodes BCD to 7 segment display cathode patterns
    process(LED_BCD) begin
        case LED_BCD is
            when "0000" => segOut <= "0000001"; -- "0"     
            when "0001" => segOut <= "1001111"; -- "1" 
            when "0010" => segOut <= "0010010"; -- "2" 
            when "0011" => segOut <= "0000110"; -- "3" 
            when "0100" => segOut <= "1001100"; -- "4" 
            when "0101" => segOut <= "0100100"; -- "5" 
            when "0110" => segOut <= "0100000"; -- "6" 
            when "0111" => segOut <= "0001111"; -- "7" 
            when "1000" => segOut <= "0000000"; -- "8"     
            when "1001" => segOut <= "0000100"; -- "9" 
            when "1010" => segOut <= "0000010"; -- a
            when "1011" => segOut <= "1100000"; -- b
            when "1100" => segOut <= "0110001"; -- C
            when "1101" => segOut <= "1000010"; -- d
            when "1110" => segOut <= "0110000"; -- E
            when "1111" => segOut <= "0111000"; -- F
            when others => segOut <= "0000000"; 
        end case;
    end process;
    
end Behavioral;