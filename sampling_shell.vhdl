library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sampling.all;



entity sampling_shell is
  generic (
    num_samplers : integer := 32;
    tau : positive := 20;
    num_observers : natural := 1
  );

  port (
    clk, reset : in std_ulogic;
    observed_joints : in state_array2_t(1 to num_observers, 1 to num_samplers);
    joint_counters : out joint_counter_array_t(1 to num_observers);
    systime : out systime_t
  );
end sampling_shell;
    

architecture rtl of sampling_shell is
  ------------------------------------------------------------
  function init_seeds
      return lfsr_state_array_t is
    variable seed1, seed2 : positive;
    variable rand : real;
    variable int_rand : integer;
    variable rv : lfsr_state_array_t(1 to num_samplers);
  begin
    for i in rv'range loop
      uniform(seed1, seed2, rand);
      int_rand := integer(rand*(2.0**lfsr_width-1.0));
      rv(i) := std_logic_vector(to_unsigned(int_rand, rv(i)'length));
    end loop;

    return rv;
  end function init_seeds;
  ------------------------------------------------------------



  -- TODO initialise constants
  constant seeds : lfsr_state_array_t(1 to num_samplers) := init_seeds;
  constant biases : weight_array_t(1 to num_samplers) := (
    others => make_fixed(0.0, weight_width-weight_fraction-1, weight_fraction)
  );
  constant weights : weight_array2_t(1 to num_samplers, 1 to num_samplers) := (
    others => (
      others => make_fixed(0.0, weight_width-weight_fraction-1, weight_fraction)
    )
  );

  signal state : state_array_t(1 to num_samplers);
begin

  ------------------------------------------------------------
  net: entity work.sampling_network(rtl)
  generic map (
    num_samplers => num_samplers,
    tau => tau
  )
  port map (
    clk => clk,
    reset => reset,
    clock_tick => open,
    systime => systime,
    state => state,
    membranes => open,
    fires => open,
    seeds => seeds,
    biases => biases,
    weights => weights
  );
  ------------------------------------------------------------


  ------------------------------------------------------------
  gen_observers: for observer_i in 1 to num_observers generate
    signal observe_state : state_array_t(1 to num_samplers);
  begin
    ------------------------------------------------------------
    process ( observed_joints )
    begin
      for i in 1 to num_samplers loop
        observe_state(i) <= observed_joints(observer_i, i);
      end loop;
    end process;
    ------------------------------------------------------------

    obs: entity work.observer(rtl)
    generic map (
      num_samplers => num_samplers,
      counter_width => joint_counter_width
    )
    port map (
      clk => clk,
      reset => reset,
      state => state,
      observe_state => observe_state,
      count => joint_counters(observer_i),
      saturated => open
    );
  end generate gen_observers;
  ------------------------------------------------------------


end rtl;


-- vim: set et fenc= ff=unix sts=0 sw=2 ts=2 :
