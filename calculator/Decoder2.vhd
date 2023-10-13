library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--decoder for 4x4 keypad PMOD

entity Decoder is
    port (
        clk : in std_logic;
        row : in std_logic_vector(3 downto 0);
        col : in std_logic_vector(3 downto 0);
        decodeOut : out std_logic_vector(3 downto 0)
    );

end Decoder;

architecture Beh of Decoder is
    
    process(row, col)
    begin
        case (row, col)
            when "11101110" => decodeOut <= "0000"; -- key 1
            when "11101101" => decodeOut <= "0001"; -- key 2
            when "11101011" => decodeOut <= "0010"; -- key 3
            when "11100111" => decodeOut <= "0011"; -- key A
            
            when "11011110" => decodeOut <= "0100"; -- key 4
            when "11011101" => decodeOut <= "0101"; -- key 5
            when "11011011" => decodeOut <= "0110"; -- key 6
            when "11010111" => decodeOut <= "0111"; -- key B
            
            when "10111110" => decodeOut <= "1000"; -- key 7
            when "10111101" => decodeOut <= "1010"; -- key 8
            when "10111011" => decodeOut <= "1011"; -- key 9 
            when "10110111" => decodeOut <= "1100"; -- key C
            
            when "01111110" => decodeOut <= "1101"; -- key *
            when "01111101" => decodeOut <= "1110"; -- key 0
            when "01111011" => decodeOut <= "1111"; -- key #
            
            when others => decodeOut <= "1111"; -- key D is used as a default case
        end case;
    end process;


end Beh;
