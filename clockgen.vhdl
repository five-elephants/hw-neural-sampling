library ieee;


use ieee.std_logic_1164.all;


entity clockgen is
  port (
    ext_clk, async_resetb : in std_ulogic;
    clk, sync_reset : out std_ulogic
  ); 
end clockgen;
