----------------------------------------------------------------------------------
-- Company: ENSEIRB-MATMECA
-- Designer: Camille Leroux
-- Generation Date:   Aug 29, 2012
-- Design Name: Viterbi_codec
-- Module Name: state_metric   
-- Description: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.definition_pkg.all;

entity state_metric_unit is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			MB_00 : in std_logic_vector(3 downto 0);
			MB_01 : in std_logic_vector(3 downto 0);
			MB_10 : in std_logic_vector(3 downto 0);
			MB_11 : in std_logic_vector(3 downto 0);
			decision : out std_logic_vector(7 downto 0));
end state_metric_unit;

architecture Behavioral of state_metric_unit is

component ACS is
	port(	rst : in std_logic;
			clk : in std_logic;
			enable : in std_logic;
			MB_0 : in std_logic_vector(3 downto 0);
			MB_1 : in std_logic_vector(3 downto 0);
			MN_0 : in std_logic_vector(7 downto 0);
			MN_1 : in std_logic_vector(7 downto 0);
			MN_out : out std_logic_vector(7 downto 0);
			decision : out std_logic);
end component;

signal state_metric_tmp, state_metric_loopback : state_metric_array;

begin

ACS0 : ACS port map(rst,clk,enable,MB_00,MB_11,state_metric_loopback(0),state_metric_loopback(1),state_metric_tmp(0),decision(0));
ACS1 : ACS port map(rst,clk,enable,MB_01,MB_10,state_metric_loopback(2),state_metric_loopback(3),state_metric_tmp(1),decision(1));
ACS2 : ACS port map(rst,clk,enable,MB_10,MB_01,state_metric_loopback(4),state_metric_loopback(5),state_metric_tmp(2),decision(2));
ACS3 : ACS port map(rst,clk,enable,MB_11,MB_00,state_metric_loopback(6),state_metric_loopback(7),state_metric_tmp(3),decision(3));
ACS4 : ACS port map(rst,clk,enable,MB_11,MB_00,state_metric_loopback(0),state_metric_loopback(1),state_metric_tmp(4),decision(4));
ACS5 : ACS port map(rst,clk,enable,MB_10,MB_01,state_metric_loopback(2),state_metric_loopback(3),state_metric_tmp(5),decision(5));
ACS6 : ACS port map(rst,clk,enable,MB_01,MB_10,state_metric_loopback(4),state_metric_loopback(5),state_metric_tmp(6),decision(6));
ACS7 : ACS port map(rst,clk,enable,MB_00,MB_11,state_metric_loopback(6),state_metric_loopback(7),state_metric_tmp(7),decision(7));

state_metric_loopback(0)(6 downto 0) <= state_metric_tmp(0)(6 downto 0);
state_metric_loopback(1)(6 downto 0) <= state_metric_tmp(1)(6 downto 0);
state_metric_loopback(2)(6 downto 0) <= state_metric_tmp(2)(6 downto 0);
state_metric_loopback(3)(6 downto 0) <= state_metric_tmp(3)(6 downto 0);
state_metric_loopback(4)(6 downto 0) <= state_metric_tmp(4)(6 downto 0);
state_metric_loopback(5)(6 downto 0) <= state_metric_tmp(5)(6 downto 0);
state_metric_loopback(6)(6 downto 0) <= state_metric_tmp(6)(6 downto 0);
state_metric_loopback(7)(6 downto 0) <= state_metric_tmp(7)(6 downto 0);

process(state_metric_tmp)
begin
if(state_metric_tmp(0)(7) = '1' and state_metric_tmp(1)(7) = '1' and state_metric_tmp(2)(7) = '1' and state_metric_tmp(3)(7) = '1' and state_metric_tmp(4)(7) = '1' and state_metric_tmp(5)(7) = '1' and state_metric_tmp(6)(7) = '1' and state_metric_tmp(7)(7) = '1') then
state_metric_loopback(0)(7) <= '0';
state_metric_loopback(1)(7) <= '0';
state_metric_loopback(2)(7) <= '0';
state_metric_loopback(3)(7) <= '0';
state_metric_loopback(4)(7) <= '0';
state_metric_loopback(5)(7) <= '0';
state_metric_loopback(6)(7) <= '0';
state_metric_loopback(7)(7) <= '0';
else
state_metric_loopback(0)(7) <= state_metric_tmp(0)(7);
state_metric_loopback(1)(7) <= state_metric_tmp(1)(7);
state_metric_loopback(2)(7) <= state_metric_tmp(2)(7);
state_metric_loopback(3)(7) <= state_metric_tmp(3)(7);
state_metric_loopback(4)(7) <= state_metric_tmp(4)(7);
state_metric_loopback(5)(7) <= state_metric_tmp(5)(7);
state_metric_loopback(6)(7) <= state_metric_tmp(6)(7);
state_metric_loopback(7)(7) <= state_metric_tmp(7)(7);
end if;

end process;

end Behavioral;

