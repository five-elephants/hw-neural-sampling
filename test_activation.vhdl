library IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;
use work.sampling.all;


entity test_activation is
end test_activation;


architecture behave of test_activation is
  constant clk_period : time := 10 ns;
  constant num_samplers : integer := 1;
  constant num_rngs_per_sampler : integer := 8;
  constant tau : integer := 20;
  constant threshold : membrane_t := make_fixed(3.0,
      membrane_width-1-membrane_fraction,
      membrane_fraction);

  constant weights : weight_array2_t(1 to num_samplers, 1 to num_samplers) := (
    others => (others => make_fixed(0.0, 2, 1))
  );

  signal clk, reset : std_ulogic;
  signal clock_tick : std_ulogic;
  signal systime : systime_t;
  signal state_clamp_mask,
      state_clamp,
      state : state_array_t(1 to num_samplers);
  signal membranes : membrane_array_t(1 to num_samplers);
  signal fires : std_ulogic_vector(1 to num_samplers);
  signal seeds : lfsr_state_array_t(1 to num_samplers*num_rngs_per_sampler);
  signal biases : weight_array_t(1 to num_samplers);
begin

  clock_generation: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  ------------------------------------------------------------
  -- unit under test
  ------------------------------------------------------------

  uut: entity work.sampling_network
  generic map (
    num_samplers => num_samplers,
    num_rngs_per_sampler => num_rngs_per_sampler,
    tau => tau,
    threshold => threshold
  )
  port map (
    clk => clk,
    reset => reset,
    clock_tick => clock_tick,
    systime => systime,
    state_clamp_mask => state_clamp_mask,
    state_clamp => state_clamp,
    state => state,
    membranes => membranes,
    fires => fires,
    seeds => seeds,
    biases => biases,
    weights => weights
  );


  ------------------------------------------------------------
  -- stimulus generation
  ------------------------------------------------------------

  stimulus: process
    variable l : line;
    variable seed1, seed2 : positive;
    variable rand : real;
    variable int_rand : integer;
    variable test_input : real;
  begin
    biases <= (others => make_fixed(0.0, 2, 1));

    for i in seeds'range loop
      uniform(seed1, seed2, rand);
      int_rand := integer(rand*(2.0**lfsr_width-1.0));
      seeds(i) <= std_logic_vector(to_unsigned(int_rand, seeds(i)'length));
    end loop;

    write(l, string'("biases:"));
    writeline(output, l);
    for i in biases'range loop
      hwrite(l, std_logic_vector(biases(i)));
      writeline(output, l);
    end loop;

    write(l, string'("weights:"));
    writeline(output, l);
    for i in 1 to num_samplers loop
      for j in 1 to num_samplers loop
        hwrite(l, std_logic_vector(weights(i,j)));
        write(l, string'("  "));
      end loop;
      writeline(output, l);
    end loop;


    write(l, string'("threshold: "));
    hwrite(l, std_logic_vector(threshold));
    writeline(output, l);


    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait until rising_edge(clk);

    test_input := -4.0;
    while test_input <= 3.5 loop
      write(l, string'("test_input: "));
      write(l, test_input);

      biases <= (others => make_fixed(test_input, 2, 1));
      write(l, string'(" ("));
      hwrite(l, std_logic_vector(make_fixed(test_input, 2, 1)));
      write(l, string'(")"));

      writeline(output, l);
      wait for 100000*clk_period;
      test_input := test_input + 0.5;
    end loop;

    assert(false)
      report "no error; simulation end"
      severity failure;
  end process;


  ------------------------------------------------------------
  recorder: process
    file f : text open write_mode is "activation_trace";
    variable ln : line;
  begin
    loop
      wait until rising_edge(clock_tick);

      for i in state'range loop
        write(ln, state(i));
        write(ln, string'(" "));
        write(ln, fires(i));
        write(ln, string'(" "));
        hwrite(ln, std_logic_vector(membranes(i)));
        write(ln, string'(" "));
        --hwrite(ln, std_logic_vector(biases(i)));
        --write(ln, string'(" "));
      end loop;

      writeline(f, ln);
    end loop;
  end process;
  ------------------------------------------------------------

end behave;
