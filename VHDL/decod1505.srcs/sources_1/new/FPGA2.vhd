library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FPGA2 is
 Port (
        clk : in  STD_LOGIC;  -- 100 MHz Clock
        reset      : in  STD_LOGIC;  -- Reset signal
        RX1,RX2         : in  STD_LOGIC;  -- UART Receive from PC
        TX         : out STD_LOGIC;  -- UART Transmit back to PC
        uart_data  : out STD_LOGIC_VECTOR (15 downto 0);
        uart_enable: out STD_LOGIC;
        
        snr  : in STD_LOGIC_VECTOR (5 downto 0);
        
        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full  : out STD_LOGIC   -- FIFO Full Indicator
    );
end FPGA2;

architecture Behavioral of FPGA2 is

component top2 is
--    port(rst : in std_logic;
--			 clk : in std_logic;
--			 enable : in std_logic;
--			 dat : in std_logic;
--			 snr : in std_logic_vector(5 downto 0);
--			 result : out std_logic);
generic (
            RAM_DEPTH : integer := 11776
        );
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        x1,x2    : in  STD_LOGIC_VECTOR(7 downto 0);  -- Input byte
        valid_in1,valid_in2   : in  STD_LOGIC;                    -- Byte is valid

        data_out   : out STD_LOGIC_VECTOR(7 downto 0); -- Output decoded byte
        valid_out  : out STD_LOGIC;                   -- Output valid flag

        snr        : in  STD_LOGIC_VECTOR(5 downto 0)
    );
end component;
component UART_RECV_generic is
    Generic (CLK_FREQU : integer := 100000000;
             BAUDRATE  : integer := 921600;
             TIME_PREC : integer := 0;
             DATA_SIZE : integer := 8);
    Port ( clk   : in STD_LOGIC;
           reset : in STD_LOGIC;
           RX    : in STD_LOGIC;
           dout  : out STD_LOGIC_VECTOR (DATA_SIZE - 1 downto 0);
           den   : out STD_LOGIC);
end component;

component UART_fifoed_send IS
   GENERIC (
      fifo_size : INTEGER := 4096;
      fifo_almost : INTEGER := 4090;
      drop_oldest_when_full : BOOLEAN := False;
      asynch_fifo_full : BOOLEAN := True;
      baudrate : INTEGER := 921600; -- [bps]
      clock_frequency : INTEGER := 100000000 -- [Hz]
   );
   PORT (
      clk_100MHz : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      dat_en : IN STD_LOGIC;
      dat : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
      TX : OUT STD_LOGIC;
      fifo_empty : OUT STD_LOGIC;
      fifo_afull : OUT STD_LOGIC;
      fifo_full : OUT STD_LOGIC
   );
end component;
 -- Internal Signals
    signal x1,x2       : STD_LOGIC_VECTOR(7 downto 0); -- Data received from UART RX
    signal data_valid1,data_valid2,data_valid_d    : STD_LOGIC;                    -- Data valid signal from UART RX
    
    signal uart_data_reg : STD_LOGIC_VECTOR(15 downto 0); -- Register for 16-bit data assembly
    signal byte_count    : STD_LOGIC := '0';  -- Tracks whether we are receiving the first or second byte
    signal dat,res : STD_LOGIC := '0';
    signal data_tx : std_logic_vector(7 downto 0);
begin

    -- UART Receiver: Receives data from the PC
    UART_RX : UART_RECV_generic
        port map (
            clk   => clk,
            reset => reset,
            RX    => RX1,
            dout  => x1,
            den   => data_valid1
        );

    UART_RX2 : UART_RECV_generic
        port map (
            clk   => clk,
            reset => reset,
            RX    => RX2,
            dout  => x2,
            den   => data_valid2
        );
                


    -- Assign output
    uart_data <= uart_data_reg;
        
    DECODE : top2
        port map(
            reset => reset,
			 clk => clk,
			 x1 => x1,
			 x2 => x2,
			 valid_in1 => data_valid1,
			 valid_in2 => data_valid2,
			 snr => snr,
			 data_out => data_tx,
			 valid_out => data_valid_d
        );
    
--    data_tx <= "0000000" & res;

--                 Process to combine two 8-bit chunks into one 16-bit value
        process (clk, reset)
        begin
            if reset = '1' then
                uart_data_reg <= (others => '0');
                byte_count <= '0';
            elsif rising_edge(clk) then
                if data_valid_d = '1' then
                    if byte_count = '0' then
                        uart_data_reg(15 downto 8) <= data_tx; -- Store first byte in upper 8 bits
                        byte_count <= '1';
                        uart_enable <= '0';
                    else
                        uart_data_reg(7 downto 0) <= data_tx;  -- Store second byte in lower 8 bits
                        byte_count <= '0';
                        uart_enable <= '1';
                    end if;
                 else
                    uart_enable <= '0';
                end if;
            end if;
        end process;
    
    -- FIFO-based UART Transmitter: Sends data back to the PC
    UART_TX_FIFO : UART_fifoed_send
        port map (
            clk_100MHz => clk,
            reset      => reset,
            dat_en     => data_valid_d,     -- Enable writing to FIFO when data is valid
            dat        => data_tx,        -- Data from UART RX
            TX         => TX,             -- UART Transmit to PC
            fifo_empty => fifo_empty,     -- FIFO empty status
            fifo_afull => fifo_afull,     -- FIFO almost full status
            fifo_full  => fifo_full       -- FIFO full status
        );
     
    

end Behavioral;

