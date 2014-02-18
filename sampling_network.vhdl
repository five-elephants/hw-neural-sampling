library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use work.sampling.all;

entity sampling_network is
  generic (
    num_samplers : integer := 1;
    num_rngs_per_sampler : integer := 4
  );
  port (
    clk, reset : in std_ulogic;
    state_clamp_mask,
    state_clamp : in state_array_t(1 to num_samplers);
    state : out state_array_t(1 to num_samplers)
  );
end sampling_network;


architecture rtl of sampling_network is
  constant fanin : integer := num_samplers -1;

  subtype sum_in_t is 
    signed(integer(ceil(log2(real(fanin))))+weight_width-1 downto 0);

  signal phase : phase_t;
  signal do_prop_count : std_ulogic;
  signal prop_ctr : integer range 0 to lfsr_width-1;
begin

  ------------------------------------------------------------
  sampler: entity work.sampler
  generic map (
    num_rngs => num_rngs_per_sampler,
    fanin => fanin
  )
  port map (
    clk => clk,
    reset => reset,
    phase => phase,
    bias => to_signed(0, weight_t'length),
    sum_in => to_signed(0, sum_in_t'length),
    state => state(1)
  );
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
          if prop_ctr = lfsr_width-1 then
            phase <= evaluate;
          end if;

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

    case phase is
      when propagate =>
        do_prop_count <= '1';

      when others =>
    end case;
  end process;
  ------------------------------------------------------------

end rtl;
