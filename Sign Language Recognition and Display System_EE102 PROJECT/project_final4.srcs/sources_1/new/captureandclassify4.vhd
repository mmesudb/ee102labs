library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity captureandclassify4 is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        thmode      : in  std_logic_vector(1 downto 0);
        enable1     : in  std_logic;
        enable2     : in  std_logic;
        enable3     : in  std_logic;
        enable4     : in  std_logic;
        adc1        : in  std_logic_vector(11 downto 0);
        adc2        : in  std_logic_vector(11 downto 0);
        adc3        : in  std_logic_vector(11 downto 0);
        adc4        : in  std_logic_vector(11 downto 0);
        finger1_state : out std_logic_vector(2 downto 0);
        finger2_state : out std_logic_vector(2 downto 0);
        finger3_state : out std_logic_vector(2 downto 0);
        finger4_state : out std_logic_vector(2 downto 0)
    );
end captureandclassify4;

architecture Behavioral of captureandclassify4 is

    signal t1_f1, t2_f1 : std_logic_vector(11 downto 0);
    signal t1_f2, t2_f2 : std_logic_vector(11 downto 0);
    signal t1_f3, t2_f3 : std_logic_vector(11 downto 0);
    signal t1_f4, t2_f4 : std_logic_vector(11 downto 0);
    
    signal threshold_mode, classify: std_logic;
    signal capture1, capture2, capture3, capture4 : std_logic;

    component threshold_capture
        Port (
            clk            : in  std_logic;
            reset          : in  std_logic;
            enable         : in  std_logic;
            adc_value      : in  std_logic_vector(11 downto 0);
            threshold_mode : in  std_logic;
            threshold1     : out std_logic_vector(11 downto 0);
            threshold2     : out std_logic_vector(11 downto 0)
        );
    end component;

    component classifier
        Port (
            clk          : in  std_logic;
            reset        : in  std_logic;
            enable       : in  std_logic;
            adc_value    : in  std_logic_vector(11 downto 0);
            threshold1   : in  std_logic_vector(11 downto 0);
            threshold2   : in  std_logic_vector(11 downto 0);
            finger_state : out std_logic_vector(2 downto 0)
        );
    end component;

begin

    capture1 <= enable1 and (thmode(1) xor thmode(0));
    capture2 <= enable2 and (thmode(1) xor thmode(0));
    capture3 <= enable3 and (thmode(1) xor thmode(0));
    capture4 <= enable4 and (thmode(1) xor thmode(0));
    threshold_mode <= thmode(1) and not thmode(0);
    classify <= not (enable1 or enable2 or enable3 or enable4);

    TCAP1: threshold_capture
        port map (
            clk => clk, reset => reset, enable => capture1,
            adc_value => adc1, threshold_mode => threshold_mode,
            threshold1 => t1_f1, threshold2 => t2_f1
        );

    TCAP2: threshold_capture
        port map (
            clk => clk, reset => reset, enable => capture2,
            adc_value => adc2, threshold_mode => threshold_mode,
            threshold1 => t1_f2, threshold2 => t2_f2
        );

    TCAP3: threshold_capture
        port map (
            clk => clk, reset => reset, enable => capture3,
            adc_value => adc3, threshold_mode => threshold_mode,
            threshold1 => t1_f3, threshold2 => t2_f3
        );

    TCAP4: threshold_capture
        port map (
            clk => clk, reset => reset, enable => capture4,
            adc_value => adc4, threshold_mode => threshold_mode,
            threshold1 => t1_f4, threshold2 => t2_f4
        );

    -- Classify fingers
    CLASS1: classifier
        port map (
            clk => clk, reset => reset, enable => classify,
            adc_value => adc1, threshold1 => t1_f1, threshold2 => t2_f1,
            finger_state => finger1_state
        );

    CLASS2: classifier
        port map (
            clk => clk, reset => reset, enable => classify,
            adc_value => adc2, threshold1 => t1_f2, threshold2 => t2_f2,
            finger_state => finger2_state
        );

    CLASS3: classifier
        port map (
            clk => clk, reset => reset, enable => classify,
            adc_value => adc3, threshold1 => t1_f3, threshold2 => t2_f3,
            finger_state => finger3_state
        );

    CLASS4: classifier
        port map (
            clk => clk, reset => reset, enable => classify,
            adc_value => adc4, threshold1 => t1_f4, threshold2 => t2_f4,
            finger_state => finger4_state
        );

end Behavioral;