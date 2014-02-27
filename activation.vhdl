library ieee;

use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sampling.all;

entity activation is
  generic (
    num_points : positive := 8;
    lfsr_polynomial : lfsr_state_t;
    tau : real := 20.0
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








architecture rtl of activation is
  subtype membrane_index_t is unsigned(3 downto 0);
  subtype cmp_t is unsigned(lfsr_use_width-1 downto 0);
  type lookup_t is array(0 to 15) 
      of cmp_t;

  constant lookup_fraction : integer := 1;
  constant sigma_lookup : lookup_t :=
  (
  -- centered points
    8 => make_ufixed(0.977023, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    9 => make_ufixed(0.962673, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    10 => make_ufixed(0.939913, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    11 => make_ufixed(0.904651, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    12 => make_ufixed(0.851953, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    13 => make_ufixed(0.777300, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    14 => make_ufixed(0.679179, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    15 => make_ufixed(0.562177, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    0 => make_ufixed(0.437823, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    1 => make_ufixed(0.320821, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    2 => make_ufixed(0.222700, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    3 => make_ufixed(0.148047, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    4 => make_ufixed(0.095349, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    5 => make_ufixed(0.060087, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    6 => make_ufixed(0.037327, lfsr_use_width-lfsr_fraction, lfsr_fraction),
    7 => make_ufixed(0.022977, lfsr_use_width-lfsr_fraction, lfsr_fraction)

  -- left anchored points
   --8 => make_ufixed(0.982014, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --9 => make_ufixed(0.970688, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--10 => make_ufixed(0.952574, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--11 => make_ufixed(0.924142, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--12 => make_ufixed(0.880797, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--13 => make_ufixed(0.817574, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--14 => make_ufixed(0.731059, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--15 => make_ufixed(0.622459, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --0 => make_ufixed(0.500000, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --1 => make_ufixed(0.377541, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --2 => make_ufixed(0.268941, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --3 => make_ufixed(0.182426, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --4 => make_ufixed(0.119203, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --5 => make_ufixed(0.075858, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --6 => make_ufixed(0.047426, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --7 => make_ufixed(0.029312, lfsr_use_width-lfsr_fraction, lfsr_fraction)
  );
  constant membrane_min : membrane_t := make_fixed(-4.0,
      membrane_width-membrane_fraction-1,
      membrane_fraction
  );
  constant membrane_max : membrane_t := make_fixed(3.5,
      membrane_width-membrane_fraction-1,
      membrane_fraction
  );
  constant log_tau : membrane_t := make_fixed(log(tau),
      membrane_width-membrane_fraction-1,
      membrane_fraction
  );

  signal x: membrane_t;
  signal rng_out : lfsr_state_t;
begin

  x <= log_tau - membrane;

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

  process
    variable ln : line;
    variable u : membrane_index_t;
  begin
    write(ln, string'("log_tau = "));
    hwrite(ln, std_logic_vector(log_tau));
    writeline(output, ln);

    write(ln, string'("lookup values"));
    writeline(output, ln);

    for v in sigma_lookup'range loop
      write(ln, v);
      write(ln, string'(" : "));
      hwrite(ln, std_logic_vector(sigma_lookup(v)));
      writeline(output, ln);
    end loop;

    loop
      wait until x'event;
      
      u := unsigned(resize(
          shift_right(x,
              membrane_fraction-lookup_fraction
          ),
          u'length
      )); 

      write(ln, string'("x: "));
      hwrite(ln, std_logic_vector(x));
      write(ln, string'(" u = "));
      hwrite(ln, std_logic_vector(u));
      write(ln, string'(" sigma_lookup(x) = "));
      hwrite(ln, std_logic_vector(sigma_lookup(to_integer(u))));
      writeline(output, ln);
    end loop;

    wait; 
  end process;

  ------------------------------------------------------------
  process ( x, rng_out )
    variable u : membrane_index_t;
    variable rand, cmp : cmp_t;
  begin
    if x < membrane_min then
      active <= '1';
    elsif x > membrane_max then
      active <= '0';
    else
      u := unsigned(resize(
          shift_right(x,
              membrane_fraction-lookup_fraction
          ),
          u'length
      )); 
      rand := resize(unsigned(rng_out), rand'length);
      cmp := sigma_lookup(to_integer(u));

      if rand(lfsr_fraction-1 downto 0) < cmp(lfsr_fraction-1 downto 0) then
        active <= '1';
      else
        active <= '0';
      end if;
    end if;
  end process;
  ------------------------------------------------------------
  

end rtl;
