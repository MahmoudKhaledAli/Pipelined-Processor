library ieee;
use ieee.std_logic_1164.all;
entity PartA is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);

end entity PartA;

architecture PartA_arch of PartA is
component my_nadder
Generic (n : integer := 8);
PORT    (a, b : in std_logic_vector(n-1 downto 0) ;
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END component;
Signal X1,X2,X3,X4,X5,Bdash,Adash,a5er: std_logic_vector(15 downto 0);
Signal Cout1,Cout2,Cout3,Cout4,Cout5,cins: std_logic;

begin

Bdash <= not B;
Adash <= not A;

a5er <= "1111111111111110" when cin='0' else
not A;

cins <= '1';


f0: my_nadder generic map(n=>16) port map(A,"0000000000000000",Cin,X1,Cout1);
f1: my_nadder generic map (n=>16) port map(A,B,Cin,X2,Cout2);
f2: my_nadder generic map (n=>16) port map(A,Bdash , Cin,X3,Cout3);
f4: my_nadder generic map (n=>16) port map(A,a5er,'1',X4,Cout4);

F <= X1 when S = "00" else
X2 when S = "01" else
X3 when S = "10" else
X4 when S = "11";

Cout <= Cout1 when S = "00" else
Cout2 when S = "01" else
not Cout3 when S = "10" else
not Cout4;


end architecture PartA_arch;