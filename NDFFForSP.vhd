Library ieee;
Use ieee.std_logic_1164.all;

Entity my_nDFFSP is
Generic ( n : integer := 16);
port( Clk,Rst : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0);
enable: in std_logic);
end my_nDFFSP;

Architecture a_my_nDFFSP of my_nDFFSP is
begin
Process (Clk,Rst)
begin
if Rst = '1' then
q <= (others=>'1');
elsif rising_edge(Clk) then
if enable = '1' then
q <= d;
end if;
end if;
end process;
end a_my_nDFFSP;

