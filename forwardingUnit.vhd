Library ieee;
Use ieee.std_logic_1164.all;



entity forwardingUnit is 
port(
clk :in std_logic ;
inputregister1 : in std_logic_vector (2 downto 0); 
inputregister2 : in std_logic_vector (2 downto 0);
operation : in std_logic_vector (0 downto 0) ;      -- dih controle signal teb2a b 1 law ay haga beta3mel write back
operationstore : in std_logic_vector (0 downto 0);  --dih controle signal teb2a b 1 law store
mux1 : out std_logic;  -- dih t2olak en el A beta3et el alu takhod mn b3d el buffer
mux2 : out std_logic;  -- dih el B
mux3 : out std_logic    -- dih te2ollak en el data el dakhla 3al memory takhod mn b3d el buffer
);
end forwardingUnit;

architecture forwardingunits of forwardingunit is

component my_nDFF is
Generic ( n : integer := 16);
port( Clk,Rst : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0); 
enable : in std_logic
);
end component ;


signal q1 : std_logic_vector (2 downto 0);
signal q2,q3 : std_logic_vector (0 downto 0);
begin 

register1: my_nDFF  generic map (n => 3) port map(clk,'0',inputregister1,q1,'1');
register2: my_nDFF  generic map (n => 1) port map(clk,'0',operation,q2,'1');

mux1 <= '1' when (q1=inputregister1 and operation(0)='1' and q2(0)='1')
else  '0' ;


mux2 <= '1' when (q1=inputregister2 and operation(0)='1' and q2(0)='1')
else '0' ;


mux3 <= '1' when (q1=inputregister1 and operationstore(0)='1' and q2(0)='1')
else '0' ;

end architecture forwardingunits;
