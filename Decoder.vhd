library ieee;
use ieee.std_logic_1164.all;

entity Decoder is port(
E: in std_logic;
I: in std_logic;
O: out std_logic_vector(1 downto 0)
);
end entity Decoder;

architecture DecoderArch of Decoder is
begin

O <= "01" when E = '1' and I = '0' else
     "10" when E= '1' and I = '1' else
     "00";
end architecture DecoderArch;