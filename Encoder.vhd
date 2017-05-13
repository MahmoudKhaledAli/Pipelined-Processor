library ieee;
use ieee.std_logic_1164.all;

entity Encoder is
port(D: in std_logic_vector(7 downto 0);
Valid: out std_logic;
Q: out std_logic_vector(2 downto 0)
);

end entity Encoder;

architecture EncoderArch of Encoder is
begin
Valid <= '0' when D = "00000000" else
	 '1';

Q <= "111" when D(7) = '1' else
     "110" when D(6) = '1' else
     "101" when D(5) = '1' else
     "100" when D(4) = '1' else
     "011" when D(3) = '1' else
     "010" when D(2) = '1' else
     "001" when D(1) = '1' else
     "000";

end architecture EncoderArch;