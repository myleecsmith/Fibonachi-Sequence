library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
port (clk, rst, n_eq_0, i_le_n, go : in std_logic;
	  n_en, i_sel, i_en, x_sel, x_en, y_sel, y_en, result_sel, result_en, done : out std_logic
);
end fsm;

architecture bhv of fsm is

type state is (CLEAR, CALCULATE);
signal current, successor : state; 
begin

	process(clk, rst)
	begin
		if(rst = '1') then
			current <= CLEAR;
		elsif(falling_edge(clk)) then
			current <= successor;
		end if;
	end process;

	process(current, go, i_le_n, n_eq_0)
	begin
		case current is
			-- stay in clear until go
			when CLEAR =>
				-- go not set, hold clear
				if(go = '0') then
					successor <= CLEAR;
					n_en  <= '0'; 
					i_sel <= '0'; 
					i_en  <= '0';
					x_sel <= '0'; 
					x_en  <= '0';
					y_sel <= '0';
					y_en  <= '0';
					result_sel <= '0';
					result_en <= '0';
					done <= '0';
				-- go is set, calculate first fibonachi number
				else
					successor <= CALCULATE;
					n_en  <= '1'; 
					i_sel <= '1'; 
					i_en  <= '1';
					x_sel <= '1'; 
					x_en  <= '1';
					y_sel <= '1';
					y_en  <= '1';
					result_sel <= '1';
					result_en <= '0';
					done <= '0';
				end if;
				
			-- begin looping calculations
			-- with checks to finish
			when CALCULATE =>
				-- 0th fibnoachi number, immediatly terminate & output 0.
				if(n_eq_0 = '1') then
					successor <= CLEAR;
					n_en  <= '0'; 
					i_sel <= '0';
					i_en  <= '0';
					x_sel <= '0';
					x_en  <= '0';
					y_sel <= '0';
					y_en  <= '0';
					result_sel <= '1';
					result_en <= '1';
					done  <= '1';
					
				-- looping done, immediatly terminate & output result.
				elsif(i_le_n = '0') then
					successor <= CLEAR;
					n_en  <= '0'; 
					i_sel <= '0';
					i_en  <= '0';
					x_sel <= '0';
					x_en  <= '0';
					y_sel <= '0';
					y_en  <= '0';
					result_sel <= '0';
					result_en <= '1';
					done  <= '1';
					
				-- continue looping
				else 
					successor <= CALCULATE;
					n_en  <= '0'; 
					i_sel <= '0';
					i_en  <= '1';
					x_sel <= '0';
					x_en  <= '1';
					y_sel <= '0';
					y_en  <= '1';
					result_sel <= '0';
					result_en <= '0';
					done  <= '0';
				end if;
		end case;
	end process;
end bhv;
				