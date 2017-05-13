library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all;

entity Processor is port(
clk: in std_logic);
end Processor;
architecture ProcessorArch of Processor is

component syncram is
generic(n: integer := 6);
port ( clk : in std_logic;
we : in std_logic;
address : in std_logic_vector(n-1 downto 0);
datain : in std_logic_vector(15 downto 0);
dataout : out std_logic_vector(15 downto 0) );
end component;

component registerfile is 
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

component ControlUnit is port(
opcode: in std_logic_vector(4 downto 0);
ALU: out std_logic_vector(6 downto 0);
RegFileEn: out std_logic;
PushPopEn: out std_logic_vector(1 downto 0);
MemEn: out std_logic;
Rot: out std_logic;
Load: out std_logic;
LDD: out std_logic;
Mov: out std_logic
);

end component;

component my_nDFF is
Generic ( n : integer := 16);
port( Clk,Rst : in std_logic;
d : in std_logic_vector(n-1 downto 0);
q : out std_logic_vector(n-1 downto 0);
enable: in std_logic);

end component;

component forwardingUnit is 
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
end component;

signal PC: std_logic_vector(15 downto 0) := "0000000000000000";
signal IR: std_logic_vector(15 downto 0);
signal FetchBuffD: std_logic_vector(15 downto 0);
signal DecodeBuffD: std_logic_vector(57 downto 0); --0-15 reg1 16-31 reg2 32-42 instruction 43-57 control signals
signal DecodeOutput: std_logic_vector(57 downto 0);
signal ALUMemBuffD: std_logic_vector(41 downto 0); --0-15 write back 16-26 instruction 27-41 control signals 
signal ALUMemOut: std_logic_vector(41 downto 0);
signal MemE: std_logic;
signal MemAddress: std_logic_vector(7 downto 0);
signal MemDataOut: std_logic_vector(15 downto 0);
signal ALUControl: std_logic_vector(6 downto 0);
signal RegFileEnable: std_logic;
signal RegFilePP: std_logic_vector(1 downto 0);
signal ALUCin: std_logic;
signal CarryFlagQ: std_logic;
signal CarryFlagD: std_logic;
signal ZeroFlagD: std_logic;
signal ZeroFlagQ: std_logic;
signal NegFlagD: std_logic;
signal NegFlagQ: std_logic;
signal OverFlagD: std_logic;
signal OverFlagQ: std_logic;
signal Rotate: std_logic;
signal Load: std_logic;
signal LDD: std_logic;
signal Mov: std_logic;
signal ALUOutput: std_logic_vector(15 downto 0);
signal PC0:std_logic_vector(15 downto 0) := "0000000000000000";
signal notClk: std_logic;
signal ForwALU1,ForwALU2,ForwMem: std_logic;
signal ALUOp1,ALUOp2,MemIn: std_logic_vector(15 downto 0);
signal operationF,operationstoreF: std_logic_vector(0 downto 0);

begin

notClk <= not clk;
operationF(0) <= DecodeOutput(46);
operationstoreF(0) <= DecodeOutput(43);

process(clk) is
begin
if rising_edge(clk) then
PC <= std_logic_vector(unsigned(PC)+1);
end if;
--PC <= PC0;
end process;

InstructionMem: syncram generic map(n => 8) port map(clk,'0',PC(7 downto 0),"0000000000000000",FetchBuffD);

FetchBuff: my_nDFF  generic map (n => 16) port map(clk,'0',FetchBuffD,IR,'1');

registerf :  registerfile port map(notClk,IR(10 downto 8),IR(7 downto 5),ALUMemOut(26 downto 24),ALUMemOut(15 downto 0),DecodeBuffD(15 downto 0),DecodeBuffD(31 downto 16),ALUMemOut(30),DecodeOutput(45 downto 44));

ControlU: ControlUnit port map(IR(15 downto 11),ALUControl,RegFileEnable,RegFilePP,MemE,Rotate,Load,LDD,Mov);

DecodeBuffD(57 downto 32) <= Mov & LDD & Load & Rotate & ALUControl & RegFileEnable & RegFilePP & MemE & IR(10 downto 0);

DecodeBuff: my_nDFF  generic map (n => 58) port map(clk,'0',DecodeBuffD,DecodeOutput,'1');

MemAddress <= std_logic_vector(unsigned(ALUMemOut(7 downto 0)) + 1) when DecodeOutput(45 downto 44) = "10" and	ALUMemOut(26 downto 24) = "111" and ALUMemOut(30) = '1' else
              std_logic_vector(unsigned(ALUMemOut(7 downto 0))) when DecodeOutput(45 downto 44) = "01" and	ALUMemOut(26 downto 24) = "111" and ALUMemOut(30) = '1' else
	      std_logic_vector(unsigned(DecodeOutput(23 downto 16))) when DecodeOutput(45 downto 44) = "01" else
	      std_logic_vector(unsigned(DecodeOutput(23 downto 16)) + 1) when DecodeOutput(45 downto 44) = "10" else
	      DecodeOutput(39 downto 32);

DataMem: syncram generic map(n => 8) port map(notClk,DecodeOutput(43),MemAddress,MemIn,MemDataOut);

Forward: forwardingUnit port map(clk,DecodeOutput(42 downto 40),DecodeOutput(39 downto 37), operationF,operationstoreF,ForwALU1,ForwALU2,ForwMem);

ALUCin <= CarryFlagQ when Rotate='1' else
DecodeOutput(47);

ALUOp1 <= DecodeOutput(15 downto 0) when ForwALU1 = '0' else
	  ALUMemOut(15 downto 0);

ALUOp2 <= DecodeOutput(31 downto 16) when ForwALU2 = '0' else
	  ALUMemOut(15 downto 0);

MemIn <= DecodeOutput(15 downto 0) when ForwMem ='0' else
	 ALUMemOut(15 downto 0);

ALUMap: ALU port map(ALUOp1, ALUOp2,DecodeOutput(51 downto 48),DecodeOutput(53),DecodeOutput(52),ALUCin,ALUOutput,ZeroFlagD,NegFlagD,CarryFlagD,OverFlagD);

ALUMemBuffD(38 downto 16) <= DecodeOutput(54 downto 32);
ALUMemBuffD(15 downto 0) <= MemDataOut when  DecodeOutput(55) ='1' else
			    "00000000" & DecodeOutput(39 downto 32) when DecodeOutput(56) = '1' else
			    ALUOp2 when DecodeOutput(57) = '1' else
			    ALUOutput;

ALUMemBuff: my_nDFF generic map(n=>42) port map(clk,'0',ALUMemBuffD,ALUMemOut,'1');

end ProcessorArch;