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
    lfsr_polynomial : lfsr_state_t;
    tau : integer := 20;
    threshold : membrane_t
  );

  port (
    clk, reset : in std_ulogic;
    phase : in phase_t;
    bias : in weight_t;
    sum_in : in signed(integer(ceil(log2(real(num_samplers))))+weight_width-1 downto 0);
    state : out std_ulogic;
    membrane : out membrane_t;
    fire : out std_ulogic;
    seeds : in lfsr_state_array_t(1 to num_rngs)
  );
end sampler;


architecture rtl of sampler is

  subtype sum_in_t is 
    signed(integer(ceil(log2(real(num_samplers))))+weight_width-1 downto 0);

  type state_number_array_t is array(1 to num_rngs) of
      membrane_t;

  subtype zeta_t is integer range 0 to tau;

  signal rng : state_number_array_t;
  signal membrane_i : membrane_t;
  signal rand_off : membrane_t;
  signal zeta : zeta_t;
begin

  membrane <= membrane_i;
  
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

    rng(rng_i) <= resize(
        signed(rand_out(lfsr_use_width-1 downto 0)), 
        rng(rng_i)'length
    );
  end generate gen_rngs;

  ------------------------------------------------------------
  sum_rand_off: process ( rng )
    variable acc : membrane_t;
  begin
    acc := to_signed(0, acc'length);
    for i in rng'range loop
      acc := acc + rng(i);
    end loop;

    rand_off <= shift_left(acc, membrane_fraction-lfsr_fraction);
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  membrane_adder: process(clk, reset)
    variable sum_in_ext : membrane_t;
    variable bias_ext : membrane_t;
  begin
    if reset = '1' then
      membrane_i <= to_signed(0, membrane'length);
    elsif rising_edge(clk) then
      if phase = propagate then
        bias_ext := shift_left(resize(bias, bias_ext'length), membrane_fraction-weight_fraction);
        sum_in_ext := shift_left(resize(sum_in, sum_in_ext'length), membrane_fraction-weight_fraction);
        membrane_i <= sum_in_ext + bias_ext;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  refractory_fsm: process ( clk, reset )
    variable over_thresh : boolean;
  begin
    if reset = '1' then
      zeta <= 0;
      fire <= '0';
    elsif rising_edge(clk) then

      if phase = evaluate then
        over_thresh := membrane_i + rand_off > threshold;
        fire <= '0';

        case zeta is
          when 1 =>
            if over_thresh then
              zeta <= tau;
              fire <= '1';
            else
              zeta <= 0;
            end if;

          when 0 =>
            if over_thresh then
              zeta <= tau;
              fire <= '1';
            end if;

          when others =>
            zeta <= zeta - 1;
        end case;
      end if;

    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  refractory_fsm_output: process ( zeta )
  begin
    if zeta > 0 then
      state <= '1';
    else
      state <= '0';
    end if;
  end process;
  ------------------------------------------------------------
  

end rtl;

    
-- vim: set et fenc=utf-8 ff=unix sts=0 sw=2 ts=2 : --
