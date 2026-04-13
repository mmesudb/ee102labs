library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gesture_LCDletter is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        reset_LCD   : in  std_logic;
        
        cursor_left_btn  : in std_logic;
        cursor_right_btn : in std_logic;

        -- gesturetoletter inputs
        upper_btn   : in  std_logic;
        lower_btn   : in  std_logic;
        thumb_btn   : in  std_logic;
        sw_in       : in  std_logic_vector(3 downto 0);
        vauxp6, vauxn6, vauxp7, vauxn7 : in std_logic;
        vauxp14, vauxn14, vauxp15, vauxn15 : in std_logic;

        -- Outputs
        leds        : out std_logic_vector(12 downto 0);
        anodes      : out std_logic_vector(3 downto 0);
        cathodes    : out std_logic_vector(6 downto 0);

        -- LCD
        LCD_RS      : out STD_LOGIC;
        LCD_RW      : out STD_LOGIC;
        LCD_EN      : out STD_LOGIC;
        LCD_DATA    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end gesture_LCDletter;

architecture Structural of gesture_LCDletter is

    signal letter_code  : std_logic_vector(4 downto 0);
    signal input_letter : std_logic_vector(7 downto 0);

    signal letter_ascii : std_logic_vector(7 downto 0) := x"41";
    signal previous_letter : std_logic_vector(7 downto 0) := x"00";
    signal pos : std_logic_vector(3 downto 0) := "0000";
    signal clock_1khz   : std_logic ;
    signal counter : integer := 0;
    signal thumb: std_logic := not thumb_btn ;
    signal wr_char        : std_logic := '0';
    
    signal wr_pending     : std_logic := '0';
    signal latched_char   : std_logic_vector(7 downto 0) := (others => '0');
    signal latched_pos    : std_logic_vector(3 downto 0) := (others => '0');
    
    signal last_left       : std_logic := '0';
    signal last_right      : std_logic := '0';

component clockdivider is Port ( 
        internalclk : in STD_LOGIC;
        speedselect : in STD_LOGIC_VECTOR (1 downto 0);
        obtainedclk : out STD_LOGIC); end component;

component LCD_Driver
    Port (
        clk        : IN    STD_LOGIC;
        rst        : IN    STD_LOGIC;
        rw, rs, e  : OUT   STD_LOGIC;
        lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        char       : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        position   : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
        wr_char    : IN    STD_LOGIC  
    );
end component;

    component gesturetoletter4
        Port (
            clk, reset       : in  std_logic;
            upper_btn, lower_btn : in  std_logic;
            vauxp6, vauxn6, vauxp7, vauxn7 : in std_logic;
            vauxp14, vauxn14, vauxp15, vauxn15 : in std_logic;
            thumb_btn         : in std_logic;
            sw_in             : in std_logic_vector(3 downto 0);
            leds              : out std_logic_vector(12 downto 0);
            letter_code       : out std_logic_vector(4 downto 0);
            anodes            : out std_logic_vector(3 downto 0);
            cathodes          : out std_logic_vector(6 downto 0)
        );
    end component;

    component lettercode_to_ascii
        Port (
            letter_code  : in  std_logic_vector(4 downto 0);
            letter_ascii : out std_logic_vector(7 downto 0));
    end component;

begin

    myCore: gesturetoletter4
        port map (
            clk => clk, reset => reset,
            upper_btn => upper_btn,
            lower_btn => lower_btn,
            thumb_btn => thumb,
            sw_in => sw_in,
            vauxp6 => vauxp6, vauxn6 => vauxn6,
            vauxp7 => vauxp7, vauxn7 => vauxn7,
            vauxp14 => vauxp14, vauxn14 => vauxn14,
            vauxp15 => vauxp15, vauxn15 => vauxn15,
            leds => leds,
            letter_code => letter_code,
            anodes => anodes,
            cathodes => cathodes);

    myConverter: lettercode_to_ascii
        port map (
            letter_code => letter_code,
            letter_ascii => input_letter);
        
    process(clock_1kHz, reset_LCD)
begin
    if reset_LCD = '1' then
        last_left  <= '0';
        last_right <= '0';
    
        counter <= 0;
        previous_letter <= (others => '0');
        pos <= "0000";
        letter_ascii <= (others => '0');
        wr_char <= '0';
        wr_pending <= '0';
    elsif rising_edge(clock_1kHz) then
        wr_char <= '0';

        if input_letter = previous_letter and input_letter /= x"00" then
            if counter < 2000 then
                counter <= counter + 1;
            else
                latched_char <= input_letter;
                latched_pos <= pos;
                pos <= std_logic_vector(unsigned(pos) + 1);
                wr_pending <= '1';
                counter <= 0;
            end if;
        else
            counter <= 0;
            previous_letter <= input_letter;
        end if;
 
        -- Pulse wr_char for one cycle
        if wr_pending = '1' then
            wr_char <= '1';
            wr_pending <= '0';
        else
            if cursor_right_btn = '1' and last_right = '0' then
                if unsigned(pos) < 15 then
                    pos <= std_logic_vector(unsigned(pos) + 1);
                end if;
            end if;
            if cursor_left_btn = '1' and last_left = '0' then
                if unsigned(pos) > 0 then
                    pos <= std_logic_vector(unsigned(pos) - 1);
                end if;
            end if;
        end if;
        
        last_left  <= cursor_left_btn;
        last_right <= cursor_right_btn;
        
    end if;
end process;

    myClockdivider: clockdivider port map( 
        internalclk => clk, 
        speedselect => "00", 
        obtainedclk => clock_1khz);
    
    myLCD: LCD_Driver port map (
            CLK      => clk,
            RST      => reset_LCD,
            CHAR     => latched_char,
            position => latched_pos,
            wr_char  => wr_char,
            RS       => LCD_RS,
            RW       => LCD_RW,
            E        => LCD_EN,
            LCD_DATA => LCD_DATA);
   
end Structural;