library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gesture_decoder is
    Port (
        gesture_code : in  std_logic_vector(12 downto 0);
        letter_code  : out std_logic_vector(4 downto 0)
    );
end gesture_decoder;

architecture Behavioral of gesture_decoder is
begin
    process(gesture_code)
    begin
        case gesture_code is
            when "0100100100100" => letter_code <= "00001";  -- A
            when "1001001001001" => letter_code <= "00010";  -- B
            when "0010100100100" => letter_code <= "00011";  -- C
            when "0001010010010" => letter_code <= "00100";  -- D
            when "1010010010010" => letter_code <= "00101";  -- E
            when "0010001001001" => letter_code <= "00110";  -- F
            when "0010010100100" => letter_code <= "00111";  -- G
            when "1100001010001" => letter_code <= "01000";  -- H
            when "1100100100001" => letter_code <= "01001";  -- I
            when "1100100100010" => letter_code <= "01010";  -- J
            when "0001001100100" => letter_code <= "01011";  -- K
            when "0001100100100" => letter_code <= "01100";  -- L
            when "1010010010100" => letter_code <= "01101";  -- M
            when "1010010100100" => letter_code <= "01110";  -- N
            when "0010010010010" => letter_code <= "01111";  -- O
            when "0001010100100" => letter_code <= "10000";  -- P
            when "0010010010001" => letter_code <= "10001";  -- Q
            when "0010001100100" => letter_code <= "10010";  -- R
            when "1100010010001" => letter_code <= "10011";  -- S
            when "1001001001100" => letter_code <= "10100";  -- T
            when "0001100001100" => letter_code <= "10101";  -- U
            when "1001001100100" => letter_code <= "10110";  -- V
            when "1001010001100" => letter_code <= "10111";  -- W
            when "1010100100100" => letter_code <= "11000";  -- X
            when "0100100100001" => letter_code <= "11001";  -- Y
            when "1001001100001" => letter_code <= "11010";  -- Z
            when "0001001001001" => letter_code <= "11111";  -- lettertoletter
            when "1100100100100" => letter_code <= "11110";  -- space
            when others => letter_code <= "00000";  -- default
        end case;
    end process;
end Behavioral;