library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_misc.all;

 -- decoding the input from the keypad
entity Decoder is
	Port (
   		 	clk	 : in  STD_LOGIC;
         	Row	 : in  STD_LOGIC_VECTOR (3 downto 0);
   		 	Col	 : out  STD_LOGIC_VECTOR (3 downto 0);
      	DecodeOut : out  STD_LOGIC_VECTOR (4 downto 0)); -- 5-bit output (the "10000" represents nothing pressed)
end Decoder;

architecture Behavioral of Decoder is

signal sclk :STD_LOGIC_VECTOR(19 downto 0);
signal sclk2: std_logic_vector(19 downto 0) := "00000000000000000000"; --setting debounce
signal DecodeOut_reg : std_logic_vector(3 downto 0);


begin



	 
	 
    process(clk)
   	 begin
   	 if rising_edge(clk) then
			
			
			if sclk2 = "11110100001001000000" then
					
					DecodeOut <= "10000";
					sclk <= sclk+1;
					sclk2 <= sclk2 + 1;
					sclk2 <= "00000000000000000000";
					
			
			
			
   		 elsif sclk = "00011000011010100000" then   --every 100,000 cycles
   			 --C1
   			 Col<= "1000";
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 -- check row pins
   		 elsif sclk = "00011000011010101000" then    
   			 --R1
   			 if Row = "1000" then
   				 DecodeOut <= "00001";    --1
   				 
   			 --R2
   			 elsif Row = "0100" then
   				 DecodeOut <= "00100"; --4
   				 
   			 --R3
   			 elsif Row = "0010" then
   				 DecodeOut <= "00111"; --7
   				 
   			 --R4
   			 elsif Row = "0001" then
   				 DecodeOut <= "00000"; --0
				 
   			 end if;
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 -- 2ms (200,000 cycles)
   		 elsif sclk = "00110000110101000000" then  
   			 --C2
   			 Col<= "0100";
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 -- check row pins
   		 elsif sclk = "00110000110101001000" then    
   			 --R1
   			 if Row = "1000" then   	 
   				 DecodeOut <= "00010"; --2
   				 
   			 --R2
   			 elsif Row = "0100" then
   				 DecodeOut <= "00101"; --5
   				 
   			 --R3
   			 elsif Row = "0010" then
   				 DecodeOut <= "01000"; --8
   				 
   			 --R4
   			 elsif Row = "0001" then
   				 DecodeOut <= "01111"; --F
   				 
   			 end if;
   			 sclk <= sclk+1;   
				 sclk2 <= sclk2 + 1; 
   		 --3ms (300,000 cycles)
   		 elsif sclk = "01001001001111100000" then	
   			 --C3
   			 Col<= "0010";
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 -- check row pins
   		 elsif sclk = "01001001001111101000" then
   			 --R1
   			 if Row = "1000" then
   				 DecodeOut <= "00011"; --3
   					 
   			 --R2
   			 elsif Row = "0100" then
   				 DecodeOut <= "00110"; --6
   				 
   			 --R3
   			 elsif Row = "0010" then
   				 DecodeOut <= "01001"; --9
   				 
   			 --R4
   			 elsif Row = "0001" then
   				 DecodeOut <= "01110"; --E
   				 
   			 end if;
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 
   		 elsif sclk = "01100001101010000000" then --4ms (400,000 Cycles)
   			 --C4
   			 Col<= "0001";
   			 sclk <= sclk+1;
				 sclk2 <= sclk2 + 1;
   		 -- check row pins
   		 elsif sclk = "01100001101010001000" then
   			 --R1
   			 if Row = "1000" then
   				 DecodeOut <= "01010"; --A
   				 
   			 --R2
   			 elsif Row = "0100" then
   				 DecodeOut <= "01011"; --B
   				 
   			 --R3
   			 elsif Row = "0010" then
   				 DecodeOut <= "01100"; --C
   				 
   			 --R4
   			 elsif Row = "0001" then
   				 DecodeOut <= "01101"; --D
					 
   			 elsif Row = "1010" then -- A and C
					DecodeOut <= "10001"; --extra case (A and C)
				
				elsif Row = "1001" then -- A and D
					DecodeOut <= "10010"; --extra case (A and D)
		
	
   			 end if;
				sclk <= "00000000000000000000";    
			 
			 else
   			 sclk <= sclk+1;
			    sclk2 <= sclk2 + 1;
	
	
   		 end if;
   	 end if;
    end process;		 
end Behavioral;
