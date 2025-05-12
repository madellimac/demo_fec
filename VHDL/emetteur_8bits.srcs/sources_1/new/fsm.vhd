library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        done      : out STD_LOGIC;
        x1_byte   : out STD_LOGIC_VECTOR(7 downto 0);
        x2_byte   : out STD_LOGIC_VECTOR(7 downto 0)
    );
end fsm;

architecture Behavioral of fsm is

    type state_type is (IDLE, ENCODE, DONEE);
    signal current_state, next_state : state_type;

    signal bit_index  : integer range 0 to 7 := 0;
    signal shift_byte : std_logic_vector(7 downto 0);
    signal x1_result, x2_result : std_logic_vector(7 downto 0);

    signal encoder_input : std_logic;
    signal x1, x2 : std_logic;

    component viterbi_encoder
        Port (
            rst     : in  STD_LOGIC;
            clk     : in  STD_LOGIC;
            enable  : in  STD_LOGIC;
            data    : in  STD_LOGIC;
            x1      : out STD_LOGIC;
            x2      : out STD_LOGIC
        );
    end component;

begin

    encoder_inst: viterbi_encoder
    port map (
        rst    => reset,
        clk    => clk,
        enable => '1',
        data   => encoder_input,
        x1     => x1,
        x2     => x2
    );

    -- FSM state update
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- FSM next state logic
    process(current_state, start, bit_index)
    begin
        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= ENCODE;
                else
                    next_state <= IDLE;
                end if;
            when ENCODE =>
                if bit_index = 7 then
                    next_state <= DONEE;
                else
                    next_state <= ENCODE;
                end if;
            when DONEE =>
                next_state <= IDLE;
        end case;
    end process;

    -- Main encoding process
    process(clk, reset)
    begin
        if reset = '1' then
            bit_index <= 0;
            x1_result <= (others => '0');
            x2_result <= (others => '0');
            shift_byte <= (others => '0');
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    if start = '1' then
                        shift_byte <= data_in;
                        bit_index <= 0;
                    end if;

                when ENCODE =>
                    encoder_input <= shift_byte(bit_index);
                    x1_result(bit_index) <= x1;
                    x2_result(bit_index) <= x2;
                    bit_index <= bit_index + 1;

                when DONEE =>
                    -- Nothing to do here
                    null;
            end case;
        end if;
    end process;

    x1_byte <= x1_result;
    x2_byte <= x2_result;
    done <= '1' when current_state = DONEE else '0';

end Behavioral;
