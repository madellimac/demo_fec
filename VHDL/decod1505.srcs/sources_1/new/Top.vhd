----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.03.2025 17:50:15
-- Design Name: 
-- Module Name: TOP - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_2 is
  Port ( clk : in  STD_LOGIC;  -- 100 MHz Clock
        reset      : in  STD_LOGIC;  -- Reset signal
        enable     : in  STD_LOGIC;  -- Read from memory
        RX1,RX2         : in  STD_LOGIC;  -- UART Receive from PC
        --BACK TO THE COMPUTER
        TX         : out STD_LOGIC;  -- UART Transmit back to PC
        
        -- PMOD OLED DISPLAY PARAMETERS
        PMOD_CS    : out STD_LOGIC;
        PMOD_MOSI  : out STD_LOGIC;
        PMOD_SCK   : out STD_LOGIC;
        PMOD_DC    : out STD_LOGIC;
        PMOD_RES   : out STD_LOGIC;
        PMOD_VCCEN : out STD_LOGIC;
        PMOD_EN    : out STD_LOGIC;
        
        --FOR THE FIFO
        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full  : out STD_LOGIC;   -- FIFO Full Indicator);
        
        --RAM DEBUGGING
        led : out std_logic
        );
end TOP_2;

architecture Behavioral of TOP_2 is
    -- Constants
    constant BAUDRATE : integer := 921600;

    -- UART Receive Signals
    signal uart_data  : STD_LOGIC_VECTOR(15 downto 0); -- Received 16-bit pixel
    signal data_valid : STD_LOGIC;  -- High when valid data received

    -- Signals for interconnecting the components
    signal ram_data_in   : STD_LOGIC_VECTOR(15 downto 0);   -- Image data in RGB565 format
    signal uart_ram_addr   : STD_LOGIC_VECTOR(12 downto 0); -- Address (96x64 = 6144 pixels)
    signal pmod_ram_addr   : STD_LOGIC_VECTOR(12 downto 0); -- Address (96x64 = 6144 pixels)
    signal ram_data_out  : STD_LOGIC_VECTOR(15 downto 0);   -- Data read from RAM
    signal ram_addr      : STD_LOGIC_VECTOR(12 downto 0);   -- RAM address
    signal ram_enable    : STD_LOGIC;                       -- Enable signal for RAM
    signal ram_ce        : STD_LOGIC;                       -- Clock enable for RAM
    signal image_enable  : STD_LOGIC;                       -- Enable for image display
    signal ram_write    : STD_LOGIC;                        -- RAM write enable
    
    -- Image Display Signals
    signal pix_col       : STD_LOGIC_VECTOR(6 downto 0);    -- Pixel column
    signal pix_row       : STD_LOGIC_VECTOR(5 downto 0);    -- Pixel row
    signal pix_data      : STD_LOGIC_VECTOR(15 downto 0);   -- RGB565 pixel data
    signal pix_write     : STD_LOGIC;                       -- Signal to write data to the PMOD display

component FPGA2 is
 Port (
        clk : in  STD_LOGIC;  -- 100 MHz Clock
        reset      : in  STD_LOGIC;  -- Reset signal
        RX1,RX2         : in  STD_LOGIC;  -- UART Receive from PC
        uart_data  : out STD_LOGIC_VECTOR (15 downto 0);
        uart_enable: out STD_LOGIC;
        TX         : out STD_LOGIC;  -- UART Transmit back to PC
        fifo_empty : out STD_LOGIC;  -- FIFO Empty Indicator
        fifo_afull : out STD_LOGIC;  -- FIFO Almost Full Indicator
        fifo_full  : out STD_LOGIC   -- FIFO Full Indicator
    );
end component;

component Image_Display is
    Generic (
        largeur_ecran : integer:= 96;
        longeur_ecran : integer:= 64;
        Bpp: integer:= 16
    );
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        
        ram_addr     : out STD_LOGIC_VECTOR(12 downto 0);
        
        enable_pmod : in  STD_LOGIC;
        ram_data_in  : in  STD_LOGIC_VECTOR(Bpp-1 downto 0);
        
        pix_col      : out STD_LOGIC_VECTOR(6 downto 0);
        pix_row      : out STD_LOGIC_VECTOR(5 downto 0);
        pix_data_out : out STD_LOGIC_VECTOR(Bpp-1 downto 0);
        pix_write    : out STD_LOGIC
    );
end component;

component PmodOLEDrgb_bitmap is
    Generic (CLK_FREQ_HZ : integer := 100000000;        -- by default, we run at 100MHz
             BPP         : integer range 1 to 16 := 16; -- bits per pixel
             GREYSCALE   : boolean := False;            -- color or greyscale ? (only for BPP>6)
             LEFT_SIDE   : boolean := False);           -- True if the Pmod is on the left side of the board
    Port (clk          : in  STD_LOGIC;
          reset        : in  STD_LOGIC;
          
          pix_write    : in  STD_LOGIC;
          pix_col      : in  STD_LOGIC_VECTOR(    6 downto 0);
          pix_row      : in  STD_LOGIC_VECTOR(    5 downto 0);
          pix_data_in  : in  STD_LOGIC_VECTOR(BPP-1 downto 0);
          pix_data_out : out STD_LOGIC_VECTOR(BPP-1 downto 0);
          
          PMOD_CS      : out STD_LOGIC;
          PMOD_MOSI    : out STD_LOGIC;
          PMOD_SCK     : out STD_LOGIC;
          PMOD_DC      : out STD_LOGIC;
          PMOD_RES     : out STD_LOGIC;
          PMOD_VCCEN   : out STD_LOGIC;
          PMOD_EN      : out STD_LOGIC);
end component;

component RAM_IMAGE is
    GENERIC (
        WIDTH  : INTEGER := 96;
        HEIGHT : INTEGER := 64;
        BPP    : INTEGER := 16
    );
        PORT (
            clk : IN STD_LOGIC;
            ce : IN STD_LOGIC;
            
            r_w : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            
            add : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
            data_in : IN STD_LOGIC_VECTOR (BPP-1 DOWNTO 0);
            
            data_out : OUT STD_LOGIC_VECTOR (BPP-1 DOWNTO 0);
            led : out std_logic
        );
end component;

begin

    -- Instantiate FPGA1 (handles UART reception)
    FPGA2_inst : FPGA2
        Port map (
            clk        => clk,
            reset      => reset,
            RX1         => RX1,
            RX2         => RX2,
            TX         => TX,
            uart_data  => uart_data,
            uart_enable=> data_valid,
            fifo_empty => fifo_empty,
            fifo_afull => fifo_afull,
            fifo_full  => fifo_full
        );

    -- Instantiate Image Display (drives OLED PMOD display)
    Image_Display_inst : Image_Display
        Port map (
            clk          => clk,
            reset        => reset,
            ram_addr     => pmod_ram_addr,
            enable_pmod  => image_enable,
            ram_data_in  => ram_data_out,
            pix_col      => pix_col,
            pix_row      => pix_row,
            pix_data_out => pix_data,
            pix_write    => pix_write
        );

    -- Instantiate PmodOLEDrgb_bitmap (control signals for PMOD)
    PmodOLEDrgb_bitmap_inst : PmodOLEDrgb_bitmap
        Port map (
            clk          => clk,
            reset        => reset,
            pix_write    => pix_write,
            pix_col      => pix_col,
            pix_row      => pix_row,
            pix_data_in  => pix_data,
            pix_data_out => open,
            PMOD_CS      => PMOD_CS,
            PMOD_MOSI    => PMOD_MOSI,
            PMOD_SCK     => PMOD_SCK,
            PMOD_DC      => PMOD_DC,
            PMOD_RES     => PMOD_RES,
            PMOD_VCCEN   => PMOD_VCCEN,
            PMOD_EN      => PMOD_EN
        );

    -- Instantiate RAM for image data storage
    RAM_IMAGE_inst : RAM_IMAGE
        Port map (
            clk        => clk,
            ce         => '1',
            r_w        => ram_write,  -- Write mode
            enable     => enable,
            add        => ram_addr,
            data_in    => ram_data_in,
            data_out   => ram_data_out,
            led        => led
        );


    -- **Button Logic: Enable Display When Pressed**
-- **Ensure RAM Read/Write Addressing Matches**
ram_addr <= pmod_ram_addr when image_enable = '1' else uart_ram_addr;

-- **Writing Pixels to RAM from UART (with image_enable)**
process(clk)
    variable pixel_counter : integer range 0 to 6144 := 0;
    variable image_received : boolean := false;  -- Track when image is fully received
begin
    if rising_edge(clk) then
        if reset = '1' then
            pixel_counter := 0;
            ram_write <= '0';
            image_received := false;
            image_enable <= '0';  -- Ensure display is OFF at reset
        elsif data_valid = '1' and not image_received then
            if pixel_counter < 6144 then  
                -- **Write pixels in correct order**
                uart_ram_addr <= std_logic_vector(to_unsigned(pixel_counter, 13));
                ram_data_in <= uart_data;  
                ram_write <= '1';  
                pixel_counter := pixel_counter + 1;
            end if;

            if pixel_counter = 6144 then  
                ram_write <= '0';  
                image_received := true;  
                image_enable <= '1';  -- Activate display only after full image is stored
            end if;
        else
            ram_write <= '0';  
        end if;

        -- **Reset image_enable when enable goes LOW**
        if enable = '0' then
            image_received := false;
            pixel_counter := 0;
            image_enable <= '0';  -- Disable display when preparing a new image
        end if;
    end if;
end process;


end Behavioral;
