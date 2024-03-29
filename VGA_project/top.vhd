--Cebron Williams
--update 12/04/2023: added support for multiple same inputs
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top is
    Port (
		  SW            : in std_logic_vector(1 downto 0);
		  LEDR          : out std_logic_vector(7 downto 0); --debug signal
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
end top;

architecture Behavioral of top is
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
			MAX10_CLK1_50 : in std_logic;
			
			LEDR : out std_logic_vector(7 downto 0);
			state_set : in std_logic
		);
	end component;
	
	signal x, y : STD_LOGIC_VECTOR(9 downto 0);
	signal clock25MHz : STD_LOGIC; -- 25 MHz clock signal
	signal clock1s : std_logic; -- 1 Hz clk signal
	signal charSel: integer range 0 to 18 := 0; --selects character
	signal Decode : std_logic_vector(4 downto 0);
	signal Decode_prev: std_logic_vector(4 downto 0) := "10000";	 

	type   state_type is (reset, digit1, digit2, digit3, op, digit4, digit5, digit6, input_final);
	signal state : state_type := reset; --used as a FSM for keypad inputs
	
	type HEXstate_type is (HEXreset, HEXdigit1, HEXdigit2, HEXdigit3, op, HEXdigit4,HEXdigit5, HEXdigit6, HEXinput_final);
	signal HEXstate : HEXstate_type  := HEXreset; --Created an option for HEX inputs
	
	
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
	
	signal disp : std_logic_vector(15 downto 0);
	
	signal disp_100 : integer;
	signal disp_10 : integer;
	signal disp_1 : integer;
	signal remain : integer;
	
	signal clkCount : std_logic_vector(6 downto 0):= "0000000";								--MAX10_CLK1_50 divider count
	signal oneUSClk : std_logic;																		--1 micro second clock signal
	
	
	signal state_set : std_logic := '0';
	
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

	LCDdisplayInstance: LCDdisplay port map (DB => DB, RS => RS, RW => RW, EN => EN, MAX10_CLK1_50 => MAX10_CLK1_50, state_set => state_set);
	
	
	
	
	
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

	
	
	--Main FSM that displays the characters (decimal)
	process(oneUSClk, clock100ms, Decode, Decode_prev, state, Decode_stable, charSel_store, charSel, charSel2, charSel3, charSel4, charSel5, charSel6, charSel7, charSel8, charSel9, charSel10, charSel11, KEY)
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
							
							disp_1   <= 0;
							disp_10  <= 0;
							disp_100 <= 0;
							state           <= digit1;
							

						when digit1 =>
							--enter first digit
							if Decode_stable /= Decode_prev then
								record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));         --records first number input and converts to integer
								Decode_prev <= Decode_stable;
								charSel <= CharSel_store;								
								Decode_stable <= "10000"; --set to unpressed
								Decode_prev <= "10000"; --set to unpressed
								state <= digit2;
							end if;							
							
							

						when digit2 =>
							if Decode_stable /= Decode_prev then
								 record_key <= record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
								 Decode_prev <= Decode_stable;
								 charSel2 <= CharSel_store;
								 Decode_stable <= "10000"; --set to unpressed
								 Decode_prev <= "10000"; --set to unpressed
								 state <= digit3;
							end if;
				
							
						when digit3 =>
							if Decode_stable /= Decode_prev then
								verify_record_key := record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
								--check if greater than 255
								if verify_record_key > 255 then
									--print on LCD screen "not allowed"
									
									state <= reset;
								else
									--record_key <= record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
									record_key <= verify_record_key;
									Decode_prev <= Decode_stable;
									charSel3 <= CharSel_store;
									Decode_stable <= "10000"; --set to unpressed
								   Decode_prev <= "10000"; --set to unpressed
									state <= op;								
								end if;
							end if;
							
							
						when op =>
							save_number1 <= record_key; --saves the first number
							-- Select the operation to use
							if Decode_stable /= Decode_prev then
								
								case Decode_stable is
									when "01010" => --add
										charSel4 <= CharSel_store;
										Decode_prev <= Decode_stable;
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
	

						when digit4 =>
							--enter first digit
							if Decode_stable /= Decode_prev then
								
								record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));         --records first number input and converts to integer
								Decode_prev <= Decode_stable;
								charSel5 <= CharSel_store;
								Decode_stable <= "10000"; --set to unpressed
								Decode_prev <= "10000"; --set to unpressed
								state <= digit5;
							end if;

						when digit5 =>
							if Decode_stable /= Decode_prev then
								 record_key <= record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
								 Decode_prev <= Decode_stable;
								 charSel6 <= CharSel_store;
								 Decode_stable <= "10000"; --set to unpressed
								 Decode_prev <= "10000"; --set to unpressed
								 state <= digit6;
							end if;
				
							
						when digit6 =>
							if Decode_stable /= Decode_prev then
								verify_record_key := record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
								--check if greater than 255
								if verify_record_key > 255 then
									--print on LCD screen "not allowed"
									
									state <= reset;
								else
									--record_key <= record_key * 10 + to_integer(unsigned(Decode_stable(3 downto 0)));
									record_key <= verify_record_key;
									Decode_prev <= Decode_stable;
									charSel7 <= CharSel_store;
									Decode_stable <= "10000"; --set to unpressed
								   Decode_prev <= "10000"; --set to unpressed
									state <= input_final;								
								end if;
							end if;
	
						when input_final =>
							save_number2 <= record_key;
							--send command to LCD that says "Press KEY01"
							if KEY = "01" then
								
								case charSel4 is
									when 10 =>
										add_out <= save_number1 + save_number2;
										--display new chars
										disp <= std_logic_vector(to_unsigned(add_out, 16)); --disp is a 16-bit slv
										
										disp_1   <= add_out mod 10; -- Last digit
										remain   <= add_out / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
										
									when 11 =>
										sub_out <= save_number1 - save_number2;
										--display new chars
										
										disp_1   <= sub_out mod 10; -- Last digit
										remain   <= sub_out / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
										
									when 12 =>
										multiply_2 <= save_number1 * 2;
										--display new chars
										
										disp_1   <= multiply_2 mod 10; -- Last digit
										remain   <= multiply_2 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;										
										
									when 13 =>
										--convert to slv and shift 1 to the right
										divide_2 <= save_number1 / 2;

										disp_1   <= divide_2 mod 10; -- Last digit
										remain   <= divide_2 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;	
										
										
									when 14 =>
										add_1 <= save_number1 + 1;
										--display new chars
										disp_1   <= add_1 mod 10; -- Last digit
										remain   <= add_1 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
										
									when 15 =>
										sub_1 <= save_number1 - 1;
										--display new chars
										
										disp_1   <= sub_1 mod 10; -- Last digit
										remain   <= sub_1 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
									when 16 =>
										multiply_4 <= save_number1 * 4;
										--display new chars
										
										disp_1   <= multiply_4 mod 10; -- Last digit
										remain   <= multiply_4 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
									when 17 =>
										divide_4 <= save_number1 / 4;
										--disp new chars
										
										disp_1   <= divide_4 mod 10; -- Last digit
										remain   <= divide_4 / 10;   -- Remaining number
										disp_10  <= remain mod 10;
										disp_100 <= remain / 10;
										
										charSel9  <= disp_100;
										charSel10 <= disp_10;
										charSel11 <= disp_1;
										
										
									when others => state <= input_final;
								end case;
							end if;
							
						when others =>
							state <= reset;
					end case;
				end if;
				
				
				
				
		end if;
	end process;
	

	--LEDR <= std_logic_vector(to_unsigned(record_key, 8)); --8 bits (display LED for debugging)
	--LEDR <= std_logic_vector(to_unsigned(save_number1, 8)); --8 bits (display LED for debugging)

	--LEDR <= std_logic_vector(to_unsigned(save_number2, 8)); --8 bits (display LED for debugging)
   --LEDR <= std_logic_vector(to_unsigned(add_out, 8));
   --LEDR <= std_logic_vector(to_unsigned(divide_2, 8));
   --LEDR <= std_logic_vector(to_unsigned(divide_4, 8));


	
end Behavioral;