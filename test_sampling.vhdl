library IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use work.sampling.all;


entity test_sampling is
end test_sampling;


architecture behave of test_sampling is
  constant clk_period : time := 10 ns;
  constant num_samplers : integer := 4;
  constant num_rngs_per_sampler : integer := 4;

  --constant seeds : lfsr_state_array_t(1 to num_samplers*num_rngs_per_sampler) := (
    --"11111111", "00001111", "11110100", "00001001",
    --"11111111", "00001111", "11110100", "00001001",
    --"11011111", "01001101", "10111000", "01000001",
    --"11011111", "01001101", "10111000", "01000001"
  --);
  constant biases : weight_array_t(1 to num_samplers) := (
    to_signed(0, weight_t'length),
    to_signed(0, weight_t'length),
    to_signed(0, weight_t'length),
    to_signed(0, weight_t'length)
  );
  constant weights : weight_array2_t(1 to num_samplers, 1 to num_samplers) := (
    ( "0000", "0001", "0001", "0001"),
    ( "0001", "0000", "0001", "0001"),
    ( "0001", "0001", "0000", "0001"),
    ( "0001", "0001", "0001", "0000")
  );

  signal clk, reset : std_ulogic;
  signal state_clamp_mask,
      state_clamp,
      state : state_array_t(1 to num_samplers);
  signal seeds : lfsr_state_array_t(1 to num_samplers*num_rngs_per_sampler);
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
    num_rngs_per_sampler => num_rngs_per_sampler 
  )
  port map (
    clk => clk,
    reset => reset,
    state_clamp_mask => state_clamp_mask,
    state_clamp => state_clamp,
    state => state,
    seeds => seeds,
    biases => biases,
    weights => weights
  );


  ------------------------------------------------------------
  -- stimulus generation
  ------------------------------------------------------------

  stimulus: process
    variable l : line;
  begin
    for i in seeds'range loop
      seeds(i) <= std_logic_vector(to_unsigned(i, seeds(i)'length));
    end loop;

    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait until rising_edge(clk);

    loop
      write(l, string'("state: "));
      write(l, std_logic_vector(state));
      writeline(output, l);

      wait until state'event;
    end loop;

    wait;
  end process;
end behave;
