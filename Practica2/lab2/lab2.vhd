---------------------------------------------------------------------
--
--  Fichero:
--    lab2.vhd  14/7/2015
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Laboratorio 2
--
--  Notas de diseño:
--
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity lab2 is
port
(
  rstPb_n     : in  std_logic;

  osc         : in  std_logic;
  startStop_n : in  std_logic;
  clear_n     : in  std_logic;
  lap_n       : in  std_logic;
  leftSegs    : out std_logic_vector(7 downto 0);
  rightSegs   : out std_logic_vector(7 downto 0)
);
end lab2;

---------------------------------------------------------------------

use work.common.all;

architecture syn of lab2 is

  component modCounter
  generic
  (
    MAXVALUE : natural   -- valor maximo alcanzable
  );
  port
  (
    rst_n : in  std_logic;   -- reset asíncrono del sistema (a baja)
    clk   : in  std_logic;   -- reloj del sistema
    clear : in  std_logic;   -- puesta a 0 sincrona
    ce    : in  std_logic;   -- capacitacion de cuenta
    tc    : out std_logic;   -- fin de cuenta
    count : out std_logic_vector(log2(MAXVALUE)-1 downto 0)   -- cuenta
  );
  end component;
  
  signal clk, rst_n : std_logic; -- declaramos las señales para "renombrar" la variable osc y rstPb_n

  signal startStopSync_n, clearSync_n, lapSync_n : std_logic;
  signal startStopDeb_n,  clearDeb_n,  lapDeb_n  : std_logic;
  signal startStopFall,   clearFall,   lapFall   : std_logic;
  
  signal lapTFF, startStopTFF : std_logic; -- las señales que van a ir desde la ultima traduciion de los valor a los biestables T
  
  signal cycleCntTC, decCntTC, secLowCntTC : std_logic;
    
  signal decCnt, secLowCnt : std_logic_vector(3 downto 0); 
  signal secHighCnt        : std_logic_vector(2 downto 0);
    
  signal secLowReg  : std_logic_vector(3 downto 0); 
  signal secHighReg : std_logic_vector(2 downto 0);
  
  signal secLowMux, secHighMux : std_logic_vector(3 downto 0); 

begin


  clk   <= osc;
  rst_n <= rstPb_n;

  startStopSynchronizer : synchronizer
    generic map ( STAGES => 2, INIT => '1' )
    port map ( rst_n => rst_n, clk => clk , x => startStop_n, xSync =>startStopSync_n ); --Faltan 2 campos 

  startStopDebouncer : debouncer
    generic map ( FREQ => 50_000, BOUNCE => 50 )
    port map ( rst_n => rst_n, clk => clk , x_n => startStopSync_n , xdeb_n => startStopDeb_n ); --Aqui tambien faltan dos campos
	 
  startStopEdgeDetector : edgeDetector
    port map ( rst_n => rst_n, clk => clk , x_n => startStopDeb_n ,xFall => startStopFall ,xRise => open );
	 
  --En el clear el numero de STATES = 2 ,pero el INIT es '1' o '0'. Al cargar el clear seguira la misma estructura de starStop
  -- o ha de ser logica inversa de manera que se ejecute cuando clear 0 y starstop 1

  clearSynchronizer : synchronizer  
    generic map ( STAGES => 2, INIT => '1')--¿El valor de inir es correcto?
    port map ( rst_n => rst_n, clk => clk , x => clear_n, xSync => clearSync_n );

  clearDebouncer : debouncer
    generic map ( FREQ => 50_000, BOUNCE => 50 )
    port map ( rst_n => rst_n, clk => clk , x_n => clearSync_n , xdeb_n => clearDeb_n );
	 
  clearEdgeDetector : edgeDetector
    port map ( rst_n => rst_n, clk => clk , x_n => clearDeb_n ,xFall => clearFall ,xRise => open );
	 
	
  lapSynchronizer : synchronizer
    generic map (STAGES => 2, INIT => '1' ) --¿ el valor de init es correcto?
    port map ( rst_n => rst_n, clk => clk , x => lap_n , xSync =>lapSync_n );

  lapDebouncer : debouncer
    generic map ( FREQ => 50_000, BOUNCE => 50 )
    port map (  rst_n => rst_n, clk => clk , x_n => lapSync_n , xdeb_n => lapDeb_n );
	 
  lapEdgeDetector : edgeDetector
    port map ( rst_n => rst_n, clk => clk , x_n => lapDeb_n ,xFall => lapFall ,xRise => open );
  
  ------------------  
  

  toggleFF :
  process (rst_n, clk)
  begin
    if rst_n='0' then
      startStopTFF <= '0';
      lapTFF       <= '0';
    elsif rising_edge(clk) then
      if startStopFall = '1' then  -- si tras filtrar la señal llega un 1 entonces propago ese uno de start
        startStopTFF <= '1';  -- como distingo si envio un star de un stop
      end if;
      if lapFall = '1' then
        lapTFF <= '1';  -- mirar el valor a trasmitir
      end if;
    end if;
  end process;
	
  cycleCounter : modCounter 
    generic map ( MAXVALUE => 5_000_000-1 )
    port map ( ... );
  
  decCounter : modCounter 
    generic map ( MAXVALUE => 9 )
    port map ( ... );
    
  secLowCounter : modCounter 
    generic map ( MAXVALUE => 9 )
    port map ( ... );
	
  secHighCounter : modCounter 
    generic map ( MAXVALUE => 6 )
    port map ( ... );
  
  lapRegister :
  process (rst_n, clk)
  begin
    if rst_n='0' then
      secLowReg  <= ...;
      secHighReg <= ...;
    elsif rising_edge(clk) then
      if ... then
        secLowReg  <= ...;
        secHighReg <= ...;       
      elsif ... then
        secLowReg <= ...;
        secHighReg <= ...;        
      end if;
    end if;
  end process;

  leftConverterMux :
    secHighMux <= ... when ... else ...;
  
  rigthConverterMux :
    secLowMux <= ... when ... else ...;
  
  leftConverter : bin2segs 
    port map ( ... );
  
  rigthConverter : bin2segs 
    port map ( ... );
  
end syn;
