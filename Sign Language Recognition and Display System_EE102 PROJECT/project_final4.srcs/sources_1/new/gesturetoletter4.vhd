library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gesturetoletter4 is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        upper_btn   : in  std_logic;
        lower_btn   : in  std_logic;
        
        vauxp6      : in  std_logic;
        vauxn6      : in  std_logic;
        vauxp7      : in  std_logic;
        vauxn7      : in  std_logic;
        vauxp14     : in  std_logic;
        vauxn14     : in  std_logic;
        vauxp15     : in  std_logic;
        vauxn15     : in  std_logic;
        
        thumb_btn   : in  std_logic;
        sw_in       : in  std_logic_vector(3 downto 0);     
        
        leds        : out std_logic_vector(12 downto 0);
        letter_code : out std_logic_vector(4 downto 0);
        anodes      : out std_logic_vector(3 downto 0);
        cathodes    : out std_logic_vector(6 downto 0) );
end gesturetoletter4;

architecture Structural of gesturetoletter4 is

    signal adc1, adc2, adc3, adc4 : std_logic_vector(11 downto 0);
    signal f1, f2, f3, f4         : std_logic_vector(2 downto 0);
    signal thmode                : std_logic_vector(1 downto 0);
    signal gesture_code          : std_logic_vector(12 downto 0);
    signal letter_internal          : std_logic_vector(4 downto 0);

    component vmeasure4
        Port (
            clk, reset     : in std_logic;
            vauxp6, vauxn6, vauxp7, vauxn7, vauxp14, vauxn14, vauxp15, vauxn15 : in std_logic;
            adc1, adc2, adc3, adc4 : out std_logic_vector(11 downto 0)
        );
    end component;

    component captureandclassify4
        Port (
            clk, reset : in std_logic;
            thmode     : in std_logic_vector(1 downto 0);
            enable1    : in std_logic;
            enable2    : in std_logic;
            enable3    : in std_logic;
            enable4    : in std_logic;
            adc1, adc2, adc3, adc4 : in std_logic_vector(11 downto 0);
            finger1_state, finger2_state, finger3_state, finger4_state : out std_logic_vector(2 downto 0)
        );
    end component;

    component gesture_decoder
        Port (
            gesture_code : in std_logic_vector(12 downto 0);
            letter_code  : out std_logic_vector(4 downto 0)
        );
    end component;

    component sevensegdisplayer
        Port (
        clk      : in  STD_LOGIC;
        value_in : in  STD_LOGIC_VECTOR (4 downto 0);
        an       : out STD_LOGIC_VECTOR (3 downto 0);
        seg_out  : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

begin

    thmode(1) <= upper_btn;
    thmode(0) <= lower_btn;
    
process(sw_in, adc1, adc2, adc3, adc4, gesture_code) begin
    if sw_in = "0001" then
        leds <= '0' & adc1;
    elsif sw_in = "0010" then
        leds <= '0' & adc2 ;
    elsif sw_in = "0100" then
        leds <= '0' & adc3;
    elsif sw_in = "1000" then
        leds <= '0' & adc4;
    else
        leds <= gesture_code;
    end if;
end process;
        
    myXADC: vmeasure4
        port map (
            clk => clk, reset => reset,
            vauxp6 => vauxp6, vauxn6 => vauxn6,
            vauxp7 => vauxp7, vauxn7 => vauxn7,
            vauxp14 => vauxp14, vauxn14 => vauxn14,
            vauxp15 => vauxp15, vauxn15 => vauxn15,
            adc1 => adc1, adc2 => adc2, adc3 => adc3, adc4 => adc4  );

    mySystem: captureandclassify4
        port map (
            clk => clk,
            reset => reset,
            thmode => thmode,
            enable1 => sw_in(0), enable2 => sw_in(1), enable3 => sw_in(2), enable4 => sw_in(3),
            adc1 => adc1, adc2 => adc2, adc3 => adc3, adc4 => adc4,
            finger1_state => f1, finger2_state => f2, finger3_state => f3, finger4_state => f4 );

    gesture_code <= thumb_btn & f1 & f2 & f3 & f4;
    letter_code <= letter_internal;

    myAlphabet: gesture_decoder
        port map (
            gesture_code => gesture_code,
            letter_code  => letter_internal);
            
     myDisplay: sevensegdisplayer
        port map (
            clk      => clk,
            value_in => letter_internal,
            an       => anodes,
            seg_out  => cathodes);

end Structural;