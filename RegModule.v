module ReqMod(Sel, RE, WE, Addr, CLK,Rst,Q0,Q1);
input Sel,RE,WE;
output [3:0] Q0,Q1;
input [1:0] Addr;
input WE,RE,Rst, CLK;

wire [3:0] MemOut;
wire SelR0,SelR1;
wire [3:0] DataToW;

assign SelR0 = RE & ~Sel;
assign SelR1 = RE & Sel;
assign DataToW = (Sel == 0) ? Q0 : Q1;

Reg Reg0(MemOut,Q0,SelR0,Rst,CLK);
Reg Reg1(MemOut,Q1,SelR1,Rst,CLK);

RAM Mem(DataToW,MemOut,Addr,WE,RE,Rst,CLK);

endmodule
