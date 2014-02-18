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
  constant num_samplers : integer := 2;
  constant num_rngs_per_sampler : integer := 4;

  signal clk, reset : std_ulogic;
  signal state_clamp_mask,
      state_clamp,
      state : state_array_t(1 to num_samplers);
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
    state => state
  );


  ------------------------------------------------------------
  -- stimulus generation
  ------------------------------------------------------------

  stimulus: process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait until rising_edge(clk);

    wait;
  end process;
end behave;
