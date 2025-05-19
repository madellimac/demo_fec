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
                clk_pulse <= '0';  -- default, unless pulsed below

                -- 1. Immediate send if idle
                if data_valid = '1' then
                    if sending = '0' then
                        current_byte <= data_in;
                        bit_index    <= 0;
                        sending      <= '1';
                        clk_pulse    <= '1';  -- first bit ready
                        byte_counter <= byte_counter + 1;
                    else
                        -- enqueue to RAM if busy
                        ram(write_ptr) <= data_in;
                        write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
                        byte_counter <= byte_counter + 1;
                    end if;
                end if;

                -- 2. Serialization FSM every 2nd clk
                if clk_div = '1' then
                    if sending = '1' then
                        if bit_index < 7 then
                            bit_index <= bit_index + 1;
                            clk_pulse <= '1';
                        else
                            -- last bit done, load next if any
                            sending   <= '0';
                            if read_ptr /= write_ptr then
                                current_byte <= ram(read_ptr);
                                read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
                                bit_index <= 0;
                                sending   <= '1';
                                clk_pulse <= '1';
                            end if;
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
