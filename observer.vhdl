library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sampling.all;


entity observer is
  generic (
    num_samplers : integer;
    counter_width : positive := 32
  );

  port (
    clk, reset : in std_ulogic;
    state, observe_state : in state_array_t(1 to num_samplers);
    count : out unsigned(counter_width-1 downto 0);
    saturated : out std_ulogic
  ); 
end observer;


architecture rtl of observer is
  subtype counter_t is unsigned(counter_width-1 downto 0);
  signal count_i : counter_t;
begin
  count <= count_i;

  ------------------------------------------------------------
  counter_process: process ( clk, reset )
  begin
    if reset = '1' then
      count_i <= to_unsigned(0, count_i'length);
    elsif rising_edge(clk) then
      if (state = observe_state) and not (count_i = 2**counter_width-1) then
        count_i <= count_i + 1;
      end if;
    end if;
  end process; 
  ------------------------------------------------------------
end rtl;
