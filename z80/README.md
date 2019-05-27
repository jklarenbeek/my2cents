# Ideas for a z80 assembler

```js

processor z80 
{
  reg:bit16 PC;
  reg:bit16 AF { bit8 A, bit8 F { SF, ZF, YF, HF, XF, PF, NF, CF } }
  reg:bit16 HL { bit8 H, bit8 L }
  reg:bit16 DE { bit8 D, bit8 E }
  reg:bit16 BC { bit8 B, bit8 C }
  reg:bit16 IX { bit8 IXh, bit8 IXl }
  reg:bit16 IY { bit8 IYh, bit8 IYl }

  enum:bit3 REG8_R { B=0x000,C,D,E,H,L,A=0x111 };
  enum:bit3 REG8_P { B=0x000,C,D,E,IXh,IXl,A=0x111 };
  enum:bit3 REG8_Q { B=0x000,C,D,E,IYh,IYl,A=0x111 };

  //////////////////////////////////////////////////////////////////////////////////////////////////

  // define a set of global anonymous generic functions that can by called by its generic type.
  // this way we have access to memnonics like A = SUB(A, C); wich will render in: 0x10.010.001;
  
  // sequence selectors
  // 0x11.011.101 select ix
  // 0x11.111.101 select iy
  // 0x10.uuu.xxx operator<u> selection

  enum:int3 OP_INT8 { ADD=0,ADC,SUB,SBC,AND,OR,XOR,CP }
  enum:OP_INT8 OP_INT8C { ADC=1,SBC=2 }
  
  int:A function<U>(int:A, int:REG8_R r) changes CF,ZF where U:OP_INT8                        emit 							 0x10.uuu.rrr;									/* ADD A,r[ + C] */
  int:A function<U>(int:A, int:REG8_R r, int:CF) where U:OP_INT8C;
  int:A function<U>(int:A, int:REG8_P p) changes int:CF,ZF where U:OP_INT8                    emit 0x11.011.101, 0x10.uuu.ppp;									/* ADD A,p[ + C] */
  int:A function<U>(int:A, int:REG8_P p, int:CF)) where U:OP_INT8C;
  int:A function<U>(int:A, int:REG8_Q q) changes int:CF,ZF where U:OP_INT8                    emit 0x11.111.101, 0x10.uuu.qqq;									/* ADD A,q[ + C] */ }
  int:A function<U>(int:A, int:REG8_Q q, int:CF) where U:OP_INT8C;

  int:A function<U>(int:A, int8(addr:HL)) changes int:CF,ZF where U:OP_INT8                   emit 							 0x10.uuu.110; 								/* ADD A,(HL)[ + C] */ }
  int:A function<U>(int:A, int8(addr:HL), int:CF) where U:OP_INT8C;
  int:A function<U>(int:A, int8:literal n) changes int:CF,ZF where U:OP_INT8                  emit 							 0x11.uuu.110, 0xnnnn.nnnn;	/* ADD A,n[ + C] */
  int:A function<U>(int:A, int8:literal n, int:CF) where U:OP_INT8C;

  int:A function<U>(int:A, int8(addr:IX, addr8:literal d) ) changes int:CF,ZF where U:OP_INT8 emit 0x11.011.101, 0x10.uuu.110, 0xddd.dddd;		/* ADD A,(IX+d)[ + C] */
  int:A function<U>(int:A, int8(addr:IX, addr8:literal d), int:CF ) where U:OP_INT8C;
  int:A function<U>(int:A, int8(addr:IY, addr8:literal d) ) changes CF,ZF where U:OP_INT8     emit 0x11.111.101, 0x10.uuu.110, 0xddd.dddd;		/* ADD A,(IX+d)[ + C] */
  int:A function<U>(int:A, int8(addr:IY, addr8:literal d), int:CF ) where U:OP_INT8C;

  //////////////////////////////////////////////////////////////////////////////////////////////////

  enum:bit2 REG16_RR { BC, DE, HL, SP }
  enum:bit2 REG16_PP { BC, DE, IX, SP }
  enum:bit2 REG16_QQ { BC, DE, IY, SP }
  int:HL ADD(int:HL, int:REG16_RR r) changes YF,HF,XF,NF=0,CF                                 emit               0x00.rr1.000;??
  int:HL ADC(int:HL, int:REG16_RR r) changes SF,ZF,YF,HF,XF,PF,NF=0,CF                        emit 0x11.101.101, 0x01.rr1.010;
  int:HL SBC(int:HL, int:REG16_RR r) changes SF,ZF,YF,HF,XF,PF,NF=1,CF                        emit 0x11.101.101, 0x01.rr0.010;
    
  //////////////////////////////////////////////////////////////////////////////////////////////////
  enum:bit2 REG16_QQ { BC, DE, HL, AF };
  void function PUSH(bit16:REG16_QQ q) changes SP where Q:REG16_QQ                            emit 0x11.qq0.101;
  bit16:Q function POP<Q>() changes SP where Q:REG16_QQ                                       emit 0x11.qq0.001;

  //////////////////////////////////////////////////////////////////////////////////////////////////

  enum:bit3 CMP_CC { NZ, Z, NC, C, PO, PE, P, M };
  enum:bit2 CMP_SS { NZ, Z, NC, C };
  void function JP(addr:literal n) changes PC                                                 emit 0x11.000.011, 0xnnnn.nnnn, 0xnnnn.nnnn;
  void function JP<C>(addr:literal n) changes PC where C:CMP_CC                               emit 0x11.ccc.010, 0xnnnn.nnnn, 0xnnnn.nnnn;
  void function JR(addr8:literal e) changes PC                                                emit               0x00.011.000, 0xeeee.eeee;
  void function JR<C>(addr8:literal e) changes PC where C:CMP_SS                              emit               0x00.1cc.000, 0xeeee.eeee;
  void function JP(addr:HL) changes PC                                                        emit 0x11.101.001;
  int:B function DJNZ(int:B, addr8:literal e) changes PC                                      emit               0x00.010.000, 0xeeee.eeee;
  
  enum:bit3 RST_P { H00, H08, H10, H18, H20, H28, H30, H38 }
  void function RST<P>() changes SP, PC where P:RST_P
 }
```

the following is a snippet of js code that is to slow.

```js

var joham = (function() {
  function z80()
  {
    // AF, BC, DE, HL, IX, IY, PC, SP, IR, AFX, BCX, DEX, HLX
    var REGBUFFER = new ArrayBuffer(26);
    var REGVIEW8 = new Uint8Array(REGBUFFER);
    var REGVIEW16 = new Uint16Array(REGBUFFER);
    
    this.register = {};

    Object.defineProperty(this.register, "AF", { get:function() { return REGVIEW16[0]; } } );
    Object.defineProperty(this.register, "A", { get:function() { return REGVIEW8[0]; } } );
    Object.defineProperty(this.register, "F", { get:function() { return REGVIEW8[1]; } } );
    Object.defineProperty(this.register, "CF", { get:function() { return this.F & 1; } } );
    Object.defineProperty(this.register, "NF", { get:function() { return this.F & 2; } } );
    Object.defineProperty(this.register, "PF", { get:function() { return this.F & 4; } } );
    Object.defineProperty(this.register, "XF", { get:function() { return this.F & 8; } } );
    Object.defineProperty(this.register, "HF", { get:function() { return this.F & 16; } } );
    Object.defineProperty(this.register, "YF", { get:function() { return this.F & 32; } } );
    Object.defineProperty(this.register, "ZF", { get:function() { return this.F & 64; } } );
    Object.defineProperty(this.register, "SF", { get:function() { return this.F & 128; } } );

    Object.defineProperty(this.register, "BC", { get:function() { return REGVIEW16[1]; } } );
    Object.defineProperty(this.register, "B", { get:function() { return REGVIEW8[2]; } } );
    Object.defineProperty(this.register, "C", { get:function() { return REGVIEW8[3]; } } );

    Object.defineProperty(this.register, "DE", { get:function() { return REGVIEW16[2]; } } );
    Object.defineProperty(this.register, "D", { get:function() { return REGVIEW8[4]; } } );
    Object.defineProperty(this.register, "E", { get:function() { return REGVIEW8[5]; } } );
    
    Object.defineProperty(this.register, "HL", { get:function() { return REGVIEW16[3]; } } );
    Object.defineProperty(this.register, "H", { get:function() { return REGVIEW8[6]; } } );
    Object.defineProperty(this.register, "L", { get:function() { return REGVIEW8[7]; } } );

    Object.defineProperty(this.register, "IX", { get:function() { return REGVIEW16[4]; } } );
    Object.defineProperty(this.register, "IXh", { get:function() { return REGVIEW8[8]; } } );
    Object.defineProperty(this.register, "IXl", { get:function() { return REGVIEW8[9]; } } );

    Object.defineProperty(this.register, "IY", { get:function() { return REGVIEW16[5]; } } );
    Object.defineProperty(this.register, "IYh", { get:function() { return REGVIEW8[10]; } } );
    Object.defineProperty(this.register, "IYl", { get:function() { return REGVIEW8[11]; } } );

    Object.defineProperty(this.register, "PC", { get:function() { return REGVIEW16[6]; } } );
    Object.defineProperty(this.register, "SP", { get:function() { return REGVIEW16[7]; } } );

    Object.defineProperty(this.register, "I", { get:function() { return REGVIEW8[16]; } } );
    Object.defineProperty(this.register, "R", { get:function() { return REGVIEW8[17]; } } );

    Object.defineProperty(this.register, "AFX", { get:function() { return REGVIEW16[9]; } } );
    Object.defineProperty(this.register, "BCX", { get:function() { return REGVIEW16[10]; } } );
    Object.defineProperty(this.register, "DEX", { get:function() { return REGVIEW16[11]; } } );
    Object.defineProperty(this.register, "HLX", { get:function() { return REGVIEW16[12]; } } );
    
    var BUSBUFFER = ArrayBuffer(10)
    var BUSVIEW8 = Uint8Array(BUSBUFFER);
    var BUSVIEW16 = Uint8Array(BUSBUFFER);
    
    this.bus = {}
    // BUS CONTROL
    Object.defineProperty(this.bus, "BUSREQ", { set:function(v) { REGVIEW8[3] = REGVIEW8[3] | ((v & 1) << 1); } } );
    Object.defineProperty(this.bus, "BUSACK", { get:function() { return REGVIEW8[3] & 1; } } );

    // MPU CONTROL
    Object.defineProperty(this.bus, "NMI", { set:function(v) { REGVIEW8[3] = REGVIEW8[3] | ((v & 1) << 4); } } );
    Object.defineProperty(this.bus, "INT", { set:function(v) { REGVIEW8[3] = REGVIEW8[3] | ((v & 1) << 3); } } );
    Object.defineProperty(this.bus, "WAIT", { set:function(v) { return REGVIEW8[3] & 128; } } );
    Object.defineProperty(this.bus, "HALT", { get:function() { return REGVIEW8[3] & 4; } } );
    Object.defineProperty(this.bus, "RESET", { set:function(v) { REGVIEW16[0] = 65535; REGVIEW16[6] = 0; REGVIEW16[7] = 65535; REGVIEW16[8] = 0; } } );

    // MEMORY AND I/O CONTROL
    Object.defineProperty(this.bus, "MREQ", { get:function() { return REGVIEW8[3] & 32; } } );
    Object.defineProperty(this.bus, "M1", { get:function() { return REGVIEW8[3] & 32; } } );
    Object.defineProperty(this.bus, "IORQ", { get:function() { return REGVIEW8[3] & 16; } } );
    Object.defineProperty(this.bus, "RD", { get:function() { return REGVIEW8[3] & 128; } } );
    Object.defineProperty(this.bus, "WR", { get:function() { return REGVIEW8[3] & 128; } } );
    Object.defineProperty(this.bus, "RFSH", { get:function() { return REGVIEW8[3] & 128; } } );

    // ADDRESS BUS
    Object.defineProperty(this.bus, "ADDR", { get:function() { return BUSVIEW16[0]; } } );
    // DATA BUS
    Object.defineProperty(this.bus, "DATA", { get:function() { return REGVIEW8[2]; }, set:function(v) { REGVIEW8[2] = v; } } );
    
    
    this.M1T1 = function() 
    {
      this.BUS.M1 = HIGH;
      this.BUS.ADDR = this.REG.PC;
      this.BUS.RD = HIGH;
    }
    this.M1T2 = function()
    {
      this.REG.PC = this.REG.PC + 1;
    }
    this.M1T3 = function()
    {
      this.BUS.MREQ = LOW;
      this.INT.CMD = this.BUS.DATA;
    }
    this.M1T4 = function()
    {
      function operate(token);
      // DECODE INSTRUCTION
      var block = (this.INT.CMD & 0xC0) >> 6;
      switch(block)
      {
        default:break;
      }
    }
    
  }
})()
```


whats this?

```js
enum2 cmd { ex16=1, cp16ltr, cp16rtl }

reg32 a32 { reg16 a16s, reg16 a16 { reg8 a8, reg8 a } }
cmd a16, hl; cmd a16,de; cmd 16, bc;
cmd a, l; cmd a, e; cmd a, d 

reg32 hlx { reg16 shl, reg16 hl { reg8 h, reg8 l  } }
reg32 dex { reg16 sde, reg16 de { reg8 d, reg8 e  } }
reg32 bcx { reg16 sbc, reg16 bc { reg8 b, reg8 c  } }

cmd hl, shl; cmd de, sde; cmd bc, sbc;

reg32 ixe { reg16 ixs, reg16 ix { reg8 ixh, reg8 ixl } }
reg32 iye { reg16 iys, reg16 iy { reg8 iyh, reg8 iyl } }
reg32 ize { reg16 izs, reg16 iz { reg8 izh, reg8 izl } }

cmd hlx, ixe; cmd dex, iye; cmd bcx, ize;

reg32 th1 { reg16 pc, reg16 sp }
```