library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package sampling is

  constant weight_width : integer := 4;
  constant weight_fraction : integer := 1;
  constant membrane_width : integer := 16;
  constant membrane_fraction : integer := 10;
  constant lfsr_width : integer := 16;
  constant lfsr_use_width : integer := 12;
  constant lfsr_fraction : integer := 10;

  subtype systime_t is unsigned(63 downto 0);
  subtype lfsr_state_t is std_logic_vector(lfsr_width-1 downto 0);
  subtype membrane_t is signed(membrane_width-1 downto 0);
  subtype weight_t is signed(weight_width-1 downto 0);

  type lfsr_state_array_t is array(positive range <>) of
    lfsr_state_t;

  type membrane_array_t is array(positive range <>) of
    membrane_t;

  type weight_array_t is array(positive range <>) of
    weight_t;

  type weight_array2_t is array(positive range <>, positive range <>) of
    weight_t;

  type state_array_t is array(positive range <>) of
    std_ulogic;

  type phase_t is (
    idle,
    propagate,
    tick,
    evaluate
  );



  -- 8bit full polynomial
  --constant lfsr_polynomial : lfsr_state_t := "10111000";

  -- 16bit full polynomial
  constant lfsr_polynomial : lfsr_state_t := "1011010000000000";


  function make_fixed(number : real; i_width, f_width : natural)
      return signed;

end sampling;


package body sampling is

  function make_fixed(number : real; i_width, f_width : natural)
      return signed is
    variable rv : signed(i_width+f_width downto 0);
  begin
    rv := to_signed(integer(number * (2.0**f_width) ), i_width+f_width+1);
    return rv;
  end make_fixed;

end sampling;
