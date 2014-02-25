library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sampling.all;


entity input_sum is
  generic (
    num_samplers : integer := 1
  );
  port (
    clk, reset : in std_ulogic;
    phase : in phase_t;
    state : in state_array_t(1 to num_samplers);
    weights : in weight_array_t(1 to num_samplers);
    sum : out signed(sum_in_size(num_samplers)-1 downto 0)
  );
end input_sum;


architecture rtl of input_sum is
  subtype sum_in_t is 
    signed(sum_in_size(num_samplers)-1 downto 0);
begin
  
  ------------------------------------------------------------
  summation: process ( state, weights )
    variable acc : sum_in_t;
  begin
    acc := to_signed(0, acc'length);
    for i in 1 to num_samplers loop
      if state(i) = '1' then
        acc := acc + resize(weights(i), acc'length);
      end if;
    end loop;

    sum <= acc;
  end process;
  ------------------------------------------------------------

end rtl;
