----------------------------------------------------------------------------------
-- Company: ENSEIRB-MATMECA
-- Designer: Camille Leroux
-- Generation Date:   Aug 29, 2012
-- Design Name: Viterbi_codec
-- Module Name: viterbi_decoder   
-- Description: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.definition_pkg.all;


entity viterbi_decoder is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			y1 : in std_logic_vector(2 downto 0);
			y2 : in std_logic_vector(2 downto 0);
			decoded_bit, decode_ready : out std_logic);
end viterbi_decoder;

architecture Behavioral of viterbi_decoder is

component branch_metric_unit is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			y1 : in std_logic_vector(2 downto 0);
			y2 : in std_logic_vector(2 downto 0);
			MB00 : out std_logic_vector(3 downto 0);
			MB01 : out std_logic_vector(3 downto 0);
			MB10 : out std_logic_vector(3 downto 0);
			MB11 : out std_logic_vector(3 downto 0));
end component;

component state_metric_unit is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			MB_00 : in std_logic_vector(3 downto 0);
			MB_01 : in std_logic_vector(3 downto 0);
			MB_10 : in std_logic_vector(3 downto 0);
			MB_11 : in std_logic_vector(3 downto 0);
			decision : out std_logic_vector(7 downto 0));
end component;

component survivor_path is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			data_in : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0)
			);
end component;

signal MB00, MB01, MB10, MB11 : std_logic_vector(3 downto 0);
--signal branch_metric : branch_metric_array;
signal state_metric : state_metric_array;
signal enable_dly1, enable_dly2, enable_dly3, enable_dly4 : std_logic;
signal decision, final_decision : std_logic_vector(7 downto 0);
signal decode_ready_pipe : std_logic_vector(28 downto 0) := (others => '0');

signal decoded_fifo : std_logic_vector(10 downto 0);  -- 9-cycle delay


begin

    process (rst,CLK)
    begin
        if(rst='1') then
				enable_dly1 <= '0';
				enable_dly2 <= '0';
				enable_dly3 <= '0';
				enable_dly4 <= '0';
		  elsif (CLK'event and CLK = '1') then            
            enable_dly1 <= enable;            
				enable_dly2 <= enable_dly1;
				enable_dly3 <= enable_dly2;
				enable_dly4 <= enable_dly3;
        end if;
    end process;
    


process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            decode_ready_pipe <= (others => '0');
            decoded_fifo      <= (others => '0');
        else
            decode_ready_pipe <= decode_ready_pipe(27 downto 0) & enable_dly3;
            decoded_fifo(0) <= final_decision(0);
            decoded_fifo(1) <= decoded_fifo(0);
            decoded_fifo(2) <= decoded_fifo(1);
            decoded_fifo(3) <= decoded_fifo(2);
            decoded_fifo(4) <= decoded_fifo(3);
            decoded_fifo(5) <= decoded_fifo(4);
            decoded_fifo(6) <= decoded_fifo(5);
            decoded_fifo(7) <= decoded_fifo(6);
            decoded_fifo(8) <= decoded_fifo(7);
            decoded_fifo(9) <= decoded_fifo(8);
            decoded_fifo(10) <= decoded_fifo(9);
        end if;
    end if;
end process;

	 
BMU : branch_metric_unit
	port map(rst,
			clk,
			enable_dly2,
			y1,
			y2,
			MB00,
			MB01,
			MB10,
			MB11);
						
--branch_metric(0) <= MB00;
--branch_metric(1) <= MB01;
--branch_metric(2) <= MB10;
--branch_metric(3) <= MB11;

SMU : state_metric_unit
	port map(rst,
	clk,
	enable_dly3,
	MB00,
	MB01,
	MB10,
	MB11,
	decision);
	
survivor_path_unit : survivor_path
	port map(rst, clk, enable_dly3, decision, final_decision);
	
	decoded_bit <= decoded_fifo(10);


    decode_ready <= decode_ready_pipe(28);

end Behavioral;