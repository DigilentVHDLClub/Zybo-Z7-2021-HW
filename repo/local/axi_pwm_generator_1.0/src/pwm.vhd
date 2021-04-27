library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; -- convert STD_lOGIC to UNSIGNED

entity pwm is
    Port ( ck : in STD_LOGIC; -- system clock
           duty_set : in STD_LOGIC_VECTOR (7 downto 0); -- presettable duty cycle (0...255)/256
           Nfckpwm_set : in STD_LOGIC_VECTOR (7 downto 0); 
		   -- PWM clock division ratio (1...255) (fpwm=fck/(256*(Nfckpwm_set+1)), Nfckpwm_set>0
           pwm_out : out STD_LOGIC_VECTOR (0 downto 0) -- PWM output signal, declare as 1-bit vector for monitoring with the ILA
          ); 
end pwm;

architecture Behavioral of pwm is


signal ckpwm : STD_LOGIC; -- divided PWM clock
signal ckpwm_vector : STD_LOGIC_VECTOR (0 downto 0); -- 1-bit vector for feeding PWM clock to the ILA probe input
signal cntckdivPWM : integer range 0 to 255; -- clock divider/prescaler counter variable
signal cntPWM : integer range 0 to 255; -- PWM modulator counter variable
signal Nfckpwm,duty : integer range 0 to 255; -- declare prescaler division ratio and duty cycle as integers for easier handling
signal pwm_temp : STD_LOGIC_VECTOR (0 downto 0); -- internal PWM signal needed for reading into ILA instead of OUT port

begin

-- convert division ratio and duty cycle settings to integer
Nfckpwm <= to_integer(unsigned(Nfckpwm_set));
duty <= to_integer(unsigned(duty_set));

--convert single clock to 1-bit vector for feeding into the appropriate ILA probe
ckpwm_vector(0)<=ckpwm;

-- PWM clock frequency divider to set PWM period/frequency
fckpwm: process (ck) 
begin
        if rising_edge(ck) then 
             -- count Nfckpwm states for clock division 
             if cntckdivPWM = Nfckpwm then
                  cntckdivPWM<=0;
                  ckpwm <= '1'; -- assign Carry to the divided output clock
             else
                  cntckdivPWM<=cntckdivPWM+1;
                  ckpwm <= '0';
             end if;       
        end if;       
end process;

-- PWM counter with 8 bits resolution
PWMcounter: process (ckpwm)
begin
        if rising_edge(ckpwm) then
             if cntPWM = 255 then -- cycle end at exactly 256 states --> (0...255)
                  cntPWM <= 0;  
             else
                  cntPWM<=cntPWM+1; 
             end if;
             if cntPWM < duty then -- PWM modulation depending on prescribed duty cycle
                  pwm_temp<="1"; -- set PWM outputs to 1 if prescribed duty cycle not reached
                
             else 
                  pwm_temp<="0"; -- if prescribed duty cycle exceeded, PWM outputs must be 0
                
             end if;                
        end if;        
end process;

-- assign the temporary PWM variable to the actual output port
pwm_out <= pwm_temp;

end Behavioral;
