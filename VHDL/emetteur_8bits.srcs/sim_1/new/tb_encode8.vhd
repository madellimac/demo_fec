--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity tb_encode8 is
--end tb_encode8;

--architecture Behavioral of tb_encode8 is

--    -- Component under test
--    component encode8 is
--        generic (
--            RAM_DEPTH : integer := 92 * 64 * 2
--        );
--        Port (
--            clk         : in  STD_LOGIC;
--            reset       : in  STD_LOGIC;
--            data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
--            data_valid  : in  STD_LOGIC;
--            done ,x1,x2        : out STD_LOGIC;
--            x1_byte     : out STD_LOGIC_VECTOR(7 downto 0);
--            x2_byte     : out STD_LOGIC_VECTOR(7 downto 0)
--        );
--    end component;

--    -- Signals
--    signal clk        : std_logic := '0';
--    signal reset      : std_logic := '1';
--    signal data_in    : std_logic_vector(7 downto 0) := (others => '0');
--    signal data_valid : std_logic := '0';
--    signal done, x1,x2       : std_logic;
--    signal x1_byte    : std_logic_vector(7 downto 0);
--    signal x2_byte    : std_logic_vector(7 downto 0);

--    constant CLK_PERIOD : time := 10 ns;

--begin

--    -- Instantiate encode8
--    uut: encode8
--        port map (
--            clk        => clk,
--            reset      => reset,
--            data_in    => data_in,
--            data_valid => data_valid,
--            done       => done,
--            x1         => x1,
--            x2         => x2,
--            x1_byte    => x1_byte,
--            x2_byte    => x2_byte
--        );

--    -- Clock process
--    clk_process : process
--    begin
--        while true loop
--            clk <= '0';
--            wait for CLK_PERIOD / 2;
--            clk <= '1';
--            wait for CLK_PERIOD / 2;
--        end loop;
--    end process;

--    -- Stimulus process
--    stim_proc : process
--    begin
--        -- Hold reset for some time
--        wait for 100 ns;
--        reset <= '0';

--        -- Send 1st byte
--        wait for CLK_PERIOD;
--        data_in <= "10101010";
--        data_valid <= '1';
--        wait for CLK_PERIOD;
--        data_valid <= '0';

--        -- Wait until encoding is done
--        wait until done = '1';
--        wait for 8 * CLK_PERIOD;

--        -- Send 2nd byte
--        data_in <= "11110000";
--        data_valid <= '1';
--        wait for CLK_PERIOD;
--        data_valid <= '0';

--        -- Wait again for encoding to complete
--        wait until done = '1';
--        wait for 20 * CLK_PERIOD;

--        -- End simulation
--        wait;
--    end process;

--end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_encode8 is
end tb_encode8;

architecture sim of tb_encode8 is

    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';

    signal data_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid : std_logic := '0';

    signal x1_byte    : std_logic_vector(7 downto 0);
    signal x2_byte    : std_logic_vector(7 downto 0);
    signal done       : std_logic;

    component encode8 is
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
    end component;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- DUT instance
    uut: encode8
        port map (
            clk        => clk,
            reset      => reset,
            data_in    => data_in,
            data_valid => data_valid,
            x1_byte    => x1_byte,
            x2_byte    => x2_byte,
            done       => done
        );

    -- Stimulus process
    stim_proc: process
    begin
        wait for 40 ns;
        reset <= '0';

        -- First byte: 10101010
        wait for 40 ns;
        data_in    <= "10101010";
        data_valid <= '1';
        wait for CLK_PERIOD;
        data_valid <= '0';

        -- Hold idle 3 cycles
        wait for 3 * CLK_PERIOD;

        -- Second byte: 11001100
        data_in    <= "11001100";
        data_valid <= '1';
        wait for CLK_PERIOD;
        data_valid <= '0';

        wait for 3 * CLK_PERIOD;

        -- Third byte: 11110000
        data_in    <= "11110000";
        data_valid <= '1';
        wait for CLK_PERIOD;
        data_valid <= '0';

        -- Wait long enough for full encoding
        wait for 2000 ns;

        wait;
    end process;

end sim;



