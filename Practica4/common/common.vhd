---------------------------------------------------------------------
--
--  Fichero:
--    common.vhd  22/3/2017
--
--    (c) J.M. Mendias
--    Dise�o Autom�tico de Sistemas
--    Facultad de Inform�tica. Universidad Complutense de Madrid
--
--  Prop�sito:
--    Contiene definiciones de constantes, funciones de utilidad
--    y componentes reusables
--
--  Notas de dise�o:
--
---------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

package common is

  constant YES  : std_logic := '1';
  constant NO   : std_logic := '0';
  constant HI   : std_logic := '1';
  constant LO   : std_logic := '0';
  constant ONE  : std_logic := '1';
  constant ZERO : std_logic := '0';
  
  -- Calcula el logaritmo en base-2 de un numero.
  function log2(v : in natural) return natural;
  -- Selecciona un entero entre dos.
  function int_select(s : in boolean; a : in integer; b : in integer) return integer;
  -- Convierte un real en un signed en punto fijo con qn bits enteros y qm bits decimales. 
  function toFix( d: real; qn : natural; qm : natural ) return signed; 
  
  -- Convierte codigo binario a codigo 7-segmentos
  component bin2segs
    port
    (
      -- host side
      bin  : in  std_logic_vector(3 downto 0);   -- codigo binario
      dp   : in  std_logic;                      -- punto
      -- leds side
      segs : out std_logic_vector(7 downto 0)    -- codigo 7-segmentos
    );
  end component;
  
  component debouncer 
  generic(
    FREQ   : natural;  -- frecuencia de operacion en KHz
    BOUNCE : natural   -- tiempo de rebote en ms
  );
  port (
    rst_n  : in  std_logic;   -- reset as�ncrono del sistema (a baja)
    clk    : in  std_logic;   -- reloj del sistema
    x_n    : in  std_logic;   -- entrada binaria a la que deben eliminarse los rebotes (a baja en reposo)
    xdeb_n : out std_logic    -- salida que sique a la entrada pero sin rebotes
  );
  end component;


  component edgeDetector
  port (
    rst_n : in  std_logic;   -- reset as�ncrono del sistema (a baja)
    clk   : in  std_logic;   -- reloj del sistema
    x_n   : in  std_logic;   -- entrada binaria con flancos a detectar (a baja en reposo)
    xFall : out std_logic;   -- se activa durante 1 ciclo cada vez que detecta un flanco de subida en x
    xRise : out std_logic    -- se activa durante 1 ciclo cada vez que detecta un flanco de bajada en x
  );
  end component;
  
  component synchronizer is
  generic (
    STAGES  : in natural;      -- n�mero de biestables del sincronizador
    INIT    : in std_logic     -- valor inicial de los biestables 
  );
  port (
    rst_n : in  std_logic;   -- reset as�ncrono de entrada (a baja)
    clk   : in  std_logic;   -- reloj del sistema
    x     : in  std_logic;   -- entrada binaria a sincronizar
    xSync : out std_logic    -- salida sincronizada que sique a la entrada
  );
  end component;
  
  component frequencySynthesizer is
	generic (
	FREQ     : natural;                 -- frecuencia del reloj de entrada en KHz
	MODE     : string;                  -- modo del sintetizador de frecuencia "LOW" o "HIGH"
	MULTIPLY : natural range 2 to 32;   -- factor por el que multiplicar la frecuencia de entrada 
	DIVIDE   : natural range 1 to 32    -- divisor por el que dividir la frecuencia de entrada
	);
	port (
	clkIn  : in  std_logic;   -- reloj de entrada
	ready  : out std_logic;   -- indica si el reloj de salida es v�lido
	clkOut : out std_logic    -- reloj de salida
	);
  end component;
   
 
end package common;

-------------------------------------------------------------------

package body common is

  function log2(v : in natural) return natural is
    variable n    : natural;
    variable logn : natural;
  begin
    n := 1;
    for i in 0 to 128 loop
      logn := i;
      exit when (n >= v);
      n := n * 2;
    end loop;
    return logn;
  end function log2;
  
  function int_select(s : in boolean; a : in integer; b : in integer) return integer is
  begin
    if s then
      return a;
    else
      return b;
    end if;
    return a;
  end function int_select;
  
  function toFix( d: real; qn : natural; qm : natural ) return signed is 
  begin 
    return to_signed( integer(d*(2.0**qm)), qn+qm );
  end function; 
  
end package body common;
