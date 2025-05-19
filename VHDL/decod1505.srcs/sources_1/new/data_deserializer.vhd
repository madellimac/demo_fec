--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity data_deserializer is
--    generic (
--        RAM_DEPTH : integer := 12000
--    );
--    Port (
--        clk           : in  STD_LOGIC;
--        reset         : in  STD_LOGIC;
--        data_in       : in  STD_LOGIC;  -- serial bit input
--        data_valid_in : in  STD_LOGIC;  -- should be high when a new bit is present

--        data_out      : out STD_LOGIC_VECTOR(7 downto 0);  -- full byte output
--        data_valid    : out STD_LOGIC  -- high when full byte is ready
--    );
--end data_deserializer;

--architecture Behavioral of data_deserializer is
--    signal buf              : std_logic_vector(7 downto 0) := (others => '0');
--    signal bit_cnt          : integer range 0 to 7 := 0;
--    signal sample_cycle     : std_logic := '0';
--    signal valid_reg        : std_logic := '0';
--    signal data_out_reg     : std_logic_vector(7 downto 0) := (others => '0');
--    signal hold_cnt         : integer range 0 to 7 := 0;
--    signal holding          : std_logic := '0';
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                bit_cnt      <= 0;
--                sample_cycle <= '0';
--                valid_reg    <= '0';
--                buf          <= (others => '0');
--                data_out_reg <= (others => '0');
--                hold_cnt     <= 0;
--                holding      <= '0';

--            elsif data_valid_in = '1' and holding = '0' then
--                -- Sample only every 2 clock cycles
--                sample_cycle <= not sample_cycle;

--                if sample_cycle = '1' then
--                    -- capture 1 bit every two cycles
--                    if bit_cnt < 7 then
--                        buf(bit_cnt + 1) <= data_in;  -- fix offset
--                        bit_cnt <= bit_cnt + 1;
--                        valid_reg <= '0';
--                    else
--                        buf(0) <= data_in;  -- last bit goes to LSB
--                        data_out_reg <= buf;
--                        valid_reg <= '1';
--                        bit_cnt <= 0;
--                        hold_cnt <= 0;
--                        holding <= '1';
--                    end if;
--                end if;

--            elsif holding = '1' then
--                -- keep output valid for 8 full clock cycles
--                if hold_cnt < 7 then
--                    hold_cnt <= hold_cnt + 1;
--                    valid_reg <= '1';
--                else
--                    holding <= '0';
--                    valid_reg <= '0';
--                end if;

--            else
--                valid_reg <= '0';
--            end if;
--        end if;
--    end process;

--    data_out   <= data_out_reg;
--    data_valid <= valid_reg;

--end Behavioral;

---VERSION 1

--architecture Behavioral of data_deserializer is
--    signal buf : std_logic_vector(7 downto 0) := (others => '0');
--    signal bit_cnt : integer range 0 to 7 := 0;
--    signal valid_reg : std_logic := '0';
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                bit_cnt <= 0;
--                valid_reg <= '0';
--                buf <= (others => '0');
--            elsif data_valid_in = '1' then
--                buf(bit_cnt) <= data_in;
--                if bit_cnt = 7 then
--                    bit_cnt <= 0;
--                    valid_reg <= '1';
--                else
--                    bit_cnt <= bit_cnt + 1;
--                    valid_reg <= '0';
--                end if;
--            else
--                valid_reg <= '0';
--            end if;
--        end if;
--    end process;

--    data_out   <= buf;
--    data_valid <= valid_reg;

--end Behavioral;

---------------------------------------   VERSION 2

--architecture Behavioral of data_deserializer is
--    signal buf         : std_logic_vector(7 downto 0) := (others => '0');
--    signal bit_cnt     : integer range 0 to 7 := 0;
--    signal valid_reg   : std_logic := '0';
--    signal data_out_reg: std_logic_vector(7 downto 0) := (others => '0');
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                bit_cnt      <= 0;
--                valid_reg    <= '0';
--                buf          <= (others => '0');
--                data_out_reg <= (others => '0');
--            elsif data_valid_in = '1' then
--                buf(bit_cnt) <= data_in;
--                if bit_cnt = 7 then
--                    bit_cnt      <= 0;
--                    valid_reg    <= '1';
--                    data_out_reg <= buf;
--                    data_out_reg(7) <= data_in;  -- make sure MSB gets last bit
--                else
--                    bit_cnt   <= bit_cnt + 1;
--                    valid_reg <= '0';
--                end if;
--            else
--                valid_reg <= '0';
--            end if;
--        end if;
--    end process;

--    data_out   <= data_out_reg;
--    data_valid <= valid_reg;
--end Behavioral;

--architecture Behavioral of data_deserializer is
--    signal buf              : std_logic_vector(7 downto 0) := (others => '0');
--    signal bit_cnt          : integer range 0 to 7 := 0;
--    signal valid_reg        : std_logic := '0';
--    signal data_out_reg     : std_logic_vector(7 downto 0) := (others => '0');
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                bit_cnt      <= 0;
--                valid_reg    <= '0';
--                buf          <= (others => '0');
--                data_out_reg <= (others => '0');

--            elsif data_valid_in = '1' then
--                if bit_cnt < 7 then
--                    buf(bit_cnt + 1) <= data_in;  -- <-- shift offset applied here
--                    bit_cnt <= bit_cnt + 1;
--                    valid_reg <= '0';
--                else
--                    buf(0) <= data_in;  -- last bit goes to LSB
--                    data_out_reg <= buf;
--                    valid_reg <= '1';
--                    bit_cnt <= 0;
--                end if;

--            else
--                valid_reg <= '0';
--            end if;
--        end if;
--    end process;

--    data_out   <= data_out_reg;
--    data_valid <= valid_reg;
--end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_deserializer is
    generic (
        RAM_DEPTH : integer := 12000
    );
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        data_in         : in  STD_LOGIC;  -- serial bit input
        data_valid_in   : in  STD_LOGIC;  -- high when a new bit is present (every 2 clk cycles)
        expected_bytes  : in  INTEGER range 0 to RAM_DEPTH;

        data_out        : out STD_LOGIC_VECTOR(7 downto 0);  -- full byte output
        data_valid      : out STD_LOGIC                      -- high when full byte is ready
    );
end data_deserializer;

architecture Behavioral of data_deserializer is
    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
    signal ram             : ram_type := (others => (others => '0'));

    signal byte_index      : integer range 0 to RAM_DEPTH-1 := 0;
    signal bit_cnt         : integer range 0 to 7 := 0;
    signal sample_cycle    : std_logic := '0';
    signal capture_done    : std_logic := '0';

    signal output_index    : integer range 0 to RAM_DEPTH-1 := 0;
    signal data_out_reg    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid_reg  : std_logic := '0';

    signal buf             : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                byte_index      <= 0;
                bit_cnt         <= 0;
                sample_cycle    <= '0';
                capture_done    <= '0';
                ram             <= (others => (others => '0'));
                output_index    <= 0;
                data_out_reg    <= (others => '0');
                data_valid_reg  <= '0';
                buf             <= (others => '0');

            elsif capture_done = '0' then
                -- Phase 1: Collect bits and store as bytes
                if data_valid_in = '1' then
                    sample_cycle <= not sample_cycle;

                    if sample_cycle = '1' then
                        if bit_cnt < 7 then
                            buf(bit_cnt + 1) <= data_in;  -- bit shifted (LSB first)
                            bit_cnt <= bit_cnt + 1;
                        else
                            buf(0) <= data_in;  -- LSB at end
                            ram(byte_index) <= buf;
                            byte_index <= byte_index + 1;
                            bit_cnt <= 0;
                        end if;
                    end if;
                end if;

                if byte_index = expected_bytes then
                    capture_done <= '1';
                    output_index <= 0;
                end if;

            else
                -- Phase 2: Output all stored bytes one per clock
                if output_index < expected_bytes then
                    data_out_reg   <= ram(output_index);
                    data_valid_reg <= '1';
                    output_index   <= output_index + 1;
                else
                    data_valid_reg <= '0';
                end if;
            end if;
        end if;
    end process;

    data_out   <= data_out_reg;
    data_valid <= data_valid_reg;
end Behavioral;
