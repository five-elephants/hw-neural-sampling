library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_misc.xor_reduce;
use ieee.numeric_std.all;
use ieee.math_real.all;

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



architecture behave of lfsr is
  subtype state_t is std_logic_vector(width-1 downto 0);

  signal state : state_t;
begin

  rand_out <= state;

  process ( clk, reset )
    variable seed1, seed2 : positive;
    variable rand : real;
    variable int_rand : integer;
  begin
    if reset = '1' then
      state <= seed;
      seed1 := to_integer(unsigned(seed));
      seed2 := 1234;
    elsif rising_edge(clk) then
      uniform(seed1, seed2, rand);
      int_rand := integer(rand * (2.0**width-1.0));
      state <= std_logic_vector(
          to_unsigned(int_rand, state'length)
      );
    end if;
  end process;


end behave;

