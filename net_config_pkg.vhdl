library ieee;

use ieee.std_logic_1164.all;
use work.sampling.all;



package net_config is
  constant tau : positive := 20;
  constant num_samplers : integer := 4;
  constant num_observers : natural := 16;

  constant seeds : lfsr_state_array_t(1 to num_samplers) := (others => (others => '1'));
  --constant biases : weight_array_t(1 to num_samplers) := (
    --others => make_fixed(0.0, weight_width-weight_fraction-1, weight_fraction)
  --);
  --constant weights : weight_array2_t(1 to num_samplers, 1 to num_samplers) := (
    --others => (
      --others => make_fixed(0.0, weight_width-weight_fraction-1, weight_fraction)
    --)
  --);

  constant biases : weight_array_t(1 to num_samplers) := (
    make_fixed(-1.0, 2, 1),
    make_fixed(-0.5, 2, 1),
    make_fixed(-2.0, 2, 1),
    make_fixed(-1.5, 2, 1)
  );
  constant weights : weight_array2_t(1 to num_samplers, 1 to num_samplers) := (
    (make_fixed(0.0, 2, 1), make_fixed(1.5, 2, 1), make_fixed(1.0, 2, 1), make_fixed(-1.0, 2, 1)),
    (make_fixed(1.5, 2, 1), make_fixed(0.0, 2, 1), make_fixed(1.0, 2, 1), make_fixed(-1.0, 2, 1)),
    (make_fixed(1.0, 2, 1), make_fixed(1.0, 2, 1), make_fixed(0.0, 2, 1), make_fixed(0.5, 2, 1)),
    (make_fixed(-1.0, 2, 1), make_fixed(-1.0, 2, 1), make_fixed(0.5, 2, 1), make_fixed(0.0, 2, 1))
  );
  constant observed_joints : state_array2_t(1 to num_observers, 1 to num_samplers) := (
    ( '0', '0', '0', '0' ),
    ( '0', '0', '0', '1' ),
    ( '0', '0', '1', '0' ),
    ( '0', '0', '1', '1' ),
    ( '0', '1', '0', '0' ),
    ( '0', '1', '0', '1' ),
    ( '0', '1', '1', '0' ),
    ( '0', '1', '1', '1' ),
    ( '1', '0', '0', '0' ),
    ( '1', '0', '0', '1' ),
    ( '1', '0', '1', '0' ),
    ( '1', '0', '1', '1' ),
    ( '1', '1', '0', '0' ),
    ( '1', '1', '0', '1' ),
    ( '1', '1', '1', '0' ),
    ( '1', '1', '1', '1' )
  );
end net_config; 


-- vim: set et fenc= ff=unix sts=0 sw=2 ts=2 : --
