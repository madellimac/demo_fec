
----------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date: 01/16/2025 11:49:09 AM
-- Design Name:
-- Module Name: RAM_SP_64_8 - Behavioral
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

entity RAM_IMAGE is
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
end RAM_IMAGE;

architecture Behavioral of RAM_IMAGE is
    type ram_type is array (0 to WIDTH*HEIGHT-1) of std_logic_vector (BPP-1 downto 0);
    signal RAM : ram_type := (others => "1111111111111111");
begin
     process (clk)
    begin
        if (clk'event and clk = '1') then
            if (ce = '1') then
                if (enable = '1') then
                
                    if ( r_w = '1') then
                        led <='1';
                        RAM(to_integer(unsigned(add))) <= data_in;
                    else
                        led <= '0';
                        data_out <= RAM(to_integer(unsigned(add)));
                    end if;
                    
                end if;
            end if;
        end if;
    end process;

    

end Behavioral;
