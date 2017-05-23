library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_DB_MOD is
generic (
	PWM_DB      :  INTEGER RANGE 0 TO 4095
);
port ( 
	CLK         :  IN  STD_LOGIC;
	PWM_FREQ 	:  IN  INTEGER RANGE 0 TO 4095;
	PWM_DUTY    :  IN  INTEGER RANGE 0 TO 4095;
	PWM_EN      :  IN  STD_LOGIC;
	PWM_A 		:  OUT STD_LOGIC;
	PWM_B		   :  OUT STD_LOGIC
);
end entity PWM_DB_MOD;


architecture PWM_DB_MOD_ARC of PWM_DB_MOD is

signal PWM_A_T		  	 :  STD_LOGIC := '0';
signal PWM_B_T        :  STD_LOGIC := '0';
signal PWM_COUNT      :  INTEGER RANGE 0 to 4095 := 0;
signal PWM_DUTY_T     :  INTEGER RANGE 0 to 4095 := 0;
signal PWM_COUNTER_T  :  INTEGER RANGE 0 TO 4095 := 4095;

begin
 
 
---------------------------------------------------------
--- 			      PWM ENABLE CONTROL 				      ---
---------------------------------------------------------
					
with (PWM_EN) select
	PWM_A   <=  PWM_A_T when '1',         -- NO FORCE  --
					'0'     when others;      -- FORCE LOW --

					
with (PWM_EN) select
	PWM_B   <=  PWM_B_T when '1',         -- NO FORCE   --
					'0'     when others;      -- FORCE LOW --
					

---------------------------------------------------------		
--- 			     PWM INCREMENT COUNTER 				   ---
---------------------------------------------------------

PWM_COUNTER_INC : process(CLK)
begin

	if(rising_edge(CLK)) 
	then
		if(PWM_COUNT >= PWM_COUNTER_T) 
		then

			--- Update PWM register values ---

			PWM_COUNTER_T <=  PWM_FREQ;
			PWM_DUTY_T    <=  PWM_DUTY;
			PWM_COUNT     <=  0;
			
		else
			PWM_COUNT 	  <=  PWM_COUNT + 1;		
		end if;

	end if;
	
end process PWM_COUNTER_INC;


---------------------------------------------------------
--- 			     PWM OUT with DEADBAND 			      ---
---------------------------------------------------------

PWM_OUTPUT_DB : process(CLK, PWM_COUNT)
begin

	if(rising_edge(CLK)) 
	then
		if(PWM_COUNT <= PWM_DB) 
		then
			PWM_A_T <= '0';
		elsif(PWM_COUNT >= PWM_DUTY_T - PWM_DB) 
		then
			PWM_A_T <= '0';
		else
			PWM_A_T <= '1';
		end if;
		
		if(PWM_COUNT <= PWM_DUTY_T + PWM_DB) 
		then
			PWM_B_T <= '0';
		elsif(PWM_COUNT >= PWM_COUNTER_T - PWM_DB) 
		then
			PWM_B_T <= '0';
		else
			PWM_B_T <= '1';
		end if;

	end if;
		
end process PWM_OUTPUT_DB;

end architecture PWM_DB_MOD_ARC;

