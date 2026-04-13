library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lettercode_to_ascii is
    Port (
        letter_code   : in  STD_LOGIC_VECTOR (4 downto 0);
        letter_ascii  : out STD_LOGIC_VECTOR (7 downto 0)
    );
end lettercode_to_ascii;

architecture Behavioral of lettercode_to_ascii is
    signal code_int : integer := to_integer(unsigned(letter_code));
begin

    process(letter_code)
    begin
        case letter_code is
            when "11110" => 
                letter_ascii <= x"20"; -- Space
            when "11111" => 
                letter_ascii <= x"00"; -- for letter-to-letter
            when "00000" => 
                letter_ascii <= x"00"; -- for default/undefined
            when others =>
                letter_ascii <= std_logic_vector(to_unsigned(64 + code_int, 8)); -- ASCII A-Z
        end case;
    end process;

end Behavioral;