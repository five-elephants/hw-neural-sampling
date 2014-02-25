library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sampling.all;

entity activation is
  generic (
    num_points : positive := 8;
    lfsr_polynomial : lfsr_state_t
  );

  port (
    clk, reset : in std_ulogic;
    membrane : in membrane_t;
    active : out std_ulogic;
    seed : in lfsr_state_t
  );
end activation;


architecture behave of activation is
  signal rng_out : lfsr_state_t;
begin

  ------------------------------------------------------------
  rng: entity work.lfsr(rtl)
  generic map(
    width => lfsr_width
  )
  port map (
    clk => clk,
    reset => reset,
    seed => seed,
    poly => lfsr_polynomial,
    rand_out => rng_out
  );
  ------------------------------------------------------------


  ------------------------------------------------------------
  process ( membrane, rng_out )
    variable u, rand, cmp : real;
  begin
    u := real(to_integer(membrane)) / 2.0 ** membrane_fraction;
    rand := real(to_integer(unsigned(rng_out))) / 2.0 ** lfsr_width;
    cmp := 1.0 / (1.0 + exp(-u + log(20.0)));

    if rand < cmp then
      active <= '1';
    else
      active <= '0';
    end if;
  end process;
  ------------------------------------------------------------
  

end behave;
