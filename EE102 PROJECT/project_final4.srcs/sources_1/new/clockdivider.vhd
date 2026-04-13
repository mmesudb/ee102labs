library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clockdivider is
    Port ( internalclk : in STD_LOGIC;
           speedselect : in STD_LOGIC_VECTOR (1 downto 0);
           obtainedclk : out STD_LOGIC);
end clockdivider;

architecture Behavioral of clockdivider is

signal count : integer range 0 to 100_000_000 := 0;
signal divisionfactor : integer := 100000000;
signal clockwaveform : std_logic := '0';

begin

process(internalclk) begin
    if rising_edge(internalclk) then
        case speedselect is
            when "00" => divisionfactor <= 100000;  -- 1 kHz
            when "01" => divisionfactor <= 100;  -- 1 MHz
            when "10" => divisionfactor <= 1000000;  -- 100 Hz
            when "11" => divisionfactor <= 100000000; -- 1 Hz
            when others => divisionfactor <= 100000000; -- Default case
end case; end if; end process;

process(internalclk) begin
if rising_edge(internalclk) then
    if count = divisionfactor / 2 then 
    clockwaveform <= not clockwaveform; count <= 0;
    else count <= count + 1 ;
    end if;
end if; end process;

obtainedclk <= clockwaveform;

end Behavioral;