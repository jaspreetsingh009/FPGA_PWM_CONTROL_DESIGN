library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_DB_MOD is
generic (
	PWM_DB_COUNT    :  INTEGER RANGE 0 TO 4095       -- Deadband (us)  <= PWM_DB * 2/(Clock Freq in MHz)
);
port ( 
	CLK         	:  IN  STD_LOGIC;		 -- Fclk <- Clock Frequency
	PWM_FREQ_COUNT  :  IN  INTEGER RANGE 0 TO 4095;  -- Switching Freq = Fclk (Hz)/(PWM_FREQ)
	PWM_DUTY_COUNT  :  IN  INTEGER RANGE 0 TO 4095;  -- [0, PWM_FREQ_COUNT] --> [0, 1]
	PWM_EN      	:  IN  STD_LOGIC;
	PWM_LS 	    	:  OUT STD_LOGIC;		 -- PWM Low  Side Output
	PWM_HS      	:  OUT STD_LOGIC		 -- PWM High Side Output
);
end entity PWM_DB_MOD;


architecture PWM_DB_MOD_ARC of PWM_DB_MOD is

signal PWM_LS_T	         :  STD_LOGIC := '0';
signal PWM_HS_T          :  STD_LOGIC := '0';
signal PWM_TICK_COUNT    :  INTEGER RANGE 0 to 4095 := 0;
signal PWM_DUTY_COUNT_T  :  INTEGER RANGE 0 to 4095 := 0;
signal PWM_FREQ_COUNT_T  :  INTEGER RANGE 0 TO 4095 := 4095;

begin
 
 
---------------------------------------------------------
--- 	   	   PWM ENABLE CONTROL 		      ---
---------------------------------------------------------
					
with (PWM_EN) select
	PWM_LS   <=  PWM_LS_T when '1',        -- NO FORCE  --
		     '0'      when others;     -- FORCE LOW --

					
with (PWM_EN) select
	PWM_HS   <=  PWM_HS_T when '1',        -- NO FORCE  --
		     '0'      when others;     -- FORCE LOW --
					

---------------------------------------------------------		
--- 	         PWM INCREMENT COUNTER 	              ---
---------------------------------------------------------

PWM_COUNTER_INC : process(CLK)
begin

	if(rising_edge(CLK)) 
	then
		if(PWM_TICK_COUNT >= PWM_COUNTER_T) 
		then
			--- Update PWM register values ---

			PWM_FREQ_COUNT_T <=  PWM_FREQ_COUNT;
			
			if(PWM_DUTY_COUNT > PWM_FREQ_COUNT) 
			then
				PWM_DUTY_COUNT_T  = 0;
			else
				PWM_DUTY_COUNT_T  <=  PWM_DUTY_COUNT;
			endif;
		
			PWM_TICK_COUNT  <=  0;

		else
			PWM_TICK_COUNT  <=  PWM_TICK_COUNT + 1;		
		end if;
	end if;
	
end process PWM_COUNTER_INC;


---------------------------------------------------------
--- 	         PWM OUT with DEADBAND 		      ---
---------------------------------------------------------

PWM_OUTPUT_DB : process(CLK, PWM_COUNT)
begin

	if(rising_edge(CLK)) 
	then
		if(PWM_TICK_COUNT <= PWM_DB_COUNT) 
		then
			PWM_LS_T <= '0';
		
		elsif(PWM_TICK_COUNT >= PWM_DUTY_COUNT_T - PWM_DB_COUNT) 
		then
			PWM_LS_T <= '0';
		else
			PWM_LS_T <= '1';
		end if;
		
		if(PWM_TICK_COUNT <= PWM_DUTY_COUNT_T + PWM_DB_COUNT) 
		then
			PWM_HS_T <= '0';
			
		elsif(PWM_TICK_COUNT >= PWM_FREQ_COUNT_T - PWM_DB_COUNT) 
		then
			PWM_HS_T <= '0';
		else
			PWM_HS_T <= '1';
		end if;
			
	end if;
		
end process PWM_OUTPUT_DB;

end architecture PWM_DB_MOD_ARC;

