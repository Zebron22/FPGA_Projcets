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
        VGA_B         : out STD_LOGIC_VECTOR(3 downto 0)
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
			charSel : in INTEGER range 0 to 17;         -- Character selection (for multiple characters)
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
	 
	
	
	signal x, y : STD_LOGIC_VECTOR(9 downto 0);
	signal clock25MHz : STD_LOGIC; -- 25 MHz clock signal
	signal clock1s : std_logic; -- 1 Hz clk signal
	signal charSel: integer range 0 to 18 := 0; --selects character
	signal Decode : std_logic_vector(4 downto 0);
	signal Decode_prev: std_logic_vector(4 downto 0) := "10000";	 

	type   state_type is (reset, digit1, digit2, digit3, input3, input4, input5, input_final);
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

	signal charSel2: integer range 0 to 18 := 0; --selects character
	signal charSel3: integer range 0 to 18 := 0; --selects character
	signal charSel4: integer range 0 to 18 := 0; --selects character
	signal charSel5: integer range 0 to 18 := 0; --selects character


	signal red1, green1, blue1: std_logic_vector(3 downto 0);
	signal red2, green2, blue2: std_logic_vector(3 downto 0);
	signal red3, green3, blue3: std_logic_vector(3 downto 0);
	signal red4, green4, blue4: std_logic_vector(3 downto 0);
	signal red5, green5, blue5: std_logic_vector(3 downto 0);
	
	signal record_key : integer;	
	signal save_number1 : integer;
	signal save_number2 : integer;
	signal add_out : integer;
	
begin
	
	charX2 <= std_logic_vector(unsigned(charX)  + to_unsigned(20, charX'length));
	charX3 <= std_logic_vector(unsigned(charX2) + to_unsigned(20, charX'length));
	charX4 <= std_logic_vector(unsigned(charX3) + to_unsigned(20, charX'length));
	charX5 <= std_logic_vector(unsigned(charX4) + to_unsigned(20, charX'length));
	
	DecodedValue     : Decoder port map (clk => MAX10_CLK1_50, Row => Row, Col => Col, DecodeOut => Decode);
	VideoSyncInstance: VideoSyncGenerator port map (clock25MHz => clock25MHz, vsync => VGA_VS, hsync => VGA_HS, x => x, y => y);
	PatternInstance  : tvPattern port map (x => x, y => y, charX => charX,   charY => charY,    red => red1, green => green1, blue => blue1, charSel => charSel);
	PatternInstance2 : tvPattern port map (x => x, y => y, charX => charX2,  charY => charY,  red => red2, green => green2, blue => blue2, charSel => charSel2); --shifted to the right
	PatternInstance3 : tvPattern port map (x => x, y => y, charX => charX3,  charY => charY,  red => red3, green => green3, blue => blue3, charSel => charSel3); --shifted to the right
	PatternInstance4 : tvPattern port map (x => x, y => y, charX => charX4,  charY => charY,  red => red4, green => green4, blue => blue4, charSel => charSel4); --shifted to the right
	PatternInstance5 : tvPattern port map (x => x, y => y, charX => charX5,  charY => charY,  red => red5, green => green5, blue => blue5, charSel => charSel5); --shifted to the right
	
	--controlling how the signal is displayed
	process(x, y, red1, green1, blue1, red2, green2, blue2, red3, green3, blue3, red4, green4, blue4, red5, green5, blue5, charX2, charX3, charX4, charX5)
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

		 else
			  -- Use output from the fourth pattern
			  VGA_R <= red5;
			  VGA_G <= green5;
			  VGA_B <= blue5;
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
	process(Decode_stable, charSel_store, charSel, charSel2, charSel3, charSel4, charSel5, state, KEY)
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
		when others  =>  charSel_store <= 18; -- empty char for reset
	end case;
	end process;

	
	
	--displays the characters
	process(clock100ms, Decode, Decode_prev, state, Decode_stable, charSel_store, charSel, charSel2, charSel3, charSel4, KEY)
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
							record_key   <= 0;
							save_number1 <= 0;
							save_number2 <= 0;
							add_out <= 0;
							state           <= digit1;
							

						when digit1 =>
							--enter first digit
							if Decode_stable /= Decode_prev then
								
								record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));         --records first number input and converts to integer
								Decode_prev <= Decode_stable;
								charSel <= CharSel_store;
								state <= digit2;
							end if;

						when digit2 =>
							--inter second digit
							if Decode_stable /= Decode_prev then
								record_key <= to_integer(unsigned(Decode_prev(3 downto 0))) * 10 + to_integer(unsigned(Decode_stable(3 downto 0))); -- New value
								
								
								Decode_prev <= Decode_stable;
								charSel2 <= CharSel_store;
								state <= input3;
							end if;						

						when input3 =>
							save_number1 <= record_key; --saves the first number
							-- Select the operation to use
							if Decode_stable /= Decode_prev then
								
								case Decode_stable is
									when "01010" => --add
										charSel3 <= CharSel_store;
										Decode_prev <= Decode_stable;
										state <= input4;
									
									when "01011" => --subtract
										charSel3 <= CharSel_store;
										Decode_prev <= Decode_stable;
										state <= input4;
										
									when "01100" => --multiply by 2
										charSel3 <= CharSel_store;
										
										
									when "01101" => --divide by 2
										charSel3 <= CharSel_store;
										
										
									when "01110" => --add1
										charSel3 <= CharSel_store;
										
										
									when "01111" => --subtract1
										charSel3 <= CharSel_store;
										
										
									when "10001" => --multiply4
										charSel3 <= CharSel_store;
										
										
									when "10010" => --divide4
										charSel3 <= CharSel_store;
										
										
									
									when others => Decode_stable <= "10000";
								end case;
							
							end if;

						when input4 =>
							if Decode_stable /= Decode_prev then
								record_key <= to_integer(unsigned(Decode_stable(3 downto 0)));
								Decode_prev <= Decode_stable;
								charSel4 <= CharSel_store;
								state <= input5;
							end if;

						when input5 =>
							if Decode_stable /= Decode_prev then
								record_key <= to_integer(unsigned(Decode_prev(3 downto 0))) * 10 + to_integer(unsigned(Decode_stable(3 downto 0))); -- New value
								Decode_prev <= Decode_stable;
								charSel5 <= CharSel_store;
								state <= input_final;
							end if;
						
						when input_final =>
							save_number2 <= record_key;
							if KEY = "01" then
								add_out <= save_number1 + save_number2;
							end if;
						
							
							
						when others =>
							state <= reset;
					end case;
				end if;
			
		end if;
	end process;



	--LEDR <= std_logic_vector(to_unsigned(record_key, 8)); --8 bits (display LED for debugging)
	--LEDR <= std_logic_vector(to_unsigned(save_number2, 8)); --8 bits (display LED for debugging)
   LEDR <= std_logic_vector(to_unsigned(add_out, 8));
	
	
end Behavioral;