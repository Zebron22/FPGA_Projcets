library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--top module
entity PmodKYPD is
    Port ( 
			  clk : in  STD_LOGIC;
			   JA : inout  STD_LOGIC_VECTOR (7 downto 0); -- PmodKYPD is designed to be connected to JA
               an : out  STD_LOGIC_VECTOR (3 downto 0);   -- Controls which position of the seven segment display to display
              seg : out  STD_LOGIC_VECTOR (6 downto 0)); -- digit to display on the seven segment display
end PmodKYPD;

architecture Behavioral of PmodKYPD is

component Decoder is
	Port (
			    clk : in  STD_LOGIC;
                Row : in  STD_LOGIC_VECTOR (3 downto 0);
			    Col : out  STD_LOGIC_VECTOR (3 downto 0);
          DecodeOut : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;

component DisplayController is
	Port (
		   DispVal : in  STD_LOGIC_VECTOR (3 downto 0);
             anode : out std_logic_vector(3 downto 0);
            segOut : out  STD_LOGIC_VECTOR (6 downto 0);
           clk_100M: in std_logic);
	end component;

signal Decode: STD_LOGIC_VECTOR (3 downto 0);
begin
    
	C0: Decoder port map (clk=>clk, Row =>JA(7 downto 4), Col=>JA(3 downto 0), DecodeOut=> Decode);
	C1: DisplayController port map (DispVal=>Decode, anode=>an, segOut=>seg, clk_100M=>clk);


end Behavioral;