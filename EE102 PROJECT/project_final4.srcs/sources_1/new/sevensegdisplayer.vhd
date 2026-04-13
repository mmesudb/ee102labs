library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sevensegdisplayer is
    Port (
        clk      : in  STD_LOGIC;                           -- 100 MHz clock
        value_in : in  STD_LOGIC_VECTOR (4 downto 0);       -- 5-bit binary input (0-31)
        an       : out STD_LOGIC_VECTOR (3 downto 0);       -- anodes (active low)
        seg_out      : out STD_LOGIC_VECTOR (6 downto 0)        -- segments a to g
    );
end sevensegdisplayer;

architecture Behavioral of sevensegdisplayer is

    signal digit_ones  : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_tens  : STD_LOGIC_VECTOR(3 downto 0);
    signal mux_select  : STD_LOGIC := '0';
    signal seg     : STD_LOGIC_VECTOR(6 downto 0);
    signal clk_div     : STD_LOGIC := '0';
    signal div_counter : INTEGER range 0 to 49999 := 0;

begin

    -- Clock Divider
    process(clk)
    begin
        if rising_edge(clk) then
            if div_counter = 49999 then
                div_counter <= 0;
                clk_div <= not clk_div;
            else
                div_counter <= div_counter + 1;
            end if;
        end if;
    end process;

    -- Mux toggling
    process(clk_div)
    begin
        if rising_edge(clk_div) then
            mux_select <= not mux_select;
        end if;
    end process;

    -- Binary to BCD
    process(value_in)
        variable val : INTEGER;
    begin
        val := to_integer(unsigned(value_in));
        digit_tens <= std_logic_vector(to_unsigned(val / 10, 4));
        digit_ones <= std_logic_vector(to_unsigned(val mod 10, 4));
    end process;

    -- Segment output based on selected digit
    process(mux_select, digit_tens, digit_ones)
    begin
        case mux_select is
            when '0' =>
                an <= "1110";
                case digit_ones is
                    when "0000" => seg <= "1000000"; -- 0
                    when "0001" => seg <= "1111001"; -- 1
                    when "0010" => seg <= "0100100"; -- 2
                    when "0011" => seg <= "0110000"; -- 3
                    when "0100" => seg <= "0011001"; -- 4
                    when "0101" => seg <= "0010010"; -- 5
                    when "0110" => seg <= "0000010"; -- 6
                    when "0111" => seg <= "1111000"; -- 7
                    when "1000" => seg <= "0000000"; -- 8
                    when "1001" => seg <= "0010000"; -- 9
                    when others => seg <= "1111111"; -- blank
                end case;
            when others =>
                an <= "1101";
                case digit_tens is
                    when "0000" => seg <= "1000000"; -- 0
                    when "0001" => seg <= "1111001"; -- 1
                    when "0010" => seg <= "0100100"; -- 2
                    when "0011" => seg <= "0110000"; -- 3
                    when others => seg <= "1111111"; -- blank (only 0-3 valid for tens)
                end case;
        end case;
    end process;

    seg_out <= seg;

end Behavioral;