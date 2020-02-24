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
    i_clk     :     in std_logic;
    i_start   :     in std_logic;
    i_rst     :     in std_logic;
    i_data    :     in std_logic_vector(7 downto 0);
    o_address :     out std_logic_vector(15 downto 0);
    o_done    :     out std_logic;
    o_en      :     out std_logic;
    o_we      :     out std_logic;
    o_data    :     out std_logic_vector(7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche  is
type state_type is (S0,S1,S2,S3,S4,S5,S6);
signal next_state, current_state: state_type;
begin


    state_reg: process(i_clk, i_rst)
    begin
        if i_rst='1' then
            current_state <= S0;
        elsif rising_edge(i_clk) then
            current_state <= next_state;
        end if;
    end process;
    
    
    
    lambda: process(current_state,i_start,i_data)
    variable i        :     unsigned(15 downto 0);
    variable addwz    :     unsigned(7 downto 0);
    variable wzNumber :     std_logic_vector(2 downto 0);
    variable wzOffset :     std_logic_vector(3 downto 0);
    begin
        case current_state is
            
            -- Reset State 
            when S0 =>
                o_done <= '0';
                o_en <= '1';
                o_we <= '0';
                o_data <= "00000000";
                i := "0000000000001000";
                addwz := "00000000";
                wzNumber := "000";
                wzOffset := "0000";
                
                
                o_address <= "0000000000001000";  -- wz RAM address
                if i_start = '1' then
                    next_state <= S1;
                 end if;
                 
            -- Read WzAddr Value     
            when S1 =>
                addwz := unsigned(i_data);
                i :=  "0000000000000000";
                o_address <= std_logic_vector(i);
                next_state <= S2;
                
              
             -- Check if Address is in Working Zone 
            when S2 =>
                if i >= 8 then 
                    next_state <= S3;
                elsif addwz >= unsigned(i_data)  and addwz <= (unsigned(i_data)+3) then --address is in current wz
                    next_state <= S4;
                else
                    i := i+1;
                    o_address <= std_logic_vector(i);
                    next_state <= current_state;
                end if;
                    
              
            -- Address not in Working Zone  
            when S3 =>
                o_we <= '1';
                o_data <=  std_logic_vector(addwz);
                o_address <= "0000000000001001";
                next_state <= S5;
            
            -- Address in Working Zone
            when S4 =>
                o_we <= '1';
                -- encode in binary wz number,3 bits
                wzNumber := std_logic_vector(i(2 downto 0));
                
                -- encode in onehot wz offset,4 bits
                if unsigned(i_data+3) = addwz then
                    wzOffset := "1000";
                elsif unsigned(i_data+3) = addwz + 1 then
                    wzOffset := "0100";
                elsif unsigned(i_data+3) = addwz + 2 then
                    wzOffset := "0010";
                elsif unsigned(i_data+3) = addwz + 3 then  
                    wzOffset := "0001";
                end if;
                
                o_data <= '1' & wzNumber & wzOffset;
                o_address <= "0000000000001001";
                next_state <= S5;
                
            -- Final State    
            when S5 => 
                o_done <= '1';
                o_we <= '0';
                o_en <= '0';
                o_address <= "0000000000000000";
                next_state <= S6;
                
            when S6 => 
                if (i_start = '0') then
                    o_done <= '0';
                    next_state <= S0;
                else 
                    next_state <= S6;
                 end if;
                
                

        end case;
     end process;
    
end Behavioral;


