library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity tvPattern is
    Port (
        x       : in STD_LOGIC_VECTOR(9 downto 0);
        y       : in STD_LOGIC_VECTOR(9 downto 0);
        charX   : in STD_LOGIC_VECTOR(9 downto 0); -- X position of the character
        charY   : in STD_LOGIC_VECTOR(9 downto 0); -- Y position of the character
        charSel : in INTEGER range 0 to 17;         -- Character selection (for multiple characters)
        red     : out STD_LOGIC_VECTOR(3 downto 0);
        green   : out STD_LOGIC_VECTOR(3 downto 0);
        blue    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end tvPattern;

architecture Behavioral of tvPattern is

--test charX and charY
--setting the pos in the center and testing char
--signal charX   : std_logic_vector(9 downto 0) := "0101000000"; --640
--signal charY   : std_logic_vector(9 downto 0) := "0011110000"; --480
--signal charSel : INTEGER range 0 to 10;         -- Character selection (for multiple characters)



-- Define character patterns
-- Numbers seem to be backwards
type char_pattern_type is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
constant zero: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000011",
3  => "1100000000000011",
4  => "1100000000000011",
5  => "1100000000000011",
6  => "1100000000000011",
7  => "1100000000000011",
8  => "1100000000000011",
9  => "1100000000000011",
10 => "1100000000000011",
11 => "1100000000000011",
12 => "1100000000000011",
13 => "1100000000000011",
14 => "1111111111111111",
15 => "1111111111111111");


constant one: char_pattern_type := (
0  => "0000001110000000",
1  => "0000001110000000",
2  => "0000001110000000",
3  => "0000001110000000",
4  => "0000001110000000",
5  => "0000001110000000",
6  => "0000001110000000",
7  => "0000001110000000",
8  => "0000001110000000",
9  => "0000001110000000",
10 => "0000001110000000",
11 => "0000001110000000",
12 => "0000001110000000",
13 => "0000001110000000",
14 => "0000001110000000",
15 => "0000001110000000");


constant two: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000000",
3  => "1100000000000000",
4  => "1100000000000000",
5  => "1100000000000000",
6  => "1100000000000000",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "0000000000000011",
10 => "0000000000000011",
11 => "0000000000000011",
12 => "0000000000000011",
13 => "0000000000000011",
14 => "1111111111111111",
15 => "1111111111111111");

constant three: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000000",
3  => "1100000000000000",
4  => "1100000000000000",
5  => "1100000000000000",
6  => "1100000000000000",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000000",
10 => "1100000000000000",
11 => "1100000000000000",
12 => "1100000000000000",
13 => "1100000000000000",
14 => "1111111111111111",
15 => "1111111111111111");

constant four: char_pattern_type := (
0  => "1100000000000011",
1  => "1100000000000011",
2  => "1100000000000011",
3  => "1100000000000011",
4  => "1100000000000011",
5  => "1100000000000011",
6  => "1100000000000011",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000000",
10 => "1100000000000000",
11 => "1100000000000000",
12 => "1100000000000000",
13 => "1100000000000000",
14 => "1100000000000000",
15 => "1100000000000000");

constant five: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "0000000000000011",
3  => "0000000000000011",
4  => "0000000000000011",
5  => "0000000000000011",
6  => "0000000000000011",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000000",
10 => "1100000000000000",
11 => "1100000000000000",
12 => "1100000000000000",
13 => "1100000000000000",
14 => "1111111111111111",
15 => "1111111111111111");

constant six: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "0000000000000011",
3  => "0000000000000011",
4  => "0000000000000011",
5  => "0000000000000011",
6  => "0000000000000011",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000011",
10 => "1100000000000011",
11 => "1100000000000011",
12 => "1100000000000011",
13 => "1100000000000011",
14 => "1111111111111111",
15 => "1111111111111111");

constant seven: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000000",
3  => "1100000000000000",
4  => "1100000000000000",
5  => "1100000000000000",
6  => "1100000000000000",
7  => "1100000000000000",
8  => "1100000000000000",
9  => "1100000000000000",
10 => "1100000000000000",
11 => "1100000000000000",
12 => "1100000000000000",
13 => "1100000000000000",
14 => "1100000000000000",
15 => "1100000000000000");

constant eight: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000011",
3  => "1100000000000011",
4  => "1100000000000011",
5  => "1100000000000011",
6  => "1100000000000011",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000011",
10 => "1100000000000011",
11 => "1100000000000011",
12 => "1100000000000011",
13 => "1100000000000011",
14 => "1111111111111111",
15 => "1111111111111111");

constant nine: char_pattern_type := (
0  => "1111111111111111",
1  => "1111111111111111",
2  => "1100000000000011",
3  => "1100000000000011",
4  => "1100000000000011",
5  => "1100000000000011",
6  => "1100000000000011",
7  => "1111111111111111",
8  => "1111111111111111",
9  => "1100000000000000",
10 => "1100000000000000",
11 => "1100000000000000",
12 => "1100000000000000",
13 => "1100000000000000",
14 => "1111111111111111",
15 => "1111111111111111");

constant add: char_pattern_type := (
0  => "0000000000000000",
1  => "0000000000000000",
2  => "0000000000000000",
3  => "0000000000000000",
4  => "0000000110000000",
5  => "0000000110000000",
6  => "0000000110000000",
7  => "0001111111111000",
8  => "0001111111111000",
9  => "0000000110000000",
10 => "0000000110000000",
11 => "0000000110000000",
12 => "0000000000000000",
13 => "0000000000000000",
14 => "0000000000000000",
15 => "0000000000000000");


constant subtract: char_pattern_type := (
0  => "0000000000000000",
1  => "0000000000000000",
2  => "0000000000000000",
3  => "0000000000000000",
4  => "0000000000000000",
5  => "0000000000000000",
6  => "0000000000000000",
7  => "0001111111111000",
8  => "0001111111111000",
9  => "0000000000000000",
10 => "0000000000000000",
11 => "0000000000000000",
12 => "0000000000000000",
13 => "0000000000000000",
14 => "0000000000000000",
15 => "0000000000000000");


constant multiply_by_2: char_pattern_type := (
  0  => "0000000000000000",
  1  => "0000000000000000",
  2  => "0000000000000000",
  3  => "0000000000000000",
  4  => "1111111010000001",
  5  => "1000000001000010",
  6  => "1000000000100100",
  7  => "1111111000011000",
  8  => "1111111000011000",
  9  => "0000001000100100",
  10 => "0000001001000010",
  11 => "1111111010000001",
  12 => "0000000000000000",
  13 => "0000000000000000",
  14 => "0000000000000000",
  15 => "0000000000000000");


constant divide_by_2: char_pattern_type := (
  0  => "0000000000000000",
  1  => "0000000000000000",
  2  => "0000000000000000",
  3  => "0000000000000000",
  4  => "1111111000011000",
  5  => "1000000000011000",
  6  => "1000000000000000",
  7  => "1111111011111111",
  8  => "1111111011111111",
  9  => "0000001000000000",
  10 => "0000001000011000",
  11 => "1111111000011000",
  12 => "0000000000000000",
  13 => "0000000000000000",
  14 => "0000000000000000",
  15 => "0000000000000000");



constant add_1: char_pattern_type := (
0  => "0000000000000000",
1  => "0000000000000000",
2  => "0000000000000000",
3  => "0000000000000000",
4  => "0000000000011000",
5  => "0001110000011000",
6  => "0001110000011000",
7  => "0111111110011000",
8  => "0111111110011000",
9  => "0001110000011000",
10 => "0001110000011000",
11 => "0000000000011000",
12 => "0000000000000000",
13 => "0000000000000000",
14 => "0000000000000000",
15 => "0000000000000000");

constant sub_1: char_pattern_type := (
0  => "0000000000000000",
1  => "0000000000000000",
2  => "0000000000000000",
3  => "0000000000000000",
4  => "0000000000011000",
5  => "0000000000011000",
6  => "0000000000011000",
7  => "0111111110011000",
8  => "0111111110011000",
9  => "0000000000011000",
10 => "0000000000011000",
11 => "0000000000011000",
12 => "0000000000000000",
13 => "0000000000000000",
14 => "0000000000000000",
15 => "0000000000000000");




constant multiply_by_4: char_pattern_type := (
  0  => "0000000000000000",
  1  => "0000000000000000",
  2  => "0000000000000000",
  3  => "0000000000000000",
  4  => "1000001010000001",
  5  => "1000001001000010",
  6  => "1000001000100100",
  7  => "1111111000011000",
  8  => "1111111000011000",
  9  => "1000000000100100",
  10 => "1000000001000010",
  11 => "1000000010000001",
  12 => "0000000000000000",
  13 => "0000000000000000",
  14 => "0000000000000000",
  15 => "0000000000000000");


constant divide_by_4: char_pattern_type := (
  0  => "0000000000000000",
  1  => "0000000000000000",
  2  => "0000000000000000",
  3  => "0000000000000000",
  4  => "1000001000011000",
  5  => "1000001000011000",
  6  => "1000001000000000",
  7  => "1111111011111111",
  8  => "1111111011111111",
  9  => "1000000000000000",
  10 => "1000000000011000",
  11 => "1000000000011000",
  12 => "0000000000000000",
  13 => "0000000000000000",
  14 => "0000000000000000",
  15 => "0000000000000000");








begin

--charSel <= 1;

    process(x, y, charX, charY, charSel)
	 
	 variable row : integer range 0 to 15;
	 variable col : integer range 0 to 15;
	 
	 
    begin
        if unsigned(x) >= unsigned(charX) and unsigned(x) < unsigned(charX) + 16 and
           unsigned(y) >= unsigned(charY) and unsigned(y) < unsigned(charY) + 16 then
            -- Calculate which row of the character to display
				
            row := to_integer(unsigned(y)) - to_integer(unsigned(charY));
            col := to_integer(unsigned(x)) - to_integer(unsigned(charX));

            -- Display the character
            case charSel is

                when 0 => -- For 'zero'
                    if zero(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
						  
						  
                when 1 => -- For 'one'
                    if one(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
						  
					 when 2 => -- For 'two'
						  if two(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;

					 when 3 => 
						  if three(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
						  
					 when 4 => 
						  if four(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;					
						  
						  
					 when 5 => 
						  if five(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;						  
						  
					 when 6 => 
						  if six(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
						  
					 when 7 => 
						  if seven(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
						  
					 when 8 =>
						  if eight(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;						  


					 when 9 => 
						  if nine(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;
					
					 when 10 => 
						  if add(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;					

			
					 when 11 => 
						  if subtract(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;				

					 when 12 => 
						  if multiply_by_2(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;							  

					 when 13 => 
						  if divide_by_2(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;	
	
					 when 14 => 
						  if add_1(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;

					 when 15 => 
						  if sub_1(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;

					 when 16 => 
						  if multiply_by_4(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;

					 when 17 => 
						  if divide_by_4(row)(col) = '1' then
                        red   <= "1111";
                        green <= "1111";
                        blue  <= "1111";
                    else
                        red   <= (others => '0');
                        green <= (others => '0');
                        blue  <= (others => '0');
                    end if;


						  
                -- Add cases for other characters
                when others =>
                    red   <= (others => '0');
                    green <= (others => '0');
                    blue  <= (others => '0');
            end case;
        else
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '0');
        end if;
    end process;
end Behavioral;
