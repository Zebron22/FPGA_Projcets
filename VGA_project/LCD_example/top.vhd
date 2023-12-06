library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
		Port ( DB : out std_logic_vector(7 downto 4); --DB : out std_logic_vector(3 downto 0);
				 RS : out std_logic;
				 RW : out std_logic;
				 EN : out std_logic;
				 MAX10_CLK1_50 : in std_logic;
				 LEDR: out std_logic_vector(9 downto 0);
				 KEY: in std_logic_vector(1 downto 0));
end top;

architecture Behavioral of top is

	component LCDdisplay is
		Port( 
			DB : out std_logic_vector(7 downto 4); --DB : out std_logic_vector(3 downto 0);
			RS : out std_logic;
			RW : out std_logic;
			EN : out std_logic;
			r : in std_logic;
			LEDR : out std_logic_vector(9 downto 0);
			MAX10_CLK1_50 : in std_logic);
	end component;
	
	component LCDdisplay2 is
		Port( 
			DB : out std_logic_vector(7 downto 4); --DB : out std_logic_vector(3 downto 0);
			RS : out std_logic;
			RW : out std_logic;
			EN : out std_logic;
			r : in std_logic;
			LEDR : out std_logic_vector(9 downto 0);
			MAX10_CLK1_50 : in std_logic);
	end component;
	
	
	
	signal DB1 : std_logic_vector(3 downto 0);
	signal RS1 : std_logic;
	signal RW1 : std_logic;
	signal EN1 : std_logic;	
	
	signal DB2 : std_logic_vector(3 downto 0);
	signal RS2 : std_logic;
	signal RW2 : std_logic;
	signal EN2 : std_logic;
	signal r   : std_logic;
	signal r2  : std_logic;

begin



pattern1 : LCDdisplay  port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB1, RS => RS1, RW => RW1, EN => EN1, r => r);
pattern2 : LCDdisplay2  port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB2, RS => RS2, RW => RW2, EN => EN2, r => r2);

process(MAX10_CLK1_50, DB1, RS1, RW1, EN1, DB2, RS2, RW2, EN2, r, r2 )
begin
if rising_edge(MAX10_CLK1_50) then
	if KEY = "10" then
		--connect pattern1 and reset it. (when r is 1, the LCD display is restarted)
		--disable r and enable r2
		r  <= '1';   --disabled r
		r2 <= '0';   --enables r2
		DB <= DB2;
		RS <= RS2;
		RW <= RW2;
		EN <= EN2;
	
	else
		--connect pattern 1 and resume. Disable pattern2
		r2 <= '1';  --disabled r2
		r  <= '0';  --enabled r
		DB <= DB1;
		RS <= RS1;
		RW <= RW1;
		EN <= EN1;
		
	end if;
end if;
end process;



end Behavioral;
