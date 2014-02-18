library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package sampling is

  constant weight_width : integer := 4;
  constant membrane_width : integer := 16;
  constant lfsr_width : integer := 8;

  subtype lfsr_state_t is std_logic_vector(lfsr_width-1 downto 0);
  subtype membrane_t is signed(membrane_width-1 downto 0);
  subtype weight_t is signed(weight_width-1 downto 0);

  type lfsr_state_array_t is array(positive range <>) of
    lfsr_state_t;

  type state_array_t is array(positive range <>) of
    std_ulogic;

  type phase_t is (
    idle,
    propagate,
    evaluate
  );

end sampling;
