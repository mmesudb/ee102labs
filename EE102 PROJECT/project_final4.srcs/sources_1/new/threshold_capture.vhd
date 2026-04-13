library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity threshold_capture is
    Port (
        clk            : in  std_logic;
        reset          : in  std_logic;
        enable         : in  std_logic;
        adc_value      : in  std_logic_vector(11 downto 0);
        threshold_mode : in  std_logic;           -- '0' to write T1, '1' to write T2
        threshold1     : out std_logic_vector(11 downto 0);
        threshold2     : out std_logic_vector(11 downto 0));
end threshold_capture;


architecture Behavioral of threshold_capture is

signal t1_def : std_logic_vector(11 downto 0) := "110110100001"; -- 3489
signal t2_def : std_logic_vector(11 downto 0) := "110111100000"; -- 3560

    signal t1_reg : std_logic_vector(11 downto 0) := t1_def;
    signal t2_reg : std_logic_vector(11 downto 0) := t2_def;

begin

    process(clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                t1_reg <= t1_def;
                t2_reg <= t2_def;
            elsif enable = '1' then
                if threshold_mode = '0' then
                    t1_reg <= adc_value;
                else
                    t2_reg <= adc_value;
        end if; end if; end if;
    end process;

    threshold1 <= t1_reg;
    threshold2 <= t2_reg;

end Behavioral;