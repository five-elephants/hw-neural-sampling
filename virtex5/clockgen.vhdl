library ieee;
library unisim;


use ieee.std_logic_1164.all;
use unisim.vcomponents.all;  -- xilinx component declarations


entity clockgen is
  port (
    ext_clk, async_resetb : in std_ulogic;
    clk, sync_reset : out std_ulogic
  ); 
end clockgen;


architecture virtex5 of clockgen is

  ------------------------------------------------------------
  -- local signals
  ------------------------------------------------------------

  signal clk_i : std_ulogic;
  signal locked : std_ulogic;
  signal clock_from_ibufg : std_ulogic;
  signal reset, reset_sync : std_ulogic;
  signal clkfb : std_ulogic;
  signal clk_to_bufg : std_ulogic;
  signal reset_cond : std_ulogic;
begin

  clk <= clk_i;


  ------------------------------------------------------------
  -- clock generation
  ------------------------------------------------------------
 
  clock_pin_ibufg: ibufg
  port map(
    I => ext_clk,
    O => clock_from_ibufg
  );


  ------------------------------------------------------------
  -- reset synchronizer
  ------------------------------------------------------------
  reset_synchronizer: process ( clock_from_ibufg, async_resetb )
  begin
    if async_resetb = '0' then
      reset <= '1';
      reset_sync <= '1';
    elsif rising_edge(clk_i) then
      reset <= reset_sync;
      reset_sync <= '0';
    end if;
  end process;
  ------------------------------------------------------------ 


  ------------------------------------------------------------
  -- PLL
  ------------------------------------------------------------
  
  pll_inst: pll_base
  generic map (
    clkfbout_mult => 1,
    clkout0_divide => 1,
    clkin_period => 10.0 
  )
  port map (
    clkin => clock_from_ibufg,
    rst => reset,
    clkfbout => clkfb,
    clkfbin => clkfb,
    clkout0 => clk_to_bufg,
    clkout1 => open,
    clkout2 => open,
    clkout3 => open,
    clkout4 => open,
    clkout5 => open,
    locked => locked
  );

  gen_clk_bufg: bufg
  port map (
    I => clk_to_bufg,
    O => clk_i
  );


  ------------------------------------------------------------
  -- synchronous reset output
  ------------------------------------------------------------
 
  reset_cond <= not locked or reset;

  ------------------------------------------------------------
  sync_rst_out: process ( clk_i, reset_cond )
  begin
    if reset_cond = '1' then
      sync_reset <= '1';
    elsif rising_edge(clk_i) then
      sync_reset <= '0';
    end if;
  end process;
  ------------------------------------------------------------

end virtex5;
