--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity data_serializer is
--    generic (
--        RAM_DEPTH : integer := 12000  -- enough to buffer a 92x64 image with 16-bit pixels
--    );
--    Port (
--        clk         : in  STD_LOGIC;
--        reset       : in  STD_LOGIC;

--        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);  -- byte input
--        data_valid  : in  STD_LOGIC;

--        data_out    : out STD_LOGIC;  -- serial bit output
--        ready       : out STD_LOGIC   -- '1' when bit is valid on data_out
--    );
--end data_serializer;

--architecture Behavioral of data_serializer is
--    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
--    signal ram           : ram_type := (others => (others => '0'));

--    signal write_ptr     : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr      : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt       : integer range 0 to 7 := 0;
--    signal current_byte  : std_logic_vector(7 downto 0) := (others => '0');
--    signal sending       : std_logic := '0';
--    signal byte_available: std_logic := '0';
--    signal bit_out_reg   : std_logic := '0';

--    signal clk_div       : std_logic := '0';  -- divides clock by 2
--    signal ready_reg     : std_logic := '0';
--    signal ready_next    : std_logic := '0';
--begin

--    -- Clock divider: toggles every cycle
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                clk_div <= '0';
--            else
--                clk_div <= not clk_div;
--            end if;
--        end if;
--    end process;

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr      <= 0;
--                read_ptr       <= 0;
--                bit_cnt        <= 0;
--                current_byte   <= (others => '0');
--                sending        <= '0';
--                byte_available <= '0';
--                bit_out_reg    <= '0';
--                ready_next     <= '0';
--            else
--                -- Write new byte to RAM
--                if data_valid = '1' then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                    byte_available <= '1';
--                end if;

--                -- On divided clock only
--                if clk_div = '1' then
--                    if sending = '0' and byte_available = '1' then
--                        current_byte <= ram(read_ptr);
--                        bit_out_reg <= ram(read_ptr)(0);
--                        read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                        bit_cnt <= 0;
--                        sending <= '1';
--                        ready_next <= '1';

--                    elsif sending = '1' then
--                        if bit_cnt < 7 then
--                            bit_cnt <= bit_cnt + 1;
--                            bit_out_reg <= current_byte(bit_cnt + 1);
--                            ready_next <= '1';
--                        else
--                            if write_ptr /= read_ptr then
--                                current_byte <= ram(read_ptr);
--                                bit_out_reg <= ram(read_ptr)(0);
--                                read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                                bit_cnt <= 0;
--                                ready_next <= '1';
--                            else
--                                bit_cnt <= 0;
--                                sending <= '0';
--                                bit_out_reg <= '0';
--                                byte_available <= '0';
--                                ready_next <= '0';
--                            end if;
--                        end if;
--                    else
--                        ready_next <= '0';
--                    end if;
--                else
--                    ready_next <= '0';
--                end if;

--                -- Delay ready by one cycle
--                ready_reg <= ready_next;
--            end if;
--        end if;
--    end process;

--    data_out <= bit_out_reg;
--    ready    <= ready_reg;

--end Behavioral;

-----VERSION 1


--architecture Behavioral of data_serializer is
--    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
--    signal ram : ram_type := (others => (others => '0'));

--    signal write_ptr : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr  : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt   : integer range 0 to 7 := 0;
--    signal current_byte : std_logic_vector(7 downto 0) := (others => '0');
--    signal sending : std_logic := '0';
--    signal byte_available : std_logic := '0';
--begin
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr <= 0;
--                read_ptr  <= 0;
--                bit_cnt <= 0;
--                sending <= '0';
--                byte_available <= '0';
--            else
--                -- write to RAM
--                if data_valid = '1' then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                    byte_available <= '1';
--                end if;

--                -- start sending
--                if sending = '0' and byte_available = '1' then
--                    current_byte <= ram(read_ptr);
--                    read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                    bit_cnt <= 0;
--                    sending <= '1';
--                elsif sending = '1' then
--                    bit_cnt <= bit_cnt + 1;
--                    if bit_cnt = 7 then
--                        sending <= '0';
--                        if write_ptr = read_ptr then
--                            byte_available <= '0';
--                        end if;
--                    end if;
--                end if;
--            end if;
--        end if;
--    end process;

--    data_out <= current_byte(bit_cnt) when sending = '1' else '0';
--    ready    <= sending;

--end Behavioral;

---------------------------------------   VERSION 2

--architecture Behavioral of data_serializer is
--    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
--    signal ram           : ram_type := (others => (others => '0'));

--    signal write_ptr     : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr      : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt       : integer range 0 to 7 := 0;
--    signal current_byte  : std_logic_vector(7 downto 0) := (others => '0');
--    signal sending       : std_logic := '0';
--    signal byte_available: std_logic := '0';
--    signal bit_out_reg   : std_logic := '0';
--begin

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr      <= 0;
--                read_ptr       <= 0;
--                bit_cnt        <= 0;
--                current_byte   <= (others => '0');
--                sending        <= '0';
--                byte_available <= '0';
--                bit_out_reg    <= '0';

--            else
--                -- Write byte to RAM
--                if data_valid = '1' then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                    byte_available <= '1';
--                end if;

--                -- Start new byte if needed
--                if sending = '0' and byte_available = '1' then
--                    current_byte <= ram(read_ptr);
--                    read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                    bit_cnt <= 0;
--                    bit_out_reg <= ram(read_ptr)(0);  -- first bit immediately
--                    sending <= '1';

--                elsif sending = '1' then
--                    -- Output next bit
--                    if bit_cnt < 7 then
--                    bit_cnt <= bit_cnt + 1;
--                    bit_out_reg <= current_byte(bit_cnt + 1);
--                else
--                    -- We just finished sending 8 bits
--                    if write_ptr /= read_ptr then
--                        -- Next byte is already in RAM ? continue without glitch
--                        current_byte <= ram(read_ptr);
--                        read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                        bit_cnt <= 0;
--                        bit_out_reg <= ram(read_ptr)(0);  -- preload new first bit
--                        sending <= '1';
--                    else
--                        -- No more data
--                        bit_cnt <= 0;
--                        sending <= '0';
--                        bit_out_reg <= '0';
--                        byte_available <= '0';
--                    end if;
--                end if;
                
--                end if;
--            end if;
--        end if;
--    end process;

--    data_out <= bit_out_reg;
--    ready    <= sending;

--end Behavioral;

----------------------------------- version 3


--architecture Behavioral of data_serializer is
--    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
--    signal ram           : ram_type := (others => (others => '0'));

--    signal write_ptr     : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr      : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt       : integer range 0 to 7 := 0;
--    signal current_byte  : std_logic_vector(7 downto 0) := (others => '0');
--    signal sending       : std_logic := '0';
--    signal bit_out_reg   : std_logic := '0';

--    signal buffer_count  : integer range 0 to RAM_DEPTH := 0;
--begin

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr     <= 0;
--                read_ptr      <= 0;
--                bit_cnt       <= 0;
--                current_byte  <= (others => '0');
--                sending       <= '0';
--                bit_out_reg   <= '0';
--                buffer_count  <= 0;

--            else
--                -- Write to RAM if data is valid
--                if data_valid = '1' and buffer_count < RAM_DEPTH then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                    buffer_count <= buffer_count + 1;
--                end if;

--                -- Start sending a new byte
--                if sending = '0' and buffer_count > 0 then
--                    current_byte <= ram(read_ptr);
--                    bit_out_reg <= ram(read_ptr)(0);
--                    read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                    buffer_count <= buffer_count - 1;
--                    bit_cnt <= 0;
--                    sending <= '1';

--                elsif sending = '1' then
--                    if bit_cnt < 7 then
--                        bit_cnt <= bit_cnt + 1;
--                        bit_out_reg <= current_byte(bit_cnt + 1);
--                    else
--                        if buffer_count > 0 then
--                            current_byte <= ram(read_ptr);
--                            bit_out_reg <= ram(read_ptr)(0);
--                            read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                            buffer_count <= buffer_count - 1;
--                            bit_cnt <= 0;
--                        else
--                            bit_cnt <= 0;
--                            sending <= '0';
--                            bit_out_reg <= '0';
--                        end if;
--                    end if;
--                end if;
--            end if;
--        end if;
--    end process;

--    data_out <= bit_out_reg;
--    ready    <= sending;

--end Behavioral;


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity data_serializer is
--    generic (
--        RAM_DEPTH : integer := 12000
--    );
--    Port (
--        clk         : in  STD_LOGIC;
--        reset       : in  STD_LOGIC;
--        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
--        data_valid  : in  STD_LOGIC;
--        data_out    : out STD_LOGIC;
--        ready       : out STD_LOGIC
--    );
--end data_serializer;

--architecture Behavioral of data_serializer is
--    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
--    signal ram           : ram_type := (others => (others => '0'));

--    signal write_ptr     : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr      : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt       : integer range 0 to 7 := 0;
--    signal current_byte  : std_logic_vector(7 downto 0) := (others => '0');
--    signal sending       : std_logic := '0';
--    signal byte_available: std_logic := '0';
--    signal bit_out_reg   : std_logic := '0';

--    signal clk_div       : std_logic := '0';  -- divides clock by 2
--begin

--    -- Clock divider: toggles every cycle
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                clk_div <= '0';
--            else
--                clk_div <= not clk_div;
--            end if;
--        end if;
--    end process;

--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr      <= 0;
--                read_ptr       <= 0;
--                bit_cnt        <= 0;
--                current_byte   <= (others => '0');
--                sending        <= '0';
--                byte_available <= '0';
--                bit_out_reg    <= '0';
--            else
--                -- Write new byte to RAM
--                if data_valid = '1' then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                    byte_available <= '1';
--                end if;

--                -- On divided clock only
--                if clk_div = '1' then
--                    if sending = '0' and byte_available = '1' then
--                        current_byte <= ram(read_ptr);
--                        bit_out_reg <= ram(read_ptr)(0);
--                        read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                        bit_cnt <= 0;
--                        sending <= '1';

--                    elsif sending = '1' then
--                        if bit_cnt < 7 then
--                            bit_cnt <= bit_cnt + 1;
--                            bit_out_reg <= current_byte(bit_cnt + 1);
--                        else
--                            if write_ptr /= read_ptr then
--                                current_byte <= ram(read_ptr);
--                                bit_out_reg <= ram(read_ptr)(0);
--                                read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                                bit_cnt <= 0;
--                            else
--                                bit_cnt <= 0;
--                                sending <= '0';
--                                bit_out_reg <= '0';
--                                byte_available <= '0';
--                            end if;
--                        end if;
--                    end if;
--                end if;
--            end if;
--        end if;
--    end process;

--    data_out <= bit_out_reg;
--    ready    <= sending;

--end Behavioral;

------------------------------------ VERSION AVANT FINALE


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity data_serializer is
--    generic (
--        RAM_DEPTH : integer := 256
--    );
--    Port (
--        clk             : in  STD_LOGIC;
--        reset           : in  STD_LOGIC;
--        data_in         : in  STD_LOGIC_VECTOR(7 downto 0);
--        data_valid      : in  STD_LOGIC;
--        data_out        : out STD_LOGIC;
--        ready           : out STD_LOGIC;
--        byte_count_sent : out INTEGER range 0 to RAM_DEPTH
--    );
--end data_serializer;

--architecture Behavioral of data_serializer is

--    type ram_type is array(0 to RAM_DEPTH-1) of STD_LOGIC_VECTOR(7 downto 0);
--    signal ram           : ram_type := (others => (others => '0'));

--    signal write_ptr     : integer range 0 to RAM_DEPTH-1 := 0;
--    signal read_ptr      : integer range 0 to RAM_DEPTH-1 := 0;
--    signal bit_cnt       : integer range 0 to 7 := 0;

--    signal clk_div       : STD_LOGIC := '0'; -- clock divider for 2-cycle serialization
--    signal sending       : STD_LOGIC := '0';
--    signal current_byte  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
--    signal ready_reg     : STD_LOGIC := '0';
--    signal bit_out_reg   : STD_LOGIC := '0';
--    signal sent_counter  : INTEGER range 0 to RAM_DEPTH := 0;

--begin

--    -- Divide clock to act every 2 cycles
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                clk_div <= '0';
--            else
--                clk_div <= not clk_div;
--            end if;
--        end if;
--    end process;

--    -- Main logic
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                write_ptr      <= 0;
--                read_ptr       <= 0;
--                bit_cnt        <= 0;
--                current_byte   <= (others => '0');
--                sending        <= '0';
--                bit_out_reg    <= '0';
--                ready_reg      <= '0';
--                sent_counter   <= 0;
--            else
--                -- Write incoming byte to RAM
--                if data_valid = '1' then
--                    ram(write_ptr) <= data_in;
--                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
--                end if;

--                -- Operate only every second cycle
--                if clk_div = '1' then
--                    if sending = '0' and write_ptr /= read_ptr then
--                        -- Start sending new byte
--                        current_byte <= ram(read_ptr);
--                        read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
--                        bit_cnt <= 0;
--                        sending <= '1';
--                        bit_out_reg <= ram(read_ptr)(0);
--                        ready_reg <= '1';
--                    elsif sending = '1' then
--                        if bit_cnt < 7 then
--                            bit_cnt <= bit_cnt + 1;
--                            bit_out_reg <= current_byte(bit_cnt + 1);
--                            ready_reg <= '1';
--                        else
--                            -- Finished sending 8 bits
--                            sending <= '0';
--                            ready_reg <= '0';
--                            bit_out_reg <= '0';
--                            sent_counter <= sent_counter + 1;
--                        end if;
--                    else
--                        ready_reg <= '0';
--                    end if;
--                else
--                    ready_reg <= '0'; -- avoid double ready
--                end if;
--            end if;
--        end if;
--    end process;

--    data_out        <= bit_out_reg;
--    ready           <= ready_reg;
--    byte_count_sent <= sent_counter;

--end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_serializer is
    generic (
        RAM_DEPTH : integer := 11776
    );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
        data_valid  : in  STD_LOGIC;

        data_out    : out STD_LOGIC;     -- One bit every 2 cycles
        ready       : out STD_LOGIC;     -- 1-cycle pulse per bit

        byte_count_sent : out INTEGER range 0 to RAM_DEPTH
    );
end data_serializer;

architecture Behavioral of data_serializer is

    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal write_ptr : integer range 0 to RAM_DEPTH-1 := 0;
    signal read_ptr  : integer range 0 to RAM_DEPTH-1 := 0;

    signal current_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_index    : integer range 0 to 7 := 0;

    signal sending      : std_logic := '0';
    signal clk_div      : std_logic := '0';  -- Toggles every clk
    signal clk_pulse    : std_logic := '0';  -- One-cycle enable for each bit

    signal byte_counter : integer range 0 to RAM_DEPTH := 0;

begin

    ---------------------------------
    -- Clock divider (÷2)
    ---------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_div <= '0';
            else
                clk_div <= not clk_div;
            end if;
        end if;
    end process;

    ---------------------------------
    -- Main serialization logic
    ---------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                write_ptr     <= 0;
                read_ptr      <= 0;
                sending       <= '0';
                bit_index     <= 0;
                byte_counter  <= 0;
                current_byte  <= (others => '0');
                clk_pulse     <= '0';
            else
                -- 1. Write incoming bytes to RAM
                if data_valid = '1' then
                    ram(write_ptr) <= data_in;
                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
                    byte_counter <= byte_counter + 1;
                end if;

                clk_pulse <= '0';  -- default, unless pulsed below

                -- 2. Serialization state
                if clk_div = '1' then
                    if sending = '0' and read_ptr /= write_ptr then
                        -- Load a new byte for serialization
                        current_byte <= ram(read_ptr);
                        bit_index    <= 0;
                        sending      <= '1';
                        clk_pulse    <= '1';  -- first bit pulse
                    elsif sending = '1' then
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                            clk_pulse <= '1';  -- pulse for each bit
                        else
                            -- All bits sent
                            sending   <= '0';
                            read_ptr  <= (read_ptr + 1) mod RAM_DEPTH;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    ---------------------------------
    -- Outputs
    ---------------------------------
    data_out <= current_byte(bit_index);
    ready    <= clk_pulse;
    byte_count_sent <= byte_counter;

end Behavioral;

