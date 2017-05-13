library ieee;
use ieee.std_logic_1164.all;
entity PartAS is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);

end entity PartAS;

architecture PartAS_arch of PartAS is
component my_nadder
Generic (n : integer := 8);
PORT    (a, b : in std_logic_vector(n-1 downto 0) ;
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END component;
Signal Func: std_logic_vector(15 downto 0);
Signal CoutFunc: std_logic;

begin


Func <= "0000000000000000" when S="00" else
         B when S="01" else
         not B when S="10" else
        "1111111111111111" when S="11" and Cin  = '0' else
         not A when S = "11" and Cin = '1';



f0: my_nadder generic map(n=>16) port map(A,Func,Cin,F,CoutFunc);


Cout <= not CoutFunc when S = "10" else
        not CoutFunc when S = "11" else
        CoutFunc;


end architecture PartAS_arch;