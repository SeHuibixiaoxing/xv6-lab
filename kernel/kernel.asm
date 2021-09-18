
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a0013103          	ld	sp,-1536(sp) # 80008a00 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	072000ef          	jal	ra,80000088 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	2781                	sext.w	a5,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000028:	0037969b          	slliw	a3,a5,0x3
    8000002c:	02004737          	lui	a4,0x2004
    80000030:	96ba                	add	a3,a3,a4
    80000032:	0200c737          	lui	a4,0x200c
    80000036:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003a:	000f4737          	lui	a4,0xf4
    8000003e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000042:	963a                	add	a2,a2,a4
    80000044:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000046:	0057979b          	slliw	a5,a5,0x5
    8000004a:	078e                	slli	a5,a5,0x3
    8000004c:	00009617          	auipc	a2,0x9
    80000050:	fe460613          	addi	a2,a2,-28 # 80009030 <mscratch0>
    80000054:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000056:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000058:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005a:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005e:	00006797          	auipc	a5,0x6
    80000062:	e2278793          	addi	a5,a5,-478 # 80005e80 <timervec>
    80000066:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000072:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000076:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007e:	30479073          	csrw	mie,a5
}
    80000082:	6422                	ld	s0,8(sp)
    80000084:	0141                	addi	sp,sp,16
    80000086:	8082                	ret

0000000080000088 <start>:
{
    80000088:	1141                	addi	sp,sp,-16
    8000008a:	e406                	sd	ra,8(sp)
    8000008c:	e022                	sd	s0,0(sp)
    8000008e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000090:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000094:	7779                	lui	a4,0xffffe
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	ed478793          	addi	a5,a5,-300 # 80000f7c <main>
    800000b0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b4:	4781                	li	a5,0
    800000b6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000ba:	67c1                	lui	a5,0x10
    800000bc:	17fd                	addi	a5,a5,-1
    800000be:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ca:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000ce:	10479073          	csrw	sie,a5
  timerinit();
    800000d2:	00000097          	auipc	ra,0x0
    800000d6:	f4a080e7          	jalr	-182(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000da:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000de:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e0:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e2:	30200073          	mret
}
    800000e6:	60a2                	ld	ra,8(sp)
    800000e8:	6402                	ld	s0,0(sp)
    800000ea:	0141                	addi	sp,sp,16
    800000ec:	8082                	ret

00000000800000ee <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ee:	715d                	addi	sp,sp,-80
    800000f0:	e486                	sd	ra,72(sp)
    800000f2:	e0a2                	sd	s0,64(sp)
    800000f4:	fc26                	sd	s1,56(sp)
    800000f6:	f84a                	sd	s2,48(sp)
    800000f8:	f44e                	sd	s3,40(sp)
    800000fa:	f052                	sd	s4,32(sp)
    800000fc:	ec56                	sd	s5,24(sp)
    800000fe:	0880                	addi	s0,sp,80
    80000100:	8a2a                	mv	s4,a0
    80000102:	892e                	mv	s2,a1
    80000104:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000106:	00011517          	auipc	a0,0x11
    8000010a:	72a50513          	addi	a0,a0,1834 # 80011830 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	b9e080e7          	jalr	-1122(ra) # 80000cac <acquire>
  for(i = 0; i < n; i++){
    80000116:	05305b63          	blez	s3,8000016c <consolewrite+0x7e>
    8000011a:	4481                	li	s1,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011c:	5afd                	li	s5,-1
    8000011e:	4685                	li	a3,1
    80000120:	864a                	mv	a2,s2
    80000122:	85d2                	mv	a1,s4
    80000124:	fbf40513          	addi	a0,s0,-65
    80000128:	00002097          	auipc	ra,0x2
    8000012c:	468080e7          	jalr	1128(ra) # 80002590 <either_copyin>
    80000130:	01550c63          	beq	a0,s5,80000148 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	7ee080e7          	jalr	2030(ra) # 80000926 <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2485                	addiw	s1,s1,1
    80000142:	0905                	addi	s2,s2,1
    80000144:	fc999de3          	bne	s3,s1,8000011e <consolewrite+0x30>
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	c10080e7          	jalr	-1008(ra) # 80000d60 <release>

  return i;
}
    80000158:	8526                	mv	a0,s1
    8000015a:	60a6                	ld	ra,72(sp)
    8000015c:	6406                	ld	s0,64(sp)
    8000015e:	74e2                	ld	s1,56(sp)
    80000160:	7942                	ld	s2,48(sp)
    80000162:	79a2                	ld	s3,40(sp)
    80000164:	7a02                	ld	s4,32(sp)
    80000166:	6ae2                	ld	s5,24(sp)
    80000168:	6161                	addi	sp,sp,80
    8000016a:	8082                	ret
  for(i = 0; i < n; i++){
    8000016c:	4481                	li	s1,0
    8000016e:	bfe9                	j	80000148 <consolewrite+0x5a>

0000000080000170 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	7119                	addi	sp,sp,-128
    80000172:	fc86                	sd	ra,120(sp)
    80000174:	f8a2                	sd	s0,112(sp)
    80000176:	f4a6                	sd	s1,104(sp)
    80000178:	f0ca                	sd	s2,96(sp)
    8000017a:	ecce                	sd	s3,88(sp)
    8000017c:	e8d2                	sd	s4,80(sp)
    8000017e:	e4d6                	sd	s5,72(sp)
    80000180:	e0da                	sd	s6,64(sp)
    80000182:	fc5e                	sd	s7,56(sp)
    80000184:	f862                	sd	s8,48(sp)
    80000186:	f466                	sd	s9,40(sp)
    80000188:	f06a                	sd	s10,32(sp)
    8000018a:	ec6e                	sd	s11,24(sp)
    8000018c:	0100                	addi	s0,sp,128
    8000018e:	8caa                	mv	s9,a0
    80000190:	8aae                	mv	s5,a1
    80000192:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000194:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000198:	00011517          	auipc	a0,0x11
    8000019c:	69850513          	addi	a0,a0,1688 # 80011830 <cons>
    800001a0:	00001097          	auipc	ra,0x1
    800001a4:	b0c080e7          	jalr	-1268(ra) # 80000cac <acquire>
  while(n > 0){
    800001a8:	09405663          	blez	s4,80000234 <consoleread+0xc4>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001ac:	00011497          	auipc	s1,0x11
    800001b0:	68448493          	addi	s1,s1,1668 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	89a6                	mv	s3,s1
    800001b6:	00011917          	auipc	s2,0x11
    800001ba:	71290913          	addi	s2,s2,1810 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001be:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001c2:	4da9                	li	s11,10
    while(cons.r == cons.w){
    800001c4:	0984a783          	lw	a5,152(s1)
    800001c8:	09c4a703          	lw	a4,156(s1)
    800001cc:	02f71463          	bne	a4,a5,800001f4 <consoleread+0x84>
      if(myproc()->killed){
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	8ea080e7          	jalr	-1814(ra) # 80001aba <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	0f8080e7          	jalr	248(ra) # 800022d8 <sleep>
    while(cons.r == cons.w){
    800001e8:	0984a783          	lw	a5,152(s1)
    800001ec:	09c4a703          	lw	a4,156(s1)
    800001f0:	fef700e3          	beq	a4,a5,800001d0 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f4:	0017871b          	addiw	a4,a5,1
    800001f8:	08e4ac23          	sw	a4,152(s1)
    800001fc:	07f7f713          	andi	a4,a5,127
    80000200:	9726                	add	a4,a4,s1
    80000202:	01874703          	lbu	a4,24(a4)
    80000206:	00070b9b          	sext.w	s7,a4
    if(c == C('D')){  // end-of-file
    8000020a:	078b8863          	beq	s7,s8,8000027a <consoleread+0x10a>
    cbuf = c;
    8000020e:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000212:	4685                	li	a3,1
    80000214:	f8f40613          	addi	a2,s0,-113
    80000218:	85d6                	mv	a1,s5
    8000021a:	8566                	mv	a0,s9
    8000021c:	00002097          	auipc	ra,0x2
    80000220:	31e080e7          	jalr	798(ra) # 8000253a <either_copyout>
    80000224:	01a50863          	beq	a0,s10,80000234 <consoleread+0xc4>
    dst++;
    80000228:	0a85                	addi	s5,s5,1
    --n;
    8000022a:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022c:	01bb8463          	beq	s7,s11,80000234 <consoleread+0xc4>
  while(n > 0){
    80000230:	f80a1ae3          	bnez	s4,800001c4 <consoleread+0x54>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000234:	00011517          	auipc	a0,0x11
    80000238:	5fc50513          	addi	a0,a0,1532 # 80011830 <cons>
    8000023c:	00001097          	auipc	ra,0x1
    80000240:	b24080e7          	jalr	-1244(ra) # 80000d60 <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b0e080e7          	jalr	-1266(ra) # 80000d60 <release>
        return -1;
    8000025a:	557d                	li	a0,-1
}
    8000025c:	70e6                	ld	ra,120(sp)
    8000025e:	7446                	ld	s0,112(sp)
    80000260:	74a6                	ld	s1,104(sp)
    80000262:	7906                	ld	s2,96(sp)
    80000264:	69e6                	ld	s3,88(sp)
    80000266:	6a46                	ld	s4,80(sp)
    80000268:	6aa6                	ld	s5,72(sp)
    8000026a:	6b06                	ld	s6,64(sp)
    8000026c:	7be2                	ld	s7,56(sp)
    8000026e:	7c42                	ld	s8,48(sp)
    80000270:	7ca2                	ld	s9,40(sp)
    80000272:	7d02                	ld	s10,32(sp)
    80000274:	6de2                	ld	s11,24(sp)
    80000276:	6109                	addi	sp,sp,128
    80000278:	8082                	ret
      if(n < target){
    8000027a:	000a071b          	sext.w	a4,s4
    8000027e:	fb677be3          	bleu	s6,a4,80000234 <consoleread+0xc4>
        cons.r--;
    80000282:	00011717          	auipc	a4,0x11
    80000286:	64f72323          	sw	a5,1606(a4) # 800118c8 <cons+0x98>
    8000028a:	b76d                	j	80000234 <consoleread+0xc4>

000000008000028c <consputc>:
{
    8000028c:	1141                	addi	sp,sp,-16
    8000028e:	e406                	sd	ra,8(sp)
    80000290:	e022                	sd	s0,0(sp)
    80000292:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000294:	10000793          	li	a5,256
    80000298:	00f50a63          	beq	a0,a5,800002ac <consputc+0x20>
    uartputc_sync(c);
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	58a080e7          	jalr	1418(ra) # 80000826 <uartputc_sync>
}
    800002a4:	60a2                	ld	ra,8(sp)
    800002a6:	6402                	ld	s0,0(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	578080e7          	jalr	1400(ra) # 80000826 <uartputc_sync>
    800002b6:	02000513          	li	a0,32
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	56c080e7          	jalr	1388(ra) # 80000826 <uartputc_sync>
    800002c2:	4521                	li	a0,8
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	562080e7          	jalr	1378(ra) # 80000826 <uartputc_sync>
    800002cc:	bfe1                	j	800002a4 <consputc+0x18>

00000000800002ce <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ce:	1101                	addi	sp,sp,-32
    800002d0:	ec06                	sd	ra,24(sp)
    800002d2:	e822                	sd	s0,16(sp)
    800002d4:	e426                	sd	s1,8(sp)
    800002d6:	e04a                	sd	s2,0(sp)
    800002d8:	1000                	addi	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	55450513          	addi	a0,a0,1364 # 80011830 <cons>
    800002e4:	00001097          	auipc	ra,0x1
    800002e8:	9c8080e7          	jalr	-1592(ra) # 80000cac <acquire>

  switch(c){
    800002ec:	47c1                	li	a5,16
    800002ee:	12f48463          	beq	s1,a5,80000416 <consoleintr+0x148>
    800002f2:	0297df63          	ble	s1,a5,80000330 <consoleintr+0x62>
    800002f6:	47d5                	li	a5,21
    800002f8:	0af48863          	beq	s1,a5,800003a8 <consoleintr+0xda>
    800002fc:	07f00793          	li	a5,127
    80000300:	02f49b63          	bne	s1,a5,80000336 <consoleintr+0x68>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f':
    if(cons.e != cons.w){
    80000304:	00011717          	auipc	a4,0x11
    80000308:	52c70713          	addi	a4,a4,1324 # 80011830 <cons>
    8000030c:	0a072783          	lw	a5,160(a4)
    80000310:	09c72703          	lw	a4,156(a4)
    80000314:	10f70563          	beq	a4,a5,8000041e <consoleintr+0x150>
      cons.e--;
    80000318:	37fd                	addiw	a5,a5,-1
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	5af72b23          	sw	a5,1462(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    80000322:	10000513          	li	a0,256
    80000326:	00000097          	auipc	ra,0x0
    8000032a:	f66080e7          	jalr	-154(ra) # 8000028c <consputc>
    8000032e:	a8c5                	j	8000041e <consoleintr+0x150>
  switch(c){
    80000330:	47a1                	li	a5,8
    80000332:	fcf489e3          	beq	s1,a5,80000304 <consoleintr+0x36>
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000336:	c4e5                	beqz	s1,8000041e <consoleintr+0x150>
    80000338:	00011717          	auipc	a4,0x11
    8000033c:	4f870713          	addi	a4,a4,1272 # 80011830 <cons>
    80000340:	0a072783          	lw	a5,160(a4)
    80000344:	09872703          	lw	a4,152(a4)
    80000348:	9f99                	subw	a5,a5,a4
    8000034a:	07f00713          	li	a4,127
    8000034e:	0cf76863          	bltu	a4,a5,8000041e <consoleintr+0x150>
      c = (c == '\r') ? '\n' : c;
    80000352:	47b5                	li	a5,13
    80000354:	0ef48363          	beq	s1,a5,8000043a <consoleintr+0x16c>

      // echo back to the user.
      consputc(c);
    80000358:	8526                	mv	a0,s1
    8000035a:	00000097          	auipc	ra,0x0
    8000035e:	f32080e7          	jalr	-206(ra) # 8000028c <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000362:	00011797          	auipc	a5,0x11
    80000366:	4ce78793          	addi	a5,a5,1230 # 80011830 <cons>
    8000036a:	0a07a703          	lw	a4,160(a5)
    8000036e:	0017069b          	addiw	a3,a4,1
    80000372:	0006861b          	sext.w	a2,a3
    80000376:	0ad7a023          	sw	a3,160(a5)
    8000037a:	07f77713          	andi	a4,a4,127
    8000037e:	97ba                	add	a5,a5,a4
    80000380:	00978c23          	sb	s1,24(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000384:	47a9                	li	a5,10
    80000386:	0ef48163          	beq	s1,a5,80000468 <consoleintr+0x19a>
    8000038a:	4791                	li	a5,4
    8000038c:	0cf48e63          	beq	s1,a5,80000468 <consoleintr+0x19a>
    80000390:	00011797          	auipc	a5,0x11
    80000394:	4a078793          	addi	a5,a5,1184 # 80011830 <cons>
    80000398:	0987a783          	lw	a5,152(a5)
    8000039c:	0807879b          	addiw	a5,a5,128
    800003a0:	06f61f63          	bne	a2,a5,8000041e <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003a4:	863e                	mv	a2,a5
    800003a6:	a0c9                	j	80000468 <consoleintr+0x19a>
    while(cons.e != cons.w &&
    800003a8:	00011717          	auipc	a4,0x11
    800003ac:	48870713          	addi	a4,a4,1160 # 80011830 <cons>
    800003b0:	0a072783          	lw	a5,160(a4)
    800003b4:	09c72703          	lw	a4,156(a4)
    800003b8:	06f70363          	beq	a4,a5,8000041e <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003bc:	37fd                	addiw	a5,a5,-1
    800003be:	0007871b          	sext.w	a4,a5
    800003c2:	07f7f793          	andi	a5,a5,127
    800003c6:	00011697          	auipc	a3,0x11
    800003ca:	46a68693          	addi	a3,a3,1130 # 80011830 <cons>
    800003ce:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    800003d0:	0187c683          	lbu	a3,24(a5)
    800003d4:	47a9                	li	a5,10
      cons.e--;
    800003d6:	00011497          	auipc	s1,0x11
    800003da:	45a48493          	addi	s1,s1,1114 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003de:	4929                	li	s2,10
    800003e0:	02f68f63          	beq	a3,a5,8000041e <consoleintr+0x150>
      cons.e--;
    800003e4:	0ae4a023          	sw	a4,160(s1)
      consputc(BACKSPACE);
    800003e8:	10000513          	li	a0,256
    800003ec:	00000097          	auipc	ra,0x0
    800003f0:	ea0080e7          	jalr	-352(ra) # 8000028c <consputc>
    while(cons.e != cons.w &&
    800003f4:	0a04a783          	lw	a5,160(s1)
    800003f8:	09c4a703          	lw	a4,156(s1)
    800003fc:	02f70163          	beq	a4,a5,8000041e <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000400:	37fd                	addiw	a5,a5,-1
    80000402:	0007871b          	sext.w	a4,a5
    80000406:	07f7f793          	andi	a5,a5,127
    8000040a:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    8000040c:	0187c783          	lbu	a5,24(a5)
    80000410:	fd279ae3          	bne	a5,s2,800003e4 <consoleintr+0x116>
    80000414:	a029                	j	8000041e <consoleintr+0x150>
    procdump();
    80000416:	00002097          	auipc	ra,0x2
    8000041a:	1d0080e7          	jalr	464(ra) # 800025e6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	93a080e7          	jalr	-1734(ra) # 80000d60 <release>
}
    8000042e:	60e2                	ld	ra,24(sp)
    80000430:	6442                	ld	s0,16(sp)
    80000432:	64a2                	ld	s1,8(sp)
    80000434:	6902                	ld	s2,0(sp)
    80000436:	6105                	addi	sp,sp,32
    80000438:	8082                	ret
      consputc(c);
    8000043a:	4529                	li	a0,10
    8000043c:	00000097          	auipc	ra,0x0
    80000440:	e50080e7          	jalr	-432(ra) # 8000028c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000444:	00011797          	auipc	a5,0x11
    80000448:	3ec78793          	addi	a5,a5,1004 # 80011830 <cons>
    8000044c:	0a07a703          	lw	a4,160(a5)
    80000450:	0017069b          	addiw	a3,a4,1
    80000454:	0006861b          	sext.w	a2,a3
    80000458:	0ad7a023          	sw	a3,160(a5)
    8000045c:	07f77713          	andi	a4,a4,127
    80000460:	97ba                	add	a5,a5,a4
    80000462:	4729                	li	a4,10
    80000464:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000468:	00011797          	auipc	a5,0x11
    8000046c:	46c7a223          	sw	a2,1124(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000470:	00011517          	auipc	a0,0x11
    80000474:	45850513          	addi	a0,a0,1112 # 800118c8 <cons+0x98>
    80000478:	00002097          	auipc	ra,0x2
    8000047c:	fe6080e7          	jalr	-26(ra) # 8000245e <wakeup>
    80000480:	bf79                	j	8000041e <consoleintr+0x150>

0000000080000482 <consoleinit>:

void
consoleinit(void)
{
    80000482:	1141                	addi	sp,sp,-16
    80000484:	e406                	sd	ra,8(sp)
    80000486:	e022                	sd	s0,0(sp)
    80000488:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000048a:	00008597          	auipc	a1,0x8
    8000048e:	b8658593          	addi	a1,a1,-1146 # 80008010 <etext+0x10>
    80000492:	00011517          	auipc	a0,0x11
    80000496:	39e50513          	addi	a0,a0,926 # 80011830 <cons>
    8000049a:	00000097          	auipc	ra,0x0
    8000049e:	782080e7          	jalr	1922(ra) # 80000c1c <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	334080e7          	jalr	820(ra) # 800007d6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00021797          	auipc	a5,0x21
    800004ae:	70678793          	addi	a5,a5,1798 # 80021bb0 <devsw>
    800004b2:	00000717          	auipc	a4,0x0
    800004b6:	cbe70713          	addi	a4,a4,-834 # 80000170 <consoleread>
    800004ba:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004bc:	00000717          	auipc	a4,0x0
    800004c0:	c3270713          	addi	a4,a4,-974 # 800000ee <consolewrite>
    800004c4:	ef98                	sd	a4,24(a5)
}
    800004c6:	60a2                	ld	ra,8(sp)
    800004c8:	6402                	ld	s0,0(sp)
    800004ca:	0141                	addi	sp,sp,16
    800004cc:	8082                	ret

00000000800004ce <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ce:	7179                	addi	sp,sp,-48
    800004d0:	f406                	sd	ra,40(sp)
    800004d2:	f022                	sd	s0,32(sp)
    800004d4:	ec26                	sd	s1,24(sp)
    800004d6:	e84a                	sd	s2,16(sp)
    800004d8:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004da:	c219                	beqz	a2,800004e0 <printint+0x12>
    800004dc:	00054d63          	bltz	a0,800004f6 <printint+0x28>
    x = -xx;
  else
    x = xx;
    800004e0:	2501                	sext.w	a0,a0
    800004e2:	4881                	li	a7,0
    800004e4:	fd040713          	addi	a4,s0,-48

  i = 0;
    800004e8:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    800004ea:	2581                	sext.w	a1,a1
    800004ec:	00008817          	auipc	a6,0x8
    800004f0:	b2c80813          	addi	a6,a6,-1236 # 80008018 <digits>
    800004f4:	a801                	j	80000504 <printint+0x36>
    x = -xx;
    800004f6:	40a0053b          	negw	a0,a0
    800004fa:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    800004fc:	4885                	li	a7,1
    x = -xx;
    800004fe:	b7dd                	j	800004e4 <printint+0x16>
  } while((x /= base) != 0);
    80000500:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    80000502:	8636                	mv	a2,a3
    80000504:	0016069b          	addiw	a3,a2,1
    80000508:	02b577bb          	remuw	a5,a0,a1
    8000050c:	1782                	slli	a5,a5,0x20
    8000050e:	9381                	srli	a5,a5,0x20
    80000510:	97c2                	add	a5,a5,a6
    80000512:	0007c783          	lbu	a5,0(a5)
    80000516:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    8000051a:	0705                	addi	a4,a4,1
    8000051c:	02b557bb          	divuw	a5,a0,a1
    80000520:	feb570e3          	bleu	a1,a0,80000500 <printint+0x32>

  if(sign)
    80000524:	00088b63          	beqz	a7,8000053a <printint+0x6c>
    buf[i++] = '-';
    80000528:	fe040793          	addi	a5,s0,-32
    8000052c:	96be                	add	a3,a3,a5
    8000052e:	02d00793          	li	a5,45
    80000532:	fef68823          	sb	a5,-16(a3)
    80000536:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    8000053a:	02d05763          	blez	a3,80000568 <printint+0x9a>
    8000053e:	fd040793          	addi	a5,s0,-48
    80000542:	00d784b3          	add	s1,a5,a3
    80000546:	fff78913          	addi	s2,a5,-1
    8000054a:	9936                	add	s2,s2,a3
    8000054c:	36fd                	addiw	a3,a3,-1
    8000054e:	1682                	slli	a3,a3,0x20
    80000550:	9281                	srli	a3,a3,0x20
    80000552:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    80000556:	fff4c503          	lbu	a0,-1(s1)
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	d32080e7          	jalr	-718(ra) # 8000028c <consputc>
  while(--i >= 0)
    80000562:	14fd                	addi	s1,s1,-1
    80000564:	ff2499e3          	bne	s1,s2,80000556 <printint+0x88>
}
    80000568:	70a2                	ld	ra,40(sp)
    8000056a:	7402                	ld	s0,32(sp)
    8000056c:	64e2                	ld	s1,24(sp)
    8000056e:	6942                	ld	s2,16(sp)
    80000570:	6145                	addi	sp,sp,48
    80000572:	8082                	ret

0000000080000574 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000574:	1101                	addi	sp,sp,-32
    80000576:	ec06                	sd	ra,24(sp)
    80000578:	e822                	sd	s0,16(sp)
    8000057a:	e426                	sd	s1,8(sp)
    8000057c:	1000                	addi	s0,sp,32
    8000057e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000580:	00011797          	auipc	a5,0x11
    80000584:	3607a823          	sw	zero,880(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000588:	00008517          	auipc	a0,0x8
    8000058c:	aa850513          	addi	a0,a0,-1368 # 80008030 <digits+0x18>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	02e080e7          	jalr	46(ra) # 800005be <printf>
  printf(s);
    80000598:	8526                	mv	a0,s1
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	024080e7          	jalr	36(ra) # 800005be <printf>
  printf("\n");
    800005a2:	00008517          	auipc	a0,0x8
    800005a6:	b2650513          	addi	a0,a0,-1242 # 800080c8 <digits+0xb0>
    800005aa:	00000097          	auipc	ra,0x0
    800005ae:	014080e7          	jalr	20(ra) # 800005be <printf>
  panicked = 1; // freeze uart output from other CPUs
    800005b2:	4785                	li	a5,1
    800005b4:	00009717          	auipc	a4,0x9
    800005b8:	a4f72623          	sw	a5,-1460(a4) # 80009000 <panicked>
  for(;;)
    800005bc:	a001                	j	800005bc <panic+0x48>

00000000800005be <printf>:
{
    800005be:	7131                	addi	sp,sp,-192
    800005c0:	fc86                	sd	ra,120(sp)
    800005c2:	f8a2                	sd	s0,112(sp)
    800005c4:	f4a6                	sd	s1,104(sp)
    800005c6:	f0ca                	sd	s2,96(sp)
    800005c8:	ecce                	sd	s3,88(sp)
    800005ca:	e8d2                	sd	s4,80(sp)
    800005cc:	e4d6                	sd	s5,72(sp)
    800005ce:	e0da                	sd	s6,64(sp)
    800005d0:	fc5e                	sd	s7,56(sp)
    800005d2:	f862                	sd	s8,48(sp)
    800005d4:	f466                	sd	s9,40(sp)
    800005d6:	f06a                	sd	s10,32(sp)
    800005d8:	ec6e                	sd	s11,24(sp)
    800005da:	0100                	addi	s0,sp,128
    800005dc:	8aaa                	mv	s5,a0
    800005de:	e40c                	sd	a1,8(s0)
    800005e0:	e810                	sd	a2,16(s0)
    800005e2:	ec14                	sd	a3,24(s0)
    800005e4:	f018                	sd	a4,32(s0)
    800005e6:	f41c                	sd	a5,40(s0)
    800005e8:	03043823          	sd	a6,48(s0)
    800005ec:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005f0:	00011797          	auipc	a5,0x11
    800005f4:	2e878793          	addi	a5,a5,744 # 800118d8 <pr>
    800005f8:	0187ad83          	lw	s11,24(a5)
  if(locking)
    800005fc:	020d9b63          	bnez	s11,80000632 <printf+0x74>
  if (fmt == 0)
    80000600:	020a8f63          	beqz	s5,8000063e <printf+0x80>
  va_start(ap, fmt);
    80000604:	00840793          	addi	a5,s0,8
    80000608:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060c:	000ac503          	lbu	a0,0(s5)
    80000610:	16050063          	beqz	a0,80000770 <printf+0x1b2>
    80000614:	4481                	li	s1,0
    if(c != '%'){
    80000616:	02500a13          	li	s4,37
    switch(c){
    8000061a:	07000b13          	li	s6,112
  consputc('x');
    8000061e:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000620:	00008b97          	auipc	s7,0x8
    80000624:	9f8b8b93          	addi	s7,s7,-1544 # 80008018 <digits>
    switch(c){
    80000628:	07300c93          	li	s9,115
    8000062c:	06400c13          	li	s8,100
    80000630:	a815                	j	80000664 <printf+0xa6>
    acquire(&pr.lock);
    80000632:	853e                	mv	a0,a5
    80000634:	00000097          	auipc	ra,0x0
    80000638:	678080e7          	jalr	1656(ra) # 80000cac <acquire>
    8000063c:	b7d1                	j	80000600 <printf+0x42>
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	a0250513          	addi	a0,a0,-1534 # 80008040 <digits+0x28>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f2e080e7          	jalr	-210(ra) # 80000574 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c3e080e7          	jalr	-962(ra) # 8000028c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2485                	addiw	s1,s1,1
    80000658:	009a87b3          	add	a5,s5,s1
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050863          	beqz	a0,80000770 <printf+0x1b2>
    if(c != '%'){
    80000664:	ff4515e3          	bne	a0,s4,8000064e <printf+0x90>
    c = fmt[++i] & 0xff;
    80000668:	2485                	addiw	s1,s1,1
    8000066a:	009a87b3          	add	a5,s5,s1
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000676:	0e090d63          	beqz	s2,80000770 <printf+0x1b2>
    switch(c){
    8000067a:	05678a63          	beq	a5,s6,800006ce <printf+0x110>
    8000067e:	02fb7663          	bleu	a5,s6,800006aa <printf+0xec>
    80000682:	09978963          	beq	a5,s9,80000714 <printf+0x156>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79863          	bne	a5,a4,8000075a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85ea                	mv	a1,s10
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e2e080e7          	jalr	-466(ra) # 800004ce <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0x98>
    switch(c){
    800006aa:	0b478263          	beq	a5,s4,8000074e <printf+0x190>
    800006ae:	0b879663          	bne	a5,s8,8000075a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	e0a080e7          	jalr	-502(ra) # 800004ce <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0x98>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	baa080e7          	jalr	-1110(ra) # 8000028c <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	b9e080e7          	jalr	-1122(ra) # 8000028c <consputc>
    800006f6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c9d793          	srli	a5,s3,0x3c
    800006fc:	97de                	add	a5,a5,s7
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b8a080e7          	jalr	-1142(ra) # 8000028c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0992                	slli	s3,s3,0x4
    8000070c:	397d                	addiw	s2,s2,-1
    8000070e:	fe0915e3          	bnez	s2,800006f8 <printf+0x13a>
    80000712:	b791                	j	80000656 <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    80000714:	f8843783          	ld	a5,-120(s0)
    80000718:	00878713          	addi	a4,a5,8
    8000071c:	f8e43423          	sd	a4,-120(s0)
    80000720:	0007b903          	ld	s2,0(a5)
    80000724:	00090e63          	beqz	s2,80000740 <printf+0x182>
      for(; *s; s++)
    80000728:	00094503          	lbu	a0,0(s2)
    8000072c:	d50d                	beqz	a0,80000656 <printf+0x98>
        consputc(*s);
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b5e080e7          	jalr	-1186(ra) # 8000028c <consputc>
      for(; *s; s++)
    80000736:	0905                	addi	s2,s2,1
    80000738:	00094503          	lbu	a0,0(s2)
    8000073c:	f96d                	bnez	a0,8000072e <printf+0x170>
    8000073e:	bf21                	j	80000656 <printf+0x98>
        s = "(null)";
    80000740:	00008917          	auipc	s2,0x8
    80000744:	8f890913          	addi	s2,s2,-1800 # 80008038 <digits+0x20>
      for(; *s; s++)
    80000748:	02800513          	li	a0,40
    8000074c:	b7cd                	j	8000072e <printf+0x170>
      consputc('%');
    8000074e:	8552                	mv	a0,s4
    80000750:	00000097          	auipc	ra,0x0
    80000754:	b3c080e7          	jalr	-1220(ra) # 8000028c <consputc>
      break;
    80000758:	bdfd                	j	80000656 <printf+0x98>
      consputc('%');
    8000075a:	8552                	mv	a0,s4
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	b30080e7          	jalr	-1232(ra) # 8000028c <consputc>
      consputc(c);
    80000764:	854a                	mv	a0,s2
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	b26080e7          	jalr	-1242(ra) # 8000028c <consputc>
      break;
    8000076e:	b5e5                	j	80000656 <printf+0x98>
  if(locking)
    80000770:	020d9163          	bnez	s11,80000792 <printf+0x1d4>
}
    80000774:	70e6                	ld	ra,120(sp)
    80000776:	7446                	ld	s0,112(sp)
    80000778:	74a6                	ld	s1,104(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	69e6                	ld	s3,88(sp)
    8000077e:	6a46                	ld	s4,80(sp)
    80000780:	6aa6                	ld	s5,72(sp)
    80000782:	6b06                	ld	s6,64(sp)
    80000784:	7be2                	ld	s7,56(sp)
    80000786:	7c42                	ld	s8,48(sp)
    80000788:	7ca2                	ld	s9,40(sp)
    8000078a:	7d02                	ld	s10,32(sp)
    8000078c:	6de2                	ld	s11,24(sp)
    8000078e:	6129                	addi	sp,sp,192
    80000790:	8082                	ret
    release(&pr.lock);
    80000792:	00011517          	auipc	a0,0x11
    80000796:	14650513          	addi	a0,a0,326 # 800118d8 <pr>
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	5c6080e7          	jalr	1478(ra) # 80000d60 <release>
}
    800007a2:	bfc9                	j	80000774 <printf+0x1b6>

00000000800007a4 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007a4:	1101                	addi	sp,sp,-32
    800007a6:	ec06                	sd	ra,24(sp)
    800007a8:	e822                	sd	s0,16(sp)
    800007aa:	e426                	sd	s1,8(sp)
    800007ac:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007ae:	00011497          	auipc	s1,0x11
    800007b2:	12a48493          	addi	s1,s1,298 # 800118d8 <pr>
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	89a58593          	addi	a1,a1,-1894 # 80008050 <digits+0x38>
    800007be:	8526                	mv	a0,s1
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	45c080e7          	jalr	1116(ra) # 80000c1c <initlock>
  pr.locking = 1;
    800007c8:	4785                	li	a5,1
    800007ca:	cc9c                	sw	a5,24(s1)
}
    800007cc:	60e2                	ld	ra,24(sp)
    800007ce:	6442                	ld	s0,16(sp)
    800007d0:	64a2                	ld	s1,8(sp)
    800007d2:	6105                	addi	sp,sp,32
    800007d4:	8082                	ret

00000000800007d6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007d6:	1141                	addi	sp,sp,-16
    800007d8:	e406                	sd	ra,8(sp)
    800007da:	e022                	sd	s0,0(sp)
    800007dc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007de:	100007b7          	lui	a5,0x10000
    800007e2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007e6:	f8000713          	li	a4,-128
    800007ea:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ee:	470d                	li	a4,3
    800007f0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007f4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007f8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007fc:	469d                	li	a3,7
    800007fe:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000802:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000806:	00008597          	auipc	a1,0x8
    8000080a:	85258593          	addi	a1,a1,-1966 # 80008058 <digits+0x40>
    8000080e:	00011517          	auipc	a0,0x11
    80000812:	0ea50513          	addi	a0,a0,234 # 800118f8 <uart_tx_lock>
    80000816:	00000097          	auipc	ra,0x0
    8000081a:	406080e7          	jalr	1030(ra) # 80000c1c <initlock>
}
    8000081e:	60a2                	ld	ra,8(sp)
    80000820:	6402                	ld	s0,0(sp)
    80000822:	0141                	addi	sp,sp,16
    80000824:	8082                	ret

0000000080000826 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000826:	1101                	addi	sp,sp,-32
    80000828:	ec06                	sd	ra,24(sp)
    8000082a:	e822                	sd	s0,16(sp)
    8000082c:	e426                	sd	s1,8(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	84aa                	mv	s1,a0
  push_off();
    80000832:	00000097          	auipc	ra,0x0
    80000836:	42e080e7          	jalr	1070(ra) # 80000c60 <push_off>

  if(panicked){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7c678793          	addi	a5,a5,1990 # 80009000 <panicked>
    80000842:	439c                	lw	a5,0(a5)
    80000844:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000846:	10000737          	lui	a4,0x10000
  if(panicked){
    8000084a:	c391                	beqz	a5,8000084e <uartputc_sync+0x28>
    for(;;)
    8000084c:	a001                	j	8000084c <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000084e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000852:	0ff7f793          	andi	a5,a5,255
    80000856:	0207f793          	andi	a5,a5,32
    8000085a:	dbf5                	beqz	a5,8000084e <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    8000085c:	0ff4f793          	andi	a5,s1,255
    80000860:	10000737          	lui	a4,0x10000
    80000864:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000868:	00000097          	auipc	ra,0x0
    8000086c:	498080e7          	jalr	1176(ra) # 80000d00 <pop_off>
}
    80000870:	60e2                	ld	ra,24(sp)
    80000872:	6442                	ld	s0,16(sp)
    80000874:	64a2                	ld	s1,8(sp)
    80000876:	6105                	addi	sp,sp,32
    80000878:	8082                	ret

000000008000087a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008797          	auipc	a5,0x8
    8000087e:	78a78793          	addi	a5,a5,1930 # 80009004 <uart_tx_r>
    80000882:	439c                	lw	a5,0(a5)
    80000884:	00008717          	auipc	a4,0x8
    80000888:	78470713          	addi	a4,a4,1924 # 80009008 <uart_tx_w>
    8000088c:	4318                	lw	a4,0(a4)
    8000088e:	08f70b63          	beq	a4,a5,80000924 <uartstart+0xaa>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000892:	10000737          	lui	a4,0x10000
    80000896:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000089a:	0ff77713          	andi	a4,a4,255
    8000089e:	02077713          	andi	a4,a4,32
    800008a2:	c349                	beqz	a4,80000924 <uartstart+0xaa>
{
    800008a4:	7139                	addi	sp,sp,-64
    800008a6:	fc06                	sd	ra,56(sp)
    800008a8:	f822                	sd	s0,48(sp)
    800008aa:	f426                	sd	s1,40(sp)
    800008ac:	f04a                	sd	s2,32(sp)
    800008ae:	ec4e                	sd	s3,24(sp)
    800008b0:	e852                	sd	s4,16(sp)
    800008b2:	e456                	sd	s5,8(sp)
    800008b4:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008b6:	00011a17          	auipc	s4,0x11
    800008ba:	042a0a13          	addi	s4,s4,66 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008be:	00008497          	auipc	s1,0x8
    800008c2:	74648493          	addi	s1,s1,1862 # 80009004 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008c6:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ca:	00008997          	auipc	s3,0x8
    800008ce:	73e98993          	addi	s3,s3,1854 # 80009008 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r];
    800008d2:	00fa0733          	add	a4,s4,a5
    800008d6:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008da:	2785                	addiw	a5,a5,1
    800008dc:	41f7d71b          	sraiw	a4,a5,0x1f
    800008e0:	01b7571b          	srliw	a4,a4,0x1b
    800008e4:	9fb9                	addw	a5,a5,a4
    800008e6:	8bfd                	andi	a5,a5,31
    800008e8:	9f99                	subw	a5,a5,a4
    800008ea:	c09c                	sw	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ec:	8526                	mv	a0,s1
    800008ee:	00002097          	auipc	ra,0x2
    800008f2:	b70080e7          	jalr	-1168(ra) # 8000245e <wakeup>
    WriteReg(THR, c);
    800008f6:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fa:	409c                	lw	a5,0(s1)
    800008fc:	0009a703          	lw	a4,0(s3)
    80000900:	00f70963          	beq	a4,a5,80000912 <uartstart+0x98>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000904:	00594703          	lbu	a4,5(s2)
    80000908:	0ff77713          	andi	a4,a4,255
    8000090c:	02077713          	andi	a4,a4,32
    80000910:	f369                	bnez	a4,800008d2 <uartstart+0x58>
  }
}
    80000912:	70e2                	ld	ra,56(sp)
    80000914:	7442                	ld	s0,48(sp)
    80000916:	74a2                	ld	s1,40(sp)
    80000918:	7902                	ld	s2,32(sp)
    8000091a:	69e2                	ld	s3,24(sp)
    8000091c:	6a42                	ld	s4,16(sp)
    8000091e:	6aa2                	ld	s5,8(sp)
    80000920:	6121                	addi	sp,sp,64
    80000922:	8082                	ret
    80000924:	8082                	ret

0000000080000926 <uartputc>:
{
    80000926:	7179                	addi	sp,sp,-48
    80000928:	f406                	sd	ra,40(sp)
    8000092a:	f022                	sd	s0,32(sp)
    8000092c:	ec26                	sd	s1,24(sp)
    8000092e:	e84a                	sd	s2,16(sp)
    80000930:	e44e                	sd	s3,8(sp)
    80000932:	e052                	sd	s4,0(sp)
    80000934:	1800                	addi	s0,sp,48
    80000936:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000938:	00011517          	auipc	a0,0x11
    8000093c:	fc050513          	addi	a0,a0,-64 # 800118f8 <uart_tx_lock>
    80000940:	00000097          	auipc	ra,0x0
    80000944:	36c080e7          	jalr	876(ra) # 80000cac <acquire>
  if(panicked){
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	6b878793          	addi	a5,a5,1720 # 80009000 <panicked>
    80000950:	439c                	lw	a5,0(a5)
    80000952:	2781                	sext.w	a5,a5
    80000954:	c391                	beqz	a5,80000958 <uartputc+0x32>
    for(;;)
    80000956:	a001                	j	80000956 <uartputc+0x30>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00008797          	auipc	a5,0x8
    8000095c:	6b078793          	addi	a5,a5,1712 # 80009008 <uart_tx_w>
    80000960:	4398                	lw	a4,0(a5)
    80000962:	0017079b          	addiw	a5,a4,1
    80000966:	41f7d69b          	sraiw	a3,a5,0x1f
    8000096a:	01b6d69b          	srliw	a3,a3,0x1b
    8000096e:	9fb5                	addw	a5,a5,a3
    80000970:	8bfd                	andi	a5,a5,31
    80000972:	9f95                	subw	a5,a5,a3
    80000974:	00008697          	auipc	a3,0x8
    80000978:	69068693          	addi	a3,a3,1680 # 80009004 <uart_tx_r>
    8000097c:	4294                	lw	a3,0(a3)
    8000097e:	04f69263          	bne	a3,a5,800009c2 <uartputc+0x9c>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000982:	00011a17          	auipc	s4,0x11
    80000986:	f76a0a13          	addi	s4,s4,-138 # 800118f8 <uart_tx_lock>
    8000098a:	00008497          	auipc	s1,0x8
    8000098e:	67a48493          	addi	s1,s1,1658 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000992:	00008917          	auipc	s2,0x8
    80000996:	67690913          	addi	s2,s2,1654 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000099a:	85d2                	mv	a1,s4
    8000099c:	8526                	mv	a0,s1
    8000099e:	00002097          	auipc	ra,0x2
    800009a2:	93a080e7          	jalr	-1734(ra) # 800022d8 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009a6:	00092703          	lw	a4,0(s2)
    800009aa:	0017079b          	addiw	a5,a4,1
    800009ae:	41f7d69b          	sraiw	a3,a5,0x1f
    800009b2:	01b6d69b          	srliw	a3,a3,0x1b
    800009b6:	9fb5                	addw	a5,a5,a3
    800009b8:	8bfd                	andi	a5,a5,31
    800009ba:	9f95                	subw	a5,a5,a3
    800009bc:	4094                	lw	a3,0(s1)
    800009be:	fcf68ee3          	beq	a3,a5,8000099a <uartputc+0x74>
      uart_tx_buf[uart_tx_w] = c;
    800009c2:	00011497          	auipc	s1,0x11
    800009c6:	f3648493          	addi	s1,s1,-202 # 800118f8 <uart_tx_lock>
    800009ca:	9726                	add	a4,a4,s1
    800009cc:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009d0:	00008717          	auipc	a4,0x8
    800009d4:	62f72c23          	sw	a5,1592(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	ea2080e7          	jalr	-350(ra) # 8000087a <uartstart>
      release(&uart_tx_lock);
    800009e0:	8526                	mv	a0,s1
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	37e080e7          	jalr	894(ra) # 80000d60 <release>
}
    800009ea:	70a2                	ld	ra,40(sp)
    800009ec:	7402                	ld	s0,32(sp)
    800009ee:	64e2                	ld	s1,24(sp)
    800009f0:	6942                	ld	s2,16(sp)
    800009f2:	69a2                	ld	s3,8(sp)
    800009f4:	6a02                	ld	s4,0(sp)
    800009f6:	6145                	addi	sp,sp,48
    800009f8:	8082                	ret

00000000800009fa <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009fa:	1141                	addi	sp,sp,-16
    800009fc:	e422                	sd	s0,8(sp)
    800009fe:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a00:	100007b7          	lui	a5,0x10000
    80000a04:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a08:	8b85                	andi	a5,a5,1
    80000a0a:	cb91                	beqz	a5,80000a1e <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a0c:	100007b7          	lui	a5,0x10000
    80000a10:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a14:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a18:	6422                	ld	s0,8(sp)
    80000a1a:	0141                	addi	sp,sp,16
    80000a1c:	8082                	ret
    return -1;
    80000a1e:	557d                	li	a0,-1
    80000a20:	bfe5                	j	80000a18 <uartgetc+0x1e>

0000000080000a22 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a22:	1101                	addi	sp,sp,-32
    80000a24:	ec06                	sd	ra,24(sp)
    80000a26:	e822                	sd	s0,16(sp)
    80000a28:	e426                	sd	s1,8(sp)
    80000a2a:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	fcc080e7          	jalr	-52(ra) # 800009fa <uartgetc>
    if(c == -1)
    80000a36:	00950763          	beq	a0,s1,80000a44 <uartintr+0x22>
      break;
    consoleintr(c);
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	894080e7          	jalr	-1900(ra) # 800002ce <consoleintr>
  while(1){
    80000a42:	b7f5                	j	80000a2e <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a44:	00011497          	auipc	s1,0x11
    80000a48:	eb448493          	addi	s1,s1,-332 # 800118f8 <uart_tx_lock>
    80000a4c:	8526                	mv	a0,s1
    80000a4e:	00000097          	auipc	ra,0x0
    80000a52:	25e080e7          	jalr	606(ra) # 80000cac <acquire>
  uartstart();
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	e24080e7          	jalr	-476(ra) # 8000087a <uartstart>
  release(&uart_tx_lock);
    80000a5e:	8526                	mv	a0,s1
    80000a60:	00000097          	auipc	ra,0x0
    80000a64:	300080e7          	jalr	768(ra) # 80000d60 <release>
}
    80000a68:	60e2                	ld	ra,24(sp)
    80000a6a:	6442                	ld	s0,16(sp)
    80000a6c:	64a2                	ld	s1,8(sp)
    80000a6e:	6105                	addi	sp,sp,32
    80000a70:	8082                	ret

0000000080000a72 <kfree>:
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a72:	1101                	addi	sp,sp,-32
    80000a74:	ec06                	sd	ra,24(sp)
    80000a76:	e822                	sd	s0,16(sp)
    80000a78:	e426                	sd	s1,8(sp)
    80000a7a:	e04a                	sd	s2,0(sp)
    80000a7c:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	17fd                	addi	a5,a5,-1
    80000a82:	8fe9                	and	a5,a5,a0
    80000a84:	ebb9                	bnez	a5,80000ada <kfree+0x68>
    80000a86:	84aa                	mv	s1,a0
    80000a88:	00025797          	auipc	a5,0x25
    80000a8c:	57878793          	addi	a5,a5,1400 # 80026000 <end>
    80000a90:	04f56563          	bltu	a0,a5,80000ada <kfree+0x68>
    80000a94:	47c5                	li	a5,17
    80000a96:	07ee                	slli	a5,a5,0x1b
    80000a98:	04f57163          	bleu	a5,a0,80000ada <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a9c:	6605                	lui	a2,0x1
    80000a9e:	4585                	li	a1,1
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	308080e7          	jalr	776(ra) # 80000da8 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000aa8:	00011917          	auipc	s2,0x11
    80000aac:	e8890913          	addi	s2,s2,-376 # 80011930 <kmem>
    80000ab0:	854a                	mv	a0,s2
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	1fa080e7          	jalr	506(ra) # 80000cac <acquire>
  r->next = kmem.freelist;
    80000aba:	01893783          	ld	a5,24(s2)
    80000abe:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ac0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ac4:	854a                	mv	a0,s2
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	29a080e7          	jalr	666(ra) # 80000d60 <release>
}
    80000ace:	60e2                	ld	ra,24(sp)
    80000ad0:	6442                	ld	s0,16(sp)
    80000ad2:	64a2                	ld	s1,8(sp)
    80000ad4:	6902                	ld	s2,0(sp)
    80000ad6:	6105                	addi	sp,sp,32
    80000ad8:	8082                	ret
    panic("kfree");
    80000ada:	00007517          	auipc	a0,0x7
    80000ade:	58650513          	addi	a0,a0,1414 # 80008060 <digits+0x48>
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	a92080e7          	jalr	-1390(ra) # 80000574 <panic>

0000000080000aea <freerange>:
{
    80000aea:	7179                	addi	sp,sp,-48
    80000aec:	f406                	sd	ra,40(sp)
    80000aee:	f022                	sd	s0,32(sp)
    80000af0:	ec26                	sd	s1,24(sp)
    80000af2:	e84a                	sd	s2,16(sp)
    80000af4:	e44e                	sd	s3,8(sp)
    80000af6:	e052                	sd	s4,0(sp)
    80000af8:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000afa:	6705                	lui	a4,0x1
    80000afc:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b00:	00f504b3          	add	s1,a0,a5
    80000b04:	77fd                	lui	a5,0xfffff
    80000b06:	8cfd                	and	s1,s1,a5
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b08:	94ba                	add	s1,s1,a4
    80000b0a:	0095ee63          	bltu	a1,s1,80000b26 <freerange+0x3c>
    80000b0e:	892e                	mv	s2,a1
    kfree(p);
    80000b10:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b12:	6985                	lui	s3,0x1
    kfree(p);
    80000b14:	01448533          	add	a0,s1,s4
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	f5a080e7          	jalr	-166(ra) # 80000a72 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b20:	94ce                	add	s1,s1,s3
    80000b22:	fe9979e3          	bleu	s1,s2,80000b14 <freerange+0x2a>
}
    80000b26:	70a2                	ld	ra,40(sp)
    80000b28:	7402                	ld	s0,32(sp)
    80000b2a:	64e2                	ld	s1,24(sp)
    80000b2c:	6942                	ld	s2,16(sp)
    80000b2e:	69a2                	ld	s3,8(sp)
    80000b30:	6a02                	ld	s4,0(sp)
    80000b32:	6145                	addi	sp,sp,48
    80000b34:	8082                	ret

0000000080000b36 <kinit>:
{
    80000b36:	1141                	addi	sp,sp,-16
    80000b38:	e406                	sd	ra,8(sp)
    80000b3a:	e022                	sd	s0,0(sp)
    80000b3c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b3e:	00007597          	auipc	a1,0x7
    80000b42:	52a58593          	addi	a1,a1,1322 # 80008068 <digits+0x50>
    80000b46:	00011517          	auipc	a0,0x11
    80000b4a:	dea50513          	addi	a0,a0,-534 # 80011930 <kmem>
    80000b4e:	00000097          	auipc	ra,0x0
    80000b52:	0ce080e7          	jalr	206(ra) # 80000c1c <initlock>
  freerange(end, (void *)PHYSTOP);
    80000b56:	45c5                	li	a1,17
    80000b58:	05ee                	slli	a1,a1,0x1b
    80000b5a:	00025517          	auipc	a0,0x25
    80000b5e:	4a650513          	addi	a0,a0,1190 # 80026000 <end>
    80000b62:	00000097          	auipc	ra,0x0
    80000b66:	f88080e7          	jalr	-120(ra) # 80000aea <freerange>
}
    80000b6a:	60a2                	ld	ra,8(sp)
    80000b6c:	6402                	ld	s0,0(sp)
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b7c:	00011497          	auipc	s1,0x11
    80000b80:	db448493          	addi	s1,s1,-588 # 80011930 <kmem>
    80000b84:	8526                	mv	a0,s1
    80000b86:	00000097          	auipc	ra,0x0
    80000b8a:	126080e7          	jalr	294(ra) # 80000cac <acquire>
  r = kmem.freelist;
    80000b8e:	6c84                	ld	s1,24(s1)
  if (r)
    80000b90:	c885                	beqz	s1,80000bc0 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b92:	609c                	ld	a5,0(s1)
    80000b94:	00011517          	auipc	a0,0x11
    80000b98:	d9c50513          	addi	a0,a0,-612 # 80011930 <kmem>
    80000b9c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	1c2080e7          	jalr	450(ra) # 80000d60 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000ba6:	6605                	lui	a2,0x1
    80000ba8:	4595                	li	a1,5
    80000baa:	8526                	mv	a0,s1
    80000bac:	00000097          	auipc	ra,0x0
    80000bb0:	1fc080e7          	jalr	508(ra) # 80000da8 <memset>
  return (void *)r;
}
    80000bb4:	8526                	mv	a0,s1
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
  release(&kmem.lock);
    80000bc0:	00011517          	auipc	a0,0x11
    80000bc4:	d7050513          	addi	a0,a0,-656 # 80011930 <kmem>
    80000bc8:	00000097          	auipc	ra,0x0
    80000bcc:	198080e7          	jalr	408(ra) # 80000d60 <release>
  if (r)
    80000bd0:	b7d5                	j	80000bb4 <kalloc+0x42>

0000000080000bd2 <getfreemem>:

int getfreemem()
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
  acquire(&kmem.lock);
    80000bdc:	00011497          	auipc	s1,0x11
    80000be0:	d5448493          	addi	s1,s1,-684 # 80011930 <kmem>
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	0c6080e7          	jalr	198(ra) # 80000cac <acquire>
  int n = 0;

  struct run *now = kmem.freelist;
    80000bee:	6c9c                	ld	a5,24(s1)
  while (now != 0)
    80000bf0:	c785                	beqz	a5,80000c18 <getfreemem+0x46>
  int n = 0;
    80000bf2:	4481                	li	s1,0
  {
    ++n;
    80000bf4:	2485                	addiw	s1,s1,1
    now = now->next;
    80000bf6:	639c                	ld	a5,0(a5)
  while (now != 0)
    80000bf8:	fff5                	bnez	a5,80000bf4 <getfreemem+0x22>
  }

  release(&kmem.lock);
    80000bfa:	00011517          	auipc	a0,0x11
    80000bfe:	d3650513          	addi	a0,a0,-714 # 80011930 <kmem>
    80000c02:	00000097          	auipc	ra,0x0
    80000c06:	15e080e7          	jalr	350(ra) # 80000d60 <release>
  return n * PGSIZE;
    80000c0a:	00c4951b          	slliw	a0,s1,0xc
    80000c0e:	60e2                	ld	ra,24(sp)
    80000c10:	6442                	ld	s0,16(sp)
    80000c12:	64a2                	ld	s1,8(sp)
    80000c14:	6105                	addi	sp,sp,32
    80000c16:	8082                	ret
  int n = 0;
    80000c18:	4481                	li	s1,0
    80000c1a:	b7c5                	j	80000bfa <getfreemem+0x28>

0000000080000c1c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c1c:	1141                	addi	sp,sp,-16
    80000c1e:	e422                	sd	s0,8(sp)
    80000c20:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c22:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c24:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c28:	00053823          	sd	zero,16(a0)
}
    80000c2c:	6422                	ld	s0,8(sp)
    80000c2e:	0141                	addi	sp,sp,16
    80000c30:	8082                	ret

0000000080000c32 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c32:	411c                	lw	a5,0(a0)
    80000c34:	e399                	bnez	a5,80000c3a <holding+0x8>
    80000c36:	4501                	li	a0,0
  return r;
}
    80000c38:	8082                	ret
{
    80000c3a:	1101                	addi	sp,sp,-32
    80000c3c:	ec06                	sd	ra,24(sp)
    80000c3e:	e822                	sd	s0,16(sp)
    80000c40:	e426                	sd	s1,8(sp)
    80000c42:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c44:	6904                	ld	s1,16(a0)
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	e58080e7          	jalr	-424(ra) # 80001a9e <mycpu>
    80000c4e:	40a48533          	sub	a0,s1,a0
    80000c52:	00153513          	seqz	a0,a0
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret

0000000080000c60 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c60:	1101                	addi	sp,sp,-32
    80000c62:	ec06                	sd	ra,24(sp)
    80000c64:	e822                	sd	s0,16(sp)
    80000c66:	e426                	sd	s1,8(sp)
    80000c68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100024f3          	csrr	s1,sstatus
    80000c6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c74:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c78:	00001097          	auipc	ra,0x1
    80000c7c:	e26080e7          	jalr	-474(ra) # 80001a9e <mycpu>
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	cf89                	beqz	a5,80000c9c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	e1a080e7          	jalr	-486(ra) # 80001a9e <mycpu>
    80000c8c:	5d3c                	lw	a5,120(a0)
    80000c8e:	2785                	addiw	a5,a5,1
    80000c90:	dd3c                	sw	a5,120(a0)
}
    80000c92:	60e2                	ld	ra,24(sp)
    80000c94:	6442                	ld	s0,16(sp)
    80000c96:	64a2                	ld	s1,8(sp)
    80000c98:	6105                	addi	sp,sp,32
    80000c9a:	8082                	ret
    mycpu()->intena = old;
    80000c9c:	00001097          	auipc	ra,0x1
    80000ca0:	e02080e7          	jalr	-510(ra) # 80001a9e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ca4:	8085                	srli	s1,s1,0x1
    80000ca6:	8885                	andi	s1,s1,1
    80000ca8:	dd64                	sw	s1,124(a0)
    80000caa:	bfe9                	j	80000c84 <push_off+0x24>

0000000080000cac <acquire>:
{
    80000cac:	1101                	addi	sp,sp,-32
    80000cae:	ec06                	sd	ra,24(sp)
    80000cb0:	e822                	sd	s0,16(sp)
    80000cb2:	e426                	sd	s1,8(sp)
    80000cb4:	1000                	addi	s0,sp,32
    80000cb6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cb8:	00000097          	auipc	ra,0x0
    80000cbc:	fa8080e7          	jalr	-88(ra) # 80000c60 <push_off>
  if(holding(lk))
    80000cc0:	8526                	mv	a0,s1
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f70080e7          	jalr	-144(ra) # 80000c32 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cca:	4705                	li	a4,1
  if(holding(lk))
    80000ccc:	e115                	bnez	a0,80000cf0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cce:	87ba                	mv	a5,a4
    80000cd0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cd4:	2781                	sext.w	a5,a5
    80000cd6:	ffe5                	bnez	a5,80000cce <acquire+0x22>
  __sync_synchronize();
    80000cd8:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cdc:	00001097          	auipc	ra,0x1
    80000ce0:	dc2080e7          	jalr	-574(ra) # 80001a9e <mycpu>
    80000ce4:	e888                	sd	a0,16(s1)
}
    80000ce6:	60e2                	ld	ra,24(sp)
    80000ce8:	6442                	ld	s0,16(sp)
    80000cea:	64a2                	ld	s1,8(sp)
    80000cec:	6105                	addi	sp,sp,32
    80000cee:	8082                	ret
    panic("acquire");
    80000cf0:	00007517          	auipc	a0,0x7
    80000cf4:	38050513          	addi	a0,a0,896 # 80008070 <digits+0x58>
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	87c080e7          	jalr	-1924(ra) # 80000574 <panic>

0000000080000d00 <pop_off>:

void
pop_off(void)
{
    80000d00:	1141                	addi	sp,sp,-16
    80000d02:	e406                	sd	ra,8(sp)
    80000d04:	e022                	sd	s0,0(sp)
    80000d06:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d08:	00001097          	auipc	ra,0x1
    80000d0c:	d96080e7          	jalr	-618(ra) # 80001a9e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d10:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d14:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d16:	e78d                	bnez	a5,80000d40 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d18:	5d3c                	lw	a5,120(a0)
    80000d1a:	02f05b63          	blez	a5,80000d50 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d1e:	37fd                	addiw	a5,a5,-1
    80000d20:	0007871b          	sext.w	a4,a5
    80000d24:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d26:	eb09                	bnez	a4,80000d38 <pop_off+0x38>
    80000d28:	5d7c                	lw	a5,124(a0)
    80000d2a:	c799                	beqz	a5,80000d38 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d30:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d34:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d38:	60a2                	ld	ra,8(sp)
    80000d3a:	6402                	ld	s0,0(sp)
    80000d3c:	0141                	addi	sp,sp,16
    80000d3e:	8082                	ret
    panic("pop_off - interruptible");
    80000d40:	00007517          	auipc	a0,0x7
    80000d44:	33850513          	addi	a0,a0,824 # 80008078 <digits+0x60>
    80000d48:	00000097          	auipc	ra,0x0
    80000d4c:	82c080e7          	jalr	-2004(ra) # 80000574 <panic>
    panic("pop_off");
    80000d50:	00007517          	auipc	a0,0x7
    80000d54:	34050513          	addi	a0,a0,832 # 80008090 <digits+0x78>
    80000d58:	00000097          	auipc	ra,0x0
    80000d5c:	81c080e7          	jalr	-2020(ra) # 80000574 <panic>

0000000080000d60 <release>:
{
    80000d60:	1101                	addi	sp,sp,-32
    80000d62:	ec06                	sd	ra,24(sp)
    80000d64:	e822                	sd	s0,16(sp)
    80000d66:	e426                	sd	s1,8(sp)
    80000d68:	1000                	addi	s0,sp,32
    80000d6a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d6c:	00000097          	auipc	ra,0x0
    80000d70:	ec6080e7          	jalr	-314(ra) # 80000c32 <holding>
    80000d74:	c115                	beqz	a0,80000d98 <release+0x38>
  lk->cpu = 0;
    80000d76:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d7a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d7e:	0f50000f          	fence	iorw,ow
    80000d82:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f7a080e7          	jalr	-134(ra) # 80000d00 <pop_off>
}
    80000d8e:	60e2                	ld	ra,24(sp)
    80000d90:	6442                	ld	s0,16(sp)
    80000d92:	64a2                	ld	s1,8(sp)
    80000d94:	6105                	addi	sp,sp,32
    80000d96:	8082                	ret
    panic("release");
    80000d98:	00007517          	auipc	a0,0x7
    80000d9c:	30050513          	addi	a0,a0,768 # 80008098 <digits+0x80>
    80000da0:	fffff097          	auipc	ra,0xfffff
    80000da4:	7d4080e7          	jalr	2004(ra) # 80000574 <panic>

0000000080000da8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000da8:	1141                	addi	sp,sp,-16
    80000daa:	e422                	sd	s0,8(sp)
    80000dac:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dae:	ce09                	beqz	a2,80000dc8 <memset+0x20>
    80000db0:	87aa                	mv	a5,a0
    80000db2:	fff6071b          	addiw	a4,a2,-1
    80000db6:	1702                	slli	a4,a4,0x20
    80000db8:	9301                	srli	a4,a4,0x20
    80000dba:	0705                	addi	a4,a4,1
    80000dbc:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000dbe:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd9000>
  for(i = 0; i < n; i++){
    80000dc2:	0785                	addi	a5,a5,1
    80000dc4:	fee79de3          	bne	a5,a4,80000dbe <memset+0x16>
  }
  return dst;
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret

0000000080000dce <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dce:	1141                	addi	sp,sp,-16
    80000dd0:	e422                	sd	s0,8(sp)
    80000dd2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dd4:	ce15                	beqz	a2,80000e10 <memcmp+0x42>
    80000dd6:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000dda:	00054783          	lbu	a5,0(a0)
    80000dde:	0005c703          	lbu	a4,0(a1)
    80000de2:	02e79063          	bne	a5,a4,80000e02 <memcmp+0x34>
    80000de6:	1682                	slli	a3,a3,0x20
    80000de8:	9281                	srli	a3,a3,0x20
    80000dea:	0685                	addi	a3,a3,1
    80000dec:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000dee:	0505                	addi	a0,a0,1
    80000df0:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000df2:	00d50d63          	beq	a0,a3,80000e0c <memcmp+0x3e>
    if(*s1 != *s2)
    80000df6:	00054783          	lbu	a5,0(a0)
    80000dfa:	0005c703          	lbu	a4,0(a1)
    80000dfe:	fee788e3          	beq	a5,a4,80000dee <memcmp+0x20>
      return *s1 - *s2;
    80000e02:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000e06:	6422                	ld	s0,8(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret
  return 0;
    80000e0c:	4501                	li	a0,0
    80000e0e:	bfe5                	j	80000e06 <memcmp+0x38>
    80000e10:	4501                	li	a0,0
    80000e12:	bfd5                	j	80000e06 <memcmp+0x38>

0000000080000e14 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e14:	1141                	addi	sp,sp,-16
    80000e16:	e422                	sd	s0,8(sp)
    80000e18:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e1a:	00a5f963          	bleu	a0,a1,80000e2c <memmove+0x18>
    80000e1e:	02061713          	slli	a4,a2,0x20
    80000e22:	9301                	srli	a4,a4,0x20
    80000e24:	00e587b3          	add	a5,a1,a4
    80000e28:	02f56563          	bltu	a0,a5,80000e52 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e2c:	fff6069b          	addiw	a3,a2,-1
    80000e30:	ce11                	beqz	a2,80000e4c <memmove+0x38>
    80000e32:	1682                	slli	a3,a3,0x20
    80000e34:	9281                	srli	a3,a3,0x20
    80000e36:	0685                	addi	a3,a3,1
    80000e38:	96ae                	add	a3,a3,a1
    80000e3a:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e3c:	0585                	addi	a1,a1,1
    80000e3e:	0785                	addi	a5,a5,1
    80000e40:	fff5c703          	lbu	a4,-1(a1)
    80000e44:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e48:	fed59ae3          	bne	a1,a3,80000e3c <memmove+0x28>

  return dst;
}
    80000e4c:	6422                	ld	s0,8(sp)
    80000e4e:	0141                	addi	sp,sp,16
    80000e50:	8082                	ret
    d += n;
    80000e52:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e54:	fff6069b          	addiw	a3,a2,-1
    80000e58:	da75                	beqz	a2,80000e4c <memmove+0x38>
    80000e5a:	02069613          	slli	a2,a3,0x20
    80000e5e:	9201                	srli	a2,a2,0x20
    80000e60:	fff64613          	not	a2,a2
    80000e64:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e66:	17fd                	addi	a5,a5,-1
    80000e68:	177d                	addi	a4,a4,-1
    80000e6a:	0007c683          	lbu	a3,0(a5)
    80000e6e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e72:	fef61ae3          	bne	a2,a5,80000e66 <memmove+0x52>
    80000e76:	bfd9                	j	80000e4c <memmove+0x38>

0000000080000e78 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e80:	00000097          	auipc	ra,0x0
    80000e84:	f94080e7          	jalr	-108(ra) # 80000e14 <memmove>
}
    80000e88:	60a2                	ld	ra,8(sp)
    80000e8a:	6402                	ld	s0,0(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret

0000000080000e90 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e90:	1141                	addi	sp,sp,-16
    80000e92:	e422                	sd	s0,8(sp)
    80000e94:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e96:	c229                	beqz	a2,80000ed8 <strncmp+0x48>
    80000e98:	00054783          	lbu	a5,0(a0)
    80000e9c:	c795                	beqz	a5,80000ec8 <strncmp+0x38>
    80000e9e:	0005c703          	lbu	a4,0(a1)
    80000ea2:	02f71363          	bne	a4,a5,80000ec8 <strncmp+0x38>
    80000ea6:	fff6071b          	addiw	a4,a2,-1
    80000eaa:	1702                	slli	a4,a4,0x20
    80000eac:	9301                	srli	a4,a4,0x20
    80000eae:	0705                	addi	a4,a4,1
    80000eb0:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000eb2:	0505                	addi	a0,a0,1
    80000eb4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000eb6:	02e50363          	beq	a0,a4,80000edc <strncmp+0x4c>
    80000eba:	00054783          	lbu	a5,0(a0)
    80000ebe:	c789                	beqz	a5,80000ec8 <strncmp+0x38>
    80000ec0:	0005c683          	lbu	a3,0(a1)
    80000ec4:	fef687e3          	beq	a3,a5,80000eb2 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000ec8:	00054503          	lbu	a0,0(a0)
    80000ecc:	0005c783          	lbu	a5,0(a1)
    80000ed0:	9d1d                	subw	a0,a0,a5
}
    80000ed2:	6422                	ld	s0,8(sp)
    80000ed4:	0141                	addi	sp,sp,16
    80000ed6:	8082                	ret
    return 0;
    80000ed8:	4501                	li	a0,0
    80000eda:	bfe5                	j	80000ed2 <strncmp+0x42>
    80000edc:	4501                	li	a0,0
    80000ede:	bfd5                	j	80000ed2 <strncmp+0x42>

0000000080000ee0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ee0:	1141                	addi	sp,sp,-16
    80000ee2:	e422                	sd	s0,8(sp)
    80000ee4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ee6:	872a                	mv	a4,a0
    80000ee8:	a011                	j	80000eec <strncpy+0xc>
    80000eea:	8636                	mv	a2,a3
    80000eec:	fff6069b          	addiw	a3,a2,-1
    80000ef0:	00c05963          	blez	a2,80000f02 <strncpy+0x22>
    80000ef4:	0705                	addi	a4,a4,1
    80000ef6:	0005c783          	lbu	a5,0(a1)
    80000efa:	fef70fa3          	sb	a5,-1(a4)
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	f7ed                	bnez	a5,80000eea <strncpy+0xa>
    ;
  while(n-- > 0)
    80000f02:	00d05c63          	blez	a3,80000f1a <strncpy+0x3a>
    80000f06:	86ba                	mv	a3,a4
    *s++ = 0;
    80000f08:	0685                	addi	a3,a3,1
    80000f0a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f0e:	fff6c793          	not	a5,a3
    80000f12:	9fb9                	addw	a5,a5,a4
    80000f14:	9fb1                	addw	a5,a5,a2
    80000f16:	fef049e3          	bgtz	a5,80000f08 <strncpy+0x28>
  return os;
}
    80000f1a:	6422                	ld	s0,8(sp)
    80000f1c:	0141                	addi	sp,sp,16
    80000f1e:	8082                	ret

0000000080000f20 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f20:	1141                	addi	sp,sp,-16
    80000f22:	e422                	sd	s0,8(sp)
    80000f24:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f26:	02c05363          	blez	a2,80000f4c <safestrcpy+0x2c>
    80000f2a:	fff6069b          	addiw	a3,a2,-1
    80000f2e:	1682                	slli	a3,a3,0x20
    80000f30:	9281                	srli	a3,a3,0x20
    80000f32:	96ae                	add	a3,a3,a1
    80000f34:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f36:	00d58963          	beq	a1,a3,80000f48 <safestrcpy+0x28>
    80000f3a:	0585                	addi	a1,a1,1
    80000f3c:	0785                	addi	a5,a5,1
    80000f3e:	fff5c703          	lbu	a4,-1(a1)
    80000f42:	fee78fa3          	sb	a4,-1(a5)
    80000f46:	fb65                	bnez	a4,80000f36 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f48:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f4c:	6422                	ld	s0,8(sp)
    80000f4e:	0141                	addi	sp,sp,16
    80000f50:	8082                	ret

0000000080000f52 <strlen>:

int
strlen(const char *s)
{
    80000f52:	1141                	addi	sp,sp,-16
    80000f54:	e422                	sd	s0,8(sp)
    80000f56:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f58:	00054783          	lbu	a5,0(a0)
    80000f5c:	cf91                	beqz	a5,80000f78 <strlen+0x26>
    80000f5e:	0505                	addi	a0,a0,1
    80000f60:	87aa                	mv	a5,a0
    80000f62:	4685                	li	a3,1
    80000f64:	9e89                	subw	a3,a3,a0
    80000f66:	00f6853b          	addw	a0,a3,a5
    80000f6a:	0785                	addi	a5,a5,1
    80000f6c:	fff7c703          	lbu	a4,-1(a5)
    80000f70:	fb7d                	bnez	a4,80000f66 <strlen+0x14>
    ;
  return n;
}
    80000f72:	6422                	ld	s0,8(sp)
    80000f74:	0141                	addi	sp,sp,16
    80000f76:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f78:	4501                	li	a0,0
    80000f7a:	bfe5                	j	80000f72 <strlen+0x20>

0000000080000f7c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e406                	sd	ra,8(sp)
    80000f80:	e022                	sd	s0,0(sp)
    80000f82:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	b0a080e7          	jalr	-1270(ra) # 80001a8e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	08070713          	addi	a4,a4,128 # 8000900c <started>
  if(cpuid() == 0){
    80000f94:	c139                	beqz	a0,80000fda <main+0x5e>
    while(started == 0)
    80000f96:	431c                	lw	a5,0(a4)
    80000f98:	2781                	sext.w	a5,a5
    80000f9a:	dff5                	beqz	a5,80000f96 <main+0x1a>
      ;
    __sync_synchronize();
    80000f9c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fa0:	00001097          	auipc	ra,0x1
    80000fa4:	aee080e7          	jalr	-1298(ra) # 80001a8e <cpuid>
    80000fa8:	85aa                	mv	a1,a0
    80000faa:	00007517          	auipc	a0,0x7
    80000fae:	10e50513          	addi	a0,a0,270 # 800080b8 <digits+0xa0>
    80000fb2:	fffff097          	auipc	ra,0xfffff
    80000fb6:	60c080e7          	jalr	1548(ra) # 800005be <printf>
    kvminithart();    // turn on paging
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	0d8080e7          	jalr	216(ra) # 80001092 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fc2:	00001097          	auipc	ra,0x1
    80000fc6:	796080e7          	jalr	1942(ra) # 80002758 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fca:	00005097          	auipc	ra,0x5
    80000fce:	ef6080e7          	jalr	-266(ra) # 80005ec0 <plicinithart>
  }

  scheduler();        
    80000fd2:	00001097          	auipc	ra,0x1
    80000fd6:	026080e7          	jalr	38(ra) # 80001ff8 <scheduler>
    consoleinit();
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	4a8080e7          	jalr	1192(ra) # 80000482 <consoleinit>
    printfinit();
    80000fe2:	fffff097          	auipc	ra,0xfffff
    80000fe6:	7c2080e7          	jalr	1986(ra) # 800007a4 <printfinit>
    printf("\n");
    80000fea:	00007517          	auipc	a0,0x7
    80000fee:	0de50513          	addi	a0,a0,222 # 800080c8 <digits+0xb0>
    80000ff2:	fffff097          	auipc	ra,0xfffff
    80000ff6:	5cc080e7          	jalr	1484(ra) # 800005be <printf>
    printf("xv6 kernel is booting\n");
    80000ffa:	00007517          	auipc	a0,0x7
    80000ffe:	0a650513          	addi	a0,a0,166 # 800080a0 <digits+0x88>
    80001002:	fffff097          	auipc	ra,0xfffff
    80001006:	5bc080e7          	jalr	1468(ra) # 800005be <printf>
    printf("\n");
    8000100a:	00007517          	auipc	a0,0x7
    8000100e:	0be50513          	addi	a0,a0,190 # 800080c8 <digits+0xb0>
    80001012:	fffff097          	auipc	ra,0xfffff
    80001016:	5ac080e7          	jalr	1452(ra) # 800005be <printf>
    kinit();         // physical page allocator
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	b1c080e7          	jalr	-1252(ra) # 80000b36 <kinit>
    kvminit();       // create kernel page table
    80001022:	00000097          	auipc	ra,0x0
    80001026:	2a6080e7          	jalr	678(ra) # 800012c8 <kvminit>
    kvminithart();   // turn on paging
    8000102a:	00000097          	auipc	ra,0x0
    8000102e:	068080e7          	jalr	104(ra) # 80001092 <kvminithart>
    procinit();      // process table
    80001032:	00001097          	auipc	ra,0x1
    80001036:	98c080e7          	jalr	-1652(ra) # 800019be <procinit>
    trapinit();      // trap vectors
    8000103a:	00001097          	auipc	ra,0x1
    8000103e:	6f6080e7          	jalr	1782(ra) # 80002730 <trapinit>
    trapinithart();  // install kernel trap vector
    80001042:	00001097          	auipc	ra,0x1
    80001046:	716080e7          	jalr	1814(ra) # 80002758 <trapinithart>
    plicinit();      // set up interrupt controller
    8000104a:	00005097          	auipc	ra,0x5
    8000104e:	e60080e7          	jalr	-416(ra) # 80005eaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001052:	00005097          	auipc	ra,0x5
    80001056:	e6e080e7          	jalr	-402(ra) # 80005ec0 <plicinithart>
    binit();         // buffer cache
    8000105a:	00002097          	auipc	ra,0x2
    8000105e:	f36080e7          	jalr	-202(ra) # 80002f90 <binit>
    iinit();         // inode cache
    80001062:	00002097          	auipc	ra,0x2
    80001066:	608080e7          	jalr	1544(ra) # 8000366a <iinit>
    fileinit();      // file table
    8000106a:	00003097          	auipc	ra,0x3
    8000106e:	5ce080e7          	jalr	1486(ra) # 80004638 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001072:	00005097          	auipc	ra,0x5
    80001076:	f58080e7          	jalr	-168(ra) # 80005fca <virtio_disk_init>
    userinit();      // first user process
    8000107a:	00001097          	auipc	ra,0x1
    8000107e:	d0c080e7          	jalr	-756(ra) # 80001d86 <userinit>
    __sync_synchronize();
    80001082:	0ff0000f          	fence
    started = 1;
    80001086:	4785                	li	a5,1
    80001088:	00008717          	auipc	a4,0x8
    8000108c:	f8f72223          	sw	a5,-124(a4) # 8000900c <started>
    80001090:	b789                	j	80000fd2 <main+0x56>

0000000080001092 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001092:	1141                	addi	sp,sp,-16
    80001094:	e422                	sd	s0,8(sp)
    80001096:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001098:	00008797          	auipc	a5,0x8
    8000109c:	f7878793          	addi	a5,a5,-136 # 80009010 <kernel_pagetable>
    800010a0:	639c                	ld	a5,0(a5)
    800010a2:	83b1                	srli	a5,a5,0xc
    800010a4:	577d                	li	a4,-1
    800010a6:	177e                	slli	a4,a4,0x3f
    800010a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010aa:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010ae:	12000073          	sfence.vma
  sfence_vma();
}
    800010b2:	6422                	ld	s0,8(sp)
    800010b4:	0141                	addi	sp,sp,16
    800010b6:	8082                	ret

00000000800010b8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010b8:	7139                	addi	sp,sp,-64
    800010ba:	fc06                	sd	ra,56(sp)
    800010bc:	f822                	sd	s0,48(sp)
    800010be:	f426                	sd	s1,40(sp)
    800010c0:	f04a                	sd	s2,32(sp)
    800010c2:	ec4e                	sd	s3,24(sp)
    800010c4:	e852                	sd	s4,16(sp)
    800010c6:	e456                	sd	s5,8(sp)
    800010c8:	e05a                	sd	s6,0(sp)
    800010ca:	0080                	addi	s0,sp,64
    800010cc:	84aa                	mv	s1,a0
    800010ce:	89ae                	mv	s3,a1
    800010d0:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010d2:	57fd                	li	a5,-1
    800010d4:	83e9                	srli	a5,a5,0x1a
    800010d6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010d8:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010da:	04b7f263          	bleu	a1,a5,8000111e <walk+0x66>
    panic("walk");
    800010de:	00007517          	auipc	a0,0x7
    800010e2:	ff250513          	addi	a0,a0,-14 # 800080d0 <digits+0xb8>
    800010e6:	fffff097          	auipc	ra,0xfffff
    800010ea:	48e080e7          	jalr	1166(ra) # 80000574 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010ee:	060b0663          	beqz	s6,8000115a <walk+0xa2>
    800010f2:	00000097          	auipc	ra,0x0
    800010f6:	a80080e7          	jalr	-1408(ra) # 80000b72 <kalloc>
    800010fa:	84aa                	mv	s1,a0
    800010fc:	c529                	beqz	a0,80001146 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	00000097          	auipc	ra,0x0
    80001106:	ca6080e7          	jalr	-858(ra) # 80000da8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000110a:	00c4d793          	srli	a5,s1,0xc
    8000110e:	07aa                	slli	a5,a5,0xa
    80001110:	0017e793          	ori	a5,a5,1
    80001114:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001118:	3a5d                	addiw	s4,s4,-9
    8000111a:	035a0063          	beq	s4,s5,8000113a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000111e:	0149d933          	srl	s2,s3,s4
    80001122:	1ff97913          	andi	s2,s2,511
    80001126:	090e                	slli	s2,s2,0x3
    80001128:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000112a:	00093483          	ld	s1,0(s2)
    8000112e:	0014f793          	andi	a5,s1,1
    80001132:	dfd5                	beqz	a5,800010ee <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001134:	80a9                	srli	s1,s1,0xa
    80001136:	04b2                	slli	s1,s1,0xc
    80001138:	b7c5                	j	80001118 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000113a:	00c9d513          	srli	a0,s3,0xc
    8000113e:	1ff57513          	andi	a0,a0,511
    80001142:	050e                	slli	a0,a0,0x3
    80001144:	9526                	add	a0,a0,s1
}
    80001146:	70e2                	ld	ra,56(sp)
    80001148:	7442                	ld	s0,48(sp)
    8000114a:	74a2                	ld	s1,40(sp)
    8000114c:	7902                	ld	s2,32(sp)
    8000114e:	69e2                	ld	s3,24(sp)
    80001150:	6a42                	ld	s4,16(sp)
    80001152:	6aa2                	ld	s5,8(sp)
    80001154:	6b02                	ld	s6,0(sp)
    80001156:	6121                	addi	sp,sp,64
    80001158:	8082                	ret
        return 0;
    8000115a:	4501                	li	a0,0
    8000115c:	b7ed                	j	80001146 <walk+0x8e>

000000008000115e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000115e:	57fd                	li	a5,-1
    80001160:	83e9                	srli	a5,a5,0x1a
    80001162:	00b7f463          	bleu	a1,a5,8000116a <walkaddr+0xc>
    return 0;
    80001166:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001168:	8082                	ret
{
    8000116a:	1141                	addi	sp,sp,-16
    8000116c:	e406                	sd	ra,8(sp)
    8000116e:	e022                	sd	s0,0(sp)
    80001170:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001172:	4601                	li	a2,0
    80001174:	00000097          	auipc	ra,0x0
    80001178:	f44080e7          	jalr	-188(ra) # 800010b8 <walk>
  if(pte == 0)
    8000117c:	c105                	beqz	a0,8000119c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000117e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001180:	0117f693          	andi	a3,a5,17
    80001184:	4745                	li	a4,17
    return 0;
    80001186:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001188:	00e68663          	beq	a3,a4,80001194 <walkaddr+0x36>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret
  pa = PTE2PA(*pte);
    80001194:	00a7d513          	srli	a0,a5,0xa
    80001198:	0532                	slli	a0,a0,0xc
  return pa;
    8000119a:	bfcd                	j	8000118c <walkaddr+0x2e>
    return 0;
    8000119c:	4501                	li	a0,0
    8000119e:	b7fd                	j	8000118c <walkaddr+0x2e>

00000000800011a0 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011a0:	1101                	addi	sp,sp,-32
    800011a2:	ec06                	sd	ra,24(sp)
    800011a4:	e822                	sd	s0,16(sp)
    800011a6:	e426                	sd	s1,8(sp)
    800011a8:	1000                	addi	s0,sp,32
    800011aa:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011ac:	6785                	lui	a5,0x1
    800011ae:	17fd                	addi	a5,a5,-1
    800011b0:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800011b4:	4601                	li	a2,0
    800011b6:	00008797          	auipc	a5,0x8
    800011ba:	e5a78793          	addi	a5,a5,-422 # 80009010 <kernel_pagetable>
    800011be:	6388                	ld	a0,0(a5)
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	ef8080e7          	jalr	-264(ra) # 800010b8 <walk>
  if(pte == 0)
    800011c8:	cd09                	beqz	a0,800011e2 <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800011ca:	6108                	ld	a0,0(a0)
    800011cc:	00157793          	andi	a5,a0,1
    800011d0:	c38d                	beqz	a5,800011f2 <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800011d2:	8129                	srli	a0,a0,0xa
    800011d4:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800011d6:	9526                	add	a0,a0,s1
    800011d8:	60e2                	ld	ra,24(sp)
    800011da:	6442                	ld	s0,16(sp)
    800011dc:	64a2                	ld	s1,8(sp)
    800011de:	6105                	addi	sp,sp,32
    800011e0:	8082                	ret
    panic("kvmpa");
    800011e2:	00007517          	auipc	a0,0x7
    800011e6:	ef650513          	addi	a0,a0,-266 # 800080d8 <digits+0xc0>
    800011ea:	fffff097          	auipc	ra,0xfffff
    800011ee:	38a080e7          	jalr	906(ra) # 80000574 <panic>
    panic("kvmpa");
    800011f2:	00007517          	auipc	a0,0x7
    800011f6:	ee650513          	addi	a0,a0,-282 # 800080d8 <digits+0xc0>
    800011fa:	fffff097          	auipc	ra,0xfffff
    800011fe:	37a080e7          	jalr	890(ra) # 80000574 <panic>

0000000080001202 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001202:	715d                	addi	sp,sp,-80
    80001204:	e486                	sd	ra,72(sp)
    80001206:	e0a2                	sd	s0,64(sp)
    80001208:	fc26                	sd	s1,56(sp)
    8000120a:	f84a                	sd	s2,48(sp)
    8000120c:	f44e                	sd	s3,40(sp)
    8000120e:	f052                	sd	s4,32(sp)
    80001210:	ec56                	sd	s5,24(sp)
    80001212:	e85a                	sd	s6,16(sp)
    80001214:	e45e                	sd	s7,8(sp)
    80001216:	0880                	addi	s0,sp,80
    80001218:	8aaa                	mv	s5,a0
    8000121a:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000121c:	79fd                	lui	s3,0xfffff
    8000121e:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    80001222:	167d                	addi	a2,a2,-1
    80001224:	962e                	add	a2,a2,a1
    80001226:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    8000122a:	8952                	mv	s2,s4
    8000122c:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001230:	6b85                	lui	s7,0x1
    80001232:	a811                	j	80001246 <mappages+0x44>
      panic("remap");
    80001234:	00007517          	auipc	a0,0x7
    80001238:	eac50513          	addi	a0,a0,-340 # 800080e0 <digits+0xc8>
    8000123c:	fffff097          	auipc	ra,0xfffff
    80001240:	338080e7          	jalr	824(ra) # 80000574 <panic>
    a += PGSIZE;
    80001244:	995e                	add	s2,s2,s7
  for(;;){
    80001246:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000124a:	4605                	li	a2,1
    8000124c:	85ca                	mv	a1,s2
    8000124e:	8556                	mv	a0,s5
    80001250:	00000097          	auipc	ra,0x0
    80001254:	e68080e7          	jalr	-408(ra) # 800010b8 <walk>
    80001258:	cd19                	beqz	a0,80001276 <mappages+0x74>
    if(*pte & PTE_V)
    8000125a:	611c                	ld	a5,0(a0)
    8000125c:	8b85                	andi	a5,a5,1
    8000125e:	fbf9                	bnez	a5,80001234 <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001260:	80b1                	srli	s1,s1,0xc
    80001262:	04aa                	slli	s1,s1,0xa
    80001264:	0164e4b3          	or	s1,s1,s6
    80001268:	0014e493          	ori	s1,s1,1
    8000126c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000126e:	fd391be3          	bne	s2,s3,80001244 <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    80001272:	4501                	li	a0,0
    80001274:	a011                	j	80001278 <mappages+0x76>
      return -1;
    80001276:	557d                	li	a0,-1
}
    80001278:	60a6                	ld	ra,72(sp)
    8000127a:	6406                	ld	s0,64(sp)
    8000127c:	74e2                	ld	s1,56(sp)
    8000127e:	7942                	ld	s2,48(sp)
    80001280:	79a2                	ld	s3,40(sp)
    80001282:	7a02                	ld	s4,32(sp)
    80001284:	6ae2                	ld	s5,24(sp)
    80001286:	6b42                	ld	s6,16(sp)
    80001288:	6ba2                	ld	s7,8(sp)
    8000128a:	6161                	addi	sp,sp,80
    8000128c:	8082                	ret

000000008000128e <kvmmap>:
{
    8000128e:	1141                	addi	sp,sp,-16
    80001290:	e406                	sd	ra,8(sp)
    80001292:	e022                	sd	s0,0(sp)
    80001294:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001296:	8736                	mv	a4,a3
    80001298:	86ae                	mv	a3,a1
    8000129a:	85aa                	mv	a1,a0
    8000129c:	00008797          	auipc	a5,0x8
    800012a0:	d7478793          	addi	a5,a5,-652 # 80009010 <kernel_pagetable>
    800012a4:	6388                	ld	a0,0(a5)
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f5c080e7          	jalr	-164(ra) # 80001202 <mappages>
    800012ae:	e509                	bnez	a0,800012b8 <kvmmap+0x2a>
}
    800012b0:	60a2                	ld	ra,8(sp)
    800012b2:	6402                	ld	s0,0(sp)
    800012b4:	0141                	addi	sp,sp,16
    800012b6:	8082                	ret
    panic("kvmmap");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e3050513          	addi	a0,a0,-464 # 800080e8 <digits+0xd0>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	2b4080e7          	jalr	692(ra) # 80000574 <panic>

00000000800012c8 <kvminit>:
{
    800012c8:	1101                	addi	sp,sp,-32
    800012ca:	ec06                	sd	ra,24(sp)
    800012cc:	e822                	sd	s0,16(sp)
    800012ce:	e426                	sd	s1,8(sp)
    800012d0:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012d2:	00000097          	auipc	ra,0x0
    800012d6:	8a0080e7          	jalr	-1888(ra) # 80000b72 <kalloc>
    800012da:	00008797          	auipc	a5,0x8
    800012de:	d2a7bb23          	sd	a0,-714(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800012e2:	6605                	lui	a2,0x1
    800012e4:	4581                	li	a1,0
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	ac2080e7          	jalr	-1342(ra) # 80000da8 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012ee:	4699                	li	a3,6
    800012f0:	6605                	lui	a2,0x1
    800012f2:	100005b7          	lui	a1,0x10000
    800012f6:	10000537          	lui	a0,0x10000
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	f94080e7          	jalr	-108(ra) # 8000128e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001302:	4699                	li	a3,6
    80001304:	6605                	lui	a2,0x1
    80001306:	100015b7          	lui	a1,0x10001
    8000130a:	10001537          	lui	a0,0x10001
    8000130e:	00000097          	auipc	ra,0x0
    80001312:	f80080e7          	jalr	-128(ra) # 8000128e <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001316:	4699                	li	a3,6
    80001318:	6641                	lui	a2,0x10
    8000131a:	020005b7          	lui	a1,0x2000
    8000131e:	02000537          	lui	a0,0x2000
    80001322:	00000097          	auipc	ra,0x0
    80001326:	f6c080e7          	jalr	-148(ra) # 8000128e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000132a:	4699                	li	a3,6
    8000132c:	00400637          	lui	a2,0x400
    80001330:	0c0005b7          	lui	a1,0xc000
    80001334:	0c000537          	lui	a0,0xc000
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	f56080e7          	jalr	-170(ra) # 8000128e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001340:	00007497          	auipc	s1,0x7
    80001344:	cc048493          	addi	s1,s1,-832 # 80008000 <etext>
    80001348:	46a9                	li	a3,10
    8000134a:	80007617          	auipc	a2,0x80007
    8000134e:	cb660613          	addi	a2,a2,-842 # 8000 <_entry-0x7fff8000>
    80001352:	4585                	li	a1,1
    80001354:	05fe                	slli	a1,a1,0x1f
    80001356:	852e                	mv	a0,a1
    80001358:	00000097          	auipc	ra,0x0
    8000135c:	f36080e7          	jalr	-202(ra) # 8000128e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001360:	4699                	li	a3,6
    80001362:	4645                	li	a2,17
    80001364:	066e                	slli	a2,a2,0x1b
    80001366:	8e05                	sub	a2,a2,s1
    80001368:	85a6                	mv	a1,s1
    8000136a:	8526                	mv	a0,s1
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	f22080e7          	jalr	-222(ra) # 8000128e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001374:	46a9                	li	a3,10
    80001376:	6605                	lui	a2,0x1
    80001378:	00006597          	auipc	a1,0x6
    8000137c:	c8858593          	addi	a1,a1,-888 # 80007000 <_trampoline>
    80001380:	04000537          	lui	a0,0x4000
    80001384:	157d                	addi	a0,a0,-1
    80001386:	0532                	slli	a0,a0,0xc
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	f06080e7          	jalr	-250(ra) # 8000128e <kvmmap>
}
    80001390:	60e2                	ld	ra,24(sp)
    80001392:	6442                	ld	s0,16(sp)
    80001394:	64a2                	ld	s1,8(sp)
    80001396:	6105                	addi	sp,sp,32
    80001398:	8082                	ret

000000008000139a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000139a:	715d                	addi	sp,sp,-80
    8000139c:	e486                	sd	ra,72(sp)
    8000139e:	e0a2                	sd	s0,64(sp)
    800013a0:	fc26                	sd	s1,56(sp)
    800013a2:	f84a                	sd	s2,48(sp)
    800013a4:	f44e                	sd	s3,40(sp)
    800013a6:	f052                	sd	s4,32(sp)
    800013a8:	ec56                	sd	s5,24(sp)
    800013aa:	e85a                	sd	s6,16(sp)
    800013ac:	e45e                	sd	s7,8(sp)
    800013ae:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013b0:	6785                	lui	a5,0x1
    800013b2:	17fd                	addi	a5,a5,-1
    800013b4:	8fed                	and	a5,a5,a1
    800013b6:	e795                	bnez	a5,800013e2 <uvmunmap+0x48>
    800013b8:	8a2a                	mv	s4,a0
    800013ba:	84ae                	mv	s1,a1
    800013bc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013be:	0632                	slli	a2,a2,0xc
    800013c0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013c4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c6:	6b05                	lui	s6,0x1
    800013c8:	0735e863          	bltu	a1,s3,80001438 <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
    panic("uvmunmap: not aligned");
    800013e2:	00007517          	auipc	a0,0x7
    800013e6:	d0e50513          	addi	a0,a0,-754 # 800080f0 <digits+0xd8>
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	18a080e7          	jalr	394(ra) # 80000574 <panic>
      panic("uvmunmap: walk");
    800013f2:	00007517          	auipc	a0,0x7
    800013f6:	d1650513          	addi	a0,a0,-746 # 80008108 <digits+0xf0>
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	17a080e7          	jalr	378(ra) # 80000574 <panic>
      panic("uvmunmap: not mapped");
    80001402:	00007517          	auipc	a0,0x7
    80001406:	d1650513          	addi	a0,a0,-746 # 80008118 <digits+0x100>
    8000140a:	fffff097          	auipc	ra,0xfffff
    8000140e:	16a080e7          	jalr	362(ra) # 80000574 <panic>
      panic("uvmunmap: not a leaf");
    80001412:	00007517          	auipc	a0,0x7
    80001416:	d1e50513          	addi	a0,a0,-738 # 80008130 <digits+0x118>
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	15a080e7          	jalr	346(ra) # 80000574 <panic>
      uint64 pa = PTE2PA(*pte);
    80001422:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001424:	0532                	slli	a0,a0,0xc
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	64c080e7          	jalr	1612(ra) # 80000a72 <kfree>
    *pte = 0;
    8000142e:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001432:	94da                	add	s1,s1,s6
    80001434:	f934fce3          	bleu	s3,s1,800013cc <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001438:	4601                	li	a2,0
    8000143a:	85a6                	mv	a1,s1
    8000143c:	8552                	mv	a0,s4
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	c7a080e7          	jalr	-902(ra) # 800010b8 <walk>
    80001446:	892a                	mv	s2,a0
    80001448:	d54d                	beqz	a0,800013f2 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    8000144a:	6108                	ld	a0,0(a0)
    8000144c:	00157793          	andi	a5,a0,1
    80001450:	dbcd                	beqz	a5,80001402 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001452:	3ff57793          	andi	a5,a0,1023
    80001456:	fb778ee3          	beq	a5,s7,80001412 <uvmunmap+0x78>
    if(do_free){
    8000145a:	fc0a8ae3          	beqz	s5,8000142e <uvmunmap+0x94>
    8000145e:	b7d1                	j	80001422 <uvmunmap+0x88>

0000000080001460 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001460:	1101                	addi	sp,sp,-32
    80001462:	ec06                	sd	ra,24(sp)
    80001464:	e822                	sd	s0,16(sp)
    80001466:	e426                	sd	s1,8(sp)
    80001468:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000146a:	fffff097          	auipc	ra,0xfffff
    8000146e:	708080e7          	jalr	1800(ra) # 80000b72 <kalloc>
    80001472:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001474:	c519                	beqz	a0,80001482 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001476:	6605                	lui	a2,0x1
    80001478:	4581                	li	a1,0
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	92e080e7          	jalr	-1746(ra) # 80000da8 <memset>
  return pagetable;
}
    80001482:	8526                	mv	a0,s1
    80001484:	60e2                	ld	ra,24(sp)
    80001486:	6442                	ld	s0,16(sp)
    80001488:	64a2                	ld	s1,8(sp)
    8000148a:	6105                	addi	sp,sp,32
    8000148c:	8082                	ret

000000008000148e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000148e:	7179                	addi	sp,sp,-48
    80001490:	f406                	sd	ra,40(sp)
    80001492:	f022                	sd	s0,32(sp)
    80001494:	ec26                	sd	s1,24(sp)
    80001496:	e84a                	sd	s2,16(sp)
    80001498:	e44e                	sd	s3,8(sp)
    8000149a:	e052                	sd	s4,0(sp)
    8000149c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000149e:	6785                	lui	a5,0x1
    800014a0:	04f67863          	bleu	a5,a2,800014f0 <uvminit+0x62>
    800014a4:	8a2a                	mv	s4,a0
    800014a6:	89ae                	mv	s3,a1
    800014a8:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	6c8080e7          	jalr	1736(ra) # 80000b72 <kalloc>
    800014b2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014b4:	6605                	lui	a2,0x1
    800014b6:	4581                	li	a1,0
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	8f0080e7          	jalr	-1808(ra) # 80000da8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014c0:	4779                	li	a4,30
    800014c2:	86ca                	mv	a3,s2
    800014c4:	6605                	lui	a2,0x1
    800014c6:	4581                	li	a1,0
    800014c8:	8552                	mv	a0,s4
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	d38080e7          	jalr	-712(ra) # 80001202 <mappages>
  memmove(mem, src, sz);
    800014d2:	8626                	mv	a2,s1
    800014d4:	85ce                	mv	a1,s3
    800014d6:	854a                	mv	a0,s2
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	93c080e7          	jalr	-1732(ra) # 80000e14 <memmove>
}
    800014e0:	70a2                	ld	ra,40(sp)
    800014e2:	7402                	ld	s0,32(sp)
    800014e4:	64e2                	ld	s1,24(sp)
    800014e6:	6942                	ld	s2,16(sp)
    800014e8:	69a2                	ld	s3,8(sp)
    800014ea:	6a02                	ld	s4,0(sp)
    800014ec:	6145                	addi	sp,sp,48
    800014ee:	8082                	ret
    panic("inituvm: more than a page");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c5850513          	addi	a0,a0,-936 # 80008148 <digits+0x130>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	07c080e7          	jalr	124(ra) # 80000574 <panic>

0000000080001500 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001500:	1101                	addi	sp,sp,-32
    80001502:	ec06                	sd	ra,24(sp)
    80001504:	e822                	sd	s0,16(sp)
    80001506:	e426                	sd	s1,8(sp)
    80001508:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000150a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000150c:	00b67d63          	bleu	a1,a2,80001526 <uvmdealloc+0x26>
    80001510:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001512:	6605                	lui	a2,0x1
    80001514:	167d                	addi	a2,a2,-1
    80001516:	00c487b3          	add	a5,s1,a2
    8000151a:	777d                	lui	a4,0xfffff
    8000151c:	8ff9                	and	a5,a5,a4
    8000151e:	962e                	add	a2,a2,a1
    80001520:	8e79                	and	a2,a2,a4
    80001522:	00c7e863          	bltu	a5,a2,80001532 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001526:	8526                	mv	a0,s1
    80001528:	60e2                	ld	ra,24(sp)
    8000152a:	6442                	ld	s0,16(sp)
    8000152c:	64a2                	ld	s1,8(sp)
    8000152e:	6105                	addi	sp,sp,32
    80001530:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001532:	8e1d                	sub	a2,a2,a5
    80001534:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001536:	4685                	li	a3,1
    80001538:	2601                	sext.w	a2,a2
    8000153a:	85be                	mv	a1,a5
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	e5e080e7          	jalr	-418(ra) # 8000139a <uvmunmap>
    80001544:	b7cd                	j	80001526 <uvmdealloc+0x26>

0000000080001546 <uvmalloc>:
  if(newsz < oldsz)
    80001546:	0ab66163          	bltu	a2,a1,800015e8 <uvmalloc+0xa2>
{
    8000154a:	7139                	addi	sp,sp,-64
    8000154c:	fc06                	sd	ra,56(sp)
    8000154e:	f822                	sd	s0,48(sp)
    80001550:	f426                	sd	s1,40(sp)
    80001552:	f04a                	sd	s2,32(sp)
    80001554:	ec4e                	sd	s3,24(sp)
    80001556:	e852                	sd	s4,16(sp)
    80001558:	e456                	sd	s5,8(sp)
    8000155a:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    8000155c:	6a05                	lui	s4,0x1
    8000155e:	1a7d                	addi	s4,s4,-1
    80001560:	95d2                	add	a1,a1,s4
    80001562:	7a7d                	lui	s4,0xfffff
    80001564:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001568:	08ca7263          	bleu	a2,s4,800015ec <uvmalloc+0xa6>
    8000156c:	89b2                	mv	s3,a2
    8000156e:	8aaa                	mv	s5,a0
    80001570:	8952                	mv	s2,s4
    mem = kalloc();
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	600080e7          	jalr	1536(ra) # 80000b72 <kalloc>
    8000157a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000157c:	c51d                	beqz	a0,800015aa <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000157e:	6605                	lui	a2,0x1
    80001580:	4581                	li	a1,0
    80001582:	00000097          	auipc	ra,0x0
    80001586:	826080e7          	jalr	-2010(ra) # 80000da8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000158a:	4779                	li	a4,30
    8000158c:	86a6                	mv	a3,s1
    8000158e:	6605                	lui	a2,0x1
    80001590:	85ca                	mv	a1,s2
    80001592:	8556                	mv	a0,s5
    80001594:	00000097          	auipc	ra,0x0
    80001598:	c6e080e7          	jalr	-914(ra) # 80001202 <mappages>
    8000159c:	e905                	bnez	a0,800015cc <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000159e:	6785                	lui	a5,0x1
    800015a0:	993e                	add	s2,s2,a5
    800015a2:	fd3968e3          	bltu	s2,s3,80001572 <uvmalloc+0x2c>
  return newsz;
    800015a6:	854e                	mv	a0,s3
    800015a8:	a809                	j	800015ba <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015aa:	8652                	mv	a2,s4
    800015ac:	85ca                	mv	a1,s2
    800015ae:	8556                	mv	a0,s5
    800015b0:	00000097          	auipc	ra,0x0
    800015b4:	f50080e7          	jalr	-176(ra) # 80001500 <uvmdealloc>
      return 0;
    800015b8:	4501                	li	a0,0
}
    800015ba:	70e2                	ld	ra,56(sp)
    800015bc:	7442                	ld	s0,48(sp)
    800015be:	74a2                	ld	s1,40(sp)
    800015c0:	7902                	ld	s2,32(sp)
    800015c2:	69e2                	ld	s3,24(sp)
    800015c4:	6a42                	ld	s4,16(sp)
    800015c6:	6aa2                	ld	s5,8(sp)
    800015c8:	6121                	addi	sp,sp,64
    800015ca:	8082                	ret
      kfree(mem);
    800015cc:	8526                	mv	a0,s1
    800015ce:	fffff097          	auipc	ra,0xfffff
    800015d2:	4a4080e7          	jalr	1188(ra) # 80000a72 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015d6:	8652                	mv	a2,s4
    800015d8:	85ca                	mv	a1,s2
    800015da:	8556                	mv	a0,s5
    800015dc:	00000097          	auipc	ra,0x0
    800015e0:	f24080e7          	jalr	-220(ra) # 80001500 <uvmdealloc>
      return 0;
    800015e4:	4501                	li	a0,0
    800015e6:	bfd1                	j	800015ba <uvmalloc+0x74>
    return oldsz;
    800015e8:	852e                	mv	a0,a1
}
    800015ea:	8082                	ret
  return newsz;
    800015ec:	8532                	mv	a0,a2
    800015ee:	b7f1                	j	800015ba <uvmalloc+0x74>

00000000800015f0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015f0:	7179                	addi	sp,sp,-48
    800015f2:	f406                	sd	ra,40(sp)
    800015f4:	f022                	sd	s0,32(sp)
    800015f6:	ec26                	sd	s1,24(sp)
    800015f8:	e84a                	sd	s2,16(sp)
    800015fa:	e44e                	sd	s3,8(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	1800                	addi	s0,sp,48
    80001600:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001602:	84aa                	mv	s1,a0
    80001604:	6905                	lui	s2,0x1
    80001606:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001608:	4985                	li	s3,1
    8000160a:	a821                	j	80001622 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000160c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000160e:	0532                	slli	a0,a0,0xc
    80001610:	00000097          	auipc	ra,0x0
    80001614:	fe0080e7          	jalr	-32(ra) # 800015f0 <freewalk>
      pagetable[i] = 0;
    80001618:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000161c:	04a1                	addi	s1,s1,8
    8000161e:	03248163          	beq	s1,s2,80001640 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001622:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001624:	00f57793          	andi	a5,a0,15
    80001628:	ff3782e3          	beq	a5,s3,8000160c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000162c:	8905                	andi	a0,a0,1
    8000162e:	d57d                	beqz	a0,8000161c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001630:	00007517          	auipc	a0,0x7
    80001634:	b3850513          	addi	a0,a0,-1224 # 80008168 <digits+0x150>
    80001638:	fffff097          	auipc	ra,0xfffff
    8000163c:	f3c080e7          	jalr	-196(ra) # 80000574 <panic>
    }
  }
  kfree((void*)pagetable);
    80001640:	8552                	mv	a0,s4
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	430080e7          	jalr	1072(ra) # 80000a72 <kfree>
}
    8000164a:	70a2                	ld	ra,40(sp)
    8000164c:	7402                	ld	s0,32(sp)
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6942                	ld	s2,16(sp)
    80001652:	69a2                	ld	s3,8(sp)
    80001654:	6a02                	ld	s4,0(sp)
    80001656:	6145                	addi	sp,sp,48
    80001658:	8082                	ret

000000008000165a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000165a:	1101                	addi	sp,sp,-32
    8000165c:	ec06                	sd	ra,24(sp)
    8000165e:	e822                	sd	s0,16(sp)
    80001660:	e426                	sd	s1,8(sp)
    80001662:	1000                	addi	s0,sp,32
    80001664:	84aa                	mv	s1,a0
  if(sz > 0)
    80001666:	e999                	bnez	a1,8000167c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001668:	8526                	mv	a0,s1
    8000166a:	00000097          	auipc	ra,0x0
    8000166e:	f86080e7          	jalr	-122(ra) # 800015f0 <freewalk>
}
    80001672:	60e2                	ld	ra,24(sp)
    80001674:	6442                	ld	s0,16(sp)
    80001676:	64a2                	ld	s1,8(sp)
    80001678:	6105                	addi	sp,sp,32
    8000167a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000167c:	6605                	lui	a2,0x1
    8000167e:	167d                	addi	a2,a2,-1
    80001680:	962e                	add	a2,a2,a1
    80001682:	4685                	li	a3,1
    80001684:	8231                	srli	a2,a2,0xc
    80001686:	4581                	li	a1,0
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	d12080e7          	jalr	-750(ra) # 8000139a <uvmunmap>
    80001690:	bfe1                	j	80001668 <uvmfree+0xe>

0000000080001692 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001692:	c679                	beqz	a2,80001760 <uvmcopy+0xce>
{
    80001694:	715d                	addi	sp,sp,-80
    80001696:	e486                	sd	ra,72(sp)
    80001698:	e0a2                	sd	s0,64(sp)
    8000169a:	fc26                	sd	s1,56(sp)
    8000169c:	f84a                	sd	s2,48(sp)
    8000169e:	f44e                	sd	s3,40(sp)
    800016a0:	f052                	sd	s4,32(sp)
    800016a2:	ec56                	sd	s5,24(sp)
    800016a4:	e85a                	sd	s6,16(sp)
    800016a6:	e45e                	sd	s7,8(sp)
    800016a8:	0880                	addi	s0,sp,80
    800016aa:	8ab2                	mv	s5,a2
    800016ac:	8b2e                	mv	s6,a1
    800016ae:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800016b0:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800016b2:	4601                	li	a2,0
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855e                	mv	a0,s7
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	a00080e7          	jalr	-1536(ra) # 800010b8 <walk>
    800016c0:	c531                	beqz	a0,8000170c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016c2:	6118                	ld	a4,0(a0)
    800016c4:	00177793          	andi	a5,a4,1
    800016c8:	cbb1                	beqz	a5,8000171c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016ca:	00a75593          	srli	a1,a4,0xa
    800016ce:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016d2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800016d6:	fffff097          	auipc	ra,0xfffff
    800016da:	49c080e7          	jalr	1180(ra) # 80000b72 <kalloc>
    800016de:	8a2a                	mv	s4,a0
    800016e0:	c939                	beqz	a0,80001736 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016e2:	6605                	lui	a2,0x1
    800016e4:	85ce                	mv	a1,s3
    800016e6:	fffff097          	auipc	ra,0xfffff
    800016ea:	72e080e7          	jalr	1838(ra) # 80000e14 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016ee:	8726                	mv	a4,s1
    800016f0:	86d2                	mv	a3,s4
    800016f2:	6605                	lui	a2,0x1
    800016f4:	85ca                	mv	a1,s2
    800016f6:	855a                	mv	a0,s6
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	b0a080e7          	jalr	-1270(ra) # 80001202 <mappages>
    80001700:	e515                	bnez	a0,8000172c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001702:	6785                	lui	a5,0x1
    80001704:	993e                	add	s2,s2,a5
    80001706:	fb5966e3          	bltu	s2,s5,800016b2 <uvmcopy+0x20>
    8000170a:	a081                	j	8000174a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000170c:	00007517          	auipc	a0,0x7
    80001710:	a6c50513          	addi	a0,a0,-1428 # 80008178 <digits+0x160>
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	e60080e7          	jalr	-416(ra) # 80000574 <panic>
      panic("uvmcopy: page not present");
    8000171c:	00007517          	auipc	a0,0x7
    80001720:	a7c50513          	addi	a0,a0,-1412 # 80008198 <digits+0x180>
    80001724:	fffff097          	auipc	ra,0xfffff
    80001728:	e50080e7          	jalr	-432(ra) # 80000574 <panic>
      kfree(mem);
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	344080e7          	jalr	836(ra) # 80000a72 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001736:	4685                	li	a3,1
    80001738:	00c95613          	srli	a2,s2,0xc
    8000173c:	4581                	li	a1,0
    8000173e:	855a                	mv	a0,s6
    80001740:	00000097          	auipc	ra,0x0
    80001744:	c5a080e7          	jalr	-934(ra) # 8000139a <uvmunmap>
  return -1;
    80001748:	557d                	li	a0,-1
}
    8000174a:	60a6                	ld	ra,72(sp)
    8000174c:	6406                	ld	s0,64(sp)
    8000174e:	74e2                	ld	s1,56(sp)
    80001750:	7942                	ld	s2,48(sp)
    80001752:	79a2                	ld	s3,40(sp)
    80001754:	7a02                	ld	s4,32(sp)
    80001756:	6ae2                	ld	s5,24(sp)
    80001758:	6b42                	ld	s6,16(sp)
    8000175a:	6ba2                	ld	s7,8(sp)
    8000175c:	6161                	addi	sp,sp,80
    8000175e:	8082                	ret
  return 0;
    80001760:	4501                	li	a0,0
}
    80001762:	8082                	ret

0000000080001764 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001764:	1141                	addi	sp,sp,-16
    80001766:	e406                	sd	ra,8(sp)
    80001768:	e022                	sd	s0,0(sp)
    8000176a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000176c:	4601                	li	a2,0
    8000176e:	00000097          	auipc	ra,0x0
    80001772:	94a080e7          	jalr	-1718(ra) # 800010b8 <walk>
  if(pte == 0)
    80001776:	c901                	beqz	a0,80001786 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001778:	611c                	ld	a5,0(a0)
    8000177a:	9bbd                	andi	a5,a5,-17
    8000177c:	e11c                	sd	a5,0(a0)
}
    8000177e:	60a2                	ld	ra,8(sp)
    80001780:	6402                	ld	s0,0(sp)
    80001782:	0141                	addi	sp,sp,16
    80001784:	8082                	ret
    panic("uvmclear");
    80001786:	00007517          	auipc	a0,0x7
    8000178a:	a3250513          	addi	a0,a0,-1486 # 800081b8 <digits+0x1a0>
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	de6080e7          	jalr	-538(ra) # 80000574 <panic>

0000000080001796 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001796:	c6bd                	beqz	a3,80001804 <copyout+0x6e>
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8baa                	mv	s7,a0
    800017b2:	8a2e                	mv	s4,a1
    800017b4:	8ab2                	mv	s5,a2
    800017b6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017b8:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017ba:	6b05                	lui	s6,0x1
    800017bc:	a015                	j	800017e0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017be:	9552                	add	a0,a0,s4
    800017c0:	0004861b          	sext.w	a2,s1
    800017c4:	85d6                	mv	a1,s5
    800017c6:	41250533          	sub	a0,a0,s2
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	64a080e7          	jalr	1610(ra) # 80000e14 <memmove>

    len -= n;
    800017d2:	409989b3          	sub	s3,s3,s1
    src += n;
    800017d6:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    800017d8:	01690a33          	add	s4,s2,s6
  while(len > 0){
    800017dc:	02098263          	beqz	s3,80001800 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800017e0:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    800017e4:	85ca                	mv	a1,s2
    800017e6:	855e                	mv	a0,s7
    800017e8:	00000097          	auipc	ra,0x0
    800017ec:	976080e7          	jalr	-1674(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    800017f0:	cd01                	beqz	a0,80001808 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800017f2:	414904b3          	sub	s1,s2,s4
    800017f6:	94da                	add	s1,s1,s6
    if(n > len)
    800017f8:	fc99f3e3          	bleu	s1,s3,800017be <copyout+0x28>
    800017fc:	84ce                	mv	s1,s3
    800017fe:	b7c1                	j	800017be <copyout+0x28>
  }
  return 0;
    80001800:	4501                	li	a0,0
    80001802:	a021                	j	8000180a <copyout+0x74>
    80001804:	4501                	li	a0,0
}
    80001806:	8082                	ret
      return -1;
    80001808:	557d                	li	a0,-1
}
    8000180a:	60a6                	ld	ra,72(sp)
    8000180c:	6406                	ld	s0,64(sp)
    8000180e:	74e2                	ld	s1,56(sp)
    80001810:	7942                	ld	s2,48(sp)
    80001812:	79a2                	ld	s3,40(sp)
    80001814:	7a02                	ld	s4,32(sp)
    80001816:	6ae2                	ld	s5,24(sp)
    80001818:	6b42                	ld	s6,16(sp)
    8000181a:	6ba2                	ld	s7,8(sp)
    8000181c:	6c02                	ld	s8,0(sp)
    8000181e:	6161                	addi	sp,sp,80
    80001820:	8082                	ret

0000000080001822 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001822:	caa5                	beqz	a3,80001892 <copyin+0x70>
{
    80001824:	715d                	addi	sp,sp,-80
    80001826:	e486                	sd	ra,72(sp)
    80001828:	e0a2                	sd	s0,64(sp)
    8000182a:	fc26                	sd	s1,56(sp)
    8000182c:	f84a                	sd	s2,48(sp)
    8000182e:	f44e                	sd	s3,40(sp)
    80001830:	f052                	sd	s4,32(sp)
    80001832:	ec56                	sd	s5,24(sp)
    80001834:	e85a                	sd	s6,16(sp)
    80001836:	e45e                	sd	s7,8(sp)
    80001838:	e062                	sd	s8,0(sp)
    8000183a:	0880                	addi	s0,sp,80
    8000183c:	8baa                	mv	s7,a0
    8000183e:	8aae                	mv	s5,a1
    80001840:	8a32                	mv	s4,a2
    80001842:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001844:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001846:	6b05                	lui	s6,0x1
    80001848:	a01d                	j	8000186e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000184a:	014505b3          	add	a1,a0,s4
    8000184e:	0004861b          	sext.w	a2,s1
    80001852:	412585b3          	sub	a1,a1,s2
    80001856:	8556                	mv	a0,s5
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	5bc080e7          	jalr	1468(ra) # 80000e14 <memmove>

    len -= n;
    80001860:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001864:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001866:	01690a33          	add	s4,s2,s6
  while(len > 0){
    8000186a:	02098263          	beqz	s3,8000188e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000186e:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80001872:	85ca                	mv	a1,s2
    80001874:	855e                	mv	a0,s7
    80001876:	00000097          	auipc	ra,0x0
    8000187a:	8e8080e7          	jalr	-1816(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    8000187e:	cd01                	beqz	a0,80001896 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001880:	414904b3          	sub	s1,s2,s4
    80001884:	94da                	add	s1,s1,s6
    if(n > len)
    80001886:	fc99f2e3          	bleu	s1,s3,8000184a <copyin+0x28>
    8000188a:	84ce                	mv	s1,s3
    8000188c:	bf7d                	j	8000184a <copyin+0x28>
  }
  return 0;
    8000188e:	4501                	li	a0,0
    80001890:	a021                	j	80001898 <copyin+0x76>
    80001892:	4501                	li	a0,0
}
    80001894:	8082                	ret
      return -1;
    80001896:	557d                	li	a0,-1
}
    80001898:	60a6                	ld	ra,72(sp)
    8000189a:	6406                	ld	s0,64(sp)
    8000189c:	74e2                	ld	s1,56(sp)
    8000189e:	7942                	ld	s2,48(sp)
    800018a0:	79a2                	ld	s3,40(sp)
    800018a2:	7a02                	ld	s4,32(sp)
    800018a4:	6ae2                	ld	s5,24(sp)
    800018a6:	6b42                	ld	s6,16(sp)
    800018a8:	6ba2                	ld	s7,8(sp)
    800018aa:	6c02                	ld	s8,0(sp)
    800018ac:	6161                	addi	sp,sp,80
    800018ae:	8082                	ret

00000000800018b0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018b0:	ced5                	beqz	a3,8000196c <copyinstr+0xbc>
{
    800018b2:	715d                	addi	sp,sp,-80
    800018b4:	e486                	sd	ra,72(sp)
    800018b6:	e0a2                	sd	s0,64(sp)
    800018b8:	fc26                	sd	s1,56(sp)
    800018ba:	f84a                	sd	s2,48(sp)
    800018bc:	f44e                	sd	s3,40(sp)
    800018be:	f052                	sd	s4,32(sp)
    800018c0:	ec56                	sd	s5,24(sp)
    800018c2:	e85a                	sd	s6,16(sp)
    800018c4:	e45e                	sd	s7,8(sp)
    800018c6:	e062                	sd	s8,0(sp)
    800018c8:	0880                	addi	s0,sp,80
    800018ca:	8aaa                	mv	s5,a0
    800018cc:	84ae                	mv	s1,a1
    800018ce:	8c32                	mv	s8,a2
    800018d0:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800018d2:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018d4:	6985                	lui	s3,0x1
    800018d6:	4b05                	li	s6,1
    800018d8:	a801                	j	800018e8 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    800018da:	87a6                	mv	a5,s1
    800018dc:	a085                	j	8000193c <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    800018de:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    800018e0:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    800018e4:	080b8063          	beqz	s7,80001964 <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    800018e8:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    800018ec:	85ca                	mv	a1,s2
    800018ee:	8556                	mv	a0,s5
    800018f0:	00000097          	auipc	ra,0x0
    800018f4:	86e080e7          	jalr	-1938(ra) # 8000115e <walkaddr>
    if(pa0 == 0)
    800018f8:	c925                	beqz	a0,80001968 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    800018fa:	41890633          	sub	a2,s2,s8
    800018fe:	964e                	add	a2,a2,s3
    if(n > max)
    80001900:	00cbf363          	bleu	a2,s7,80001906 <copyinstr+0x56>
    80001904:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001906:	9562                	add	a0,a0,s8
    80001908:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000190c:	da71                	beqz	a2,800018e0 <copyinstr+0x30>
      if(*p == '\0'){
    8000190e:	00054703          	lbu	a4,0(a0)
    80001912:	d761                	beqz	a4,800018da <copyinstr+0x2a>
    80001914:	9626                	add	a2,a2,s1
    80001916:	87a6                	mv	a5,s1
    80001918:	1bfd                	addi	s7,s7,-1
    8000191a:	009b86b3          	add	a3,s7,s1
    8000191e:	409b04b3          	sub	s1,s6,s1
    80001922:	94aa                	add	s1,s1,a0
        *dst = *p;
    80001924:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001928:	40f68bb3          	sub	s7,a3,a5
      p++;
    8000192c:	00f48733          	add	a4,s1,a5
      dst++;
    80001930:	0785                	addi	a5,a5,1
    while(n > 0){
    80001932:	faf606e3          	beq	a2,a5,800018de <copyinstr+0x2e>
      if(*p == '\0'){
    80001936:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000193a:	f76d                	bnez	a4,80001924 <copyinstr+0x74>
        *dst = '\0';
    8000193c:	00078023          	sb	zero,0(a5)
    80001940:	4785                	li	a5,1
  }
  if(got_null){
    80001942:	0017b513          	seqz	a0,a5
    80001946:	40a0053b          	negw	a0,a0
    8000194a:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    8000194c:	60a6                	ld	ra,72(sp)
    8000194e:	6406                	ld	s0,64(sp)
    80001950:	74e2                	ld	s1,56(sp)
    80001952:	7942                	ld	s2,48(sp)
    80001954:	79a2                	ld	s3,40(sp)
    80001956:	7a02                	ld	s4,32(sp)
    80001958:	6ae2                	ld	s5,24(sp)
    8000195a:	6b42                	ld	s6,16(sp)
    8000195c:	6ba2                	ld	s7,8(sp)
    8000195e:	6c02                	ld	s8,0(sp)
    80001960:	6161                	addi	sp,sp,80
    80001962:	8082                	ret
    80001964:	4781                	li	a5,0
    80001966:	bff1                	j	80001942 <copyinstr+0x92>
      return -1;
    80001968:	557d                	li	a0,-1
    8000196a:	b7cd                	j	8000194c <copyinstr+0x9c>
  int got_null = 0;
    8000196c:	4781                	li	a5,0
  if(got_null){
    8000196e:	0017b513          	seqz	a0,a5
    80001972:	40a0053b          	negw	a0,a0
    80001976:	2501                	sext.w	a0,a0
}
    80001978:	8082                	ret

000000008000197a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000197a:	1101                	addi	sp,sp,-32
    8000197c:	ec06                	sd	ra,24(sp)
    8000197e:	e822                	sd	s0,16(sp)
    80001980:	e426                	sd	s1,8(sp)
    80001982:	1000                	addi	s0,sp,32
    80001984:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	2ac080e7          	jalr	684(ra) # 80000c32 <holding>
    8000198e:	c909                	beqz	a0,800019a0 <wakeup1+0x26>
    panic("wakeup1");
  if (p->chan == p && p->state == SLEEPING)
    80001990:	749c                	ld	a5,40(s1)
    80001992:	00978f63          	beq	a5,s1,800019b0 <wakeup1+0x36>
  {
    p->state = RUNNABLE;
  }
}
    80001996:	60e2                	ld	ra,24(sp)
    80001998:	6442                	ld	s0,16(sp)
    8000199a:	64a2                	ld	s1,8(sp)
    8000199c:	6105                	addi	sp,sp,32
    8000199e:	8082                	ret
    panic("wakeup1");
    800019a0:	00007517          	auipc	a0,0x7
    800019a4:	85050513          	addi	a0,a0,-1968 # 800081f0 <states.1726+0x28>
    800019a8:	fffff097          	auipc	ra,0xfffff
    800019ac:	bcc080e7          	jalr	-1076(ra) # 80000574 <panic>
  if (p->chan == p && p->state == SLEEPING)
    800019b0:	4c98                	lw	a4,24(s1)
    800019b2:	4785                	li	a5,1
    800019b4:	fef711e3          	bne	a4,a5,80001996 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019b8:	4789                	li	a5,2
    800019ba:	cc9c                	sw	a5,24(s1)
}
    800019bc:	bfe9                	j	80001996 <wakeup1+0x1c>

00000000800019be <procinit>:
{
    800019be:	715d                	addi	sp,sp,-80
    800019c0:	e486                	sd	ra,72(sp)
    800019c2:	e0a2                	sd	s0,64(sp)
    800019c4:	fc26                	sd	s1,56(sp)
    800019c6:	f84a                	sd	s2,48(sp)
    800019c8:	f44e                	sd	s3,40(sp)
    800019ca:	f052                	sd	s4,32(sp)
    800019cc:	ec56                	sd	s5,24(sp)
    800019ce:	e85a                	sd	s6,16(sp)
    800019d0:	e45e                	sd	s7,8(sp)
    800019d2:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019d4:	00007597          	auipc	a1,0x7
    800019d8:	82458593          	addi	a1,a1,-2012 # 800081f8 <states.1726+0x30>
    800019dc:	00010517          	auipc	a0,0x10
    800019e0:	f7450513          	addi	a0,a0,-140 # 80011950 <pid_lock>
    800019e4:	fffff097          	auipc	ra,0xfffff
    800019e8:	238080e7          	jalr	568(ra) # 80000c1c <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    800019ec:	00010917          	auipc	s2,0x10
    800019f0:	37c90913          	addi	s2,s2,892 # 80011d68 <proc>
    initlock(&p->lock, "proc");
    800019f4:	00007b97          	auipc	s7,0x7
    800019f8:	80cb8b93          	addi	s7,s7,-2036 # 80008200 <states.1726+0x38>
    uint64 va = KSTACK((int)(p - proc));
    800019fc:	8b4a                	mv	s6,s2
    800019fe:	00006a97          	auipc	s5,0x6
    80001a02:	602a8a93          	addi	s5,s5,1538 # 80008000 <etext>
    80001a06:	040009b7          	lui	s3,0x4000
    80001a0a:	19fd                	addi	s3,s3,-1
    80001a0c:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a0e:	00016a17          	auipc	s4,0x16
    80001a12:	f5aa0a13          	addi	s4,s4,-166 # 80017968 <tickslock>
    initlock(&p->lock, "proc");
    80001a16:	85de                	mv	a1,s7
    80001a18:	854a                	mv	a0,s2
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	202080e7          	jalr	514(ra) # 80000c1c <initlock>
    char *pa = kalloc();
    80001a22:	fffff097          	auipc	ra,0xfffff
    80001a26:	150080e7          	jalr	336(ra) # 80000b72 <kalloc>
    80001a2a:	85aa                	mv	a1,a0
    if (pa == 0)
    80001a2c:	c929                	beqz	a0,80001a7e <procinit+0xc0>
    uint64 va = KSTACK((int)(p - proc));
    80001a2e:	416904b3          	sub	s1,s2,s6
    80001a32:	8491                	srai	s1,s1,0x4
    80001a34:	000ab783          	ld	a5,0(s5)
    80001a38:	02f484b3          	mul	s1,s1,a5
    80001a3c:	2485                	addiw	s1,s1,1
    80001a3e:	00d4949b          	slliw	s1,s1,0xd
    80001a42:	409984b3          	sub	s1,s3,s1
    kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a46:	4699                	li	a3,6
    80001a48:	6605                	lui	a2,0x1
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	00000097          	auipc	ra,0x0
    80001a50:	842080e7          	jalr	-1982(ra) # 8000128e <kvmmap>
    p->kstack = va;
    80001a54:	04993023          	sd	s1,64(s2)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a58:	17090913          	addi	s2,s2,368
    80001a5c:	fb491de3          	bne	s2,s4,80001a16 <procinit+0x58>
  kvminithart();
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	632080e7          	jalr	1586(ra) # 80001092 <kvminithart>
}
    80001a68:	60a6                	ld	ra,72(sp)
    80001a6a:	6406                	ld	s0,64(sp)
    80001a6c:	74e2                	ld	s1,56(sp)
    80001a6e:	7942                	ld	s2,48(sp)
    80001a70:	79a2                	ld	s3,40(sp)
    80001a72:	7a02                	ld	s4,32(sp)
    80001a74:	6ae2                	ld	s5,24(sp)
    80001a76:	6b42                	ld	s6,16(sp)
    80001a78:	6ba2                	ld	s7,8(sp)
    80001a7a:	6161                	addi	sp,sp,80
    80001a7c:	8082                	ret
      panic("kalloc");
    80001a7e:	00006517          	auipc	a0,0x6
    80001a82:	78a50513          	addi	a0,a0,1930 # 80008208 <states.1726+0x40>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	aee080e7          	jalr	-1298(ra) # 80000574 <panic>

0000000080001a8e <cpuid>:
{
    80001a8e:	1141                	addi	sp,sp,-16
    80001a90:	e422                	sd	s0,8(sp)
    80001a92:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a94:	8512                	mv	a0,tp
}
    80001a96:	2501                	sext.w	a0,a0
    80001a98:	6422                	ld	s0,8(sp)
    80001a9a:	0141                	addi	sp,sp,16
    80001a9c:	8082                	ret

0000000080001a9e <mycpu>:
{
    80001a9e:	1141                	addi	sp,sp,-16
    80001aa0:	e422                	sd	s0,8(sp)
    80001aa2:	0800                	addi	s0,sp,16
    80001aa4:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001aa6:	2781                	sext.w	a5,a5
    80001aa8:	079e                	slli	a5,a5,0x7
}
    80001aaa:	00010517          	auipc	a0,0x10
    80001aae:	ebe50513          	addi	a0,a0,-322 # 80011968 <cpus>
    80001ab2:	953e                	add	a0,a0,a5
    80001ab4:	6422                	ld	s0,8(sp)
    80001ab6:	0141                	addi	sp,sp,16
    80001ab8:	8082                	ret

0000000080001aba <myproc>:
{
    80001aba:	1101                	addi	sp,sp,-32
    80001abc:	ec06                	sd	ra,24(sp)
    80001abe:	e822                	sd	s0,16(sp)
    80001ac0:	e426                	sd	s1,8(sp)
    80001ac2:	1000                	addi	s0,sp,32
  push_off();
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	19c080e7          	jalr	412(ra) # 80000c60 <push_off>
    80001acc:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ace:	2781                	sext.w	a5,a5
    80001ad0:	079e                	slli	a5,a5,0x7
    80001ad2:	00010717          	auipc	a4,0x10
    80001ad6:	e7e70713          	addi	a4,a4,-386 # 80011950 <pid_lock>
    80001ada:	97ba                	add	a5,a5,a4
    80001adc:	6f84                	ld	s1,24(a5)
  pop_off();
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	222080e7          	jalr	546(ra) # 80000d00 <pop_off>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret

0000000080001af2 <forkret>:
{
    80001af2:	1141                	addi	sp,sp,-16
    80001af4:	e406                	sd	ra,8(sp)
    80001af6:	e022                	sd	s0,0(sp)
    80001af8:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	fc0080e7          	jalr	-64(ra) # 80001aba <myproc>
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	25e080e7          	jalr	606(ra) # 80000d60 <release>
  if (first)
    80001b0a:	00007797          	auipc	a5,0x7
    80001b0e:	ea678793          	addi	a5,a5,-346 # 800089b0 <first.1686>
    80001b12:	439c                	lw	a5,0(a5)
    80001b14:	eb89                	bnez	a5,80001b26 <forkret+0x34>
  usertrapret();
    80001b16:	00001097          	auipc	ra,0x1
    80001b1a:	c5a080e7          	jalr	-934(ra) # 80002770 <usertrapret>
}
    80001b1e:	60a2                	ld	ra,8(sp)
    80001b20:	6402                	ld	s0,0(sp)
    80001b22:	0141                	addi	sp,sp,16
    80001b24:	8082                	ret
    first = 0;
    80001b26:	00007797          	auipc	a5,0x7
    80001b2a:	e807a523          	sw	zero,-374(a5) # 800089b0 <first.1686>
    fsinit(ROOTDEV);
    80001b2e:	4505                	li	a0,1
    80001b30:	00002097          	auipc	ra,0x2
    80001b34:	abc080e7          	jalr	-1348(ra) # 800035ec <fsinit>
    80001b38:	bff9                	j	80001b16 <forkret+0x24>

0000000080001b3a <allocpid>:
{
    80001b3a:	1101                	addi	sp,sp,-32
    80001b3c:	ec06                	sd	ra,24(sp)
    80001b3e:	e822                	sd	s0,16(sp)
    80001b40:	e426                	sd	s1,8(sp)
    80001b42:	e04a                	sd	s2,0(sp)
    80001b44:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b46:	00010917          	auipc	s2,0x10
    80001b4a:	e0a90913          	addi	s2,s2,-502 # 80011950 <pid_lock>
    80001b4e:	854a                	mv	a0,s2
    80001b50:	fffff097          	auipc	ra,0xfffff
    80001b54:	15c080e7          	jalr	348(ra) # 80000cac <acquire>
  pid = nextpid;
    80001b58:	00007797          	auipc	a5,0x7
    80001b5c:	e5c78793          	addi	a5,a5,-420 # 800089b4 <nextpid>
    80001b60:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b62:	0014871b          	addiw	a4,s1,1
    80001b66:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b68:	854a                	mv	a0,s2
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	1f6080e7          	jalr	502(ra) # 80000d60 <release>
}
    80001b72:	8526                	mv	a0,s1
    80001b74:	60e2                	ld	ra,24(sp)
    80001b76:	6442                	ld	s0,16(sp)
    80001b78:	64a2                	ld	s1,8(sp)
    80001b7a:	6902                	ld	s2,0(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <proc_pagetable>:
{
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	e04a                	sd	s2,0(sp)
    80001b8a:	1000                	addi	s0,sp,32
    80001b8c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b8e:	00000097          	auipc	ra,0x0
    80001b92:	8d2080e7          	jalr	-1838(ra) # 80001460 <uvmcreate>
    80001b96:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001b98:	c121                	beqz	a0,80001bd8 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b9a:	4729                	li	a4,10
    80001b9c:	00005697          	auipc	a3,0x5
    80001ba0:	46468693          	addi	a3,a3,1124 # 80007000 <_trampoline>
    80001ba4:	6605                	lui	a2,0x1
    80001ba6:	040005b7          	lui	a1,0x4000
    80001baa:	15fd                	addi	a1,a1,-1
    80001bac:	05b2                	slli	a1,a1,0xc
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	654080e7          	jalr	1620(ra) # 80001202 <mappages>
    80001bb6:	02054863          	bltz	a0,80001be6 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bba:	4719                	li	a4,6
    80001bbc:	05893683          	ld	a3,88(s2)
    80001bc0:	6605                	lui	a2,0x1
    80001bc2:	020005b7          	lui	a1,0x2000
    80001bc6:	15fd                	addi	a1,a1,-1
    80001bc8:	05b6                	slli	a1,a1,0xd
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	636080e7          	jalr	1590(ra) # 80001202 <mappages>
    80001bd4:	02054163          	bltz	a0,80001bf6 <proc_pagetable+0x76>
}
    80001bd8:	8526                	mv	a0,s1
    80001bda:	60e2                	ld	ra,24(sp)
    80001bdc:	6442                	ld	s0,16(sp)
    80001bde:	64a2                	ld	s1,8(sp)
    80001be0:	6902                	ld	s2,0(sp)
    80001be2:	6105                	addi	sp,sp,32
    80001be4:	8082                	ret
    uvmfree(pagetable, 0);
    80001be6:	4581                	li	a1,0
    80001be8:	8526                	mv	a0,s1
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	a70080e7          	jalr	-1424(ra) # 8000165a <uvmfree>
    return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	b7d5                	j	80001bd8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bf6:	4681                	li	a3,0
    80001bf8:	4605                	li	a2,1
    80001bfa:	040005b7          	lui	a1,0x4000
    80001bfe:	15fd                	addi	a1,a1,-1
    80001c00:	05b2                	slli	a1,a1,0xc
    80001c02:	8526                	mv	a0,s1
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	796080e7          	jalr	1942(ra) # 8000139a <uvmunmap>
    uvmfree(pagetable, 0);
    80001c0c:	4581                	li	a1,0
    80001c0e:	8526                	mv	a0,s1
    80001c10:	00000097          	auipc	ra,0x0
    80001c14:	a4a080e7          	jalr	-1462(ra) # 8000165a <uvmfree>
    return 0;
    80001c18:	4481                	li	s1,0
    80001c1a:	bf7d                	j	80001bd8 <proc_pagetable+0x58>

0000000080001c1c <proc_freepagetable>:
{
    80001c1c:	1101                	addi	sp,sp,-32
    80001c1e:	ec06                	sd	ra,24(sp)
    80001c20:	e822                	sd	s0,16(sp)
    80001c22:	e426                	sd	s1,8(sp)
    80001c24:	e04a                	sd	s2,0(sp)
    80001c26:	1000                	addi	s0,sp,32
    80001c28:	84aa                	mv	s1,a0
    80001c2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c2c:	4681                	li	a3,0
    80001c2e:	4605                	li	a2,1
    80001c30:	040005b7          	lui	a1,0x4000
    80001c34:	15fd                	addi	a1,a1,-1
    80001c36:	05b2                	slli	a1,a1,0xc
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	762080e7          	jalr	1890(ra) # 8000139a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c40:	4681                	li	a3,0
    80001c42:	4605                	li	a2,1
    80001c44:	020005b7          	lui	a1,0x2000
    80001c48:	15fd                	addi	a1,a1,-1
    80001c4a:	05b6                	slli	a1,a1,0xd
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	74c080e7          	jalr	1868(ra) # 8000139a <uvmunmap>
  uvmfree(pagetable, sz);
    80001c56:	85ca                	mv	a1,s2
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	a00080e7          	jalr	-1536(ra) # 8000165a <uvmfree>
}
    80001c62:	60e2                	ld	ra,24(sp)
    80001c64:	6442                	ld	s0,16(sp)
    80001c66:	64a2                	ld	s1,8(sp)
    80001c68:	6902                	ld	s2,0(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret

0000000080001c6e <freeproc>:
{
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	1000                	addi	s0,sp,32
    80001c78:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001c7a:	6d28                	ld	a0,88(a0)
    80001c7c:	c509                	beqz	a0,80001c86 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	df4080e7          	jalr	-524(ra) # 80000a72 <kfree>
  p->trapframe = 0;
    80001c86:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001c8a:	68a8                	ld	a0,80(s1)
    80001c8c:	c511                	beqz	a0,80001c98 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c8e:	64ac                	ld	a1,72(s1)
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	f8c080e7          	jalr	-116(ra) # 80001c1c <proc_freepagetable>
  p->pagetable = 0;
    80001c98:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c9c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ca0:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001ca4:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001ca8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cac:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001cb0:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001cb4:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001cb8:	0004ac23          	sw	zero,24(s1)
}
    80001cbc:	60e2                	ld	ra,24(sp)
    80001cbe:	6442                	ld	s0,16(sp)
    80001cc0:	64a2                	ld	s1,8(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret

0000000080001cc6 <allocproc>:
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	e04a                	sd	s2,0(sp)
    80001cd0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001cd2:	00010497          	auipc	s1,0x10
    80001cd6:	09648493          	addi	s1,s1,150 # 80011d68 <proc>
    80001cda:	00016917          	auipc	s2,0x16
    80001cde:	c8e90913          	addi	s2,s2,-882 # 80017968 <tickslock>
    acquire(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	fc8080e7          	jalr	-56(ra) # 80000cac <acquire>
    if (p->state == UNUSED)
    80001cec:	4c9c                	lw	a5,24(s1)
    80001cee:	cf81                	beqz	a5,80001d06 <allocproc+0x40>
      release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	06e080e7          	jalr	110(ra) # 80000d60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001cfa:	17048493          	addi	s1,s1,368
    80001cfe:	ff2492e3          	bne	s1,s2,80001ce2 <allocproc+0x1c>
  return 0;
    80001d02:	4481                	li	s1,0
    80001d04:	a0b9                	j	80001d52 <allocproc+0x8c>
  p->pid = allocpid();
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	e34080e7          	jalr	-460(ra) # 80001b3a <allocpid>
    80001d0e:	dc88                	sw	a0,56(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	e62080e7          	jalr	-414(ra) # 80000b72 <kalloc>
    80001d18:	892a                	mv	s2,a0
    80001d1a:	eca8                	sd	a0,88(s1)
    80001d1c:	c131                	beqz	a0,80001d60 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001d1e:	8526                	mv	a0,s1
    80001d20:	00000097          	auipc	ra,0x0
    80001d24:	e60080e7          	jalr	-416(ra) # 80001b80 <proc_pagetable>
    80001d28:	892a                	mv	s2,a0
    80001d2a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001d2c:	c129                	beqz	a0,80001d6e <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001d2e:	07000613          	li	a2,112
    80001d32:	4581                	li	a1,0
    80001d34:	06048513          	addi	a0,s1,96
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	070080e7          	jalr	112(ra) # 80000da8 <memset>
  p->context.ra = (uint64)forkret;
    80001d40:	00000797          	auipc	a5,0x0
    80001d44:	db278793          	addi	a5,a5,-590 # 80001af2 <forkret>
    80001d48:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d4a:	60bc                	ld	a5,64(s1)
    80001d4c:	6705                	lui	a4,0x1
    80001d4e:	97ba                	add	a5,a5,a4
    80001d50:	f4bc                	sd	a5,104(s1)
}
    80001d52:	8526                	mv	a0,s1
    80001d54:	60e2                	ld	ra,24(sp)
    80001d56:	6442                	ld	s0,16(sp)
    80001d58:	64a2                	ld	s1,8(sp)
    80001d5a:	6902                	ld	s2,0(sp)
    80001d5c:	6105                	addi	sp,sp,32
    80001d5e:	8082                	ret
    release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	ffe080e7          	jalr	-2(ra) # 80000d60 <release>
    return 0;
    80001d6a:	84ca                	mv	s1,s2
    80001d6c:	b7dd                	j	80001d52 <allocproc+0x8c>
    freeproc(p);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	efe080e7          	jalr	-258(ra) # 80001c6e <freeproc>
    release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	fe6080e7          	jalr	-26(ra) # 80000d60 <release>
    return 0;
    80001d82:	84ca                	mv	s1,s2
    80001d84:	b7f9                	j	80001d52 <allocproc+0x8c>

0000000080001d86 <userinit>:
{
    80001d86:	1101                	addi	sp,sp,-32
    80001d88:	ec06                	sd	ra,24(sp)
    80001d8a:	e822                	sd	s0,16(sp)
    80001d8c:	e426                	sd	s1,8(sp)
    80001d8e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	f36080e7          	jalr	-202(ra) # 80001cc6 <allocproc>
    80001d98:	84aa                	mv	s1,a0
  initproc = p;
    80001d9a:	00007797          	auipc	a5,0x7
    80001d9e:	26a7bf23          	sd	a0,638(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001da2:	03400613          	li	a2,52
    80001da6:	00007597          	auipc	a1,0x7
    80001daa:	c1a58593          	addi	a1,a1,-998 # 800089c0 <initcode>
    80001dae:	6928                	ld	a0,80(a0)
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	6de080e7          	jalr	1758(ra) # 8000148e <uvminit>
  p->sz = PGSIZE;
    80001db8:	6785                	lui	a5,0x1
    80001dba:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001dbc:	6cb8                	ld	a4,88(s1)
    80001dbe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001dc2:	6cb8                	ld	a4,88(s1)
    80001dc4:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dc6:	4641                	li	a2,16
    80001dc8:	00006597          	auipc	a1,0x6
    80001dcc:	44858593          	addi	a1,a1,1096 # 80008210 <states.1726+0x48>
    80001dd0:	15848513          	addi	a0,s1,344
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	14c080e7          	jalr	332(ra) # 80000f20 <safestrcpy>
  p->cwd = namei("/");
    80001ddc:	00006517          	auipc	a0,0x6
    80001de0:	44450513          	addi	a0,a0,1092 # 80008220 <states.1726+0x58>
    80001de4:	00002097          	auipc	ra,0x2
    80001de8:	23c080e7          	jalr	572(ra) # 80004020 <namei>
    80001dec:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001df0:	4789                	li	a5,2
    80001df2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	f6a080e7          	jalr	-150(ra) # 80000d60 <release>
}
    80001dfe:	60e2                	ld	ra,24(sp)
    80001e00:	6442                	ld	s0,16(sp)
    80001e02:	64a2                	ld	s1,8(sp)
    80001e04:	6105                	addi	sp,sp,32
    80001e06:	8082                	ret

0000000080001e08 <growproc>:
{
    80001e08:	1101                	addi	sp,sp,-32
    80001e0a:	ec06                	sd	ra,24(sp)
    80001e0c:	e822                	sd	s0,16(sp)
    80001e0e:	e426                	sd	s1,8(sp)
    80001e10:	e04a                	sd	s2,0(sp)
    80001e12:	1000                	addi	s0,sp,32
    80001e14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	ca4080e7          	jalr	-860(ra) # 80001aba <myproc>
    80001e1e:	892a                	mv	s2,a0
  sz = p->sz;
    80001e20:	652c                	ld	a1,72(a0)
    80001e22:	0005851b          	sext.w	a0,a1
  if (n > 0)
    80001e26:	00904f63          	bgtz	s1,80001e44 <growproc+0x3c>
  else if (n < 0)
    80001e2a:	0204cd63          	bltz	s1,80001e64 <growproc+0x5c>
  p->sz = sz;
    80001e2e:	1502                	slli	a0,a0,0x20
    80001e30:	9101                	srli	a0,a0,0x20
    80001e32:	04a93423          	sd	a0,72(s2)
  return 0;
    80001e36:	4501                	li	a0,0
}
    80001e38:	60e2                	ld	ra,24(sp)
    80001e3a:	6442                	ld	s0,16(sp)
    80001e3c:	64a2                	ld	s1,8(sp)
    80001e3e:	6902                	ld	s2,0(sp)
    80001e40:	6105                	addi	sp,sp,32
    80001e42:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001e44:	00a4863b          	addw	a2,s1,a0
    80001e48:	1602                	slli	a2,a2,0x20
    80001e4a:	9201                	srli	a2,a2,0x20
    80001e4c:	1582                	slli	a1,a1,0x20
    80001e4e:	9181                	srli	a1,a1,0x20
    80001e50:	05093503          	ld	a0,80(s2)
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	6f2080e7          	jalr	1778(ra) # 80001546 <uvmalloc>
    80001e5c:	2501                	sext.w	a0,a0
    80001e5e:	f961                	bnez	a0,80001e2e <growproc+0x26>
      return -1;
    80001e60:	557d                	li	a0,-1
    80001e62:	bfd9                	j	80001e38 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e64:	00a4863b          	addw	a2,s1,a0
    80001e68:	1602                	slli	a2,a2,0x20
    80001e6a:	9201                	srli	a2,a2,0x20
    80001e6c:	1582                	slli	a1,a1,0x20
    80001e6e:	9181                	srli	a1,a1,0x20
    80001e70:	05093503          	ld	a0,80(s2)
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	68c080e7          	jalr	1676(ra) # 80001500 <uvmdealloc>
    80001e7c:	2501                	sext.w	a0,a0
    80001e7e:	bf45                	j	80001e2e <growproc+0x26>

0000000080001e80 <fork>:
{
    80001e80:	7179                	addi	sp,sp,-48
    80001e82:	f406                	sd	ra,40(sp)
    80001e84:	f022                	sd	s0,32(sp)
    80001e86:	ec26                	sd	s1,24(sp)
    80001e88:	e84a                	sd	s2,16(sp)
    80001e8a:	e44e                	sd	s3,8(sp)
    80001e8c:	e052                	sd	s4,0(sp)
    80001e8e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	c2a080e7          	jalr	-982(ra) # 80001aba <myproc>
    80001e98:	892a                	mv	s2,a0
  if ((np = allocproc()) == 0)
    80001e9a:	00000097          	auipc	ra,0x0
    80001e9e:	e2c080e7          	jalr	-468(ra) # 80001cc6 <allocproc>
    80001ea2:	c575                	beqz	a0,80001f8e <fork+0x10e>
    80001ea4:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001ea6:	04893603          	ld	a2,72(s2)
    80001eaa:	692c                	ld	a1,80(a0)
    80001eac:	05093503          	ld	a0,80(s2)
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	7e2080e7          	jalr	2018(ra) # 80001692 <uvmcopy>
    80001eb8:	04054c63          	bltz	a0,80001f10 <fork+0x90>
  np->sz = p->sz;
    80001ebc:	04893783          	ld	a5,72(s2)
    80001ec0:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001ec4:	0329b023          	sd	s2,32(s3)
  np->sysmask = p->sysmask;
    80001ec8:	16892783          	lw	a5,360(s2)
    80001ecc:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ed0:	05893683          	ld	a3,88(s2)
    80001ed4:	87b6                	mv	a5,a3
    80001ed6:	0589b703          	ld	a4,88(s3)
    80001eda:	12068693          	addi	a3,a3,288
    80001ede:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ee2:	6788                	ld	a0,8(a5)
    80001ee4:	6b8c                	ld	a1,16(a5)
    80001ee6:	6f90                	ld	a2,24(a5)
    80001ee8:	01073023          	sd	a6,0(a4)
    80001eec:	e708                	sd	a0,8(a4)
    80001eee:	eb0c                	sd	a1,16(a4)
    80001ef0:	ef10                	sd	a2,24(a4)
    80001ef2:	02078793          	addi	a5,a5,32
    80001ef6:	02070713          	addi	a4,a4,32
    80001efa:	fed792e3          	bne	a5,a3,80001ede <fork+0x5e>
  np->trapframe->a0 = 0;
    80001efe:	0589b783          	ld	a5,88(s3)
    80001f02:	0607b823          	sd	zero,112(a5)
    80001f06:	0d000493          	li	s1,208
  for (i = 0; i < NOFILE; i++)
    80001f0a:	15000a13          	li	s4,336
    80001f0e:	a03d                	j	80001f3c <fork+0xbc>
    freeproc(np);
    80001f10:	854e                	mv	a0,s3
    80001f12:	00000097          	auipc	ra,0x0
    80001f16:	d5c080e7          	jalr	-676(ra) # 80001c6e <freeproc>
    release(&np->lock);
    80001f1a:	854e                	mv	a0,s3
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	e44080e7          	jalr	-444(ra) # 80000d60 <release>
    return -1;
    80001f24:	54fd                	li	s1,-1
    80001f26:	a899                	j	80001f7c <fork+0xfc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f28:	00002097          	auipc	ra,0x2
    80001f2c:	7b6080e7          	jalr	1974(ra) # 800046de <filedup>
    80001f30:	009987b3          	add	a5,s3,s1
    80001f34:	e388                	sd	a0,0(a5)
  for (i = 0; i < NOFILE; i++)
    80001f36:	04a1                	addi	s1,s1,8
    80001f38:	01448763          	beq	s1,s4,80001f46 <fork+0xc6>
    if (p->ofile[i])
    80001f3c:	009907b3          	add	a5,s2,s1
    80001f40:	6388                	ld	a0,0(a5)
    80001f42:	f17d                	bnez	a0,80001f28 <fork+0xa8>
    80001f44:	bfcd                	j	80001f36 <fork+0xb6>
  np->cwd = idup(p->cwd);
    80001f46:	15093503          	ld	a0,336(s2)
    80001f4a:	00002097          	auipc	ra,0x2
    80001f4e:	8de080e7          	jalr	-1826(ra) # 80003828 <idup>
    80001f52:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f56:	4641                	li	a2,16
    80001f58:	15890593          	addi	a1,s2,344
    80001f5c:	15898513          	addi	a0,s3,344
    80001f60:	fffff097          	auipc	ra,0xfffff
    80001f64:	fc0080e7          	jalr	-64(ra) # 80000f20 <safestrcpy>
  pid = np->pid;
    80001f68:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001f6c:	4789                	li	a5,2
    80001f6e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f72:	854e                	mv	a0,s3
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	dec080e7          	jalr	-532(ra) # 80000d60 <release>
}
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	70a2                	ld	ra,40(sp)
    80001f80:	7402                	ld	s0,32(sp)
    80001f82:	64e2                	ld	s1,24(sp)
    80001f84:	6942                	ld	s2,16(sp)
    80001f86:	69a2                	ld	s3,8(sp)
    80001f88:	6a02                	ld	s4,0(sp)
    80001f8a:	6145                	addi	sp,sp,48
    80001f8c:	8082                	ret
    return -1;
    80001f8e:	54fd                	li	s1,-1
    80001f90:	b7f5                	j	80001f7c <fork+0xfc>

0000000080001f92 <reparent>:
{
    80001f92:	7179                	addi	sp,sp,-48
    80001f94:	f406                	sd	ra,40(sp)
    80001f96:	f022                	sd	s0,32(sp)
    80001f98:	ec26                	sd	s1,24(sp)
    80001f9a:	e84a                	sd	s2,16(sp)
    80001f9c:	e44e                	sd	s3,8(sp)
    80001f9e:	e052                	sd	s4,0(sp)
    80001fa0:	1800                	addi	s0,sp,48
    80001fa2:	89aa                	mv	s3,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80001fa4:	00010497          	auipc	s1,0x10
    80001fa8:	dc448493          	addi	s1,s1,-572 # 80011d68 <proc>
      pp->parent = initproc;
    80001fac:	00007a17          	auipc	s4,0x7
    80001fb0:	06ca0a13          	addi	s4,s4,108 # 80009018 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80001fb4:	00016917          	auipc	s2,0x16
    80001fb8:	9b490913          	addi	s2,s2,-1612 # 80017968 <tickslock>
    80001fbc:	a029                	j	80001fc6 <reparent+0x34>
    80001fbe:	17048493          	addi	s1,s1,368
    80001fc2:	03248363          	beq	s1,s2,80001fe8 <reparent+0x56>
    if (pp->parent == p)
    80001fc6:	709c                	ld	a5,32(s1)
    80001fc8:	ff379be3          	bne	a5,s3,80001fbe <reparent+0x2c>
      acquire(&pp->lock);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	cde080e7          	jalr	-802(ra) # 80000cac <acquire>
      pp->parent = initproc;
    80001fd6:	000a3783          	ld	a5,0(s4)
    80001fda:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	d82080e7          	jalr	-638(ra) # 80000d60 <release>
    80001fe6:	bfe1                	j	80001fbe <reparent+0x2c>
}
    80001fe8:	70a2                	ld	ra,40(sp)
    80001fea:	7402                	ld	s0,32(sp)
    80001fec:	64e2                	ld	s1,24(sp)
    80001fee:	6942                	ld	s2,16(sp)
    80001ff0:	69a2                	ld	s3,8(sp)
    80001ff2:	6a02                	ld	s4,0(sp)
    80001ff4:	6145                	addi	sp,sp,48
    80001ff6:	8082                	ret

0000000080001ff8 <scheduler>:
{
    80001ff8:	715d                	addi	sp,sp,-80
    80001ffa:	e486                	sd	ra,72(sp)
    80001ffc:	e0a2                	sd	s0,64(sp)
    80001ffe:	fc26                	sd	s1,56(sp)
    80002000:	f84a                	sd	s2,48(sp)
    80002002:	f44e                	sd	s3,40(sp)
    80002004:	f052                	sd	s4,32(sp)
    80002006:	ec56                	sd	s5,24(sp)
    80002008:	e85a                	sd	s6,16(sp)
    8000200a:	e45e                	sd	s7,8(sp)
    8000200c:	e062                	sd	s8,0(sp)
    8000200e:	0880                	addi	s0,sp,80
    80002010:	8792                	mv	a5,tp
  int id = r_tp();
    80002012:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002014:	00779b13          	slli	s6,a5,0x7
    80002018:	00010717          	auipc	a4,0x10
    8000201c:	93870713          	addi	a4,a4,-1736 # 80011950 <pid_lock>
    80002020:	975a                	add	a4,a4,s6
    80002022:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002026:	00010717          	auipc	a4,0x10
    8000202a:	94a70713          	addi	a4,a4,-1718 # 80011970 <cpus+0x8>
    8000202e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002030:	4c0d                	li	s8,3
        c->proc = p;
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	00010a17          	auipc	s4,0x10
    80002038:	91ca0a13          	addi	s4,s4,-1764 # 80011950 <pid_lock>
    8000203c:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000203e:	00016997          	auipc	s3,0x16
    80002042:	92a98993          	addi	s3,s3,-1750 # 80017968 <tickslock>
        found = 1;
    80002046:	4b85                	li	s7,1
    80002048:	a899                	j	8000209e <scheduler+0xa6>
        p->state = RUNNING;
    8000204a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000204e:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80002052:	06048593          	addi	a1,s1,96
    80002056:	855a                	mv	a0,s6
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	66e080e7          	jalr	1646(ra) # 800026c6 <swtch>
        c->proc = 0;
    80002060:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80002064:	8ade                	mv	s5,s7
      release(&p->lock);
    80002066:	8526                	mv	a0,s1
    80002068:	fffff097          	auipc	ra,0xfffff
    8000206c:	cf8080e7          	jalr	-776(ra) # 80000d60 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002070:	17048493          	addi	s1,s1,368
    80002074:	01348b63          	beq	s1,s3,8000208a <scheduler+0x92>
      acquire(&p->lock);
    80002078:	8526                	mv	a0,s1
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c32080e7          	jalr	-974(ra) # 80000cac <acquire>
      if (p->state == RUNNABLE)
    80002082:	4c9c                	lw	a5,24(s1)
    80002084:	ff2791e3          	bne	a5,s2,80002066 <scheduler+0x6e>
    80002088:	b7c9                	j	8000204a <scheduler+0x52>
    if (found == 0)
    8000208a:	000a9a63          	bnez	s5,8000209e <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000208e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002092:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002096:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000209a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020a6:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020aa:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++)
    800020ac:	00010497          	auipc	s1,0x10
    800020b0:	cbc48493          	addi	s1,s1,-836 # 80011d68 <proc>
      if (p->state == RUNNABLE)
    800020b4:	4909                	li	s2,2
    800020b6:	b7c9                	j	80002078 <scheduler+0x80>

00000000800020b8 <sched>:
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c6:	00000097          	auipc	ra,0x0
    800020ca:	9f4080e7          	jalr	-1548(ra) # 80001aba <myproc>
    800020ce:	892a                	mv	s2,a0
  if (!holding(&p->lock))
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	b62080e7          	jalr	-1182(ra) # 80000c32 <holding>
    800020d8:	cd25                	beqz	a0,80002150 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020da:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800020dc:	2781                	sext.w	a5,a5
    800020de:	079e                	slli	a5,a5,0x7
    800020e0:	00010717          	auipc	a4,0x10
    800020e4:	87070713          	addi	a4,a4,-1936 # 80011950 <pid_lock>
    800020e8:	97ba                	add	a5,a5,a4
    800020ea:	0907a703          	lw	a4,144(a5)
    800020ee:	4785                	li	a5,1
    800020f0:	06f71863          	bne	a4,a5,80002160 <sched+0xa8>
  if (p->state == RUNNING)
    800020f4:	01892703          	lw	a4,24(s2)
    800020f8:	478d                	li	a5,3
    800020fa:	06f70b63          	beq	a4,a5,80002170 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002102:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002104:	efb5                	bnez	a5,80002180 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002106:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002108:	00010497          	auipc	s1,0x10
    8000210c:	84848493          	addi	s1,s1,-1976 # 80011950 <pid_lock>
    80002110:	2781                	sext.w	a5,a5
    80002112:	079e                	slli	a5,a5,0x7
    80002114:	97a6                	add	a5,a5,s1
    80002116:	0947a983          	lw	s3,148(a5)
    8000211a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000211c:	2781                	sext.w	a5,a5
    8000211e:	079e                	slli	a5,a5,0x7
    80002120:	00010597          	auipc	a1,0x10
    80002124:	85058593          	addi	a1,a1,-1968 # 80011970 <cpus+0x8>
    80002128:	95be                	add	a1,a1,a5
    8000212a:	06090513          	addi	a0,s2,96
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	598080e7          	jalr	1432(ra) # 800026c6 <swtch>
    80002136:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002138:	2781                	sext.w	a5,a5
    8000213a:	079e                	slli	a5,a5,0x7
    8000213c:	97a6                	add	a5,a5,s1
    8000213e:	0937aa23          	sw	s3,148(a5)
}
    80002142:	70a2                	ld	ra,40(sp)
    80002144:	7402                	ld	s0,32(sp)
    80002146:	64e2                	ld	s1,24(sp)
    80002148:	6942                	ld	s2,16(sp)
    8000214a:	69a2                	ld	s3,8(sp)
    8000214c:	6145                	addi	sp,sp,48
    8000214e:	8082                	ret
    panic("sched p->lock");
    80002150:	00006517          	auipc	a0,0x6
    80002154:	0d850513          	addi	a0,a0,216 # 80008228 <states.1726+0x60>
    80002158:	ffffe097          	auipc	ra,0xffffe
    8000215c:	41c080e7          	jalr	1052(ra) # 80000574 <panic>
    panic("sched locks");
    80002160:	00006517          	auipc	a0,0x6
    80002164:	0d850513          	addi	a0,a0,216 # 80008238 <states.1726+0x70>
    80002168:	ffffe097          	auipc	ra,0xffffe
    8000216c:	40c080e7          	jalr	1036(ra) # 80000574 <panic>
    panic("sched running");
    80002170:	00006517          	auipc	a0,0x6
    80002174:	0d850513          	addi	a0,a0,216 # 80008248 <states.1726+0x80>
    80002178:	ffffe097          	auipc	ra,0xffffe
    8000217c:	3fc080e7          	jalr	1020(ra) # 80000574 <panic>
    panic("sched interruptible");
    80002180:	00006517          	auipc	a0,0x6
    80002184:	0d850513          	addi	a0,a0,216 # 80008258 <states.1726+0x90>
    80002188:	ffffe097          	auipc	ra,0xffffe
    8000218c:	3ec080e7          	jalr	1004(ra) # 80000574 <panic>

0000000080002190 <exit>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	918080e7          	jalr	-1768(ra) # 80001aba <myproc>
    800021aa:	89aa                	mv	s3,a0
  if (p == initproc)
    800021ac:	00007797          	auipc	a5,0x7
    800021b0:	e6c78793          	addi	a5,a5,-404 # 80009018 <initproc>
    800021b4:	639c                	ld	a5,0(a5)
    800021b6:	0d050493          	addi	s1,a0,208
    800021ba:	15050913          	addi	s2,a0,336
    800021be:	02a79363          	bne	a5,a0,800021e4 <exit+0x54>
    panic("init exiting");
    800021c2:	00006517          	auipc	a0,0x6
    800021c6:	0ae50513          	addi	a0,a0,174 # 80008270 <states.1726+0xa8>
    800021ca:	ffffe097          	auipc	ra,0xffffe
    800021ce:	3aa080e7          	jalr	938(ra) # 80000574 <panic>
      fileclose(f);
    800021d2:	00002097          	auipc	ra,0x2
    800021d6:	55e080e7          	jalr	1374(ra) # 80004730 <fileclose>
      p->ofile[fd] = 0;
    800021da:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800021de:	04a1                	addi	s1,s1,8
    800021e0:	01248563          	beq	s1,s2,800021ea <exit+0x5a>
    if (p->ofile[fd])
    800021e4:	6088                	ld	a0,0(s1)
    800021e6:	f575                	bnez	a0,800021d2 <exit+0x42>
    800021e8:	bfdd                	j	800021de <exit+0x4e>
  begin_op();
    800021ea:	00002097          	auipc	ra,0x2
    800021ee:	044080e7          	jalr	68(ra) # 8000422e <begin_op>
  iput(p->cwd);
    800021f2:	1509b503          	ld	a0,336(s3)
    800021f6:	00002097          	auipc	ra,0x2
    800021fa:	82c080e7          	jalr	-2004(ra) # 80003a22 <iput>
  end_op();
    800021fe:	00002097          	auipc	ra,0x2
    80002202:	0b0080e7          	jalr	176(ra) # 800042ae <end_op>
  p->cwd = 0;
    80002206:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000220a:	00007497          	auipc	s1,0x7
    8000220e:	e0e48493          	addi	s1,s1,-498 # 80009018 <initproc>
    80002212:	6088                	ld	a0,0(s1)
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	a98080e7          	jalr	-1384(ra) # 80000cac <acquire>
  wakeup1(initproc);
    8000221c:	6088                	ld	a0,0(s1)
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	75c080e7          	jalr	1884(ra) # 8000197a <wakeup1>
  release(&initproc->lock);
    80002226:	6088                	ld	a0,0(s1)
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	b38080e7          	jalr	-1224(ra) # 80000d60 <release>
  acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a7a080e7          	jalr	-1414(ra) # 80000cac <acquire>
  struct proc *original_parent = p->parent;
    8000223a:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    8000223e:	854e                	mv	a0,s3
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	b20080e7          	jalr	-1248(ra) # 80000d60 <release>
  acquire(&original_parent->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	a62080e7          	jalr	-1438(ra) # 80000cac <acquire>
  acquire(&p->lock);
    80002252:	854e                	mv	a0,s3
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a58080e7          	jalr	-1448(ra) # 80000cac <acquire>
  reparent(p);
    8000225c:	854e                	mv	a0,s3
    8000225e:	00000097          	auipc	ra,0x0
    80002262:	d34080e7          	jalr	-716(ra) # 80001f92 <reparent>
  wakeup1(original_parent);
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	712080e7          	jalr	1810(ra) # 8000197a <wakeup1>
  p->xstate = status;
    80002270:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002274:	4791                	li	a5,4
    80002276:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000227a:	8526                	mv	a0,s1
    8000227c:	fffff097          	auipc	ra,0xfffff
    80002280:	ae4080e7          	jalr	-1308(ra) # 80000d60 <release>
  sched();
    80002284:	00000097          	auipc	ra,0x0
    80002288:	e34080e7          	jalr	-460(ra) # 800020b8 <sched>
  panic("zombie exit");
    8000228c:	00006517          	auipc	a0,0x6
    80002290:	ff450513          	addi	a0,a0,-12 # 80008280 <states.1726+0xb8>
    80002294:	ffffe097          	auipc	ra,0xffffe
    80002298:	2e0080e7          	jalr	736(ra) # 80000574 <panic>

000000008000229c <yield>:
{
    8000229c:	1101                	addi	sp,sp,-32
    8000229e:	ec06                	sd	ra,24(sp)
    800022a0:	e822                	sd	s0,16(sp)
    800022a2:	e426                	sd	s1,8(sp)
    800022a4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	814080e7          	jalr	-2028(ra) # 80001aba <myproc>
    800022ae:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	9fc080e7          	jalr	-1540(ra) # 80000cac <acquire>
  p->state = RUNNABLE;
    800022b8:	4789                	li	a5,2
    800022ba:	cc9c                	sw	a5,24(s1)
  sched();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	dfc080e7          	jalr	-516(ra) # 800020b8 <sched>
  release(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	a9a080e7          	jalr	-1382(ra) # 80000d60 <release>
}
    800022ce:	60e2                	ld	ra,24(sp)
    800022d0:	6442                	ld	s0,16(sp)
    800022d2:	64a2                	ld	s1,8(sp)
    800022d4:	6105                	addi	sp,sp,32
    800022d6:	8082                	ret

00000000800022d8 <sleep>:
{
    800022d8:	7179                	addi	sp,sp,-48
    800022da:	f406                	sd	ra,40(sp)
    800022dc:	f022                	sd	s0,32(sp)
    800022de:	ec26                	sd	s1,24(sp)
    800022e0:	e84a                	sd	s2,16(sp)
    800022e2:	e44e                	sd	s3,8(sp)
    800022e4:	1800                	addi	s0,sp,48
    800022e6:	89aa                	mv	s3,a0
    800022e8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	7d0080e7          	jalr	2000(ra) # 80001aba <myproc>
    800022f2:	84aa                	mv	s1,a0
  if (lk != &p->lock)
    800022f4:	05250663          	beq	a0,s2,80002340 <sleep+0x68>
    acquire(&p->lock); //DOC: sleeplock1
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	9b4080e7          	jalr	-1612(ra) # 80000cac <acquire>
    release(lk);
    80002300:	854a                	mv	a0,s2
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	a5e080e7          	jalr	-1442(ra) # 80000d60 <release>
  p->chan = chan;
    8000230a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000230e:	4785                	li	a5,1
    80002310:	cc9c                	sw	a5,24(s1)
  sched();
    80002312:	00000097          	auipc	ra,0x0
    80002316:	da6080e7          	jalr	-602(ra) # 800020b8 <sched>
  p->chan = 0;
    8000231a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	a40080e7          	jalr	-1472(ra) # 80000d60 <release>
    acquire(lk);
    80002328:	854a                	mv	a0,s2
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	982080e7          	jalr	-1662(ra) # 80000cac <acquire>
}
    80002332:	70a2                	ld	ra,40(sp)
    80002334:	7402                	ld	s0,32(sp)
    80002336:	64e2                	ld	s1,24(sp)
    80002338:	6942                	ld	s2,16(sp)
    8000233a:	69a2                	ld	s3,8(sp)
    8000233c:	6145                	addi	sp,sp,48
    8000233e:	8082                	ret
  p->chan = chan;
    80002340:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002344:	4785                	li	a5,1
    80002346:	cd1c                	sw	a5,24(a0)
  sched();
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	d70080e7          	jalr	-656(ra) # 800020b8 <sched>
  p->chan = 0;
    80002350:	0204b423          	sd	zero,40(s1)
  if (lk != &p->lock)
    80002354:	bff9                	j	80002332 <sleep+0x5a>

0000000080002356 <wait>:
{
    80002356:	715d                	addi	sp,sp,-80
    80002358:	e486                	sd	ra,72(sp)
    8000235a:	e0a2                	sd	s0,64(sp)
    8000235c:	fc26                	sd	s1,56(sp)
    8000235e:	f84a                	sd	s2,48(sp)
    80002360:	f44e                	sd	s3,40(sp)
    80002362:	f052                	sd	s4,32(sp)
    80002364:	ec56                	sd	s5,24(sp)
    80002366:	e85a                	sd	s6,16(sp)
    80002368:	e45e                	sd	s7,8(sp)
    8000236a:	e062                	sd	s8,0(sp)
    8000236c:	0880                	addi	s0,sp,80
    8000236e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	74a080e7          	jalr	1866(ra) # 80001aba <myproc>
    80002378:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000237a:	8c2a                	mv	s8,a0
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	930080e7          	jalr	-1744(ra) # 80000cac <acquire>
    havekids = 0;
    80002384:	4b01                	li	s6,0
        if (np->state == ZOMBIE)
    80002386:	4a11                	li	s4,4
    for (np = proc; np < &proc[NPROC]; np++)
    80002388:	00015997          	auipc	s3,0x15
    8000238c:	5e098993          	addi	s3,s3,1504 # 80017968 <tickslock>
        havekids = 1;
    80002390:	4a85                	li	s5,1
    havekids = 0;
    80002392:	875a                	mv	a4,s6
    for (np = proc; np < &proc[NPROC]; np++)
    80002394:	00010497          	auipc	s1,0x10
    80002398:	9d448493          	addi	s1,s1,-1580 # 80011d68 <proc>
    8000239c:	a08d                	j	800023fe <wait+0xa8>
          pid = np->pid;
    8000239e:	0384a983          	lw	s3,56(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023a2:	000b8e63          	beqz	s7,800023be <wait+0x68>
    800023a6:	4691                	li	a3,4
    800023a8:	03448613          	addi	a2,s1,52
    800023ac:	85de                	mv	a1,s7
    800023ae:	05093503          	ld	a0,80(s2)
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	3e4080e7          	jalr	996(ra) # 80001796 <copyout>
    800023ba:	02054263          	bltz	a0,800023de <wait+0x88>
          freeproc(np);
    800023be:	8526                	mv	a0,s1
    800023c0:	00000097          	auipc	ra,0x0
    800023c4:	8ae080e7          	jalr	-1874(ra) # 80001c6e <freeproc>
          release(&np->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	996080e7          	jalr	-1642(ra) # 80000d60 <release>
          release(&p->lock);
    800023d2:	854a                	mv	a0,s2
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	98c080e7          	jalr	-1652(ra) # 80000d60 <release>
          return pid;
    800023dc:	a8a9                	j	80002436 <wait+0xe0>
            release(&np->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	980080e7          	jalr	-1664(ra) # 80000d60 <release>
            release(&p->lock);
    800023e8:	854a                	mv	a0,s2
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	976080e7          	jalr	-1674(ra) # 80000d60 <release>
            return -1;
    800023f2:	59fd                	li	s3,-1
    800023f4:	a089                	j	80002436 <wait+0xe0>
    for (np = proc; np < &proc[NPROC]; np++)
    800023f6:	17048493          	addi	s1,s1,368
    800023fa:	03348463          	beq	s1,s3,80002422 <wait+0xcc>
      if (np->parent == p)
    800023fe:	709c                	ld	a5,32(s1)
    80002400:	ff279be3          	bne	a5,s2,800023f6 <wait+0xa0>
        acquire(&np->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	8a6080e7          	jalr	-1882(ra) # 80000cac <acquire>
        if (np->state == ZOMBIE)
    8000240e:	4c9c                	lw	a5,24(s1)
    80002410:	f94787e3          	beq	a5,s4,8000239e <wait+0x48>
        release(&np->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	94a080e7          	jalr	-1718(ra) # 80000d60 <release>
        havekids = 1;
    8000241e:	8756                	mv	a4,s5
    80002420:	bfd9                	j	800023f6 <wait+0xa0>
    if (!havekids || p->killed)
    80002422:	c701                	beqz	a4,8000242a <wait+0xd4>
    80002424:	03092783          	lw	a5,48(s2)
    80002428:	c785                	beqz	a5,80002450 <wait+0xfa>
      release(&p->lock);
    8000242a:	854a                	mv	a0,s2
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	934080e7          	jalr	-1740(ra) # 80000d60 <release>
      return -1;
    80002434:	59fd                	li	s3,-1
}
    80002436:	854e                	mv	a0,s3
    80002438:	60a6                	ld	ra,72(sp)
    8000243a:	6406                	ld	s0,64(sp)
    8000243c:	74e2                	ld	s1,56(sp)
    8000243e:	7942                	ld	s2,48(sp)
    80002440:	79a2                	ld	s3,40(sp)
    80002442:	7a02                	ld	s4,32(sp)
    80002444:	6ae2                	ld	s5,24(sp)
    80002446:	6b42                	ld	s6,16(sp)
    80002448:	6ba2                	ld	s7,8(sp)
    8000244a:	6c02                	ld	s8,0(sp)
    8000244c:	6161                	addi	sp,sp,80
    8000244e:	8082                	ret
    sleep(p, &p->lock); //DOC: wait-sleep
    80002450:	85e2                	mv	a1,s8
    80002452:	854a                	mv	a0,s2
    80002454:	00000097          	auipc	ra,0x0
    80002458:	e84080e7          	jalr	-380(ra) # 800022d8 <sleep>
    havekids = 0;
    8000245c:	bf1d                	j	80002392 <wait+0x3c>

000000008000245e <wakeup>:
{
    8000245e:	7139                	addi	sp,sp,-64
    80002460:	fc06                	sd	ra,56(sp)
    80002462:	f822                	sd	s0,48(sp)
    80002464:	f426                	sd	s1,40(sp)
    80002466:	f04a                	sd	s2,32(sp)
    80002468:	ec4e                	sd	s3,24(sp)
    8000246a:	e852                	sd	s4,16(sp)
    8000246c:	e456                	sd	s5,8(sp)
    8000246e:	0080                	addi	s0,sp,64
    80002470:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    80002472:	00010497          	auipc	s1,0x10
    80002476:	8f648493          	addi	s1,s1,-1802 # 80011d68 <proc>
    if (p->state == SLEEPING && p->chan == chan)
    8000247a:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000247c:	4a89                	li	s5,2
  for (p = proc; p < &proc[NPROC]; p++)
    8000247e:	00015917          	auipc	s2,0x15
    80002482:	4ea90913          	addi	s2,s2,1258 # 80017968 <tickslock>
    80002486:	a821                	j	8000249e <wakeup+0x40>
      p->state = RUNNABLE;
    80002488:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000248c:	8526                	mv	a0,s1
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	8d2080e7          	jalr	-1838(ra) # 80000d60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002496:	17048493          	addi	s1,s1,368
    8000249a:	01248e63          	beq	s1,s2,800024b6 <wakeup+0x58>
    acquire(&p->lock);
    8000249e:	8526                	mv	a0,s1
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	80c080e7          	jalr	-2036(ra) # 80000cac <acquire>
    if (p->state == SLEEPING && p->chan == chan)
    800024a8:	4c9c                	lw	a5,24(s1)
    800024aa:	ff3791e3          	bne	a5,s3,8000248c <wakeup+0x2e>
    800024ae:	749c                	ld	a5,40(s1)
    800024b0:	fd479ee3          	bne	a5,s4,8000248c <wakeup+0x2e>
    800024b4:	bfd1                	j	80002488 <wakeup+0x2a>
}
    800024b6:	70e2                	ld	ra,56(sp)
    800024b8:	7442                	ld	s0,48(sp)
    800024ba:	74a2                	ld	s1,40(sp)
    800024bc:	7902                	ld	s2,32(sp)
    800024be:	69e2                	ld	s3,24(sp)
    800024c0:	6a42                	ld	s4,16(sp)
    800024c2:	6aa2                	ld	s5,8(sp)
    800024c4:	6121                	addi	sp,sp,64
    800024c6:	8082                	ret

00000000800024c8 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800024c8:	7179                	addi	sp,sp,-48
    800024ca:	f406                	sd	ra,40(sp)
    800024cc:	f022                	sd	s0,32(sp)
    800024ce:	ec26                	sd	s1,24(sp)
    800024d0:	e84a                	sd	s2,16(sp)
    800024d2:	e44e                	sd	s3,8(sp)
    800024d4:	1800                	addi	s0,sp,48
    800024d6:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024d8:	00010497          	auipc	s1,0x10
    800024dc:	89048493          	addi	s1,s1,-1904 # 80011d68 <proc>
    800024e0:	00015997          	auipc	s3,0x15
    800024e4:	48898993          	addi	s3,s3,1160 # 80017968 <tickslock>
  {
    acquire(&p->lock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	ffffe097          	auipc	ra,0xffffe
    800024ee:	7c2080e7          	jalr	1986(ra) # 80000cac <acquire>
    if (p->pid == pid)
    800024f2:	5c9c                	lw	a5,56(s1)
    800024f4:	01278d63          	beq	a5,s2,8000250e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	866080e7          	jalr	-1946(ra) # 80000d60 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002502:	17048493          	addi	s1,s1,368
    80002506:	ff3491e3          	bne	s1,s3,800024e8 <kill+0x20>
  }
  return -1;
    8000250a:	557d                	li	a0,-1
    8000250c:	a829                	j	80002526 <kill+0x5e>
      p->killed = 1;
    8000250e:	4785                	li	a5,1
    80002510:	d89c                	sw	a5,48(s1)
      if (p->state == SLEEPING)
    80002512:	4c98                	lw	a4,24(s1)
    80002514:	4785                	li	a5,1
    80002516:	00f70f63          	beq	a4,a5,80002534 <kill+0x6c>
      release(&p->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	844080e7          	jalr	-1980(ra) # 80000d60 <release>
      return 0;
    80002524:	4501                	li	a0,0
}
    80002526:	70a2                	ld	ra,40(sp)
    80002528:	7402                	ld	s0,32(sp)
    8000252a:	64e2                	ld	s1,24(sp)
    8000252c:	6942                	ld	s2,16(sp)
    8000252e:	69a2                	ld	s3,8(sp)
    80002530:	6145                	addi	sp,sp,48
    80002532:	8082                	ret
        p->state = RUNNABLE;
    80002534:	4789                	li	a5,2
    80002536:	cc9c                	sw	a5,24(s1)
    80002538:	b7cd                	j	8000251a <kill+0x52>

000000008000253a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000253a:	7179                	addi	sp,sp,-48
    8000253c:	f406                	sd	ra,40(sp)
    8000253e:	f022                	sd	s0,32(sp)
    80002540:	ec26                	sd	s1,24(sp)
    80002542:	e84a                	sd	s2,16(sp)
    80002544:	e44e                	sd	s3,8(sp)
    80002546:	e052                	sd	s4,0(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	84aa                	mv	s1,a0
    8000254c:	892e                	mv	s2,a1
    8000254e:	89b2                	mv	s3,a2
    80002550:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002552:	fffff097          	auipc	ra,0xfffff
    80002556:	568080e7          	jalr	1384(ra) # 80001aba <myproc>
  if (user_dst)
    8000255a:	c08d                	beqz	s1,8000257c <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000255c:	86d2                	mv	a3,s4
    8000255e:	864e                	mv	a2,s3
    80002560:	85ca                	mv	a1,s2
    80002562:	6928                	ld	a0,80(a0)
    80002564:	fffff097          	auipc	ra,0xfffff
    80002568:	232080e7          	jalr	562(ra) # 80001796 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6a02                	ld	s4,0(sp)
    80002578:	6145                	addi	sp,sp,48
    8000257a:	8082                	ret
    memmove((char *)dst, src, len);
    8000257c:	000a061b          	sext.w	a2,s4
    80002580:	85ce                	mv	a1,s3
    80002582:	854a                	mv	a0,s2
    80002584:	fffff097          	auipc	ra,0xfffff
    80002588:	890080e7          	jalr	-1904(ra) # 80000e14 <memmove>
    return 0;
    8000258c:	8526                	mv	a0,s1
    8000258e:	bff9                	j	8000256c <either_copyout+0x32>

0000000080002590 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002590:	7179                	addi	sp,sp,-48
    80002592:	f406                	sd	ra,40(sp)
    80002594:	f022                	sd	s0,32(sp)
    80002596:	ec26                	sd	s1,24(sp)
    80002598:	e84a                	sd	s2,16(sp)
    8000259a:	e44e                	sd	s3,8(sp)
    8000259c:	e052                	sd	s4,0(sp)
    8000259e:	1800                	addi	s0,sp,48
    800025a0:	892a                	mv	s2,a0
    800025a2:	84ae                	mv	s1,a1
    800025a4:	89b2                	mv	s3,a2
    800025a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025a8:	fffff097          	auipc	ra,0xfffff
    800025ac:	512080e7          	jalr	1298(ra) # 80001aba <myproc>
  if (user_src)
    800025b0:	c08d                	beqz	s1,800025d2 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800025b2:	86d2                	mv	a3,s4
    800025b4:	864e                	mv	a2,s3
    800025b6:	85ca                	mv	a1,s2
    800025b8:	6928                	ld	a0,80(a0)
    800025ba:	fffff097          	auipc	ra,0xfffff
    800025be:	268080e7          	jalr	616(ra) # 80001822 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800025c2:	70a2                	ld	ra,40(sp)
    800025c4:	7402                	ld	s0,32(sp)
    800025c6:	64e2                	ld	s1,24(sp)
    800025c8:	6942                	ld	s2,16(sp)
    800025ca:	69a2                	ld	s3,8(sp)
    800025cc:	6a02                	ld	s4,0(sp)
    800025ce:	6145                	addi	sp,sp,48
    800025d0:	8082                	ret
    memmove(dst, (char *)src, len);
    800025d2:	000a061b          	sext.w	a2,s4
    800025d6:	85ce                	mv	a1,s3
    800025d8:	854a                	mv	a0,s2
    800025da:	fffff097          	auipc	ra,0xfffff
    800025de:	83a080e7          	jalr	-1990(ra) # 80000e14 <memmove>
    return 0;
    800025e2:	8526                	mv	a0,s1
    800025e4:	bff9                	j	800025c2 <either_copyin+0x32>

00000000800025e6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025e6:	715d                	addi	sp,sp,-80
    800025e8:	e486                	sd	ra,72(sp)
    800025ea:	e0a2                	sd	s0,64(sp)
    800025ec:	fc26                	sd	s1,56(sp)
    800025ee:	f84a                	sd	s2,48(sp)
    800025f0:	f44e                	sd	s3,40(sp)
    800025f2:	f052                	sd	s4,32(sp)
    800025f4:	ec56                	sd	s5,24(sp)
    800025f6:	e85a                	sd	s6,16(sp)
    800025f8:	e45e                	sd	s7,8(sp)
    800025fa:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025fc:	00006517          	auipc	a0,0x6
    80002600:	acc50513          	addi	a0,a0,-1332 # 800080c8 <digits+0xb0>
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	fba080e7          	jalr	-70(ra) # 800005be <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000260c:	00010497          	auipc	s1,0x10
    80002610:	8b448493          	addi	s1,s1,-1868 # 80011ec0 <proc+0x158>
    80002614:	00015917          	auipc	s2,0x15
    80002618:	4ac90913          	addi	s2,s2,1196 # 80017ac0 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261c:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000261e:	00006997          	auipc	s3,0x6
    80002622:	c7298993          	addi	s3,s3,-910 # 80008290 <states.1726+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002626:	00006a97          	auipc	s5,0x6
    8000262a:	c72a8a93          	addi	s5,s5,-910 # 80008298 <states.1726+0xd0>
    printf("\n");
    8000262e:	00006a17          	auipc	s4,0x6
    80002632:	a9aa0a13          	addi	s4,s4,-1382 # 800080c8 <digits+0xb0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002636:	00006b97          	auipc	s7,0x6
    8000263a:	b92b8b93          	addi	s7,s7,-1134 # 800081c8 <states.1726>
    8000263e:	a015                	j	80002662 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80002640:	86ba                	mv	a3,a4
    80002642:	ee072583          	lw	a1,-288(a4)
    80002646:	8556                	mv	a0,s5
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	f76080e7          	jalr	-138(ra) # 800005be <printf>
    printf("\n");
    80002650:	8552                	mv	a0,s4
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	f6c080e7          	jalr	-148(ra) # 800005be <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000265a:	17048493          	addi	s1,s1,368
    8000265e:	03248163          	beq	s1,s2,80002680 <procdump+0x9a>
    if (p->state == UNUSED)
    80002662:	8726                	mv	a4,s1
    80002664:	ec04a783          	lw	a5,-320(s1)
    80002668:	dbed                	beqz	a5,8000265a <procdump+0x74>
      state = "???";
    8000266a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000266c:	fcfb6ae3          	bltu	s6,a5,80002640 <procdump+0x5a>
    80002670:	1782                	slli	a5,a5,0x20
    80002672:	9381                	srli	a5,a5,0x20
    80002674:	078e                	slli	a5,a5,0x3
    80002676:	97de                	add	a5,a5,s7
    80002678:	6390                	ld	a2,0(a5)
    8000267a:	f279                	bnez	a2,80002640 <procdump+0x5a>
      state = "???";
    8000267c:	864e                	mv	a2,s3
    8000267e:	b7c9                	j	80002640 <procdump+0x5a>
  }
}
    80002680:	60a6                	ld	ra,72(sp)
    80002682:	6406                	ld	s0,64(sp)
    80002684:	74e2                	ld	s1,56(sp)
    80002686:	7942                	ld	s2,48(sp)
    80002688:	79a2                	ld	s3,40(sp)
    8000268a:	7a02                	ld	s4,32(sp)
    8000268c:	6ae2                	ld	s5,24(sp)
    8000268e:	6b42                	ld	s6,16(sp)
    80002690:	6ba2                	ld	s7,8(sp)
    80002692:	6161                	addi	sp,sp,80
    80002694:	8082                	ret

0000000080002696 <getnproc>:

int getnproc()
{
    80002696:	1141                	addi	sp,sp,-16
    80002698:	e422                	sd	s0,8(sp)
    8000269a:	0800                	addi	s0,sp,16
  int n = 0;
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000269c:	0000f797          	auipc	a5,0xf
    800026a0:	6cc78793          	addi	a5,a5,1740 # 80011d68 <proc>
  int n = 0;
    800026a4:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; p++)
    800026a6:	00015697          	auipc	a3,0x15
    800026aa:	2c268693          	addi	a3,a3,706 # 80017968 <tickslock>
    800026ae:	a029                	j	800026b8 <getnproc+0x22>
    800026b0:	17078793          	addi	a5,a5,368
    800026b4:	00d78663          	beq	a5,a3,800026c0 <getnproc+0x2a>
    if (p->state != UNUSED)
    800026b8:	4f98                	lw	a4,24(a5)
    800026ba:	db7d                	beqz	a4,800026b0 <getnproc+0x1a>
      ++n;
    800026bc:	2505                	addiw	a0,a0,1
    800026be:	bfcd                	j	800026b0 <getnproc+0x1a>
  return n;
    800026c0:	6422                	ld	s0,8(sp)
    800026c2:	0141                	addi	sp,sp,16
    800026c4:	8082                	ret

00000000800026c6 <swtch>:
    800026c6:	00153023          	sd	ra,0(a0)
    800026ca:	00253423          	sd	sp,8(a0)
    800026ce:	e900                	sd	s0,16(a0)
    800026d0:	ed04                	sd	s1,24(a0)
    800026d2:	03253023          	sd	s2,32(a0)
    800026d6:	03353423          	sd	s3,40(a0)
    800026da:	03453823          	sd	s4,48(a0)
    800026de:	03553c23          	sd	s5,56(a0)
    800026e2:	05653023          	sd	s6,64(a0)
    800026e6:	05753423          	sd	s7,72(a0)
    800026ea:	05853823          	sd	s8,80(a0)
    800026ee:	05953c23          	sd	s9,88(a0)
    800026f2:	07a53023          	sd	s10,96(a0)
    800026f6:	07b53423          	sd	s11,104(a0)
    800026fa:	0005b083          	ld	ra,0(a1)
    800026fe:	0085b103          	ld	sp,8(a1)
    80002702:	6980                	ld	s0,16(a1)
    80002704:	6d84                	ld	s1,24(a1)
    80002706:	0205b903          	ld	s2,32(a1)
    8000270a:	0285b983          	ld	s3,40(a1)
    8000270e:	0305ba03          	ld	s4,48(a1)
    80002712:	0385ba83          	ld	s5,56(a1)
    80002716:	0405bb03          	ld	s6,64(a1)
    8000271a:	0485bb83          	ld	s7,72(a1)
    8000271e:	0505bc03          	ld	s8,80(a1)
    80002722:	0585bc83          	ld	s9,88(a1)
    80002726:	0605bd03          	ld	s10,96(a1)
    8000272a:	0685bd83          	ld	s11,104(a1)
    8000272e:	8082                	ret

0000000080002730 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002730:	1141                	addi	sp,sp,-16
    80002732:	e406                	sd	ra,8(sp)
    80002734:	e022                	sd	s0,0(sp)
    80002736:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002738:	00006597          	auipc	a1,0x6
    8000273c:	b9858593          	addi	a1,a1,-1128 # 800082d0 <states.1726+0x108>
    80002740:	00015517          	auipc	a0,0x15
    80002744:	22850513          	addi	a0,a0,552 # 80017968 <tickslock>
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	4d4080e7          	jalr	1236(ra) # 80000c1c <initlock>
}
    80002750:	60a2                	ld	ra,8(sp)
    80002752:	6402                	ld	s0,0(sp)
    80002754:	0141                	addi	sp,sp,16
    80002756:	8082                	ret

0000000080002758 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002758:	1141                	addi	sp,sp,-16
    8000275a:	e422                	sd	s0,8(sp)
    8000275c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000275e:	00003797          	auipc	a5,0x3
    80002762:	69278793          	addi	a5,a5,1682 # 80005df0 <kernelvec>
    80002766:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000276a:	6422                	ld	s0,8(sp)
    8000276c:	0141                	addi	sp,sp,16
    8000276e:	8082                	ret

0000000080002770 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002770:	1141                	addi	sp,sp,-16
    80002772:	e406                	sd	ra,8(sp)
    80002774:	e022                	sd	s0,0(sp)
    80002776:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002778:	fffff097          	auipc	ra,0xfffff
    8000277c:	342080e7          	jalr	834(ra) # 80001aba <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002780:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002784:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002786:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000278a:	00005617          	auipc	a2,0x5
    8000278e:	87660613          	addi	a2,a2,-1930 # 80007000 <_trampoline>
    80002792:	00005697          	auipc	a3,0x5
    80002796:	86e68693          	addi	a3,a3,-1938 # 80007000 <_trampoline>
    8000279a:	8e91                	sub	a3,a3,a2
    8000279c:	040007b7          	lui	a5,0x4000
    800027a0:	17fd                	addi	a5,a5,-1
    800027a2:	07b2                	slli	a5,a5,0xc
    800027a4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a6:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027aa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027ac:	180026f3          	csrr	a3,satp
    800027b0:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027b2:	6d38                	ld	a4,88(a0)
    800027b4:	6134                	ld	a3,64(a0)
    800027b6:	6585                	lui	a1,0x1
    800027b8:	96ae                	add	a3,a3,a1
    800027ba:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027bc:	6d38                	ld	a4,88(a0)
    800027be:	00000697          	auipc	a3,0x0
    800027c2:	13868693          	addi	a3,a3,312 # 800028f6 <usertrap>
    800027c6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027c8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027ca:	8692                	mv	a3,tp
    800027cc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ce:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027d2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800027d6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027da:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800027de:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800027e0:	6f18                	ld	a4,24(a4)
    800027e2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027e6:	692c                	ld	a1,80(a0)
    800027e8:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800027ea:	00005717          	auipc	a4,0x5
    800027ee:	8a670713          	addi	a4,a4,-1882 # 80007090 <userret>
    800027f2:	8f11                	sub	a4,a4,a2
    800027f4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800027f6:	577d                	li	a4,-1
    800027f8:	177e                	slli	a4,a4,0x3f
    800027fa:	8dd9                	or	a1,a1,a4
    800027fc:	02000537          	lui	a0,0x2000
    80002800:	157d                	addi	a0,a0,-1
    80002802:	0536                	slli	a0,a0,0xd
    80002804:	9782                	jalr	a5
}
    80002806:	60a2                	ld	ra,8(sp)
    80002808:	6402                	ld	s0,0(sp)
    8000280a:	0141                	addi	sp,sp,16
    8000280c:	8082                	ret

000000008000280e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000280e:	1101                	addi	sp,sp,-32
    80002810:	ec06                	sd	ra,24(sp)
    80002812:	e822                	sd	s0,16(sp)
    80002814:	e426                	sd	s1,8(sp)
    80002816:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002818:	00015497          	auipc	s1,0x15
    8000281c:	15048493          	addi	s1,s1,336 # 80017968 <tickslock>
    80002820:	8526                	mv	a0,s1
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	48a080e7          	jalr	1162(ra) # 80000cac <acquire>
  ticks++;
    8000282a:	00006517          	auipc	a0,0x6
    8000282e:	7f650513          	addi	a0,a0,2038 # 80009020 <ticks>
    80002832:	411c                	lw	a5,0(a0)
    80002834:	2785                	addiw	a5,a5,1
    80002836:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	c26080e7          	jalr	-986(ra) # 8000245e <wakeup>
  release(&tickslock);
    80002840:	8526                	mv	a0,s1
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	51e080e7          	jalr	1310(ra) # 80000d60 <release>
}
    8000284a:	60e2                	ld	ra,24(sp)
    8000284c:	6442                	ld	s0,16(sp)
    8000284e:	64a2                	ld	s1,8(sp)
    80002850:	6105                	addi	sp,sp,32
    80002852:	8082                	ret

0000000080002854 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002854:	1101                	addi	sp,sp,-32
    80002856:	ec06                	sd	ra,24(sp)
    80002858:	e822                	sd	s0,16(sp)
    8000285a:	e426                	sd	s1,8(sp)
    8000285c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000285e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002862:	00074d63          	bltz	a4,8000287c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002866:	57fd                	li	a5,-1
    80002868:	17fe                	slli	a5,a5,0x3f
    8000286a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000286c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000286e:	06f70363          	beq	a4,a5,800028d4 <devintr+0x80>
  }
}
    80002872:	60e2                	ld	ra,24(sp)
    80002874:	6442                	ld	s0,16(sp)
    80002876:	64a2                	ld	s1,8(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret
     (scause & 0xff) == 9){
    8000287c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002880:	46a5                	li	a3,9
    80002882:	fed792e3          	bne	a5,a3,80002866 <devintr+0x12>
    int irq = plic_claim();
    80002886:	00003097          	auipc	ra,0x3
    8000288a:	672080e7          	jalr	1650(ra) # 80005ef8 <plic_claim>
    8000288e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002890:	47a9                	li	a5,10
    80002892:	02f50763          	beq	a0,a5,800028c0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002896:	4785                	li	a5,1
    80002898:	02f50963          	beq	a0,a5,800028ca <devintr+0x76>
    return 1;
    8000289c:	4505                	li	a0,1
    } else if(irq){
    8000289e:	d8f1                	beqz	s1,80002872 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028a0:	85a6                	mv	a1,s1
    800028a2:	00006517          	auipc	a0,0x6
    800028a6:	a3650513          	addi	a0,a0,-1482 # 800082d8 <states.1726+0x110>
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	d14080e7          	jalr	-748(ra) # 800005be <printf>
      plic_complete(irq);
    800028b2:	8526                	mv	a0,s1
    800028b4:	00003097          	auipc	ra,0x3
    800028b8:	668080e7          	jalr	1640(ra) # 80005f1c <plic_complete>
    return 1;
    800028bc:	4505                	li	a0,1
    800028be:	bf55                	j	80002872 <devintr+0x1e>
      uartintr();
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	162080e7          	jalr	354(ra) # 80000a22 <uartintr>
    800028c8:	b7ed                	j	800028b2 <devintr+0x5e>
      virtio_disk_intr();
    800028ca:	00004097          	auipc	ra,0x4
    800028ce:	afe080e7          	jalr	-1282(ra) # 800063c8 <virtio_disk_intr>
    800028d2:	b7c5                	j	800028b2 <devintr+0x5e>
    if(cpuid() == 0){
    800028d4:	fffff097          	auipc	ra,0xfffff
    800028d8:	1ba080e7          	jalr	442(ra) # 80001a8e <cpuid>
    800028dc:	c901                	beqz	a0,800028ec <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800028de:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800028e2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800028e4:	14479073          	csrw	sip,a5
    return 2;
    800028e8:	4509                	li	a0,2
    800028ea:	b761                	j	80002872 <devintr+0x1e>
      clockintr();
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	f22080e7          	jalr	-222(ra) # 8000280e <clockintr>
    800028f4:	b7ed                	j	800028de <devintr+0x8a>

00000000800028f6 <usertrap>:
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	e04a                	sd	s2,0(sp)
    80002900:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002906:	1007f793          	andi	a5,a5,256
    8000290a:	e3ad                	bnez	a5,8000296c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000290c:	00003797          	auipc	a5,0x3
    80002910:	4e478793          	addi	a5,a5,1252 # 80005df0 <kernelvec>
    80002914:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002918:	fffff097          	auipc	ra,0xfffff
    8000291c:	1a2080e7          	jalr	418(ra) # 80001aba <myproc>
    80002920:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002922:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002924:	14102773          	csrr	a4,sepc
    80002928:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000292a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000292e:	47a1                	li	a5,8
    80002930:	04f71c63          	bne	a4,a5,80002988 <usertrap+0x92>
    if(p->killed)
    80002934:	591c                	lw	a5,48(a0)
    80002936:	e3b9                	bnez	a5,8000297c <usertrap+0x86>
    p->trapframe->epc += 4;
    80002938:	6cb8                	ld	a4,88(s1)
    8000293a:	6f1c                	ld	a5,24(a4)
    8000293c:	0791                	addi	a5,a5,4
    8000293e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002940:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002944:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002948:	10079073          	csrw	sstatus,a5
    syscall();
    8000294c:	00000097          	auipc	ra,0x0
    80002950:	2e6080e7          	jalr	742(ra) # 80002c32 <syscall>
  if(p->killed)
    80002954:	589c                	lw	a5,48(s1)
    80002956:	ebc1                	bnez	a5,800029e6 <usertrap+0xf0>
  usertrapret();
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	e18080e7          	jalr	-488(ra) # 80002770 <usertrapret>
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	64a2                	ld	s1,8(sp)
    80002966:	6902                	ld	s2,0(sp)
    80002968:	6105                	addi	sp,sp,32
    8000296a:	8082                	ret
    panic("usertrap: not from user mode");
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	98c50513          	addi	a0,a0,-1652 # 800082f8 <states.1726+0x130>
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	c00080e7          	jalr	-1024(ra) # 80000574 <panic>
      exit(-1);
    8000297c:	557d                	li	a0,-1
    8000297e:	00000097          	auipc	ra,0x0
    80002982:	812080e7          	jalr	-2030(ra) # 80002190 <exit>
    80002986:	bf4d                	j	80002938 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002988:	00000097          	auipc	ra,0x0
    8000298c:	ecc080e7          	jalr	-308(ra) # 80002854 <devintr>
    80002990:	892a                	mv	s2,a0
    80002992:	c501                	beqz	a0,8000299a <usertrap+0xa4>
  if(p->killed)
    80002994:	589c                	lw	a5,48(s1)
    80002996:	c3a1                	beqz	a5,800029d6 <usertrap+0xe0>
    80002998:	a815                	j	800029cc <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000299a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000299e:	5c90                	lw	a2,56(s1)
    800029a0:	00006517          	auipc	a0,0x6
    800029a4:	97850513          	addi	a0,a0,-1672 # 80008318 <states.1726+0x150>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	c16080e7          	jalr	-1002(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029b4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029b8:	00006517          	auipc	a0,0x6
    800029bc:	99050513          	addi	a0,a0,-1648 # 80008348 <states.1726+0x180>
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	bfe080e7          	jalr	-1026(ra) # 800005be <printf>
    p->killed = 1;
    800029c8:	4785                	li	a5,1
    800029ca:	d89c                	sw	a5,48(s1)
    exit(-1);
    800029cc:	557d                	li	a0,-1
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	7c2080e7          	jalr	1986(ra) # 80002190 <exit>
  if(which_dev == 2)
    800029d6:	4789                	li	a5,2
    800029d8:	f8f910e3          	bne	s2,a5,80002958 <usertrap+0x62>
    yield();
    800029dc:	00000097          	auipc	ra,0x0
    800029e0:	8c0080e7          	jalr	-1856(ra) # 8000229c <yield>
    800029e4:	bf95                	j	80002958 <usertrap+0x62>
  int which_dev = 0;
    800029e6:	4901                	li	s2,0
    800029e8:	b7d5                	j	800029cc <usertrap+0xd6>

00000000800029ea <kerneltrap>:
{
    800029ea:	7179                	addi	sp,sp,-48
    800029ec:	f406                	sd	ra,40(sp)
    800029ee:	f022                	sd	s0,32(sp)
    800029f0:	ec26                	sd	s1,24(sp)
    800029f2:	e84a                	sd	s2,16(sp)
    800029f4:	e44e                	sd	s3,8(sp)
    800029f6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029f8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029fc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a00:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a04:	1004f793          	andi	a5,s1,256
    80002a08:	cb85                	beqz	a5,80002a38 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a0a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a0e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a10:	ef85                	bnez	a5,80002a48 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a12:	00000097          	auipc	ra,0x0
    80002a16:	e42080e7          	jalr	-446(ra) # 80002854 <devintr>
    80002a1a:	cd1d                	beqz	a0,80002a58 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a1c:	4789                	li	a5,2
    80002a1e:	06f50a63          	beq	a0,a5,80002a92 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a22:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a26:	10049073          	csrw	sstatus,s1
}
    80002a2a:	70a2                	ld	ra,40(sp)
    80002a2c:	7402                	ld	s0,32(sp)
    80002a2e:	64e2                	ld	s1,24(sp)
    80002a30:	6942                	ld	s2,16(sp)
    80002a32:	69a2                	ld	s3,8(sp)
    80002a34:	6145                	addi	sp,sp,48
    80002a36:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a38:	00006517          	auipc	a0,0x6
    80002a3c:	93050513          	addi	a0,a0,-1744 # 80008368 <states.1726+0x1a0>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	b34080e7          	jalr	-1228(ra) # 80000574 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a48:	00006517          	auipc	a0,0x6
    80002a4c:	94850513          	addi	a0,a0,-1720 # 80008390 <states.1726+0x1c8>
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	b24080e7          	jalr	-1244(ra) # 80000574 <panic>
    printf("scause %p\n", scause);
    80002a58:	85ce                	mv	a1,s3
    80002a5a:	00006517          	auipc	a0,0x6
    80002a5e:	95650513          	addi	a0,a0,-1706 # 800083b0 <states.1726+0x1e8>
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	b5c080e7          	jalr	-1188(ra) # 800005be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a6a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a6e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a72:	00006517          	auipc	a0,0x6
    80002a76:	94e50513          	addi	a0,a0,-1714 # 800083c0 <states.1726+0x1f8>
    80002a7a:	ffffe097          	auipc	ra,0xffffe
    80002a7e:	b44080e7          	jalr	-1212(ra) # 800005be <printf>
    panic("kerneltrap");
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	95650513          	addi	a0,a0,-1706 # 800083d8 <states.1726+0x210>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	aea080e7          	jalr	-1302(ra) # 80000574 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	028080e7          	jalr	40(ra) # 80001aba <myproc>
    80002a9a:	d541                	beqz	a0,80002a22 <kerneltrap+0x38>
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	01e080e7          	jalr	30(ra) # 80001aba <myproc>
    80002aa4:	4d18                	lw	a4,24(a0)
    80002aa6:	478d                	li	a5,3
    80002aa8:	f6f71de3          	bne	a4,a5,80002a22 <kerneltrap+0x38>
    yield();
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	7f0080e7          	jalr	2032(ra) # 8000229c <yield>
    80002ab4:	b7bd                	j	80002a22 <kerneltrap+0x38>

0000000080002ab6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ab6:	1101                	addi	sp,sp,-32
    80002ab8:	ec06                	sd	ra,24(sp)
    80002aba:	e822                	sd	s0,16(sp)
    80002abc:	e426                	sd	s1,8(sp)
    80002abe:	1000                	addi	s0,sp,32
    80002ac0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ac2:	fffff097          	auipc	ra,0xfffff
    80002ac6:	ff8080e7          	jalr	-8(ra) # 80001aba <myproc>
  switch (n)
    80002aca:	4795                	li	a5,5
    80002acc:	0497e363          	bltu	a5,s1,80002b12 <argraw+0x5c>
    80002ad0:	1482                	slli	s1,s1,0x20
    80002ad2:	9081                	srli	s1,s1,0x20
    80002ad4:	048a                	slli	s1,s1,0x2
    80002ad6:	00006717          	auipc	a4,0x6
    80002ada:	91270713          	addi	a4,a4,-1774 # 800083e8 <states.1726+0x220>
    80002ade:	94ba                	add	s1,s1,a4
    80002ae0:	409c                	lw	a5,0(s1)
    80002ae2:	97ba                	add	a5,a5,a4
    80002ae4:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002ae6:	6d3c                	ld	a5,88(a0)
    80002ae8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aea:	60e2                	ld	ra,24(sp)
    80002aec:	6442                	ld	s0,16(sp)
    80002aee:	64a2                	ld	s1,8(sp)
    80002af0:	6105                	addi	sp,sp,32
    80002af2:	8082                	ret
    return p->trapframe->a1;
    80002af4:	6d3c                	ld	a5,88(a0)
    80002af6:	7fa8                	ld	a0,120(a5)
    80002af8:	bfcd                	j	80002aea <argraw+0x34>
    return p->trapframe->a2;
    80002afa:	6d3c                	ld	a5,88(a0)
    80002afc:	63c8                	ld	a0,128(a5)
    80002afe:	b7f5                	j	80002aea <argraw+0x34>
    return p->trapframe->a3;
    80002b00:	6d3c                	ld	a5,88(a0)
    80002b02:	67c8                	ld	a0,136(a5)
    80002b04:	b7dd                	j	80002aea <argraw+0x34>
    return p->trapframe->a4;
    80002b06:	6d3c                	ld	a5,88(a0)
    80002b08:	6bc8                	ld	a0,144(a5)
    80002b0a:	b7c5                	j	80002aea <argraw+0x34>
    return p->trapframe->a5;
    80002b0c:	6d3c                	ld	a5,88(a0)
    80002b0e:	6fc8                	ld	a0,152(a5)
    80002b10:	bfe9                	j	80002aea <argraw+0x34>
  panic("argraw");
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	a6e50513          	addi	a0,a0,-1426 # 80008580 <syscallname+0xc0>
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	a5a080e7          	jalr	-1446(ra) # 80000574 <panic>

0000000080002b22 <fetchaddr>:
{
    80002b22:	1101                	addi	sp,sp,-32
    80002b24:	ec06                	sd	ra,24(sp)
    80002b26:	e822                	sd	s0,16(sp)
    80002b28:	e426                	sd	s1,8(sp)
    80002b2a:	e04a                	sd	s2,0(sp)
    80002b2c:	1000                	addi	s0,sp,32
    80002b2e:	84aa                	mv	s1,a0
    80002b30:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	f88080e7          	jalr	-120(ra) # 80001aba <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz)
    80002b3a:	653c                	ld	a5,72(a0)
    80002b3c:	02f4f963          	bleu	a5,s1,80002b6e <fetchaddr+0x4c>
    80002b40:	00848713          	addi	a4,s1,8
    80002b44:	02e7e763          	bltu	a5,a4,80002b72 <fetchaddr+0x50>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b48:	46a1                	li	a3,8
    80002b4a:	8626                	mv	a2,s1
    80002b4c:	85ca                	mv	a1,s2
    80002b4e:	6928                	ld	a0,80(a0)
    80002b50:	fffff097          	auipc	ra,0xfffff
    80002b54:	cd2080e7          	jalr	-814(ra) # 80001822 <copyin>
    80002b58:	00a03533          	snez	a0,a0
    80002b5c:	40a0053b          	negw	a0,a0
    80002b60:	2501                	sext.w	a0,a0
}
    80002b62:	60e2                	ld	ra,24(sp)
    80002b64:	6442                	ld	s0,16(sp)
    80002b66:	64a2                	ld	s1,8(sp)
    80002b68:	6902                	ld	s2,0(sp)
    80002b6a:	6105                	addi	sp,sp,32
    80002b6c:	8082                	ret
    return -1;
    80002b6e:	557d                	li	a0,-1
    80002b70:	bfcd                	j	80002b62 <fetchaddr+0x40>
    80002b72:	557d                	li	a0,-1
    80002b74:	b7fd                	j	80002b62 <fetchaddr+0x40>

0000000080002b76 <fetchstr>:
{
    80002b76:	7179                	addi	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	e84a                	sd	s2,16(sp)
    80002b80:	e44e                	sd	s3,8(sp)
    80002b82:	1800                	addi	s0,sp,48
    80002b84:	892a                	mv	s2,a0
    80002b86:	84ae                	mv	s1,a1
    80002b88:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b8a:	fffff097          	auipc	ra,0xfffff
    80002b8e:	f30080e7          	jalr	-208(ra) # 80001aba <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b92:	86ce                	mv	a3,s3
    80002b94:	864a                	mv	a2,s2
    80002b96:	85a6                	mv	a1,s1
    80002b98:	6928                	ld	a0,80(a0)
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	d16080e7          	jalr	-746(ra) # 800018b0 <copyinstr>
  if (err < 0)
    80002ba2:	00054763          	bltz	a0,80002bb0 <fetchstr+0x3a>
  return strlen(buf);
    80002ba6:	8526                	mv	a0,s1
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	3aa080e7          	jalr	938(ra) # 80000f52 <strlen>
}
    80002bb0:	70a2                	ld	ra,40(sp)
    80002bb2:	7402                	ld	s0,32(sp)
    80002bb4:	64e2                	ld	s1,24(sp)
    80002bb6:	6942                	ld	s2,16(sp)
    80002bb8:	69a2                	ld	s3,8(sp)
    80002bba:	6145                	addi	sp,sp,48
    80002bbc:	8082                	ret

0000000080002bbe <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	e426                	sd	s1,8(sp)
    80002bc6:	1000                	addi	s0,sp,32
    80002bc8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	eec080e7          	jalr	-276(ra) # 80002ab6 <argraw>
    80002bd2:	c088                	sw	a0,0(s1)
  return 0;
}
    80002bd4:	4501                	li	a0,0
    80002bd6:	60e2                	ld	ra,24(sp)
    80002bd8:	6442                	ld	s0,16(sp)
    80002bda:	64a2                	ld	s1,8(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002be0:	1101                	addi	sp,sp,-32
    80002be2:	ec06                	sd	ra,24(sp)
    80002be4:	e822                	sd	s0,16(sp)
    80002be6:	e426                	sd	s1,8(sp)
    80002be8:	1000                	addi	s0,sp,32
    80002bea:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bec:	00000097          	auipc	ra,0x0
    80002bf0:	eca080e7          	jalr	-310(ra) # 80002ab6 <argraw>
    80002bf4:	e088                	sd	a0,0(s1)
  return 0;
}
    80002bf6:	4501                	li	a0,0
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6105                	addi	sp,sp,32
    80002c00:	8082                	ret

0000000080002c02 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	e426                	sd	s1,8(sp)
    80002c0a:	e04a                	sd	s2,0(sp)
    80002c0c:	1000                	addi	s0,sp,32
    80002c0e:	84ae                	mv	s1,a1
    80002c10:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c12:	00000097          	auipc	ra,0x0
    80002c16:	ea4080e7          	jalr	-348(ra) # 80002ab6 <argraw>
  uint64 addr;
  if (argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c1a:	864a                	mv	a2,s2
    80002c1c:	85a6                	mv	a1,s1
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	f58080e7          	jalr	-168(ra) # 80002b76 <fetchstr>
}
    80002c26:	60e2                	ld	ra,24(sp)
    80002c28:	6442                	ld	s0,16(sp)
    80002c2a:	64a2                	ld	s1,8(sp)
    80002c2c:	6902                	ld	s2,0(sp)
    80002c2e:	6105                	addi	sp,sp,32
    80002c30:	8082                	ret

0000000080002c32 <syscall>:
    [SYS_close] "close",
    [SYS_trace] "trace",
    [SYS_sysinfo] "sysinfo"};

void syscall(void)
{
    80002c32:	7179                	addi	sp,sp,-48
    80002c34:	f406                	sd	ra,40(sp)
    80002c36:	f022                	sd	s0,32(sp)
    80002c38:	ec26                	sd	s1,24(sp)
    80002c3a:	e84a                	sd	s2,16(sp)
    80002c3c:	e44e                	sd	s3,8(sp)
    80002c3e:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	e7a080e7          	jalr	-390(ra) # 80001aba <myproc>
    80002c48:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c4a:	05853983          	ld	s3,88(a0)
    80002c4e:	0a89b783          	ld	a5,168(s3)
    80002c52:	0007891b          	sext.w	s2,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002c56:	37fd                	addiw	a5,a5,-1
    80002c58:	4759                	li	a4,22
    80002c5a:	04f76863          	bltu	a4,a5,80002caa <syscall+0x78>
    80002c5e:	00391713          	slli	a4,s2,0x3
    80002c62:	00005797          	auipc	a5,0x5
    80002c66:	79e78793          	addi	a5,a5,1950 # 80008400 <syscalls>
    80002c6a:	97ba                	add	a5,a5,a4
    80002c6c:	639c                	ld	a5,0(a5)
    80002c6e:	cf95                	beqz	a5,80002caa <syscall+0x78>
  {
    p->trapframe->a0 = syscalls[num]();
    80002c70:	9782                	jalr	a5
    80002c72:	06a9b823          	sd	a0,112(s3)

    //printf("%d\n%d\n", num, p->sysmask);
    if (((1 << num) & p->sysmask))
    80002c76:	1684a783          	lw	a5,360(s1)
    80002c7a:	4127d7bb          	sraw	a5,a5,s2
    80002c7e:	8b85                	andi	a5,a5,1
    80002c80:	c7a1                	beqz	a5,80002cc8 <syscall+0x96>
    {
      printf("%d: syscall %s -> %d\n", p->pid, syscallname[num], p->trapframe->a0);
    80002c82:	6cb8                	ld	a4,88(s1)
    80002c84:	090e                	slli	s2,s2,0x3
    80002c86:	00005797          	auipc	a5,0x5
    80002c8a:	77a78793          	addi	a5,a5,1914 # 80008400 <syscalls>
    80002c8e:	993e                	add	s2,s2,a5
    80002c90:	7b34                	ld	a3,112(a4)
    80002c92:	0c093603          	ld	a2,192(s2)
    80002c96:	5c8c                	lw	a1,56(s1)
    80002c98:	00006517          	auipc	a0,0x6
    80002c9c:	8f050513          	addi	a0,a0,-1808 # 80008588 <syscallname+0xc8>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	91e080e7          	jalr	-1762(ra) # 800005be <printf>
    80002ca8:	a005                	j	80002cc8 <syscall+0x96>
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002caa:	86ca                	mv	a3,s2
    80002cac:	15848613          	addi	a2,s1,344
    80002cb0:	5c8c                	lw	a1,56(s1)
    80002cb2:	00006517          	auipc	a0,0x6
    80002cb6:	8ee50513          	addi	a0,a0,-1810 # 800085a0 <syscallname+0xe0>
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	904080e7          	jalr	-1788(ra) # 800005be <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cc2:	6cbc                	ld	a5,88(s1)
    80002cc4:	577d                	li	a4,-1
    80002cc6:	fbb8                	sd	a4,112(a5)
  }
}
    80002cc8:	70a2                	ld	ra,40(sp)
    80002cca:	7402                	ld	s0,32(sp)
    80002ccc:	64e2                	ld	s1,24(sp)
    80002cce:	6942                	ld	s2,16(sp)
    80002cd0:	69a2                	ld	s3,8(sp)
    80002cd2:	6145                	addi	sp,sp,48
    80002cd4:	8082                	ret

0000000080002cd6 <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	1000                	addi	s0,sp,32
  int n;
  if (argint(0, &n) < 0)
    80002cde:	fec40593          	addi	a1,s0,-20
    80002ce2:	4501                	li	a0,0
    80002ce4:	00000097          	auipc	ra,0x0
    80002ce8:	eda080e7          	jalr	-294(ra) # 80002bbe <argint>
    return -1;
    80002cec:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002cee:	00054963          	bltz	a0,80002d00 <sys_exit+0x2a>
  exit(n);
    80002cf2:	fec42503          	lw	a0,-20(s0)
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	49a080e7          	jalr	1178(ra) # 80002190 <exit>
  return 0; // not reached
    80002cfe:	4781                	li	a5,0
}
    80002d00:	853e                	mv	a0,a5
    80002d02:	60e2                	ld	ra,24(sp)
    80002d04:	6442                	ld	s0,16(sp)
    80002d06:	6105                	addi	sp,sp,32
    80002d08:	8082                	ret

0000000080002d0a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d0a:	1141                	addi	sp,sp,-16
    80002d0c:	e406                	sd	ra,8(sp)
    80002d0e:	e022                	sd	s0,0(sp)
    80002d10:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	da8080e7          	jalr	-600(ra) # 80001aba <myproc>
}
    80002d1a:	5d08                	lw	a0,56(a0)
    80002d1c:	60a2                	ld	ra,8(sp)
    80002d1e:	6402                	ld	s0,0(sp)
    80002d20:	0141                	addi	sp,sp,16
    80002d22:	8082                	ret

0000000080002d24 <sys_fork>:

uint64
sys_fork(void)
{
    80002d24:	1141                	addi	sp,sp,-16
    80002d26:	e406                	sd	ra,8(sp)
    80002d28:	e022                	sd	s0,0(sp)
    80002d2a:	0800                	addi	s0,sp,16
  return fork();
    80002d2c:	fffff097          	auipc	ra,0xfffff
    80002d30:	154080e7          	jalr	340(ra) # 80001e80 <fork>
}
    80002d34:	60a2                	ld	ra,8(sp)
    80002d36:	6402                	ld	s0,0(sp)
    80002d38:	0141                	addi	sp,sp,16
    80002d3a:	8082                	ret

0000000080002d3c <sys_wait>:

uint64
sys_wait(void)
{
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80002d44:	fe840593          	addi	a1,s0,-24
    80002d48:	4501                	li	a0,0
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	e96080e7          	jalr	-362(ra) # 80002be0 <argaddr>
    return -1;
    80002d52:	57fd                	li	a5,-1
  if (argaddr(0, &p) < 0)
    80002d54:	00054963          	bltz	a0,80002d66 <sys_wait+0x2a>
  return wait(p);
    80002d58:	fe843503          	ld	a0,-24(s0)
    80002d5c:	fffff097          	auipc	ra,0xfffff
    80002d60:	5fa080e7          	jalr	1530(ra) # 80002356 <wait>
    80002d64:	87aa                	mv	a5,a0
}
    80002d66:	853e                	mv	a0,a5
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	6105                	addi	sp,sp,32
    80002d6e:	8082                	ret

0000000080002d70 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d70:	7179                	addi	sp,sp,-48
    80002d72:	f406                	sd	ra,40(sp)
    80002d74:	f022                	sd	s0,32(sp)
    80002d76:	ec26                	sd	s1,24(sp)
    80002d78:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if (argint(0, &n) < 0)
    80002d7a:	fdc40593          	addi	a1,s0,-36
    80002d7e:	4501                	li	a0,0
    80002d80:	00000097          	auipc	ra,0x0
    80002d84:	e3e080e7          	jalr	-450(ra) # 80002bbe <argint>
    return -1;
    80002d88:	54fd                	li	s1,-1
  if (argint(0, &n) < 0)
    80002d8a:	00054f63          	bltz	a0,80002da8 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	d2c080e7          	jalr	-724(ra) # 80001aba <myproc>
    80002d96:	4524                	lw	s1,72(a0)
  if (growproc(n) < 0)
    80002d98:	fdc42503          	lw	a0,-36(s0)
    80002d9c:	fffff097          	auipc	ra,0xfffff
    80002da0:	06c080e7          	jalr	108(ra) # 80001e08 <growproc>
    80002da4:	00054863          	bltz	a0,80002db4 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002da8:	8526                	mv	a0,s1
    80002daa:	70a2                	ld	ra,40(sp)
    80002dac:	7402                	ld	s0,32(sp)
    80002dae:	64e2                	ld	s1,24(sp)
    80002db0:	6145                	addi	sp,sp,48
    80002db2:	8082                	ret
    return -1;
    80002db4:	54fd                	li	s1,-1
    80002db6:	bfcd                	j	80002da8 <sys_sbrk+0x38>

0000000080002db8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002db8:	7139                	addi	sp,sp,-64
    80002dba:	fc06                	sd	ra,56(sp)
    80002dbc:	f822                	sd	s0,48(sp)
    80002dbe:	f426                	sd	s1,40(sp)
    80002dc0:	f04a                	sd	s2,32(sp)
    80002dc2:	ec4e                	sd	s3,24(sp)
    80002dc4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if (argint(0, &n) < 0)
    80002dc6:	fcc40593          	addi	a1,s0,-52
    80002dca:	4501                	li	a0,0
    80002dcc:	00000097          	auipc	ra,0x0
    80002dd0:	df2080e7          	jalr	-526(ra) # 80002bbe <argint>
    return -1;
    80002dd4:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002dd6:	06054763          	bltz	a0,80002e44 <sys_sleep+0x8c>
  acquire(&tickslock);
    80002dda:	00015517          	auipc	a0,0x15
    80002dde:	b8e50513          	addi	a0,a0,-1138 # 80017968 <tickslock>
    80002de2:	ffffe097          	auipc	ra,0xffffe
    80002de6:	eca080e7          	jalr	-310(ra) # 80000cac <acquire>
  ticks0 = ticks;
    80002dea:	00006797          	auipc	a5,0x6
    80002dee:	23678793          	addi	a5,a5,566 # 80009020 <ticks>
    80002df2:	0007a903          	lw	s2,0(a5)
  while (ticks - ticks0 < n)
    80002df6:	fcc42783          	lw	a5,-52(s0)
    80002dfa:	cf85                	beqz	a5,80002e32 <sys_sleep+0x7a>
    if (myproc()->killed)
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dfc:	00015997          	auipc	s3,0x15
    80002e00:	b6c98993          	addi	s3,s3,-1172 # 80017968 <tickslock>
    80002e04:	00006497          	auipc	s1,0x6
    80002e08:	21c48493          	addi	s1,s1,540 # 80009020 <ticks>
    if (myproc()->killed)
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	cae080e7          	jalr	-850(ra) # 80001aba <myproc>
    80002e14:	591c                	lw	a5,48(a0)
    80002e16:	ef9d                	bnez	a5,80002e54 <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002e18:	85ce                	mv	a1,s3
    80002e1a:	8526                	mv	a0,s1
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	4bc080e7          	jalr	1212(ra) # 800022d8 <sleep>
  while (ticks - ticks0 < n)
    80002e24:	409c                	lw	a5,0(s1)
    80002e26:	412787bb          	subw	a5,a5,s2
    80002e2a:	fcc42703          	lw	a4,-52(s0)
    80002e2e:	fce7efe3          	bltu	a5,a4,80002e0c <sys_sleep+0x54>
  }
  release(&tickslock);
    80002e32:	00015517          	auipc	a0,0x15
    80002e36:	b3650513          	addi	a0,a0,-1226 # 80017968 <tickslock>
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	f26080e7          	jalr	-218(ra) # 80000d60 <release>
  return 0;
    80002e42:	4781                	li	a5,0
}
    80002e44:	853e                	mv	a0,a5
    80002e46:	70e2                	ld	ra,56(sp)
    80002e48:	7442                	ld	s0,48(sp)
    80002e4a:	74a2                	ld	s1,40(sp)
    80002e4c:	7902                	ld	s2,32(sp)
    80002e4e:	69e2                	ld	s3,24(sp)
    80002e50:	6121                	addi	sp,sp,64
    80002e52:	8082                	ret
      release(&tickslock);
    80002e54:	00015517          	auipc	a0,0x15
    80002e58:	b1450513          	addi	a0,a0,-1260 # 80017968 <tickslock>
    80002e5c:	ffffe097          	auipc	ra,0xffffe
    80002e60:	f04080e7          	jalr	-252(ra) # 80000d60 <release>
      return -1;
    80002e64:	57fd                	li	a5,-1
    80002e66:	bff9                	j	80002e44 <sys_sleep+0x8c>

0000000080002e68 <sys_kill>:

uint64
sys_kill(void)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	1000                	addi	s0,sp,32
  int pid;

  if (argint(0, &pid) < 0)
    80002e70:	fec40593          	addi	a1,s0,-20
    80002e74:	4501                	li	a0,0
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	d48080e7          	jalr	-696(ra) # 80002bbe <argint>
    return -1;
    80002e7e:	57fd                	li	a5,-1
  if (argint(0, &pid) < 0)
    80002e80:	00054963          	bltz	a0,80002e92 <sys_kill+0x2a>
  return kill(pid);
    80002e84:	fec42503          	lw	a0,-20(s0)
    80002e88:	fffff097          	auipc	ra,0xfffff
    80002e8c:	640080e7          	jalr	1600(ra) # 800024c8 <kill>
    80002e90:	87aa                	mv	a5,a0
}
    80002e92:	853e                	mv	a0,a5
    80002e94:	60e2                	ld	ra,24(sp)
    80002e96:	6442                	ld	s0,16(sp)
    80002e98:	6105                	addi	sp,sp,32
    80002e9a:	8082                	ret

0000000080002e9c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e9c:	1101                	addi	sp,sp,-32
    80002e9e:	ec06                	sd	ra,24(sp)
    80002ea0:	e822                	sd	s0,16(sp)
    80002ea2:	e426                	sd	s1,8(sp)
    80002ea4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ea6:	00015517          	auipc	a0,0x15
    80002eaa:	ac250513          	addi	a0,a0,-1342 # 80017968 <tickslock>
    80002eae:	ffffe097          	auipc	ra,0xffffe
    80002eb2:	dfe080e7          	jalr	-514(ra) # 80000cac <acquire>
  xticks = ticks;
    80002eb6:	00006797          	auipc	a5,0x6
    80002eba:	16a78793          	addi	a5,a5,362 # 80009020 <ticks>
    80002ebe:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002ec0:	00015517          	auipc	a0,0x15
    80002ec4:	aa850513          	addi	a0,a0,-1368 # 80017968 <tickslock>
    80002ec8:	ffffe097          	auipc	ra,0xffffe
    80002ecc:	e98080e7          	jalr	-360(ra) # 80000d60 <release>
  return xticks;
}
    80002ed0:	02049513          	slli	a0,s1,0x20
    80002ed4:	9101                	srli	a0,a0,0x20
    80002ed6:	60e2                	ld	ra,24(sp)
    80002ed8:	6442                	ld	s0,16(sp)
    80002eda:	64a2                	ld	s1,8(sp)
    80002edc:	6105                	addi	sp,sp,32
    80002ede:	8082                	ret

0000000080002ee0 <sys_trace>:

uint64
sys_trace(void)
{
    80002ee0:	1101                	addi	sp,sp,-32
    80002ee2:	ec06                	sd	ra,24(sp)
    80002ee4:	e822                	sd	s0,16(sp)
    80002ee6:	1000                	addi	s0,sp,32
  int sysid;
  if (argint(0, &sysid) < 0)
    80002ee8:	fec40593          	addi	a1,s0,-20
    80002eec:	4501                	li	a0,0
    80002eee:	00000097          	auipc	ra,0x0
    80002ef2:	cd0080e7          	jalr	-816(ra) # 80002bbe <argint>
    return -1;
    80002ef6:	57fd                	li	a5,-1
  if (argint(0, &sysid) < 0)
    80002ef8:	02054363          	bltz	a0,80002f1e <sys_trace+0x3e>
  struct proc *p = myproc();
    80002efc:	fffff097          	auipc	ra,0xfffff
    80002f00:	bbe080e7          	jalr	-1090(ra) # 80001aba <myproc>
  p->sysmask = sysid;
    80002f04:	fec42583          	lw	a1,-20(s0)
    80002f08:	16b52423          	sw	a1,360(a0)
  printf("[%d]\n", sysid);
    80002f0c:	00005517          	auipc	a0,0x5
    80002f10:	76450513          	addi	a0,a0,1892 # 80008670 <syscallname+0x1b0>
    80002f14:	ffffd097          	auipc	ra,0xffffd
    80002f18:	6aa080e7          	jalr	1706(ra) # 800005be <printf>
  return 0;
    80002f1c:	4781                	li	a5,0
}
    80002f1e:	853e                	mv	a0,a5
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret

0000000080002f28 <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80002f28:	7139                	addi	sp,sp,-64
    80002f2a:	fc06                	sd	ra,56(sp)
    80002f2c:	f822                	sd	s0,48(sp)
    80002f2e:	f426                	sd	s1,40(sp)
    80002f30:	0080                	addi	s0,sp,64
  uint64 addr; // user pointer to struct sysinfo
  if (argaddr(0, &addr) < 0)
    80002f32:	fd840593          	addi	a1,s0,-40
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	ca8080e7          	jalr	-856(ra) # 80002be0 <argaddr>
  {
    return -1;
    80002f40:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0)
    80002f42:	04054163          	bltz	a0,80002f84 <sys_sysinfo+0x5c>
  }

  struct proc *p = myproc();
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	b74080e7          	jalr	-1164(ra) # 80001aba <myproc>
    80002f4e:	84aa                	mv	s1,a0
  struct sysinfo info;

  info.freemem = getfreemem();
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	c82080e7          	jalr	-894(ra) # 80000bd2 <getfreemem>
    80002f58:	fca43423          	sd	a0,-56(s0)
  info.nproc = getnproc();
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	73a080e7          	jalr	1850(ra) # 80002696 <getnproc>
    80002f64:	fca43823          	sd	a0,-48(s0)

  if (copyout(p->pagetable, addr, (char *)&info, sizeof(info)))
    80002f68:	46c1                	li	a3,16
    80002f6a:	fc840613          	addi	a2,s0,-56
    80002f6e:	fd843583          	ld	a1,-40(s0)
    80002f72:	68a8                	ld	a0,80(s1)
    80002f74:	fffff097          	auipc	ra,0xfffff
    80002f78:	822080e7          	jalr	-2014(ra) # 80001796 <copyout>
    80002f7c:	00a03533          	snez	a0,a0
    80002f80:	40a007b3          	neg	a5,a0
    return -1;
  return 0;
    80002f84:	853e                	mv	a0,a5
    80002f86:	70e2                	ld	ra,56(sp)
    80002f88:	7442                	ld	s0,48(sp)
    80002f8a:	74a2                	ld	s1,40(sp)
    80002f8c:	6121                	addi	sp,sp,64
    80002f8e:	8082                	ret

0000000080002f90 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	e84a                	sd	s2,16(sp)
    80002f9a:	e44e                	sd	s3,8(sp)
    80002f9c:	e052                	sd	s4,0(sp)
    80002f9e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fa0:	00005597          	auipc	a1,0x5
    80002fa4:	6d858593          	addi	a1,a1,1752 # 80008678 <syscallname+0x1b8>
    80002fa8:	00015517          	auipc	a0,0x15
    80002fac:	9d850513          	addi	a0,a0,-1576 # 80017980 <bcache>
    80002fb0:	ffffe097          	auipc	ra,0xffffe
    80002fb4:	c6c080e7          	jalr	-916(ra) # 80000c1c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fb8:	0001d797          	auipc	a5,0x1d
    80002fbc:	9c878793          	addi	a5,a5,-1592 # 8001f980 <bcache+0x8000>
    80002fc0:	0001d717          	auipc	a4,0x1d
    80002fc4:	c2870713          	addi	a4,a4,-984 # 8001fbe8 <bcache+0x8268>
    80002fc8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fcc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fd0:	00015497          	auipc	s1,0x15
    80002fd4:	9c848493          	addi	s1,s1,-1592 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80002fd8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fda:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fdc:	00005a17          	auipc	s4,0x5
    80002fe0:	6a4a0a13          	addi	s4,s4,1700 # 80008680 <syscallname+0x1c0>
    b->next = bcache.head.next;
    80002fe4:	2b893783          	ld	a5,696(s2)
    80002fe8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fea:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fee:	85d2                	mv	a1,s4
    80002ff0:	01048513          	addi	a0,s1,16
    80002ff4:	00001097          	auipc	ra,0x1
    80002ff8:	51a080e7          	jalr	1306(ra) # 8000450e <initsleeplock>
    bcache.head.next->prev = b;
    80002ffc:	2b893783          	ld	a5,696(s2)
    80003000:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003002:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003006:	45848493          	addi	s1,s1,1112
    8000300a:	fd349de3          	bne	s1,s3,80002fe4 <binit+0x54>
  }
}
    8000300e:	70a2                	ld	ra,40(sp)
    80003010:	7402                	ld	s0,32(sp)
    80003012:	64e2                	ld	s1,24(sp)
    80003014:	6942                	ld	s2,16(sp)
    80003016:	69a2                	ld	s3,8(sp)
    80003018:	6a02                	ld	s4,0(sp)
    8000301a:	6145                	addi	sp,sp,48
    8000301c:	8082                	ret

000000008000301e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000301e:	7179                	addi	sp,sp,-48
    80003020:	f406                	sd	ra,40(sp)
    80003022:	f022                	sd	s0,32(sp)
    80003024:	ec26                	sd	s1,24(sp)
    80003026:	e84a                	sd	s2,16(sp)
    80003028:	e44e                	sd	s3,8(sp)
    8000302a:	1800                	addi	s0,sp,48
    8000302c:	89aa                	mv	s3,a0
    8000302e:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003030:	00015517          	auipc	a0,0x15
    80003034:	95050513          	addi	a0,a0,-1712 # 80017980 <bcache>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	c74080e7          	jalr	-908(ra) # 80000cac <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003040:	0001d797          	auipc	a5,0x1d
    80003044:	94078793          	addi	a5,a5,-1728 # 8001f980 <bcache+0x8000>
    80003048:	2b87b483          	ld	s1,696(a5)
    8000304c:	0001d797          	auipc	a5,0x1d
    80003050:	b9c78793          	addi	a5,a5,-1124 # 8001fbe8 <bcache+0x8268>
    80003054:	02f48f63          	beq	s1,a5,80003092 <bread+0x74>
    80003058:	873e                	mv	a4,a5
    8000305a:	a021                	j	80003062 <bread+0x44>
    8000305c:	68a4                	ld	s1,80(s1)
    8000305e:	02e48a63          	beq	s1,a4,80003092 <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    80003062:	449c                	lw	a5,8(s1)
    80003064:	ff379ce3          	bne	a5,s3,8000305c <bread+0x3e>
    80003068:	44dc                	lw	a5,12(s1)
    8000306a:	ff2799e3          	bne	a5,s2,8000305c <bread+0x3e>
      b->refcnt++;
    8000306e:	40bc                	lw	a5,64(s1)
    80003070:	2785                	addiw	a5,a5,1
    80003072:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003074:	00015517          	auipc	a0,0x15
    80003078:	90c50513          	addi	a0,a0,-1780 # 80017980 <bcache>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	ce4080e7          	jalr	-796(ra) # 80000d60 <release>
      acquiresleep(&b->lock);
    80003084:	01048513          	addi	a0,s1,16
    80003088:	00001097          	auipc	ra,0x1
    8000308c:	4c0080e7          	jalr	1216(ra) # 80004548 <acquiresleep>
      return b;
    80003090:	a8b1                	j	800030ec <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003092:	0001d797          	auipc	a5,0x1d
    80003096:	8ee78793          	addi	a5,a5,-1810 # 8001f980 <bcache+0x8000>
    8000309a:	2b07b483          	ld	s1,688(a5)
    8000309e:	0001d797          	auipc	a5,0x1d
    800030a2:	b4a78793          	addi	a5,a5,-1206 # 8001fbe8 <bcache+0x8268>
    800030a6:	04f48d63          	beq	s1,a5,80003100 <bread+0xe2>
    if(b->refcnt == 0) {
    800030aa:	40bc                	lw	a5,64(s1)
    800030ac:	cb91                	beqz	a5,800030c0 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ae:	0001d717          	auipc	a4,0x1d
    800030b2:	b3a70713          	addi	a4,a4,-1222 # 8001fbe8 <bcache+0x8268>
    800030b6:	64a4                	ld	s1,72(s1)
    800030b8:	04e48463          	beq	s1,a4,80003100 <bread+0xe2>
    if(b->refcnt == 0) {
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	ffe5                	bnez	a5,800030b6 <bread+0x98>
      b->dev = dev;
    800030c0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030c4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800030c8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030cc:	4785                	li	a5,1
    800030ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030d0:	00015517          	auipc	a0,0x15
    800030d4:	8b050513          	addi	a0,a0,-1872 # 80017980 <bcache>
    800030d8:	ffffe097          	auipc	ra,0xffffe
    800030dc:	c88080e7          	jalr	-888(ra) # 80000d60 <release>
      acquiresleep(&b->lock);
    800030e0:	01048513          	addi	a0,s1,16
    800030e4:	00001097          	auipc	ra,0x1
    800030e8:	464080e7          	jalr	1124(ra) # 80004548 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030ec:	409c                	lw	a5,0(s1)
    800030ee:	c38d                	beqz	a5,80003110 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030f0:	8526                	mv	a0,s1
    800030f2:	70a2                	ld	ra,40(sp)
    800030f4:	7402                	ld	s0,32(sp)
    800030f6:	64e2                	ld	s1,24(sp)
    800030f8:	6942                	ld	s2,16(sp)
    800030fa:	69a2                	ld	s3,8(sp)
    800030fc:	6145                	addi	sp,sp,48
    800030fe:	8082                	ret
  panic("bget: no buffers");
    80003100:	00005517          	auipc	a0,0x5
    80003104:	58850513          	addi	a0,a0,1416 # 80008688 <syscallname+0x1c8>
    80003108:	ffffd097          	auipc	ra,0xffffd
    8000310c:	46c080e7          	jalr	1132(ra) # 80000574 <panic>
    virtio_disk_rw(b, 0);
    80003110:	4581                	li	a1,0
    80003112:	8526                	mv	a0,s1
    80003114:	00003097          	auipc	ra,0x3
    80003118:	ffa080e7          	jalr	-6(ra) # 8000610e <virtio_disk_rw>
    b->valid = 1;
    8000311c:	4785                	li	a5,1
    8000311e:	c09c                	sw	a5,0(s1)
  return b;
    80003120:	bfc1                	j	800030f0 <bread+0xd2>

0000000080003122 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003122:	1101                	addi	sp,sp,-32
    80003124:	ec06                	sd	ra,24(sp)
    80003126:	e822                	sd	s0,16(sp)
    80003128:	e426                	sd	s1,8(sp)
    8000312a:	1000                	addi	s0,sp,32
    8000312c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000312e:	0541                	addi	a0,a0,16
    80003130:	00001097          	auipc	ra,0x1
    80003134:	4b2080e7          	jalr	1202(ra) # 800045e2 <holdingsleep>
    80003138:	cd01                	beqz	a0,80003150 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000313a:	4585                	li	a1,1
    8000313c:	8526                	mv	a0,s1
    8000313e:	00003097          	auipc	ra,0x3
    80003142:	fd0080e7          	jalr	-48(ra) # 8000610e <virtio_disk_rw>
}
    80003146:	60e2                	ld	ra,24(sp)
    80003148:	6442                	ld	s0,16(sp)
    8000314a:	64a2                	ld	s1,8(sp)
    8000314c:	6105                	addi	sp,sp,32
    8000314e:	8082                	ret
    panic("bwrite");
    80003150:	00005517          	auipc	a0,0x5
    80003154:	55050513          	addi	a0,a0,1360 # 800086a0 <syscallname+0x1e0>
    80003158:	ffffd097          	auipc	ra,0xffffd
    8000315c:	41c080e7          	jalr	1052(ra) # 80000574 <panic>

0000000080003160 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003160:	1101                	addi	sp,sp,-32
    80003162:	ec06                	sd	ra,24(sp)
    80003164:	e822                	sd	s0,16(sp)
    80003166:	e426                	sd	s1,8(sp)
    80003168:	e04a                	sd	s2,0(sp)
    8000316a:	1000                	addi	s0,sp,32
    8000316c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000316e:	01050913          	addi	s2,a0,16
    80003172:	854a                	mv	a0,s2
    80003174:	00001097          	auipc	ra,0x1
    80003178:	46e080e7          	jalr	1134(ra) # 800045e2 <holdingsleep>
    8000317c:	c92d                	beqz	a0,800031ee <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000317e:	854a                	mv	a0,s2
    80003180:	00001097          	auipc	ra,0x1
    80003184:	41e080e7          	jalr	1054(ra) # 8000459e <releasesleep>

  acquire(&bcache.lock);
    80003188:	00014517          	auipc	a0,0x14
    8000318c:	7f850513          	addi	a0,a0,2040 # 80017980 <bcache>
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	b1c080e7          	jalr	-1252(ra) # 80000cac <acquire>
  b->refcnt--;
    80003198:	40bc                	lw	a5,64(s1)
    8000319a:	37fd                	addiw	a5,a5,-1
    8000319c:	0007871b          	sext.w	a4,a5
    800031a0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031a2:	eb05                	bnez	a4,800031d2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031a4:	68bc                	ld	a5,80(s1)
    800031a6:	64b8                	ld	a4,72(s1)
    800031a8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031aa:	64bc                	ld	a5,72(s1)
    800031ac:	68b8                	ld	a4,80(s1)
    800031ae:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031b0:	0001c797          	auipc	a5,0x1c
    800031b4:	7d078793          	addi	a5,a5,2000 # 8001f980 <bcache+0x8000>
    800031b8:	2b87b703          	ld	a4,696(a5)
    800031bc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031be:	0001d717          	auipc	a4,0x1d
    800031c2:	a2a70713          	addi	a4,a4,-1494 # 8001fbe8 <bcache+0x8268>
    800031c6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031c8:	2b87b703          	ld	a4,696(a5)
    800031cc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031ce:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031d2:	00014517          	auipc	a0,0x14
    800031d6:	7ae50513          	addi	a0,a0,1966 # 80017980 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	b86080e7          	jalr	-1146(ra) # 80000d60 <release>
}
    800031e2:	60e2                	ld	ra,24(sp)
    800031e4:	6442                	ld	s0,16(sp)
    800031e6:	64a2                	ld	s1,8(sp)
    800031e8:	6902                	ld	s2,0(sp)
    800031ea:	6105                	addi	sp,sp,32
    800031ec:	8082                	ret
    panic("brelse");
    800031ee:	00005517          	auipc	a0,0x5
    800031f2:	4ba50513          	addi	a0,a0,1210 # 800086a8 <syscallname+0x1e8>
    800031f6:	ffffd097          	auipc	ra,0xffffd
    800031fa:	37e080e7          	jalr	894(ra) # 80000574 <panic>

00000000800031fe <bpin>:

void
bpin(struct buf *b) {
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	1000                	addi	s0,sp,32
    80003208:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000320a:	00014517          	auipc	a0,0x14
    8000320e:	77650513          	addi	a0,a0,1910 # 80017980 <bcache>
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	a9a080e7          	jalr	-1382(ra) # 80000cac <acquire>
  b->refcnt++;
    8000321a:	40bc                	lw	a5,64(s1)
    8000321c:	2785                	addiw	a5,a5,1
    8000321e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003220:	00014517          	auipc	a0,0x14
    80003224:	76050513          	addi	a0,a0,1888 # 80017980 <bcache>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	b38080e7          	jalr	-1224(ra) # 80000d60 <release>
}
    80003230:	60e2                	ld	ra,24(sp)
    80003232:	6442                	ld	s0,16(sp)
    80003234:	64a2                	ld	s1,8(sp)
    80003236:	6105                	addi	sp,sp,32
    80003238:	8082                	ret

000000008000323a <bunpin>:

void
bunpin(struct buf *b) {
    8000323a:	1101                	addi	sp,sp,-32
    8000323c:	ec06                	sd	ra,24(sp)
    8000323e:	e822                	sd	s0,16(sp)
    80003240:	e426                	sd	s1,8(sp)
    80003242:	1000                	addi	s0,sp,32
    80003244:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003246:	00014517          	auipc	a0,0x14
    8000324a:	73a50513          	addi	a0,a0,1850 # 80017980 <bcache>
    8000324e:	ffffe097          	auipc	ra,0xffffe
    80003252:	a5e080e7          	jalr	-1442(ra) # 80000cac <acquire>
  b->refcnt--;
    80003256:	40bc                	lw	a5,64(s1)
    80003258:	37fd                	addiw	a5,a5,-1
    8000325a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000325c:	00014517          	auipc	a0,0x14
    80003260:	72450513          	addi	a0,a0,1828 # 80017980 <bcache>
    80003264:	ffffe097          	auipc	ra,0xffffe
    80003268:	afc080e7          	jalr	-1284(ra) # 80000d60 <release>
}
    8000326c:	60e2                	ld	ra,24(sp)
    8000326e:	6442                	ld	s0,16(sp)
    80003270:	64a2                	ld	s1,8(sp)
    80003272:	6105                	addi	sp,sp,32
    80003274:	8082                	ret

0000000080003276 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003276:	1101                	addi	sp,sp,-32
    80003278:	ec06                	sd	ra,24(sp)
    8000327a:	e822                	sd	s0,16(sp)
    8000327c:	e426                	sd	s1,8(sp)
    8000327e:	e04a                	sd	s2,0(sp)
    80003280:	1000                	addi	s0,sp,32
    80003282:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003284:	00d5d59b          	srliw	a1,a1,0xd
    80003288:	0001d797          	auipc	a5,0x1d
    8000328c:	db878793          	addi	a5,a5,-584 # 80020040 <sb>
    80003290:	4fdc                	lw	a5,28(a5)
    80003292:	9dbd                	addw	a1,a1,a5
    80003294:	00000097          	auipc	ra,0x0
    80003298:	d8a080e7          	jalr	-630(ra) # 8000301e <bread>
  bi = b % BPB;
    8000329c:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    8000329e:	0074f793          	andi	a5,s1,7
    800032a2:	4705                	li	a4,1
    800032a4:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800032a8:	6789                	lui	a5,0x2
    800032aa:	17fd                	addi	a5,a5,-1
    800032ac:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800032ae:	41f4d79b          	sraiw	a5,s1,0x1f
    800032b2:	01d7d79b          	srliw	a5,a5,0x1d
    800032b6:	9fa5                	addw	a5,a5,s1
    800032b8:	4037d79b          	sraiw	a5,a5,0x3
    800032bc:	00f506b3          	add	a3,a0,a5
    800032c0:	0586c683          	lbu	a3,88(a3)
    800032c4:	00d77633          	and	a2,a4,a3
    800032c8:	c61d                	beqz	a2,800032f6 <bfree+0x80>
    800032ca:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032cc:	97aa                	add	a5,a5,a0
    800032ce:	fff74713          	not	a4,a4
    800032d2:	8f75                	and	a4,a4,a3
    800032d4:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    800032d8:	00001097          	auipc	ra,0x1
    800032dc:	132080e7          	jalr	306(ra) # 8000440a <log_write>
  brelse(bp);
    800032e0:	854a                	mv	a0,s2
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	e7e080e7          	jalr	-386(ra) # 80003160 <brelse>
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	64a2                	ld	s1,8(sp)
    800032f0:	6902                	ld	s2,0(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret
    panic("freeing free block");
    800032f6:	00005517          	auipc	a0,0x5
    800032fa:	3ba50513          	addi	a0,a0,954 # 800086b0 <syscallname+0x1f0>
    800032fe:	ffffd097          	auipc	ra,0xffffd
    80003302:	276080e7          	jalr	630(ra) # 80000574 <panic>

0000000080003306 <balloc>:
{
    80003306:	711d                	addi	sp,sp,-96
    80003308:	ec86                	sd	ra,88(sp)
    8000330a:	e8a2                	sd	s0,80(sp)
    8000330c:	e4a6                	sd	s1,72(sp)
    8000330e:	e0ca                	sd	s2,64(sp)
    80003310:	fc4e                	sd	s3,56(sp)
    80003312:	f852                	sd	s4,48(sp)
    80003314:	f456                	sd	s5,40(sp)
    80003316:	f05a                	sd	s6,32(sp)
    80003318:	ec5e                	sd	s7,24(sp)
    8000331a:	e862                	sd	s8,16(sp)
    8000331c:	e466                	sd	s9,8(sp)
    8000331e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003320:	0001d797          	auipc	a5,0x1d
    80003324:	d2078793          	addi	a5,a5,-736 # 80020040 <sb>
    80003328:	43dc                	lw	a5,4(a5)
    8000332a:	10078e63          	beqz	a5,80003446 <balloc+0x140>
    8000332e:	8baa                	mv	s7,a0
    80003330:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003332:	0001db17          	auipc	s6,0x1d
    80003336:	d0eb0b13          	addi	s6,s6,-754 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333a:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    8000333c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003340:	6c89                	lui	s9,0x2
    80003342:	a079                	j	800033d0 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003344:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    80003346:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003348:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    8000334a:	96a6                	add	a3,a3,s1
    8000334c:	8f51                	or	a4,a4,a2
    8000334e:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    80003352:	8526                	mv	a0,s1
    80003354:	00001097          	auipc	ra,0x1
    80003358:	0b6080e7          	jalr	182(ra) # 8000440a <log_write>
        brelse(bp);
    8000335c:	8526                	mv	a0,s1
    8000335e:	00000097          	auipc	ra,0x0
    80003362:	e02080e7          	jalr	-510(ra) # 80003160 <brelse>
  bp = bread(dev, bno);
    80003366:	85ca                	mv	a1,s2
    80003368:	855e                	mv	a0,s7
    8000336a:	00000097          	auipc	ra,0x0
    8000336e:	cb4080e7          	jalr	-844(ra) # 8000301e <bread>
    80003372:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    80003374:	40000613          	li	a2,1024
    80003378:	4581                	li	a1,0
    8000337a:	05850513          	addi	a0,a0,88
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	a2a080e7          	jalr	-1494(ra) # 80000da8 <memset>
  log_write(bp);
    80003386:	8526                	mv	a0,s1
    80003388:	00001097          	auipc	ra,0x1
    8000338c:	082080e7          	jalr	130(ra) # 8000440a <log_write>
  brelse(bp);
    80003390:	8526                	mv	a0,s1
    80003392:	00000097          	auipc	ra,0x0
    80003396:	dce080e7          	jalr	-562(ra) # 80003160 <brelse>
}
    8000339a:	854a                	mv	a0,s2
    8000339c:	60e6                	ld	ra,88(sp)
    8000339e:	6446                	ld	s0,80(sp)
    800033a0:	64a6                	ld	s1,72(sp)
    800033a2:	6906                	ld	s2,64(sp)
    800033a4:	79e2                	ld	s3,56(sp)
    800033a6:	7a42                	ld	s4,48(sp)
    800033a8:	7aa2                	ld	s5,40(sp)
    800033aa:	7b02                	ld	s6,32(sp)
    800033ac:	6be2                	ld	s7,24(sp)
    800033ae:	6c42                	ld	s8,16(sp)
    800033b0:	6ca2                	ld	s9,8(sp)
    800033b2:	6125                	addi	sp,sp,96
    800033b4:	8082                	ret
    brelse(bp);
    800033b6:	8526                	mv	a0,s1
    800033b8:	00000097          	auipc	ra,0x0
    800033bc:	da8080e7          	jalr	-600(ra) # 80003160 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033c0:	015c87bb          	addw	a5,s9,s5
    800033c4:	00078a9b          	sext.w	s5,a5
    800033c8:	004b2703          	lw	a4,4(s6)
    800033cc:	06eafd63          	bleu	a4,s5,80003446 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800033d0:	41fad79b          	sraiw	a5,s5,0x1f
    800033d4:	0137d79b          	srliw	a5,a5,0x13
    800033d8:	015787bb          	addw	a5,a5,s5
    800033dc:	40d7d79b          	sraiw	a5,a5,0xd
    800033e0:	01cb2583          	lw	a1,28(s6)
    800033e4:	9dbd                	addw	a1,a1,a5
    800033e6:	855e                	mv	a0,s7
    800033e8:	00000097          	auipc	ra,0x0
    800033ec:	c36080e7          	jalr	-970(ra) # 8000301e <bread>
    800033f0:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f2:	000a881b          	sext.w	a6,s5
    800033f6:	004b2503          	lw	a0,4(s6)
    800033fa:	faa87ee3          	bleu	a0,a6,800033b6 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033fe:	0584c603          	lbu	a2,88(s1)
    80003402:	00167793          	andi	a5,a2,1
    80003406:	df9d                	beqz	a5,80003344 <balloc+0x3e>
    80003408:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340c:	87e2                	mv	a5,s8
    8000340e:	0107893b          	addw	s2,a5,a6
    80003412:	faa782e3          	beq	a5,a0,800033b6 <balloc+0xb0>
      m = 1 << (bi % 8);
    80003416:	41f7d71b          	sraiw	a4,a5,0x1f
    8000341a:	01d7561b          	srliw	a2,a4,0x1d
    8000341e:	00f606bb          	addw	a3,a2,a5
    80003422:	0076f713          	andi	a4,a3,7
    80003426:	9f11                	subw	a4,a4,a2
    80003428:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000342c:	4036d69b          	sraiw	a3,a3,0x3
    80003430:	00d48633          	add	a2,s1,a3
    80003434:	05864603          	lbu	a2,88(a2)
    80003438:	00c775b3          	and	a1,a4,a2
    8000343c:	d599                	beqz	a1,8000334a <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000343e:	2785                	addiw	a5,a5,1
    80003440:	fd4797e3          	bne	a5,s4,8000340e <balloc+0x108>
    80003444:	bf8d                	j	800033b6 <balloc+0xb0>
  panic("balloc: out of blocks");
    80003446:	00005517          	auipc	a0,0x5
    8000344a:	28250513          	addi	a0,a0,642 # 800086c8 <syscallname+0x208>
    8000344e:	ffffd097          	auipc	ra,0xffffd
    80003452:	126080e7          	jalr	294(ra) # 80000574 <panic>

0000000080003456 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003456:	7179                	addi	sp,sp,-48
    80003458:	f406                	sd	ra,40(sp)
    8000345a:	f022                	sd	s0,32(sp)
    8000345c:	ec26                	sd	s1,24(sp)
    8000345e:	e84a                	sd	s2,16(sp)
    80003460:	e44e                	sd	s3,8(sp)
    80003462:	e052                	sd	s4,0(sp)
    80003464:	1800                	addi	s0,sp,48
    80003466:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003468:	47ad                	li	a5,11
    8000346a:	04b7fe63          	bleu	a1,a5,800034c6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000346e:	ff45849b          	addiw	s1,a1,-12
    80003472:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003476:	0ff00793          	li	a5,255
    8000347a:	0ae7e363          	bltu	a5,a4,80003520 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000347e:	08052583          	lw	a1,128(a0)
    80003482:	c5ad                	beqz	a1,800034ec <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003484:	0009a503          	lw	a0,0(s3)
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	b96080e7          	jalr	-1130(ra) # 8000301e <bread>
    80003490:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003492:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003496:	02049593          	slli	a1,s1,0x20
    8000349a:	9181                	srli	a1,a1,0x20
    8000349c:	058a                	slli	a1,a1,0x2
    8000349e:	00b784b3          	add	s1,a5,a1
    800034a2:	0004a903          	lw	s2,0(s1)
    800034a6:	04090d63          	beqz	s2,80003500 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034aa:	8552                	mv	a0,s4
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	cb4080e7          	jalr	-844(ra) # 80003160 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034b4:	854a                	mv	a0,s2
    800034b6:	70a2                	ld	ra,40(sp)
    800034b8:	7402                	ld	s0,32(sp)
    800034ba:	64e2                	ld	s1,24(sp)
    800034bc:	6942                	ld	s2,16(sp)
    800034be:	69a2                	ld	s3,8(sp)
    800034c0:	6a02                	ld	s4,0(sp)
    800034c2:	6145                	addi	sp,sp,48
    800034c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034c6:	02059493          	slli	s1,a1,0x20
    800034ca:	9081                	srli	s1,s1,0x20
    800034cc:	048a                	slli	s1,s1,0x2
    800034ce:	94aa                	add	s1,s1,a0
    800034d0:	0504a903          	lw	s2,80(s1)
    800034d4:	fe0910e3          	bnez	s2,800034b4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034d8:	4108                	lw	a0,0(a0)
    800034da:	00000097          	auipc	ra,0x0
    800034de:	e2c080e7          	jalr	-468(ra) # 80003306 <balloc>
    800034e2:	0005091b          	sext.w	s2,a0
    800034e6:	0524a823          	sw	s2,80(s1)
    800034ea:	b7e9                	j	800034b4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034ec:	4108                	lw	a0,0(a0)
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	e18080e7          	jalr	-488(ra) # 80003306 <balloc>
    800034f6:	0005059b          	sext.w	a1,a0
    800034fa:	08b9a023          	sw	a1,128(s3)
    800034fe:	b759                	j	80003484 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003500:	0009a503          	lw	a0,0(s3)
    80003504:	00000097          	auipc	ra,0x0
    80003508:	e02080e7          	jalr	-510(ra) # 80003306 <balloc>
    8000350c:	0005091b          	sext.w	s2,a0
    80003510:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    80003514:	8552                	mv	a0,s4
    80003516:	00001097          	auipc	ra,0x1
    8000351a:	ef4080e7          	jalr	-268(ra) # 8000440a <log_write>
    8000351e:	b771                	j	800034aa <bmap+0x54>
  panic("bmap: out of range");
    80003520:	00005517          	auipc	a0,0x5
    80003524:	1c050513          	addi	a0,a0,448 # 800086e0 <syscallname+0x220>
    80003528:	ffffd097          	auipc	ra,0xffffd
    8000352c:	04c080e7          	jalr	76(ra) # 80000574 <panic>

0000000080003530 <iget>:
{
    80003530:	7179                	addi	sp,sp,-48
    80003532:	f406                	sd	ra,40(sp)
    80003534:	f022                	sd	s0,32(sp)
    80003536:	ec26                	sd	s1,24(sp)
    80003538:	e84a                	sd	s2,16(sp)
    8000353a:	e44e                	sd	s3,8(sp)
    8000353c:	e052                	sd	s4,0(sp)
    8000353e:	1800                	addi	s0,sp,48
    80003540:	89aa                	mv	s3,a0
    80003542:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003544:	0001d517          	auipc	a0,0x1d
    80003548:	b1c50513          	addi	a0,a0,-1252 # 80020060 <icache>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	760080e7          	jalr	1888(ra) # 80000cac <acquire>
  empty = 0;
    80003554:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003556:	0001d497          	auipc	s1,0x1d
    8000355a:	b2248493          	addi	s1,s1,-1246 # 80020078 <icache+0x18>
    8000355e:	0001e697          	auipc	a3,0x1e
    80003562:	5aa68693          	addi	a3,a3,1450 # 80021b08 <log>
    80003566:	a039                	j	80003574 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003568:	02090b63          	beqz	s2,8000359e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000356c:	08848493          	addi	s1,s1,136
    80003570:	02d48a63          	beq	s1,a3,800035a4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003574:	449c                	lw	a5,8(s1)
    80003576:	fef059e3          	blez	a5,80003568 <iget+0x38>
    8000357a:	4098                	lw	a4,0(s1)
    8000357c:	ff3716e3          	bne	a4,s3,80003568 <iget+0x38>
    80003580:	40d8                	lw	a4,4(s1)
    80003582:	ff4713e3          	bne	a4,s4,80003568 <iget+0x38>
      ip->ref++;
    80003586:	2785                	addiw	a5,a5,1
    80003588:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000358a:	0001d517          	auipc	a0,0x1d
    8000358e:	ad650513          	addi	a0,a0,-1322 # 80020060 <icache>
    80003592:	ffffd097          	auipc	ra,0xffffd
    80003596:	7ce080e7          	jalr	1998(ra) # 80000d60 <release>
      return ip;
    8000359a:	8926                	mv	s2,s1
    8000359c:	a03d                	j	800035ca <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000359e:	f7f9                	bnez	a5,8000356c <iget+0x3c>
    800035a0:	8926                	mv	s2,s1
    800035a2:	b7e9                	j	8000356c <iget+0x3c>
  if(empty == 0)
    800035a4:	02090c63          	beqz	s2,800035dc <iget+0xac>
  ip->dev = dev;
    800035a8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035ac:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035b0:	4785                	li	a5,1
    800035b2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035b6:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035ba:	0001d517          	auipc	a0,0x1d
    800035be:	aa650513          	addi	a0,a0,-1370 # 80020060 <icache>
    800035c2:	ffffd097          	auipc	ra,0xffffd
    800035c6:	79e080e7          	jalr	1950(ra) # 80000d60 <release>
}
    800035ca:	854a                	mv	a0,s2
    800035cc:	70a2                	ld	ra,40(sp)
    800035ce:	7402                	ld	s0,32(sp)
    800035d0:	64e2                	ld	s1,24(sp)
    800035d2:	6942                	ld	s2,16(sp)
    800035d4:	69a2                	ld	s3,8(sp)
    800035d6:	6a02                	ld	s4,0(sp)
    800035d8:	6145                	addi	sp,sp,48
    800035da:	8082                	ret
    panic("iget: no inodes");
    800035dc:	00005517          	auipc	a0,0x5
    800035e0:	11c50513          	addi	a0,a0,284 # 800086f8 <syscallname+0x238>
    800035e4:	ffffd097          	auipc	ra,0xffffd
    800035e8:	f90080e7          	jalr	-112(ra) # 80000574 <panic>

00000000800035ec <fsinit>:
fsinit(int dev) {
    800035ec:	7179                	addi	sp,sp,-48
    800035ee:	f406                	sd	ra,40(sp)
    800035f0:	f022                	sd	s0,32(sp)
    800035f2:	ec26                	sd	s1,24(sp)
    800035f4:	e84a                	sd	s2,16(sp)
    800035f6:	e44e                	sd	s3,8(sp)
    800035f8:	1800                	addi	s0,sp,48
    800035fa:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    800035fc:	4585                	li	a1,1
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	a20080e7          	jalr	-1504(ra) # 8000301e <bread>
    80003606:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003608:	0001d497          	auipc	s1,0x1d
    8000360c:	a3848493          	addi	s1,s1,-1480 # 80020040 <sb>
    80003610:	02000613          	li	a2,32
    80003614:	05850593          	addi	a1,a0,88
    80003618:	8526                	mv	a0,s1
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	7fa080e7          	jalr	2042(ra) # 80000e14 <memmove>
  brelse(bp);
    80003622:	854a                	mv	a0,s2
    80003624:	00000097          	auipc	ra,0x0
    80003628:	b3c080e7          	jalr	-1220(ra) # 80003160 <brelse>
  if(sb.magic != FSMAGIC)
    8000362c:	4098                	lw	a4,0(s1)
    8000362e:	102037b7          	lui	a5,0x10203
    80003632:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003636:	02f71263          	bne	a4,a5,8000365a <fsinit+0x6e>
  initlog(dev, &sb);
    8000363a:	0001d597          	auipc	a1,0x1d
    8000363e:	a0658593          	addi	a1,a1,-1530 # 80020040 <sb>
    80003642:	854e                	mv	a0,s3
    80003644:	00001097          	auipc	ra,0x1
    80003648:	b48080e7          	jalr	-1208(ra) # 8000418c <initlog>
}
    8000364c:	70a2                	ld	ra,40(sp)
    8000364e:	7402                	ld	s0,32(sp)
    80003650:	64e2                	ld	s1,24(sp)
    80003652:	6942                	ld	s2,16(sp)
    80003654:	69a2                	ld	s3,8(sp)
    80003656:	6145                	addi	sp,sp,48
    80003658:	8082                	ret
    panic("invalid file system");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	0ae50513          	addi	a0,a0,174 # 80008708 <syscallname+0x248>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	f12080e7          	jalr	-238(ra) # 80000574 <panic>

000000008000366a <iinit>:
{
    8000366a:	7179                	addi	sp,sp,-48
    8000366c:	f406                	sd	ra,40(sp)
    8000366e:	f022                	sd	s0,32(sp)
    80003670:	ec26                	sd	s1,24(sp)
    80003672:	e84a                	sd	s2,16(sp)
    80003674:	e44e                	sd	s3,8(sp)
    80003676:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003678:	00005597          	auipc	a1,0x5
    8000367c:	0a858593          	addi	a1,a1,168 # 80008720 <syscallname+0x260>
    80003680:	0001d517          	auipc	a0,0x1d
    80003684:	9e050513          	addi	a0,a0,-1568 # 80020060 <icache>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	594080e7          	jalr	1428(ra) # 80000c1c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003690:	0001d497          	auipc	s1,0x1d
    80003694:	9f848493          	addi	s1,s1,-1544 # 80020088 <icache+0x28>
    80003698:	0001e997          	auipc	s3,0x1e
    8000369c:	48098993          	addi	s3,s3,1152 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036a0:	00005917          	auipc	s2,0x5
    800036a4:	08890913          	addi	s2,s2,136 # 80008728 <syscallname+0x268>
    800036a8:	85ca                	mv	a1,s2
    800036aa:	8526                	mv	a0,s1
    800036ac:	00001097          	auipc	ra,0x1
    800036b0:	e62080e7          	jalr	-414(ra) # 8000450e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036b4:	08848493          	addi	s1,s1,136
    800036b8:	ff3498e3          	bne	s1,s3,800036a8 <iinit+0x3e>
}
    800036bc:	70a2                	ld	ra,40(sp)
    800036be:	7402                	ld	s0,32(sp)
    800036c0:	64e2                	ld	s1,24(sp)
    800036c2:	6942                	ld	s2,16(sp)
    800036c4:	69a2                	ld	s3,8(sp)
    800036c6:	6145                	addi	sp,sp,48
    800036c8:	8082                	ret

00000000800036ca <ialloc>:
{
    800036ca:	715d                	addi	sp,sp,-80
    800036cc:	e486                	sd	ra,72(sp)
    800036ce:	e0a2                	sd	s0,64(sp)
    800036d0:	fc26                	sd	s1,56(sp)
    800036d2:	f84a                	sd	s2,48(sp)
    800036d4:	f44e                	sd	s3,40(sp)
    800036d6:	f052                	sd	s4,32(sp)
    800036d8:	ec56                	sd	s5,24(sp)
    800036da:	e85a                	sd	s6,16(sp)
    800036dc:	e45e                	sd	s7,8(sp)
    800036de:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e0:	0001d797          	auipc	a5,0x1d
    800036e4:	96078793          	addi	a5,a5,-1696 # 80020040 <sb>
    800036e8:	47d8                	lw	a4,12(a5)
    800036ea:	4785                	li	a5,1
    800036ec:	04e7fa63          	bleu	a4,a5,80003740 <ialloc+0x76>
    800036f0:	8a2a                	mv	s4,a0
    800036f2:	8b2e                	mv	s6,a1
    800036f4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036f6:	0001d997          	auipc	s3,0x1d
    800036fa:	94a98993          	addi	s3,s3,-1718 # 80020040 <sb>
    800036fe:	00048a9b          	sext.w	s5,s1
    80003702:	0044d593          	srli	a1,s1,0x4
    80003706:	0189a783          	lw	a5,24(s3)
    8000370a:	9dbd                	addw	a1,a1,a5
    8000370c:	8552                	mv	a0,s4
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	910080e7          	jalr	-1776(ra) # 8000301e <bread>
    80003716:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003718:	05850913          	addi	s2,a0,88
    8000371c:	00f4f793          	andi	a5,s1,15
    80003720:	079a                	slli	a5,a5,0x6
    80003722:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80003724:	00091783          	lh	a5,0(s2)
    80003728:	c785                	beqz	a5,80003750 <ialloc+0x86>
    brelse(bp);
    8000372a:	00000097          	auipc	ra,0x0
    8000372e:	a36080e7          	jalr	-1482(ra) # 80003160 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003732:	0485                	addi	s1,s1,1
    80003734:	00c9a703          	lw	a4,12(s3)
    80003738:	0004879b          	sext.w	a5,s1
    8000373c:	fce7e1e3          	bltu	a5,a4,800036fe <ialloc+0x34>
  panic("ialloc: no inodes");
    80003740:	00005517          	auipc	a0,0x5
    80003744:	ff050513          	addi	a0,a0,-16 # 80008730 <syscallname+0x270>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	e2c080e7          	jalr	-468(ra) # 80000574 <panic>
      memset(dip, 0, sizeof(*dip));
    80003750:	04000613          	li	a2,64
    80003754:	4581                	li	a1,0
    80003756:	854a                	mv	a0,s2
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	650080e7          	jalr	1616(ra) # 80000da8 <memset>
      dip->type = type;
    80003760:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80003764:	855e                	mv	a0,s7
    80003766:	00001097          	auipc	ra,0x1
    8000376a:	ca4080e7          	jalr	-860(ra) # 8000440a <log_write>
      brelse(bp);
    8000376e:	855e                	mv	a0,s7
    80003770:	00000097          	auipc	ra,0x0
    80003774:	9f0080e7          	jalr	-1552(ra) # 80003160 <brelse>
      return iget(dev, inum);
    80003778:	85d6                	mv	a1,s5
    8000377a:	8552                	mv	a0,s4
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	db4080e7          	jalr	-588(ra) # 80003530 <iget>
}
    80003784:	60a6                	ld	ra,72(sp)
    80003786:	6406                	ld	s0,64(sp)
    80003788:	74e2                	ld	s1,56(sp)
    8000378a:	7942                	ld	s2,48(sp)
    8000378c:	79a2                	ld	s3,40(sp)
    8000378e:	7a02                	ld	s4,32(sp)
    80003790:	6ae2                	ld	s5,24(sp)
    80003792:	6b42                	ld	s6,16(sp)
    80003794:	6ba2                	ld	s7,8(sp)
    80003796:	6161                	addi	sp,sp,80
    80003798:	8082                	ret

000000008000379a <iupdate>:
{
    8000379a:	1101                	addi	sp,sp,-32
    8000379c:	ec06                	sd	ra,24(sp)
    8000379e:	e822                	sd	s0,16(sp)
    800037a0:	e426                	sd	s1,8(sp)
    800037a2:	e04a                	sd	s2,0(sp)
    800037a4:	1000                	addi	s0,sp,32
    800037a6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037a8:	415c                	lw	a5,4(a0)
    800037aa:	0047d79b          	srliw	a5,a5,0x4
    800037ae:	0001d717          	auipc	a4,0x1d
    800037b2:	89270713          	addi	a4,a4,-1902 # 80020040 <sb>
    800037b6:	4f0c                	lw	a1,24(a4)
    800037b8:	9dbd                	addw	a1,a1,a5
    800037ba:	4108                	lw	a0,0(a0)
    800037bc:	00000097          	auipc	ra,0x0
    800037c0:	862080e7          	jalr	-1950(ra) # 8000301e <bread>
    800037c4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037c6:	05850513          	addi	a0,a0,88
    800037ca:	40dc                	lw	a5,4(s1)
    800037cc:	8bbd                	andi	a5,a5,15
    800037ce:	079a                	slli	a5,a5,0x6
    800037d0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037d2:	04449783          	lh	a5,68(s1)
    800037d6:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    800037da:	04649783          	lh	a5,70(s1)
    800037de:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    800037e2:	04849783          	lh	a5,72(s1)
    800037e6:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    800037ea:	04a49783          	lh	a5,74(s1)
    800037ee:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    800037f2:	44fc                	lw	a5,76(s1)
    800037f4:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037f6:	03400613          	li	a2,52
    800037fa:	05048593          	addi	a1,s1,80
    800037fe:	0531                	addi	a0,a0,12
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	614080e7          	jalr	1556(ra) # 80000e14 <memmove>
  log_write(bp);
    80003808:	854a                	mv	a0,s2
    8000380a:	00001097          	auipc	ra,0x1
    8000380e:	c00080e7          	jalr	-1024(ra) # 8000440a <log_write>
  brelse(bp);
    80003812:	854a                	mv	a0,s2
    80003814:	00000097          	auipc	ra,0x0
    80003818:	94c080e7          	jalr	-1716(ra) # 80003160 <brelse>
}
    8000381c:	60e2                	ld	ra,24(sp)
    8000381e:	6442                	ld	s0,16(sp)
    80003820:	64a2                	ld	s1,8(sp)
    80003822:	6902                	ld	s2,0(sp)
    80003824:	6105                	addi	sp,sp,32
    80003826:	8082                	ret

0000000080003828 <idup>:
{
    80003828:	1101                	addi	sp,sp,-32
    8000382a:	ec06                	sd	ra,24(sp)
    8000382c:	e822                	sd	s0,16(sp)
    8000382e:	e426                	sd	s1,8(sp)
    80003830:	1000                	addi	s0,sp,32
    80003832:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003834:	0001d517          	auipc	a0,0x1d
    80003838:	82c50513          	addi	a0,a0,-2004 # 80020060 <icache>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	470080e7          	jalr	1136(ra) # 80000cac <acquire>
  ip->ref++;
    80003844:	449c                	lw	a5,8(s1)
    80003846:	2785                	addiw	a5,a5,1
    80003848:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000384a:	0001d517          	auipc	a0,0x1d
    8000384e:	81650513          	addi	a0,a0,-2026 # 80020060 <icache>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	50e080e7          	jalr	1294(ra) # 80000d60 <release>
}
    8000385a:	8526                	mv	a0,s1
    8000385c:	60e2                	ld	ra,24(sp)
    8000385e:	6442                	ld	s0,16(sp)
    80003860:	64a2                	ld	s1,8(sp)
    80003862:	6105                	addi	sp,sp,32
    80003864:	8082                	ret

0000000080003866 <ilock>:
{
    80003866:	1101                	addi	sp,sp,-32
    80003868:	ec06                	sd	ra,24(sp)
    8000386a:	e822                	sd	s0,16(sp)
    8000386c:	e426                	sd	s1,8(sp)
    8000386e:	e04a                	sd	s2,0(sp)
    80003870:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003872:	c115                	beqz	a0,80003896 <ilock+0x30>
    80003874:	84aa                	mv	s1,a0
    80003876:	451c                	lw	a5,8(a0)
    80003878:	00f05f63          	blez	a5,80003896 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000387c:	0541                	addi	a0,a0,16
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	cca080e7          	jalr	-822(ra) # 80004548 <acquiresleep>
  if(ip->valid == 0){
    80003886:	40bc                	lw	a5,64(s1)
    80003888:	cf99                	beqz	a5,800038a6 <ilock+0x40>
}
    8000388a:	60e2                	ld	ra,24(sp)
    8000388c:	6442                	ld	s0,16(sp)
    8000388e:	64a2                	ld	s1,8(sp)
    80003890:	6902                	ld	s2,0(sp)
    80003892:	6105                	addi	sp,sp,32
    80003894:	8082                	ret
    panic("ilock");
    80003896:	00005517          	auipc	a0,0x5
    8000389a:	eb250513          	addi	a0,a0,-334 # 80008748 <syscallname+0x288>
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	cd6080e7          	jalr	-810(ra) # 80000574 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038a6:	40dc                	lw	a5,4(s1)
    800038a8:	0047d79b          	srliw	a5,a5,0x4
    800038ac:	0001c717          	auipc	a4,0x1c
    800038b0:	79470713          	addi	a4,a4,1940 # 80020040 <sb>
    800038b4:	4f0c                	lw	a1,24(a4)
    800038b6:	9dbd                	addw	a1,a1,a5
    800038b8:	4088                	lw	a0,0(s1)
    800038ba:	fffff097          	auipc	ra,0xfffff
    800038be:	764080e7          	jalr	1892(ra) # 8000301e <bread>
    800038c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038c4:	05850593          	addi	a1,a0,88
    800038c8:	40dc                	lw	a5,4(s1)
    800038ca:	8bbd                	andi	a5,a5,15
    800038cc:	079a                	slli	a5,a5,0x6
    800038ce:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038d0:	00059783          	lh	a5,0(a1)
    800038d4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038d8:	00259783          	lh	a5,2(a1)
    800038dc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038e0:	00459783          	lh	a5,4(a1)
    800038e4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038e8:	00659783          	lh	a5,6(a1)
    800038ec:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038f0:	459c                	lw	a5,8(a1)
    800038f2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038f4:	03400613          	li	a2,52
    800038f8:	05b1                	addi	a1,a1,12
    800038fa:	05048513          	addi	a0,s1,80
    800038fe:	ffffd097          	auipc	ra,0xffffd
    80003902:	516080e7          	jalr	1302(ra) # 80000e14 <memmove>
    brelse(bp);
    80003906:	854a                	mv	a0,s2
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	858080e7          	jalr	-1960(ra) # 80003160 <brelse>
    ip->valid = 1;
    80003910:	4785                	li	a5,1
    80003912:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003914:	04449783          	lh	a5,68(s1)
    80003918:	fbad                	bnez	a5,8000388a <ilock+0x24>
      panic("ilock: no type");
    8000391a:	00005517          	auipc	a0,0x5
    8000391e:	e3650513          	addi	a0,a0,-458 # 80008750 <syscallname+0x290>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	c52080e7          	jalr	-942(ra) # 80000574 <panic>

000000008000392a <iunlock>:
{
    8000392a:	1101                	addi	sp,sp,-32
    8000392c:	ec06                	sd	ra,24(sp)
    8000392e:	e822                	sd	s0,16(sp)
    80003930:	e426                	sd	s1,8(sp)
    80003932:	e04a                	sd	s2,0(sp)
    80003934:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003936:	c905                	beqz	a0,80003966 <iunlock+0x3c>
    80003938:	84aa                	mv	s1,a0
    8000393a:	01050913          	addi	s2,a0,16
    8000393e:	854a                	mv	a0,s2
    80003940:	00001097          	auipc	ra,0x1
    80003944:	ca2080e7          	jalr	-862(ra) # 800045e2 <holdingsleep>
    80003948:	cd19                	beqz	a0,80003966 <iunlock+0x3c>
    8000394a:	449c                	lw	a5,8(s1)
    8000394c:	00f05d63          	blez	a5,80003966 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003950:	854a                	mv	a0,s2
    80003952:	00001097          	auipc	ra,0x1
    80003956:	c4c080e7          	jalr	-948(ra) # 8000459e <releasesleep>
}
    8000395a:	60e2                	ld	ra,24(sp)
    8000395c:	6442                	ld	s0,16(sp)
    8000395e:	64a2                	ld	s1,8(sp)
    80003960:	6902                	ld	s2,0(sp)
    80003962:	6105                	addi	sp,sp,32
    80003964:	8082                	ret
    panic("iunlock");
    80003966:	00005517          	auipc	a0,0x5
    8000396a:	dfa50513          	addi	a0,a0,-518 # 80008760 <syscallname+0x2a0>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	c06080e7          	jalr	-1018(ra) # 80000574 <panic>

0000000080003976 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003976:	7179                	addi	sp,sp,-48
    80003978:	f406                	sd	ra,40(sp)
    8000397a:	f022                	sd	s0,32(sp)
    8000397c:	ec26                	sd	s1,24(sp)
    8000397e:	e84a                	sd	s2,16(sp)
    80003980:	e44e                	sd	s3,8(sp)
    80003982:	e052                	sd	s4,0(sp)
    80003984:	1800                	addi	s0,sp,48
    80003986:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003988:	05050493          	addi	s1,a0,80
    8000398c:	08050913          	addi	s2,a0,128
    80003990:	a821                	j	800039a8 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003992:	0009a503          	lw	a0,0(s3)
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	8e0080e7          	jalr	-1824(ra) # 80003276 <bfree>
      ip->addrs[i] = 0;
    8000399e:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800039a2:	0491                	addi	s1,s1,4
    800039a4:	01248563          	beq	s1,s2,800039ae <itrunc+0x38>
    if(ip->addrs[i]){
    800039a8:	408c                	lw	a1,0(s1)
    800039aa:	dde5                	beqz	a1,800039a2 <itrunc+0x2c>
    800039ac:	b7dd                	j	80003992 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039ae:	0809a583          	lw	a1,128(s3)
    800039b2:	e185                	bnez	a1,800039d2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039b4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039b8:	854e                	mv	a0,s3
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	de0080e7          	jalr	-544(ra) # 8000379a <iupdate>
}
    800039c2:	70a2                	ld	ra,40(sp)
    800039c4:	7402                	ld	s0,32(sp)
    800039c6:	64e2                	ld	s1,24(sp)
    800039c8:	6942                	ld	s2,16(sp)
    800039ca:	69a2                	ld	s3,8(sp)
    800039cc:	6a02                	ld	s4,0(sp)
    800039ce:	6145                	addi	sp,sp,48
    800039d0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039d2:	0009a503          	lw	a0,0(s3)
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	648080e7          	jalr	1608(ra) # 8000301e <bread>
    800039de:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039e0:	05850493          	addi	s1,a0,88
    800039e4:	45850913          	addi	s2,a0,1112
    800039e8:	a811                	j	800039fc <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039ea:	0009a503          	lw	a0,0(s3)
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	888080e7          	jalr	-1912(ra) # 80003276 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039f6:	0491                	addi	s1,s1,4
    800039f8:	01248563          	beq	s1,s2,80003a02 <itrunc+0x8c>
      if(a[j])
    800039fc:	408c                	lw	a1,0(s1)
    800039fe:	dde5                	beqz	a1,800039f6 <itrunc+0x80>
    80003a00:	b7ed                	j	800039ea <itrunc+0x74>
    brelse(bp);
    80003a02:	8552                	mv	a0,s4
    80003a04:	fffff097          	auipc	ra,0xfffff
    80003a08:	75c080e7          	jalr	1884(ra) # 80003160 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a0c:	0809a583          	lw	a1,128(s3)
    80003a10:	0009a503          	lw	a0,0(s3)
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	862080e7          	jalr	-1950(ra) # 80003276 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a1c:	0809a023          	sw	zero,128(s3)
    80003a20:	bf51                	j	800039b4 <itrunc+0x3e>

0000000080003a22 <iput>:
{
    80003a22:	1101                	addi	sp,sp,-32
    80003a24:	ec06                	sd	ra,24(sp)
    80003a26:	e822                	sd	s0,16(sp)
    80003a28:	e426                	sd	s1,8(sp)
    80003a2a:	e04a                	sd	s2,0(sp)
    80003a2c:	1000                	addi	s0,sp,32
    80003a2e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a30:	0001c517          	auipc	a0,0x1c
    80003a34:	63050513          	addi	a0,a0,1584 # 80020060 <icache>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	274080e7          	jalr	628(ra) # 80000cac <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a40:	4498                	lw	a4,8(s1)
    80003a42:	4785                	li	a5,1
    80003a44:	02f70363          	beq	a4,a5,80003a6a <iput+0x48>
  ip->ref--;
    80003a48:	449c                	lw	a5,8(s1)
    80003a4a:	37fd                	addiw	a5,a5,-1
    80003a4c:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a4e:	0001c517          	auipc	a0,0x1c
    80003a52:	61250513          	addi	a0,a0,1554 # 80020060 <icache>
    80003a56:	ffffd097          	auipc	ra,0xffffd
    80003a5a:	30a080e7          	jalr	778(ra) # 80000d60 <release>
}
    80003a5e:	60e2                	ld	ra,24(sp)
    80003a60:	6442                	ld	s0,16(sp)
    80003a62:	64a2                	ld	s1,8(sp)
    80003a64:	6902                	ld	s2,0(sp)
    80003a66:	6105                	addi	sp,sp,32
    80003a68:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a6a:	40bc                	lw	a5,64(s1)
    80003a6c:	dff1                	beqz	a5,80003a48 <iput+0x26>
    80003a6e:	04a49783          	lh	a5,74(s1)
    80003a72:	fbf9                	bnez	a5,80003a48 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a74:	01048913          	addi	s2,s1,16
    80003a78:	854a                	mv	a0,s2
    80003a7a:	00001097          	auipc	ra,0x1
    80003a7e:	ace080e7          	jalr	-1330(ra) # 80004548 <acquiresleep>
    release(&icache.lock);
    80003a82:	0001c517          	auipc	a0,0x1c
    80003a86:	5de50513          	addi	a0,a0,1502 # 80020060 <icache>
    80003a8a:	ffffd097          	auipc	ra,0xffffd
    80003a8e:	2d6080e7          	jalr	726(ra) # 80000d60 <release>
    itrunc(ip);
    80003a92:	8526                	mv	a0,s1
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	ee2080e7          	jalr	-286(ra) # 80003976 <itrunc>
    ip->type = 0;
    80003a9c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aa0:	8526                	mv	a0,s1
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	cf8080e7          	jalr	-776(ra) # 8000379a <iupdate>
    ip->valid = 0;
    80003aaa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aae:	854a                	mv	a0,s2
    80003ab0:	00001097          	auipc	ra,0x1
    80003ab4:	aee080e7          	jalr	-1298(ra) # 8000459e <releasesleep>
    acquire(&icache.lock);
    80003ab8:	0001c517          	auipc	a0,0x1c
    80003abc:	5a850513          	addi	a0,a0,1448 # 80020060 <icache>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	1ec080e7          	jalr	492(ra) # 80000cac <acquire>
    80003ac8:	b741                	j	80003a48 <iput+0x26>

0000000080003aca <iunlockput>:
{
    80003aca:	1101                	addi	sp,sp,-32
    80003acc:	ec06                	sd	ra,24(sp)
    80003ace:	e822                	sd	s0,16(sp)
    80003ad0:	e426                	sd	s1,8(sp)
    80003ad2:	1000                	addi	s0,sp,32
    80003ad4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	e54080e7          	jalr	-428(ra) # 8000392a <iunlock>
  iput(ip);
    80003ade:	8526                	mv	a0,s1
    80003ae0:	00000097          	auipc	ra,0x0
    80003ae4:	f42080e7          	jalr	-190(ra) # 80003a22 <iput>
}
    80003ae8:	60e2                	ld	ra,24(sp)
    80003aea:	6442                	ld	s0,16(sp)
    80003aec:	64a2                	ld	s1,8(sp)
    80003aee:	6105                	addi	sp,sp,32
    80003af0:	8082                	ret

0000000080003af2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003af2:	1141                	addi	sp,sp,-16
    80003af4:	e422                	sd	s0,8(sp)
    80003af6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003af8:	411c                	lw	a5,0(a0)
    80003afa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003afc:	415c                	lw	a5,4(a0)
    80003afe:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b00:	04451783          	lh	a5,68(a0)
    80003b04:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b08:	04a51783          	lh	a5,74(a0)
    80003b0c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b10:	04c56783          	lwu	a5,76(a0)
    80003b14:	e99c                	sd	a5,16(a1)
}
    80003b16:	6422                	ld	s0,8(sp)
    80003b18:	0141                	addi	sp,sp,16
    80003b1a:	8082                	ret

0000000080003b1c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b1c:	457c                	lw	a5,76(a0)
    80003b1e:	0ed7e863          	bltu	a5,a3,80003c0e <readi+0xf2>
{
    80003b22:	7159                	addi	sp,sp,-112
    80003b24:	f486                	sd	ra,104(sp)
    80003b26:	f0a2                	sd	s0,96(sp)
    80003b28:	eca6                	sd	s1,88(sp)
    80003b2a:	e8ca                	sd	s2,80(sp)
    80003b2c:	e4ce                	sd	s3,72(sp)
    80003b2e:	e0d2                	sd	s4,64(sp)
    80003b30:	fc56                	sd	s5,56(sp)
    80003b32:	f85a                	sd	s6,48(sp)
    80003b34:	f45e                	sd	s7,40(sp)
    80003b36:	f062                	sd	s8,32(sp)
    80003b38:	ec66                	sd	s9,24(sp)
    80003b3a:	e86a                	sd	s10,16(sp)
    80003b3c:	e46e                	sd	s11,8(sp)
    80003b3e:	1880                	addi	s0,sp,112
    80003b40:	8baa                	mv	s7,a0
    80003b42:	8c2e                	mv	s8,a1
    80003b44:	8a32                	mv	s4,a2
    80003b46:	84b6                	mv	s1,a3
    80003b48:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b4a:	9f35                	addw	a4,a4,a3
    return 0;
    80003b4c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b4e:	08d76f63          	bltu	a4,a3,80003bec <readi+0xd0>
  if(off + n > ip->size)
    80003b52:	00e7f463          	bleu	a4,a5,80003b5a <readi+0x3e>
    n = ip->size - off;
    80003b56:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b5a:	0a0b0863          	beqz	s6,80003c0a <readi+0xee>
    80003b5e:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b60:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b64:	5cfd                	li	s9,-1
    80003b66:	a82d                	j	80003ba0 <readi+0x84>
    80003b68:	02099d93          	slli	s11,s3,0x20
    80003b6c:	020ddd93          	srli	s11,s11,0x20
    80003b70:	058a8613          	addi	a2,s5,88
    80003b74:	86ee                	mv	a3,s11
    80003b76:	963a                	add	a2,a2,a4
    80003b78:	85d2                	mv	a1,s4
    80003b7a:	8562                	mv	a0,s8
    80003b7c:	fffff097          	auipc	ra,0xfffff
    80003b80:	9be080e7          	jalr	-1602(ra) # 8000253a <either_copyout>
    80003b84:	05950d63          	beq	a0,s9,80003bde <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b88:	8556                	mv	a0,s5
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	5d6080e7          	jalr	1494(ra) # 80003160 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b92:	0129893b          	addw	s2,s3,s2
    80003b96:	009984bb          	addw	s1,s3,s1
    80003b9a:	9a6e                	add	s4,s4,s11
    80003b9c:	05697663          	bleu	s6,s2,80003be8 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ba0:	000ba983          	lw	s3,0(s7)
    80003ba4:	00a4d59b          	srliw	a1,s1,0xa
    80003ba8:	855e                	mv	a0,s7
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	8ac080e7          	jalr	-1876(ra) # 80003456 <bmap>
    80003bb2:	0005059b          	sext.w	a1,a0
    80003bb6:	854e                	mv	a0,s3
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	466080e7          	jalr	1126(ra) # 8000301e <bread>
    80003bc0:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc2:	3ff4f713          	andi	a4,s1,1023
    80003bc6:	40ed07bb          	subw	a5,s10,a4
    80003bca:	412b06bb          	subw	a3,s6,s2
    80003bce:	89be                	mv	s3,a5
    80003bd0:	2781                	sext.w	a5,a5
    80003bd2:	0006861b          	sext.w	a2,a3
    80003bd6:	f8f679e3          	bleu	a5,a2,80003b68 <readi+0x4c>
    80003bda:	89b6                	mv	s3,a3
    80003bdc:	b771                	j	80003b68 <readi+0x4c>
      brelse(bp);
    80003bde:	8556                	mv	a0,s5
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	580080e7          	jalr	1408(ra) # 80003160 <brelse>
  }
  return tot;
    80003be8:	0009051b          	sext.w	a0,s2
}
    80003bec:	70a6                	ld	ra,104(sp)
    80003bee:	7406                	ld	s0,96(sp)
    80003bf0:	64e6                	ld	s1,88(sp)
    80003bf2:	6946                	ld	s2,80(sp)
    80003bf4:	69a6                	ld	s3,72(sp)
    80003bf6:	6a06                	ld	s4,64(sp)
    80003bf8:	7ae2                	ld	s5,56(sp)
    80003bfa:	7b42                	ld	s6,48(sp)
    80003bfc:	7ba2                	ld	s7,40(sp)
    80003bfe:	7c02                	ld	s8,32(sp)
    80003c00:	6ce2                	ld	s9,24(sp)
    80003c02:	6d42                	ld	s10,16(sp)
    80003c04:	6da2                	ld	s11,8(sp)
    80003c06:	6165                	addi	sp,sp,112
    80003c08:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c0a:	895a                	mv	s2,s6
    80003c0c:	bff1                	j	80003be8 <readi+0xcc>
    return 0;
    80003c0e:	4501                	li	a0,0
}
    80003c10:	8082                	ret

0000000080003c12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c12:	457c                	lw	a5,76(a0)
    80003c14:	10d7e663          	bltu	a5,a3,80003d20 <writei+0x10e>
{
    80003c18:	7159                	addi	sp,sp,-112
    80003c1a:	f486                	sd	ra,104(sp)
    80003c1c:	f0a2                	sd	s0,96(sp)
    80003c1e:	eca6                	sd	s1,88(sp)
    80003c20:	e8ca                	sd	s2,80(sp)
    80003c22:	e4ce                	sd	s3,72(sp)
    80003c24:	e0d2                	sd	s4,64(sp)
    80003c26:	fc56                	sd	s5,56(sp)
    80003c28:	f85a                	sd	s6,48(sp)
    80003c2a:	f45e                	sd	s7,40(sp)
    80003c2c:	f062                	sd	s8,32(sp)
    80003c2e:	ec66                	sd	s9,24(sp)
    80003c30:	e86a                	sd	s10,16(sp)
    80003c32:	e46e                	sd	s11,8(sp)
    80003c34:	1880                	addi	s0,sp,112
    80003c36:	8baa                	mv	s7,a0
    80003c38:	8c2e                	mv	s8,a1
    80003c3a:	8ab2                	mv	s5,a2
    80003c3c:	84b6                	mv	s1,a3
    80003c3e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c40:	00e687bb          	addw	a5,a3,a4
    80003c44:	0ed7e063          	bltu	a5,a3,80003d24 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c48:	00043737          	lui	a4,0x43
    80003c4c:	0cf76e63          	bltu	a4,a5,80003d28 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c50:	0a0b0763          	beqz	s6,80003cfe <writei+0xec>
    80003c54:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c56:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c5a:	5cfd                	li	s9,-1
    80003c5c:	a091                	j	80003ca0 <writei+0x8e>
    80003c5e:	02091d93          	slli	s11,s2,0x20
    80003c62:	020ddd93          	srli	s11,s11,0x20
    80003c66:	05898513          	addi	a0,s3,88
    80003c6a:	86ee                	mv	a3,s11
    80003c6c:	8656                	mv	a2,s5
    80003c6e:	85e2                	mv	a1,s8
    80003c70:	953a                	add	a0,a0,a4
    80003c72:	fffff097          	auipc	ra,0xfffff
    80003c76:	91e080e7          	jalr	-1762(ra) # 80002590 <either_copyin>
    80003c7a:	07950263          	beq	a0,s9,80003cde <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c7e:	854e                	mv	a0,s3
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	78a080e7          	jalr	1930(ra) # 8000440a <log_write>
    brelse(bp);
    80003c88:	854e                	mv	a0,s3
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	4d6080e7          	jalr	1238(ra) # 80003160 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c92:	01490a3b          	addw	s4,s2,s4
    80003c96:	009904bb          	addw	s1,s2,s1
    80003c9a:	9aee                	add	s5,s5,s11
    80003c9c:	056a7663          	bleu	s6,s4,80003ce8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ca0:	000ba903          	lw	s2,0(s7)
    80003ca4:	00a4d59b          	srliw	a1,s1,0xa
    80003ca8:	855e                	mv	a0,s7
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	7ac080e7          	jalr	1964(ra) # 80003456 <bmap>
    80003cb2:	0005059b          	sext.w	a1,a0
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	366080e7          	jalr	870(ra) # 8000301e <bread>
    80003cc0:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc2:	3ff4f713          	andi	a4,s1,1023
    80003cc6:	40ed07bb          	subw	a5,s10,a4
    80003cca:	414b06bb          	subw	a3,s6,s4
    80003cce:	893e                	mv	s2,a5
    80003cd0:	2781                	sext.w	a5,a5
    80003cd2:	0006861b          	sext.w	a2,a3
    80003cd6:	f8f674e3          	bleu	a5,a2,80003c5e <writei+0x4c>
    80003cda:	8936                	mv	s2,a3
    80003cdc:	b749                	j	80003c5e <writei+0x4c>
      brelse(bp);
    80003cde:	854e                	mv	a0,s3
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	480080e7          	jalr	1152(ra) # 80003160 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003ce8:	04cba783          	lw	a5,76(s7)
    80003cec:	0097f463          	bleu	s1,a5,80003cf4 <writei+0xe2>
      ip->size = off;
    80003cf0:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003cf4:	855e                	mv	a0,s7
    80003cf6:	00000097          	auipc	ra,0x0
    80003cfa:	aa4080e7          	jalr	-1372(ra) # 8000379a <iupdate>
  }

  return n;
    80003cfe:	000b051b          	sext.w	a0,s6
}
    80003d02:	70a6                	ld	ra,104(sp)
    80003d04:	7406                	ld	s0,96(sp)
    80003d06:	64e6                	ld	s1,88(sp)
    80003d08:	6946                	ld	s2,80(sp)
    80003d0a:	69a6                	ld	s3,72(sp)
    80003d0c:	6a06                	ld	s4,64(sp)
    80003d0e:	7ae2                	ld	s5,56(sp)
    80003d10:	7b42                	ld	s6,48(sp)
    80003d12:	7ba2                	ld	s7,40(sp)
    80003d14:	7c02                	ld	s8,32(sp)
    80003d16:	6ce2                	ld	s9,24(sp)
    80003d18:	6d42                	ld	s10,16(sp)
    80003d1a:	6da2                	ld	s11,8(sp)
    80003d1c:	6165                	addi	sp,sp,112
    80003d1e:	8082                	ret
    return -1;
    80003d20:	557d                	li	a0,-1
}
    80003d22:	8082                	ret
    return -1;
    80003d24:	557d                	li	a0,-1
    80003d26:	bff1                	j	80003d02 <writei+0xf0>
    return -1;
    80003d28:	557d                	li	a0,-1
    80003d2a:	bfe1                	j	80003d02 <writei+0xf0>

0000000080003d2c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d2c:	1141                	addi	sp,sp,-16
    80003d2e:	e406                	sd	ra,8(sp)
    80003d30:	e022                	sd	s0,0(sp)
    80003d32:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d34:	4639                	li	a2,14
    80003d36:	ffffd097          	auipc	ra,0xffffd
    80003d3a:	15a080e7          	jalr	346(ra) # 80000e90 <strncmp>
}
    80003d3e:	60a2                	ld	ra,8(sp)
    80003d40:	6402                	ld	s0,0(sp)
    80003d42:	0141                	addi	sp,sp,16
    80003d44:	8082                	ret

0000000080003d46 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d46:	7139                	addi	sp,sp,-64
    80003d48:	fc06                	sd	ra,56(sp)
    80003d4a:	f822                	sd	s0,48(sp)
    80003d4c:	f426                	sd	s1,40(sp)
    80003d4e:	f04a                	sd	s2,32(sp)
    80003d50:	ec4e                	sd	s3,24(sp)
    80003d52:	e852                	sd	s4,16(sp)
    80003d54:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d56:	04451703          	lh	a4,68(a0)
    80003d5a:	4785                	li	a5,1
    80003d5c:	00f71a63          	bne	a4,a5,80003d70 <dirlookup+0x2a>
    80003d60:	892a                	mv	s2,a0
    80003d62:	89ae                	mv	s3,a1
    80003d64:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d66:	457c                	lw	a5,76(a0)
    80003d68:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d6a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d6c:	e79d                	bnez	a5,80003d9a <dirlookup+0x54>
    80003d6e:	a8a5                	j	80003de6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d70:	00005517          	auipc	a0,0x5
    80003d74:	9f850513          	addi	a0,a0,-1544 # 80008768 <syscallname+0x2a8>
    80003d78:	ffffc097          	auipc	ra,0xffffc
    80003d7c:	7fc080e7          	jalr	2044(ra) # 80000574 <panic>
      panic("dirlookup read");
    80003d80:	00005517          	auipc	a0,0x5
    80003d84:	a0050513          	addi	a0,a0,-1536 # 80008780 <syscallname+0x2c0>
    80003d88:	ffffc097          	auipc	ra,0xffffc
    80003d8c:	7ec080e7          	jalr	2028(ra) # 80000574 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d90:	24c1                	addiw	s1,s1,16
    80003d92:	04c92783          	lw	a5,76(s2)
    80003d96:	04f4f763          	bleu	a5,s1,80003de4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d9a:	4741                	li	a4,16
    80003d9c:	86a6                	mv	a3,s1
    80003d9e:	fc040613          	addi	a2,s0,-64
    80003da2:	4581                	li	a1,0
    80003da4:	854a                	mv	a0,s2
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	d76080e7          	jalr	-650(ra) # 80003b1c <readi>
    80003dae:	47c1                	li	a5,16
    80003db0:	fcf518e3          	bne	a0,a5,80003d80 <dirlookup+0x3a>
    if(de.inum == 0)
    80003db4:	fc045783          	lhu	a5,-64(s0)
    80003db8:	dfe1                	beqz	a5,80003d90 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dba:	fc240593          	addi	a1,s0,-62
    80003dbe:	854e                	mv	a0,s3
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	f6c080e7          	jalr	-148(ra) # 80003d2c <namecmp>
    80003dc8:	f561                	bnez	a0,80003d90 <dirlookup+0x4a>
      if(poff)
    80003dca:	000a0463          	beqz	s4,80003dd2 <dirlookup+0x8c>
        *poff = off;
    80003dce:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003dd2:	fc045583          	lhu	a1,-64(s0)
    80003dd6:	00092503          	lw	a0,0(s2)
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	756080e7          	jalr	1878(ra) # 80003530 <iget>
    80003de2:	a011                	j	80003de6 <dirlookup+0xa0>
  return 0;
    80003de4:	4501                	li	a0,0
}
    80003de6:	70e2                	ld	ra,56(sp)
    80003de8:	7442                	ld	s0,48(sp)
    80003dea:	74a2                	ld	s1,40(sp)
    80003dec:	7902                	ld	s2,32(sp)
    80003dee:	69e2                	ld	s3,24(sp)
    80003df0:	6a42                	ld	s4,16(sp)
    80003df2:	6121                	addi	sp,sp,64
    80003df4:	8082                	ret

0000000080003df6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003df6:	711d                	addi	sp,sp,-96
    80003df8:	ec86                	sd	ra,88(sp)
    80003dfa:	e8a2                	sd	s0,80(sp)
    80003dfc:	e4a6                	sd	s1,72(sp)
    80003dfe:	e0ca                	sd	s2,64(sp)
    80003e00:	fc4e                	sd	s3,56(sp)
    80003e02:	f852                	sd	s4,48(sp)
    80003e04:	f456                	sd	s5,40(sp)
    80003e06:	f05a                	sd	s6,32(sp)
    80003e08:	ec5e                	sd	s7,24(sp)
    80003e0a:	e862                	sd	s8,16(sp)
    80003e0c:	e466                	sd	s9,8(sp)
    80003e0e:	1080                	addi	s0,sp,96
    80003e10:	84aa                	mv	s1,a0
    80003e12:	8bae                	mv	s7,a1
    80003e14:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e16:	00054703          	lbu	a4,0(a0)
    80003e1a:	02f00793          	li	a5,47
    80003e1e:	02f70363          	beq	a4,a5,80003e44 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e22:	ffffe097          	auipc	ra,0xffffe
    80003e26:	c98080e7          	jalr	-872(ra) # 80001aba <myproc>
    80003e2a:	15053503          	ld	a0,336(a0)
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	9fa080e7          	jalr	-1542(ra) # 80003828 <idup>
    80003e36:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e38:	02f00913          	li	s2,47
  len = path - s;
    80003e3c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e3e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e40:	4c05                	li	s8,1
    80003e42:	a865                	j	80003efa <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e44:	4585                	li	a1,1
    80003e46:	4505                	li	a0,1
    80003e48:	fffff097          	auipc	ra,0xfffff
    80003e4c:	6e8080e7          	jalr	1768(ra) # 80003530 <iget>
    80003e50:	89aa                	mv	s3,a0
    80003e52:	b7dd                	j	80003e38 <namex+0x42>
      iunlockput(ip);
    80003e54:	854e                	mv	a0,s3
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	c74080e7          	jalr	-908(ra) # 80003aca <iunlockput>
      return 0;
    80003e5e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e60:	854e                	mv	a0,s3
    80003e62:	60e6                	ld	ra,88(sp)
    80003e64:	6446                	ld	s0,80(sp)
    80003e66:	64a6                	ld	s1,72(sp)
    80003e68:	6906                	ld	s2,64(sp)
    80003e6a:	79e2                	ld	s3,56(sp)
    80003e6c:	7a42                	ld	s4,48(sp)
    80003e6e:	7aa2                	ld	s5,40(sp)
    80003e70:	7b02                	ld	s6,32(sp)
    80003e72:	6be2                	ld	s7,24(sp)
    80003e74:	6c42                	ld	s8,16(sp)
    80003e76:	6ca2                	ld	s9,8(sp)
    80003e78:	6125                	addi	sp,sp,96
    80003e7a:	8082                	ret
      iunlock(ip);
    80003e7c:	854e                	mv	a0,s3
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	aac080e7          	jalr	-1364(ra) # 8000392a <iunlock>
      return ip;
    80003e86:	bfe9                	j	80003e60 <namex+0x6a>
      iunlockput(ip);
    80003e88:	854e                	mv	a0,s3
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	c40080e7          	jalr	-960(ra) # 80003aca <iunlockput>
      return 0;
    80003e92:	89d2                	mv	s3,s4
    80003e94:	b7f1                	j	80003e60 <namex+0x6a>
  len = path - s;
    80003e96:	40b48633          	sub	a2,s1,a1
    80003e9a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e9e:	094cd663          	ble	s4,s9,80003f2a <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003ea2:	4639                	li	a2,14
    80003ea4:	8556                	mv	a0,s5
    80003ea6:	ffffd097          	auipc	ra,0xffffd
    80003eaa:	f6e080e7          	jalr	-146(ra) # 80000e14 <memmove>
  while(*path == '/')
    80003eae:	0004c783          	lbu	a5,0(s1)
    80003eb2:	01279763          	bne	a5,s2,80003ec0 <namex+0xca>
    path++;
    80003eb6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eb8:	0004c783          	lbu	a5,0(s1)
    80003ebc:	ff278de3          	beq	a5,s2,80003eb6 <namex+0xc0>
    ilock(ip);
    80003ec0:	854e                	mv	a0,s3
    80003ec2:	00000097          	auipc	ra,0x0
    80003ec6:	9a4080e7          	jalr	-1628(ra) # 80003866 <ilock>
    if(ip->type != T_DIR){
    80003eca:	04499783          	lh	a5,68(s3)
    80003ece:	f98793e3          	bne	a5,s8,80003e54 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ed2:	000b8563          	beqz	s7,80003edc <namex+0xe6>
    80003ed6:	0004c783          	lbu	a5,0(s1)
    80003eda:	d3cd                	beqz	a5,80003e7c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003edc:	865a                	mv	a2,s6
    80003ede:	85d6                	mv	a1,s5
    80003ee0:	854e                	mv	a0,s3
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	e64080e7          	jalr	-412(ra) # 80003d46 <dirlookup>
    80003eea:	8a2a                	mv	s4,a0
    80003eec:	dd51                	beqz	a0,80003e88 <namex+0x92>
    iunlockput(ip);
    80003eee:	854e                	mv	a0,s3
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	bda080e7          	jalr	-1062(ra) # 80003aca <iunlockput>
    ip = next;
    80003ef8:	89d2                	mv	s3,s4
  while(*path == '/')
    80003efa:	0004c783          	lbu	a5,0(s1)
    80003efe:	05279d63          	bne	a5,s2,80003f58 <namex+0x162>
    path++;
    80003f02:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f04:	0004c783          	lbu	a5,0(s1)
    80003f08:	ff278de3          	beq	a5,s2,80003f02 <namex+0x10c>
  if(*path == 0)
    80003f0c:	cf8d                	beqz	a5,80003f46 <namex+0x150>
  while(*path != '/' && *path != 0)
    80003f0e:	01278b63          	beq	a5,s2,80003f24 <namex+0x12e>
    80003f12:	c795                	beqz	a5,80003f3e <namex+0x148>
    path++;
    80003f14:	85a6                	mv	a1,s1
    path++;
    80003f16:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f18:	0004c783          	lbu	a5,0(s1)
    80003f1c:	f7278de3          	beq	a5,s2,80003e96 <namex+0xa0>
    80003f20:	fbfd                	bnez	a5,80003f16 <namex+0x120>
    80003f22:	bf95                	j	80003e96 <namex+0xa0>
    80003f24:	85a6                	mv	a1,s1
  len = path - s;
    80003f26:	8a5a                	mv	s4,s6
    80003f28:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003f2a:	2601                	sext.w	a2,a2
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	ffffd097          	auipc	ra,0xffffd
    80003f32:	ee6080e7          	jalr	-282(ra) # 80000e14 <memmove>
    name[len] = 0;
    80003f36:	9a56                	add	s4,s4,s5
    80003f38:	000a0023          	sb	zero,0(s4)
    80003f3c:	bf8d                	j	80003eae <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003f3e:	85a6                	mv	a1,s1
  len = path - s;
    80003f40:	8a5a                	mv	s4,s6
    80003f42:	865a                	mv	a2,s6
    80003f44:	b7dd                	j	80003f2a <namex+0x134>
  if(nameiparent){
    80003f46:	f00b8de3          	beqz	s7,80003e60 <namex+0x6a>
    iput(ip);
    80003f4a:	854e                	mv	a0,s3
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	ad6080e7          	jalr	-1322(ra) # 80003a22 <iput>
    return 0;
    80003f54:	4981                	li	s3,0
    80003f56:	b729                	j	80003e60 <namex+0x6a>
  if(*path == 0)
    80003f58:	d7fd                	beqz	a5,80003f46 <namex+0x150>
    80003f5a:	85a6                	mv	a1,s1
    80003f5c:	bf6d                	j	80003f16 <namex+0x120>

0000000080003f5e <dirlink>:
{
    80003f5e:	7139                	addi	sp,sp,-64
    80003f60:	fc06                	sd	ra,56(sp)
    80003f62:	f822                	sd	s0,48(sp)
    80003f64:	f426                	sd	s1,40(sp)
    80003f66:	f04a                	sd	s2,32(sp)
    80003f68:	ec4e                	sd	s3,24(sp)
    80003f6a:	e852                	sd	s4,16(sp)
    80003f6c:	0080                	addi	s0,sp,64
    80003f6e:	892a                	mv	s2,a0
    80003f70:	8a2e                	mv	s4,a1
    80003f72:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f74:	4601                	li	a2,0
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	dd0080e7          	jalr	-560(ra) # 80003d46 <dirlookup>
    80003f7e:	e93d                	bnez	a0,80003ff4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f80:	04c92483          	lw	s1,76(s2)
    80003f84:	c49d                	beqz	s1,80003fb2 <dirlink+0x54>
    80003f86:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f88:	4741                	li	a4,16
    80003f8a:	86a6                	mv	a3,s1
    80003f8c:	fc040613          	addi	a2,s0,-64
    80003f90:	4581                	li	a1,0
    80003f92:	854a                	mv	a0,s2
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	b88080e7          	jalr	-1144(ra) # 80003b1c <readi>
    80003f9c:	47c1                	li	a5,16
    80003f9e:	06f51163          	bne	a0,a5,80004000 <dirlink+0xa2>
    if(de.inum == 0)
    80003fa2:	fc045783          	lhu	a5,-64(s0)
    80003fa6:	c791                	beqz	a5,80003fb2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fa8:	24c1                	addiw	s1,s1,16
    80003faa:	04c92783          	lw	a5,76(s2)
    80003fae:	fcf4ede3          	bltu	s1,a5,80003f88 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fb2:	4639                	li	a2,14
    80003fb4:	85d2                	mv	a1,s4
    80003fb6:	fc240513          	addi	a0,s0,-62
    80003fba:	ffffd097          	auipc	ra,0xffffd
    80003fbe:	f26080e7          	jalr	-218(ra) # 80000ee0 <strncpy>
  de.inum = inum;
    80003fc2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc6:	4741                	li	a4,16
    80003fc8:	86a6                	mv	a3,s1
    80003fca:	fc040613          	addi	a2,s0,-64
    80003fce:	4581                	li	a1,0
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	c40080e7          	jalr	-960(ra) # 80003c12 <writei>
    80003fda:	4741                	li	a4,16
  return 0;
    80003fdc:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fde:	02e51963          	bne	a0,a4,80004010 <dirlink+0xb2>
}
    80003fe2:	853e                	mv	a0,a5
    80003fe4:	70e2                	ld	ra,56(sp)
    80003fe6:	7442                	ld	s0,48(sp)
    80003fe8:	74a2                	ld	s1,40(sp)
    80003fea:	7902                	ld	s2,32(sp)
    80003fec:	69e2                	ld	s3,24(sp)
    80003fee:	6a42                	ld	s4,16(sp)
    80003ff0:	6121                	addi	sp,sp,64
    80003ff2:	8082                	ret
    iput(ip);
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	a2e080e7          	jalr	-1490(ra) # 80003a22 <iput>
    return -1;
    80003ffc:	57fd                	li	a5,-1
    80003ffe:	b7d5                	j	80003fe2 <dirlink+0x84>
      panic("dirlink read");
    80004000:	00004517          	auipc	a0,0x4
    80004004:	79050513          	addi	a0,a0,1936 # 80008790 <syscallname+0x2d0>
    80004008:	ffffc097          	auipc	ra,0xffffc
    8000400c:	56c080e7          	jalr	1388(ra) # 80000574 <panic>
    panic("dirlink");
    80004010:	00005517          	auipc	a0,0x5
    80004014:	89850513          	addi	a0,a0,-1896 # 800088a8 <syscallname+0x3e8>
    80004018:	ffffc097          	auipc	ra,0xffffc
    8000401c:	55c080e7          	jalr	1372(ra) # 80000574 <panic>

0000000080004020 <namei>:

struct inode*
namei(char *path)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004028:	fe040613          	addi	a2,s0,-32
    8000402c:	4581                	li	a1,0
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	dc8080e7          	jalr	-568(ra) # 80003df6 <namex>
}
    80004036:	60e2                	ld	ra,24(sp)
    80004038:	6442                	ld	s0,16(sp)
    8000403a:	6105                	addi	sp,sp,32
    8000403c:	8082                	ret

000000008000403e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000403e:	1141                	addi	sp,sp,-16
    80004040:	e406                	sd	ra,8(sp)
    80004042:	e022                	sd	s0,0(sp)
    80004044:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    80004046:	862e                	mv	a2,a1
    80004048:	4585                	li	a1,1
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	dac080e7          	jalr	-596(ra) # 80003df6 <namex>
}
    80004052:	60a2                	ld	ra,8(sp)
    80004054:	6402                	ld	s0,0(sp)
    80004056:	0141                	addi	sp,sp,16
    80004058:	8082                	ret

000000008000405a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000405a:	1101                	addi	sp,sp,-32
    8000405c:	ec06                	sd	ra,24(sp)
    8000405e:	e822                	sd	s0,16(sp)
    80004060:	e426                	sd	s1,8(sp)
    80004062:	e04a                	sd	s2,0(sp)
    80004064:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004066:	0001e917          	auipc	s2,0x1e
    8000406a:	aa290913          	addi	s2,s2,-1374 # 80021b08 <log>
    8000406e:	01892583          	lw	a1,24(s2)
    80004072:	02892503          	lw	a0,40(s2)
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	fa8080e7          	jalr	-88(ra) # 8000301e <bread>
    8000407e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004080:	02c92683          	lw	a3,44(s2)
    80004084:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004086:	02d05763          	blez	a3,800040b4 <write_head+0x5a>
    8000408a:	0001e797          	auipc	a5,0x1e
    8000408e:	aae78793          	addi	a5,a5,-1362 # 80021b38 <log+0x30>
    80004092:	05c50713          	addi	a4,a0,92
    80004096:	36fd                	addiw	a3,a3,-1
    80004098:	1682                	slli	a3,a3,0x20
    8000409a:	9281                	srli	a3,a3,0x20
    8000409c:	068a                	slli	a3,a3,0x2
    8000409e:	0001e617          	auipc	a2,0x1e
    800040a2:	a9e60613          	addi	a2,a2,-1378 # 80021b3c <log+0x34>
    800040a6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040a8:	4390                	lw	a2,0(a5)
    800040aa:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	0791                	addi	a5,a5,4
    800040ae:	0711                	addi	a4,a4,4
    800040b0:	fed79ce3          	bne	a5,a3,800040a8 <write_head+0x4e>
  }
  bwrite(buf);
    800040b4:	8526                	mv	a0,s1
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	06c080e7          	jalr	108(ra) # 80003122 <bwrite>
  brelse(buf);
    800040be:	8526                	mv	a0,s1
    800040c0:	fffff097          	auipc	ra,0xfffff
    800040c4:	0a0080e7          	jalr	160(ra) # 80003160 <brelse>
}
    800040c8:	60e2                	ld	ra,24(sp)
    800040ca:	6442                	ld	s0,16(sp)
    800040cc:	64a2                	ld	s1,8(sp)
    800040ce:	6902                	ld	s2,0(sp)
    800040d0:	6105                	addi	sp,sp,32
    800040d2:	8082                	ret

00000000800040d4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d4:	0001e797          	auipc	a5,0x1e
    800040d8:	a3478793          	addi	a5,a5,-1484 # 80021b08 <log>
    800040dc:	57dc                	lw	a5,44(a5)
    800040de:	0af05663          	blez	a5,8000418a <install_trans+0xb6>
{
    800040e2:	7139                	addi	sp,sp,-64
    800040e4:	fc06                	sd	ra,56(sp)
    800040e6:	f822                	sd	s0,48(sp)
    800040e8:	f426                	sd	s1,40(sp)
    800040ea:	f04a                	sd	s2,32(sp)
    800040ec:	ec4e                	sd	s3,24(sp)
    800040ee:	e852                	sd	s4,16(sp)
    800040f0:	e456                	sd	s5,8(sp)
    800040f2:	0080                	addi	s0,sp,64
    800040f4:	0001ea17          	auipc	s4,0x1e
    800040f8:	a44a0a13          	addi	s4,s4,-1468 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fc:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040fe:	0001e917          	auipc	s2,0x1e
    80004102:	a0a90913          	addi	s2,s2,-1526 # 80021b08 <log>
    80004106:	01892583          	lw	a1,24(s2)
    8000410a:	013585bb          	addw	a1,a1,s3
    8000410e:	2585                	addiw	a1,a1,1
    80004110:	02892503          	lw	a0,40(s2)
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	f0a080e7          	jalr	-246(ra) # 8000301e <bread>
    8000411c:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000411e:	000a2583          	lw	a1,0(s4)
    80004122:	02892503          	lw	a0,40(s2)
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	ef8080e7          	jalr	-264(ra) # 8000301e <bread>
    8000412e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004130:	40000613          	li	a2,1024
    80004134:	058a8593          	addi	a1,s5,88
    80004138:	05850513          	addi	a0,a0,88
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	cd8080e7          	jalr	-808(ra) # 80000e14 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004144:	8526                	mv	a0,s1
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	fdc080e7          	jalr	-36(ra) # 80003122 <bwrite>
    bunpin(dbuf);
    8000414e:	8526                	mv	a0,s1
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	0ea080e7          	jalr	234(ra) # 8000323a <bunpin>
    brelse(lbuf);
    80004158:	8556                	mv	a0,s5
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	006080e7          	jalr	6(ra) # 80003160 <brelse>
    brelse(dbuf);
    80004162:	8526                	mv	a0,s1
    80004164:	fffff097          	auipc	ra,0xfffff
    80004168:	ffc080e7          	jalr	-4(ra) # 80003160 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416c:	2985                	addiw	s3,s3,1
    8000416e:	0a11                	addi	s4,s4,4
    80004170:	02c92783          	lw	a5,44(s2)
    80004174:	f8f9c9e3          	blt	s3,a5,80004106 <install_trans+0x32>
}
    80004178:	70e2                	ld	ra,56(sp)
    8000417a:	7442                	ld	s0,48(sp)
    8000417c:	74a2                	ld	s1,40(sp)
    8000417e:	7902                	ld	s2,32(sp)
    80004180:	69e2                	ld	s3,24(sp)
    80004182:	6a42                	ld	s4,16(sp)
    80004184:	6aa2                	ld	s5,8(sp)
    80004186:	6121                	addi	sp,sp,64
    80004188:	8082                	ret
    8000418a:	8082                	ret

000000008000418c <initlog>:
{
    8000418c:	7179                	addi	sp,sp,-48
    8000418e:	f406                	sd	ra,40(sp)
    80004190:	f022                	sd	s0,32(sp)
    80004192:	ec26                	sd	s1,24(sp)
    80004194:	e84a                	sd	s2,16(sp)
    80004196:	e44e                	sd	s3,8(sp)
    80004198:	1800                	addi	s0,sp,48
    8000419a:	892a                	mv	s2,a0
    8000419c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000419e:	0001e497          	auipc	s1,0x1e
    800041a2:	96a48493          	addi	s1,s1,-1686 # 80021b08 <log>
    800041a6:	00004597          	auipc	a1,0x4
    800041aa:	5fa58593          	addi	a1,a1,1530 # 800087a0 <syscallname+0x2e0>
    800041ae:	8526                	mv	a0,s1
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	a6c080e7          	jalr	-1428(ra) # 80000c1c <initlock>
  log.start = sb->logstart;
    800041b8:	0149a583          	lw	a1,20(s3)
    800041bc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041be:	0109a783          	lw	a5,16(s3)
    800041c2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041c4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041c8:	854a                	mv	a0,s2
    800041ca:	fffff097          	auipc	ra,0xfffff
    800041ce:	e54080e7          	jalr	-428(ra) # 8000301e <bread>
  log.lh.n = lh->n;
    800041d2:	4d3c                	lw	a5,88(a0)
    800041d4:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041d6:	02f05563          	blez	a5,80004200 <initlog+0x74>
    800041da:	05c50713          	addi	a4,a0,92
    800041de:	0001e697          	auipc	a3,0x1e
    800041e2:	95a68693          	addi	a3,a3,-1702 # 80021b38 <log+0x30>
    800041e6:	37fd                	addiw	a5,a5,-1
    800041e8:	1782                	slli	a5,a5,0x20
    800041ea:	9381                	srli	a5,a5,0x20
    800041ec:	078a                	slli	a5,a5,0x2
    800041ee:	06050613          	addi	a2,a0,96
    800041f2:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041f4:	4310                	lw	a2,0(a4)
    800041f6:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800041f8:	0711                	addi	a4,a4,4
    800041fa:	0691                	addi	a3,a3,4
    800041fc:	fef71ce3          	bne	a4,a5,800041f4 <initlog+0x68>
  brelse(buf);
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	f60080e7          	jalr	-160(ra) # 80003160 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	ecc080e7          	jalr	-308(ra) # 800040d4 <install_trans>
  log.lh.n = 0;
    80004210:	0001e797          	auipc	a5,0x1e
    80004214:	9207a223          	sw	zero,-1756(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	e42080e7          	jalr	-446(ra) # 8000405a <write_head>
}
    80004220:	70a2                	ld	ra,40(sp)
    80004222:	7402                	ld	s0,32(sp)
    80004224:	64e2                	ld	s1,24(sp)
    80004226:	6942                	ld	s2,16(sp)
    80004228:	69a2                	ld	s3,8(sp)
    8000422a:	6145                	addi	sp,sp,48
    8000422c:	8082                	ret

000000008000422e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000422e:	1101                	addi	sp,sp,-32
    80004230:	ec06                	sd	ra,24(sp)
    80004232:	e822                	sd	s0,16(sp)
    80004234:	e426                	sd	s1,8(sp)
    80004236:	e04a                	sd	s2,0(sp)
    80004238:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000423a:	0001e517          	auipc	a0,0x1e
    8000423e:	8ce50513          	addi	a0,a0,-1842 # 80021b08 <log>
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	a6a080e7          	jalr	-1430(ra) # 80000cac <acquire>
  while(1){
    if(log.committing){
    8000424a:	0001e497          	auipc	s1,0x1e
    8000424e:	8be48493          	addi	s1,s1,-1858 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004252:	4979                	li	s2,30
    80004254:	a039                	j	80004262 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004256:	85a6                	mv	a1,s1
    80004258:	8526                	mv	a0,s1
    8000425a:	ffffe097          	auipc	ra,0xffffe
    8000425e:	07e080e7          	jalr	126(ra) # 800022d8 <sleep>
    if(log.committing){
    80004262:	50dc                	lw	a5,36(s1)
    80004264:	fbed                	bnez	a5,80004256 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004266:	509c                	lw	a5,32(s1)
    80004268:	0017871b          	addiw	a4,a5,1
    8000426c:	0007069b          	sext.w	a3,a4
    80004270:	0027179b          	slliw	a5,a4,0x2
    80004274:	9fb9                	addw	a5,a5,a4
    80004276:	0017979b          	slliw	a5,a5,0x1
    8000427a:	54d8                	lw	a4,44(s1)
    8000427c:	9fb9                	addw	a5,a5,a4
    8000427e:	00f95963          	ble	a5,s2,80004290 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004282:	85a6                	mv	a1,s1
    80004284:	8526                	mv	a0,s1
    80004286:	ffffe097          	auipc	ra,0xffffe
    8000428a:	052080e7          	jalr	82(ra) # 800022d8 <sleep>
    8000428e:	bfd1                	j	80004262 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004290:	0001e517          	auipc	a0,0x1e
    80004294:	87850513          	addi	a0,a0,-1928 # 80021b08 <log>
    80004298:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000429a:	ffffd097          	auipc	ra,0xffffd
    8000429e:	ac6080e7          	jalr	-1338(ra) # 80000d60 <release>
      break;
    }
  }
}
    800042a2:	60e2                	ld	ra,24(sp)
    800042a4:	6442                	ld	s0,16(sp)
    800042a6:	64a2                	ld	s1,8(sp)
    800042a8:	6902                	ld	s2,0(sp)
    800042aa:	6105                	addi	sp,sp,32
    800042ac:	8082                	ret

00000000800042ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042ae:	7139                	addi	sp,sp,-64
    800042b0:	fc06                	sd	ra,56(sp)
    800042b2:	f822                	sd	s0,48(sp)
    800042b4:	f426                	sd	s1,40(sp)
    800042b6:	f04a                	sd	s2,32(sp)
    800042b8:	ec4e                	sd	s3,24(sp)
    800042ba:	e852                	sd	s4,16(sp)
    800042bc:	e456                	sd	s5,8(sp)
    800042be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042c0:	0001e917          	auipc	s2,0x1e
    800042c4:	84890913          	addi	s2,s2,-1976 # 80021b08 <log>
    800042c8:	854a                	mv	a0,s2
    800042ca:	ffffd097          	auipc	ra,0xffffd
    800042ce:	9e2080e7          	jalr	-1566(ra) # 80000cac <acquire>
  log.outstanding -= 1;
    800042d2:	02092783          	lw	a5,32(s2)
    800042d6:	37fd                	addiw	a5,a5,-1
    800042d8:	0007849b          	sext.w	s1,a5
    800042dc:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800042e0:	02492783          	lw	a5,36(s2)
    800042e4:	eba1                	bnez	a5,80004334 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800042e6:	ecb9                	bnez	s1,80004344 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800042e8:	0001e917          	auipc	s2,0x1e
    800042ec:	82090913          	addi	s2,s2,-2016 # 80021b08 <log>
    800042f0:	4785                	li	a5,1
    800042f2:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042f6:	854a                	mv	a0,s2
    800042f8:	ffffd097          	auipc	ra,0xffffd
    800042fc:	a68080e7          	jalr	-1432(ra) # 80000d60 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004300:	02c92783          	lw	a5,44(s2)
    80004304:	06f04763          	bgtz	a5,80004372 <end_op+0xc4>
    acquire(&log.lock);
    80004308:	0001e497          	auipc	s1,0x1e
    8000430c:	80048493          	addi	s1,s1,-2048 # 80021b08 <log>
    80004310:	8526                	mv	a0,s1
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	99a080e7          	jalr	-1638(ra) # 80000cac <acquire>
    log.committing = 0;
    8000431a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffe097          	auipc	ra,0xffffe
    80004324:	13e080e7          	jalr	318(ra) # 8000245e <wakeup>
    release(&log.lock);
    80004328:	8526                	mv	a0,s1
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	a36080e7          	jalr	-1482(ra) # 80000d60 <release>
}
    80004332:	a03d                	j	80004360 <end_op+0xb2>
    panic("log.committing");
    80004334:	00004517          	auipc	a0,0x4
    80004338:	47450513          	addi	a0,a0,1140 # 800087a8 <syscallname+0x2e8>
    8000433c:	ffffc097          	auipc	ra,0xffffc
    80004340:	238080e7          	jalr	568(ra) # 80000574 <panic>
    wakeup(&log);
    80004344:	0001d497          	auipc	s1,0x1d
    80004348:	7c448493          	addi	s1,s1,1988 # 80021b08 <log>
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffe097          	auipc	ra,0xffffe
    80004352:	110080e7          	jalr	272(ra) # 8000245e <wakeup>
  release(&log.lock);
    80004356:	8526                	mv	a0,s1
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	a08080e7          	jalr	-1528(ra) # 80000d60 <release>
}
    80004360:	70e2                	ld	ra,56(sp)
    80004362:	7442                	ld	s0,48(sp)
    80004364:	74a2                	ld	s1,40(sp)
    80004366:	7902                	ld	s2,32(sp)
    80004368:	69e2                	ld	s3,24(sp)
    8000436a:	6a42                	ld	s4,16(sp)
    8000436c:	6aa2                	ld	s5,8(sp)
    8000436e:	6121                	addi	sp,sp,64
    80004370:	8082                	ret
    80004372:	0001da17          	auipc	s4,0x1d
    80004376:	7c6a0a13          	addi	s4,s4,1990 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000437a:	0001d917          	auipc	s2,0x1d
    8000437e:	78e90913          	addi	s2,s2,1934 # 80021b08 <log>
    80004382:	01892583          	lw	a1,24(s2)
    80004386:	9da5                	addw	a1,a1,s1
    80004388:	2585                	addiw	a1,a1,1
    8000438a:	02892503          	lw	a0,40(s2)
    8000438e:	fffff097          	auipc	ra,0xfffff
    80004392:	c90080e7          	jalr	-880(ra) # 8000301e <bread>
    80004396:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004398:	000a2583          	lw	a1,0(s4)
    8000439c:	02892503          	lw	a0,40(s2)
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	c7e080e7          	jalr	-898(ra) # 8000301e <bread>
    800043a8:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800043aa:	40000613          	li	a2,1024
    800043ae:	05850593          	addi	a1,a0,88
    800043b2:	05898513          	addi	a0,s3,88
    800043b6:	ffffd097          	auipc	ra,0xffffd
    800043ba:	a5e080e7          	jalr	-1442(ra) # 80000e14 <memmove>
    bwrite(to);  // write the log
    800043be:	854e                	mv	a0,s3
    800043c0:	fffff097          	auipc	ra,0xfffff
    800043c4:	d62080e7          	jalr	-670(ra) # 80003122 <bwrite>
    brelse(from);
    800043c8:	8556                	mv	a0,s5
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	d96080e7          	jalr	-618(ra) # 80003160 <brelse>
    brelse(to);
    800043d2:	854e                	mv	a0,s3
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	d8c080e7          	jalr	-628(ra) # 80003160 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043dc:	2485                	addiw	s1,s1,1
    800043de:	0a11                	addi	s4,s4,4
    800043e0:	02c92783          	lw	a5,44(s2)
    800043e4:	f8f4cfe3          	blt	s1,a5,80004382 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043e8:	00000097          	auipc	ra,0x0
    800043ec:	c72080e7          	jalr	-910(ra) # 8000405a <write_head>
    install_trans(); // Now install writes to home locations
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	ce4080e7          	jalr	-796(ra) # 800040d4 <install_trans>
    log.lh.n = 0;
    800043f8:	0001d797          	auipc	a5,0x1d
    800043fc:	7207ae23          	sw	zero,1852(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004400:	00000097          	auipc	ra,0x0
    80004404:	c5a080e7          	jalr	-934(ra) # 8000405a <write_head>
    80004408:	b701                	j	80004308 <end_op+0x5a>

000000008000440a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000440a:	1101                	addi	sp,sp,-32
    8000440c:	ec06                	sd	ra,24(sp)
    8000440e:	e822                	sd	s0,16(sp)
    80004410:	e426                	sd	s1,8(sp)
    80004412:	e04a                	sd	s2,0(sp)
    80004414:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004416:	0001d797          	auipc	a5,0x1d
    8000441a:	6f278793          	addi	a5,a5,1778 # 80021b08 <log>
    8000441e:	57d8                	lw	a4,44(a5)
    80004420:	47f5                	li	a5,29
    80004422:	08e7c563          	blt	a5,a4,800044ac <log_write+0xa2>
    80004426:	892a                	mv	s2,a0
    80004428:	0001d797          	auipc	a5,0x1d
    8000442c:	6e078793          	addi	a5,a5,1760 # 80021b08 <log>
    80004430:	4fdc                	lw	a5,28(a5)
    80004432:	37fd                	addiw	a5,a5,-1
    80004434:	06f75c63          	ble	a5,a4,800044ac <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004438:	0001d797          	auipc	a5,0x1d
    8000443c:	6d078793          	addi	a5,a5,1744 # 80021b08 <log>
    80004440:	539c                	lw	a5,32(a5)
    80004442:	06f05d63          	blez	a5,800044bc <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004446:	0001d497          	auipc	s1,0x1d
    8000444a:	6c248493          	addi	s1,s1,1730 # 80021b08 <log>
    8000444e:	8526                	mv	a0,s1
    80004450:	ffffd097          	auipc	ra,0xffffd
    80004454:	85c080e7          	jalr	-1956(ra) # 80000cac <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004458:	54d0                	lw	a2,44(s1)
    8000445a:	0ac05063          	blez	a2,800044fa <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000445e:	00c92583          	lw	a1,12(s2)
    80004462:	589c                	lw	a5,48(s1)
    80004464:	0ab78363          	beq	a5,a1,8000450a <log_write+0x100>
    80004468:	0001d717          	auipc	a4,0x1d
    8000446c:	6d470713          	addi	a4,a4,1748 # 80021b3c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    80004470:	4781                	li	a5,0
    80004472:	2785                	addiw	a5,a5,1
    80004474:	04c78c63          	beq	a5,a2,800044cc <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004478:	4314                	lw	a3,0(a4)
    8000447a:	0711                	addi	a4,a4,4
    8000447c:	feb69be3          	bne	a3,a1,80004472 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004480:	07a1                	addi	a5,a5,8
    80004482:	078a                	slli	a5,a5,0x2
    80004484:	0001d717          	auipc	a4,0x1d
    80004488:	68470713          	addi	a4,a4,1668 # 80021b08 <log>
    8000448c:	97ba                	add	a5,a5,a4
    8000448e:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004490:	0001d517          	auipc	a0,0x1d
    80004494:	67850513          	addi	a0,a0,1656 # 80021b08 <log>
    80004498:	ffffd097          	auipc	ra,0xffffd
    8000449c:	8c8080e7          	jalr	-1848(ra) # 80000d60 <release>
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	64a2                	ld	s1,8(sp)
    800044a6:	6902                	ld	s2,0(sp)
    800044a8:	6105                	addi	sp,sp,32
    800044aa:	8082                	ret
    panic("too big a transaction");
    800044ac:	00004517          	auipc	a0,0x4
    800044b0:	30c50513          	addi	a0,a0,780 # 800087b8 <syscallname+0x2f8>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	0c0080e7          	jalr	192(ra) # 80000574 <panic>
    panic("log_write outside of trans");
    800044bc:	00004517          	auipc	a0,0x4
    800044c0:	31450513          	addi	a0,a0,788 # 800087d0 <syscallname+0x310>
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	0b0080e7          	jalr	176(ra) # 80000574 <panic>
  log.lh.block[i] = b->blockno;
    800044cc:	0621                	addi	a2,a2,8
    800044ce:	060a                	slli	a2,a2,0x2
    800044d0:	0001d797          	auipc	a5,0x1d
    800044d4:	63878793          	addi	a5,a5,1592 # 80021b08 <log>
    800044d8:	963e                	add	a2,a2,a5
    800044da:	00c92783          	lw	a5,12(s2)
    800044de:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800044e0:	854a                	mv	a0,s2
    800044e2:	fffff097          	auipc	ra,0xfffff
    800044e6:	d1c080e7          	jalr	-740(ra) # 800031fe <bpin>
    log.lh.n++;
    800044ea:	0001d717          	auipc	a4,0x1d
    800044ee:	61e70713          	addi	a4,a4,1566 # 80021b08 <log>
    800044f2:	575c                	lw	a5,44(a4)
    800044f4:	2785                	addiw	a5,a5,1
    800044f6:	d75c                	sw	a5,44(a4)
    800044f8:	bf61                	j	80004490 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    800044fa:	00c92783          	lw	a5,12(s2)
    800044fe:	0001d717          	auipc	a4,0x1d
    80004502:	62f72d23          	sw	a5,1594(a4) # 80021b38 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    80004506:	f649                	bnez	a2,80004490 <log_write+0x86>
    80004508:	bfe1                	j	800044e0 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    8000450a:	4781                	li	a5,0
    8000450c:	bf95                	j	80004480 <log_write+0x76>

000000008000450e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000450e:	1101                	addi	sp,sp,-32
    80004510:	ec06                	sd	ra,24(sp)
    80004512:	e822                	sd	s0,16(sp)
    80004514:	e426                	sd	s1,8(sp)
    80004516:	e04a                	sd	s2,0(sp)
    80004518:	1000                	addi	s0,sp,32
    8000451a:	84aa                	mv	s1,a0
    8000451c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000451e:	00004597          	auipc	a1,0x4
    80004522:	2d258593          	addi	a1,a1,722 # 800087f0 <syscallname+0x330>
    80004526:	0521                	addi	a0,a0,8
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	6f4080e7          	jalr	1780(ra) # 80000c1c <initlock>
  lk->name = name;
    80004530:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004534:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004538:	0204a423          	sw	zero,40(s1)
}
    8000453c:	60e2                	ld	ra,24(sp)
    8000453e:	6442                	ld	s0,16(sp)
    80004540:	64a2                	ld	s1,8(sp)
    80004542:	6902                	ld	s2,0(sp)
    80004544:	6105                	addi	sp,sp,32
    80004546:	8082                	ret

0000000080004548 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004548:	1101                	addi	sp,sp,-32
    8000454a:	ec06                	sd	ra,24(sp)
    8000454c:	e822                	sd	s0,16(sp)
    8000454e:	e426                	sd	s1,8(sp)
    80004550:	e04a                	sd	s2,0(sp)
    80004552:	1000                	addi	s0,sp,32
    80004554:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004556:	00850913          	addi	s2,a0,8
    8000455a:	854a                	mv	a0,s2
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	750080e7          	jalr	1872(ra) # 80000cac <acquire>
  while (lk->locked) {
    80004564:	409c                	lw	a5,0(s1)
    80004566:	cb89                	beqz	a5,80004578 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004568:	85ca                	mv	a1,s2
    8000456a:	8526                	mv	a0,s1
    8000456c:	ffffe097          	auipc	ra,0xffffe
    80004570:	d6c080e7          	jalr	-660(ra) # 800022d8 <sleep>
  while (lk->locked) {
    80004574:	409c                	lw	a5,0(s1)
    80004576:	fbed                	bnez	a5,80004568 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004578:	4785                	li	a5,1
    8000457a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	53e080e7          	jalr	1342(ra) # 80001aba <myproc>
    80004584:	5d1c                	lw	a5,56(a0)
    80004586:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004588:	854a                	mv	a0,s2
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	7d6080e7          	jalr	2006(ra) # 80000d60 <release>
}
    80004592:	60e2                	ld	ra,24(sp)
    80004594:	6442                	ld	s0,16(sp)
    80004596:	64a2                	ld	s1,8(sp)
    80004598:	6902                	ld	s2,0(sp)
    8000459a:	6105                	addi	sp,sp,32
    8000459c:	8082                	ret

000000008000459e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000459e:	1101                	addi	sp,sp,-32
    800045a0:	ec06                	sd	ra,24(sp)
    800045a2:	e822                	sd	s0,16(sp)
    800045a4:	e426                	sd	s1,8(sp)
    800045a6:	e04a                	sd	s2,0(sp)
    800045a8:	1000                	addi	s0,sp,32
    800045aa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ac:	00850913          	addi	s2,a0,8
    800045b0:	854a                	mv	a0,s2
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	6fa080e7          	jalr	1786(ra) # 80000cac <acquire>
  lk->locked = 0;
    800045ba:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045be:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045c2:	8526                	mv	a0,s1
    800045c4:	ffffe097          	auipc	ra,0xffffe
    800045c8:	e9a080e7          	jalr	-358(ra) # 8000245e <wakeup>
  release(&lk->lk);
    800045cc:	854a                	mv	a0,s2
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	792080e7          	jalr	1938(ra) # 80000d60 <release>
}
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6902                	ld	s2,0(sp)
    800045de:	6105                	addi	sp,sp,32
    800045e0:	8082                	ret

00000000800045e2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045e2:	7179                	addi	sp,sp,-48
    800045e4:	f406                	sd	ra,40(sp)
    800045e6:	f022                	sd	s0,32(sp)
    800045e8:	ec26                	sd	s1,24(sp)
    800045ea:	e84a                	sd	s2,16(sp)
    800045ec:	e44e                	sd	s3,8(sp)
    800045ee:	1800                	addi	s0,sp,48
    800045f0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045f2:	00850913          	addi	s2,a0,8
    800045f6:	854a                	mv	a0,s2
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	6b4080e7          	jalr	1716(ra) # 80000cac <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004600:	409c                	lw	a5,0(s1)
    80004602:	ef99                	bnez	a5,80004620 <holdingsleep+0x3e>
    80004604:	4481                	li	s1,0
  release(&lk->lk);
    80004606:	854a                	mv	a0,s2
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	758080e7          	jalr	1880(ra) # 80000d60 <release>
  return r;
}
    80004610:	8526                	mv	a0,s1
    80004612:	70a2                	ld	ra,40(sp)
    80004614:	7402                	ld	s0,32(sp)
    80004616:	64e2                	ld	s1,24(sp)
    80004618:	6942                	ld	s2,16(sp)
    8000461a:	69a2                	ld	s3,8(sp)
    8000461c:	6145                	addi	sp,sp,48
    8000461e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004620:	0284a983          	lw	s3,40(s1)
    80004624:	ffffd097          	auipc	ra,0xffffd
    80004628:	496080e7          	jalr	1174(ra) # 80001aba <myproc>
    8000462c:	5d04                	lw	s1,56(a0)
    8000462e:	413484b3          	sub	s1,s1,s3
    80004632:	0014b493          	seqz	s1,s1
    80004636:	bfc1                	j	80004606 <holdingsleep+0x24>

0000000080004638 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004638:	1141                	addi	sp,sp,-16
    8000463a:	e406                	sd	ra,8(sp)
    8000463c:	e022                	sd	s0,0(sp)
    8000463e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004640:	00004597          	auipc	a1,0x4
    80004644:	1c058593          	addi	a1,a1,448 # 80008800 <syscallname+0x340>
    80004648:	0001d517          	auipc	a0,0x1d
    8000464c:	60850513          	addi	a0,a0,1544 # 80021c50 <ftable>
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	5cc080e7          	jalr	1484(ra) # 80000c1c <initlock>
}
    80004658:	60a2                	ld	ra,8(sp)
    8000465a:	6402                	ld	s0,0(sp)
    8000465c:	0141                	addi	sp,sp,16
    8000465e:	8082                	ret

0000000080004660 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004660:	1101                	addi	sp,sp,-32
    80004662:	ec06                	sd	ra,24(sp)
    80004664:	e822                	sd	s0,16(sp)
    80004666:	e426                	sd	s1,8(sp)
    80004668:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000466a:	0001d517          	auipc	a0,0x1d
    8000466e:	5e650513          	addi	a0,a0,1510 # 80021c50 <ftable>
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	63a080e7          	jalr	1594(ra) # 80000cac <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    8000467a:	0001d797          	auipc	a5,0x1d
    8000467e:	5d678793          	addi	a5,a5,1494 # 80021c50 <ftable>
    80004682:	4fdc                	lw	a5,28(a5)
    80004684:	cb8d                	beqz	a5,800046b6 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004686:	0001d497          	auipc	s1,0x1d
    8000468a:	60a48493          	addi	s1,s1,1546 # 80021c90 <ftable+0x40>
    8000468e:	0001e717          	auipc	a4,0x1e
    80004692:	57a70713          	addi	a4,a4,1402 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    80004696:	40dc                	lw	a5,4(s1)
    80004698:	c39d                	beqz	a5,800046be <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000469a:	02848493          	addi	s1,s1,40
    8000469e:	fee49ce3          	bne	s1,a4,80004696 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046a2:	0001d517          	auipc	a0,0x1d
    800046a6:	5ae50513          	addi	a0,a0,1454 # 80021c50 <ftable>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	6b6080e7          	jalr	1718(ra) # 80000d60 <release>
  return 0;
    800046b2:	4481                	li	s1,0
    800046b4:	a839                	j	800046d2 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046b6:	0001d497          	auipc	s1,0x1d
    800046ba:	5b248493          	addi	s1,s1,1458 # 80021c68 <ftable+0x18>
      f->ref = 1;
    800046be:	4785                	li	a5,1
    800046c0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046c2:	0001d517          	auipc	a0,0x1d
    800046c6:	58e50513          	addi	a0,a0,1422 # 80021c50 <ftable>
    800046ca:	ffffc097          	auipc	ra,0xffffc
    800046ce:	696080e7          	jalr	1686(ra) # 80000d60 <release>
}
    800046d2:	8526                	mv	a0,s1
    800046d4:	60e2                	ld	ra,24(sp)
    800046d6:	6442                	ld	s0,16(sp)
    800046d8:	64a2                	ld	s1,8(sp)
    800046da:	6105                	addi	sp,sp,32
    800046dc:	8082                	ret

00000000800046de <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046de:	1101                	addi	sp,sp,-32
    800046e0:	ec06                	sd	ra,24(sp)
    800046e2:	e822                	sd	s0,16(sp)
    800046e4:	e426                	sd	s1,8(sp)
    800046e6:	1000                	addi	s0,sp,32
    800046e8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046ea:	0001d517          	auipc	a0,0x1d
    800046ee:	56650513          	addi	a0,a0,1382 # 80021c50 <ftable>
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	5ba080e7          	jalr	1466(ra) # 80000cac <acquire>
  if(f->ref < 1)
    800046fa:	40dc                	lw	a5,4(s1)
    800046fc:	02f05263          	blez	a5,80004720 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004700:	2785                	addiw	a5,a5,1
    80004702:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004704:	0001d517          	auipc	a0,0x1d
    80004708:	54c50513          	addi	a0,a0,1356 # 80021c50 <ftable>
    8000470c:	ffffc097          	auipc	ra,0xffffc
    80004710:	654080e7          	jalr	1620(ra) # 80000d60 <release>
  return f;
}
    80004714:	8526                	mv	a0,s1
    80004716:	60e2                	ld	ra,24(sp)
    80004718:	6442                	ld	s0,16(sp)
    8000471a:	64a2                	ld	s1,8(sp)
    8000471c:	6105                	addi	sp,sp,32
    8000471e:	8082                	ret
    panic("filedup");
    80004720:	00004517          	auipc	a0,0x4
    80004724:	0e850513          	addi	a0,a0,232 # 80008808 <syscallname+0x348>
    80004728:	ffffc097          	auipc	ra,0xffffc
    8000472c:	e4c080e7          	jalr	-436(ra) # 80000574 <panic>

0000000080004730 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004730:	7139                	addi	sp,sp,-64
    80004732:	fc06                	sd	ra,56(sp)
    80004734:	f822                	sd	s0,48(sp)
    80004736:	f426                	sd	s1,40(sp)
    80004738:	f04a                	sd	s2,32(sp)
    8000473a:	ec4e                	sd	s3,24(sp)
    8000473c:	e852                	sd	s4,16(sp)
    8000473e:	e456                	sd	s5,8(sp)
    80004740:	0080                	addi	s0,sp,64
    80004742:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004744:	0001d517          	auipc	a0,0x1d
    80004748:	50c50513          	addi	a0,a0,1292 # 80021c50 <ftable>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	560080e7          	jalr	1376(ra) # 80000cac <acquire>
  if(f->ref < 1)
    80004754:	40dc                	lw	a5,4(s1)
    80004756:	06f05163          	blez	a5,800047b8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000475a:	37fd                	addiw	a5,a5,-1
    8000475c:	0007871b          	sext.w	a4,a5
    80004760:	c0dc                	sw	a5,4(s1)
    80004762:	06e04363          	bgtz	a4,800047c8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004766:	0004a903          	lw	s2,0(s1)
    8000476a:	0094ca83          	lbu	s5,9(s1)
    8000476e:	0104ba03          	ld	s4,16(s1)
    80004772:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004776:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000477a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000477e:	0001d517          	auipc	a0,0x1d
    80004782:	4d250513          	addi	a0,a0,1234 # 80021c50 <ftable>
    80004786:	ffffc097          	auipc	ra,0xffffc
    8000478a:	5da080e7          	jalr	1498(ra) # 80000d60 <release>

  if(ff.type == FD_PIPE){
    8000478e:	4785                	li	a5,1
    80004790:	04f90d63          	beq	s2,a5,800047ea <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004794:	3979                	addiw	s2,s2,-2
    80004796:	4785                	li	a5,1
    80004798:	0527e063          	bltu	a5,s2,800047d8 <fileclose+0xa8>
    begin_op();
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	a92080e7          	jalr	-1390(ra) # 8000422e <begin_op>
    iput(ff.ip);
    800047a4:	854e                	mv	a0,s3
    800047a6:	fffff097          	auipc	ra,0xfffff
    800047aa:	27c080e7          	jalr	636(ra) # 80003a22 <iput>
    end_op();
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	b00080e7          	jalr	-1280(ra) # 800042ae <end_op>
    800047b6:	a00d                	j	800047d8 <fileclose+0xa8>
    panic("fileclose");
    800047b8:	00004517          	auipc	a0,0x4
    800047bc:	05850513          	addi	a0,a0,88 # 80008810 <syscallname+0x350>
    800047c0:	ffffc097          	auipc	ra,0xffffc
    800047c4:	db4080e7          	jalr	-588(ra) # 80000574 <panic>
    release(&ftable.lock);
    800047c8:	0001d517          	auipc	a0,0x1d
    800047cc:	48850513          	addi	a0,a0,1160 # 80021c50 <ftable>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	590080e7          	jalr	1424(ra) # 80000d60 <release>
  }
}
    800047d8:	70e2                	ld	ra,56(sp)
    800047da:	7442                	ld	s0,48(sp)
    800047dc:	74a2                	ld	s1,40(sp)
    800047de:	7902                	ld	s2,32(sp)
    800047e0:	69e2                	ld	s3,24(sp)
    800047e2:	6a42                	ld	s4,16(sp)
    800047e4:	6aa2                	ld	s5,8(sp)
    800047e6:	6121                	addi	sp,sp,64
    800047e8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047ea:	85d6                	mv	a1,s5
    800047ec:	8552                	mv	a0,s4
    800047ee:	00000097          	auipc	ra,0x0
    800047f2:	364080e7          	jalr	868(ra) # 80004b52 <pipeclose>
    800047f6:	b7cd                	j	800047d8 <fileclose+0xa8>

00000000800047f8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047f8:	715d                	addi	sp,sp,-80
    800047fa:	e486                	sd	ra,72(sp)
    800047fc:	e0a2                	sd	s0,64(sp)
    800047fe:	fc26                	sd	s1,56(sp)
    80004800:	f84a                	sd	s2,48(sp)
    80004802:	f44e                	sd	s3,40(sp)
    80004804:	0880                	addi	s0,sp,80
    80004806:	84aa                	mv	s1,a0
    80004808:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000480a:	ffffd097          	auipc	ra,0xffffd
    8000480e:	2b0080e7          	jalr	688(ra) # 80001aba <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004812:	409c                	lw	a5,0(s1)
    80004814:	37f9                	addiw	a5,a5,-2
    80004816:	4705                	li	a4,1
    80004818:	04f76763          	bltu	a4,a5,80004866 <filestat+0x6e>
    8000481c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000481e:	6c88                	ld	a0,24(s1)
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	046080e7          	jalr	70(ra) # 80003866 <ilock>
    stati(f->ip, &st);
    80004828:	fb840593          	addi	a1,s0,-72
    8000482c:	6c88                	ld	a0,24(s1)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	2c4080e7          	jalr	708(ra) # 80003af2 <stati>
    iunlock(f->ip);
    80004836:	6c88                	ld	a0,24(s1)
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	0f2080e7          	jalr	242(ra) # 8000392a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004840:	46e1                	li	a3,24
    80004842:	fb840613          	addi	a2,s0,-72
    80004846:	85ce                	mv	a1,s3
    80004848:	05093503          	ld	a0,80(s2)
    8000484c:	ffffd097          	auipc	ra,0xffffd
    80004850:	f4a080e7          	jalr	-182(ra) # 80001796 <copyout>
    80004854:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004858:	60a6                	ld	ra,72(sp)
    8000485a:	6406                	ld	s0,64(sp)
    8000485c:	74e2                	ld	s1,56(sp)
    8000485e:	7942                	ld	s2,48(sp)
    80004860:	79a2                	ld	s3,40(sp)
    80004862:	6161                	addi	sp,sp,80
    80004864:	8082                	ret
  return -1;
    80004866:	557d                	li	a0,-1
    80004868:	bfc5                	j	80004858 <filestat+0x60>

000000008000486a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000486a:	7179                	addi	sp,sp,-48
    8000486c:	f406                	sd	ra,40(sp)
    8000486e:	f022                	sd	s0,32(sp)
    80004870:	ec26                	sd	s1,24(sp)
    80004872:	e84a                	sd	s2,16(sp)
    80004874:	e44e                	sd	s3,8(sp)
    80004876:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004878:	00854783          	lbu	a5,8(a0)
    8000487c:	c3d5                	beqz	a5,80004920 <fileread+0xb6>
    8000487e:	89b2                	mv	s3,a2
    80004880:	892e                	mv	s2,a1
    80004882:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004884:	411c                	lw	a5,0(a0)
    80004886:	4705                	li	a4,1
    80004888:	04e78963          	beq	a5,a4,800048da <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000488c:	470d                	li	a4,3
    8000488e:	04e78d63          	beq	a5,a4,800048e8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004892:	4709                	li	a4,2
    80004894:	06e79e63          	bne	a5,a4,80004910 <fileread+0xa6>
    ilock(f->ip);
    80004898:	6d08                	ld	a0,24(a0)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	fcc080e7          	jalr	-52(ra) # 80003866 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048a2:	874e                	mv	a4,s3
    800048a4:	5094                	lw	a3,32(s1)
    800048a6:	864a                	mv	a2,s2
    800048a8:	4585                	li	a1,1
    800048aa:	6c88                	ld	a0,24(s1)
    800048ac:	fffff097          	auipc	ra,0xfffff
    800048b0:	270080e7          	jalr	624(ra) # 80003b1c <readi>
    800048b4:	892a                	mv	s2,a0
    800048b6:	00a05563          	blez	a0,800048c0 <fileread+0x56>
      f->off += r;
    800048ba:	509c                	lw	a5,32(s1)
    800048bc:	9fa9                	addw	a5,a5,a0
    800048be:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048c0:	6c88                	ld	a0,24(s1)
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	068080e7          	jalr	104(ra) # 8000392a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048ca:	854a                	mv	a0,s2
    800048cc:	70a2                	ld	ra,40(sp)
    800048ce:	7402                	ld	s0,32(sp)
    800048d0:	64e2                	ld	s1,24(sp)
    800048d2:	6942                	ld	s2,16(sp)
    800048d4:	69a2                	ld	s3,8(sp)
    800048d6:	6145                	addi	sp,sp,48
    800048d8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048da:	6908                	ld	a0,16(a0)
    800048dc:	00000097          	auipc	ra,0x0
    800048e0:	416080e7          	jalr	1046(ra) # 80004cf2 <piperead>
    800048e4:	892a                	mv	s2,a0
    800048e6:	b7d5                	j	800048ca <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048e8:	02451783          	lh	a5,36(a0)
    800048ec:	03079693          	slli	a3,a5,0x30
    800048f0:	92c1                	srli	a3,a3,0x30
    800048f2:	4725                	li	a4,9
    800048f4:	02d76863          	bltu	a4,a3,80004924 <fileread+0xba>
    800048f8:	0792                	slli	a5,a5,0x4
    800048fa:	0001d717          	auipc	a4,0x1d
    800048fe:	2b670713          	addi	a4,a4,694 # 80021bb0 <devsw>
    80004902:	97ba                	add	a5,a5,a4
    80004904:	639c                	ld	a5,0(a5)
    80004906:	c38d                	beqz	a5,80004928 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004908:	4505                	li	a0,1
    8000490a:	9782                	jalr	a5
    8000490c:	892a                	mv	s2,a0
    8000490e:	bf75                	j	800048ca <fileread+0x60>
    panic("fileread");
    80004910:	00004517          	auipc	a0,0x4
    80004914:	f1050513          	addi	a0,a0,-240 # 80008820 <syscallname+0x360>
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	c5c080e7          	jalr	-932(ra) # 80000574 <panic>
    return -1;
    80004920:	597d                	li	s2,-1
    80004922:	b765                	j	800048ca <fileread+0x60>
      return -1;
    80004924:	597d                	li	s2,-1
    80004926:	b755                	j	800048ca <fileread+0x60>
    80004928:	597d                	li	s2,-1
    8000492a:	b745                	j	800048ca <fileread+0x60>

000000008000492c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000492c:	00954783          	lbu	a5,9(a0)
    80004930:	12078e63          	beqz	a5,80004a6c <filewrite+0x140>
{
    80004934:	715d                	addi	sp,sp,-80
    80004936:	e486                	sd	ra,72(sp)
    80004938:	e0a2                	sd	s0,64(sp)
    8000493a:	fc26                	sd	s1,56(sp)
    8000493c:	f84a                	sd	s2,48(sp)
    8000493e:	f44e                	sd	s3,40(sp)
    80004940:	f052                	sd	s4,32(sp)
    80004942:	ec56                	sd	s5,24(sp)
    80004944:	e85a                	sd	s6,16(sp)
    80004946:	e45e                	sd	s7,8(sp)
    80004948:	e062                	sd	s8,0(sp)
    8000494a:	0880                	addi	s0,sp,80
    8000494c:	8ab2                	mv	s5,a2
    8000494e:	8b2e                	mv	s6,a1
    80004950:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80004952:	411c                	lw	a5,0(a0)
    80004954:	4705                	li	a4,1
    80004956:	02e78263          	beq	a5,a4,8000497a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000495a:	470d                	li	a4,3
    8000495c:	02e78563          	beq	a5,a4,80004986 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004960:	4709                	li	a4,2
    80004962:	0ee79d63          	bne	a5,a4,80004a5c <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004966:	0ec05763          	blez	a2,80004a54 <filewrite+0x128>
    int i = 0;
    8000496a:	4901                	li	s2,0
    8000496c:	6b85                	lui	s7,0x1
    8000496e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004972:	6c05                	lui	s8,0x1
    80004974:	c00c0c1b          	addiw	s8,s8,-1024
    80004978:	a061                	j	80004a00 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    8000497a:	6908                	ld	a0,16(a0)
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	246080e7          	jalr	582(ra) # 80004bc2 <pipewrite>
    80004984:	a065                	j	80004a2c <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004986:	02451783          	lh	a5,36(a0)
    8000498a:	03079693          	slli	a3,a5,0x30
    8000498e:	92c1                	srli	a3,a3,0x30
    80004990:	4725                	li	a4,9
    80004992:	0cd76f63          	bltu	a4,a3,80004a70 <filewrite+0x144>
    80004996:	0792                	slli	a5,a5,0x4
    80004998:	0001d717          	auipc	a4,0x1d
    8000499c:	21870713          	addi	a4,a4,536 # 80021bb0 <devsw>
    800049a0:	97ba                	add	a5,a5,a4
    800049a2:	679c                	ld	a5,8(a5)
    800049a4:	cbe1                	beqz	a5,80004a74 <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    800049a6:	4505                	li	a0,1
    800049a8:	9782                	jalr	a5
    800049aa:	a049                	j	80004a2c <filewrite+0x100>
    800049ac:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049b0:	00000097          	auipc	ra,0x0
    800049b4:	87e080e7          	jalr	-1922(ra) # 8000422e <begin_op>
      ilock(f->ip);
    800049b8:	6c88                	ld	a0,24(s1)
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	eac080e7          	jalr	-340(ra) # 80003866 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049c2:	8752                	mv	a4,s4
    800049c4:	5094                	lw	a3,32(s1)
    800049c6:	01690633          	add	a2,s2,s6
    800049ca:	4585                	li	a1,1
    800049cc:	6c88                	ld	a0,24(s1)
    800049ce:	fffff097          	auipc	ra,0xfffff
    800049d2:	244080e7          	jalr	580(ra) # 80003c12 <writei>
    800049d6:	89aa                	mv	s3,a0
    800049d8:	02a05c63          	blez	a0,80004a10 <filewrite+0xe4>
        f->off += r;
    800049dc:	509c                	lw	a5,32(s1)
    800049de:	9fa9                	addw	a5,a5,a0
    800049e0:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800049e2:	6c88                	ld	a0,24(s1)
    800049e4:	fffff097          	auipc	ra,0xfffff
    800049e8:	f46080e7          	jalr	-186(ra) # 8000392a <iunlock>
      end_op();
    800049ec:	00000097          	auipc	ra,0x0
    800049f0:	8c2080e7          	jalr	-1854(ra) # 800042ae <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049f4:	05499863          	bne	s3,s4,80004a44 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    800049f8:	012a093b          	addw	s2,s4,s2
    while(i < n){
    800049fc:	03595563          	ble	s5,s2,80004a26 <filewrite+0xfa>
      int n1 = n - i;
    80004a00:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004a04:	89be                	mv	s3,a5
    80004a06:	2781                	sext.w	a5,a5
    80004a08:	fafbd2e3          	ble	a5,s7,800049ac <filewrite+0x80>
    80004a0c:	89e2                	mv	s3,s8
    80004a0e:	bf79                	j	800049ac <filewrite+0x80>
      iunlock(f->ip);
    80004a10:	6c88                	ld	a0,24(s1)
    80004a12:	fffff097          	auipc	ra,0xfffff
    80004a16:	f18080e7          	jalr	-232(ra) # 8000392a <iunlock>
      end_op();
    80004a1a:	00000097          	auipc	ra,0x0
    80004a1e:	894080e7          	jalr	-1900(ra) # 800042ae <end_op>
      if(r < 0)
    80004a22:	fc09d9e3          	bgez	s3,800049f4 <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004a26:	8556                	mv	a0,s5
    80004a28:	032a9863          	bne	s5,s2,80004a58 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a2c:	60a6                	ld	ra,72(sp)
    80004a2e:	6406                	ld	s0,64(sp)
    80004a30:	74e2                	ld	s1,56(sp)
    80004a32:	7942                	ld	s2,48(sp)
    80004a34:	79a2                	ld	s3,40(sp)
    80004a36:	7a02                	ld	s4,32(sp)
    80004a38:	6ae2                	ld	s5,24(sp)
    80004a3a:	6b42                	ld	s6,16(sp)
    80004a3c:	6ba2                	ld	s7,8(sp)
    80004a3e:	6c02                	ld	s8,0(sp)
    80004a40:	6161                	addi	sp,sp,80
    80004a42:	8082                	ret
        panic("short filewrite");
    80004a44:	00004517          	auipc	a0,0x4
    80004a48:	dec50513          	addi	a0,a0,-532 # 80008830 <syscallname+0x370>
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	b28080e7          	jalr	-1240(ra) # 80000574 <panic>
    int i = 0;
    80004a54:	4901                	li	s2,0
    80004a56:	bfc1                	j	80004a26 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004a58:	557d                	li	a0,-1
    80004a5a:	bfc9                	j	80004a2c <filewrite+0x100>
    panic("filewrite");
    80004a5c:	00004517          	auipc	a0,0x4
    80004a60:	de450513          	addi	a0,a0,-540 # 80008840 <syscallname+0x380>
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	b10080e7          	jalr	-1264(ra) # 80000574 <panic>
    return -1;
    80004a6c:	557d                	li	a0,-1
}
    80004a6e:	8082                	ret
      return -1;
    80004a70:	557d                	li	a0,-1
    80004a72:	bf6d                	j	80004a2c <filewrite+0x100>
    80004a74:	557d                	li	a0,-1
    80004a76:	bf5d                	j	80004a2c <filewrite+0x100>

0000000080004a78 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a78:	7179                	addi	sp,sp,-48
    80004a7a:	f406                	sd	ra,40(sp)
    80004a7c:	f022                	sd	s0,32(sp)
    80004a7e:	ec26                	sd	s1,24(sp)
    80004a80:	e84a                	sd	s2,16(sp)
    80004a82:	e44e                	sd	s3,8(sp)
    80004a84:	e052                	sd	s4,0(sp)
    80004a86:	1800                	addi	s0,sp,48
    80004a88:	84aa                	mv	s1,a0
    80004a8a:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a8c:	0005b023          	sd	zero,0(a1)
    80004a90:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	bcc080e7          	jalr	-1076(ra) # 80004660 <filealloc>
    80004a9c:	e088                	sd	a0,0(s1)
    80004a9e:	c551                	beqz	a0,80004b2a <pipealloc+0xb2>
    80004aa0:	00000097          	auipc	ra,0x0
    80004aa4:	bc0080e7          	jalr	-1088(ra) # 80004660 <filealloc>
    80004aa8:	00a93023          	sd	a0,0(s2)
    80004aac:	c92d                	beqz	a0,80004b1e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004aae:	ffffc097          	auipc	ra,0xffffc
    80004ab2:	0c4080e7          	jalr	196(ra) # 80000b72 <kalloc>
    80004ab6:	89aa                	mv	s3,a0
    80004ab8:	c125                	beqz	a0,80004b18 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004aba:	4a05                	li	s4,1
    80004abc:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004ac0:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004ac4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ac8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004acc:	00004597          	auipc	a1,0x4
    80004ad0:	b0c58593          	addi	a1,a1,-1268 # 800085d8 <syscallname+0x118>
    80004ad4:	ffffc097          	auipc	ra,0xffffc
    80004ad8:	148080e7          	jalr	328(ra) # 80000c1c <initlock>
  (*f0)->type = FD_PIPE;
    80004adc:	609c                	ld	a5,0(s1)
    80004ade:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004ae2:	609c                	ld	a5,0(s1)
    80004ae4:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004ae8:	609c                	ld	a5,0(s1)
    80004aea:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004aee:	609c                	ld	a5,0(s1)
    80004af0:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004af4:	00093783          	ld	a5,0(s2)
    80004af8:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004afc:	00093783          	ld	a5,0(s2)
    80004b00:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b04:	00093783          	ld	a5,0(s2)
    80004b08:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004b0c:	00093783          	ld	a5,0(s2)
    80004b10:	0137b823          	sd	s3,16(a5)
  return 0;
    80004b14:	4501                	li	a0,0
    80004b16:	a025                	j	80004b3e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b18:	6088                	ld	a0,0(s1)
    80004b1a:	e501                	bnez	a0,80004b22 <pipealloc+0xaa>
    80004b1c:	a039                	j	80004b2a <pipealloc+0xb2>
    80004b1e:	6088                	ld	a0,0(s1)
    80004b20:	c51d                	beqz	a0,80004b4e <pipealloc+0xd6>
    fileclose(*f0);
    80004b22:	00000097          	auipc	ra,0x0
    80004b26:	c0e080e7          	jalr	-1010(ra) # 80004730 <fileclose>
  if(*f1)
    80004b2a:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004b2e:	557d                	li	a0,-1
  if(*f1)
    80004b30:	c799                	beqz	a5,80004b3e <pipealloc+0xc6>
    fileclose(*f1);
    80004b32:	853e                	mv	a0,a5
    80004b34:	00000097          	auipc	ra,0x0
    80004b38:	bfc080e7          	jalr	-1028(ra) # 80004730 <fileclose>
  return -1;
    80004b3c:	557d                	li	a0,-1
}
    80004b3e:	70a2                	ld	ra,40(sp)
    80004b40:	7402                	ld	s0,32(sp)
    80004b42:	64e2                	ld	s1,24(sp)
    80004b44:	6942                	ld	s2,16(sp)
    80004b46:	69a2                	ld	s3,8(sp)
    80004b48:	6a02                	ld	s4,0(sp)
    80004b4a:	6145                	addi	sp,sp,48
    80004b4c:	8082                	ret
  return -1;
    80004b4e:	557d                	li	a0,-1
    80004b50:	b7fd                	j	80004b3e <pipealloc+0xc6>

0000000080004b52 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b52:	1101                	addi	sp,sp,-32
    80004b54:	ec06                	sd	ra,24(sp)
    80004b56:	e822                	sd	s0,16(sp)
    80004b58:	e426                	sd	s1,8(sp)
    80004b5a:	e04a                	sd	s2,0(sp)
    80004b5c:	1000                	addi	s0,sp,32
    80004b5e:	84aa                	mv	s1,a0
    80004b60:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b62:	ffffc097          	auipc	ra,0xffffc
    80004b66:	14a080e7          	jalr	330(ra) # 80000cac <acquire>
  if(writable){
    80004b6a:	02090d63          	beqz	s2,80004ba4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b6e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b72:	21848513          	addi	a0,s1,536
    80004b76:	ffffe097          	auipc	ra,0xffffe
    80004b7a:	8e8080e7          	jalr	-1816(ra) # 8000245e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b7e:	2204b783          	ld	a5,544(s1)
    80004b82:	eb95                	bnez	a5,80004bb6 <pipeclose+0x64>
    release(&pi->lock);
    80004b84:	8526                	mv	a0,s1
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	1da080e7          	jalr	474(ra) # 80000d60 <release>
    kfree((char*)pi);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	ee2080e7          	jalr	-286(ra) # 80000a72 <kfree>
  } else
    release(&pi->lock);
}
    80004b98:	60e2                	ld	ra,24(sp)
    80004b9a:	6442                	ld	s0,16(sp)
    80004b9c:	64a2                	ld	s1,8(sp)
    80004b9e:	6902                	ld	s2,0(sp)
    80004ba0:	6105                	addi	sp,sp,32
    80004ba2:	8082                	ret
    pi->readopen = 0;
    80004ba4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ba8:	21c48513          	addi	a0,s1,540
    80004bac:	ffffe097          	auipc	ra,0xffffe
    80004bb0:	8b2080e7          	jalr	-1870(ra) # 8000245e <wakeup>
    80004bb4:	b7e9                	j	80004b7e <pipeclose+0x2c>
    release(&pi->lock);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	1a8080e7          	jalr	424(ra) # 80000d60 <release>
}
    80004bc0:	bfe1                	j	80004b98 <pipeclose+0x46>

0000000080004bc2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bc2:	7119                	addi	sp,sp,-128
    80004bc4:	fc86                	sd	ra,120(sp)
    80004bc6:	f8a2                	sd	s0,112(sp)
    80004bc8:	f4a6                	sd	s1,104(sp)
    80004bca:	f0ca                	sd	s2,96(sp)
    80004bcc:	ecce                	sd	s3,88(sp)
    80004bce:	e8d2                	sd	s4,80(sp)
    80004bd0:	e4d6                	sd	s5,72(sp)
    80004bd2:	e0da                	sd	s6,64(sp)
    80004bd4:	fc5e                	sd	s7,56(sp)
    80004bd6:	f862                	sd	s8,48(sp)
    80004bd8:	f466                	sd	s9,40(sp)
    80004bda:	f06a                	sd	s10,32(sp)
    80004bdc:	ec6e                	sd	s11,24(sp)
    80004bde:	0100                	addi	s0,sp,128
    80004be0:	84aa                	mv	s1,a0
    80004be2:	8d2e                	mv	s10,a1
    80004be4:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004be6:	ffffd097          	auipc	ra,0xffffd
    80004bea:	ed4080e7          	jalr	-300(ra) # 80001aba <myproc>
    80004bee:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	0ba080e7          	jalr	186(ra) # 80000cac <acquire>
  for(i = 0; i < n; i++){
    80004bfa:	0d605f63          	blez	s6,80004cd8 <pipewrite+0x116>
    80004bfe:	89a6                	mv	s3,s1
    80004c00:	3b7d                	addiw	s6,s6,-1
    80004c02:	1b02                	slli	s6,s6,0x20
    80004c04:	020b5b13          	srli	s6,s6,0x20
    80004c08:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c0a:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c0e:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c12:	5dfd                	li	s11,-1
    80004c14:	000b8c9b          	sext.w	s9,s7
    80004c18:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c1a:	2184a783          	lw	a5,536(s1)
    80004c1e:	21c4a703          	lw	a4,540(s1)
    80004c22:	2007879b          	addiw	a5,a5,512
    80004c26:	06f71763          	bne	a4,a5,80004c94 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c2a:	2204a783          	lw	a5,544(s1)
    80004c2e:	cf8d                	beqz	a5,80004c68 <pipewrite+0xa6>
    80004c30:	03092783          	lw	a5,48(s2)
    80004c34:	eb95                	bnez	a5,80004c68 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004c36:	8556                	mv	a0,s5
    80004c38:	ffffe097          	auipc	ra,0xffffe
    80004c3c:	826080e7          	jalr	-2010(ra) # 8000245e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c40:	85ce                	mv	a1,s3
    80004c42:	8552                	mv	a0,s4
    80004c44:	ffffd097          	auipc	ra,0xffffd
    80004c48:	694080e7          	jalr	1684(ra) # 800022d8 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c4c:	2184a783          	lw	a5,536(s1)
    80004c50:	21c4a703          	lw	a4,540(s1)
    80004c54:	2007879b          	addiw	a5,a5,512
    80004c58:	02f71e63          	bne	a4,a5,80004c94 <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c5c:	2204a783          	lw	a5,544(s1)
    80004c60:	c781                	beqz	a5,80004c68 <pipewrite+0xa6>
    80004c62:	03092783          	lw	a5,48(s2)
    80004c66:	dbe1                	beqz	a5,80004c36 <pipewrite+0x74>
        release(&pi->lock);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	0f6080e7          	jalr	246(ra) # 80000d60 <release>
        return -1;
    80004c72:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c74:	8562                	mv	a0,s8
    80004c76:	70e6                	ld	ra,120(sp)
    80004c78:	7446                	ld	s0,112(sp)
    80004c7a:	74a6                	ld	s1,104(sp)
    80004c7c:	7906                	ld	s2,96(sp)
    80004c7e:	69e6                	ld	s3,88(sp)
    80004c80:	6a46                	ld	s4,80(sp)
    80004c82:	6aa6                	ld	s5,72(sp)
    80004c84:	6b06                	ld	s6,64(sp)
    80004c86:	7be2                	ld	s7,56(sp)
    80004c88:	7c42                	ld	s8,48(sp)
    80004c8a:	7ca2                	ld	s9,40(sp)
    80004c8c:	7d02                	ld	s10,32(sp)
    80004c8e:	6de2                	ld	s11,24(sp)
    80004c90:	6109                	addi	sp,sp,128
    80004c92:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c94:	4685                	li	a3,1
    80004c96:	01ab8633          	add	a2,s7,s10
    80004c9a:	f8f40593          	addi	a1,s0,-113
    80004c9e:	05093503          	ld	a0,80(s2)
    80004ca2:	ffffd097          	auipc	ra,0xffffd
    80004ca6:	b80080e7          	jalr	-1152(ra) # 80001822 <copyin>
    80004caa:	03b50863          	beq	a0,s11,80004cda <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cae:	21c4a783          	lw	a5,540(s1)
    80004cb2:	0017871b          	addiw	a4,a5,1
    80004cb6:	20e4ae23          	sw	a4,540(s1)
    80004cba:	1ff7f793          	andi	a5,a5,511
    80004cbe:	97a6                	add	a5,a5,s1
    80004cc0:	f8f44703          	lbu	a4,-113(s0)
    80004cc4:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cc8:	001c8c1b          	addiw	s8,s9,1
    80004ccc:	001b8793          	addi	a5,s7,1
    80004cd0:	016b8563          	beq	s7,s6,80004cda <pipewrite+0x118>
    80004cd4:	8bbe                	mv	s7,a5
    80004cd6:	bf3d                	j	80004c14 <pipewrite+0x52>
    80004cd8:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004cda:	21848513          	addi	a0,s1,536
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	780080e7          	jalr	1920(ra) # 8000245e <wakeup>
  release(&pi->lock);
    80004ce6:	8526                	mv	a0,s1
    80004ce8:	ffffc097          	auipc	ra,0xffffc
    80004cec:	078080e7          	jalr	120(ra) # 80000d60 <release>
  return i;
    80004cf0:	b751                	j	80004c74 <pipewrite+0xb2>

0000000080004cf2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cf2:	715d                	addi	sp,sp,-80
    80004cf4:	e486                	sd	ra,72(sp)
    80004cf6:	e0a2                	sd	s0,64(sp)
    80004cf8:	fc26                	sd	s1,56(sp)
    80004cfa:	f84a                	sd	s2,48(sp)
    80004cfc:	f44e                	sd	s3,40(sp)
    80004cfe:	f052                	sd	s4,32(sp)
    80004d00:	ec56                	sd	s5,24(sp)
    80004d02:	e85a                	sd	s6,16(sp)
    80004d04:	0880                	addi	s0,sp,80
    80004d06:	84aa                	mv	s1,a0
    80004d08:	89ae                	mv	s3,a1
    80004d0a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d0c:	ffffd097          	auipc	ra,0xffffd
    80004d10:	dae080e7          	jalr	-594(ra) # 80001aba <myproc>
    80004d14:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d16:	8526                	mv	a0,s1
    80004d18:	ffffc097          	auipc	ra,0xffffc
    80004d1c:	f94080e7          	jalr	-108(ra) # 80000cac <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d20:	2184a703          	lw	a4,536(s1)
    80004d24:	21c4a783          	lw	a5,540(s1)
    80004d28:	06f71b63          	bne	a4,a5,80004d9e <piperead+0xac>
    80004d2c:	8926                	mv	s2,s1
    80004d2e:	2244a783          	lw	a5,548(s1)
    80004d32:	cf9d                	beqz	a5,80004d70 <piperead+0x7e>
    if(pr->killed){
    80004d34:	030a2783          	lw	a5,48(s4)
    80004d38:	e78d                	bnez	a5,80004d62 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d3a:	21848b13          	addi	s6,s1,536
    80004d3e:	85ca                	mv	a1,s2
    80004d40:	855a                	mv	a0,s6
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	596080e7          	jalr	1430(ra) # 800022d8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d4a:	2184a703          	lw	a4,536(s1)
    80004d4e:	21c4a783          	lw	a5,540(s1)
    80004d52:	04f71663          	bne	a4,a5,80004d9e <piperead+0xac>
    80004d56:	2244a783          	lw	a5,548(s1)
    80004d5a:	cb99                	beqz	a5,80004d70 <piperead+0x7e>
    if(pr->killed){
    80004d5c:	030a2783          	lw	a5,48(s4)
    80004d60:	dff9                	beqz	a5,80004d3e <piperead+0x4c>
      release(&pi->lock);
    80004d62:	8526                	mv	a0,s1
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	ffc080e7          	jalr	-4(ra) # 80000d60 <release>
      return -1;
    80004d6c:	597d                	li	s2,-1
    80004d6e:	a829                	j	80004d88 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004d70:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d72:	21c48513          	addi	a0,s1,540
    80004d76:	ffffd097          	auipc	ra,0xffffd
    80004d7a:	6e8080e7          	jalr	1768(ra) # 8000245e <wakeup>
  release(&pi->lock);
    80004d7e:	8526                	mv	a0,s1
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	fe0080e7          	jalr	-32(ra) # 80000d60 <release>
  return i;
}
    80004d88:	854a                	mv	a0,s2
    80004d8a:	60a6                	ld	ra,72(sp)
    80004d8c:	6406                	ld	s0,64(sp)
    80004d8e:	74e2                	ld	s1,56(sp)
    80004d90:	7942                	ld	s2,48(sp)
    80004d92:	79a2                	ld	s3,40(sp)
    80004d94:	7a02                	ld	s4,32(sp)
    80004d96:	6ae2                	ld	s5,24(sp)
    80004d98:	6b42                	ld	s6,16(sp)
    80004d9a:	6161                	addi	sp,sp,80
    80004d9c:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d9e:	4901                	li	s2,0
    80004da0:	fd5059e3          	blez	s5,80004d72 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004da4:	2184a783          	lw	a5,536(s1)
    80004da8:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004daa:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dac:	0017871b          	addiw	a4,a5,1
    80004db0:	20e4ac23          	sw	a4,536(s1)
    80004db4:	1ff7f793          	andi	a5,a5,511
    80004db8:	97a6                	add	a5,a5,s1
    80004dba:	0187c783          	lbu	a5,24(a5)
    80004dbe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dc2:	4685                	li	a3,1
    80004dc4:	fbf40613          	addi	a2,s0,-65
    80004dc8:	85ce                	mv	a1,s3
    80004dca:	050a3503          	ld	a0,80(s4)
    80004dce:	ffffd097          	auipc	ra,0xffffd
    80004dd2:	9c8080e7          	jalr	-1592(ra) # 80001796 <copyout>
    80004dd6:	f9650ee3          	beq	a0,s6,80004d72 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dda:	2905                	addiw	s2,s2,1
    80004ddc:	f92a8be3          	beq	s5,s2,80004d72 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004de0:	2184a783          	lw	a5,536(s1)
    80004de4:	0985                	addi	s3,s3,1
    80004de6:	21c4a703          	lw	a4,540(s1)
    80004dea:	fcf711e3          	bne	a4,a5,80004dac <piperead+0xba>
    80004dee:	b751                	j	80004d72 <piperead+0x80>

0000000080004df0 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004df0:	de010113          	addi	sp,sp,-544
    80004df4:	20113c23          	sd	ra,536(sp)
    80004df8:	20813823          	sd	s0,528(sp)
    80004dfc:	20913423          	sd	s1,520(sp)
    80004e00:	21213023          	sd	s2,512(sp)
    80004e04:	ffce                	sd	s3,504(sp)
    80004e06:	fbd2                	sd	s4,496(sp)
    80004e08:	f7d6                	sd	s5,488(sp)
    80004e0a:	f3da                	sd	s6,480(sp)
    80004e0c:	efde                	sd	s7,472(sp)
    80004e0e:	ebe2                	sd	s8,464(sp)
    80004e10:	e7e6                	sd	s9,456(sp)
    80004e12:	e3ea                	sd	s10,448(sp)
    80004e14:	ff6e                	sd	s11,440(sp)
    80004e16:	1400                	addi	s0,sp,544
    80004e18:	892a                	mv	s2,a0
    80004e1a:	dea43823          	sd	a0,-528(s0)
    80004e1e:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	c98080e7          	jalr	-872(ra) # 80001aba <myproc>
    80004e2a:	84aa                	mv	s1,a0

  begin_op();
    80004e2c:	fffff097          	auipc	ra,0xfffff
    80004e30:	402080e7          	jalr	1026(ra) # 8000422e <begin_op>

  if((ip = namei(path)) == 0){
    80004e34:	854a                	mv	a0,s2
    80004e36:	fffff097          	auipc	ra,0xfffff
    80004e3a:	1ea080e7          	jalr	490(ra) # 80004020 <namei>
    80004e3e:	c93d                	beqz	a0,80004eb4 <exec+0xc4>
    80004e40:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	a24080e7          	jalr	-1500(ra) # 80003866 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e4a:	04000713          	li	a4,64
    80004e4e:	4681                	li	a3,0
    80004e50:	e4840613          	addi	a2,s0,-440
    80004e54:	4581                	li	a1,0
    80004e56:	854a                	mv	a0,s2
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	cc4080e7          	jalr	-828(ra) # 80003b1c <readi>
    80004e60:	04000793          	li	a5,64
    80004e64:	00f51a63          	bne	a0,a5,80004e78 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e68:	e4842703          	lw	a4,-440(s0)
    80004e6c:	464c47b7          	lui	a5,0x464c4
    80004e70:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e74:	04f70663          	beq	a4,a5,80004ec0 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e78:	854a                	mv	a0,s2
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	c50080e7          	jalr	-944(ra) # 80003aca <iunlockput>
    end_op();
    80004e82:	fffff097          	auipc	ra,0xfffff
    80004e86:	42c080e7          	jalr	1068(ra) # 800042ae <end_op>
  }
  return -1;
    80004e8a:	557d                	li	a0,-1
}
    80004e8c:	21813083          	ld	ra,536(sp)
    80004e90:	21013403          	ld	s0,528(sp)
    80004e94:	20813483          	ld	s1,520(sp)
    80004e98:	20013903          	ld	s2,512(sp)
    80004e9c:	79fe                	ld	s3,504(sp)
    80004e9e:	7a5e                	ld	s4,496(sp)
    80004ea0:	7abe                	ld	s5,488(sp)
    80004ea2:	7b1e                	ld	s6,480(sp)
    80004ea4:	6bfe                	ld	s7,472(sp)
    80004ea6:	6c5e                	ld	s8,464(sp)
    80004ea8:	6cbe                	ld	s9,456(sp)
    80004eaa:	6d1e                	ld	s10,448(sp)
    80004eac:	7dfa                	ld	s11,440(sp)
    80004eae:	22010113          	addi	sp,sp,544
    80004eb2:	8082                	ret
    end_op();
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	3fa080e7          	jalr	1018(ra) # 800042ae <end_op>
    return -1;
    80004ebc:	557d                	li	a0,-1
    80004ebe:	b7f9                	j	80004e8c <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	cbe080e7          	jalr	-834(ra) # 80001b80 <proc_pagetable>
    80004eca:	e0a43423          	sd	a0,-504(s0)
    80004ece:	d54d                	beqz	a0,80004e78 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ed0:	e6842983          	lw	s3,-408(s0)
    80004ed4:	e8045783          	lhu	a5,-384(s0)
    80004ed8:	c7ad                	beqz	a5,80004f42 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004eda:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004edc:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ede:	6c05                	lui	s8,0x1
    80004ee0:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004ee4:	def43423          	sd	a5,-536(s0)
    80004ee8:	7cfd                	lui	s9,0xfffff
    80004eea:	ac1d                	j	80005120 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004eec:	00004517          	auipc	a0,0x4
    80004ef0:	96450513          	addi	a0,a0,-1692 # 80008850 <syscallname+0x390>
    80004ef4:	ffffb097          	auipc	ra,0xffffb
    80004ef8:	680080e7          	jalr	1664(ra) # 80000574 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004efc:	8756                	mv	a4,s5
    80004efe:	009d86bb          	addw	a3,s11,s1
    80004f02:	4581                	li	a1,0
    80004f04:	854a                	mv	a0,s2
    80004f06:	fffff097          	auipc	ra,0xfffff
    80004f0a:	c16080e7          	jalr	-1002(ra) # 80003b1c <readi>
    80004f0e:	2501                	sext.w	a0,a0
    80004f10:	1aaa9e63          	bne	s5,a0,800050cc <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004f14:	6785                	lui	a5,0x1
    80004f16:	9cbd                	addw	s1,s1,a5
    80004f18:	014c8a3b          	addw	s4,s9,s4
    80004f1c:	1f74f963          	bleu	s7,s1,8000510e <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004f20:	02049593          	slli	a1,s1,0x20
    80004f24:	9181                	srli	a1,a1,0x20
    80004f26:	95ea                	add	a1,a1,s10
    80004f28:	e0843503          	ld	a0,-504(s0)
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	232080e7          	jalr	562(ra) # 8000115e <walkaddr>
    80004f34:	862a                	mv	a2,a0
    if(pa == 0)
    80004f36:	d95d                	beqz	a0,80004eec <exec+0xfc>
      n = PGSIZE;
    80004f38:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004f3a:	fd8a71e3          	bleu	s8,s4,80004efc <exec+0x10c>
      n = sz - i;
    80004f3e:	8ad2                	mv	s5,s4
    80004f40:	bf75                	j	80004efc <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f42:	4481                	li	s1,0
  iunlockput(ip);
    80004f44:	854a                	mv	a0,s2
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	b84080e7          	jalr	-1148(ra) # 80003aca <iunlockput>
  end_op();
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	360080e7          	jalr	864(ra) # 800042ae <end_op>
  p = myproc();
    80004f56:	ffffd097          	auipc	ra,0xffffd
    80004f5a:	b64080e7          	jalr	-1180(ra) # 80001aba <myproc>
    80004f5e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f60:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f64:	6785                	lui	a5,0x1
    80004f66:	17fd                	addi	a5,a5,-1
    80004f68:	94be                	add	s1,s1,a5
    80004f6a:	77fd                	lui	a5,0xfffff
    80004f6c:	8fe5                	and	a5,a5,s1
    80004f6e:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f72:	6609                	lui	a2,0x2
    80004f74:	963e                	add	a2,a2,a5
    80004f76:	85be                	mv	a1,a5
    80004f78:	e0843483          	ld	s1,-504(s0)
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	ffffc097          	auipc	ra,0xffffc
    80004f82:	5c8080e7          	jalr	1480(ra) # 80001546 <uvmalloc>
    80004f86:	8b2a                	mv	s6,a0
  ip = 0;
    80004f88:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f8a:	14050163          	beqz	a0,800050cc <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f8e:	75f9                	lui	a1,0xffffe
    80004f90:	95aa                	add	a1,a1,a0
    80004f92:	8526                	mv	a0,s1
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	7d0080e7          	jalr	2000(ra) # 80001764 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f9c:	7bfd                	lui	s7,0xfffff
    80004f9e:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fa0:	df843783          	ld	a5,-520(s0)
    80004fa4:	6388                	ld	a0,0(a5)
    80004fa6:	c925                	beqz	a0,80005016 <exec+0x226>
    80004fa8:	e8840993          	addi	s3,s0,-376
    80004fac:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004fb0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fb2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fb4:	ffffc097          	auipc	ra,0xffffc
    80004fb8:	f9e080e7          	jalr	-98(ra) # 80000f52 <strlen>
    80004fbc:	2505                	addiw	a0,a0,1
    80004fbe:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fc2:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fc6:	13796863          	bltu	s2,s7,800050f6 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fca:	df843c83          	ld	s9,-520(s0)
    80004fce:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80004fd2:	8552                	mv	a0,s4
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	f7e080e7          	jalr	-130(ra) # 80000f52 <strlen>
    80004fdc:	0015069b          	addiw	a3,a0,1
    80004fe0:	8652                	mv	a2,s4
    80004fe2:	85ca                	mv	a1,s2
    80004fe4:	e0843503          	ld	a0,-504(s0)
    80004fe8:	ffffc097          	auipc	ra,0xffffc
    80004fec:	7ae080e7          	jalr	1966(ra) # 80001796 <copyout>
    80004ff0:	10054763          	bltz	a0,800050fe <exec+0x30e>
    ustack[argc] = sp;
    80004ff4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ff8:	0485                	addi	s1,s1,1
    80004ffa:	008c8793          	addi	a5,s9,8
    80004ffe:	def43c23          	sd	a5,-520(s0)
    80005002:	008cb503          	ld	a0,8(s9)
    80005006:	c911                	beqz	a0,8000501a <exec+0x22a>
    if(argc >= MAXARG)
    80005008:	09a1                	addi	s3,s3,8
    8000500a:	fb8995e3          	bne	s3,s8,80004fb4 <exec+0x1c4>
  sz = sz1;
    8000500e:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005012:	4901                	li	s2,0
    80005014:	a865                	j	800050cc <exec+0x2dc>
  sp = sz;
    80005016:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005018:	4481                	li	s1,0
  ustack[argc] = 0;
    8000501a:	00349793          	slli	a5,s1,0x3
    8000501e:	f9040713          	addi	a4,s0,-112
    80005022:	97ba                	add	a5,a5,a4
    80005024:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005028:	00148693          	addi	a3,s1,1
    8000502c:	068e                	slli	a3,a3,0x3
    8000502e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005032:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005036:	01797663          	bleu	s7,s2,80005042 <exec+0x252>
  sz = sz1;
    8000503a:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000503e:	4901                	li	s2,0
    80005040:	a071                	j	800050cc <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005042:	e8840613          	addi	a2,s0,-376
    80005046:	85ca                	mv	a1,s2
    80005048:	e0843503          	ld	a0,-504(s0)
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	74a080e7          	jalr	1866(ra) # 80001796 <copyout>
    80005054:	0a054963          	bltz	a0,80005106 <exec+0x316>
  p->trapframe->a1 = sp;
    80005058:	058ab783          	ld	a5,88(s5)
    8000505c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005060:	df043783          	ld	a5,-528(s0)
    80005064:	0007c703          	lbu	a4,0(a5)
    80005068:	cf11                	beqz	a4,80005084 <exec+0x294>
    8000506a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000506c:	02f00693          	li	a3,47
    80005070:	a029                	j	8000507a <exec+0x28a>
  for(last=s=path; *s; s++)
    80005072:	0785                	addi	a5,a5,1
    80005074:	fff7c703          	lbu	a4,-1(a5)
    80005078:	c711                	beqz	a4,80005084 <exec+0x294>
    if(*s == '/')
    8000507a:	fed71ce3          	bne	a4,a3,80005072 <exec+0x282>
      last = s+1;
    8000507e:	def43823          	sd	a5,-528(s0)
    80005082:	bfc5                	j	80005072 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    80005084:	4641                	li	a2,16
    80005086:	df043583          	ld	a1,-528(s0)
    8000508a:	158a8513          	addi	a0,s5,344
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	e92080e7          	jalr	-366(ra) # 80000f20 <safestrcpy>
  oldpagetable = p->pagetable;
    80005096:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000509a:	e0843783          	ld	a5,-504(s0)
    8000509e:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    800050a2:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050a6:	058ab783          	ld	a5,88(s5)
    800050aa:	e6043703          	ld	a4,-416(s0)
    800050ae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050b0:	058ab783          	ld	a5,88(s5)
    800050b4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050b8:	85ea                	mv	a1,s10
    800050ba:	ffffd097          	auipc	ra,0xffffd
    800050be:	b62080e7          	jalr	-1182(ra) # 80001c1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050c2:	0004851b          	sext.w	a0,s1
    800050c6:	b3d9                	j	80004e8c <exec+0x9c>
    800050c8:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800050cc:	e0043583          	ld	a1,-512(s0)
    800050d0:	e0843503          	ld	a0,-504(s0)
    800050d4:	ffffd097          	auipc	ra,0xffffd
    800050d8:	b48080e7          	jalr	-1208(ra) # 80001c1c <proc_freepagetable>
  if(ip){
    800050dc:	d8091ee3          	bnez	s2,80004e78 <exec+0x88>
  return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	b36d                	j	80004e8c <exec+0x9c>
    800050e4:	e0943023          	sd	s1,-512(s0)
    800050e8:	b7d5                	j	800050cc <exec+0x2dc>
    800050ea:	e0943023          	sd	s1,-512(s0)
    800050ee:	bff9                	j	800050cc <exec+0x2dc>
    800050f0:	e0943023          	sd	s1,-512(s0)
    800050f4:	bfe1                	j	800050cc <exec+0x2dc>
  sz = sz1;
    800050f6:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    800050fa:	4901                	li	s2,0
    800050fc:	bfc1                	j	800050cc <exec+0x2dc>
  sz = sz1;
    800050fe:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005102:	4901                	li	s2,0
    80005104:	b7e1                	j	800050cc <exec+0x2dc>
  sz = sz1;
    80005106:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000510a:	4901                	li	s2,0
    8000510c:	b7c1                	j	800050cc <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000510e:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005112:	2b05                	addiw	s6,s6,1
    80005114:	0389899b          	addiw	s3,s3,56
    80005118:	e8045783          	lhu	a5,-384(s0)
    8000511c:	e2fb54e3          	ble	a5,s6,80004f44 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005120:	2981                	sext.w	s3,s3
    80005122:	03800713          	li	a4,56
    80005126:	86ce                	mv	a3,s3
    80005128:	e1040613          	addi	a2,s0,-496
    8000512c:	4581                	li	a1,0
    8000512e:	854a                	mv	a0,s2
    80005130:	fffff097          	auipc	ra,0xfffff
    80005134:	9ec080e7          	jalr	-1556(ra) # 80003b1c <readi>
    80005138:	03800793          	li	a5,56
    8000513c:	f8f516e3          	bne	a0,a5,800050c8 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    80005140:	e1042783          	lw	a5,-496(s0)
    80005144:	4705                	li	a4,1
    80005146:	fce796e3          	bne	a5,a4,80005112 <exec+0x322>
    if(ph.memsz < ph.filesz)
    8000514a:	e3843603          	ld	a2,-456(s0)
    8000514e:	e3043783          	ld	a5,-464(s0)
    80005152:	f8f669e3          	bltu	a2,a5,800050e4 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005156:	e2043783          	ld	a5,-480(s0)
    8000515a:	963e                	add	a2,a2,a5
    8000515c:	f8f667e3          	bltu	a2,a5,800050ea <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005160:	85a6                	mv	a1,s1
    80005162:	e0843503          	ld	a0,-504(s0)
    80005166:	ffffc097          	auipc	ra,0xffffc
    8000516a:	3e0080e7          	jalr	992(ra) # 80001546 <uvmalloc>
    8000516e:	e0a43023          	sd	a0,-512(s0)
    80005172:	dd3d                	beqz	a0,800050f0 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    80005174:	e2043d03          	ld	s10,-480(s0)
    80005178:	de843783          	ld	a5,-536(s0)
    8000517c:	00fd77b3          	and	a5,s10,a5
    80005180:	f7b1                	bnez	a5,800050cc <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005182:	e1842d83          	lw	s11,-488(s0)
    80005186:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000518a:	f80b82e3          	beqz	s7,8000510e <exec+0x31e>
    8000518e:	8a5e                	mv	s4,s7
    80005190:	4481                	li	s1,0
    80005192:	b379                	j	80004f20 <exec+0x130>

0000000080005194 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005194:	7179                	addi	sp,sp,-48
    80005196:	f406                	sd	ra,40(sp)
    80005198:	f022                	sd	s0,32(sp)
    8000519a:	ec26                	sd	s1,24(sp)
    8000519c:	e84a                	sd	s2,16(sp)
    8000519e:	1800                	addi	s0,sp,48
    800051a0:	892e                	mv	s2,a1
    800051a2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051a4:	fdc40593          	addi	a1,s0,-36
    800051a8:	ffffe097          	auipc	ra,0xffffe
    800051ac:	a16080e7          	jalr	-1514(ra) # 80002bbe <argint>
    800051b0:	04054063          	bltz	a0,800051f0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051b4:	fdc42703          	lw	a4,-36(s0)
    800051b8:	47bd                	li	a5,15
    800051ba:	02e7ed63          	bltu	a5,a4,800051f4 <argfd+0x60>
    800051be:	ffffd097          	auipc	ra,0xffffd
    800051c2:	8fc080e7          	jalr	-1796(ra) # 80001aba <myproc>
    800051c6:	fdc42703          	lw	a4,-36(s0)
    800051ca:	01a70793          	addi	a5,a4,26
    800051ce:	078e                	slli	a5,a5,0x3
    800051d0:	953e                	add	a0,a0,a5
    800051d2:	611c                	ld	a5,0(a0)
    800051d4:	c395                	beqz	a5,800051f8 <argfd+0x64>
    return -1;
  if(pfd)
    800051d6:	00090463          	beqz	s2,800051de <argfd+0x4a>
    *pfd = fd;
    800051da:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051de:	4501                	li	a0,0
  if(pf)
    800051e0:	c091                	beqz	s1,800051e4 <argfd+0x50>
    *pf = f;
    800051e2:	e09c                	sd	a5,0(s1)
}
    800051e4:	70a2                	ld	ra,40(sp)
    800051e6:	7402                	ld	s0,32(sp)
    800051e8:	64e2                	ld	s1,24(sp)
    800051ea:	6942                	ld	s2,16(sp)
    800051ec:	6145                	addi	sp,sp,48
    800051ee:	8082                	ret
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	bfcd                	j	800051e4 <argfd+0x50>
    return -1;
    800051f4:	557d                	li	a0,-1
    800051f6:	b7fd                	j	800051e4 <argfd+0x50>
    800051f8:	557d                	li	a0,-1
    800051fa:	b7ed                	j	800051e4 <argfd+0x50>

00000000800051fc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051fc:	1101                	addi	sp,sp,-32
    800051fe:	ec06                	sd	ra,24(sp)
    80005200:	e822                	sd	s0,16(sp)
    80005202:	e426                	sd	s1,8(sp)
    80005204:	1000                	addi	s0,sp,32
    80005206:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005208:	ffffd097          	auipc	ra,0xffffd
    8000520c:	8b2080e7          	jalr	-1870(ra) # 80001aba <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80005210:	697c                	ld	a5,208(a0)
    80005212:	c395                	beqz	a5,80005236 <fdalloc+0x3a>
    80005214:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80005218:	4785                	li	a5,1
    8000521a:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000521c:	6314                	ld	a3,0(a4)
    8000521e:	ce89                	beqz	a3,80005238 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80005220:	2785                	addiw	a5,a5,1
    80005222:	0721                	addi	a4,a4,8
    80005224:	fec79ce3          	bne	a5,a2,8000521c <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005228:	57fd                	li	a5,-1
}
    8000522a:	853e                	mv	a0,a5
    8000522c:	60e2                	ld	ra,24(sp)
    8000522e:	6442                	ld	s0,16(sp)
    80005230:	64a2                	ld	s1,8(sp)
    80005232:	6105                	addi	sp,sp,32
    80005234:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80005236:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005238:	01a78713          	addi	a4,a5,26
    8000523c:	070e                	slli	a4,a4,0x3
    8000523e:	953a                	add	a0,a0,a4
    80005240:	e104                	sd	s1,0(a0)
      return fd;
    80005242:	b7e5                	j	8000522a <fdalloc+0x2e>

0000000080005244 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005244:	715d                	addi	sp,sp,-80
    80005246:	e486                	sd	ra,72(sp)
    80005248:	e0a2                	sd	s0,64(sp)
    8000524a:	fc26                	sd	s1,56(sp)
    8000524c:	f84a                	sd	s2,48(sp)
    8000524e:	f44e                	sd	s3,40(sp)
    80005250:	f052                	sd	s4,32(sp)
    80005252:	ec56                	sd	s5,24(sp)
    80005254:	0880                	addi	s0,sp,80
    80005256:	89ae                	mv	s3,a1
    80005258:	8ab2                	mv	s5,a2
    8000525a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000525c:	fb040593          	addi	a1,s0,-80
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	dde080e7          	jalr	-546(ra) # 8000403e <nameiparent>
    80005268:	892a                	mv	s2,a0
    8000526a:	12050f63          	beqz	a0,800053a8 <create+0x164>
    return 0;

  ilock(dp);
    8000526e:	ffffe097          	auipc	ra,0xffffe
    80005272:	5f8080e7          	jalr	1528(ra) # 80003866 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005276:	4601                	li	a2,0
    80005278:	fb040593          	addi	a1,s0,-80
    8000527c:	854a                	mv	a0,s2
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	ac8080e7          	jalr	-1336(ra) # 80003d46 <dirlookup>
    80005286:	84aa                	mv	s1,a0
    80005288:	c921                	beqz	a0,800052d8 <create+0x94>
    iunlockput(dp);
    8000528a:	854a                	mv	a0,s2
    8000528c:	fffff097          	auipc	ra,0xfffff
    80005290:	83e080e7          	jalr	-1986(ra) # 80003aca <iunlockput>
    ilock(ip);
    80005294:	8526                	mv	a0,s1
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	5d0080e7          	jalr	1488(ra) # 80003866 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000529e:	2981                	sext.w	s3,s3
    800052a0:	4789                	li	a5,2
    800052a2:	02f99463          	bne	s3,a5,800052ca <create+0x86>
    800052a6:	0444d783          	lhu	a5,68(s1)
    800052aa:	37f9                	addiw	a5,a5,-2
    800052ac:	17c2                	slli	a5,a5,0x30
    800052ae:	93c1                	srli	a5,a5,0x30
    800052b0:	4705                	li	a4,1
    800052b2:	00f76c63          	bltu	a4,a5,800052ca <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052b6:	8526                	mv	a0,s1
    800052b8:	60a6                	ld	ra,72(sp)
    800052ba:	6406                	ld	s0,64(sp)
    800052bc:	74e2                	ld	s1,56(sp)
    800052be:	7942                	ld	s2,48(sp)
    800052c0:	79a2                	ld	s3,40(sp)
    800052c2:	7a02                	ld	s4,32(sp)
    800052c4:	6ae2                	ld	s5,24(sp)
    800052c6:	6161                	addi	sp,sp,80
    800052c8:	8082                	ret
    iunlockput(ip);
    800052ca:	8526                	mv	a0,s1
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	7fe080e7          	jalr	2046(ra) # 80003aca <iunlockput>
    return 0;
    800052d4:	4481                	li	s1,0
    800052d6:	b7c5                	j	800052b6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052d8:	85ce                	mv	a1,s3
    800052da:	00092503          	lw	a0,0(s2)
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	3ec080e7          	jalr	1004(ra) # 800036ca <ialloc>
    800052e6:	84aa                	mv	s1,a0
    800052e8:	c529                	beqz	a0,80005332 <create+0xee>
  ilock(ip);
    800052ea:	ffffe097          	auipc	ra,0xffffe
    800052ee:	57c080e7          	jalr	1404(ra) # 80003866 <ilock>
  ip->major = major;
    800052f2:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052f6:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800052fa:	4785                	li	a5,1
    800052fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005300:	8526                	mv	a0,s1
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	498080e7          	jalr	1176(ra) # 8000379a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000530a:	2981                	sext.w	s3,s3
    8000530c:	4785                	li	a5,1
    8000530e:	02f98a63          	beq	s3,a5,80005342 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005312:	40d0                	lw	a2,4(s1)
    80005314:	fb040593          	addi	a1,s0,-80
    80005318:	854a                	mv	a0,s2
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	c44080e7          	jalr	-956(ra) # 80003f5e <dirlink>
    80005322:	06054b63          	bltz	a0,80005398 <create+0x154>
  iunlockput(dp);
    80005326:	854a                	mv	a0,s2
    80005328:	ffffe097          	auipc	ra,0xffffe
    8000532c:	7a2080e7          	jalr	1954(ra) # 80003aca <iunlockput>
  return ip;
    80005330:	b759                	j	800052b6 <create+0x72>
    panic("create: ialloc");
    80005332:	00003517          	auipc	a0,0x3
    80005336:	53e50513          	addi	a0,a0,1342 # 80008870 <syscallname+0x3b0>
    8000533a:	ffffb097          	auipc	ra,0xffffb
    8000533e:	23a080e7          	jalr	570(ra) # 80000574 <panic>
    dp->nlink++;  // for ".."
    80005342:	04a95783          	lhu	a5,74(s2)
    80005346:	2785                	addiw	a5,a5,1
    80005348:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000534c:	854a                	mv	a0,s2
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	44c080e7          	jalr	1100(ra) # 8000379a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005356:	40d0                	lw	a2,4(s1)
    80005358:	00003597          	auipc	a1,0x3
    8000535c:	52858593          	addi	a1,a1,1320 # 80008880 <syscallname+0x3c0>
    80005360:	8526                	mv	a0,s1
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	bfc080e7          	jalr	-1028(ra) # 80003f5e <dirlink>
    8000536a:	00054f63          	bltz	a0,80005388 <create+0x144>
    8000536e:	00492603          	lw	a2,4(s2)
    80005372:	00003597          	auipc	a1,0x3
    80005376:	51658593          	addi	a1,a1,1302 # 80008888 <syscallname+0x3c8>
    8000537a:	8526                	mv	a0,s1
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	be2080e7          	jalr	-1054(ra) # 80003f5e <dirlink>
    80005384:	f80557e3          	bgez	a0,80005312 <create+0xce>
      panic("create dots");
    80005388:	00003517          	auipc	a0,0x3
    8000538c:	50850513          	addi	a0,a0,1288 # 80008890 <syscallname+0x3d0>
    80005390:	ffffb097          	auipc	ra,0xffffb
    80005394:	1e4080e7          	jalr	484(ra) # 80000574 <panic>
    panic("create: dirlink");
    80005398:	00003517          	auipc	a0,0x3
    8000539c:	50850513          	addi	a0,a0,1288 # 800088a0 <syscallname+0x3e0>
    800053a0:	ffffb097          	auipc	ra,0xffffb
    800053a4:	1d4080e7          	jalr	468(ra) # 80000574 <panic>
    return 0;
    800053a8:	84aa                	mv	s1,a0
    800053aa:	b731                	j	800052b6 <create+0x72>

00000000800053ac <sys_dup>:
{
    800053ac:	7179                	addi	sp,sp,-48
    800053ae:	f406                	sd	ra,40(sp)
    800053b0:	f022                	sd	s0,32(sp)
    800053b2:	ec26                	sd	s1,24(sp)
    800053b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053b6:	fd840613          	addi	a2,s0,-40
    800053ba:	4581                	li	a1,0
    800053bc:	4501                	li	a0,0
    800053be:	00000097          	auipc	ra,0x0
    800053c2:	dd6080e7          	jalr	-554(ra) # 80005194 <argfd>
    return -1;
    800053c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053c8:	02054363          	bltz	a0,800053ee <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053cc:	fd843503          	ld	a0,-40(s0)
    800053d0:	00000097          	auipc	ra,0x0
    800053d4:	e2c080e7          	jalr	-468(ra) # 800051fc <fdalloc>
    800053d8:	84aa                	mv	s1,a0
    return -1;
    800053da:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053dc:	00054963          	bltz	a0,800053ee <sys_dup+0x42>
  filedup(f);
    800053e0:	fd843503          	ld	a0,-40(s0)
    800053e4:	fffff097          	auipc	ra,0xfffff
    800053e8:	2fa080e7          	jalr	762(ra) # 800046de <filedup>
  return fd;
    800053ec:	87a6                	mv	a5,s1
}
    800053ee:	853e                	mv	a0,a5
    800053f0:	70a2                	ld	ra,40(sp)
    800053f2:	7402                	ld	s0,32(sp)
    800053f4:	64e2                	ld	s1,24(sp)
    800053f6:	6145                	addi	sp,sp,48
    800053f8:	8082                	ret

00000000800053fa <sys_read>:
{
    800053fa:	7179                	addi	sp,sp,-48
    800053fc:	f406                	sd	ra,40(sp)
    800053fe:	f022                	sd	s0,32(sp)
    80005400:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005402:	fe840613          	addi	a2,s0,-24
    80005406:	4581                	li	a1,0
    80005408:	4501                	li	a0,0
    8000540a:	00000097          	auipc	ra,0x0
    8000540e:	d8a080e7          	jalr	-630(ra) # 80005194 <argfd>
    return -1;
    80005412:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005414:	04054163          	bltz	a0,80005456 <sys_read+0x5c>
    80005418:	fe440593          	addi	a1,s0,-28
    8000541c:	4509                	li	a0,2
    8000541e:	ffffd097          	auipc	ra,0xffffd
    80005422:	7a0080e7          	jalr	1952(ra) # 80002bbe <argint>
    return -1;
    80005426:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005428:	02054763          	bltz	a0,80005456 <sys_read+0x5c>
    8000542c:	fd840593          	addi	a1,s0,-40
    80005430:	4505                	li	a0,1
    80005432:	ffffd097          	auipc	ra,0xffffd
    80005436:	7ae080e7          	jalr	1966(ra) # 80002be0 <argaddr>
    return -1;
    8000543a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000543c:	00054d63          	bltz	a0,80005456 <sys_read+0x5c>
  return fileread(f, p, n);
    80005440:	fe442603          	lw	a2,-28(s0)
    80005444:	fd843583          	ld	a1,-40(s0)
    80005448:	fe843503          	ld	a0,-24(s0)
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	41e080e7          	jalr	1054(ra) # 8000486a <fileread>
    80005454:	87aa                	mv	a5,a0
}
    80005456:	853e                	mv	a0,a5
    80005458:	70a2                	ld	ra,40(sp)
    8000545a:	7402                	ld	s0,32(sp)
    8000545c:	6145                	addi	sp,sp,48
    8000545e:	8082                	ret

0000000080005460 <sys_write>:
{
    80005460:	7179                	addi	sp,sp,-48
    80005462:	f406                	sd	ra,40(sp)
    80005464:	f022                	sd	s0,32(sp)
    80005466:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005468:	fe840613          	addi	a2,s0,-24
    8000546c:	4581                	li	a1,0
    8000546e:	4501                	li	a0,0
    80005470:	00000097          	auipc	ra,0x0
    80005474:	d24080e7          	jalr	-732(ra) # 80005194 <argfd>
    return -1;
    80005478:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000547a:	04054163          	bltz	a0,800054bc <sys_write+0x5c>
    8000547e:	fe440593          	addi	a1,s0,-28
    80005482:	4509                	li	a0,2
    80005484:	ffffd097          	auipc	ra,0xffffd
    80005488:	73a080e7          	jalr	1850(ra) # 80002bbe <argint>
    return -1;
    8000548c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548e:	02054763          	bltz	a0,800054bc <sys_write+0x5c>
    80005492:	fd840593          	addi	a1,s0,-40
    80005496:	4505                	li	a0,1
    80005498:	ffffd097          	auipc	ra,0xffffd
    8000549c:	748080e7          	jalr	1864(ra) # 80002be0 <argaddr>
    return -1;
    800054a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a2:	00054d63          	bltz	a0,800054bc <sys_write+0x5c>
  return filewrite(f, p, n);
    800054a6:	fe442603          	lw	a2,-28(s0)
    800054aa:	fd843583          	ld	a1,-40(s0)
    800054ae:	fe843503          	ld	a0,-24(s0)
    800054b2:	fffff097          	auipc	ra,0xfffff
    800054b6:	47a080e7          	jalr	1146(ra) # 8000492c <filewrite>
    800054ba:	87aa                	mv	a5,a0
}
    800054bc:	853e                	mv	a0,a5
    800054be:	70a2                	ld	ra,40(sp)
    800054c0:	7402                	ld	s0,32(sp)
    800054c2:	6145                	addi	sp,sp,48
    800054c4:	8082                	ret

00000000800054c6 <sys_close>:
{
    800054c6:	1101                	addi	sp,sp,-32
    800054c8:	ec06                	sd	ra,24(sp)
    800054ca:	e822                	sd	s0,16(sp)
    800054cc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054ce:	fe040613          	addi	a2,s0,-32
    800054d2:	fec40593          	addi	a1,s0,-20
    800054d6:	4501                	li	a0,0
    800054d8:	00000097          	auipc	ra,0x0
    800054dc:	cbc080e7          	jalr	-836(ra) # 80005194 <argfd>
    return -1;
    800054e0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054e2:	02054463          	bltz	a0,8000550a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054e6:	ffffc097          	auipc	ra,0xffffc
    800054ea:	5d4080e7          	jalr	1492(ra) # 80001aba <myproc>
    800054ee:	fec42783          	lw	a5,-20(s0)
    800054f2:	07e9                	addi	a5,a5,26
    800054f4:	078e                	slli	a5,a5,0x3
    800054f6:	953e                	add	a0,a0,a5
    800054f8:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054fc:	fe043503          	ld	a0,-32(s0)
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	230080e7          	jalr	560(ra) # 80004730 <fileclose>
  return 0;
    80005508:	4781                	li	a5,0
}
    8000550a:	853e                	mv	a0,a5
    8000550c:	60e2                	ld	ra,24(sp)
    8000550e:	6442                	ld	s0,16(sp)
    80005510:	6105                	addi	sp,sp,32
    80005512:	8082                	ret

0000000080005514 <sys_fstat>:
{
    80005514:	1101                	addi	sp,sp,-32
    80005516:	ec06                	sd	ra,24(sp)
    80005518:	e822                	sd	s0,16(sp)
    8000551a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000551c:	fe840613          	addi	a2,s0,-24
    80005520:	4581                	li	a1,0
    80005522:	4501                	li	a0,0
    80005524:	00000097          	auipc	ra,0x0
    80005528:	c70080e7          	jalr	-912(ra) # 80005194 <argfd>
    return -1;
    8000552c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552e:	02054563          	bltz	a0,80005558 <sys_fstat+0x44>
    80005532:	fe040593          	addi	a1,s0,-32
    80005536:	4505                	li	a0,1
    80005538:	ffffd097          	auipc	ra,0xffffd
    8000553c:	6a8080e7          	jalr	1704(ra) # 80002be0 <argaddr>
    return -1;
    80005540:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005542:	00054b63          	bltz	a0,80005558 <sys_fstat+0x44>
  return filestat(f, st);
    80005546:	fe043583          	ld	a1,-32(s0)
    8000554a:	fe843503          	ld	a0,-24(s0)
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	2aa080e7          	jalr	682(ra) # 800047f8 <filestat>
    80005556:	87aa                	mv	a5,a0
}
    80005558:	853e                	mv	a0,a5
    8000555a:	60e2                	ld	ra,24(sp)
    8000555c:	6442                	ld	s0,16(sp)
    8000555e:	6105                	addi	sp,sp,32
    80005560:	8082                	ret

0000000080005562 <sys_link>:
{
    80005562:	7169                	addi	sp,sp,-304
    80005564:	f606                	sd	ra,296(sp)
    80005566:	f222                	sd	s0,288(sp)
    80005568:	ee26                	sd	s1,280(sp)
    8000556a:	ea4a                	sd	s2,272(sp)
    8000556c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000556e:	08000613          	li	a2,128
    80005572:	ed040593          	addi	a1,s0,-304
    80005576:	4501                	li	a0,0
    80005578:	ffffd097          	auipc	ra,0xffffd
    8000557c:	68a080e7          	jalr	1674(ra) # 80002c02 <argstr>
    return -1;
    80005580:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005582:	10054e63          	bltz	a0,8000569e <sys_link+0x13c>
    80005586:	08000613          	li	a2,128
    8000558a:	f5040593          	addi	a1,s0,-176
    8000558e:	4505                	li	a0,1
    80005590:	ffffd097          	auipc	ra,0xffffd
    80005594:	672080e7          	jalr	1650(ra) # 80002c02 <argstr>
    return -1;
    80005598:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000559a:	10054263          	bltz	a0,8000569e <sys_link+0x13c>
  begin_op();
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	c90080e7          	jalr	-880(ra) # 8000422e <begin_op>
  if((ip = namei(old)) == 0){
    800055a6:	ed040513          	addi	a0,s0,-304
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	a76080e7          	jalr	-1418(ra) # 80004020 <namei>
    800055b2:	84aa                	mv	s1,a0
    800055b4:	c551                	beqz	a0,80005640 <sys_link+0xde>
  ilock(ip);
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	2b0080e7          	jalr	688(ra) # 80003866 <ilock>
  if(ip->type == T_DIR){
    800055be:	04449703          	lh	a4,68(s1)
    800055c2:	4785                	li	a5,1
    800055c4:	08f70463          	beq	a4,a5,8000564c <sys_link+0xea>
  ip->nlink++;
    800055c8:	04a4d783          	lhu	a5,74(s1)
    800055cc:	2785                	addiw	a5,a5,1
    800055ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055d2:	8526                	mv	a0,s1
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	1c6080e7          	jalr	454(ra) # 8000379a <iupdate>
  iunlock(ip);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	34c080e7          	jalr	844(ra) # 8000392a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055e6:	fd040593          	addi	a1,s0,-48
    800055ea:	f5040513          	addi	a0,s0,-176
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	a50080e7          	jalr	-1456(ra) # 8000403e <nameiparent>
    800055f6:	892a                	mv	s2,a0
    800055f8:	c935                	beqz	a0,8000566c <sys_link+0x10a>
  ilock(dp);
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	26c080e7          	jalr	620(ra) # 80003866 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005602:	00092703          	lw	a4,0(s2)
    80005606:	409c                	lw	a5,0(s1)
    80005608:	04f71d63          	bne	a4,a5,80005662 <sys_link+0x100>
    8000560c:	40d0                	lw	a2,4(s1)
    8000560e:	fd040593          	addi	a1,s0,-48
    80005612:	854a                	mv	a0,s2
    80005614:	fffff097          	auipc	ra,0xfffff
    80005618:	94a080e7          	jalr	-1718(ra) # 80003f5e <dirlink>
    8000561c:	04054363          	bltz	a0,80005662 <sys_link+0x100>
  iunlockput(dp);
    80005620:	854a                	mv	a0,s2
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	4a8080e7          	jalr	1192(ra) # 80003aca <iunlockput>
  iput(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	3f6080e7          	jalr	1014(ra) # 80003a22 <iput>
  end_op();
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	c7a080e7          	jalr	-902(ra) # 800042ae <end_op>
  return 0;
    8000563c:	4781                	li	a5,0
    8000563e:	a085                	j	8000569e <sys_link+0x13c>
    end_op();
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	c6e080e7          	jalr	-914(ra) # 800042ae <end_op>
    return -1;
    80005648:	57fd                	li	a5,-1
    8000564a:	a891                	j	8000569e <sys_link+0x13c>
    iunlockput(ip);
    8000564c:	8526                	mv	a0,s1
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	47c080e7          	jalr	1148(ra) # 80003aca <iunlockput>
    end_op();
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	c58080e7          	jalr	-936(ra) # 800042ae <end_op>
    return -1;
    8000565e:	57fd                	li	a5,-1
    80005660:	a83d                	j	8000569e <sys_link+0x13c>
    iunlockput(dp);
    80005662:	854a                	mv	a0,s2
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	466080e7          	jalr	1126(ra) # 80003aca <iunlockput>
  ilock(ip);
    8000566c:	8526                	mv	a0,s1
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	1f8080e7          	jalr	504(ra) # 80003866 <ilock>
  ip->nlink--;
    80005676:	04a4d783          	lhu	a5,74(s1)
    8000567a:	37fd                	addiw	a5,a5,-1
    8000567c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005680:	8526                	mv	a0,s1
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	118080e7          	jalr	280(ra) # 8000379a <iupdate>
  iunlockput(ip);
    8000568a:	8526                	mv	a0,s1
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	43e080e7          	jalr	1086(ra) # 80003aca <iunlockput>
  end_op();
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	c1a080e7          	jalr	-998(ra) # 800042ae <end_op>
  return -1;
    8000569c:	57fd                	li	a5,-1
}
    8000569e:	853e                	mv	a0,a5
    800056a0:	70b2                	ld	ra,296(sp)
    800056a2:	7412                	ld	s0,288(sp)
    800056a4:	64f2                	ld	s1,280(sp)
    800056a6:	6952                	ld	s2,272(sp)
    800056a8:	6155                	addi	sp,sp,304
    800056aa:	8082                	ret

00000000800056ac <sys_unlink>:
{
    800056ac:	7151                	addi	sp,sp,-240
    800056ae:	f586                	sd	ra,232(sp)
    800056b0:	f1a2                	sd	s0,224(sp)
    800056b2:	eda6                	sd	s1,216(sp)
    800056b4:	e9ca                	sd	s2,208(sp)
    800056b6:	e5ce                	sd	s3,200(sp)
    800056b8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056ba:	08000613          	li	a2,128
    800056be:	f3040593          	addi	a1,s0,-208
    800056c2:	4501                	li	a0,0
    800056c4:	ffffd097          	auipc	ra,0xffffd
    800056c8:	53e080e7          	jalr	1342(ra) # 80002c02 <argstr>
    800056cc:	16054f63          	bltz	a0,8000584a <sys_unlink+0x19e>
  begin_op();
    800056d0:	fffff097          	auipc	ra,0xfffff
    800056d4:	b5e080e7          	jalr	-1186(ra) # 8000422e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056d8:	fb040593          	addi	a1,s0,-80
    800056dc:	f3040513          	addi	a0,s0,-208
    800056e0:	fffff097          	auipc	ra,0xfffff
    800056e4:	95e080e7          	jalr	-1698(ra) # 8000403e <nameiparent>
    800056e8:	89aa                	mv	s3,a0
    800056ea:	c979                	beqz	a0,800057c0 <sys_unlink+0x114>
  ilock(dp);
    800056ec:	ffffe097          	auipc	ra,0xffffe
    800056f0:	17a080e7          	jalr	378(ra) # 80003866 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056f4:	00003597          	auipc	a1,0x3
    800056f8:	18c58593          	addi	a1,a1,396 # 80008880 <syscallname+0x3c0>
    800056fc:	fb040513          	addi	a0,s0,-80
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	62c080e7          	jalr	1580(ra) # 80003d2c <namecmp>
    80005708:	14050863          	beqz	a0,80005858 <sys_unlink+0x1ac>
    8000570c:	00003597          	auipc	a1,0x3
    80005710:	17c58593          	addi	a1,a1,380 # 80008888 <syscallname+0x3c8>
    80005714:	fb040513          	addi	a0,s0,-80
    80005718:	ffffe097          	auipc	ra,0xffffe
    8000571c:	614080e7          	jalr	1556(ra) # 80003d2c <namecmp>
    80005720:	12050c63          	beqz	a0,80005858 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005724:	f2c40613          	addi	a2,s0,-212
    80005728:	fb040593          	addi	a1,s0,-80
    8000572c:	854e                	mv	a0,s3
    8000572e:	ffffe097          	auipc	ra,0xffffe
    80005732:	618080e7          	jalr	1560(ra) # 80003d46 <dirlookup>
    80005736:	84aa                	mv	s1,a0
    80005738:	12050063          	beqz	a0,80005858 <sys_unlink+0x1ac>
  ilock(ip);
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	12a080e7          	jalr	298(ra) # 80003866 <ilock>
  if(ip->nlink < 1)
    80005744:	04a49783          	lh	a5,74(s1)
    80005748:	08f05263          	blez	a5,800057cc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000574c:	04449703          	lh	a4,68(s1)
    80005750:	4785                	li	a5,1
    80005752:	08f70563          	beq	a4,a5,800057dc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005756:	4641                	li	a2,16
    80005758:	4581                	li	a1,0
    8000575a:	fc040513          	addi	a0,s0,-64
    8000575e:	ffffb097          	auipc	ra,0xffffb
    80005762:	64a080e7          	jalr	1610(ra) # 80000da8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005766:	4741                	li	a4,16
    80005768:	f2c42683          	lw	a3,-212(s0)
    8000576c:	fc040613          	addi	a2,s0,-64
    80005770:	4581                	li	a1,0
    80005772:	854e                	mv	a0,s3
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	49e080e7          	jalr	1182(ra) # 80003c12 <writei>
    8000577c:	47c1                	li	a5,16
    8000577e:	0af51363          	bne	a0,a5,80005824 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80005782:	04449703          	lh	a4,68(s1)
    80005786:	4785                	li	a5,1
    80005788:	0af70663          	beq	a4,a5,80005834 <sys_unlink+0x188>
  iunlockput(dp);
    8000578c:	854e                	mv	a0,s3
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	33c080e7          	jalr	828(ra) # 80003aca <iunlockput>
  ip->nlink--;
    80005796:	04a4d783          	lhu	a5,74(s1)
    8000579a:	37fd                	addiw	a5,a5,-1
    8000579c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a0:	8526                	mv	a0,s1
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	ff8080e7          	jalr	-8(ra) # 8000379a <iupdate>
  iunlockput(ip);
    800057aa:	8526                	mv	a0,s1
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	31e080e7          	jalr	798(ra) # 80003aca <iunlockput>
  end_op();
    800057b4:	fffff097          	auipc	ra,0xfffff
    800057b8:	afa080e7          	jalr	-1286(ra) # 800042ae <end_op>
  return 0;
    800057bc:	4501                	li	a0,0
    800057be:	a07d                	j	8000586c <sys_unlink+0x1c0>
    end_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	aee080e7          	jalr	-1298(ra) # 800042ae <end_op>
    return -1;
    800057c8:	557d                	li	a0,-1
    800057ca:	a04d                	j	8000586c <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    800057cc:	00003517          	auipc	a0,0x3
    800057d0:	0e450513          	addi	a0,a0,228 # 800088b0 <syscallname+0x3f0>
    800057d4:	ffffb097          	auipc	ra,0xffffb
    800057d8:	da0080e7          	jalr	-608(ra) # 80000574 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057dc:	44f8                	lw	a4,76(s1)
    800057de:	02000793          	li	a5,32
    800057e2:	f6e7fae3          	bleu	a4,a5,80005756 <sys_unlink+0xaa>
    800057e6:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057ea:	4741                	li	a4,16
    800057ec:	86ca                	mv	a3,s2
    800057ee:	f1840613          	addi	a2,s0,-232
    800057f2:	4581                	li	a1,0
    800057f4:	8526                	mv	a0,s1
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	326080e7          	jalr	806(ra) # 80003b1c <readi>
    800057fe:	47c1                	li	a5,16
    80005800:	00f51a63          	bne	a0,a5,80005814 <sys_unlink+0x168>
    if(de.inum != 0)
    80005804:	f1845783          	lhu	a5,-232(s0)
    80005808:	e3b9                	bnez	a5,8000584e <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000580a:	2941                	addiw	s2,s2,16
    8000580c:	44fc                	lw	a5,76(s1)
    8000580e:	fcf96ee3          	bltu	s2,a5,800057ea <sys_unlink+0x13e>
    80005812:	b791                	j	80005756 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005814:	00003517          	auipc	a0,0x3
    80005818:	0b450513          	addi	a0,a0,180 # 800088c8 <syscallname+0x408>
    8000581c:	ffffb097          	auipc	ra,0xffffb
    80005820:	d58080e7          	jalr	-680(ra) # 80000574 <panic>
    panic("unlink: writei");
    80005824:	00003517          	auipc	a0,0x3
    80005828:	0bc50513          	addi	a0,a0,188 # 800088e0 <syscallname+0x420>
    8000582c:	ffffb097          	auipc	ra,0xffffb
    80005830:	d48080e7          	jalr	-696(ra) # 80000574 <panic>
    dp->nlink--;
    80005834:	04a9d783          	lhu	a5,74(s3)
    80005838:	37fd                	addiw	a5,a5,-1
    8000583a:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    8000583e:	854e                	mv	a0,s3
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	f5a080e7          	jalr	-166(ra) # 8000379a <iupdate>
    80005848:	b791                	j	8000578c <sys_unlink+0xe0>
    return -1;
    8000584a:	557d                	li	a0,-1
    8000584c:	a005                	j	8000586c <sys_unlink+0x1c0>
    iunlockput(ip);
    8000584e:	8526                	mv	a0,s1
    80005850:	ffffe097          	auipc	ra,0xffffe
    80005854:	27a080e7          	jalr	634(ra) # 80003aca <iunlockput>
  iunlockput(dp);
    80005858:	854e                	mv	a0,s3
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	270080e7          	jalr	624(ra) # 80003aca <iunlockput>
  end_op();
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	a4c080e7          	jalr	-1460(ra) # 800042ae <end_op>
  return -1;
    8000586a:	557d                	li	a0,-1
}
    8000586c:	70ae                	ld	ra,232(sp)
    8000586e:	740e                	ld	s0,224(sp)
    80005870:	64ee                	ld	s1,216(sp)
    80005872:	694e                	ld	s2,208(sp)
    80005874:	69ae                	ld	s3,200(sp)
    80005876:	616d                	addi	sp,sp,240
    80005878:	8082                	ret

000000008000587a <sys_open>:

uint64
sys_open(void)
{
    8000587a:	7131                	addi	sp,sp,-192
    8000587c:	fd06                	sd	ra,184(sp)
    8000587e:	f922                	sd	s0,176(sp)
    80005880:	f526                	sd	s1,168(sp)
    80005882:	f14a                	sd	s2,160(sp)
    80005884:	ed4e                	sd	s3,152(sp)
    80005886:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005888:	08000613          	li	a2,128
    8000588c:	f5040593          	addi	a1,s0,-176
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	370080e7          	jalr	880(ra) # 80002c02 <argstr>
    return -1;
    8000589a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000589c:	0c054163          	bltz	a0,8000595e <sys_open+0xe4>
    800058a0:	f4c40593          	addi	a1,s0,-180
    800058a4:	4505                	li	a0,1
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	318080e7          	jalr	792(ra) # 80002bbe <argint>
    800058ae:	0a054863          	bltz	a0,8000595e <sys_open+0xe4>

  begin_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	97c080e7          	jalr	-1668(ra) # 8000422e <begin_op>

  if(omode & O_CREATE){
    800058ba:	f4c42783          	lw	a5,-180(s0)
    800058be:	2007f793          	andi	a5,a5,512
    800058c2:	cbdd                	beqz	a5,80005978 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058c4:	4681                	li	a3,0
    800058c6:	4601                	li	a2,0
    800058c8:	4589                	li	a1,2
    800058ca:	f5040513          	addi	a0,s0,-176
    800058ce:	00000097          	auipc	ra,0x0
    800058d2:	976080e7          	jalr	-1674(ra) # 80005244 <create>
    800058d6:	892a                	mv	s2,a0
    if(ip == 0){
    800058d8:	c959                	beqz	a0,8000596e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058da:	04491703          	lh	a4,68(s2)
    800058de:	478d                	li	a5,3
    800058e0:	00f71763          	bne	a4,a5,800058ee <sys_open+0x74>
    800058e4:	04695703          	lhu	a4,70(s2)
    800058e8:	47a5                	li	a5,9
    800058ea:	0ce7ec63          	bltu	a5,a4,800059c2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	d72080e7          	jalr	-654(ra) # 80004660 <filealloc>
    800058f6:	89aa                	mv	s3,a0
    800058f8:	10050263          	beqz	a0,800059fc <sys_open+0x182>
    800058fc:	00000097          	auipc	ra,0x0
    80005900:	900080e7          	jalr	-1792(ra) # 800051fc <fdalloc>
    80005904:	84aa                	mv	s1,a0
    80005906:	0e054663          	bltz	a0,800059f2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000590a:	04491703          	lh	a4,68(s2)
    8000590e:	478d                	li	a5,3
    80005910:	0cf70463          	beq	a4,a5,800059d8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005914:	4789                	li	a5,2
    80005916:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000591a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000591e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005922:	f4c42783          	lw	a5,-180(s0)
    80005926:	0017c713          	xori	a4,a5,1
    8000592a:	8b05                	andi	a4,a4,1
    8000592c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005930:	0037f713          	andi	a4,a5,3
    80005934:	00e03733          	snez	a4,a4
    80005938:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000593c:	4007f793          	andi	a5,a5,1024
    80005940:	c791                	beqz	a5,8000594c <sys_open+0xd2>
    80005942:	04491703          	lh	a4,68(s2)
    80005946:	4789                	li	a5,2
    80005948:	08f70f63          	beq	a4,a5,800059e6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000594c:	854a                	mv	a0,s2
    8000594e:	ffffe097          	auipc	ra,0xffffe
    80005952:	fdc080e7          	jalr	-36(ra) # 8000392a <iunlock>
  end_op();
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	958080e7          	jalr	-1704(ra) # 800042ae <end_op>

  return fd;
}
    8000595e:	8526                	mv	a0,s1
    80005960:	70ea                	ld	ra,184(sp)
    80005962:	744a                	ld	s0,176(sp)
    80005964:	74aa                	ld	s1,168(sp)
    80005966:	790a                	ld	s2,160(sp)
    80005968:	69ea                	ld	s3,152(sp)
    8000596a:	6129                	addi	sp,sp,192
    8000596c:	8082                	ret
      end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	940080e7          	jalr	-1728(ra) # 800042ae <end_op>
      return -1;
    80005976:	b7e5                	j	8000595e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005978:	f5040513          	addi	a0,s0,-176
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	6a4080e7          	jalr	1700(ra) # 80004020 <namei>
    80005984:	892a                	mv	s2,a0
    80005986:	c905                	beqz	a0,800059b6 <sys_open+0x13c>
    ilock(ip);
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	ede080e7          	jalr	-290(ra) # 80003866 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005990:	04491703          	lh	a4,68(s2)
    80005994:	4785                	li	a5,1
    80005996:	f4f712e3          	bne	a4,a5,800058da <sys_open+0x60>
    8000599a:	f4c42783          	lw	a5,-180(s0)
    8000599e:	dba1                	beqz	a5,800058ee <sys_open+0x74>
      iunlockput(ip);
    800059a0:	854a                	mv	a0,s2
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	128080e7          	jalr	296(ra) # 80003aca <iunlockput>
      end_op();
    800059aa:	fffff097          	auipc	ra,0xfffff
    800059ae:	904080e7          	jalr	-1788(ra) # 800042ae <end_op>
      return -1;
    800059b2:	54fd                	li	s1,-1
    800059b4:	b76d                	j	8000595e <sys_open+0xe4>
      end_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	8f8080e7          	jalr	-1800(ra) # 800042ae <end_op>
      return -1;
    800059be:	54fd                	li	s1,-1
    800059c0:	bf79                	j	8000595e <sys_open+0xe4>
    iunlockput(ip);
    800059c2:	854a                	mv	a0,s2
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	106080e7          	jalr	262(ra) # 80003aca <iunlockput>
    end_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	8e2080e7          	jalr	-1822(ra) # 800042ae <end_op>
    return -1;
    800059d4:	54fd                	li	s1,-1
    800059d6:	b761                	j	8000595e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059d8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059dc:	04691783          	lh	a5,70(s2)
    800059e0:	02f99223          	sh	a5,36(s3)
    800059e4:	bf2d                	j	8000591e <sys_open+0xa4>
    itrunc(ip);
    800059e6:	854a                	mv	a0,s2
    800059e8:	ffffe097          	auipc	ra,0xffffe
    800059ec:	f8e080e7          	jalr	-114(ra) # 80003976 <itrunc>
    800059f0:	bfb1                	j	8000594c <sys_open+0xd2>
      fileclose(f);
    800059f2:	854e                	mv	a0,s3
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	d3c080e7          	jalr	-708(ra) # 80004730 <fileclose>
    iunlockput(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	0cc080e7          	jalr	204(ra) # 80003aca <iunlockput>
    end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	8a8080e7          	jalr	-1880(ra) # 800042ae <end_op>
    return -1;
    80005a0e:	54fd                	li	s1,-1
    80005a10:	b7b9                	j	8000595e <sys_open+0xe4>

0000000080005a12 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a12:	7175                	addi	sp,sp,-144
    80005a14:	e506                	sd	ra,136(sp)
    80005a16:	e122                	sd	s0,128(sp)
    80005a18:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	814080e7          	jalr	-2028(ra) # 8000422e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a22:	08000613          	li	a2,128
    80005a26:	f7040593          	addi	a1,s0,-144
    80005a2a:	4501                	li	a0,0
    80005a2c:	ffffd097          	auipc	ra,0xffffd
    80005a30:	1d6080e7          	jalr	470(ra) # 80002c02 <argstr>
    80005a34:	02054963          	bltz	a0,80005a66 <sys_mkdir+0x54>
    80005a38:	4681                	li	a3,0
    80005a3a:	4601                	li	a2,0
    80005a3c:	4585                	li	a1,1
    80005a3e:	f7040513          	addi	a0,s0,-144
    80005a42:	00000097          	auipc	ra,0x0
    80005a46:	802080e7          	jalr	-2046(ra) # 80005244 <create>
    80005a4a:	cd11                	beqz	a0,80005a66 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	07e080e7          	jalr	126(ra) # 80003aca <iunlockput>
  end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	85a080e7          	jalr	-1958(ra) # 800042ae <end_op>
  return 0;
    80005a5c:	4501                	li	a0,0
}
    80005a5e:	60aa                	ld	ra,136(sp)
    80005a60:	640a                	ld	s0,128(sp)
    80005a62:	6149                	addi	sp,sp,144
    80005a64:	8082                	ret
    end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	848080e7          	jalr	-1976(ra) # 800042ae <end_op>
    return -1;
    80005a6e:	557d                	li	a0,-1
    80005a70:	b7fd                	j	80005a5e <sys_mkdir+0x4c>

0000000080005a72 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a72:	7135                	addi	sp,sp,-160
    80005a74:	ed06                	sd	ra,152(sp)
    80005a76:	e922                	sd	s0,144(sp)
    80005a78:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a7a:	ffffe097          	auipc	ra,0xffffe
    80005a7e:	7b4080e7          	jalr	1972(ra) # 8000422e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a82:	08000613          	li	a2,128
    80005a86:	f7040593          	addi	a1,s0,-144
    80005a8a:	4501                	li	a0,0
    80005a8c:	ffffd097          	auipc	ra,0xffffd
    80005a90:	176080e7          	jalr	374(ra) # 80002c02 <argstr>
    80005a94:	04054a63          	bltz	a0,80005ae8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005a98:	f6c40593          	addi	a1,s0,-148
    80005a9c:	4505                	li	a0,1
    80005a9e:	ffffd097          	auipc	ra,0xffffd
    80005aa2:	120080e7          	jalr	288(ra) # 80002bbe <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa6:	04054163          	bltz	a0,80005ae8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005aaa:	f6840593          	addi	a1,s0,-152
    80005aae:	4509                	li	a0,2
    80005ab0:	ffffd097          	auipc	ra,0xffffd
    80005ab4:	10e080e7          	jalr	270(ra) # 80002bbe <argint>
     argint(1, &major) < 0 ||
    80005ab8:	02054863          	bltz	a0,80005ae8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005abc:	f6841683          	lh	a3,-152(s0)
    80005ac0:	f6c41603          	lh	a2,-148(s0)
    80005ac4:	458d                	li	a1,3
    80005ac6:	f7040513          	addi	a0,s0,-144
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	77a080e7          	jalr	1914(ra) # 80005244 <create>
     argint(2, &minor) < 0 ||
    80005ad2:	c919                	beqz	a0,80005ae8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	ff6080e7          	jalr	-10(ra) # 80003aca <iunlockput>
  end_op();
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	7d2080e7          	jalr	2002(ra) # 800042ae <end_op>
  return 0;
    80005ae4:	4501                	li	a0,0
    80005ae6:	a031                	j	80005af2 <sys_mknod+0x80>
    end_op();
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	7c6080e7          	jalr	1990(ra) # 800042ae <end_op>
    return -1;
    80005af0:	557d                	li	a0,-1
}
    80005af2:	60ea                	ld	ra,152(sp)
    80005af4:	644a                	ld	s0,144(sp)
    80005af6:	610d                	addi	sp,sp,160
    80005af8:	8082                	ret

0000000080005afa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005afa:	7135                	addi	sp,sp,-160
    80005afc:	ed06                	sd	ra,152(sp)
    80005afe:	e922                	sd	s0,144(sp)
    80005b00:	e526                	sd	s1,136(sp)
    80005b02:	e14a                	sd	s2,128(sp)
    80005b04:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b06:	ffffc097          	auipc	ra,0xffffc
    80005b0a:	fb4080e7          	jalr	-76(ra) # 80001aba <myproc>
    80005b0e:	892a                	mv	s2,a0
  
  begin_op();
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	71e080e7          	jalr	1822(ra) # 8000422e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b18:	08000613          	li	a2,128
    80005b1c:	f6040593          	addi	a1,s0,-160
    80005b20:	4501                	li	a0,0
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	0e0080e7          	jalr	224(ra) # 80002c02 <argstr>
    80005b2a:	04054b63          	bltz	a0,80005b80 <sys_chdir+0x86>
    80005b2e:	f6040513          	addi	a0,s0,-160
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	4ee080e7          	jalr	1262(ra) # 80004020 <namei>
    80005b3a:	84aa                	mv	s1,a0
    80005b3c:	c131                	beqz	a0,80005b80 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	d28080e7          	jalr	-728(ra) # 80003866 <ilock>
  if(ip->type != T_DIR){
    80005b46:	04449703          	lh	a4,68(s1)
    80005b4a:	4785                	li	a5,1
    80005b4c:	04f71063          	bne	a4,a5,80005b8c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b50:	8526                	mv	a0,s1
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	dd8080e7          	jalr	-552(ra) # 8000392a <iunlock>
  iput(p->cwd);
    80005b5a:	15093503          	ld	a0,336(s2)
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	ec4080e7          	jalr	-316(ra) # 80003a22 <iput>
  end_op();
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	748080e7          	jalr	1864(ra) # 800042ae <end_op>
  p->cwd = ip;
    80005b6e:	14993823          	sd	s1,336(s2)
  return 0;
    80005b72:	4501                	li	a0,0
}
    80005b74:	60ea                	ld	ra,152(sp)
    80005b76:	644a                	ld	s0,144(sp)
    80005b78:	64aa                	ld	s1,136(sp)
    80005b7a:	690a                	ld	s2,128(sp)
    80005b7c:	610d                	addi	sp,sp,160
    80005b7e:	8082                	ret
    end_op();
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	72e080e7          	jalr	1838(ra) # 800042ae <end_op>
    return -1;
    80005b88:	557d                	li	a0,-1
    80005b8a:	b7ed                	j	80005b74 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b8c:	8526                	mv	a0,s1
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	f3c080e7          	jalr	-196(ra) # 80003aca <iunlockput>
    end_op();
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	718080e7          	jalr	1816(ra) # 800042ae <end_op>
    return -1;
    80005b9e:	557d                	li	a0,-1
    80005ba0:	bfd1                	j	80005b74 <sys_chdir+0x7a>

0000000080005ba2 <sys_exec>:

uint64
sys_exec(void)
{
    80005ba2:	7145                	addi	sp,sp,-464
    80005ba4:	e786                	sd	ra,456(sp)
    80005ba6:	e3a2                	sd	s0,448(sp)
    80005ba8:	ff26                	sd	s1,440(sp)
    80005baa:	fb4a                	sd	s2,432(sp)
    80005bac:	f74e                	sd	s3,424(sp)
    80005bae:	f352                	sd	s4,416(sp)
    80005bb0:	ef56                	sd	s5,408(sp)
    80005bb2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bb4:	08000613          	li	a2,128
    80005bb8:	f4040593          	addi	a1,s0,-192
    80005bbc:	4501                	li	a0,0
    80005bbe:	ffffd097          	auipc	ra,0xffffd
    80005bc2:	044080e7          	jalr	68(ra) # 80002c02 <argstr>
    return -1;
    80005bc6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bc8:	0e054c63          	bltz	a0,80005cc0 <sys_exec+0x11e>
    80005bcc:	e3840593          	addi	a1,s0,-456
    80005bd0:	4505                	li	a0,1
    80005bd2:	ffffd097          	auipc	ra,0xffffd
    80005bd6:	00e080e7          	jalr	14(ra) # 80002be0 <argaddr>
    80005bda:	0e054363          	bltz	a0,80005cc0 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005bde:	e4040913          	addi	s2,s0,-448
    80005be2:	10000613          	li	a2,256
    80005be6:	4581                	li	a1,0
    80005be8:	854a                	mv	a0,s2
    80005bea:	ffffb097          	auipc	ra,0xffffb
    80005bee:	1be080e7          	jalr	446(ra) # 80000da8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bf2:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005bf4:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005bf6:	02000a93          	li	s5,32
    80005bfa:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bfe:	00349513          	slli	a0,s1,0x3
    80005c02:	e3040593          	addi	a1,s0,-464
    80005c06:	e3843783          	ld	a5,-456(s0)
    80005c0a:	953e                	add	a0,a0,a5
    80005c0c:	ffffd097          	auipc	ra,0xffffd
    80005c10:	f16080e7          	jalr	-234(ra) # 80002b22 <fetchaddr>
    80005c14:	02054a63          	bltz	a0,80005c48 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c18:	e3043783          	ld	a5,-464(s0)
    80005c1c:	cfa9                	beqz	a5,80005c76 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c1e:	ffffb097          	auipc	ra,0xffffb
    80005c22:	f54080e7          	jalr	-172(ra) # 80000b72 <kalloc>
    80005c26:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c2a:	cd19                	beqz	a0,80005c48 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c2c:	6605                	lui	a2,0x1
    80005c2e:	85aa                	mv	a1,a0
    80005c30:	e3043503          	ld	a0,-464(s0)
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	f42080e7          	jalr	-190(ra) # 80002b76 <fetchstr>
    80005c3c:	00054663          	bltz	a0,80005c48 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c40:	0485                	addi	s1,s1,1
    80005c42:	0921                	addi	s2,s2,8
    80005c44:	fb549be3          	bne	s1,s5,80005bfa <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c48:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005c4c:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c4e:	c92d                	beqz	a0,80005cc0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c50:	ffffb097          	auipc	ra,0xffffb
    80005c54:	e22080e7          	jalr	-478(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c58:	e4840493          	addi	s1,s0,-440
    80005c5c:	10098993          	addi	s3,s3,256
    80005c60:	6088                	ld	a0,0(s1)
    80005c62:	cd31                	beqz	a0,80005cbe <sys_exec+0x11c>
    kfree(argv[i]);
    80005c64:	ffffb097          	auipc	ra,0xffffb
    80005c68:	e0e080e7          	jalr	-498(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6c:	04a1                	addi	s1,s1,8
    80005c6e:	ff3499e3          	bne	s1,s3,80005c60 <sys_exec+0xbe>
  return -1;
    80005c72:	597d                	li	s2,-1
    80005c74:	a0b1                	j	80005cc0 <sys_exec+0x11e>
      argv[i] = 0;
    80005c76:	0a0e                	slli	s4,s4,0x3
    80005c78:	fc040793          	addi	a5,s0,-64
    80005c7c:	9a3e                	add	s4,s4,a5
    80005c7e:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005c82:	e4040593          	addi	a1,s0,-448
    80005c86:	f4040513          	addi	a0,s0,-192
    80005c8a:	fffff097          	auipc	ra,0xfffff
    80005c8e:	166080e7          	jalr	358(ra) # 80004df0 <exec>
    80005c92:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c94:	e4043503          	ld	a0,-448(s0)
    80005c98:	c505                	beqz	a0,80005cc0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c9a:	ffffb097          	auipc	ra,0xffffb
    80005c9e:	dd8080e7          	jalr	-552(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca2:	e4840493          	addi	s1,s0,-440
    80005ca6:	10098993          	addi	s3,s3,256
    80005caa:	6088                	ld	a0,0(s1)
    80005cac:	c911                	beqz	a0,80005cc0 <sys_exec+0x11e>
    kfree(argv[i]);
    80005cae:	ffffb097          	auipc	ra,0xffffb
    80005cb2:	dc4080e7          	jalr	-572(ra) # 80000a72 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb6:	04a1                	addi	s1,s1,8
    80005cb8:	ff3499e3          	bne	s1,s3,80005caa <sys_exec+0x108>
    80005cbc:	a011                	j	80005cc0 <sys_exec+0x11e>
  return -1;
    80005cbe:	597d                	li	s2,-1
}
    80005cc0:	854a                	mv	a0,s2
    80005cc2:	60be                	ld	ra,456(sp)
    80005cc4:	641e                	ld	s0,448(sp)
    80005cc6:	74fa                	ld	s1,440(sp)
    80005cc8:	795a                	ld	s2,432(sp)
    80005cca:	79ba                	ld	s3,424(sp)
    80005ccc:	7a1a                	ld	s4,416(sp)
    80005cce:	6afa                	ld	s5,408(sp)
    80005cd0:	6179                	addi	sp,sp,464
    80005cd2:	8082                	ret

0000000080005cd4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cd4:	7139                	addi	sp,sp,-64
    80005cd6:	fc06                	sd	ra,56(sp)
    80005cd8:	f822                	sd	s0,48(sp)
    80005cda:	f426                	sd	s1,40(sp)
    80005cdc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cde:	ffffc097          	auipc	ra,0xffffc
    80005ce2:	ddc080e7          	jalr	-548(ra) # 80001aba <myproc>
    80005ce6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005ce8:	fd840593          	addi	a1,s0,-40
    80005cec:	4501                	li	a0,0
    80005cee:	ffffd097          	auipc	ra,0xffffd
    80005cf2:	ef2080e7          	jalr	-270(ra) # 80002be0 <argaddr>
    return -1;
    80005cf6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005cf8:	0c054f63          	bltz	a0,80005dd6 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005cfc:	fc840593          	addi	a1,s0,-56
    80005d00:	fd040513          	addi	a0,s0,-48
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	d74080e7          	jalr	-652(ra) # 80004a78 <pipealloc>
    return -1;
    80005d0c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d0e:	0c054463          	bltz	a0,80005dd6 <sys_pipe+0x102>
  fd0 = -1;
    80005d12:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d16:	fd043503          	ld	a0,-48(s0)
    80005d1a:	fffff097          	auipc	ra,0xfffff
    80005d1e:	4e2080e7          	jalr	1250(ra) # 800051fc <fdalloc>
    80005d22:	fca42223          	sw	a0,-60(s0)
    80005d26:	08054b63          	bltz	a0,80005dbc <sys_pipe+0xe8>
    80005d2a:	fc843503          	ld	a0,-56(s0)
    80005d2e:	fffff097          	auipc	ra,0xfffff
    80005d32:	4ce080e7          	jalr	1230(ra) # 800051fc <fdalloc>
    80005d36:	fca42023          	sw	a0,-64(s0)
    80005d3a:	06054863          	bltz	a0,80005daa <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d3e:	4691                	li	a3,4
    80005d40:	fc440613          	addi	a2,s0,-60
    80005d44:	fd843583          	ld	a1,-40(s0)
    80005d48:	68a8                	ld	a0,80(s1)
    80005d4a:	ffffc097          	auipc	ra,0xffffc
    80005d4e:	a4c080e7          	jalr	-1460(ra) # 80001796 <copyout>
    80005d52:	02054063          	bltz	a0,80005d72 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d56:	4691                	li	a3,4
    80005d58:	fc040613          	addi	a2,s0,-64
    80005d5c:	fd843583          	ld	a1,-40(s0)
    80005d60:	0591                	addi	a1,a1,4
    80005d62:	68a8                	ld	a0,80(s1)
    80005d64:	ffffc097          	auipc	ra,0xffffc
    80005d68:	a32080e7          	jalr	-1486(ra) # 80001796 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d6c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d6e:	06055463          	bgez	a0,80005dd6 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005d72:	fc442783          	lw	a5,-60(s0)
    80005d76:	07e9                	addi	a5,a5,26
    80005d78:	078e                	slli	a5,a5,0x3
    80005d7a:	97a6                	add	a5,a5,s1
    80005d7c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d80:	fc042783          	lw	a5,-64(s0)
    80005d84:	07e9                	addi	a5,a5,26
    80005d86:	078e                	slli	a5,a5,0x3
    80005d88:	94be                	add	s1,s1,a5
    80005d8a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d8e:	fd043503          	ld	a0,-48(s0)
    80005d92:	fffff097          	auipc	ra,0xfffff
    80005d96:	99e080e7          	jalr	-1634(ra) # 80004730 <fileclose>
    fileclose(wf);
    80005d9a:	fc843503          	ld	a0,-56(s0)
    80005d9e:	fffff097          	auipc	ra,0xfffff
    80005da2:	992080e7          	jalr	-1646(ra) # 80004730 <fileclose>
    return -1;
    80005da6:	57fd                	li	a5,-1
    80005da8:	a03d                	j	80005dd6 <sys_pipe+0x102>
    if(fd0 >= 0)
    80005daa:	fc442783          	lw	a5,-60(s0)
    80005dae:	0007c763          	bltz	a5,80005dbc <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005db2:	07e9                	addi	a5,a5,26
    80005db4:	078e                	slli	a5,a5,0x3
    80005db6:	94be                	add	s1,s1,a5
    80005db8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005dbc:	fd043503          	ld	a0,-48(s0)
    80005dc0:	fffff097          	auipc	ra,0xfffff
    80005dc4:	970080e7          	jalr	-1680(ra) # 80004730 <fileclose>
    fileclose(wf);
    80005dc8:	fc843503          	ld	a0,-56(s0)
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	964080e7          	jalr	-1692(ra) # 80004730 <fileclose>
    return -1;
    80005dd4:	57fd                	li	a5,-1
}
    80005dd6:	853e                	mv	a0,a5
    80005dd8:	70e2                	ld	ra,56(sp)
    80005dda:	7442                	ld	s0,48(sp)
    80005ddc:	74a2                	ld	s1,40(sp)
    80005dde:	6121                	addi	sp,sp,64
    80005de0:	8082                	ret
	...

0000000080005df0 <kernelvec>:
    80005df0:	7111                	addi	sp,sp,-256
    80005df2:	e006                	sd	ra,0(sp)
    80005df4:	e40a                	sd	sp,8(sp)
    80005df6:	e80e                	sd	gp,16(sp)
    80005df8:	ec12                	sd	tp,24(sp)
    80005dfa:	f016                	sd	t0,32(sp)
    80005dfc:	f41a                	sd	t1,40(sp)
    80005dfe:	f81e                	sd	t2,48(sp)
    80005e00:	fc22                	sd	s0,56(sp)
    80005e02:	e0a6                	sd	s1,64(sp)
    80005e04:	e4aa                	sd	a0,72(sp)
    80005e06:	e8ae                	sd	a1,80(sp)
    80005e08:	ecb2                	sd	a2,88(sp)
    80005e0a:	f0b6                	sd	a3,96(sp)
    80005e0c:	f4ba                	sd	a4,104(sp)
    80005e0e:	f8be                	sd	a5,112(sp)
    80005e10:	fcc2                	sd	a6,120(sp)
    80005e12:	e146                	sd	a7,128(sp)
    80005e14:	e54a                	sd	s2,136(sp)
    80005e16:	e94e                	sd	s3,144(sp)
    80005e18:	ed52                	sd	s4,152(sp)
    80005e1a:	f156                	sd	s5,160(sp)
    80005e1c:	f55a                	sd	s6,168(sp)
    80005e1e:	f95e                	sd	s7,176(sp)
    80005e20:	fd62                	sd	s8,184(sp)
    80005e22:	e1e6                	sd	s9,192(sp)
    80005e24:	e5ea                	sd	s10,200(sp)
    80005e26:	e9ee                	sd	s11,208(sp)
    80005e28:	edf2                	sd	t3,216(sp)
    80005e2a:	f1f6                	sd	t4,224(sp)
    80005e2c:	f5fa                	sd	t5,232(sp)
    80005e2e:	f9fe                	sd	t6,240(sp)
    80005e30:	bbbfc0ef          	jal	ra,800029ea <kerneltrap>
    80005e34:	6082                	ld	ra,0(sp)
    80005e36:	6122                	ld	sp,8(sp)
    80005e38:	61c2                	ld	gp,16(sp)
    80005e3a:	7282                	ld	t0,32(sp)
    80005e3c:	7322                	ld	t1,40(sp)
    80005e3e:	73c2                	ld	t2,48(sp)
    80005e40:	7462                	ld	s0,56(sp)
    80005e42:	6486                	ld	s1,64(sp)
    80005e44:	6526                	ld	a0,72(sp)
    80005e46:	65c6                	ld	a1,80(sp)
    80005e48:	6666                	ld	a2,88(sp)
    80005e4a:	7686                	ld	a3,96(sp)
    80005e4c:	7726                	ld	a4,104(sp)
    80005e4e:	77c6                	ld	a5,112(sp)
    80005e50:	7866                	ld	a6,120(sp)
    80005e52:	688a                	ld	a7,128(sp)
    80005e54:	692a                	ld	s2,136(sp)
    80005e56:	69ca                	ld	s3,144(sp)
    80005e58:	6a6a                	ld	s4,152(sp)
    80005e5a:	7a8a                	ld	s5,160(sp)
    80005e5c:	7b2a                	ld	s6,168(sp)
    80005e5e:	7bca                	ld	s7,176(sp)
    80005e60:	7c6a                	ld	s8,184(sp)
    80005e62:	6c8e                	ld	s9,192(sp)
    80005e64:	6d2e                	ld	s10,200(sp)
    80005e66:	6dce                	ld	s11,208(sp)
    80005e68:	6e6e                	ld	t3,216(sp)
    80005e6a:	7e8e                	ld	t4,224(sp)
    80005e6c:	7f2e                	ld	t5,232(sp)
    80005e6e:	7fce                	ld	t6,240(sp)
    80005e70:	6111                	addi	sp,sp,256
    80005e72:	10200073          	sret
    80005e76:	00000013          	nop
    80005e7a:	00000013          	nop
    80005e7e:	0001                	nop

0000000080005e80 <timervec>:
    80005e80:	34051573          	csrrw	a0,mscratch,a0
    80005e84:	e10c                	sd	a1,0(a0)
    80005e86:	e510                	sd	a2,8(a0)
    80005e88:	e914                	sd	a3,16(a0)
    80005e8a:	710c                	ld	a1,32(a0)
    80005e8c:	7510                	ld	a2,40(a0)
    80005e8e:	6194                	ld	a3,0(a1)
    80005e90:	96b2                	add	a3,a3,a2
    80005e92:	e194                	sd	a3,0(a1)
    80005e94:	4589                	li	a1,2
    80005e96:	14459073          	csrw	sip,a1
    80005e9a:	6914                	ld	a3,16(a0)
    80005e9c:	6510                	ld	a2,8(a0)
    80005e9e:	610c                	ld	a1,0(a0)
    80005ea0:	34051573          	csrrw	a0,mscratch,a0
    80005ea4:	30200073          	mret
	...

0000000080005eaa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eaa:	1141                	addi	sp,sp,-16
    80005eac:	e422                	sd	s0,8(sp)
    80005eae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005eb0:	0c0007b7          	lui	a5,0xc000
    80005eb4:	4705                	li	a4,1
    80005eb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005eb8:	c3d8                	sw	a4,4(a5)
}
    80005eba:	6422                	ld	s0,8(sp)
    80005ebc:	0141                	addi	sp,sp,16
    80005ebe:	8082                	ret

0000000080005ec0 <plicinithart>:

void
plicinithart(void)
{
    80005ec0:	1141                	addi	sp,sp,-16
    80005ec2:	e406                	sd	ra,8(sp)
    80005ec4:	e022                	sd	s0,0(sp)
    80005ec6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	bc6080e7          	jalr	-1082(ra) # 80001a8e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ed0:	0085171b          	slliw	a4,a0,0x8
    80005ed4:	0c0027b7          	lui	a5,0xc002
    80005ed8:	97ba                	add	a5,a5,a4
    80005eda:	40200713          	li	a4,1026
    80005ede:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ee2:	00d5151b          	slliw	a0,a0,0xd
    80005ee6:	0c2017b7          	lui	a5,0xc201
    80005eea:	953e                	add	a0,a0,a5
    80005eec:	00052023          	sw	zero,0(a0)
}
    80005ef0:	60a2                	ld	ra,8(sp)
    80005ef2:	6402                	ld	s0,0(sp)
    80005ef4:	0141                	addi	sp,sp,16
    80005ef6:	8082                	ret

0000000080005ef8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ef8:	1141                	addi	sp,sp,-16
    80005efa:	e406                	sd	ra,8(sp)
    80005efc:	e022                	sd	s0,0(sp)
    80005efe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f00:	ffffc097          	auipc	ra,0xffffc
    80005f04:	b8e080e7          	jalr	-1138(ra) # 80001a8e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f08:	00d5151b          	slliw	a0,a0,0xd
    80005f0c:	0c2017b7          	lui	a5,0xc201
    80005f10:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f12:	43c8                	lw	a0,4(a5)
    80005f14:	60a2                	ld	ra,8(sp)
    80005f16:	6402                	ld	s0,0(sp)
    80005f18:	0141                	addi	sp,sp,16
    80005f1a:	8082                	ret

0000000080005f1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f1c:	1101                	addi	sp,sp,-32
    80005f1e:	ec06                	sd	ra,24(sp)
    80005f20:	e822                	sd	s0,16(sp)
    80005f22:	e426                	sd	s1,8(sp)
    80005f24:	1000                	addi	s0,sp,32
    80005f26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f28:	ffffc097          	auipc	ra,0xffffc
    80005f2c:	b66080e7          	jalr	-1178(ra) # 80001a8e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f30:	00d5151b          	slliw	a0,a0,0xd
    80005f34:	0c2017b7          	lui	a5,0xc201
    80005f38:	97aa                	add	a5,a5,a0
    80005f3a:	c3c4                	sw	s1,4(a5)
}
    80005f3c:	60e2                	ld	ra,24(sp)
    80005f3e:	6442                	ld	s0,16(sp)
    80005f40:	64a2                	ld	s1,8(sp)
    80005f42:	6105                	addi	sp,sp,32
    80005f44:	8082                	ret

0000000080005f46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f46:	1141                	addi	sp,sp,-16
    80005f48:	e406                	sd	ra,8(sp)
    80005f4a:	e022                	sd	s0,0(sp)
    80005f4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f4e:	479d                	li	a5,7
    80005f50:	04a7cd63          	blt	a5,a0,80005faa <free_desc+0x64>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005f54:	0001d797          	auipc	a5,0x1d
    80005f58:	0ac78793          	addi	a5,a5,172 # 80023000 <disk>
    80005f5c:	00a78733          	add	a4,a5,a0
    80005f60:	6789                	lui	a5,0x2
    80005f62:	97ba                	add	a5,a5,a4
    80005f64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f68:	eba9                	bnez	a5,80005fba <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f6a:	0001f797          	auipc	a5,0x1f
    80005f6e:	09678793          	addi	a5,a5,150 # 80025000 <disk+0x2000>
    80005f72:	639c                	ld	a5,0(a5)
    80005f74:	00451713          	slli	a4,a0,0x4
    80005f78:	97ba                	add	a5,a5,a4
    80005f7a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f7e:	0001d797          	auipc	a5,0x1d
    80005f82:	08278793          	addi	a5,a5,130 # 80023000 <disk>
    80005f86:	97aa                	add	a5,a5,a0
    80005f88:	6509                	lui	a0,0x2
    80005f8a:	953e                	add	a0,a0,a5
    80005f8c:	4785                	li	a5,1
    80005f8e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f92:	0001f517          	auipc	a0,0x1f
    80005f96:	08650513          	addi	a0,a0,134 # 80025018 <disk+0x2018>
    80005f9a:	ffffc097          	auipc	ra,0xffffc
    80005f9e:	4c4080e7          	jalr	1220(ra) # 8000245e <wakeup>
}
    80005fa2:	60a2                	ld	ra,8(sp)
    80005fa4:	6402                	ld	s0,0(sp)
    80005fa6:	0141                	addi	sp,sp,16
    80005fa8:	8082                	ret
    panic("virtio_disk_intr 1");
    80005faa:	00003517          	auipc	a0,0x3
    80005fae:	94650513          	addi	a0,a0,-1722 # 800088f0 <syscallname+0x430>
    80005fb2:	ffffa097          	auipc	ra,0xffffa
    80005fb6:	5c2080e7          	jalr	1474(ra) # 80000574 <panic>
    panic("virtio_disk_intr 2");
    80005fba:	00003517          	auipc	a0,0x3
    80005fbe:	94e50513          	addi	a0,a0,-1714 # 80008908 <syscallname+0x448>
    80005fc2:	ffffa097          	auipc	ra,0xffffa
    80005fc6:	5b2080e7          	jalr	1458(ra) # 80000574 <panic>

0000000080005fca <virtio_disk_init>:
{
    80005fca:	1101                	addi	sp,sp,-32
    80005fcc:	ec06                	sd	ra,24(sp)
    80005fce:	e822                	sd	s0,16(sp)
    80005fd0:	e426                	sd	s1,8(sp)
    80005fd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fd4:	00003597          	auipc	a1,0x3
    80005fd8:	94c58593          	addi	a1,a1,-1716 # 80008920 <syscallname+0x460>
    80005fdc:	0001f517          	auipc	a0,0x1f
    80005fe0:	0cc50513          	addi	a0,a0,204 # 800250a8 <disk+0x20a8>
    80005fe4:	ffffb097          	auipc	ra,0xffffb
    80005fe8:	c38080e7          	jalr	-968(ra) # 80000c1c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fec:	100017b7          	lui	a5,0x10001
    80005ff0:	4398                	lw	a4,0(a5)
    80005ff2:	2701                	sext.w	a4,a4
    80005ff4:	747277b7          	lui	a5,0x74727
    80005ff8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ffc:	0ef71163          	bne	a4,a5,800060de <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006000:	100017b7          	lui	a5,0x10001
    80006004:	43dc                	lw	a5,4(a5)
    80006006:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006008:	4705                	li	a4,1
    8000600a:	0ce79a63          	bne	a5,a4,800060de <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000600e:	100017b7          	lui	a5,0x10001
    80006012:	479c                	lw	a5,8(a5)
    80006014:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006016:	4709                	li	a4,2
    80006018:	0ce79363          	bne	a5,a4,800060de <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000601c:	100017b7          	lui	a5,0x10001
    80006020:	47d8                	lw	a4,12(a5)
    80006022:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006024:	554d47b7          	lui	a5,0x554d4
    80006028:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000602c:	0af71963          	bne	a4,a5,800060de <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006030:	100017b7          	lui	a5,0x10001
    80006034:	4705                	li	a4,1
    80006036:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006038:	470d                	li	a4,3
    8000603a:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000603c:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000603e:	c7ffe737          	lui	a4,0xc7ffe
    80006042:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80006046:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006048:	2701                	sext.w	a4,a4
    8000604a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604c:	472d                	li	a4,11
    8000604e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006050:	473d                	li	a4,15
    80006052:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006054:	6705                	lui	a4,0x1
    80006056:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006058:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000605c:	5bdc                	lw	a5,52(a5)
    8000605e:	2781                	sext.w	a5,a5
  if(max == 0)
    80006060:	c7d9                	beqz	a5,800060ee <virtio_disk_init+0x124>
  if(max < NUM)
    80006062:	471d                	li	a4,7
    80006064:	08f77d63          	bleu	a5,a4,800060fe <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006068:	100014b7          	lui	s1,0x10001
    8000606c:	47a1                	li	a5,8
    8000606e:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006070:	6609                	lui	a2,0x2
    80006072:	4581                	li	a1,0
    80006074:	0001d517          	auipc	a0,0x1d
    80006078:	f8c50513          	addi	a0,a0,-116 # 80023000 <disk>
    8000607c:	ffffb097          	auipc	ra,0xffffb
    80006080:	d2c080e7          	jalr	-724(ra) # 80000da8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006084:	0001d717          	auipc	a4,0x1d
    80006088:	f7c70713          	addi	a4,a4,-132 # 80023000 <disk>
    8000608c:	00c75793          	srli	a5,a4,0xc
    80006090:	2781                	sext.w	a5,a5
    80006092:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006094:	0001f797          	auipc	a5,0x1f
    80006098:	f6c78793          	addi	a5,a5,-148 # 80025000 <disk+0x2000>
    8000609c:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000609e:	0001d717          	auipc	a4,0x1d
    800060a2:	fe270713          	addi	a4,a4,-30 # 80023080 <disk+0x80>
    800060a6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060a8:	0001e717          	auipc	a4,0x1e
    800060ac:	f5870713          	addi	a4,a4,-168 # 80024000 <disk+0x1000>
    800060b0:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060b2:	4705                	li	a4,1
    800060b4:	00e78c23          	sb	a4,24(a5)
    800060b8:	00e78ca3          	sb	a4,25(a5)
    800060bc:	00e78d23          	sb	a4,26(a5)
    800060c0:	00e78da3          	sb	a4,27(a5)
    800060c4:	00e78e23          	sb	a4,28(a5)
    800060c8:	00e78ea3          	sb	a4,29(a5)
    800060cc:	00e78f23          	sb	a4,30(a5)
    800060d0:	00e78fa3          	sb	a4,31(a5)
}
    800060d4:	60e2                	ld	ra,24(sp)
    800060d6:	6442                	ld	s0,16(sp)
    800060d8:	64a2                	ld	s1,8(sp)
    800060da:	6105                	addi	sp,sp,32
    800060dc:	8082                	ret
    panic("could not find virtio disk");
    800060de:	00003517          	auipc	a0,0x3
    800060e2:	85250513          	addi	a0,a0,-1966 # 80008930 <syscallname+0x470>
    800060e6:	ffffa097          	auipc	ra,0xffffa
    800060ea:	48e080e7          	jalr	1166(ra) # 80000574 <panic>
    panic("virtio disk has no queue 0");
    800060ee:	00003517          	auipc	a0,0x3
    800060f2:	86250513          	addi	a0,a0,-1950 # 80008950 <syscallname+0x490>
    800060f6:	ffffa097          	auipc	ra,0xffffa
    800060fa:	47e080e7          	jalr	1150(ra) # 80000574 <panic>
    panic("virtio disk max queue too short");
    800060fe:	00003517          	auipc	a0,0x3
    80006102:	87250513          	addi	a0,a0,-1934 # 80008970 <syscallname+0x4b0>
    80006106:	ffffa097          	auipc	ra,0xffffa
    8000610a:	46e080e7          	jalr	1134(ra) # 80000574 <panic>

000000008000610e <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    8000610e:	7159                	addi	sp,sp,-112
    80006110:	f486                	sd	ra,104(sp)
    80006112:	f0a2                	sd	s0,96(sp)
    80006114:	eca6                	sd	s1,88(sp)
    80006116:	e8ca                	sd	s2,80(sp)
    80006118:	e4ce                	sd	s3,72(sp)
    8000611a:	e0d2                	sd	s4,64(sp)
    8000611c:	fc56                	sd	s5,56(sp)
    8000611e:	f85a                	sd	s6,48(sp)
    80006120:	f45e                	sd	s7,40(sp)
    80006122:	f062                	sd	s8,32(sp)
    80006124:	1880                	addi	s0,sp,112
    80006126:	892a                	mv	s2,a0
    80006128:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000612a:	00c52b83          	lw	s7,12(a0)
    8000612e:	001b9b9b          	slliw	s7,s7,0x1
    80006132:	1b82                	slli	s7,s7,0x20
    80006134:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80006138:	0001f517          	auipc	a0,0x1f
    8000613c:	f7050513          	addi	a0,a0,-144 # 800250a8 <disk+0x20a8>
    80006140:	ffffb097          	auipc	ra,0xffffb
    80006144:	b6c080e7          	jalr	-1172(ra) # 80000cac <acquire>
    if(disk.free[i]){
    80006148:	0001f997          	auipc	s3,0x1f
    8000614c:	eb898993          	addi	s3,s3,-328 # 80025000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006150:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006152:	0001da97          	auipc	s5,0x1d
    80006156:	eaea8a93          	addi	s5,s5,-338 # 80023000 <disk>
  for(int i = 0; i < 3; i++){
    8000615a:	4a0d                	li	s4,3
    8000615c:	a079                	j	800061ea <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    8000615e:	00fa86b3          	add	a3,s5,a5
    80006162:	96ae                	add	a3,a3,a1
    80006164:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006168:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000616a:	0207ca63          	bltz	a5,8000619e <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    8000616e:	2485                	addiw	s1,s1,1
    80006170:	0711                	addi	a4,a4,4
    80006172:	25448163          	beq	s1,s4,800063b4 <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006176:	863a                	mv	a2,a4
    if(disk.free[i]){
    80006178:	0189c783          	lbu	a5,24(s3)
    8000617c:	24079163          	bnez	a5,800063be <virtio_disk_rw+0x2b0>
    80006180:	0001f697          	auipc	a3,0x1f
    80006184:	e9968693          	addi	a3,a3,-359 # 80025019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    80006188:	87aa                	mv	a5,a0
    if(disk.free[i]){
    8000618a:	0006c803          	lbu	a6,0(a3)
    8000618e:	fc0818e3          	bnez	a6,8000615e <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006192:	2785                	addiw	a5,a5,1
    80006194:	0685                	addi	a3,a3,1
    80006196:	ff679ae3          	bne	a5,s6,8000618a <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    8000619a:	57fd                	li	a5,-1
    8000619c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000619e:	02905a63          	blez	s1,800061d2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061a2:	fa042503          	lw	a0,-96(s0)
    800061a6:	00000097          	auipc	ra,0x0
    800061aa:	da0080e7          	jalr	-608(ra) # 80005f46 <free_desc>
      for(int j = 0; j < i; j++)
    800061ae:	4785                	li	a5,1
    800061b0:	0297d163          	ble	s1,a5,800061d2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061b4:	fa442503          	lw	a0,-92(s0)
    800061b8:	00000097          	auipc	ra,0x0
    800061bc:	d8e080e7          	jalr	-626(ra) # 80005f46 <free_desc>
      for(int j = 0; j < i; j++)
    800061c0:	4789                	li	a5,2
    800061c2:	0097d863          	ble	s1,a5,800061d2 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800061c6:	fa842503          	lw	a0,-88(s0)
    800061ca:	00000097          	auipc	ra,0x0
    800061ce:	d7c080e7          	jalr	-644(ra) # 80005f46 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061d2:	0001f597          	auipc	a1,0x1f
    800061d6:	ed658593          	addi	a1,a1,-298 # 800250a8 <disk+0x20a8>
    800061da:	0001f517          	auipc	a0,0x1f
    800061de:	e3e50513          	addi	a0,a0,-450 # 80025018 <disk+0x2018>
    800061e2:	ffffc097          	auipc	ra,0xffffc
    800061e6:	0f6080e7          	jalr	246(ra) # 800022d8 <sleep>
  for(int i = 0; i < 3; i++){
    800061ea:	fa040713          	addi	a4,s0,-96
    800061ee:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    800061f0:	4505                	li	a0,1
      disk.free[i] = 0;
    800061f2:	6589                	lui	a1,0x2
    800061f4:	b749                	j	80006176 <virtio_disk_rw+0x68>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    800061f6:	4785                	li	a5,1
    800061f8:	f8f42823          	sw	a5,-112(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    800061fc:	f8042a23          	sw	zero,-108(s0)
  buf0.sector = sector;
    80006200:	f9743c23          	sd	s7,-104(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006204:	fa042983          	lw	s3,-96(s0)
    80006208:	00499493          	slli	s1,s3,0x4
    8000620c:	0001fa17          	auipc	s4,0x1f
    80006210:	df4a0a13          	addi	s4,s4,-524 # 80025000 <disk+0x2000>
    80006214:	000a3a83          	ld	s5,0(s4)
    80006218:	9aa6                	add	s5,s5,s1
    8000621a:	f9040513          	addi	a0,s0,-112
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	f82080e7          	jalr	-126(ra) # 800011a0 <kvmpa>
    80006226:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000622a:	000a3783          	ld	a5,0(s4)
    8000622e:	97a6                	add	a5,a5,s1
    80006230:	4741                	li	a4,16
    80006232:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006234:	000a3783          	ld	a5,0(s4)
    80006238:	97a6                	add	a5,a5,s1
    8000623a:	4705                	li	a4,1
    8000623c:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006240:	fa442703          	lw	a4,-92(s0)
    80006244:	000a3783          	ld	a5,0(s4)
    80006248:	97a6                	add	a5,a5,s1
    8000624a:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000624e:	0712                	slli	a4,a4,0x4
    80006250:	000a3783          	ld	a5,0(s4)
    80006254:	97ba                	add	a5,a5,a4
    80006256:	05890693          	addi	a3,s2,88
    8000625a:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    8000625c:	000a3783          	ld	a5,0(s4)
    80006260:	97ba                	add	a5,a5,a4
    80006262:	40000693          	li	a3,1024
    80006266:	c794                	sw	a3,8(a5)
  if(write)
    80006268:	100c0863          	beqz	s8,80006378 <virtio_disk_rw+0x26a>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000626c:	000a3783          	ld	a5,0(s4)
    80006270:	97ba                	add	a5,a5,a4
    80006272:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006276:	0001d517          	auipc	a0,0x1d
    8000627a:	d8a50513          	addi	a0,a0,-630 # 80023000 <disk>
    8000627e:	0001f797          	auipc	a5,0x1f
    80006282:	d8278793          	addi	a5,a5,-638 # 80025000 <disk+0x2000>
    80006286:	6394                	ld	a3,0(a5)
    80006288:	96ba                	add	a3,a3,a4
    8000628a:	00c6d603          	lhu	a2,12(a3)
    8000628e:	00166613          	ori	a2,a2,1
    80006292:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006296:	fa842683          	lw	a3,-88(s0)
    8000629a:	6390                	ld	a2,0(a5)
    8000629c:	9732                	add	a4,a4,a2
    8000629e:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    800062a2:	20098613          	addi	a2,s3,512
    800062a6:	0612                	slli	a2,a2,0x4
    800062a8:	962a                	add	a2,a2,a0
    800062aa:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062ae:	00469713          	slli	a4,a3,0x4
    800062b2:	6394                	ld	a3,0(a5)
    800062b4:	96ba                	add	a3,a3,a4
    800062b6:	6589                	lui	a1,0x2
    800062b8:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    800062bc:	94ae                	add	s1,s1,a1
    800062be:	94aa                	add	s1,s1,a0
    800062c0:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    800062c2:	6394                	ld	a3,0(a5)
    800062c4:	96ba                	add	a3,a3,a4
    800062c6:	4585                	li	a1,1
    800062c8:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062ca:	6394                	ld	a3,0(a5)
    800062cc:	96ba                	add	a3,a3,a4
    800062ce:	4509                	li	a0,2
    800062d0:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800062d4:	6394                	ld	a3,0(a5)
    800062d6:	9736                	add	a4,a4,a3
    800062d8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062dc:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062e0:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800062e4:	6794                	ld	a3,8(a5)
    800062e6:	0026d703          	lhu	a4,2(a3)
    800062ea:	8b1d                	andi	a4,a4,7
    800062ec:	2709                	addiw	a4,a4,2
    800062ee:	0706                	slli	a4,a4,0x1
    800062f0:	9736                	add	a4,a4,a3
    800062f2:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    800062f6:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800062fa:	6798                	ld	a4,8(a5)
    800062fc:	00275783          	lhu	a5,2(a4)
    80006300:	2785                	addiw	a5,a5,1
    80006302:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006306:	100017b7          	lui	a5,0x10001
    8000630a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000630e:	00492703          	lw	a4,4(s2)
    80006312:	4785                	li	a5,1
    80006314:	02f71163          	bne	a4,a5,80006336 <virtio_disk_rw+0x228>
    sleep(b, &disk.vdisk_lock);
    80006318:	0001f997          	auipc	s3,0x1f
    8000631c:	d9098993          	addi	s3,s3,-624 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006320:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006322:	85ce                	mv	a1,s3
    80006324:	854a                	mv	a0,s2
    80006326:	ffffc097          	auipc	ra,0xffffc
    8000632a:	fb2080e7          	jalr	-78(ra) # 800022d8 <sleep>
  while(b->disk == 1) {
    8000632e:	00492783          	lw	a5,4(s2)
    80006332:	fe9788e3          	beq	a5,s1,80006322 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006336:	fa042483          	lw	s1,-96(s0)
    8000633a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000633e:	00479713          	slli	a4,a5,0x4
    80006342:	0001d797          	auipc	a5,0x1d
    80006346:	cbe78793          	addi	a5,a5,-834 # 80023000 <disk>
    8000634a:	97ba                	add	a5,a5,a4
    8000634c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006350:	0001f917          	auipc	s2,0x1f
    80006354:	cb090913          	addi	s2,s2,-848 # 80025000 <disk+0x2000>
    free_desc(i);
    80006358:	8526                	mv	a0,s1
    8000635a:	00000097          	auipc	ra,0x0
    8000635e:	bec080e7          	jalr	-1044(ra) # 80005f46 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006362:	0492                	slli	s1,s1,0x4
    80006364:	00093783          	ld	a5,0(s2)
    80006368:	94be                	add	s1,s1,a5
    8000636a:	00c4d783          	lhu	a5,12(s1)
    8000636e:	8b85                	andi	a5,a5,1
    80006370:	cf91                	beqz	a5,8000638c <virtio_disk_rw+0x27e>
      i = disk.desc[i].next;
    80006372:	00e4d483          	lhu	s1,14(s1)
  while(1){
    80006376:	b7cd                	j	80006358 <virtio_disk_rw+0x24a>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006378:	0001f797          	auipc	a5,0x1f
    8000637c:	c8878793          	addi	a5,a5,-888 # 80025000 <disk+0x2000>
    80006380:	639c                	ld	a5,0(a5)
    80006382:	97ba                	add	a5,a5,a4
    80006384:	4689                	li	a3,2
    80006386:	00d79623          	sh	a3,12(a5)
    8000638a:	b5f5                	j	80006276 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000638c:	0001f517          	auipc	a0,0x1f
    80006390:	d1c50513          	addi	a0,a0,-740 # 800250a8 <disk+0x20a8>
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	9cc080e7          	jalr	-1588(ra) # 80000d60 <release>
}
    8000639c:	70a6                	ld	ra,104(sp)
    8000639e:	7406                	ld	s0,96(sp)
    800063a0:	64e6                	ld	s1,88(sp)
    800063a2:	6946                	ld	s2,80(sp)
    800063a4:	69a6                	ld	s3,72(sp)
    800063a6:	6a06                	ld	s4,64(sp)
    800063a8:	7ae2                	ld	s5,56(sp)
    800063aa:	7b42                	ld	s6,48(sp)
    800063ac:	7ba2                	ld	s7,40(sp)
    800063ae:	7c02                	ld	s8,32(sp)
    800063b0:	6165                	addi	sp,sp,112
    800063b2:	8082                	ret
  if(write)
    800063b4:	e40c11e3          	bnez	s8,800061f6 <virtio_disk_rw+0xe8>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800063b8:	f8042823          	sw	zero,-112(s0)
    800063bc:	b581                	j	800061fc <virtio_disk_rw+0xee>
      disk.free[i] = 0;
    800063be:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    800063c2:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    800063c6:	b365                	j	8000616e <virtio_disk_rw+0x60>

00000000800063c8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063c8:	1101                	addi	sp,sp,-32
    800063ca:	ec06                	sd	ra,24(sp)
    800063cc:	e822                	sd	s0,16(sp)
    800063ce:	e426                	sd	s1,8(sp)
    800063d0:	e04a                	sd	s2,0(sp)
    800063d2:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063d4:	0001f517          	auipc	a0,0x1f
    800063d8:	cd450513          	addi	a0,a0,-812 # 800250a8 <disk+0x20a8>
    800063dc:	ffffb097          	auipc	ra,0xffffb
    800063e0:	8d0080e7          	jalr	-1840(ra) # 80000cac <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063e4:	0001f797          	auipc	a5,0x1f
    800063e8:	c1c78793          	addi	a5,a5,-996 # 80025000 <disk+0x2000>
    800063ec:	0207d683          	lhu	a3,32(a5)
    800063f0:	6b98                	ld	a4,16(a5)
    800063f2:	00275783          	lhu	a5,2(a4)
    800063f6:	8fb5                	xor	a5,a5,a3
    800063f8:	8b9d                	andi	a5,a5,7
    800063fa:	c7c9                	beqz	a5,80006484 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    800063fc:	068e                	slli	a3,a3,0x3
    800063fe:	9736                	add	a4,a4,a3
    80006400:	435c                	lw	a5,4(a4)

    if(disk.info[id].status != 0)
    80006402:	20078713          	addi	a4,a5,512
    80006406:	00471693          	slli	a3,a4,0x4
    8000640a:	0001d717          	auipc	a4,0x1d
    8000640e:	bf670713          	addi	a4,a4,-1034 # 80023000 <disk>
    80006412:	9736                	add	a4,a4,a3
    80006414:	03074703          	lbu	a4,48(a4)
    80006418:	ef31                	bnez	a4,80006474 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000641a:	0001d917          	auipc	s2,0x1d
    8000641e:	be690913          	addi	s2,s2,-1050 # 80023000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006422:	0001f497          	auipc	s1,0x1f
    80006426:	bde48493          	addi	s1,s1,-1058 # 80025000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000642a:	20078793          	addi	a5,a5,512
    8000642e:	0792                	slli	a5,a5,0x4
    80006430:	97ca                	add	a5,a5,s2
    80006432:	7798                	ld	a4,40(a5)
    80006434:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006438:	7788                	ld	a0,40(a5)
    8000643a:	ffffc097          	auipc	ra,0xffffc
    8000643e:	024080e7          	jalr	36(ra) # 8000245e <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006442:	0204d783          	lhu	a5,32(s1)
    80006446:	2785                	addiw	a5,a5,1
    80006448:	8b9d                	andi	a5,a5,7
    8000644a:	03079613          	slli	a2,a5,0x30
    8000644e:	9241                	srli	a2,a2,0x30
    80006450:	02c49023          	sh	a2,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006454:	6898                	ld	a4,16(s1)
    80006456:	00275683          	lhu	a3,2(a4)
    8000645a:	8a9d                	andi	a3,a3,7
    8000645c:	02c68463          	beq	a3,a2,80006484 <virtio_disk_intr+0xbc>
    int id = disk.used->elems[disk.used_idx].id;
    80006460:	078e                	slli	a5,a5,0x3
    80006462:	97ba                	add	a5,a5,a4
    80006464:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006466:	20078713          	addi	a4,a5,512
    8000646a:	0712                	slli	a4,a4,0x4
    8000646c:	974a                	add	a4,a4,s2
    8000646e:	03074703          	lbu	a4,48(a4)
    80006472:	df45                	beqz	a4,8000642a <virtio_disk_intr+0x62>
      panic("virtio_disk_intr status");
    80006474:	00002517          	auipc	a0,0x2
    80006478:	51c50513          	addi	a0,a0,1308 # 80008990 <syscallname+0x4d0>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	0f8080e7          	jalr	248(ra) # 80000574 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006484:	10001737          	lui	a4,0x10001
    80006488:	533c                	lw	a5,96(a4)
    8000648a:	8b8d                	andi	a5,a5,3
    8000648c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000648e:	0001f517          	auipc	a0,0x1f
    80006492:	c1a50513          	addi	a0,a0,-998 # 800250a8 <disk+0x20a8>
    80006496:	ffffb097          	auipc	ra,0xffffb
    8000649a:	8ca080e7          	jalr	-1846(ra) # 80000d60 <release>
}
    8000649e:	60e2                	ld	ra,24(sp)
    800064a0:	6442                	ld	s0,16(sp)
    800064a2:	64a2                	ld	s1,8(sp)
    800064a4:	6902                	ld	s2,0(sp)
    800064a6:	6105                	addi	sp,sp,32
    800064a8:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
