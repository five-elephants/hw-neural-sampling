library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.xor_reduce;

entity lfsr is
  generic (
    width : integer := 8
  );

  port (
    clk, reset : in std_ulogic;
    seed, poly : in std_logic_vector(width-1 downto 0);
    rand_out : out std_logic_vector(width-1 downto 0)
  );
end lfsr;


architecture rtl of lfsr is
  subtype state_t is std_logic_vector(width-1 downto 0);

  signal state : state_t;
begin

  rand_out <= state;

  process ( clk, reset )
    variable taps : state_t;
    variable b : std_logic;
  begin
    if reset = '1' then
      state <= seed;
    elsif rising_edge(clk) then
      taps := state and poly;
      b := xor_reduce(taps);
      state <= state(state'left-1 downto state'right) & b; 
    end if;
  end process;

end rtl;
