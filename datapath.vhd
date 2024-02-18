library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity equals is
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic
	);
end equals;

architecture bhv of equals is
begin
process(input_0, input_1)
	begin
		if(unsigned(input_0) = unsigned(input_1)) then
			output <= '1';
		else
			output <= '0';
		end if;
end process;
end;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity less_than_or_equals is
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic
	);
end less_than_or_equals;

architecture bhv of less_than_or_equals is
begin
process(input_0, input_1)
	begin
		if(unsigned(input_1) <= unsigned(input_0)) then
			output <= '1';
		else
			output <= '0';
		end if;
end process;
end;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add is
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic_vector(WIDTH-1 downto 0)
	);
end add;

architecture bhv of add is
begin
process(input_0, input_1)
	begin
		output <= std_logic_vector(unsigned(input_0) + unsigned(input_1));
end process;
end;




library ieee;
use ieee.std_logic_1164.all;

entity mux is
generic(WIDTH : positive);
	port(
		input_0 : in std_logic_vector(WIDTH-1 downto 0);
		input_1 : in std_logic_vector(WIDTH-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(WIDTH-1 downto 0));
end mux;

architecture bhv of mux is
begin
	process(input_0, input_1, sel)
	begin
		if (sel = '1') then
			output <= input_0;
		else 
			output <= input_1;
		end if;
end process;
end bhv;




library ieee;
use ieee.std_logic_1164.all;

entity reg is
generic(WIDTH : positive);
PORT (clk, rst, en : in std_logic;
		input : in std_logic_vector(WIDTH-1 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0));
end reg;

architecture bhv of reg is
begin
process(clk, rst, en, input)
	begin
		if(rst = '1') then
			output <= (others => '0');
		
		elsif(clk'event and clk = '0') then
			if(en = '1') then
				output <= input;
			end if;
		end if;
end process;
end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port (
		clk : in std_logic;
		rst : in std_logic;
		n : in std_logic_vector(5 downto 0);
		result : out std_logic_vector(23 downto 0);
		n_en : in std_logic;
		result_en : in std_logic;
		result_sel : in std_logic;
		x_en : in std_logic;
		x_sel : in std_logic;
		y_en : in std_logic;
		y_sel : in std_logic;
		i_en : in std_logic;
		i_sel : in std_logic;
		n_eq_0 : out std_logic;
		i_le_n : out std_logic
	);
end datapath;

architecture bhv of datapath is

component equals
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic
	);
end component;


component less_than_or_equals
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic
	);
end component;


component add
generic(WIDTH : positive);
PORT (
	input_0 : in std_logic_vector(WIDTH-1 downto 0);
	input_1 : in std_logic_vector(WIDTH-1 downto 0);
	output : out std_logic_vector(WIDTH-1 downto 0)
	);
end component;	


component reg
generic(WIDTH : positive);
PORT (clk, rst, en : in std_logic;
		input : in std_logic_vector(WIDTH-1 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0));
end component;


component mux
generic(WIDTH : positive);
	port(
		input_0 : in std_logic_vector(WIDTH-1 downto 0);
		input_1 : in std_logic_vector(WIDTH-1 downto 0);
		sel : in std_logic;
		output : out std_logic_vector(WIDTH-1 downto 0));
end component;

signal out_n_reg : std_logic_vector(5 downto 0);
signal out_i_reg : std_logic_vector(5 downto 0);
signal out_i_mux : std_logic_vector(5 downto 0);
signal out_add_1 : std_logic_vector(5 downto 0);
signal two_6_bits : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(2,6));
signal one_6_bits : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(1,6));
signal zero_6_bits : std_logic_vector(5 downto 0) := (others => '0');

signal out_x_mux : std_logic_vector(23 downto 0);
signal out_y_mux : std_logic_vector(23 downto 0);
signal out_x_reg : std_logic_vector(23 downto 0);
signal out_y_reg : std_logic_vector(23 downto 0);
signal out_add_reg : std_logic_vector(23 downto 0);
signal out_result_mux : std_logic_vector(23 downto 0);
signal zero_24_bits : std_logic_vector(23 downto 0) := (others => '0');
signal one_24_bits : std_logic_vector(23 downto 0) := std_logic_vector(to_unsigned(1,24));

begin

n_reg : reg
	generic map(WIDTH => 6)
	port map(clk=>clk, rst=>rst, en=>n_en, input=>n, output=>out_n_reg);
	
equals_0 : equals
	generic map(WIDTH => 6)
	port map(input_0=>zero_6_bits, input_1=>out_n_reg, output=>n_eq_0);
	
ltoe : less_than_or_equals
	generic map(WIDTH => 6)
	port map(input_0=>out_n_reg, input_1=>out_i_reg, output=>i_le_n);

plus_1 : add
	generic map(WIDTH => 6)
	port map(input_0=>out_i_reg, input_1=>one_6_bits, output=>out_add_1);
	
I_MUX : mux
	generic map(WIDTH => 6)
	port map(input_0=>two_6_bits, input_1=>out_add_1, sel=>i_sel, output=>out_i_mux);	
	
I_REG : reg
	generic map(WIDTH => 6)
	port map(clk=>clk, rst=>rst, en=>i_en, input=>out_i_mux, output=>out_i_reg);

X_MUX : mux
	generic map(WIDTH => 24)
	port map(input_0=>zero_24_bits, input_1=>out_y_reg, sel=>x_sel, output=>out_x_mux);		

X_REG : reg
	generic map(WIDTH => 24)
	port map(clk=>clk, rst=>rst, en=>x_en, input=>out_x_mux, output=>out_x_reg);		

Y_MUX : mux
	generic map(WIDTH => 24)
	port map(input_0=>one_24_bits, input_1=>out_add_reg, sel=>y_sel, output=>out_y_mux);		

Y_REG : reg
	generic map(WIDTH => 24)
	port map(clk=>clk, rst=>rst, en=>y_en, input=>out_y_mux, output=>out_y_reg);

sum_reg : add
	generic map(WIDTH => 24)
	port map(input_0=>out_x_reg, input_1=>out_y_reg, output=>out_add_reg);	
	
RESULT_MUX : mux
	generic map(WIDTH => 24)
	port map(input_0=>zero_24_bits, input_1=>out_y_reg, sel=>result_sel, output=>out_result_mux);

RESULT_REG : reg
	generic map(WIDTH => 24)
	port map(clk=>clk, rst=>rst, en=>result_en, input=>out_result_mux, output=>result);	
	
end bhv;