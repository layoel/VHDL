

-- Descripción de una procesador que ejecuta cuatro instrucciones. 
-- Basado en ejemplo de Hamblen, J.O., Hall T.S., Furman, M.D.:
-- Rapid Prototyping of Digital Systems : SOPC Edition, Springer 2008.
-- (Capítulo 9) 



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY procesador_v0_0 IS
PORT( clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		AC_out : out std_logic_vector(15 downto 0);
		IR_out : out std_logic_vector(15 downto 0);
		PC_out : out std_logic_vector(7 downto 0);
		MEMq : in std_logic_vector(15 downto 0);
		MEMdata: out std_logic_vector(15 downto 0);
		MEMwe : out std_logic;
		MEMadr : out std_logic_vector(7 downto 0)
		);
END procesador_v0_0;

ARCHITECTURE rtl OF procesador_v0_0 IS
	TYPE STATE_TYPE IS ( reset_pc, fetch1, decode, add0, add1, load0, load1, 
								store0, store1, jump);-- estados del procesador
	SIGNAL state: STATE_TYPE;
	SIGNAL IR, AC: STD_LOGIC_VECTOR(15 DOWNTO 0 ); -- son de 16 bit
	SIGNAL PC : STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- ason de 8 bit
	
	BEGIN
	
	
	-- Asignaciones a puertos de salida
	--	 para verlo en los piertos de salida lo q hay en esos registros
	AC_out <= AC;
	IR_out <= IR;
	PC_out <= PC;
	

--maquina de estados finitos datapath MIO
FSMD: PROCESS ( CLOCK, RESET, state, PC, AC, IR )

BEGIN

-- Asignaciones a REGISTROS en datapath y MAQUINA DE ESTADOS de la unidad de control
IF reset = '1' THEN --si reset vale 1
	state <= reset_pc; --estado inicial vale reset pc
	ELSIF clock'EVENT AND clock = '1' THEN -- con el flanco positivo de la señal del reloj cambia el estado 
	--dependiendo de lo que hay en la señal estado decidimos cual será el estado siguiente, van sincronizadas 
	--con el flanco de l reloj, esto hace que quartus2 sepa que IR,PC,AC son registros.
	 CASE state IS   
		WHEN reset_pc => -- si reset pc
			PC	<= "00000000"; -- pone a 0 pc 
			AC <= "0000000000000000"; -- pone a 0 ac
			state <= fetch1; --  da la orden de que quiero leer la instruccion
		
		WHEN fetch1 =>  --
			IR <= MEMq; -- pone a ir lo que hay en memq
			PC <= PC + 1; -- incrementa contador de programa
			state <= decode;	 --  el estado siguiente a fecht1 es el estado decode el 
		WHEN decode =>  -- si decode
			CASE IR( 15 DOWNTO 8 ) IS  --  miro lo q hay en los bit del 15 al 8 que es donde esta el codigo de operacion
				WHEN "00000000" =>  -- si cod op es 00 
					state <= add0;  -- pasa al estado add0
				WHEN "00000001" =>  -- si cod op es 01
					state <= store0;  -- pasa a store0
				WHEN "00000010" =>  -- si es 10
					state <= load0;  -- pasa a load 0
				WHEN "00000011" =>  -- si es 11
					state <= jump;  -- pasa a jump
				WHEN OTHERS =>  -- en cualquier otro caso
					state <= fetch1;  -- va al estado fetch0
			END CASE; 
		WHEN add0 =>   -- si estamos en el estado add0
			state <= add1;  -- pasa al estado add1
		WHEN add1 =>  --
			AC <= AC + MEMq;  -- suma el contenido del acumulador mas lo que hay en la memoria
			state <= fetch1;  --	 pasa al estado siguiente fetch0
		WHEN store0 =>  -- 
			state <= store1; -- pasa al estado store1
		WHEN store1 =>  --
			state <= fetch1;	 --	 sigueinte estado fetch0	
		WHEN load0 =>  --
			state <= load1;	 -- 
		WHEN load1 => --
			AC <= MEMq;  -- lee de la memoria y lo almacena en el acumulador
			state <= fetch1;	 --	 	
		WHEN jump => -- si salto
			PC <= IR( 7 DOWNTO 0 ); -- pasa a la parte mas baja del cod de op
			state <= fetch1;			 -- esado siguiente fetch0
		WHEN OTHERS =>
			state <= fetch1;	
	 END CASE;
	END IF;
	
-- Asignaciones a BUSES de entrada a MEMORIA (Direcciones, Datos y control de escritura)
 
	CASE state IS  -- este no esta sincronizado con el flanco del reloj, aqui da valor a las entradas de memoria
		WHEN Reset_pc => -- es una lectura
			MEMadr <= PC;  -- paso a memadr lo que tenga el contador de programa
			MEMwe <= '0';  -- 
			MEMdata <= (others =>'-');  -- no importa dont care
		WHEN add0 | load0 =>  -- 
			MEMadr <= IR(7 downto 0);  -- lee  de la direccion menos significativa del registro de instruccion 
			MEMwe <= '0';  --
			MEMdata <= (others =>'-');  --
		WHEN store0 =>   --
			MEMadr <= IR(7 downto 0);  --lee  de la direccion menos significativa del registro de instruccion 
			MEMwe <= '1'; --
			MEMdata <= AC; -- lo que hay en el acumulador lo escribimos en memdata
		WHEN add1 | load1 |store1 =>  -- 
			MEMadr <= PC;  -- lee  de la direccion menos significativa del registro de instruccion 
			MEMwe <= '0';  --
			MEMdata <= (others =>'-');  --
		WHEN others =>  --
			MEMadr <= IR(7 downto 0);  --lee  de la direccion menos significativa del registro de instruccion 
			MEMwe <= '0';  --
			MEMdata <= (others =>'-');  --
	end case;
	
END PROCESS;


END rtl;