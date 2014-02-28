library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sampling.all;


entity sampler is
  generic (
    num_samplers : integer := 8;
    lfsr_polynomial : lfsr_state_t;
    tau : positive := 20
  );

  port (
    clk, reset : in std_ulogic;
    phase : in phase_t;
    bias : in weight_t;
    sum_in : in signed(sum_in_size(num_samplers)-1 downto 0);
    state : out std_ulogic;
    membrane : out membrane_t;
    fire : out std_ulogic;
    seed : in lfsr_state_t
  );
end sampler;


architecture rtl of sampler is

  subtype sum_in_t is 
    signed(sum_in_size(num_samplers)-1 downto 0);

  subtype zeta_t is integer range 0 to tau;

  signal membrane_i : membrane_t;
  signal zeta : zeta_t;
  signal activate : std_ulogic;
begin

  membrane <= membrane_i;
  

  ------------------------------------------------------------
  membrane_adder: process(clk, reset)
    variable sum_in_ext : membrane_t;
    variable bias_ext : membrane_t;
  begin
    if reset = '1' then
      membrane_i <= to_signed(0, membrane'length);
    elsif rising_edge(clk) then
      if phase = propagate then
        bias_ext := shift_left(
            resize(bias, bias_ext'length),
            membrane_fraction-weight_fraction
        );
        sum_in_ext := shift_left(
            resize(sum_in, sum_in_ext'length),
            membrane_fraction-weight_fraction
        );
        membrane_i <= sum_in_ext + bias_ext;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  activation_function: entity work.activation(rtl)
  generic map (
    lfsr_polynomial => lfsr_polynomial
  )
  port map (
    clk => clk,
    reset => reset,
    membrane => membrane_i,
    active => activate,
    seed => seed
  );
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
        over_thresh := (activate = '1');
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

    




architecture behave of sampler is

  subtype sum_in_t is 
    signed(sum_in_size(num_samplers)-1 downto 0);

  subtype zeta_t is integer range 0 to tau;

  signal membrane_i : membrane_t;
  signal zeta : zeta_t;
begin

  membrane <= membrane_i;
  
  ------------------------------------------------------------
  membrane_adder: process(clk, reset)
    variable sum_in_ext : membrane_t;
    variable bias_ext : membrane_t;
  begin
    if reset = '1' then
      membrane_i <= to_signed(0, membrane'length);
    elsif rising_edge(clk) then
      if phase = propagate then
        bias_ext := shift_left(
            resize(bias, bias_ext'length),
            membrane_fraction-weight_fraction
        );
        sum_in_ext := shift_left(
            resize(sum_in, sum_in_ext'length),
            membrane_fraction-weight_fraction
        );
        membrane_i <= sum_in_ext + bias_ext;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  refractory_fsm: process ( clk, reset )
    constant log_tau : real := log(20.0);
    variable seed1, seed2 : positive;
    variable rand : real;
    variable cmp : real;
    variable u : real;

    variable over_thresh : boolean;
  begin
    if reset = '1' then
      zeta <= 0;
      fire <= '0';
      seed1 := to_integer(unsigned(seed));
      seed2 := 1;
    elsif rising_edge(clk) then

      if phase = evaluate then
        uniform(seed1, seed2, rand);
        u := real(to_integer(membrane_i)) / 2.0**membrane_fraction;
        cmp := 1.0 / (1.0 + exp(-u + log_tau));
        over_thresh := rand < cmp;
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
  

end behave;
-- vim: set et fenc=utf-8 ff=unix sts=0 sw=2 ts=2 : --
