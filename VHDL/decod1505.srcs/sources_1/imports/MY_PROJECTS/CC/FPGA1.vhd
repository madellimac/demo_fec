------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 02/03/2025 02:47:48 PM
---- Design Name: 
---- Module Name: FPGA1 - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity FPGA1 is
-- Port (
--        clk : in  STD_LOGIC;  -- 100 MHz Clock
--        reset      : in  STD_LOGIC;  -- Reset signal
--        RX         : in  STD_LOGIC;  -- UART Receive from PC
--        TX         : out STD_LOGIC;  -- UART Transmit back to PC
----        uart_data  : out STD_LOGIC_VECTOR (15 downto 0);
----        uart_enable: out STD_LOGIC;
        
--        snr  : in STD_LOGIC_VECTOR (5 downto 0);
        
--        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
--        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
--        fifo_full  : out STD_LOGIC   -- FIFO Full Indicator
--    );
--end FPGA1;

--architecture Behavioral of FPGA1 is

--component data_deserializer is
--    generic (
--        RAM_DEPTH : integer := 64
--    );
--    Port (
--        clk        : in  STD_LOGIC;
--        reset      : in  STD_LOGIC;
--        data_in    : in  STD_LOGIC;  -- input bit (serial)
--        data_valid_in : in STD_LOGIC; -- only store when this is '1'

--        data_out   : out STD_LOGIC_VECTOR(7 downto 0); -- full byte output
--        data_valid : out STD_LOGIC  -- high when byte is ready
--    );
--end component;

--component data_serializer is
--    generic (
--        RAM_DEPTH : integer := 16
--    );
--    Port (
--        clk         : in  STD_LOGIC;
--        reset       : in  STD_LOGIC;

--        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
--        data_valid  : in  STD_LOGIC;

--        data_out    : out STD_LOGIC;
--        ready       : out STD_LOGIC  -- high when a bit is present at data_out
--    );
--end component;

--component top_level is
--    port(rst : in std_logic;
--			 clk : in std_logic;
--			 enable : in std_logic;
--			 dat : in std_logic;
--			 snr : in std_logic_vector(5 downto 0);
--			 result : out std_logic);
--end component;
--component UART_RECV_generic is
--    Generic (CLK_FREQU : integer := 100000000;
--             BAUDRATE  : integer := 921600;
--             TIME_PREC : integer := 0;
--             DATA_SIZE : integer := 8);
--    Port ( clk   : in STD_LOGIC;
--           reset : in STD_LOGIC;
--           RX    : in STD_LOGIC;
--           dout  : out STD_LOGIC_VECTOR (DATA_SIZE - 1 downto 0);
--           den   : out STD_LOGIC);
--end component;

--component UART_fifoed_send IS
--   GENERIC (
--      fifo_size : INTEGER := 4096;
--      fifo_almost : INTEGER := 4090;
--      drop_oldest_when_full : BOOLEAN := False;
--      asynch_fifo_full : BOOLEAN := True;
--      baudrate : INTEGER := 921600; -- [bps]
--      clock_frequency : INTEGER := 100000000 -- [Hz]
--   );
--   PORT (
--      clk_100MHz : IN STD_LOGIC;
--      reset : IN STD_LOGIC;
--      dat_en : IN STD_LOGIC;
--      dat : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--      TX : OUT STD_LOGIC;
--      fifo_empty : OUT STD_LOGIC;
--      fifo_afull : OUT STD_LOGIC;
--      fifo_full : OUT STD_LOGIC
--   );
--end component;
-- -- Internal Signals
--    signal data_in       : STD_LOGIC_VECTOR(7 downto 0); -- Data received from UART RX
--    signal data_valid    : STD_LOGIC;                    -- Data valid signal from UART RX
--    signal uart_data_reg : STD_LOGIC_VECTOR(15 downto 0); -- Register for 16-bit data assembly
--    signal byte_count    : STD_LOGIC := '0';  -- Tracks whether we are receiving the first or second byte
--    signal dat,res : STD_LOGIC := '0';
--    signal data_tx : std_logic_vector(7 downto 0);
--    signal data_valid_d : std_logic;
--    signal s2p : std_logic;
--    signal ready : std_logic;

--begin

--    -- UART Receiver: Receives data from the PC
--    UART_RX : UART_RECV_generic
--        port map (
--            clk   => clk,
--            reset => reset,
--            RX    => RX,
--            dout  => data_in,
--            den   => data_valid
--        );
        
--     StoP : data_serializer
--        port map (
--            clk   => clk,
--            reset => reset,
--            data_in => data_in,
--            data_valid => data_valid,
--            data_out => s2p,
--            ready => ready
--        );
        
--                -- Process to combine two 8-bit chunks into one 16-bit value
----    process (clk, reset)
----    begin
----        if reset = '1' then
----            uart_data_reg <= (others => '0');
----            byte_count <= '0';
----        elsif rising_edge(clk) then
----            if data_valid = '1' then
----                if byte_count = '0' then
----                    uart_data_reg(15 downto 8) <= data_in; -- Store first byte in upper 8 bits
----                    byte_count <= '1';
----                    uart_enable <= '0';
----                else
----                    uart_data_reg(7 downto 0) <= data_in;  -- Store second byte in lower 8 bits
----                    byte_count <= '0';
----                    uart_enable <= '1';
----                end if;
----             else
----                uart_enable <= '0';
----            end if;
----        end if;
----    end process;

----    -- Assign output
----    uart_data <= uart_data_reg;
        
--    ENCODE_DECODE : top_level
--        port map(
--            rst => reset,
--			 clk => clk,
--			 enable => '1',
--			 dat => s2p,
--			 snr => snr,
--			 result => res
--        );
    
----    data_tx <= "0000000" & res;
   
--        PtoS : data_deserializer
--                port map (
--                    clk   => clk,
--                    reset => reset,
--                    data_in => res,
--                    data_valid_in => '1',
--                    data_out => data_tx,
--                    data_valid => data_valid_d
--                );


    
--    -- FIFO-based UART Transmitter: Sends data back to the PC
--    UART_TX_FIFO : UART_fifoed_send
--        port map (
--            clk_100MHz => clk,
--            reset      => reset,
--            dat_en     => data_valid_d,     -- Enable writing to FIFO when data is valid
--            dat        => data_tx,        -- Data from UART RX
--            TX         => TX,             -- UART Transmit to PC
--            fifo_empty => fifo_empty,     -- FIFO empty status
--            fifo_afull => fifo_afull,     -- FIFO almost full status
--            fifo_full  => fifo_full       -- FIFO full status
--        );
     
    

--end Behavioral;





-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
--                                      TEST                                       --
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/03/2025 02:47:48 PM
-- Design Name: 
-- Module Name: FPGA1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FPGA1 is
 Port (
        clk : in  STD_LOGIC;  -- 100 MHz Clock
        reset      : in  STD_LOGIC;  -- Reset signal
        RX         : in  STD_LOGIC;  -- UART Receive from PC
        TX         : out STD_LOGIC;  -- UART Transmit back to PC
--        uart_data  : out STD_LOGIC_VECTOR (15 downto 0);
--        uart_enable: out STD_LOGIC;
        
        snr  : in STD_LOGIC_VECTOR (5 downto 0);
        
        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full  : out STD_LOGIC   -- FIFO Full Indicator
    );
end FPGA1;

architecture Behavioral of FPGA1 is

component top1 is
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
        data_in    : in  STD_LOGIC_VECTOR(7 downto 0);  -- Input byte
        valid_in   : in  STD_LOGIC;                    -- Byte is valid

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
    signal data_in       : STD_LOGIC_VECTOR(7 downto 0); -- Data received from UART RX
    signal data_valid,data_valid_d    : STD_LOGIC;                    -- Data valid signal from UART RX
    
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
            RX    => RX,
            dout  => data_in,
            den   => data_valid
        );
        
                -- Process to combine two 8-bit chunks into one 16-bit value
--    process (clk, reset)
--    begin
--        if reset = '1' then
--            uart_data_reg <= (others => '0');
--            byte_count <= '0';
--        elsif rising_edge(clk) then
--            if data_valid = '1' then
--                if byte_count = '0' then
--                    uart_data_reg(15 downto 8) <= data_in; -- Store first byte in upper 8 bits
--                    byte_count <= '1';
--                    uart_enable <= '0';
--                else
--                    uart_data_reg(7 downto 0) <= data_in;  -- Store second byte in lower 8 bits
--                    byte_count <= '0';
--                    uart_enable <= '1';
--                end if;
--             else
--                uart_enable <= '0';
--            end if;
--        end if;
--    end process;

--    -- Assign output
--    uart_data <= uart_data_reg;
        
    ENCODE_DECODE : top1
        port map(
            reset => reset,
			 clk => clk,
			 valid_in => data_valid,
			 data_in => data_in,
			 snr => snr,
			 data_out => data_tx,
			 valid_out => data_valid_d
        );
    
--    data_tx <= "0000000" & res;
    
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

