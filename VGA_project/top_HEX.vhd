--Cebron Williams
--update 12/04/2023: added support for multiple same inputs
--added HEX functionality - the user enters a HEX value. As the user enters a HEX value, the display updates with the decimal equivalent
--Modified the buffer states to allow for automatic HEX to decimal conversion. The user will only need to press the keypad twice
--update 12/06/2023: added proper LCD transition states
--update 12/07/2023: removed the division by 2 and division by 4 functionality to support integer division
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_HEX is
    Port (
		  SW            : in std_logic_vector(1 downto 0);
		  LEDR          : out std_logic_vector(9 downto 0); --debug signal
		  Row           : in  std_logic_vector(3 downto 0);
		  Col           : out std_logic_vector(3 downto 0); --out
		  KEY           : in std_logic_vector(1 downto 0);
        MAX10_CLK1_50 : in  STD_LOGIC; -- Input clock at 50 MHz
        VGA_VS        : out STD_LOGIC;
        VGA_HS        : out STD_LOGIC;
        VGA_R         : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_G         : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_B         : out STD_LOGIC_VECTOR(3 downto 0);
		  DB : out std_logic_vector(7 downto 4); --DB : out std_logic_vector(3 downto 0);
		  RS : out std_logic;
		  RW : out std_logic;
		  EN : out std_logic
		  
    );
end top_HEX;

architecture Behavioral of top_HEX is
    component VideoSyncGenerator
        Port (
            clock25MHz : in STD_LOGIC;
            vsync : out STD_LOGIC;
            hsync : out STD_LOGIC;
            x : out STD_LOGIC_VECTOR(9 downto 0);
            y : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

    component tvPattern
        Port (
          x      : in STD_LOGIC_VECTOR(9 downto 0);
          y      : in STD_LOGIC_VECTOR(9 downto 0);
			charX   : in STD_LOGIC_VECTOR(9 downto 0);
			charY   : in STD_LOGIC_VECTOR(9 downto 0);
         red     : out STD_LOGIC_VECTOR(3 downto 0);
			green   : out STD_LOGIC_VECTOR(3 downto 0);
			charSel : in INTEGER range 0 to 19;         -- Character selection (for multiple characters)
         blue    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
	 
	 
	 component Decoder
		port(
   		clk	    : in  STD_LOGIC;
         Row	    : in  STD_LOGIC_VECTOR (3 downto 0);
   		Col	    : out  STD_LOGIC_VECTOR (3 downto 0); --out
      	DecodeOut : out  STD_LOGIC_VECTOR (4 downto 0) -- 5-bit output (the "10000" represents nothing pressed)
		);
	 end component;
	
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

	component LCDdisplay3 is
		Port( 
			DB : out std_logic_vector(7 downto 4); --DB : out std_logic_vector(3 downto 0);
			RS : out std_logic;
			RW : out std_logic;
			EN : out std_logic;
			r : in std_logic;
			LEDR : out std_logic_vector(9 downto 0);
			MAX10_CLK1_50 : in std_logic);
	end component;	
	
	component LCDdisplay4 is
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
	
	signal DB3 : std_logic_vector(3 downto 0);
	signal RS3 : std_logic;
	signal RW3 : std_logic;
	signal EN3 : std_logic;
	
	
	signal DB4 : std_logic_vector(3 downto 0);
	signal RS4 : std_logic;
	signal RW4 : std_logic;
	signal EN4 : std_logic;
	
	signal r   : std_logic; --enter first number
	signal r2  : std_logic;	--enter second number
	signal r3  : std_logic; --enter op (operation)
	signal r4  : std_logic;
	
	
	signal x, y : STD_LOGIC_VECTOR(9 downto 0);
	signal clock25MHz : STD_LOGIC; -- 25 MHz clock signal
	signal clock1s : std_logic; -- 1 Hz clk signal
	signal charSel: integer range 0 to 18 := 0; --selects character
	signal Decode : std_logic_vector(4 downto 0);
	signal Decode_prev: std_logic_vector(4 downto 0) := "10000";	 

	type   state_type is (reset, digit1, digit2, digit3, op, digit4, digit5, digit6, input_final, buff, buff2);
	signal state : state_type := reset; --used as a FSM for keypad inputs
	
	
	signal charSel_store : integer := 0; --used to hold the state of charSel
	signal clock100ms : std_logic; -- 1ms clk signal
	signal Decode_stable : std_logic_vector(4 downto 0) := "10000";


	--start at 320 pixels
	signal charX   : std_logic_vector(9 downto 0)  := "0101000000"; --w = 640 default_values (320)
	signal charY   : std_logic_vector(9 downto 0)  := "0011110000"; --h = 480 default_values (240)

	--16 pixels over
	signal charX2   : std_logic_vector(9 downto 0);	

	--16 pixels over
	signal charX3   : std_logic_vector(9 downto 0);

	--16 pixels over
	signal charX4   : std_logic_vector(9 downto 0);

	--16 pixels over
	signal charX5  : std_logic_vector(9 downto 0);

	--16 pixels over
	signal charX6  : std_logic_vector(9 downto 0);
	
	--16 pixels over
	signal charX7  : std_logic_vector(9 downto 0);
	
	--16 pixels over
	signal charX8  : std_logic_vector(9 downto 0);
	signal charY8 : std_logic_vector(9 downto 0);
	
	
	signal charX9, charX10, charX11  : std_logic_vector(9 downto 0);
	signal charY9, charY10  : std_logic_vector(9 downto 0);
	signal charSel9, charSel10, charSel11: integer range 0 to 18 := 0;
	signal red9, green9, blue9: std_logic_vector(3 downto 0);
	signal red10, green10, blue10: std_logic_vector(3 downto 0);
	signal red11, green11, blue11: std_logic_vector(3 downto 0);	
	


	
	signal charSel2: integer range 0 to 19 := 0; --selects character
	signal charSel3: integer range 0 to 19 := 0; --selects character
	signal charSel4: integer range 0 to 19 := 0; --selects character
	signal charSel5: integer range 0 to 19 := 0; --selects character
	signal charSel6: integer range 0 to 19 := 0; --selects character
	signal charSel7: integer range 0 to 19 := 0; --selects character
	signal charSel8: integer range 0 to 19 := 18; --selects character	
	
	
	
	signal red1, green1, blue1: std_logic_vector(3 downto 0);
	signal red2, green2, blue2: std_logic_vector(3 downto 0);
	signal red3, green3, blue3: std_logic_vector(3 downto 0);
	signal red4, green4, blue4: std_logic_vector(3 downto 0);
	signal red5, green5, blue5: std_logic_vector(3 downto 0);
	signal red6, green6, blue6: std_logic_vector(3 downto 0);
	signal red7, green7, blue7: std_logic_vector(3 downto 0);
	signal red8, green8, blue8: std_logic_vector(3 downto 0);
	
	signal record_key : integer;	
	signal save_number1 : integer;
	signal save_number2 : integer;
	
	signal add_out    : integer;
	signal sub_out    : integer;
	signal multiply_2 : integer;
	signal divide_2   : integer;
	signal multiply_4 : integer;
	signal divide_4   : integer;
	signal add_1      : integer;
	signal sub_1      : integer;
	
	signal h1 : integer;
	signal h2 : integer;
	
	signal disp : std_logic_vector(15 downto 0);
	
	signal disp_first_digit : std_logic_vector(7 downto 0); --8 bit
	signal disp_first_digit_100 : integer;
	signal disp_first_digit_10 : integer;
	signal disp_first_digit_1 : integer;
	
	signal disp_second_digit: std_logic_vector(7 downto 0); --8 bit
	
	
	
	signal clkCount : std_logic_vector(6 downto 0):= "0000000";								--MAX10_CLK1_50 divider count
	signal oneUSClk : std_logic;																		--1 micro second clock signal
	
	
begin
	
	charX2 <= std_logic_vector(unsigned(charX)  + to_unsigned(20, charX'length));
	charX3 <= std_logic_vector(unsigned(charX2) + to_unsigned(20, charX'length));
	charX4 <= std_logic_vector(unsigned(charX3) + to_unsigned(20, charX'length));
	charX5 <= std_logic_vector(unsigned(charX4) + to_unsigned(20, charX'length));
	charX6 <= std_logic_vector(unsigned(charX5) + to_unsigned(20, charX'length));
	charX7 <= std_logic_vector(unsigned(charX6) + to_unsigned(20, charX'length));
	
	
	charX8 <= std_logic_vector(unsigned(charX7) + to_unsigned(20, charX'length));
	charY8 <= std_logic_vector(unsigned(charX7) + to_unsigned(24, charY'length));
	
	
	charX9  <= std_logic_vector(unsigned(charX8) + to_unsigned(20, charX'length));
	charY9  <= charY8; 
	
	charX10 <= std_logic_vector(unsigned(charX9) + to_unsigned(20, charX'length));
	charY10 <= charY9; 
	
	charX11 <= std_logic_vector(unsigned(charX10) + to_unsigned(20, charX'length));
	
		
	
	DecodedValue     : Decoder port map (clk => MAX10_CLK1_50, Row => Row, Col => Col, DecodeOut => Decode);
	VideoSyncInstance: VideoSyncGenerator port map (clock25MHz => clock25MHz, vsync => VGA_VS, hsync => VGA_HS, x => x, y => y);
	PatternInstance  : tvPattern port map (x => x, y => y, charX => charX,   charY => charY,    red => red1, green => green1, blue => blue1, charSel => charSel);
	PatternInstance2 : tvPattern port map (x => x, y => y, charX => charX2,  charY => charY,  red => red2, green => green2, blue => blue2, charSel => charSel2); --shifted to the right
	PatternInstance3 : tvPattern port map (x => x, y => y, charX => charX3,  charY => charY,  red => red3, green => green3, blue => blue3, charSel => charSel3); --shifted to the right
	PatternInstance4 : tvPattern port map (x => x, y => y, charX => charX4,  charY => charY,  red => red4, green => green4, blue => blue4, charSel => charSel4); --shifted to the right
	PatternInstance5 : tvPattern port map (x => x, y => y, charX => charX5,  charY => charY,  red => red5, green => green5, blue => blue5, charSel => charSel5); --shifted to the right
	PatternInstance6 : tvPattern port map (x => x, y => y, charX => charX6,  charY => charY,  red => red6, green => green6, blue => blue6, charSel => charSel6); --shifted to the right
	PatternInstance7 : tvPattern port map (x => x, y => y, charX => charX7,  charY => charY,  red => red7, green => green7, blue => blue7, charSel => charSel7); --shifted to the right
	PatternInstance8 : tvPattern port map (x => x, y => y, charX => charX8,  charY => charY,  red => red8, green => green8, blue => blue8, charSel => charSel8); --shifted to the right
	PatternInstance9 : tvPattern port map (x => x, y => y, charX => charX9, charY => charY, red => red9, green => green9, blue => blue9, charSel => charSel9);
	PatternInstance10: tvPattern port map (x => x, y => y, charX => charX10, charY => charY, red => red10, green => green10, blue => blue10, charSel => charSel10);
	PatternInstance11: tvPattern port map (x => x, y => y, charX => charX11, charY => charY, red => red11, green => green11, blue => blue11, charSel => charSel11);

	
--LCD stuff
pattern1 : LCDdisplay   port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB1, RS => RS1, RW => RW1, EN => EN1, r => r);
pattern2 : LCDdisplay2  port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB2, RS => RS2, RW => RW2, EN => EN2, r => r2);
pattern3 : LCDdisplay3  port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB3, RS => RS3, RW => RW3, EN => EN3, r => r3);
pattern4 : LCDdisplay4  port map(MAX10_CLK1_50 => MAX10_CLK1_50, DB => DB4, RS => RS4, RW => RW4, EN => EN4, r => r4);


--process for LCD patterns
process(MAX10_CLK1_50, DB1, RS1, RW1, EN1, r, DB2, RS2, RW2, EN2, r2 , DB3, RS3, RW3, EN3, r3, DB4, RS4, RW4, EN4, r4)
begin
if rising_edge(MAX10_CLK1_50) then
	if state = digit4 then
		--disable r and enable r2
		r  <= '1';   --disabled r
		r2 <= '0';   --enables pattern2
		r3 <= '1';
		r4 <= '1';
		DB <= DB2;
		RS <= RS2;
		RW <= RW2;
		EN <= EN2;
	
	elsif state = op then
		r4 <= '1';
		r3 <= '0';  --enables pattern3
		r2 <= '1';
		r <= '1';
		DB <= DB3;
		RS <= RS3;
		RW <= RW3;
		EN <= EN3;
		
	elsif state = input_final then
		r4 <= '0'; --enables pattern4
		r3 <= '1';  
		r2 <= '1';
		r <=  '1';
		DB <= DB4;
		RS <= RS4;
		RW <= RW4;
		EN <= EN4;
	
	elsif SW = "11" then
		--disable all patterns
		r4 <= '1';		
		r3 <= '1';
		r2 <= '1';
		r <=  '1';
		
	else
		--connect pattern 1 and resume. Disable pattern2
		r4 <= '1';		
		r3 <= '1';
		r2 <= '1';  --disabled r2
		r  <= '0';  --enabled pattern1
		DB <= DB1;
		RS <= RS1;
		RW <= RW1;
		EN <= EN1;
		
	end if;
end if;
end process;

	
	
	
	--create 1us clk divider
	process (MAX10_CLK1_50, oneUSClk)
	begin
	if (MAX10_CLK1_50 = '1' and MAX10_CLK1_50'event) then
			clkCount <= std_logic_vector(unsigned(clkCount) + 1);
	end if;
	end process;
	oneUSClk <= clkCount(6);
	
	
	--controlling how the signal is displayed
	process(x, y, red1, green1, blue1, red2, green2, blue2, red3, green3, blue3, red4, green4, blue4, red5, green5, blue5, red6, green6, blue6, red7, green7, blue7, red8, green8, blue8, red9, green9, blue9, red10, green10, blue10, red11, green11, blue11, charX, charX2, charX3, charX4, charX5, charX6, charX7, charX8, charX9, charX10, charX11, charY9, charY10, charY8)
	begin
		 if unsigned(x) < unsigned(charX2) then
			  -- Use output from the first pattern
			  VGA_R <= red1;
			  VGA_G <= green1;
			  VGA_B <= blue1;
		 
		 elsif unsigned(x) < unsigned(charX3) then
			  -- Use output from the second pattern
			  VGA_R <= red2;
			  VGA_G <= green2;
			  VGA_B <= blue2;
		 elsif unsigned(x) < unsigned(charX4) then
			  -- Use output from the third pattern
			  VGA_R <= red3;
			  VGA_G <= green3;
			  VGA_B <= blue3;

		elsif unsigned(x) < unsigned(charX5) then
			-- Use output from the third pattern
				VGA_R <= red4;
				VGA_G <= green4;
				VGA_B <= blue4;

		elsif unsigned(x) < unsigned(charX6) then
			-- Use output from the third pattern
				VGA_R <= red5;
				VGA_G <= green5;
				VGA_B <= blue5;							
				
		elsif unsigned(x) < unsigned(charX7) then
			-- Use output from the third pattern
				VGA_R <= red6;
				VGA_G <= green6;
				VGA_B <= blue6;		
		
			
		elsif unsigned(x) < unsigned(charX8) then
				VGA_R <= red7;
				VGA_G <= green7;
				VGA_B <= blue7;				
		
		
		elsif unsigned(x) < unsigned(charX9) then
			 VGA_R <= red8;
			 VGA_G <= green8;
			 VGA_B <= blue8;

		elsif unsigned(x) < unsigned(charX10) then
			 VGA_R <= red9;
			 VGA_G <= green9;
			 VGA_B <= blue9;

		elsif unsigned(x) < unsigned(charX11) then
			 VGA_R <= red10;
			 VGA_G <= green10;
			 VGA_B <= blue10;			 
			 
		else
			 VGA_R <= red11;
			 VGA_G <= green11;
			 VGA_B <= blue11;
			  
		 end if;
	end process;
	
	-- Clock divider (50 MHz to 25 MHz)
	process(MAX10_CLK1_50)
	  variable divider : STD_LOGIC := '0';
	begin
	  if rising_edge(MAX10_CLK1_50) then
			divider := not divider;
			clock25MHz <= divider;
	  end if;
	end process;

	-- clk divider 100ms
	process(MAX10_CLK1_50)
	  variable divider3 : integer := 0;
	begin
	  if rising_edge(MAX10_CLK1_50) then
			if divider3 >= 2500000 then
				clock100ms <= not clock100ms;
				divider3 := 0;
			else
				divider3 := divider3 + 1;
			end if;
	  end if;
	end process;
 
	--one second clk divider
	process(MAX10_CLK1_50)
	  variable divider2 : integer := 0;
	begin
	  if rising_edge(MAX10_CLK1_50) then
			if divider2 >= 25000000 then
				clock1s <= not clock1s;
				divider2 := 0;
			else
				divider2 := divider2 + 1;
			end if;
	  end if;
	end process;

	--decoder
	process(Decode_stable, charSel_store, charSel, charSel2, charSel3, charSel4, charSel5, charSel6, charSel7, charSel8, charSel9, charSel10, state, KEY)
	begin
	case Decode_stable is 
		when "00000" =>  charSel_store <= 0;  -- 0
		when "00001" =>  charSel_store <= 1;  -- 1
		when "00010" =>  charSel_store <= 2;  -- 2
		when "00011" =>  charSel_store <= 3;  -- 3
		when "00100" =>  charSel_store <= 4;  -- 4
		when "00101" =>  charSel_store <= 5;  -- 5
		when "00110" =>  charSel_store <= 6;  -- 6
		when "00111" =>  charSel_store <= 7;  -- 7
		when "01000" =>  charSel_store <= 8;  -- 8
		when "01001" =>  charSel_store <= 9;  -- 9
		when "01010" =>  charSel_store <= 10; -- a (add)
		when "01011" =>  charSel_store <= 11; -- b (subtract)
		when "01100" =>  charSel_store <= 12; -- c (multiply)
		when "01101" =>  charSel_store <= 13; -- d (divide)
		when "01110" =>  charSel_store <= 14; -- E (add 1)
		when "01111" =>  charSel_store <= 15; -- F (subtract 1)
		when "10001" =>  charSel_store <= 16; -- special AC (multiply by 4)
		when "10010" =>  charSel_store <= 17; -- special AD (divide by 4)
		when "10000" =>  charSel_store <= 0;  -- Default case (0)
		when others  =>  charSel_store <= 19; -- empty char for reset
	end case;
	end process;

	
	
	--main FSM that displays the characters (HEX)
	--Numbers are inputted as HEX. When the numbers are imputted as HEX, the value will be displayed in decimal
	--EX: Press A, 10 is displayed

	
	--Main FSM that displays the characters (decimal)
	process(oneUSClk, clock100ms, Decode, Decode_prev, state, Decode_stable, charSel_store, charSel, charSel2, charSel3, charSel4, charSel5, charSel6, charSel7, charSel8, charSel9, charSel10, charSel11, KEY,      DB1, RS1, RW1, EN1, r, DB2, RS2, RW2, EN2, r2 , DB3, RS3, RW3, EN3, r3)
	variable verify_record_key: integer;
	variable valid_range      : integer;	
	begin
		if rising_edge(clock100ms) then
			if Decode /= "10000" then
				Decode_stable <= Decode;
			end if;
				
				--FSM for calculations
				if KEY = "10" then
					state <= reset;
				else
					case state is
						when reset =>
							Decode_stable <= "10000";
							Decode_prev   <= "10000";
							charSel  <= 0;
							charSel2 <= 0;
							charSel3 <= 0;
							charSel4 <= 0;
							charSel5 <= 0;
							charSel6 <= 0;
							charSel7 <= 0;
							charSel9 <= 0;
							charSel10 <= 0;
							charSel11 <= 0;
							record_key   <= 0;
							save_number1 <= 0;
							save_number2 <= 0;
							add_out <= 0;
							verify_record_key := 0;
							add_out        <= 0;
							sub_out        <= 0;
							multiply_2     <= 0;
							divide_2       <= 0;
							multiply_4     <= 0;
							divide_4       <= 0;
							add_1          <= 0;
							sub_1      		<= 0;
													
							
							state <= digit1;
						
						when digit1 =>
							--enter first digit as 4 bit hex number. If A-F, the character will be 10-16 repsectively in decimal
							if Decode_stable /= Decode_prev then
								
								--in this state, if decode_stable is A-F
								case Decode_stable is
									when "01010" => --when A, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 0;
										
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
										
										
									when "01011" => --when B, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 1;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
										
										
									when "01100" => --when C, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 2;
										
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
										
										
									when "01101" => --when D, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 3;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
										
										
									when "01110" => --when E, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 4;	
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
										
										
									when "01111" => --when F, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel <= 1;
										charSel2 <= 5;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
								
								
									when others =>
									
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0))); --converts to an integer
										Decode_prev <= Decode_stable;
										charSel <= 0;
										charSel2 <= CharSel_store;
										
										
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit2;
								end case;													
							end if;
							
							
						when digit2 =>
							if Decode_stable /= Decode_prev then
							
									record_key <= record_key * 16 + to_integer(unsigned(Decode_stable(3 downto 0)));
									disp_first_digit <= std_logic_vector(to_unsigned(record_key, 8));
									Decode_prev <= Decode_stable;
									
									--if 1 and 0, then HEX is 00010000 and decimal is 16
									--display 16
									charSel <= record_key / 100;
									CharSel2  <= (record_key / 10) mod 10;
									CharSel3 <= record_key mod 10;
									Decode_stable <= "10000"; --set to unpressed
									Decode_prev <= "10000"; --set to unpressed
									state <= buff;
							end if;
							
						when buff =>
									disp_first_digit <= std_logic_vector(to_unsigned(record_key, 8));
									Decode_prev <= Decode_stable;
									
									--if 1 and 0, then HEX is 00010000 and decimal is 16
									--display 16
									charSel <= record_key / 100;
									CharSel2  <= (record_key / 10) mod 10;
									CharSel3 <= record_key mod 10;
									Decode_stable <= "10000"; --set to unpressed
									Decode_prev <= "10000"; --set to unpressed
									state <= op;							
							
						when op =>
							save_number1 <= record_key; --saves the first number as an integer
							-- Select the operation to use
							if Decode_stable /= Decode_prev then
								
								case Decode_stable is
									when "01010" => --add
										charSel4 <= CharSel_store;
										Decode_prev <= Decode_stable;
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit4;
									
									when "01011" => --subtract
										charSel4 <= CharSel_store;
										Decode_prev <= Decode_stable;
										state <= digit4;
										
									when "01100" => --multiply by 2
										charSel4 <= CharSel_store;
										state <= input_final;
										
									when "01101" => --divide by 2
										charSel4 <= CharSel_store;
										state <= input_final;
										
									when "01110" => --add1
										charSel4 <= CharSel_store;
										state <= input_final;
										
									when "01111" => --subtract1
										charSel4 <= CharSel_store;
										state <= input_final;
										
									when "10001" => --multiply4
										charSel4 <= CharSel_store;
										state <= input_final;
										
									when "10010" => --divide4
										charSel4 <= CharSel_store;
										state <= input_final;
										
									
									when others => Decode_stable <= "10000";
								end case;
							end if;
	

						when digit4 => --after op
							record_key <= 0;
							--enter first digit as 4 bit hex number. If A-F, the character will be 10-16 repsectively in decimal
							if Decode_stable /= Decode_prev then
								
								--in this state, if decode_stable is A-F
								case Decode_stable is
									when "01010" => --when A, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 0;
										
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
										
										
									when "01011" => --when B, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 1;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
										
										
									when "01100" => --when C, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 2;
										
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
										
										
									when "01101" => --when D, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 3;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
										
										
									when "01110" => --when E, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 4;	
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
										
										
									when "01111" => --when F, make charSel1 = 1 and charSel = 0 and move to the third digit3 state
										charSel5 <= 1;
										charSel6 <= 5;
										--saves the hex value as an integer
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
								
								
									when others =>
									
										record_key <= to_integer(unsigned(Decode_stable(3 downto 0))); --converts to an integer
										Decode_prev <= Decode_stable;
										charSel5 <= 0;
										charSel6 <= CharSel_store;
										
										
										Decode_stable <= "10000"; --set to unpressed
										Decode_prev <= "10000"; --set to unpressed
										state <= digit5;
								end case;													
							end if;

						when digit5 =>
							if Decode_stable /= Decode_prev then
									record_key <= record_key * 16 + to_integer(unsigned(Decode_stable(3 downto 0)));
									disp_first_digit <= std_logic_vector(to_unsigned(record_key, 8));
									Decode_prev <= Decode_stable;
									
									--if 1 and 0, then HEX is 00010000 and decimal is 16
									--display 16
									charSel5 <= record_key / 100;
									CharSel6 <= (record_key / 10) mod 10;
									CharSel7 <= record_key mod 10;
									Decode_stable <= "10000"; --set to unpressed
									Decode_prev <= "10000"; --set to unpressed
									state <= buff2;							
							end if;
							
							
							when buff2 =>
									disp_first_digit <= std_logic_vector(to_unsigned(record_key, 8));
									Decode_prev <= Decode_stable;
									
									--if 1 and 0, then HEX is 00010000 and decimal is 16
									--display 16
									charSel5 <= record_key / 100;
									CharSel6 <= (record_key / 10) mod 10;
									CharSel7 <= record_key mod 10;
									Decode_stable <= "10000"; --set to unpressed
									Decode_prev <= "10000"; --set to unpressed
									save_number2 <= record_key;
									state <= input_final;							
							
	
						when input_final =>
							--send command to LCD that says "Press KEY01"
							if KEY = "01" then
								
								case charSel4 is
									when 10 =>
										add_out <= save_number1 + save_number2;
										charSel9  <= add_out / 100;
										CharSel10 <= (add_out / 10) mod 10;
										CharSel11 <= add_out mod 10;
										
									when 11 =>
										sub_out <= save_number1 - save_number2;
										if sub_out < 0 then
											state <= reset;
										else
											charSel9  <= sub_out / 100;
											CharSel10 <= (sub_out / 10) mod 10;
											CharSel11 <= sub_out mod 10;
										end if;
										
										
									when 12 =>
										multiply_2 <= save_number1 * 2;										
										charSel9  <= multiply_2 / 100;
										CharSel10 <= (multiply_2 / 10) mod 10;
										CharSel11 <= multiply_2 mod 10;									
										
									when 13 =>
										divide_2 <= save_number1 / 2;
										--only allow even division
										
										--if (divide_2 mod 2) /= 0 then
										--	state <= reset;
										--else
											charSel9  <= divide_2 / 100;
											CharSel10 <= (divide_2 / 10) mod 10;
											CharSel11 <= divide_2 mod 10;
										--end if;
										
									when 14 =>
										add_1 <= save_number1 + 1;
										--display new chars
										charSel9  <= add_1 / 100;
										CharSel10 <= (add_1 / 10) mod 10;
										CharSel11 <= add_1 mod 10;
										
									when 15 =>
										sub_1 <= save_number1 - 1;
										--display new chars
										if sub_1 < 0 then
											state <= reset;
										else
											charSel9  <= sub_1 / 100;
											CharSel10 <= (sub_1 / 10) mod 10;
											CharSel11 <= sub_1 mod 10;
										end if;
									when 16 =>
										multiply_4 <= save_number1 * 4;										
										--check if less than 1000 decimal:
										if multiply_4 > 999 then
											state <= reset;
										else
											charSel9  <= multiply_4 / 100;
											CharSel10 <= (multiply_4 / 10) mod 10;
											CharSel11 <= multiply_4 mod 10;
										end if;
																				
									when 17 =>
										divide_4 <= save_number1 / 4;
										--only allow even division
										--if (divide_4 mod 4) /= 0 then
										--	state <= reset;
										--else
											charSel9  <= divide_4 / 100;
											CharSel10 <= (divide_4 / 10) mod 10;
											CharSel11 <= divide_4 mod 10;
										--end if;
										
									when others => state <= input_final;
								end case;
								
								
								
								
								
								
								
							end if;
						when others =>
							state <= reset;
					end case;
				end if;
				
				
				
				
		end if;
	end process;
	

	--test signals:
	--LEDR <= std_logic_vector(to_unsigned(record_key, 8)); --8 bits (display LED for debugging)
	--LEDR <= std_logic_vector(to_unsigned(save_number1, 8)); --8 bits (display LED for debugging)
	--LEDR <= std_logic_vector(to_unsigned(save_number2, 10)); --8 bits (display LED for debugging)
	
	
	--check if LEDR is not 360 (replace with any integer value)
	--LEDR <= "1111111111" when add_out = 360 else
	--		  "0000000000";
	
	
   --LEDR <= std_logic_vector(to_unsigned(add_out, 8));
   --LEDR <= std_logic_vector(to_unsigned(divide_2, 8));
   --LEDR <= std_logic_vector(to_unsigned(divide_4, 8));
	


	
end Behavioral;
