library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity classifier is
    Port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        enable       : in  std_logic;
        adc_value    : in  std_logic_vector(11 downto 0);
        threshold1   : in  std_logic_vector(11 downto 0);
        threshold2   : in  std_logic_vector(11 downto 0);
        finger_state : out std_logic_vector(2 downto 0));
end classifier;

architecture Behavioral of classifier is

signal state_reg : std_logic_vector(2 downto 0) := "000";

begin
    process(clk) begin if rising_edge(clk) then
            if reset = '1' then
                state_reg <= "000";  -- straight by default
            elsif enable = '1' then
                if adc_value < threshold1 then
                    state_reg <= "001";  -- straight
                elsif adc_value < threshold2 then
                    state_reg <= "010";  -- half bent
                else
                    state_reg <= "100";  -- fully bent
            end if; end if; end if;
    end process;
finger_state <= state_reg;

end Behavioral;