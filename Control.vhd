library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all;

entity ControlUnit is port(
opcode: in std_logic_vector(4 downto 0);
ALU: out std_logic_vector(6 downto 0); --6 setc 5 clrc 4-1 selectors 0 cin
RegFileEn: out std_logic;
PushPopEn: out std_logic_vector(1 downto 0);
MemEn: out std_logic;
Rot: out std_logic;
Load: out std_logic;
LDD: out std_logic;
Mov: out std_logic
);

end ControlUnit;

architecture ControlArch of ControlUnit is begin

ALU <= "0000111" when opcode = "00000" else
"1001000" when opcode = "00001" else
"0101000" when opcode = "00010" else
"0000010" when opcode = "00110" else
"0000101" when opcode = "00111" else
"0001000" when opcode = "01000" else
"0001010" when opcode = "01001" else
"0000000" when opcode = "01011" else
"0011100" when opcode = "10000" else
"0010100" when opcode = "10001" else
"0000000" when opcode = "10010" else
"0000000" when opcode = "10100" else
"0001110" when opcode="10110" else
"0001111" when opcode="10111" else
"0000001" when opcode = "11000" else
"0000110" when opcode = "11001" else
"0000111";

RegFileEn <= '1' when opcode="00101" or opcode="00110" or opcode="00111" or opcode="01000" or opcode="01001" or opcode="01010" or opcode="01100" or opcode="10000" or opcode="10001" or opcode="10011" or opcode="10101" or opcode="10110" or opcode="10111" or opcode="11000" or opcode="11001" else
'0';
PushPopEn <= "01" when opcode="10010" else
"10" when opcode="10011" else
"00";

MemEn <= '1' when opcode = "01011" or opcode = "10010" else
'0';

Rot <= '1' when opcode = "10000" or opcode = "10001" else
'0';

Load <= '1' when opcode = "01010" or opcode = "10011" else
'0';

LDD <= '1' when opcode = "01100" else
'0';

Mov <= '1' when opcode = "00101" else
'0';

end ControlArch;