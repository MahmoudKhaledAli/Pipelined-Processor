Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity registerfile is 
port(
clk :in std_logic ;
address1 : in std_logic_vector(2 downto 0);
address2 : in std_logic_vector(2 downto 0);
writeaddress : in std_logic_vector (2 downto 0);
datawrite : in std_logic_vector (15 downto 0);
dataout1 : out std_logic_vector (15 downto 0);
dataout2 : out std_logic_vector (15 downto 0);
enable : in std_logic ;
pushpop : in std_logic_vector (1 downto 0)
);
end registerfile;


architecture registerfiles of registerfile is 

component my_nDFF is
Generic ( n : integer := 16);
port( Clk,Rst : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0);
enable : in std_logic
);
end component ;

signal q1,q2,q3,q4,q5,q6,q7,d1,d2,d3,d4,d5,d6,d7,d8 : std_logic_vector (15 downto 0);
signal q8: std_logic_vector(15 downto 0) := "0000000011111111";
signal e1,e2,e3,e4,e5,e6,e7 :std_logic :='0';
signal e8: std_logic:='0';


begin

register1: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q1,e1);
register2: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q2,e2);
register3: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q3,e3);
register4: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q4,e4);
register5: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q5,e5);
register6: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q6,e6);
register7: my_nDFF  generic map (n => 16) port map(clk,'0',datawrite,q7,e7);
register8: my_nDFF  generic map (n => 16) port map(clk,'0',d8,q8,e8);

dataout1 <=  q1 when address1="000"
        else q2 when address1="001"
	else q3 when address1="010"
	else q4 when address1="011"
	else q5 when address1="100"
	else q6 when address1="101"
	else q7 when address1="110"
	else q8 when address1="111";

dataout2 <=  q1 when address2="000"
        else q2 when address2="001"
	else q3 when address2="010"
	else q4 when address2="011"
	else q5 when address2="100"
	else q6 when address2="101"
	else q7 when address2="110"
	else q8 when address2="111";

e1 <='1' when writeaddress="000" and enable='1'
else '0';
e2 <='1' when writeaddress="001" and enable='1'
else '0';
e3 <='1' when writeaddress="010" and enable='1'
else '0';
e4 <='1' when writeaddress="011" and enable='1'
else '0';
e5 <='1' when writeaddress="100" and enable='1'
else '0';
e6 <='1' when writeaddress="101" and enable='1'
else '0';
e7 <='1' when writeaddress="110" and enable='1'
else '0';
e8 <='1' when (writeaddress="111" and enable='1') or pushpop="10" or pushpop="01"
else '0';

d8 <= datawrite when pushpop = "00"
else std_logic_vector(unsigned(datawrite) + 1) when pushpop = "10" and writeaddress="111"
else std_logic_vector(unsigned(datawrite) -1) when pushpop = "01" and writeaddress="111"
else std_logic_vector(unsigned(q8) + 1) when pushpop ="10"    -- pushpop = 10 and enable =0 when pop
else std_logic_vector(unsigned(q8) - 1) when pushpop ="01";    -- pushpop = 01 and enable =0 when push


end architecture registerfiles;