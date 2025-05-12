------------------------------------------------------------------------------------
---- Company: ENSEIRB-MATMECA
---- Designer: Camille Leroux
---- Generation Date:   Aug 29, 2012
---- Design Name: Viterbi_codec
---- Module Name: viterbi_encoder   
---- Description: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--entity viterbi_encoder is
--    Port ( rst : in  STD_LOGIC;
--           clk : in  STD_LOGIC;
--           enable : in  STD_LOGIC;
--           data : in  STD_LOGIC;
--           x1 : out  STD_LOGIC;
--			  x2 : out  STD_LOGIC);
--end viterbi_encoder;

--architecture Behavioral of viterbi_encoder is

--signal shift_register : std_logic_vector(2 downto 0);

--begin

--process(rst,clk)
--begin
--	if(rst='1') then
--		shift_register <=(others =>'0');
--	elsif(clk'event and clk='1') then
--		if(enable='1') then
--			shift_register(1 downto 0) <= shift_register(2 downto 1);
--			shift_register(2) <= data;
--		end if;
--	end if;
--end process;

--x2 <= data xor shift_register(1) xor shift_register(0);
--x1 <= data xor shift_register(2) xor shift_register(0);


--end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity viterbi_encoder is
    generic (
        RAM_DEPTH : integer := 11776
    );
    Port (
        rst            : in  STD_LOGIC;
        clk            : in  STD_LOGIC;
        enable         : in  STD_LOGIC;
        data           : in  STD_LOGIC;

        x1             : out STD_LOGIC;
        x2             : out STD_LOGIC;

        x1_ram_out     : out STD_LOGIC_VECTOR(7 downto 0);
        x2_ram_out     : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid_out : out STD_LOGIC
    );
end viterbi_encoder;

architecture Behavioral of viterbi_encoder is

    signal shift_register : std_logic_vector(2 downto 0) := (others => '0');

    signal x1_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal x2_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_cnt : integer range 0 to 7 := 0;

    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
    signal x1_ram : ram_type := (others => (others => '0'));
    signal x2_ram : ram_type := (others => (others => '0'));

    signal write_ptr : integer range 0 to RAM_DEPTH-1 := 0;
    signal last_written_ptr : integer range 0 to RAM_DEPTH-1 := 0;

    signal x1_bit, x2_bit : std_logic := '0';
    signal valid_reg      : std_logic := '0';
    signal write_now      : std_logic := '0';  -- new!

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_register   <= (others => '0');
                x1_byte          <= (others => '0');
                x2_byte          <= (others => '0');
                bit_cnt          <= 0;
                write_ptr        <= 0;
                last_written_ptr <= 0;
                valid_reg        <= '0';
                x1_bit           <= '0';
                x2_bit           <= '0';
                write_now        <= '0';

            elsif enable = '1' then
                -- Encode current bit
                x1_bit <= data xor shift_register(2) xor shift_register(0);
                x2_bit <= data xor shift_register(1) xor shift_register(0);

                x1_byte(bit_cnt) <= data xor shift_register(2) xor shift_register(0);
                x2_byte(bit_cnt) <= data xor shift_register(1) xor shift_register(0);

                shift_register <= data & shift_register(2 downto 1);

                if bit_cnt = 7 then
                    bit_cnt <= 0;
                    write_now <= '1';  -- write will happen next cycle
                else
                    bit_cnt <= bit_cnt + 1;
                end if;

            else
                x1_bit <= x1_bit;
                x2_bit <= x2_bit;
                write_now <= '0';
                valid_reg <= '0';
            end if;

            -- Perform RAM write one cycle after bit 7 was stored
            if write_now = '1' then
                x1_ram(write_ptr) <= x1_byte;
                x2_ram(write_ptr) <= x2_byte;
                last_written_ptr  <= write_ptr;
                write_ptr <= (write_ptr + 1) mod RAM_DEPTH;
                valid_reg <= '1';
            end if;
        end if;
    end process;

    -- Outputs
    x1 <= x1_bit;
    x2 <= x2_bit;

    x1_ram_out <= x1_ram(last_written_ptr);
    x2_ram_out <= x2_ram(last_written_ptr);
    data_valid_out <= valid_reg;

end Behavioral;

