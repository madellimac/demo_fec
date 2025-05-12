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
        
        
        
        TX1         : out STD_LOGIC;  -- UART Transmit back to PC
        TX2         : out STD_LOGIC;  -- UART Transmit back to PC

--        uart_data  : out STD_LOGIC_VECTOR (15 downto 0); -- for when we have an image
--        uart_enable: out STD_LOGIC; -- for when we have in image
--        snr : in std_logic_vector(5 downto 0);
        enable : in std_logic;
        
        
        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full  : out STD_LOGIC;   -- FIFO Full Indicator
        
        fifo_empty1 : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull1 : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full1  : out STD_LOGIC;   -- FIFO Full Indicator

        fifo_empty2 : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull2 : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full2  : out STD_LOGIC   -- FIFO Full Indicator
    );
end FPGA1;

architecture Behavioral of FPGA1 is
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



--component fsm is
--    Port (
--        clk       : in  STD_LOGIC;
--        reset     : in  STD_LOGIC;
--        start     : in  STD_LOGIC;
--        data_in   : in  STD_LOGIC_VECTOR(7 downto 0);
--        done      : out STD_LOGIC;
--        x1_byte   : out STD_LOGIC_VECTOR(7 downto 0);
--        x2_byte   : out STD_LOGIC_VECTOR(7 downto 0)
--    );
--end component;

component encode8 is
    generic (
            RAM_DEPTH : integer := 16
        );
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
        data_valid  : in  STD_LOGIC;
        done        : out STD_LOGIC;
        x1_byte     : out STD_LOGIC_VECTOR(7 downto 0);
        x2_byte     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end component;



 -- Internal Signals
    signal data_in       : STD_LOGIC_VECTOR(7 downto 0); -- Data received from UART RX
    signal data_valid    : STD_LOGIC;                    -- Data valid signal from UART RX
--    signal uart_data_reg : STD_LOGIC_VECTOR(15 downto 0); -- Register for 16-bit data assembly
--    signal byte_count    : STD_LOGIC := '0';  -- Tracks whether we are receiving the first or second byte


signal encoder_done : std_logic;
signal fifo_full_sig : std_logic;
signal x1_byte, x2_byte : std_logic_vector(7 downto 0);

    
    signal data_out1, data_out : std_logic_vector(7 downto 0);
    signal data_out2 : std_logic_vector(7 downto 0);
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
        
        
        
    
--    fsm_encoder_inst: fsm
--        port map (
--            clk     => clk,
--            reset   => reset,
--            start   => data_valid, -- from UART
--            data_in => data_in,
--            done    => encoder_done,
--            x1_byte => x1_byte,
--            x2_byte => x2_byte
--        );

	encoder_inst : encode8
        port map (
            clk        => clk,
            reset      => reset,
            data_in    => data_in,
            data_valid => data_valid,
            done       => encoder_done,
            x1_byte    => x1_byte,
            x2_byte    => x2_byte
        );
		  

				
	    
    data_out <= x2_byte WHEN enable = '1' ELSE x1_byte;		

    -- FIFO-based UART Transmitter: Sends data back to the PC
    UART_TX_FIFO1 : UART_fifoed_send
        port map (
            clk_100MHz => clk,
            reset      => reset,
            dat_en     => encoder_done,     -- Enable writing to FIFO when data is valid
            dat        => x1_byte,        -- Data from UART RX
            TX         => TX1,             -- UART Transmit to PC
            fifo_empty => fifo_empty1,     -- FIFO empty status
            fifo_afull => fifo_afull1,     -- FIFO almost full status
            fifo_full  => fifo_full1       -- FIFO full status
        );
        
            -- FIFO-based UART Transmitter: Sends data back to the PC
    UART_TX_FIFO2 : UART_fifoed_send
        port map (
            clk_100MHz => clk,
            reset      => reset,
            dat_en     => encoder_done,     -- Enable writing to FIFO when data is valid
            dat        => x2_byte,        -- Data from UART RX
            TX         => TX2,             -- UART Transmit to PC
            fifo_empty => fifo_empty2,     -- FIFO empty status
            fifo_afull => fifo_afull2,     -- FIFO almost full status
            fifo_full  => fifo_full2       -- FIFO full status
        );
        
     	
	
			  
     UART_TX_FIFO : UART_fifoed_send
        port map (
            clk_100MHz => clk,
            reset      => reset,
            dat_en     => encoder_done,     -- Enable writing to FIFO when data is valid
            dat        => data_out,        -- Data from UART RX
            TX         => TX,             -- UART Transmit to PC
            fifo_empty => fifo_empty,     -- FIFO empty status
            fifo_afull => fifo_afull,     -- FIFO almost full status
            fifo_full  => fifo_full       -- FIFO full status
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
    

end Behavioral;
