
library ieee;
use ieee.std_logic_1164.all;

entity PartD is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic
);

end entity PartD;

architecture PartD_arch of PartD is begin

F <= A(14 downto 0) & '0' when S = "00" else
     A(14 downto 0) & A(15) when S = "01" else
     A(14 downto 0) & Cin  when S = "10";

Cout <= A(15);

end architecture PartD_arch;