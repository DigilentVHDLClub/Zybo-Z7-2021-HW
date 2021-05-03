----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Ferenc Damo
-- 
-- Create Date: 03/08/2021 06:03:03 PM
-- Design Name: pwm
-- Module Name: pwm - Behavioral
-- Project Name: pwm
-- Target Devices: Basys 3
-- Tool Versions: 2020.1
-- Description: Pulse with modulator
-- 
-- Dependencies: no dependencies
-- 
-- Revision: A
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm is
    Port ( ck : in STD_LOGIC; --system clock
           duty_set : in STD_LOGIC_VECTOR (7 downto 0); --presettable duty cycle (0..255)/256
           Nfckpwm_set : in STD_LOGIC_VECTOR (7 downto 0);
           --pwm clock division ratio (1..255) (fpwm = fck/(256*(Nfckpwm_set + 1))), Nfckpwm_set>0
           pwm_out : out STD_LOGIC_VECTOR (0 downto 0)--pwm output signal, 1-bit vector for monitoring with ILA
           ); --led pwm output signal
end pwm;

architecture Behavioral of pwm is


signal ckpwm : STD_LOGIC ; --divided pwm clock
signal ckpwm_vector : STD_LOGIC_VECTOR(0 downto 0); -- for ILA
signal cntckdivPWM  : integer range 0 to 255 ; --clock divider/prescaler counter variable
signal cntPWM : integer range 0 to 255; -- pwm modulator counter variable
signal Nfckpwm, duty : integer range 0 to 255; --declare prescaler division ratio and duty cyckle as integers
signal pwm_temp : STD_LOGIC_VECTOR (0 downto 0); -- internal pwm signal needed for ILA

begin

Nfckpwm <= to_integer(unsigned(Nfckpwm_set));
duty <= to_integer(unsigned(duty_set));

ckpwm_vector(0) <= ckpwm;

--pwm clock frequency divider
fckpwm:process(ck)
begin
    if rising_edge(ck) then
        if cntckdivPWM = Nfckpwm then
            cntckdivPWM<=0;
            ckpwm <= '1';
        else
            cntckdivPWM<=cntckdivPWM + 1;
            ckpwm <= '0';
        end if;
    end if;
end process;

--pwm counter with 8-bit
PWMcounter:process(ckpwm)
begin
    if rising_edge(ckpwm) then
        if cntPWM = 255 then
            cntPWM<= 0;
        else cntPWM <= cntPWM + 1;
        end if;
        if cntPWM < duty then
            pwm_out <= "1";
        else
            pwm_out <= "0";
        end if;
    end if;
end process;



end Behavioral;
