---------------------------------------------------------------------
--
--  Fichero:
--    vgaInterface.vhd  15/7/2015
--
--    (c) J.M. Mendias
--    Diseño Automático de Sistemas
--    Facultad de Informática. Universidad Complutense de Madrid
--
--  Propósito:
--    Genera las señales de color y sincronismo de un interfaz VGA
--    con resolución 640x420 px
--
--  Notas de diseño:

--    - Para frecuencias a partir de 50 Mhz en multiplos de 25 MHz 
--
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vgaInterface is

  generic(
    FREQ      : natural;  -- frecuencia de operacion en KHz
    SYNCDELAY : natural   -- numero de pixeles a retrasar las señales de sincronismo respecto a las de posición
  );
  port ( 
    -- host side
    rst_n : in  std_logic;   -- reset asíncrono del sistema (a baja)
    clk   : in  std_logic;   -- reloj del sistema
    line  : out std_logic_vector(9 downto 0);   -- numero de linea que se esta barriendo
    pixel : out std_logic_vector(9 downto 0);   -- numero de pixel que se esta barriendo
    R     : in  std_logic_vector(2 downto 0);   -- intensidad roja del pixel que se esta barriendo
    G     : in  std_logic_vector(2 downto 0);   -- intensidad verde del pixel que se esta barriendo
    B     : in  std_logic_vector(2 downto 0);   -- intensidad azul del pixel que se esta barriendo
    -- VGA side
    hSync : out std_logic;   -- sincronizacion horizontal
    vSync : out std_logic;   -- sincronizacion vertical
    RGB   : out std_logic_vector(8 downto 0)   -- canales de color
  );
end vgaInterface;

---------------------------------------------------------------------


library ieee;
use ieee.numeric_std.all;

architecture syn of vgaInterface is
  
  constant CYCLESxPIXEL : natural := FREQ/25_000;
  constant PIXELSxLINE  : natural  := 800; 
  constant LINESxFRAME  : natural  := 525;
  
  signal hSyncInt, vSyncInt : std_logic;


  signal pixelCnt : unsigned(pixel'range);
  signal lineCnt  : unsigned(line'range);
  signal blanking : std_logic;

  

  signal cycleCntTC : std_logic;
  signal pixelCntTC : std_logic;

begin

  cycleCounter:
  process (rst_n, clk)
    variable cycleCnt : natural range 0 to CYCLESxPIXEL-1;
  begin
	cycleCntTC <= '0';
    if rst_n='0' then
      cycleCnt := 0;
    elsif rising_edge(clk) then
      if cycleCnt = (CYCLESxPIXEL-1) then 
			cycleCntTC <= '1';
			cycleCnt := 0;
		else
			cycleCnt := cycleCnt+1;
		end if;
    end if; 
  end process;
  

  pixelCounter:
  process (rst_n, clk)
    variable pixel : natural range 0 to PIXELSxLINE-1;
  begin
    pixelCntTC <= '0';
	 pixelCnt := pixel; -- CORREGIR EL TIPO DE DATO
	 
    if rst_n='0' then
      pixel:= 0;
    elsif rising_edge(clk) then
      if cycleCntTC = '1' then
			if (pixel = PIXELSxLINE-1) then 
				pixelCntTC <= '1';
				pixel := 0;
			else
				pixel := pixel+1;
			end if;
		end if; 
	  end if;
	end process;

  lineCounter:
  process (rst_n, clk)
   variable line : natural range 0 to LINESxFRAME-1;
  begin
	 lineCnt := line;-- CORREGIR EL TIPO DE DATO
	 
    if rst_n='0' then
      line := 0;
    elsif rising_edge(clk) then
		if pixelCntTC = '1' then
			if line = (LINESxFRAME-1) then 
				line := 0;
			else
				line := line+1;
			end if;
		end if; 
	 end if;
	end process;

  pixel <= pixelCnt; -- CORREGIR EL TIPO DE DATO
  line  <= lineCnt; -- CORREGIR EL TIPO DE DATO
  
  hSyncInt <= '0' when (pixelCnt >= 656 and pixelCnt < 752) else '1';
  vSyncInt <= '0' when (lineCnt >= 494 and lineCnt < 496) else '1';     
 
  blanking <= '0' when (pixelCnt >= 640 or lineCnt >=480) else '1';
  
  
  outputRegisters:
  process (rst_n, clk)
  begin
   if rst_n = '0' then
		RGB <=(others =>'0');
	else
		RGB(8)<= R(2)and not(blanking);
		RGB(7)<= R(1)and not(blanking);
		RGB(6)<= R(0)and not(blanking);
		RGB(5)<= G(2)and not(blanking);
		RGB(4)<= G(1)and not(blanking);
		RGB(3)<= G(0)and not(blanking);
		RGB(2)<= B(2)and not(blanking);
		RGB(1)<= B(1)and not(blanking);
		RGB(0)<= B(0)and not(blanking);
	end if;
  end process;
    
end syn;
