library ieee;
use ieee.std_logic_1164.all;

entity PartC is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);

end entity PartC;

architecture PartC_arch of PartC is begin

F <= '0' & A(15 downto 1) when S = "00" else
     A(0) & A(15 downto 1) when S = "01" else
     Cin & A(15 downto 1)  when S = "10" else
     A(15) & A(15 downto 1) when S = "11";

Cout <= A(0);

end architecture PartC_arch;