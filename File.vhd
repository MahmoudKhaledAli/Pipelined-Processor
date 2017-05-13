library ieee;
use ieee.std_logic_1164.all;

entity RegisterFileS is port(
InPort: in std_logic_vector(15 downto 0);
OutPort: out std_logic_vector(15 downto 0);
Cout: out std_logic;
S: in std_logic_vector(3 downto 0);
En: in std_logic;
InS: in std_logic;
clk: in std_logic;
Cin: in std_logic);

end entity RegisterFileS;

architecture RegisterFileArch of RegisterFileS is
component Decoder is port(
E: in std_logic;
I: in std_logic;
O: out std_logic_vector(1 downto 0)
);
end component;
component my_nDFF is
Generic ( n : integer := 16);
port( Clk,Rst : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0);
enable: in std_logic);
end component;
component ALU is
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
end component;
signal Reg0: std_logic_vector(15 downto 0);
signal Reg1: std_logic_vector(15 downto 0) := "1111111111111111";
signal DecoderO: std_logic_vector(1 downto 0);
signal a5: std_logic;
begin

f0: Decoder port map(En,InS,DecoderO);
f1: my_nDFF generic map(n=>16) port map(clk,'0',InPort,Reg0,DecoderO(0));
f2: my_nDFF generic map(n=>16) port map(clk,'0',InPort,Reg1,DecoderO(1));
f3: ALU port map(Reg0,Reg1,S,'0','0',Cin,OutPort,Cout,Cout,Cout,Cout);

end architecture RegisterFileArch;