----------------------------------------------------------------------------------
-- Company: Politecnico di Milano 
-- Engineer: Alessandro Messori
-- 
-- Create Date: 18.02.2020 16:58:59
-- Module Name: Working Zone - Behavioral
-- Project Name: Logical Nets Project
 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity project_reti_logiche is
Port (
    i_clk : in std_logic;
    i_start : in std_logic;
    i_rst : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector(7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche  is
type state_type is (S0,S1,S2,S3);
signal next_state, current_state: state_type;
signal check : std_logic;
signal i : std_logic_vector(15 downto 0);
begin

    --current_state <= S0;


    state_reg: process(i_clk, i_rst)
    begin
        if i_rst='1' then
            current_state <= S0;
        elsif rising_edge(i_clk) then
            current_state <= next_state;
        end if;
    end process;
    
    
    
    lambda: process(current_state,i_start,i_data)
    begin
        case current_state is
            
            -- Reset State 
            when S0 =>
                check <= '0';
                o_done <= '0';
                o_en <= '1';
                o_we <= '0';
                i <=  "0000000000000000";
                o_address <= std_logic_vector(i);
                o_data <= "00000000";
                if i_start = '1' then
                    next_state <= S1;
                 end if;
            -- Set Initial Values
              
             -- Check if Address is in Working Zone 
            when S1 =>
                o_address <= std_logic_vector(unsigned(i)+1);
                i <= i+1;
                --o_data <= "00000001";
                if check = '1' then 
                    next_state <= S3;
                elsif unsigned(i) < 8 then 
                    next_state <= S1;
                else 
                    next_state <= S2;
                end if;
              
            -- Address not in Working Zone  
            when S2 =>
                o_done <= '1';
                o_we <= '1';
                --o_data <= "00000010";
                o_address <= "0000000000001001";
                next_state <= S2;
            
            -- Address in Working Zone
            when S3 =>
                o_done <= '1';
                o_we <= '1';
                o_address <= "0000000000001001";
                --o_data <= "00000011";
                next_state <= S3;
        end case;
     end process;
    
end Behavioral;


