library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fib_tb is
end fib_tb;

architecture tb of fib_tb is   
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal go : std_logic := '0';
	signal n: std_logic_vector(5 downto 0);
	signal result : std_logic_vector(23 downto 0);
	signal done : std_logic;
	
	signal n_en       : std_logic;
    signal result_en  : std_logic;
    signal result_sel : std_logic;
    signal x_en       : std_logic;
    signal x_sel      : std_logic;
    signal y_en       : std_logic;
    signal y_sel      : std_logic;
    signal i_en       : std_logic;
    signal i_sel      : std_logic;
    signal n_eq_0     : std_logic;
    signal i_le_n     : std_logic;
	
	-- recursive function to calculate the Nth fibonacci number
	-- used to compare to the output of the fibonacci calculator
	function fibonacci_value(n: integer) return integer is
    begin
        if n = 0 then
            return 0;
        elsif n = 1 then
            return 1;
        else
            return fibonacci_value(n-1) + fibonacci_value(n-2);
        end if;
    end fibonacci_value;
	
begin
	DATAPATH : entity work.datapath 
		port map (
			clk => clk,
			rst => rst,
			n => n,
			result => result,
			n_en => n_en,
			result_en => result_en,
			result_sel => result_sel,
			x_en => x_en,
			x_sel => x_sel,
			y_en => y_en,
			y_sel => y_sel,
			i_en => i_en,
			i_sel => i_sel,
			n_eq_0 => n_eq_0,
			i_le_n => i_le_n
	);
	
	FSM : entity work.fsm 
		port map (
			clk => clk,
			rst => rst,
			go => go,
			done => done,
			n_en => n_en,
			result_en => result_en,
			result_sel => result_sel,
			x_en => x_en,
			x_sel => x_sel,
			y_en => y_en,
			y_sel => y_sel,
			i_en => i_en,
			i_sel => i_sel,
			n_eq_0 => n_eq_0,
			i_le_n => i_le_n
	);
		
	clk <= not clk after 5ns;
	
	
	process
	begin 
		-- set reset at beginning of design 
		rst <= '1';
		go <= '0';
		n <= "000000";
		
		-- wait a few clock cycles to reset everything
		for i in 0 to 5 loop 
			wait until rising_edge(clk);
		end loop;
		
		assert(unsigned(result) = to_unsigned(0, 6))
		report "error: reset does not work properly -- result is not 0";
		assert(done = '0')
		report "error: reset does not work properly -- done is 1";
		
		-- check if go is faulty 
		rst <= '0';
		go <= '0';
		n <= "000001";
		for i in 0 to 5 loop
			wait until rising_edge(clk);
		end loop;
		
		-- if result is not 0, the controller executed without a go signal
		assert(unsigned(result) = to_unsigned(0, 6))
		report "error: go does not work properly -- result is not 0";
		assert(done = '0')
		report "error: go does not work properly -- done is 1";
		
		for i in 0 to 20 loop
			-- assign input to fib calculator from loop iteration & enable datapath
			rst <= '0';
			go <= '1';
			n <= std_logic_vector(to_unsigned(i, 6));
			
			wait until rising_edge(clk);
			
			-- disable new inputs to datapath
			go <= '0';
			
			-- check if done has been asserted
			if (done = '1') then
				wait until rising_edge(clk) and done = '0' for 1 us;
			end if;
			if (done = '0') then
				wait until rising_edge(clk) and done = '1' for 15 us;
			end if;
			assert(done = '1')
			report "done never asserted.";
			
			-- check output of datapath
			assert(unsigned(result) = to_unsigned(fibonacci_value(i), 24))
			report "incorrect result!Fib(" & integer'image(i) & ") is " & integer'image(fibonacci_value(i)) & " but output was " & integer'image(to_integer(unsigned(result))) severity warning;
			
		end loop;
		
		
	wait;
	end process;
end tb;