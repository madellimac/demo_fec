----library IEEE;
----use IEEE.STD_LOGIC_1164.ALL;
----use IEEE.NUMERIC_STD.ALL;

----entity encode8 is
----    generic (
----        RAM_DEPTH : integer := 16
----    );
----    Port (
----        clk         : in  STD_LOGIC;
----        reset       : in  STD_LOGIC;

----        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);  -- From UART
----        data_valid  : in  STD_LOGIC;

----        done        : out STD_LOGIC;
----        x1_byte     : out STD_LOGIC_VECTOR(7 downto 0);
----        x2_byte     : out STD_LOGIC_VECTOR(7 downto 0)
----    );
----end encode8;

----architecture Behavioral of encode8 is

----    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
----    signal ram        : ram_type := (others => (others => '0'));
----    signal write_ptr  : integer range 0 to RAM_DEPTH-1 := 0;
----    signal read_ptr   : integer range 0 to RAM_DEPTH-1 := 0;
----    signal count      : integer range 0 to RAM_DEPTH := 0;

----    signal shift_byte   : std_logic_vector(7 downto 0) := (others => '0');
----    signal bit_counter  : integer range 0 to 7 := 0;
----    signal busy         : std_logic := '0';

----    signal encoder_enable : std_logic := '0';
----    signal encoder_data   : std_logic;
----    signal x1, x2         : std_logic;
----    signal x1_result, x2_result : std_logic_vector(7 downto 0) := (others => '0');

----    component viterbi_encoder
----        Port (
----            rst    : in  STD_LOGIC;
----            clk    : in  STD_LOGIC;
----            enable : in  STD_LOGIC;
----            data   : in  STD_LOGIC;
----            x1     : out STD_LOGIC;
----            x2     : out STD_LOGIC
----        );
----    end component;

----begin

----    encoder_data <= shift_byte(bit_counter);
----    encoder_enable <= busy;

----    viterbi_inst : viterbi_encoder
----        port map (
----            rst    => reset,
----            clk    => clk,
----            enable => encoder_enable,
----            data   => encoder_data,
----            x1     => x1,
----            x2     => x2
----        );

----    -- Unified RAM control process
----    process(clk)
----    begin
----        if rising_edge(clk) then
----            if reset = '1' then
----                write_ptr   <= 0;
----                read_ptr    <= 0;
----                count       <= 0;
----                shift_byte  <= (others => '0');
----                bit_counter <= 0;
----                busy        <= '0';
----                x1_result   <= (others => '0');
----                x2_result   <= (others => '0');
----            else
----                -- Write to RAM from UART
----                if data_valid = '1' and count < RAM_DEPTH then
----                    ram(write_ptr) <= data_in;
----                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
----                    count <= count + 1;
----                end if;

----                -- Start encoding if ready
----                if busy = '0' and count > 0 then
----                    shift_byte <= ram(read_ptr);
----                    read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
----                    count <= count - 1;
----                    bit_counter <= 0;
----                    busy <= '1';
----                elsif busy = '1' then
----                    -- Store encoder result
----                    x1_result(bit_counter) <= x1;
----                    x2_result(bit_counter) <= x2;

----                    if bit_counter = 7 then
----                        busy <= '0';
----                    else
----                        bit_counter <= bit_counter + 1;
----                    end if;
----                end if;
----            end if;
----        end if;
----    end process;

----    x1_byte <= x1_result;
----    x2_byte <= x2_result;
----    done    <= '1' when (busy = '0' and bit_counter = 7) else '0';

----end Behavioral;

-------------------- VERSION 2

----architecture Behavioral of encode8 is

----    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
----    signal ram        : ram_type := (others => (others => '0'));
----    signal write_ptr  : integer range 0 to RAM_DEPTH-1 := 0;
----    signal read_ptr   : integer range 0 to RAM_DEPTH-1 := 0;
----    signal count      : integer range 0 to RAM_DEPTH := 0;

----    signal shift_byte   : std_logic_vector(7 downto 0) := (others => '0');
----    signal bit_counter  : integer range 0 to 8 := 0;  -- Now goes to 8
----    signal busy         : std_logic := '0';

----    signal encoder_enable : std_logic := '0';
----    signal encoder_data   : std_logic;
----    signal x1, x2         : std_logic;
----    signal x1_result, x2_result : std_logic_vector(7 downto 0) := (others => '0');
----    signal done_reg       : std_logic := '0';

----    component viterbi_encoder
----        Port (
----            rst    : in  STD_LOGIC;
----            clk    : in  STD_LOGIC;
----            enable : in  STD_LOGIC;
----            data   : in  STD_LOGIC;
----            x1     : out STD_LOGIC;
----            x2     : out STD_LOGIC
----        );
----    end component;

----begin

----    encoder_data   <= shift_byte(bit_counter) when bit_counter < 8 else '0';
----    encoder_enable <= busy;

----    viterbi_inst : viterbi_encoder
----        port map (
----            rst    => reset,
----            clk    => clk,
----            enable => encoder_enable,
----            data   => encoder_data,
----            x1     => x1,
----            x2     => x2
----        );

----    process(clk)
----    begin
----        if rising_edge(clk) then
----            if reset = '1' then
----                write_ptr   <= 0;
----                read_ptr    <= 0;
----                count       <= 0;
----                shift_byte  <= (others => '0');
----                bit_counter <= 0;
----                busy        <= '0';
----                x1_result   <= (others => '0');
----                x2_result   <= (others => '0');
----                done_reg    <= '0';

----            else
----                -- Write to RAM from UART
----                if data_valid = '1' and count < RAM_DEPTH then
----                    ram(write_ptr) <= data_in;
----                    write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
----                    count <= count + 1;
----                end if;

----                -- Start encoding if idle and data available
----                if busy = '0' and count > 0 then
----                    shift_byte <= ram(read_ptr);
----                    read_ptr <= (read_ptr + 1) mod RAM_DEPTH;
----                    count <= count - 1;
----                    bit_counter <= 0;
----                    busy <= '1';
----                    done_reg <= '0';

----                elsif busy = '1' then
----                    -- Capture encoder outputs during bits 0..7
----                    if bit_counter < 8 then
----                        x1_result(bit_counter) <= x1;
----                        x2_result(bit_counter) <= x2;
----                        bit_counter <= bit_counter + 1;
----                        done_reg <= '0';

----                    else  -- bit_counter = 8 ? all bits processed
----                        busy <= '0';
----                        done_reg <= '1';
----                    end if;
----                else
----                    done_reg <= '0';
----                end if;
----            end if;
----        end if;
----    end process;

----    x1_byte <= x1_result;
----    x2_byte <= x2_result;
----    done    <= done_reg;

----end Behavioral;

--------- version 3

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity encode8 is
--    generic ( RAM_DEPTH : integer := 256 );
--    Port (
--        clk         : in  STD_LOGIC;
--        reset       : in  STD_LOGIC;
--        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);  -- Byte from UART
--        data_valid  : in  STD_LOGIC;                     -- '1' when data_in is valid
--        x1_byte     : out STD_LOGIC_VECTOR(7 downto 0);  -- Encoded x1 byte
--        x2_byte     : out STD_LOGIC_VECTOR(7 downto 0);  -- Encoded x2 byte
--        done        : out STD_LOGIC                      -- '1' when both x1 and x2 are valid
--    );
--end encode8;

--architecture Behavioral of encode8 is

--    component data_serializer is
--        generic ( RAM_DEPTH : integer := 256 );
--        Port (
--            clk               : in  STD_LOGIC;
--            reset             : in  STD_LOGIC;
--            data_in           : in  STD_LOGIC_VECTOR(7 downto 0);
--            data_valid        : in  STD_LOGIC;
--            data_out          : out STD_LOGIC;           -- Bit output
--            ready             : out STD_LOGIC;           -- High when data_out is valid
--            byte_count_sent   : out INTEGER range 0 to RAM_DEPTH
--        );
--    end component;

----    component viterbi_encoder is
----        Port (
----            rst    : in  STD_LOGIC;
----            clk    : in  STD_LOGIC;
----            enable : in  STD_LOGIC;
----            data   : in  STD_LOGIC;
----            x1     : out STD_LOGIC;
----            x2     : out STD_LOGIC;
----            encoder_ready  : out STD_LOGIC  -- NEW: high when output is valid
----        );
----    end component;

----    component data_deserializer is
------        generic ( RAM_DEPTH : integer := 256 );
----        Port (
----            clk             : in  STD_LOGIC;
----            reset           : in  STD_LOGIC;
----            data_in         : in  STD_LOGIC;
----            data_valid_in   : in  STD_LOGIC;
------            expected_bytes  : in  INTEGER range 0 to RAM_DEPTH;
----            data_out        : out STD_LOGIC_VECTOR(7 downto 0);
----            data_valid      : out STD_LOGIC
----        );
----    end component;

--component viterbi_encoder is
--    generic (
--        RAM_DEPTH : integer := 92 * 64 * 2
--    );
--    Port (
--        rst              : in  STD_LOGIC;
--        clk              : in  STD_LOGIC;
--        enable           : in  STD_LOGIC;
--        data             : in  STD_LOGIC;

--        -- outputs per bit
--        x1               : out STD_LOGIC;
--        x2               : out STD_LOGIC;

--        -- access to RAM outputs
--        x1_ram_out       : out STD_LOGIC_VECTOR(7 downto 0);
--        x2_ram_out       : out STD_LOGIC_VECTOR(7 downto 0);
--        data_valid_out   : out STD_LOGIC  -- high for 1 cycle when a new byte is ready
--    );
--end component;

--    -- Internal signals
--    signal serialized_bit : STD_LOGIC;
--    signal ready_bit,encoder_done, s_done      : STD_LOGIC;
--    signal byte_count     : INTEGER range 0 to RAM_DEPTH;

--    signal x1_bit, x2_bit : STD_LOGIC;
--    signal x1_valid, x2_valid : STD_LOGIC;
--    signal x1_byte_int, x2_byte_int : STD_LOGIC_VECTOR(7 downto 0);

--begin

--    -- SERIALIZER: input byte -> bit stream
--    serializer_inst : data_serializer
--        port map (
--            clk              => clk,
--            reset            => reset,
--            data_in          => data_in,
--            data_valid       => data_valid,
--            data_out         => serialized_bit,
--            ready            => ready_bit,
--            byte_count_sent  => byte_count
            
--        );

--    -- ENCODER: bit stream -> (x1,x2) bits
----    encoder_inst : viterbi_encoder
----        port map (
----            rst     => reset,
----            clk     => clk,
----            enable  => ready_bit,
----            data    => serialized_bit,
----            x1      => x1_bit,
----            x2      => x2_bit,
----            encoder_ready => encoder_done
----        );

--    encoder_inst : viterbi_encoder
--        port map (
--            rst     => reset,
--            clk     => clk,
--            enable  => ready_bit,
--            data    => serialized_bit,
--            x1      => x1_bit,
--            x2      => x2_bit,
--            x1_ram_out => x1_byte_int,
--            x2_ram_out => x2_byte_int,
--            data_valid_out   => s_done
--            );
            
----    -- DESERIALIZER for x1 stream
----    x1_deserializer : data_deserializer
----        port map (
----            clk             => clk,
----            reset           => reset,
----            data_in         => x1_bit,
----            data_valid_in   => encoder_done,
------            expected_bytes  => byte_count,
----            data_out        => x1_byte_int,
----            data_valid      => x1_valid
----        );

----    -- DESERIALIZER for x2 stream
----    x2_deserializer : data_deserializer
----        port map (
----            clk             => clk,
----            reset           => reset,
----            data_in         => x2_bit,
----            data_valid_in   => encoder_done,
------            expected_bytes  => byte_count,
----            data_out        => x2_byte_int,
----            data_valid      => x2_valid
----        );

--    -- Final output
--    x1_byte <= x1_byte_int;
--    x2_byte <= x2_byte_int;
--    done    <= x1_valid or x2_valid;

--end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity encode8 is
    generic (
        RAM_DEPTH : integer := 11776
    );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
        data_valid  : in  STD_LOGIC;

        x1_byte     : out STD_LOGIC_VECTOR(7 downto 0);
        x2_byte     : out STD_LOGIC_VECTOR(7 downto 0);
        done        : out STD_LOGIC
    );
end encode8;

architecture Behavioral of encode8 is

    component data_serializer is
        generic (
            RAM_DEPTH : integer := 11776
        );
        Port (
            clk              : in  STD_LOGIC;
            reset            : in  STD_LOGIC;
            data_in          : in  STD_LOGIC_VECTOR(7 downto 0);
            data_valid       : in  STD_LOGIC;
            data_out         : out STD_LOGIC;
            ready            : out STD_LOGIC;
            byte_count_sent  : out INTEGER range 0 to RAM_DEPTH
        );
    end component;

    component viterbi_encoder is
        generic (
            RAM_DEPTH : integer := 11776
        );
        Port (
            rst              : in  STD_LOGIC;
            clk              : in  STD_LOGIC;
            enable           : in  STD_LOGIC;
            data             : in  STD_LOGIC;
            x1               : out STD_LOGIC;
            x2               : out STD_LOGIC;
            x1_ram_out       : out STD_LOGIC_VECTOR(7 downto 0);
            x2_ram_out       : out STD_LOGIC_VECTOR(7 downto 0);
            data_valid_out   : out STD_LOGIC
        );
    end component;

    -- Internal signals
    signal serialized_bit     : STD_LOGIC;
    signal serializer_ready   : STD_LOGIC;
    signal encoder_valid      : STD_LOGIC;
    signal x1_ram_data        : STD_LOGIC_VECTOR(7 downto 0);
    signal x2_ram_data        : STD_LOGIC_VECTOR(7 downto 0);
    signal dummy_x1, dummy_x2 : STD_LOGIC;
    signal byte_counter       : INTEGER range 0 to RAM_DEPTH;

begin

    serializer_inst : data_serializer
        port map (
            clk              => clk,
            reset            => reset,
            data_in          => data_in,
            data_valid       => data_valid,
            data_out         => serialized_bit,
            ready            => serializer_ready,
            byte_count_sent  => byte_counter
        );

    encoder_inst : viterbi_encoder
        port map (
            rst              => reset,
            clk              => clk,
            enable           => serializer_ready,
            data             => serialized_bit,
            x1               => dummy_x1,
            x2               => dummy_x2,
            x1_ram_out       => x1_ram_data,
            x2_ram_out       => x2_ram_data,
            data_valid_out   => encoder_valid
        );

    x1_byte <= x1_ram_data;
    x2_byte <= x2_ram_data;
    done    <= encoder_valid;

end Behavioral;
