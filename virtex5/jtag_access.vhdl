library ieee;
library unisim;

use ieee.std_logic_1164.all;
use unisim.vcomponents.all;
use work.sampling.all;


entity jtag_access is
  generic (
    num_samplers : integer;
    num_observers : natural
  );

  port (
    clk, reset : in std_ulogic;
    joint_counters : in joint_counter_array_t(1 to num_observers);
    systime : in systime_t
  ); 
end jtag_access;


architecture virtex5 of jtag_access is
  constant data_register_width : positive := 
      systime_t'length + (num_observers * joint_counter_width);

  subtype data_register_t is std_ulogic_vector(data_register_width-1 downto 0);

  signal jtag_reset : std_ulogic;
  signal capture : std_ulogic;
  signal shift, tdi, tdo, drck : std_ulogic;
  signal capture_sync_d, capture_sync : std_ulogic;
  signal data_register, data_register_jtag : data_register_t;
begin

  ------------------------------------------------------------
  -- Virtex5 BSCAN instance
  ------------------------------------------------------------
  
  bscan: bscan_virtex5
  generic map (
    jtag_chain => 1
  )
  port map (
    capture => capture,
    drck => drck,
    reset => jtag_reset,
    sel => open,
    shift => shift,
    tdi => tdi,
    update => open,
    tdo => tdo
  );


  ------------------------------------------------------------
  -- data register capturing
  ------------------------------------------------------------
  
  ------------------------------------------------------------
  capture_clk_sync: process ( clk, reset )
  begin
    if reset = '1' then
      capture_sync_d <= '0';
      capture_sync <= '0';
    elsif rising_edge(clk) then
      capture_sync_d <= capture;
      capture_sync <= capture_sync_d;
    end if;
  end process;
  ------------------------------------------------------------
  

  ------------------------------------------------------------
  data_register_flop: process ( clk, reset )
    variable a, b : natural;
  begin
    if reset = '1' then
      data_register <= (others => '0');
    elsif rising_edge(clk) then
      if capture_sync = '1' then
        data_register(systime'left downto systime'right) <= std_ulogic_vector(systime);

        for i in 1 to num_observers loop
          a := systime'length + (i * joint_counter_width) -1;
          b := systime'length + ((i-1) * joint_counter_width);
          data_register(a downto b) <= std_ulogic_vector(joint_counters(i));
        end loop;
      end if;
    end if;
  end process;
  ------------------------------------------------------------


  ------------------------------------------------------------
  -- output mux
  ------------------------------------------------------------
  
  ------------------------------------------------------------
  dr_shifter: process ( drck, jtag_reset )
  begin
    if jtag_reset = '1' then
      tdo <= '0';
      data_register_jtag <= (others => '0');
    elsif rising_edge(drck) then
      if shift = '1' then
        data_register_jtag <= 
            tdi
            & data_register_jtag(data_register_jtag'left downto 1);
        tdo <= data_register_jtag(0);
      else
        data_register_jtag <= data_register;
      end if;
    end if;
  end process;
  ------------------------------------------------------------

end virtex5;
