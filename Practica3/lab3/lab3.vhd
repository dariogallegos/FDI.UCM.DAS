---------------------------------------------------------------------
--
--  Fichero:
--    lab3.vhd  15/7/2015
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 3
--
--  Notas de diseño:
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lab3 is
port
(
  rstPb_n    : in  std_logic;
  osc        : in  std_logic;
  enter_n    : in  std_logic;
  switches_n : in  std_logic_vector(7 downto 0);
  leds       : out std_logic_vector(7 downto 0);
  upSegs     : out std_logic_vector(7 downto 0)
);
end lab3;

---------------------------------------------------------------------

use work.common.all;

architecture syn of lab3 is

  signal clk, rst_n : std_logic; --señales de reloj y reset
  signal ready, rstInit_n : std_logic;
  
  signal enterSync_n, enterDeb_n, enterFall : std_logic;
  signal switchesSync_n : std_logic_vector(7 downto 0);
  signal ldCode, eq, lock : std_logic;
  signal code : std_logic_vector(7 downto 0);
  signal tries : std_logic_vector(3 downto 0);
    
begin

  rstInit_n <= rstPb_n and ready;
  
  resetSyncronizer : synchronizer
    generic map ( STAGES => 2, INIT => '0' )
    port map ( rst_n => rstInit_n, clk => clk, x => '1', xSync => rst_n );
  
  clkGenerator : frequencySynthesizer
    generic map ( FREQ => 50_000, MODE => "LOW", MULTIPLY => 3, DIVIDE => 5 )
    port map ( clkIn => osc,ready =>ready , clkOut => clk);

  ------------------

  enterSynchronizer : synchronizer
    generic map ( STAGES => 2, INIT => 1 )
    port map ( rst_n => rst_n, clk => clk, x => enter_n ,xSync => enterSync_n);
   
  enterDebouncer : debouncer
    generic map ( FREQ => 30_000, BOUNCE => 50 )
    port map ( rst_n => rst_n, clk => clk, x_n => enterSync_n ,xdeb_n => enterDeb_n );
   
  enterEdgeDetector : edgeDetector
    port map ( rst_n => rst_n, clk => clk, x_n => enterDeb_n ,xFall=> enterFall,xRise =>open);
  -------------------
  
  switchesSynchronizer : 
  for i in switches_n'range generate
  begin
    switchsynchronizer : synchronizer
      generic map ( STAGES => 2, INIT => 1 )
      port map ( rst_n => rst_n, clk => clk, x => switches_n  ,xSync => switchesSync_n );
  end generate;

  ------------------

  fsm:
  process (rst_n, clk, enterFall)
    type states is (initial, S3, S2, S1, S0); 
    variable state: states;
  begin 
    if ... then
      ldCode <= ...;
    ...
    end if;
    case state is
      when initial =>
        tries <= ...;
        lock  <= ...;
    ...
    end case;
	 ----- arriba logia de estados y abajo la secuencial
    if rst_n='0' then
      state := ...;
    elsif rising_edge(clk) then
      case state is
        when initial =>
        ...
      end case;
    end if;
  end process;  

  codeRegister :
  process (rst_n, clk)
  begin
	code <= (others=>'0');
	if rst_n = '0' then 
		code <=(others=>'0');
	elsif rising_edge(clk) then
		if ldCode = '1' then
			code <= switchesSync_n;
  end process;
  
  comparator:
  eq <= '1' when (switchesSync_n = code ) else '0'; -- comparador '=' con un multiplexor 
    
  rigthConverter : bin2segs 
    port map( bin => tries , dp => '0', segs =>upSegs);
  
  leds <= std_logic_vector((others =>'0')&lock); -- si no meter 7 ceros antes del lock "0000000"

end syn;
