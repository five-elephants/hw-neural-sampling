library IEEE;

use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;


entity test_lfsr is
end test_lfsr;


architecture behave of test_lfsr is
  constant num_rng : integer := 4;
  constant width : integer := 8;

  type state_array_t is array(1 to num_rng) of
      std_logic_vector(width-1 downto 0);
  subtype state_uns_t is unsigned(width+2-1 downto 0);
  type state_uns_array_t is array(1 to num_rng) of
      state_uns_t;

  constant seeds : state_array_t := (
    1 => "11111111",
    2 => "00001111",
    3 => "11110000",
    4 => "00000001"
  );

  signal clk, reset : std_ulogic;
  signal rand_out : state_array_t;
  signal rng : state_uns_array_t;
  signal sum : state_uns_t;
  signal ctr : integer range 1 to width;
begin

  clock_generation: process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;


  gen_rngs: for rng_i in 1 to num_rng generate 

    uut : entity work.lfsr
    generic map (
      width => width
    )
    port map (
      clk => clk,
      reset => reset,
      seed => seeds(rng_i),
      poly => "10111000",
      rand_out => rand_out(rng_i)
    );

    rng(rng_i) <= "00" & unsigned(rand_out(rng_i));

  end generate gen_rngs;


  process (clk, reset)
  begin
    if reset = '1' then
      ctr <= 1;
    elsif rising_edge(clk) then
      if ctr < width then
        ctr <= ctr + 1;
      else
        ctr <= 1;
      end if;
    end if;
  end process;

  sum <= (rng(1) + rng(2)) + (rng(3) + rng(4)) when ctr = 1
         else sum;

  stimulus: process
    variable l : line;
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait until clk'event and clk = '1';

    write(l, string'("releasing reset"));
    writeline(output, l);


    for i in 0 to 19 loop
      write(l, string'("rand_out = "));
      for rng_i in 1 to num_rng loop
        hwrite(l, rand_out(rng_i));
        write(l, string'("  "));
      end loop;
      write(l, string'("  sum="));
      write(l, std_logic_vector(sum));
      writeline(output, l);
      
      wait until rising_edge(clk);
    end loop;

    wait;
  end process;

end behave;
