--Cebron Williams
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity VideoSyncGenerator is
    Port (
        clock25MHz : in STD_LOGIC;
        vsync : out STD_LOGIC;
        hsync : out STD_LOGIC;
        canDisplayImage : out STD_LOGIC;
        x : out STD_LOGIC_VECTOR(9 downto 0);
        y : out STD_LOGIC_VECTOR(9 downto 0)
    );
end VideoSyncGenerator;

architecture Behavioral of VideoSyncGenerator is

    signal xCounter, yCounter: INTEGER range 0 to 799; -- Adjust range as needed

begin

    -- Horizontal counter
    process(clock25MHz)
    begin
        if rising_edge(clock25MHz) then
            if (xCounter < 799) then
                xCounter <= xCounter + 1;
            else
                xCounter <= 0;
            end if;
        end if;
    end process;

    -- Vertical counter
    process(clock25MHz)
    begin
        if rising_edge(clock25MHz) then
            if (xCounter = 799) then
                if (yCounter < 525) then
                    yCounter <= yCounter + 1;
                else
                    yCounter <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Calculate x and y
    process(clock25MHz)
    begin
        if rising_edge(clock25MHz) then
            if (xCounter >= 144 and xCounter < 784) then
                x <= std_logic_vector(to_unsigned(xCounter - 144, 10));
            else
                x <= (others => '0');
            end if;

            if (yCounter >= 35 and yCounter < 515) then
                y <= std_logic_vector(to_unsigned(yCounter - 35, 10));
            else
                y <= (others => '0');
            end if;
        end if;
    end process;

    -- Sync signals
    hsync <= '1' when (xCounter >= 0 and xCounter < 96) else '0';
    vsync <= '1' when (yCounter >= 0 and yCounter < 2) else '0';

    -- Display image signal
    canDisplayImage <= '1' when ((xCounter > 144) and (xCounter <= 783) and
                                 (yCounter > 35) and (yCounter <= 514)) else '0';

end Behavioral;
