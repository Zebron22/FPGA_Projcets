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
              seg : out  STD_LOGIC_VECTOR (6 downto 0); -- digit to display on the seven segment display
              trigger : out std_logic;                            --observe this signal
              Decode_debug : out std_logic_vector(3 downto 0);    --observe this signal
              Decode_reg_dbug : out std_logic_vector(3 downto 0)  --observe this signal
              );
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
            trigger : out std_logic; 
          clk_100M : in std_logic);
	end component;

signal Decode: STD_LOGIC_VECTOR (3 downto 0);
signal Decode_reg : std_logic_vector(3 downto 0);
signal trigger_counter: std_logic_vector(19 downto 0);
signal Decode_or_reduced: std_logic;



--fsm for trigger
--type state_type is (state_0, state_1);
--signal state: state_type;



begin
	C0: Decoder port map (clk=>clk, Row =>JA(7 downto 4), Col=>JA(3 downto 0), DecodeOut=> Decode);
	C1: DisplayController port map (DispVal=>Decode, anode=>an, segOut=>seg, clk_100M=>clk, trigger=>trigger);

	Decode_reg_dbug <= Decode_reg;
	Decode_debug <= Decode;


--trigger mechanism
--    process(clk) begin
--        if (rising_edge(clk)) then
--            case state is
--                when state_0 =>
--                    if (Decode /= Decode_reg) then
--                        trigger <= '1';
--                        state <= state_1;
--                        Decode_reg <= Decode;
--                    end if;
                
--                when state_1 =>
--                    if (Decode /= Decode_reg and trigger <= '1') then
--                        trigger <= '0';
--                        state <= state_0;
--                        Decode_reg <= Decode;
--                    end if;
--            end case;
--        end if;
--    end process;
    
end Behavioral;