library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_1164.all;

entity Processor is port(
clk: in std_logic;
InPort: in std_logic_vector(15 downto 0);
Reset: in std_logic;
Interrupt: in std_logic;
OutPort: out std_logic_vector(15 downto 0)
);
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
Mov: out std_logic;
InIns: out std_logic;
OutIns: out std_logic;
Call: out std_logic;


CarryEn: out std_logic;
OverEn: out std_logic;
NegEn: out std_logic;
ZeroEn: out std_logic;
JumpSigs: out std_logic_vector(2 downto 0);
Ret: out std_logic
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

component jumpunit is 
port(
zeroflag : in std_logic ;
negativeflag : in std_logic;
carryflag : in std_logic;
controlsignal : in std_logic_vector(2 downto 0); --000 no jump ,001 jump ,010 jump carry ,011 jump neg ,100 jump zero
decision : out std_logic
);
end component;

component my_DFF is
port( d,clk,rst, enable: in std_logic;
q : out std_logic);
end component;

signal PC: std_logic_vector(15 downto 0) := "0000000000000000";
signal IR: std_logic_vector(15 downto 0);
signal FetchBuffD: std_logic_vector(15 downto 0);
signal DecodeBuffD: std_logic_vector(66 downto 0); --0-15 reg1 16-31 reg2 32-42 instruction 43-a5er control signals
signal DecodeOutput: std_logic_vector(66 downto 0);
signal ALUMemBuffD: std_logic_vector(43 downto 0); --0-15 write back 16-26 instruction 27-a5er control signals 
signal ALUMemOut: std_logic_vector(43 downto 0);
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
signal InIns: std_logic;
signal OutIns: std_logic;
signal ALUOutput: std_logic_vector(15 downto 0);
signal PC0:std_logic_vector(15 downto 0) := "0000000000000000";
signal notClk: std_logic;
signal ForwALU1,ForwALU2,ForwMem: std_logic;
signal ALUOp1,ALUOp2,MemIn: std_logic_vector(15 downto 0);
signal operationF,operationstoreF: std_logic_vector(0 downto 0);
signal jumpers: std_logic_vector(2 downto 0);
signal decision: std_logic;
signal CarryEn, OverEn, ZeroEn, NegEn: std_logic := '0';
signal MemInsOut: std_logic_vector(15 downto 0);
signal PCTempOut: std_logic_vector(15 downto 0);
signal CallSig: std_logic;
signal NewPC: std_logic_vector(15 downto 0);
signal RetSig: std_logic;
signal MemInsAddress: std_logic_vector(7 downto 0);
signal IntCounter: integer := 3;
signal InterAC: std_logic;
signal PCInt: std_logic_vector(15 downto 0);
signal DecisionInt: std_logic;

begin

process(clk) is
begin
if Interrupt = '1' then
   InterAC = '1';
end if;
if IntCounter = 3 then
	PCInt <= PC;
	if decision='1' then
		DecisionInt = '1'
	else DecisionInt='0';
end if;
if IntCounter = 2 then
	if DecisionInt='1' then
		PCInt <= PC;
end if;
if rising_edge(clk) then 
if InterAC = '1' then
   IntCounter = IntCounter-1;
end if;
if IntCounter = 0 then
	IntCounter = 3;
end if;
end process;




notClk <= not clk;
operationF(0) <= DecodeOutput(46) or DecodeOutput(62);
operationstoreF(0) <= DecodeOutput(43);

NewPC <= MemDataOut when DecodeOutput(65) = '1' else 
  	 ALUMemBuffD(15 downto 0) when ALUMemBuffD(26 downto 24) = DecodeBuffD(42 downto 40) and DecodeOutput(46)='1' else
	 DecodeBuffD(15 downto 0);

process(clk) is
begin
if rising_edge(clk) then
	if decision='1' or DecodeOutput(65)='1' then 
		PC <= NewPC;
	elsif Reset='1' then
		PC <= MemInsOut;
	else
		PC <= std_logic_vector(unsigned(PC)+1);
	end if;
end if;
--PC <= PC0;
end process;


MemInsAddress <= "00000000" when Reset = '1' else
		  PC(7 downto 0);

InstructionMem: syncram generic map(n => 8) port map(notClk,'0',MemInsAddress,"0000000000000000",MemInsOut);

PCTemp: my_nDFF  generic map (n => 16) port map(notClk,'0',PC,PCTempOut,CallSig);

FetchBuffD <= "0000000000000000" when decision = '1' or RetSig='1'  or DecodeOutput(65) = '1' else MemInsOut;
FetchBuff: my_nDFF  generic map (n => 16) port map(clk,Reset,FetchBuffD,IR,'1');

registerf :  registerfile port map(notClk,IR(10 downto 8),IR(7 downto 5),ALUMemOut(26 downto 24),ALUMemOut(15 downto 0),DecodeBuffD(15 downto 0),DecodeBuffD(31 downto 16),ALUMemOut(30),DecodeOutput(45 downto 44));

ControlU: ControlUnit port map(IR(15 downto 11),ALUControl,RegFileEnable,RegFilePP,MemE,Rotate,Load,LDD,Mov,InIns,OutIns,CallSig,CarryEn,OverEn,NegEn,ZeroEn,jumpers,RetSig);

DecodeBuffD(65 downto 32) <= RetSig & CallSig & InIns & OutIns & CarryEn & NegEn & ZeroEn & OverEn & Mov & LDD & Load & Rotate & ALUControl & RegFileEnable & RegFilePP & MemE & IR(10 downto 0);

DecodeBuff: my_nDFF  generic map (n => 66) port map(clk,Reset,DecodeBuffD,DecodeOutput,'1');


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

MemIn <= PCTempOut when DecodeOutput(64)='1' else
	DecodeOutput(15 downto 0) when ForwMem ='0' else
	 ALUMemOut(15 downto 0);

ALUMap: ALU port map(ALUOp1, ALUOp2,DecodeOutput(51 downto 48),DecodeOutput(53),DecodeOutput(52),ALUCin,ALUOutput,ZeroFlagD,NegFlagD,CarryFlagD,OverFlagD);

ALUMemBuffD(43) <= DecodeOutput(65);
ALUMemBuffD(42) <= DecodeOutput(62);
ALUMemBuffD(38 downto 16) <= DecodeOutput(54 downto 32);
ALUMemBuffD(15 downto 0) <= MemDataOut when  DecodeOutput(55) ='1' else
			    "00000000" & DecodeOutput(39 downto 32) when DecodeOutput(56) = '1' else
			    ALUOp2 when DecodeOutput(57) = '1' else
			    ALUOp1 when DecodeOutput(62) = '1' else
			    InPort when DecodeOutput(63) = '1' else
			    ALUOutput;

ALUMemBuff: my_nDFF generic map(n=>44) port map(clk,Reset,ALUMemBuffD,ALUMemOut,'1');

OutPortL: my_nDFF generic map(n=>16) port map(notClk,'0',ALUMemOut(15 downto 0),OutPort,ALUMemOut(42));

CFlag: my_DFF  port map(CarryFlagD,notClk,'0',DecodeOutput(61),CarryFlagQ);
NegFlag: my_DFF  port map(NegFlagD,notClk,'0',DecodeOutput(60),NegFlagQ);
ZeroFlag: my_DFF  port map(ZeroFlagD,notClk,'0',DecodeOutput(59),ZeroFlagQ);
OverFlag: my_DFF  port map(OverFlagD,notClk,'0',DecodeOutput(58),OverFlagQ);

JumpUN: jumpunit port map(ZeroFlagQ,NegFlagQ,CarryFlagQ,jumpers,decision);

end ProcessorArch;