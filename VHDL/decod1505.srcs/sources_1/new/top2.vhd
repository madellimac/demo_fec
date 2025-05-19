library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top2 is
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
end top2;

architecture Behavioral of top2 is

    -- === Serializer Component ===
    component data_serializer is
        generic (
            RAM_DEPTH : integer := 11776
        );
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            data_in         : in  STD_LOGIC_VECTOR(7 downto 0);
            data_valid      : in  STD_LOGIC;
            data_out        : out STD_LOGIC;
            ready           : out STD_LOGIC;
            byte_count_sent : out INTEGER
        );
    end component;

    -- === Top-Level Encode+Decode Component ===
    component top_level2 is
    generic (
            RAM_DEPTH : integer := 11776
        );
	port(rst : in std_logic;
			 clk : in std_logic;
			 enable : in std_logic;
			 x1,x2 : in std_logic;
			 snr : in std_logic_vector(5 downto 0);
			 expected_bytes : in INTEGER range 0 to RAM_DEPTH;
			 result,decode_ready : out std_logic;
			 data_valid_out: out std_logic;
			 decoded_ram_out : out std_logic_vector(7 downto 0));
    end component;

    -- === Internal Signals ===
    signal serialized_bit1,serialized_bit2         : std_logic;
    signal serializer_ready1,ready2       : std_logic;
    signal stable_bit      : std_logic := '0';

    signal decoded_bit,decode_ready     : std_logic;
    signal decoded_byte    : std_logic_vector(7 downto 0);
    signal byte_ready_flag : std_logic;

    signal byte_count1,byte_count2      : integer := 0;
    -- === Delay logic for enable pulse ===
    signal delayed_enable : std_logic := '0';
    signal delay_counter  : integer range 0 to 1500000000 := 0;
begin

    -- === Serializer Instance ===
    serializer_inst1 : data_serializer
        port map (
            clk             => clk,
            reset           => reset,
            data_in         => x1,
            data_valid      => valid_in1,
            data_out        => serialized_bit1,
            ready           => serializer_ready1,
            byte_count_sent => byte_count1
        );

    serializer_inst2 : data_serializer
        port map (
            clk             => clk,
            reset           => reset,
            data_in         => x2,
            data_valid      => valid_in2,
            data_out        => serialized_bit2,
            ready           => ready2,
            byte_count_sent => byte_count2
        );


    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                delay_counter  <= 0;
                delayed_enable <= '0';
            elsif serializer_ready1 = '1' then
                delay_counter  <= 8*92*64*2;  -- Extend enable signal for 6 cycles
                delayed_enable <= '1';
            elsif delay_counter > 0 then
                delay_counter <= delay_counter - 1;
                delayed_enable <= '1';
            else
                delayed_enable <= '0';
            end if;
        end if;
    end process;
    

    -- === Top-Level Encode+Decode Instance ===
    decode_inst : top_level2
        port map (
            rst               => reset,
            clk               => clk,
            enable            => delayed_enable,
            x1               => serialized_bit1,
            x2               => serialized_bit2,
            snr               => snr,
            expected_bytes    => byte_count1,
            result            => decoded_bit,
            decode_ready      => decode_ready,
            decoded_ram_out   => decoded_byte,
            data_valid_out    => byte_ready_flag
        );

    data_out <= decoded_byte;
    valid_out <= byte_ready_flag;

end Behavioral;