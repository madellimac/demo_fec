
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level2 is
    generic (
        RAM_DEPTH : integer := 11776
    );
    port (
        rst             : in  std_logic;
        clk             : in  std_logic;
        enable          : in  std_logic;
        x1,x2             : in  std_logic;
        snr             : in  std_logic_vector(5 downto 0);
        expected_bytes : in INTEGER range 0 to RAM_DEPTH;
        
        result          : out std_logic;
        decode_ready    : out std_logic;
        data_valid_out  : out std_logic;
        decoded_ram_out : out std_logic_vector(7 downto 0)
    );
end top_level2;

architecture Behavioral of top_level2 is

    -- Components
    component transmitter1 is
        port (
            rst              : in  std_logic;
            clk              : in  std_logic;
            enable           : in  std_logic;
            x1,x2              : in  std_logic;
            y1               : out std_logic_vector(2 downto 0);
            y2               : out std_logic_vector(2 downto 0);
            valid            : out std_logic;
            snr              : in  std_logic_vector(5 downto 0)
        );
    end component;

    component viterbi_decoder is
        port (
            rst          : in  std_logic;
            clk          : in  std_logic;
            enable       : in  std_logic;
            y1           : in  std_logic_vector(2 downto 0);
            y2           : in  std_logic_vector(2 downto 0);
            decoded_bit  : out std_logic;
            decode_ready : out std_logic
        );
    end component;

    component fifo is
        port (
            rst      : in  std_logic;
            clk      : in  std_logic;
            enable   : in  std_logic;
            data_in  : in  std_logic;
            data_out : out std_logic
        );
    end component;

    component Error_count_module_1 is
        port (
            rst           : in  std_logic;
            clk           : in  std_logic;
            enable        : in  std_logic;
            comp_1        : in  std_logic;
            comp_2        : in  std_logic;
            BE_Nb         : out std_logic_vector(15 downto 0);
            FE_Nb         : out std_logic_vector(12 downto 0);
            
            
            Bit_Nb        : out std_logic_vector(49 downto 0);
            Frame_Nb      : out std_logic_vector(47 downto 0);
            BER_LED       : out std_logic_vector(1 downto 0);
            overflow_LED  : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Signals
    signal y1, y2                         : std_logic_vector(2 downto 0);
    signal decoded_bit                    : std_logic;
    signal decoder_ready_internal         : std_logic;
    signal information_bit, sync_information_bit : std_logic;
    signal decode_valid : std_logic;
    signal valid : std_logic;
    signal FE_Nb                   : std_logic_vector(12 downto 0);
    signal BE_Nb                   : std_logic_vector(15 downto 0);
    signal Bit_Nb                         : std_logic_vector(49 downto 0);
    signal Frame_Nb                       : std_logic_vector(47 downto 0);
    signal BER_LED, overflow_LED          : std_logic_vector(1 downto 0);

    signal decoded_byte                   : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_cnt                        : integer range 0 to 7 := 0;

    type ram_type is array(0 to RAM_DEPTH-1) of std_logic_vector(7 downto 0);
    signal decoded_ram                    : ram_type := (others => (others => '0'));

    signal write_ptr                      : integer range 0 to RAM_DEPTH-1 := 0;
    signal last_written_ptr               : integer range 0 to RAM_DEPTH-1 := 0;

    signal valid_reg                      : std_logic := '0';
    signal latch_bit                      : std_logic := '0';
    signal decoded_byte_out : std_logic_vector(7 downto 0) := (others => '0');
    -- Add signal at top of architecture
signal v_byte : std_logic_vector(7 downto 0) := (others => '0');
signal write_byte_next : std_logic := '0';
signal latch_next_cycle : std_logic := '0';
signal pending_write : std_logic := '0';  -- new flag
signal last_bit      : std_logic := '0';  -- hold last bit separately
signal seen_first_valid : std_logic := '0';
signal decoder_ready_d : std_logic := '0';  -- delayed version of decode_ready
signal decoded_bit_d   : std_logic := '0';  -- delayed decoded bit

signal decoded_byte_count : integer range 0 to RAM_DEPTH-1 := 0;


begin



trans : transmitter1
   Port map(rst,
				clk,
				enable,
				x1,
				x2,
				y1,
				y2,
				valid,
				snr );

dec : viterbi_decoder
	port map(	rst,
			clk,
			enable,
			y1,
			y2,
			decoded_bit,
			decoder_ready_internal );
			
delay_data : fifo
	port map(rst,
				clk,
				enable,
				information_bit,
				sync_information_bit);

error_count : Error_count_module_1
	port map(rst,
				clk,
				enable,
				sync_information_bit,
				decoded_bit,
				BE_Nb,
				FE_Nb,
				Bit_Nb,
				Frame_Nb,
				BER_LED,
				overflow_LED
	);
    -- === Bit Accumulation and Byte Write Process ===
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            v_byte            <= (others => '0');
            decoded_byte_out <= (others => '0');
            bit_cnt          <= 0;
            write_ptr        <= 0;
            last_written_ptr <= 0;
            valid_reg        <= '0';
            latch_next_cycle <= '0';
            seen_first_valid <= '0';
            decoded_byte_count <= 0;

        elsif latch_next_cycle = '1' then
            v_byte(bit_cnt) <= decoded_bit;

            if bit_cnt = 7 then
                decoded_byte_out       <= v_byte;
                decoded_ram(write_ptr) <= v_byte;
                last_written_ptr       <= write_ptr;
                write_ptr              <= (write_ptr + 1) mod RAM_DEPTH;
                bit_cnt                <= 0;
                valid_reg              <= '1';
                decoded_byte_count     <= decoded_byte_count + 1;

                -- Stop decoding if we've reached the expected number of bytes
                if decoded_byte_count + 1 = expected_bytes then
                    seen_first_valid <= '0';  -- block further decoding
                end if;
            else
                bit_cnt <= bit_cnt + 1;
                valid_reg <= '0';
            end if;

            latch_next_cycle <= '0';

        elsif decoder_ready_internal = '1' and decoded_byte_count < expected_bytes then
            if seen_first_valid = '0' then
                seen_first_valid <= '1';
            else
                latch_next_cycle <= '1';
            end if;
            valid_reg <= '0';

        else
            valid_reg <= '0';
        end if;
    end if;
end process;



    -- Outputs
    decoded_ram_out <= decoded_byte_out;

    result          <= decoded_bit;
    decode_ready    <= decoder_ready_internal;
    data_valid_out  <= valid_reg;

end Behavioral;
