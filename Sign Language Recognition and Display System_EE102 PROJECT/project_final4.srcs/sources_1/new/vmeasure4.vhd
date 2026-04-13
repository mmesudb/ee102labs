library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vmeasure4 is
    Port (
        clk        : in  std_logic;
        reset       : in STD_LOGIC;
        vauxp6     : in  std_logic;
        vauxn6     : in  std_logic;
        vauxp7     : in  std_logic;
        vauxn7     : in  std_logic;
        vauxp14    : in  std_logic;
        vauxn14    : in  std_logic;
        vauxp15    : in  std_logic;
        vauxn15    : in  std_logic;
        adc1       : out std_logic_vector(11 downto 0);
        adc2       : out std_logic_vector(11 downto 0);
        adc3       : out std_logic_vector(11 downto 0);
        adc4       : out std_logic_vector(11 downto 0)
    );
end vmeasure4;

architecture Behavioral of vmeasure4 is

    -- XADC component declaration
    component xadc_wiz_0 is
        port (
            daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);
            den_in          : in  STD_LOGIC;
            di_in           : in  STD_LOGIC_VECTOR (15 downto 0);
            dwe_in          : in  STD_LOGIC;
            do_out          : out STD_LOGIC_VECTOR (15 downto 0);
            drdy_out        : out STD_LOGIC;
            dclk_in         : in  STD_LOGIC;
            reset_in        : in  STD_LOGIC;
            vauxp6          : in  STD_LOGIC;
            vauxn6          : in  STD_LOGIC;
            vauxp7          : in  STD_LOGIC;
            vauxn7          : in  STD_LOGIC;
            vauxp14         : in  STD_LOGIC;
            vauxn14         : in  STD_LOGIC;
            vauxp15         : in  STD_LOGIC;
            vauxn15         : in  STD_LOGIC;
            busy_out        : out STD_LOGIC;
            channel_out     : out STD_LOGIC_VECTOR (4 downto 0);
            eoc_out         : out STD_LOGIC;
            eos_out         : out STD_LOGIC;
            alarm_out       : out STD_LOGIC;
            vp_in           : in  STD_LOGIC;
            vn_in           : in  STD_LOGIC
        );
    end component;

    -- Constants for XADC channel addresses
    constant ADDR_CHAN0  : std_logic_vector(6 downto 0) := "0010110"; -- Channel 6 (VAUXP/N6)
    constant ADDR_CHAN1  : std_logic_vector(6 downto 0) := "0010111"; -- Channel 7 (VAUXP/N7)
    constant ADDR_CHAN2  : std_logic_vector(6 downto 0) := "0011110"; -- Channel 14 (VAUXP/N14)
    constant ADDR_CHAN3  : std_logic_vector(6 downto 0) := "0011111"; -- Channel 15 (VAUXP/N15)
    
    -- Signals for XADC interface
    signal daddr_in      : STD_LOGIC_VECTOR (6 downto 0);
    signal den_in        : STD_LOGIC := '0';
    signal di_in         : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal dwe_in        : STD_LOGIC := '0';
    signal do_out        : STD_LOGIC_VECTOR (15 downto 0);
    signal drdy_out      : STD_LOGIC;
    signal busy_out      : STD_LOGIC;
    signal channel_out   : STD_LOGIC_VECTOR (4 downto 0);
    signal eoc_out       : STD_LOGIC;
    signal eos_out       : STD_LOGIC;
    
    -- ADC data storage
    signal adc_data_ch0  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal adc_data_ch1  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal adc_data_ch2  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal adc_data_ch3  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    
    -- State machine for reading ADC channels
    type state_type is (IDLE, READ_CH0, READ_CH1, READ_CH2, READ_CH3, WAIT_DRDY);
    signal state : state_type := IDLE;
    
    -- Clock divider to slow down the state machine
    signal clk_div_counter : integer range 0 to 999999 := 0;
    signal clk_div : std_logic := '0';
    
begin
    -- Instantiate the XADC wizard
    XADC_INST : xadc_wiz_0
        port map (
            daddr_in => daddr_in,
            den_in => den_in,
            di_in => di_in,
            dwe_in => dwe_in,
            do_out => do_out,
            drdy_out => drdy_out,
            dclk_in => clk,
            reset_in => reset,
            vauxp6 => vauxp6,
            vauxn6 => vauxn6,
            vauxp7 => vauxp7,
            vauxn7 => vauxn7,
            vauxp14 => vauxp14,
            vauxn14 => vauxn14,
            vauxp15 => vauxp15,
            vauxn15 => vauxn15,
            busy_out => busy_out,
            channel_out => channel_out,
            eoc_out => eoc_out,
            eos_out => eos_out,
            alarm_out => open,
            vp_in => '0',
            vn_in => '0'
        );

    -- Clock divider process to slow down state machine
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_div_counter <= 0;
                clk_div <= '0';
            else
                if clk_div_counter = 999999 then -- Approx 10ms at 100MHz
                    clk_div_counter <= 0;
                    clk_div <= not clk_div;
                else
                    clk_div_counter <= clk_div_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- XADC reading state machine
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                den_in <= '0';
                daddr_in <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if clk_div = '1' then
                            state <= READ_CH0;
                        end if;
                        
                    when READ_CH0 =>
                        daddr_in <= ADDR_CHAN0;
                        den_in <= '1';
                        state <= WAIT_DRDY;
                        
                    when READ_CH1 =>
                        daddr_in <= ADDR_CHAN1;
                        den_in <= '1';
                        state <= WAIT_DRDY;
                        
                    when READ_CH2 =>
                        daddr_in <= ADDR_CHAN2;
                        den_in <= '1';
                        state <= WAIT_DRDY;
                        
                    when READ_CH3 =>
                        daddr_in <= ADDR_CHAN3;
                        den_in <= '1';
                        state <= WAIT_DRDY;
                        
                    when WAIT_DRDY =>
                        den_in <= '0';
                        
                        if drdy_out = '1' then
                            -- Store the data based on current address
                            case daddr_in is
                                when ADDR_CHAN0 =>
                                    adc_data_ch0 <= do_out;
                                    state <= READ_CH1;
                                when ADDR_CHAN1 =>
                                    adc_data_ch1 <= do_out;
                                    state <= READ_CH2;
                                when ADDR_CHAN2 =>
                                    adc_data_ch2 <= do_out;
                                    state <= READ_CH3;
                                when ADDR_CHAN3 =>
                                    adc_data_ch3 <= do_out;
                                    state <= IDLE;
                                when others =>
                                    state <= IDLE;
                            end case;
                        end if;
                end case;
            end if;
        end if;
    end process;
    
adc1 <= adc_data_ch0(15 downto 4);
adc2 <= adc_data_ch1(15 downto 4);
adc3 <= adc_data_ch2(15 downto 4);
adc4 <= adc_data_ch3(15 downto 4);

end Behavioral;