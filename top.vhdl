library ieee;

use ieee.std_logic_1164.all;
use work.sampling.all;
use work.net_config.all;


entity top is
  port (
    ext_clk, async_reset : in std_ulogic
  ); 
end top;


architecture rtl of top is

  ------------------------------------------------------------
  -- component declarations
  ------------------------------------------------------------

  component clockgen is
    port (
      ext_clk, async_resetb : in std_ulogic;
      clk, sync_reset : out std_ulogic
    ); 
  end component;


  component sampling_shell is
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
  end component;


  ------------------------------------------------------------
  -- local signals
  ------------------------------------------------------------

  signal clk, reset : std_ulogic;
  signal observed_joints : state_array2_t(1 to num_observers, 1 to num_samplers);
  signal joint_counters : joint_counter_array_t(1 to num_observers);
  signal systime : systime_t;
begin

  ------------------------------------------------------------
  -- support logic
  ------------------------------------------------------------
  
  clkgen: clockgen 
  port map (
    ext_clk => ext_clk,
    clk => clk,
    async_resetb => async_resetb,
    sync_reset => reset
  );


  ------------------------------------------------------------
  -- sampling related stuff
  ------------------------------------------------------------

  sampling: sampling_shell
  generic map (
    num_samplers => num_samplers,
    tau => tau,
    num_observers => num_observers
  )
  port map (
    clk => clk,
    reset => reset,
    observed_joints => observed_joints,
    joint_counters => joint_counters,
    systime => systime
  );


end rtl;
