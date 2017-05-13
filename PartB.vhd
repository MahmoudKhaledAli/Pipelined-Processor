library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity PartB is
port(A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
S : in std_logic_vector(1 downto 0);
Cin: in std_logic;
F : out std_logic_vector(15 downto 0)
);

end entity PartB;

architecture PartB_arch of PartB is 
Signal Cins: std_logic_vector(0 downto 0);
begin

Cins(0) <= Cin;
F <= A and B when S = "00" else
     A or B when S = "01" else
     A xor B when S = "10" else
     std_logic_vector(unsigned(Not A) + unsigned(Cins)) when S = "11";

end architecture PartB_arch;