library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use work.sampling.all;


entity sampler is
  generic (
    num_rngs : integer := 4;
    num_samplers : integer := 8;
    lfsr_polynomial : lfsr_state_t := "10111000"
  );

  port (
    clk, reset : in std_ulogic;
    phase : in phase_t;
    bias : in weight_t;
    sum_in : in signed(integer(ceil(log2(real(num_samplers))))+weight_width-1 downto 0);
    state : out std_ulogic;
    seeds : in lfsr_state_array_t(1 to num_rngs)
  );
end sampler;


architecture rtl of sampler is
  constant threshold : membrane_t := to_signed(100, membrane_t'length);

  subtype sum_in_t is 
    signed(integer(ceil(log2(real(num_samplers))))+weight_width-1 downto 0);

  type state_number_array_t is array(1 to num_rngs) of
      membrane_t;

  signal rng : state_number_array_t;
  signal membrane : membrane_t;
  signal rand_off : membrane_t;
begin

  
  gen_rngs: for rng_i in 1 to num_rngs generate 
    signal rand_out : lfsr_state_t;
  begin

    ------------------------------------------------------------
    rng_inst: entity work.lfsr
    generic map (
      width => lfsr_width
    )
    port map (
      clk => clk,
      reset => reset,
      seed => seeds(rng_i),
      poly => lfsr_polynomial,
      rand_out => rand_out
    );
    ------------------------------------------------------------

    rng(rng_i) <= resize(signed(rand_out), rng(rng_i)'length);
  end generate gen_rngs;

  ------------------------------------------------------------
  process ( rng )
    variable acc : membrane_t;
  begin
    acc := to_signed(0, acc'length);
    for i in rng'range loop
      acc := acc + rng(i);
    end loop;

    rand_off <= acc;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  membrane_adder: process(clk, reset)
    variable sum_in_ext : membrane_t;
    variable bias_ext : membrane_t;
  begin
    if reset = '1' then
      membrane <= to_signed(0, membrane'length);
    elsif rising_edge(clk) then
      if phase = propagate then
        bias_ext := resize(bias, bias_ext'length);
        sum_in_ext := resize(sum_in, sum_in_ext'length);
        membrane <= sum_in_ext + bias_ext;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  state_detect: process ( clk, reset )
  begin
    if reset = '1' then
      state <= '0';
    elsif rising_edge(clk) then
      if phase = evaluate then
        if membrane + rand_off > threshold then
          state <= '1';
        else
          state <= '0';
        end if;
      end if;
    end if;
  end process;
  ------------------------------------------------------------

end rtl;

    
