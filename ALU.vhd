library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all;

entity ALU is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(3 downto 0);
SetC: in std_logic;
ClrC: in std_logic;
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Zero: out std_logic;
Neg: out std_logic;
Cout : out std_logic;
Over: out std_logic
);

end entity ALU;

architecture Alu_arch of ALU is
component PartC is port (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
Cout : out std_logic;
F : out std_logic_vector(15 downto 0)
);
end component;
component PartB is port (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0)
);
end component;
component PartD is port (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);
end component;

component PartAS is port (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);
end component;

signal x1,x2,x3,x4,F1 : std_logic_vector(15 downto 0);
signal c1,c2,c3 : std_logic;


begin


u0: PartB port map(A,B,S(1 downto 0),Cin,x1);
u1: PartC port map(A,B,S(1 downto 0),Cin,c1,x2);
u2: PartD port map(A,B,S(1 downto 0),Cin,x3,c2);
u3: PartAS port map(A,B,S(1 downto 0),Cin,x4,c3);

F1 <= x1 when S(3 downto 2) = "01" else
     x2 when S(3 downto 2) = "10" else
     x3 when S(3 downto 2) = "11"else
     x4 when S(3 downto 2) = "00";
F <=F1;

Cout <= c1 when S(3 downto 2) = "10" else
        c2 when S(3 downto 2)="11" else
        c3 when S(3 downto 2)="00" else
	'1' when SetC = '1' else
	'0' when ClrC = '1';

Over <= '1' when (A(15) ='0' and B(15) = '0' and F1(15) = '1') or (A(15) ='1' and B(15) = '1' and F1(15) = '0') else
'0';

Neg <= F1(15);

Zero <= '1' when unsigned(F1) = 0 else
'0'; 


end architecture Alu_arch;