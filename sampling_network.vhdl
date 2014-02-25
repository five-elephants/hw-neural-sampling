library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use work.sampling.all;

entity sampling_network is
  generic (
    num_samplers : integer := 1;
    num_rngs_per_sampler : integer := 4;
    tau : integer := 20;
    threshold : membrane_t
  );
  port (
    clk, reset : in std_ulogic;
    clock_tick : out std_ulogic;
    systime : out systime_t;
    state_clamp_mask,
    state_clamp : in state_array_t(1 to num_samplers);
    state : out state_array_t(1 to num_samplers);
    membranes : out membrane_array_t(1 to num_samplers);
    fires : out std_ulogic_vector(1 to num_samplers);
    seeds : in lfsr_state_array_t(1 to num_samplers*num_rngs_per_sampler);
    biases : in weight_array_t(1 to num_samplers);
    weights : in weight_array2_t(1 to num_samplers, 1 to num_samplers)
  );
end sampling_network;


architecture rtl of sampling_network is
  subtype sum_in_t is 
    signed(sum_in_size(num_samplers)-1 downto 0);

  signal phase : phase_t;
  signal do_prop_count : std_ulogic;
  signal prop_ctr : integer range 0 to lfsr_width-1;
  signal state_i : state_array_t(1 to num_samplers);
  signal systime_i : systime_t;
begin


  state <= state_i;
  systime <= systime_i;

  ------------------------------------------------------------
  gen_samplers: for sampler_i in 1 to num_samplers generate
    signal sum_in : sum_in_t;
    signal weight_row : weight_array_t(1 to num_samplers);
  begin

    process ( weights )
    begin
      for i in 1 to num_samplers loop
        weight_row(i) <= weights(sampler_i, i);
      end loop;
    end process;


    summation: entity work.input_sum
    generic map (
      num_samplers => num_samplers 
    )
    port map (
      clk => clk,
      reset => reset,
      phase => phase,
      state => state_i,
      weights => weight_row,
      sum => sum_in
    );


    sampler: entity work.sampler
    generic map (
      num_rngs => num_rngs_per_sampler,
      num_samplers => num_samplers,
      tau => tau,
      threshold => threshold,
      lfsr_polynomial => lfsr_polynomial
    )
    port map (
      clk => clk,
      reset => reset,
      phase => phase,
      bias => biases(sampler_i),
      sum_in => sum_in,
      state => state_i(sampler_i),
      membrane => membranes(sampler_i),
      fire => fires(sampler_i),
      seeds => seeds((sampler_i-1)*num_rngs_per_sampler+1 to sampler_i*num_rngs_per_sampler)
    );

  end generate gen_samplers;
  ------------------------------------------------------------

  ------------------------------------------------------------
  count_propagation: process ( clk, reset )
  begin
    if reset = '1' then
      prop_ctr <= 0;
    elsif rising_edge(clk) then
      if do_prop_count = '1' then
        if prop_ctr < lfsr_width-1 then
          prop_ctr <= prop_ctr + 1;
        else
          prop_ctr <= 0;
        end if;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  phase_fsm_transitions: process ( clk, reset )
  begin
    if reset = '1' then
      phase <= idle;
    elsif rising_edge(clk) then
      case phase is
        when idle =>
          phase <= propagate;

        when propagate =>
          if prop_ctr = lfsr_width-2 then
            phase <= tick;
          end if;

        when tick =>
          phase <= evaluate;

        when evaluate =>
          phase <= propagate;
      end case;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  phase_fsm_output: process (phase)
  begin
    --default assignments
    do_prop_count <= '0';
    clock_tick <= '0';

    case phase is
      when propagate =>
        do_prop_count <= '1';

      when tick =>
        clock_tick <= '1';

      when others =>
    end case;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  systime_counter: process ( clk, reset )
  begin
    if reset = '1' then
      systime_i <= to_unsigned(0, systime_i'length);
    elsif rising_edge(clk) then
      if phase = tick then
        systime_i <= systime_i + to_unsigned(1, systime_i'length);
      end if;
    end if;
  end process;
  ------------------------------------------------------------

end rtl;
