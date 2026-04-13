LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lcd_driver IS
  PORT(
    clk        : IN    STD_LOGIC;
    rst        : IN    STD_LOGIC;
    rw, rs, e  : OUT   STD_LOGIC;
    lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    char       : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    position   : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
    wr_char    : IN    STD_LOGIC
  );
END lcd_driver;

ARCHITECTURE controller OF lcd_driver IS
  TYPE CONTROL IS(power_up, initialize, set_position, write_char, idle);
  SIGNAL state         : CONTROL;
  CONSTANT freq        : INTEGER := 100; --system clock freq in MHz
  SIGNAL pos_addr      : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

--reset <= not rst;

  PROCESS(clk)
    VARIABLE clk_count : INTEGER := 0; --event counter for timing
  BEGIN
    if rising_edge(clk) then
      
      CASE state IS
        
        --wait 50 ms to ensure Vdd has risen and required LCD wait is met
        WHEN power_up =>
          IF(clk_count < (50000 * freq)) THEN    --wait 50 ms
            clk_count := clk_count + 1;
            state <= power_up;
          ELSE                                   
            clk_count := 0;
            rs <= '0';
            rw <= '0';
            lcd_data <= "00110000";
            state <= initialize;
          END IF;
          
        --cycle through initialization sequence  
        WHEN initialize =>
          clk_count := clk_count + 1;
          IF(clk_count < (10 * freq)) THEN       --function set
            lcd_data <= "00111100";      --2-line mode, display on
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (60 * freq)) THEN    --wait 50 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (70 * freq)) THEN    --display on/off control
            lcd_data <= "00001111";      --display on, cursor on, blink on
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (120 * freq)) THEN   --wait 50 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (130 * freq)) THEN   --display clear
            lcd_data <= "00000001";
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2130 * freq)) THEN  --wait 2 ms
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (2140 * freq)) THEN  --entry mode set
            lcd_data <= "00000110";      --increment mode, entire shift off
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2200 * freq)) THEN  --wait 60 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSE                                   --initialization complete
            clk_count := 0;
            state <= idle;
          END IF;
          
        WHEN idle =>
          IF wr_char = '1' THEN
            pos_addr <= "10000000" OR ("0000" & position);
            clk_count := 0;
            state <= set_position;
          ELSE
            state <= idle;
          END IF;

        WHEN set_position =>
          IF(clk_count < (50 * freq)) THEN      --do not exit for 50us
            IF(clk_count < freq) THEN           --negative enable
              lcd_data <= pos_addr;             -- Position command
              rs <= '0';                        -- Command mode
              rw <= '0';                        -- Write mode
              e <= '0';
            ELSIF(clk_count < (14 * freq)) THEN  --positive enable half-cycle
              e <= '1';
            ELSIF(clk_count < (27 * freq)) THEN  --negative enable half-cycle
              e <= '0';
            END IF;
            clk_count := clk_count + 1;
            state <= set_position;
          ELSE
            clk_count := 0;
            state <= write_char;
          END IF;

        WHEN write_char =>
          IF(clk_count < (50 * freq)) THEN      --do not exit for 50us
            IF(clk_count < freq) THEN           --negative enable
              lcd_data <= char;                 -- Character data
              rs <= '1';                        -- Data mode
              rw <= '0';                        -- Write mode
              e <= '0';
            ELSIF(clk_count < (14 * freq)) THEN  --positive enable half-cycle
              e <= '1';
            ELSIF(clk_count < (27 * freq)) THEN  --negative enable half-cycle
              e <= '0';
            END IF;
            clk_count := clk_count + 1;
            state <= write_char;
          ELSE
            clk_count := 0;
            state <= idle;
          END IF;
      END CASE;
      
IF (rst = '1') THEN
    state <= power_up;
    clk_count := 0;
    pos_addr <= (others => '0');
END IF;

    END IF;
  END PROCESS;
END controller;