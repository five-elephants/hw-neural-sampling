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
  constant lookup_width : integer := 4;
  constant lookup_fraction : integer := 1;
  subtype membrane_index_t is unsigned(lookup_width-1 downto 0);
  subtype cmp_t is unsigned(lfsr_use_width-1 downto 0);
  type lookup_t is array(0 to 15) 
      of cmp_t;

  constant sigma_lookup : lookup_t :=
  (
  -- lookup for -u + log tau
   8 => make_ufixed(0.000915, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   9 => make_ufixed(0.001508, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  10 => make_ufixed(0.002483, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  11 => make_ufixed(0.004087, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  12 => make_ufixed(0.006721, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  13 => make_ufixed(0.011033, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  14 => make_ufixed(0.018062, lfsr_use_width-lfsr_fraction, lfsr_fraction),
  15 => make_ufixed(0.029434, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   0 => make_ufixed(0.047619, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   1 => make_ufixed(0.076158, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   2 => make_ufixed(0.119652, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   3 => make_ufixed(0.183063, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   4 => make_ufixed(0.269781, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   5 => make_ufixed(0.378544, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   6 => make_ufixed(0.501067, lfsr_use_width-lfsr_fraction, lfsr_fraction),
   7 => make_ufixed(0.623462, lfsr_use_width-lfsr_fraction, lfsr_fraction)

  -- 4.1
  --16 => make_ufixed(0.000017, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--17 => make_ufixed(0.000028, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--18 => make_ufixed(0.000046, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--19 => make_ufixed(0.000075, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--20 => make_ufixed(0.000124, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--21 => make_ufixed(0.000204, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--22 => make_ufixed(0.000337, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--23 => make_ufixed(0.000555, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--24 => make_ufixed(0.000915, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--25 => make_ufixed(0.001508, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--26 => make_ufixed(0.002483, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--27 => make_ufixed(0.004087, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--28 => make_ufixed(0.006721, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--29 => make_ufixed(0.011033, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--30 => make_ufixed(0.018062, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--31 => make_ufixed(0.029434, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --0 => make_ufixed(0.047619, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --1 => make_ufixed(0.076158, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --2 => make_ufixed(0.119652, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --3 => make_ufixed(0.183063, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --4 => make_ufixed(0.269781, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --5 => make_ufixed(0.378544, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --6 => make_ufixed(0.501067, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --7 => make_ufixed(0.623462, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --8 => make_ufixed(0.731897, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --9 => make_ufixed(0.818210, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--10 => make_ufixed(0.881244, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--11 => make_ufixed(0.924440, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--12 => make_ufixed(0.952767, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--13 => make_ufixed(0.970809, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--14 => make_ufixed(0.982089, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--15 => make_ufixed(0.989059, lfsr_use_width-lfsr_fraction, lfsr_fraction)

  -- 3.2
  --16 => make_ufixed(0.000915, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--17 => make_ufixed(0.001175, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--18 => make_ufixed(0.001508, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--19 => make_ufixed(0.001935, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--20 => make_ufixed(0.002483, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--21 => make_ufixed(0.003186, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--22 => make_ufixed(0.004087, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--23 => make_ufixed(0.005242, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--24 => make_ufixed(0.006721, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--25 => make_ufixed(0.008614, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--26 => make_ufixed(0.011033, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--27 => make_ufixed(0.014123, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--28 => make_ufixed(0.018062, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--29 => make_ufixed(0.023073, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--30 => make_ufixed(0.029434, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--31 => make_ufixed(0.037481, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --0 => make_ufixed(0.047619, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --1 => make_ufixed(0.060328, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --2 => make_ufixed(0.076158, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --3 => make_ufixed(0.095718, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --4 => make_ufixed(0.119652, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --5 => make_ufixed(0.148586, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --6 => make_ufixed(0.183063, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --7 => make_ufixed(0.223440, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --8 => make_ufixed(0.269781, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	 --9 => make_ufixed(0.321752, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--10 => make_ufixed(0.378544, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--11 => make_ufixed(0.438874, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--12 => make_ufixed(0.501067, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--13 => make_ufixed(0.563227, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--14 => make_ufixed(0.623462, lfsr_use_width-lfsr_fraction, lfsr_fraction),
	--15 => make_ufixed(0.680108, lfsr_use_width-lfsr_fraction, lfsr_fraction)
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

  --x <= log_tau - membrane;
  x <= membrane;

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

  --process
    --variable ln : line;
    --variable u : membrane_index_t;
  --begin
    --write(ln, string'("log_tau = "));
    --hwrite(ln, std_logic_vector(log_tau));
    --writeline(output, ln);

    --write(ln, string'("lookup values"));
    --writeline(output, ln);

    --for v in sigma_lookup'range loop
      --write(ln, v);
      --write(ln, string'(" : "));
      --hwrite(ln, std_logic_vector(sigma_lookup(v)));
      --writeline(output, ln);
    --end loop;

    --loop
      --wait until x'event;
      
      --u := unsigned(resize(
          --shift_right(x,
              --membrane_fraction-lookup_fraction
          --),
          --u'length
      --)); 

      --write(ln, string'("x: "));
      --hwrite(ln, std_logic_vector(x));
      --write(ln, string'(" u = "));
      --hwrite(ln, std_logic_vector(u));
      --write(ln, string'(" sigma_lookup(x) = "));
      --hwrite(ln, std_logic_vector(sigma_lookup(to_integer(u))));
      --writeline(output, ln);
    --end loop;

    --wait; 
  --end process;

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
