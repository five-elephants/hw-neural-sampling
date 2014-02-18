library IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;

entity hello is
  port (
    clk, reset : in std_ulogic;
    seed, poly : in std_logic_vector(7 downto 0);
    random_out : out std_logic_vector(7 downto 0)
  );
end hello;
    

architecture rtl of hello is
  signal random_out_i : std_logic_vector(7 downto 0);
begin

  process
    variable l : line;
  begin
    write(l, string'("hello world"));
    writeline(output, l);
    wait;
  end process;

end rtl;


    
