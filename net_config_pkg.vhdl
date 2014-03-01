library ieee;

use ieee.std_logic_1164.all;
use work.sampling.all;



package net_config is
  constant tau : positive := 20;
  constant num_samplers : integer := 4;
  constant num_observers : natural := 16;
end net_config; 
