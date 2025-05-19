library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top1 is
end tb_top1;

architecture sim of tb_top1 is

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal data_in     : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_in    : std_logic := '0';
    signal data_out    : std_logic_vector(7 downto 0);
    signal valid_out   : std_logic;
    signal snr         : std_logic_vector(5 downto 0) := "000000";

    -- Example input image bytes (shortened for simulation)
--    type byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
--    constant test_data : byte_array := (
--        x"4B", x"E2", x"FC", x"D2", x"1F", x"9C", x"56", x"12"
--    );
    
    constant CLK_PERIOD : time := 10 ns;


    component top1 is
    generic (
            RAM_DEPTH : integer := 11776
        );
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        data_in    : in  STD_LOGIC_VECTOR(7 downto 0);  -- Input byte
        valid_in   : in  STD_LOGIC;                    -- Byte is valid

        data_out   : out STD_LOGIC_VECTOR(7 downto 0); -- Output decoded byte
        valid_out  : out STD_LOGIC;                   -- Output valid flag

        snr        : in  STD_LOGIC_VECTOR(5 downto 0)
    );
    end component;
begin

    -- Clock generation: 100 MHz (10 ns period)
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
    uut: top1
        port map (
            clk        => clk,
            reset      => reset,
            data_in    => data_in,
            valid_in => valid_in,
            data_out    => data_out,
            valid_out       => valid_out,
            snr   => snr
        );

    -- Stimulus process
    stim_proc: process
    begin
        wait for 40 ns;
        reset <= '0';

        -- First byte: 10101010
        wait for 100 ns;
        data_in    <= "11101010";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        -- Hold idle 3 cycles
        wait for 2 * CLK_PERIOD;

        -- Second byte: 11001100
        data_in    <= "11001100";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        wait for 2 * CLK_PERIOD;

        -- Third byte: 11110000
        data_in    <= "11110000";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';
        
        wait for 2 * CLK_PERIOD;

        -- Third byte: 11110000
        data_in    <= "11110011";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';
        
        wait for 2 * CLK_PERIOD;

        -- Second byte: 11001100
        data_in    <= "11001100";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';
        
        wait for 8 * CLK_PERIOD;

        -- Second byte: 11001100
        data_in    <= "11010101";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        wait for 2 * CLK_PERIOD;

        -- Second byte: 11001100
        data_in    <= "10101100";
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';
        -- Wait long enough for full encoding
        wait for 2000 ns;

        wait;
    end process;

end sim;
