
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	89013103          	ld	sp,-1904(sp) # 80008890 <_GLOBAL_OFFSET_TABLE_+0x8>
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
  asm volatile("csrr %0, mhartid"
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
  asm volatile("csrw mscratch, %0"
    8000005a:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0"
    8000005e:	00006797          	auipc	a5,0x6
    80000062:	e2278793          	addi	a5,a5,-478 # 80005e80 <timervec>
    80000066:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus"
    8000006a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0"
    80000072:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie"
    80000076:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0"
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
  asm volatile("csrr %0, mstatus"
    80000090:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000094:	7779                	lui	a4,0xffffe
    80000096:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    8000009a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009c:	6705                	lui	a4,0x1
    8000009e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0"
    800000a4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0"
    800000a8:	00001797          	auipc	a5,0x1
    800000ac:	efe78793          	addi	a5,a5,-258 # 80000fa6 <main>
    800000b0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0"
    800000b4:	4781                	li	a5,0
    800000b6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0"
    800000ba:	67c1                	lui	a5,0x10
    800000bc:	17fd                	addi	a5,a5,-1
    800000be:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0"
    800000c2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie"
    800000c6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ca:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0"
    800000ce:	10479073          	csrw	sie,a5
  timerinit();
    800000d2:	00000097          	auipc	ra,0x0
    800000d6:	f4a080e7          	jalr	-182(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid"
    800000da:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000de:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0"
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
    80000112:	bc8080e7          	jalr	-1080(ra) # 80000cd6 <acquire>
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
    8000012c:	4c2080e7          	jalr	1218(ra) # 800025ea <either_copyin>
    80000130:	01550c63          	beq	a0,s5,80000148 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000134:	fbf44503          	lbu	a0,-65(s0)
    80000138:	00001097          	auipc	ra,0x1
    8000013c:	862080e7          	jalr	-1950(ra) # 8000099a <uartputc>
  for(i = 0; i < n; i++){
    80000140:	2485                	addiw	s1,s1,1
    80000142:	0905                	addi	s2,s2,1
    80000144:	fc999de3          	bne	s3,s1,8000011e <consolewrite+0x30>
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	c3a080e7          	jalr	-966(ra) # 80000d8a <release>

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
    800001a4:	b36080e7          	jalr	-1226(ra) # 80000cd6 <acquire>
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
    800001d4:	914080e7          	jalr	-1772(ra) # 80001ae4 <myproc>
    800001d8:	591c                	lw	a5,48(a0)
    800001da:	eba5                	bnez	a5,8000024a <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001dc:	85ce                	mv	a1,s3
    800001de:	854a                	mv	a0,s2
    800001e0:	00002097          	auipc	ra,0x2
    800001e4:	152080e7          	jalr	338(ra) # 80002332 <sleep>
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
    80000220:	378080e7          	jalr	888(ra) # 80002594 <either_copyout>
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
    80000240:	b4e080e7          	jalr	-1202(ra) # 80000d8a <release>

  return target - n;
    80000244:	414b053b          	subw	a0,s6,s4
    80000248:	a811                	j	8000025c <consoleread+0xec>
        release(&cons.lock);
    8000024a:	00011517          	auipc	a0,0x11
    8000024e:	5e650513          	addi	a0,a0,1510 # 80011830 <cons>
    80000252:	00001097          	auipc	ra,0x1
    80000256:	b38080e7          	jalr	-1224(ra) # 80000d8a <release>
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
    800002a0:	5fe080e7          	jalr	1534(ra) # 8000089a <uartputc_sync>
}
    800002a4:	60a2                	ld	ra,8(sp)
    800002a6:	6402                	ld	s0,0(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	5ec080e7          	jalr	1516(ra) # 8000089a <uartputc_sync>
    800002b6:	02000513          	li	a0,32
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	5e0080e7          	jalr	1504(ra) # 8000089a <uartputc_sync>
    800002c2:	4521                	li	a0,8
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	5d6080e7          	jalr	1494(ra) # 8000089a <uartputc_sync>
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
    800002e8:	9f2080e7          	jalr	-1550(ra) # 80000cd6 <acquire>

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
    8000041a:	22a080e7          	jalr	554(ra) # 80002640 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000041e:	00011517          	auipc	a0,0x11
    80000422:	41250513          	addi	a0,a0,1042 # 80011830 <cons>
    80000426:	00001097          	auipc	ra,0x1
    8000042a:	964080e7          	jalr	-1692(ra) # 80000d8a <release>
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
    8000047c:	040080e7          	jalr	64(ra) # 800024b8 <wakeup>
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
    8000049e:	7ac080e7          	jalr	1964(ra) # 80000c46 <initlock>

  uartinit();
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	3a8080e7          	jalr	936(ra) # 8000084a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800004aa:	00022797          	auipc	a5,0x22
    800004ae:	b0678793          	addi	a5,a5,-1274 # 80021fb0 <devsw>
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

  if (sign && (sign = xx < 0))
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
  do
  {
    buf[i++] = digits[x % base];
    800004ea:	2581                	sext.w	a1,a1
    800004ec:	00008817          	auipc	a6,0x8
    800004f0:	b2c80813          	addi	a6,a6,-1236 # 80008018 <digits>
    800004f4:	a801                	j	80000504 <printint+0x36>
    x = -xx;
    800004f6:	40a0053b          	negw	a0,a0
    800004fa:	2501                	sext.w	a0,a0
  if (sign && (sign = xx < 0))
    800004fc:	4885                	li	a7,1
    x = -xx;
    800004fe:	b7dd                	j	800004e4 <printint+0x16>
  } while ((x /= base) != 0);
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
  } while ((x /= base) != 0);
    8000051a:	0705                	addi	a4,a4,1
    8000051c:	02b557bb          	divuw	a5,a0,a1
    80000520:	feb570e3          	bleu	a1,a0,80000500 <printint+0x32>

  if (sign)
    80000524:	00088b63          	beqz	a7,8000053a <printint+0x6c>
    buf[i++] = '-';
    80000528:	fe040793          	addi	a5,s0,-32
    8000052c:	96be                	add	a3,a3,a5
    8000052e:	02d00793          	li	a5,45
    80000532:	fef68823          	sb	a5,-16(a3)
    80000536:	0026069b          	addiw	a3,a2,2

  while (--i >= 0)
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
  while (--i >= 0)
    80000562:	14fd                	addi	s1,s1,-1
    80000564:	ff2499e3          	bne	s1,s2,80000556 <printint+0x88>
}
    80000568:	70a2                	ld	ra,40(sp)
    8000056a:	7402                	ld	s0,32(sp)
    8000056c:	64e2                	ld	s1,24(sp)
    8000056e:	6942                	ld	s2,16(sp)
    80000570:	6145                	addi	sp,sp,48
    80000572:	8082                	ret

0000000080000574 <printfinit>:
  for (;;)
    ;
}

void printfinit(void)
{
    80000574:	1101                	addi	sp,sp,-32
    80000576:	ec06                	sd	ra,24(sp)
    80000578:	e822                	sd	s0,16(sp)
    8000057a:	e426                	sd	s1,8(sp)
    8000057c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000057e:	00011497          	auipc	s1,0x11
    80000582:	35a48493          	addi	s1,s1,858 # 800118d8 <pr>
    80000586:	00008597          	auipc	a1,0x8
    8000058a:	aaa58593          	addi	a1,a1,-1366 # 80008030 <digits+0x18>
    8000058e:	8526                	mv	a0,s1
    80000590:	00000097          	auipc	ra,0x0
    80000594:	6b6080e7          	jalr	1718(ra) # 80000c46 <initlock>
  pr.locking = 1;
    80000598:	4785                	li	a5,1
    8000059a:	cc9c                	sw	a5,24(s1)
}
    8000059c:	60e2                	ld	ra,24(sp)
    8000059e:	6442                	ld	s0,16(sp)
    800005a0:	64a2                	ld	s1,8(sp)
    800005a2:	6105                	addi	sp,sp,32
    800005a4:	8082                	ret

00000000800005a6 <backtrace>:

void backtrace()
{
    800005a6:	7179                	addi	sp,sp,-48
    800005a8:	f406                	sd	ra,40(sp)
    800005aa:	f022                	sd	s0,32(sp)
    800005ac:	ec26                	sd	s1,24(sp)
    800005ae:	e84a                	sd	s2,16(sp)
    800005b0:	e44e                	sd	s3,8(sp)
    800005b2:	e052                	sd	s4,0(sp)
    800005b4:	1800                	addi	s0,sp,48
  printf("backtrace:\n");
    800005b6:	00008517          	auipc	a0,0x8
    800005ba:	a8250513          	addi	a0,a0,-1406 # 80008038 <digits+0x20>
    800005be:	00000097          	auipc	ra,0x0
    800005c2:	0a6080e7          	jalr	166(ra) # 80000664 <printf>

static inline uint64
r_fp()
{
  uint64 x;
  asm volatile("mv %0, s0"
    800005c6:	84a2                	mv	s1,s0
  uint64 fp = r_fp();
  uint64 up = PGROUNDUP(fp), down = PGROUNDDOWN(fp);
    800005c8:	6905                	lui	s2,0x1
    800005ca:	197d                	addi	s2,s2,-1
    800005cc:	9926                	add	s2,s2,s1
    800005ce:	79fd                	lui	s3,0xfffff
    800005d0:	01397933          	and	s2,s2,s3
    800005d4:	0134f9b3          	and	s3,s1,s3
  while (fp < up && fp >= down)
    800005d8:	0324f563          	bleu	s2,s1,80000602 <backtrace+0x5c>
    800005dc:	0334e363          	bltu	s1,s3,80000602 <backtrace+0x5c>
  {
    printf("%p\n", *((uint64 *)(fp - 8)));
    800005e0:	00008a17          	auipc	s4,0x8
    800005e4:	a68a0a13          	addi	s4,s4,-1432 # 80008048 <digits+0x30>
    800005e8:	ff84b583          	ld	a1,-8(s1)
    800005ec:	8552                	mv	a0,s4
    800005ee:	00000097          	auipc	ra,0x0
    800005f2:	076080e7          	jalr	118(ra) # 80000664 <printf>
    fp = *((uint64 *)(fp - 16));
    800005f6:	ff04b483          	ld	s1,-16(s1)
  while (fp < up && fp >= down)
    800005fa:	0124f463          	bleu	s2,s1,80000602 <backtrace+0x5c>
    800005fe:	ff34f5e3          	bleu	s3,s1,800005e8 <backtrace+0x42>
  }
}
    80000602:	70a2                	ld	ra,40(sp)
    80000604:	7402                	ld	s0,32(sp)
    80000606:	64e2                	ld	s1,24(sp)
    80000608:	6942                	ld	s2,16(sp)
    8000060a:	69a2                	ld	s3,8(sp)
    8000060c:	6a02                	ld	s4,0(sp)
    8000060e:	6145                	addi	sp,sp,48
    80000610:	8082                	ret

0000000080000612 <panic>:
{
    80000612:	1101                	addi	sp,sp,-32
    80000614:	ec06                	sd	ra,24(sp)
    80000616:	e822                	sd	s0,16(sp)
    80000618:	e426                	sd	s1,8(sp)
    8000061a:	1000                	addi	s0,sp,32
    8000061c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000061e:	00011797          	auipc	a5,0x11
    80000622:	2c07a923          	sw	zero,722(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000626:	00008517          	auipc	a0,0x8
    8000062a:	a2a50513          	addi	a0,a0,-1494 # 80008050 <digits+0x38>
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	036080e7          	jalr	54(ra) # 80000664 <printf>
  printf(s);
    80000636:	8526                	mv	a0,s1
    80000638:	00000097          	auipc	ra,0x0
    8000063c:	02c080e7          	jalr	44(ra) # 80000664 <printf>
  printf("\n");
    80000640:	00008517          	auipc	a0,0x8
    80000644:	aa050513          	addi	a0,a0,-1376 # 800080e0 <digits+0xc8>
    80000648:	00000097          	auipc	ra,0x0
    8000064c:	01c080e7          	jalr	28(ra) # 80000664 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000650:	4785                	li	a5,1
    80000652:	00009717          	auipc	a4,0x9
    80000656:	9af72723          	sw	a5,-1618(a4) # 80009000 <panicked>
  backtrace();
    8000065a:	00000097          	auipc	ra,0x0
    8000065e:	f4c080e7          	jalr	-180(ra) # 800005a6 <backtrace>
  for (;;)
    80000662:	a001                	j	80000662 <panic+0x50>

0000000080000664 <printf>:
{
    80000664:	7131                	addi	sp,sp,-192
    80000666:	fc86                	sd	ra,120(sp)
    80000668:	f8a2                	sd	s0,112(sp)
    8000066a:	f4a6                	sd	s1,104(sp)
    8000066c:	f0ca                	sd	s2,96(sp)
    8000066e:	ecce                	sd	s3,88(sp)
    80000670:	e8d2                	sd	s4,80(sp)
    80000672:	e4d6                	sd	s5,72(sp)
    80000674:	e0da                	sd	s6,64(sp)
    80000676:	fc5e                	sd	s7,56(sp)
    80000678:	f862                	sd	s8,48(sp)
    8000067a:	f466                	sd	s9,40(sp)
    8000067c:	f06a                	sd	s10,32(sp)
    8000067e:	ec6e                	sd	s11,24(sp)
    80000680:	0100                	addi	s0,sp,128
    80000682:	8aaa                	mv	s5,a0
    80000684:	e40c                	sd	a1,8(s0)
    80000686:	e810                	sd	a2,16(s0)
    80000688:	ec14                	sd	a3,24(s0)
    8000068a:	f018                	sd	a4,32(s0)
    8000068c:	f41c                	sd	a5,40(s0)
    8000068e:	03043823          	sd	a6,48(s0)
    80000692:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80000696:	00011797          	auipc	a5,0x11
    8000069a:	24278793          	addi	a5,a5,578 # 800118d8 <pr>
    8000069e:	0187ad83          	lw	s11,24(a5)
  if (locking)
    800006a2:	020d9b63          	bnez	s11,800006d8 <printf+0x74>
  if (fmt == 0)
    800006a6:	020a8f63          	beqz	s5,800006e4 <printf+0x80>
  va_start(ap, fmt);
    800006aa:	00840793          	addi	a5,s0,8
    800006ae:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800006b2:	000ac503          	lbu	a0,0(s5)
    800006b6:	16050063          	beqz	a0,80000816 <printf+0x1b2>
    800006ba:	4481                	li	s1,0
    if (c != '%')
    800006bc:	02500a13          	li	s4,37
    switch (c)
    800006c0:	07000b13          	li	s6,112
  consputc('x');
    800006c4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	00008b97          	auipc	s7,0x8
    800006ca:	952b8b93          	addi	s7,s7,-1710 # 80008018 <digits>
    switch (c)
    800006ce:	07300c93          	li	s9,115
    800006d2:	06400c13          	li	s8,100
    800006d6:	a815                	j	8000070a <printf+0xa6>
    acquire(&pr.lock);
    800006d8:	853e                	mv	a0,a5
    800006da:	00000097          	auipc	ra,0x0
    800006de:	5fc080e7          	jalr	1532(ra) # 80000cd6 <acquire>
    800006e2:	b7d1                	j	800006a6 <printf+0x42>
    panic("null fmt");
    800006e4:	00008517          	auipc	a0,0x8
    800006e8:	97c50513          	addi	a0,a0,-1668 # 80008060 <digits+0x48>
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	f26080e7          	jalr	-218(ra) # 80000612 <panic>
      consputc(c);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b98080e7          	jalr	-1128(ra) # 8000028c <consputc>
  for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800006fc:	2485                	addiw	s1,s1,1
    800006fe:	009a87b3          	add	a5,s5,s1
    80000702:	0007c503          	lbu	a0,0(a5)
    80000706:	10050863          	beqz	a0,80000816 <printf+0x1b2>
    if (c != '%')
    8000070a:	ff4515e3          	bne	a0,s4,800006f4 <printf+0x90>
    c = fmt[++i] & 0xff;
    8000070e:	2485                	addiw	s1,s1,1
    80000710:	009a87b3          	add	a5,s5,s1
    80000714:	0007c783          	lbu	a5,0(a5)
    80000718:	0007891b          	sext.w	s2,a5
    if (c == 0)
    8000071c:	0e090d63          	beqz	s2,80000816 <printf+0x1b2>
    switch (c)
    80000720:	05678a63          	beq	a5,s6,80000774 <printf+0x110>
    80000724:	02fb7663          	bleu	a5,s6,80000750 <printf+0xec>
    80000728:	09978963          	beq	a5,s9,800007ba <printf+0x156>
    8000072c:	07800713          	li	a4,120
    80000730:	0ce79863          	bne	a5,a4,80000800 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000734:	f8843783          	ld	a5,-120(s0)
    80000738:	00878713          	addi	a4,a5,8
    8000073c:	f8e43423          	sd	a4,-120(s0)
    80000740:	4605                	li	a2,1
    80000742:	85ea                	mv	a1,s10
    80000744:	4388                	lw	a0,0(a5)
    80000746:	00000097          	auipc	ra,0x0
    8000074a:	d88080e7          	jalr	-632(ra) # 800004ce <printint>
      break;
    8000074e:	b77d                	j	800006fc <printf+0x98>
    switch (c)
    80000750:	0b478263          	beq	a5,s4,800007f4 <printf+0x190>
    80000754:	0b879663          	bne	a5,s8,80000800 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000758:	f8843783          	ld	a5,-120(s0)
    8000075c:	00878713          	addi	a4,a5,8
    80000760:	f8e43423          	sd	a4,-120(s0)
    80000764:	4605                	li	a2,1
    80000766:	45a9                	li	a1,10
    80000768:	4388                	lw	a0,0(a5)
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	d64080e7          	jalr	-668(ra) # 800004ce <printint>
      break;
    80000772:	b769                	j	800006fc <printf+0x98>
      printptr(va_arg(ap, uint64));
    80000774:	f8843783          	ld	a5,-120(s0)
    80000778:	00878713          	addi	a4,a5,8
    8000077c:	f8e43423          	sd	a4,-120(s0)
    80000780:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000784:	03000513          	li	a0,48
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	b04080e7          	jalr	-1276(ra) # 8000028c <consputc>
  consputc('x');
    80000790:	07800513          	li	a0,120
    80000794:	00000097          	auipc	ra,0x0
    80000798:	af8080e7          	jalr	-1288(ra) # 8000028c <consputc>
    8000079c:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000079e:	03c9d793          	srli	a5,s3,0x3c
    800007a2:	97de                	add	a5,a5,s7
    800007a4:	0007c503          	lbu	a0,0(a5)
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	ae4080e7          	jalr	-1308(ra) # 8000028c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800007b0:	0992                	slli	s3,s3,0x4
    800007b2:	397d                	addiw	s2,s2,-1
    800007b4:	fe0915e3          	bnez	s2,8000079e <printf+0x13a>
    800007b8:	b791                	j	800006fc <printf+0x98>
      if ((s = va_arg(ap, char *)) == 0)
    800007ba:	f8843783          	ld	a5,-120(s0)
    800007be:	00878713          	addi	a4,a5,8
    800007c2:	f8e43423          	sd	a4,-120(s0)
    800007c6:	0007b903          	ld	s2,0(a5)
    800007ca:	00090e63          	beqz	s2,800007e6 <printf+0x182>
      for (; *s; s++)
    800007ce:	00094503          	lbu	a0,0(s2) # 1000 <_entry-0x7ffff000>
    800007d2:	d50d                	beqz	a0,800006fc <printf+0x98>
        consputc(*s);
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	ab8080e7          	jalr	-1352(ra) # 8000028c <consputc>
      for (; *s; s++)
    800007dc:	0905                	addi	s2,s2,1
    800007de:	00094503          	lbu	a0,0(s2)
    800007e2:	f96d                	bnez	a0,800007d4 <printf+0x170>
    800007e4:	bf21                	j	800006fc <printf+0x98>
        s = "(null)";
    800007e6:	00008917          	auipc	s2,0x8
    800007ea:	87290913          	addi	s2,s2,-1934 # 80008058 <digits+0x40>
      for (; *s; s++)
    800007ee:	02800513          	li	a0,40
    800007f2:	b7cd                	j	800007d4 <printf+0x170>
      consputc('%');
    800007f4:	8552                	mv	a0,s4
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	a96080e7          	jalr	-1386(ra) # 8000028c <consputc>
      break;
    800007fe:	bdfd                	j	800006fc <printf+0x98>
      consputc('%');
    80000800:	8552                	mv	a0,s4
    80000802:	00000097          	auipc	ra,0x0
    80000806:	a8a080e7          	jalr	-1398(ra) # 8000028c <consputc>
      consputc(c);
    8000080a:	854a                	mv	a0,s2
    8000080c:	00000097          	auipc	ra,0x0
    80000810:	a80080e7          	jalr	-1408(ra) # 8000028c <consputc>
      break;
    80000814:	b5e5                	j	800006fc <printf+0x98>
  if (locking)
    80000816:	020d9163          	bnez	s11,80000838 <printf+0x1d4>
}
    8000081a:	70e6                	ld	ra,120(sp)
    8000081c:	7446                	ld	s0,112(sp)
    8000081e:	74a6                	ld	s1,104(sp)
    80000820:	7906                	ld	s2,96(sp)
    80000822:	69e6                	ld	s3,88(sp)
    80000824:	6a46                	ld	s4,80(sp)
    80000826:	6aa6                	ld	s5,72(sp)
    80000828:	6b06                	ld	s6,64(sp)
    8000082a:	7be2                	ld	s7,56(sp)
    8000082c:	7c42                	ld	s8,48(sp)
    8000082e:	7ca2                	ld	s9,40(sp)
    80000830:	7d02                	ld	s10,32(sp)
    80000832:	6de2                	ld	s11,24(sp)
    80000834:	6129                	addi	sp,sp,192
    80000836:	8082                	ret
    release(&pr.lock);
    80000838:	00011517          	auipc	a0,0x11
    8000083c:	0a050513          	addi	a0,a0,160 # 800118d8 <pr>
    80000840:	00000097          	auipc	ra,0x0
    80000844:	54a080e7          	jalr	1354(ra) # 80000d8a <release>
}
    80000848:	bfc9                	j	8000081a <printf+0x1b6>

000000008000084a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000084a:	1141                	addi	sp,sp,-16
    8000084c:	e406                	sd	ra,8(sp)
    8000084e:	e022                	sd	s0,0(sp)
    80000850:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000852:	100007b7          	lui	a5,0x10000
    80000856:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000085a:	f8000713          	li	a4,-128
    8000085e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000862:	470d                	li	a4,3
    80000864:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000868:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000870:	469d                	li	a3,7
    80000872:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000876:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000087a:	00007597          	auipc	a1,0x7
    8000087e:	7f658593          	addi	a1,a1,2038 # 80008070 <digits+0x58>
    80000882:	00011517          	auipc	a0,0x11
    80000886:	07650513          	addi	a0,a0,118 # 800118f8 <uart_tx_lock>
    8000088a:	00000097          	auipc	ra,0x0
    8000088e:	3bc080e7          	jalr	956(ra) # 80000c46 <initlock>
}
    80000892:	60a2                	ld	ra,8(sp)
    80000894:	6402                	ld	s0,0(sp)
    80000896:	0141                	addi	sp,sp,16
    80000898:	8082                	ret

000000008000089a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000089a:	1101                	addi	sp,sp,-32
    8000089c:	ec06                	sd	ra,24(sp)
    8000089e:	e822                	sd	s0,16(sp)
    800008a0:	e426                	sd	s1,8(sp)
    800008a2:	1000                	addi	s0,sp,32
    800008a4:	84aa                	mv	s1,a0
  push_off();
    800008a6:	00000097          	auipc	ra,0x0
    800008aa:	3e4080e7          	jalr	996(ra) # 80000c8a <push_off>

  if(panicked){
    800008ae:	00008797          	auipc	a5,0x8
    800008b2:	75278793          	addi	a5,a5,1874 # 80009000 <panicked>
    800008b6:	439c                	lw	a5,0(a5)
    800008b8:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008ba:	10000737          	lui	a4,0x10000
  if(panicked){
    800008be:	c391                	beqz	a5,800008c2 <uartputc_sync+0x28>
    for(;;)
    800008c0:	a001                	j	800008c0 <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800008c2:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008c6:	0ff7f793          	andi	a5,a5,255
    800008ca:	0207f793          	andi	a5,a5,32
    800008ce:	dbf5                	beqz	a5,800008c2 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    800008d0:	0ff4f793          	andi	a5,s1,255
    800008d4:	10000737          	lui	a4,0x10000
    800008d8:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    800008dc:	00000097          	auipc	ra,0x0
    800008e0:	44e080e7          	jalr	1102(ra) # 80000d2a <pop_off>
}
    800008e4:	60e2                	ld	ra,24(sp)
    800008e6:	6442                	ld	s0,16(sp)
    800008e8:	64a2                	ld	s1,8(sp)
    800008ea:	6105                	addi	sp,sp,32
    800008ec:	8082                	ret

00000000800008ee <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	71678793          	addi	a5,a5,1814 # 80009004 <uart_tx_r>
    800008f6:	439c                	lw	a5,0(a5)
    800008f8:	00008717          	auipc	a4,0x8
    800008fc:	71070713          	addi	a4,a4,1808 # 80009008 <uart_tx_w>
    80000900:	4318                	lw	a4,0(a4)
    80000902:	08f70b63          	beq	a4,a5,80000998 <uartstart+0xaa>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000906:	10000737          	lui	a4,0x10000
    8000090a:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000090e:	0ff77713          	andi	a4,a4,255
    80000912:	02077713          	andi	a4,a4,32
    80000916:	c349                	beqz	a4,80000998 <uartstart+0xaa>
{
    80000918:	7139                	addi	sp,sp,-64
    8000091a:	fc06                	sd	ra,56(sp)
    8000091c:	f822                	sd	s0,48(sp)
    8000091e:	f426                	sd	s1,40(sp)
    80000920:	f04a                	sd	s2,32(sp)
    80000922:	ec4e                	sd	s3,24(sp)
    80000924:	e852                	sd	s4,16(sp)
    80000926:	e456                	sd	s5,8(sp)
    80000928:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    8000092a:	00011a17          	auipc	s4,0x11
    8000092e:	fcea0a13          	addi	s4,s4,-50 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000932:	00008497          	auipc	s1,0x8
    80000936:	6d248493          	addi	s1,s1,1746 # 80009004 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    8000093a:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    8000093e:	00008997          	auipc	s3,0x8
    80000942:	6ca98993          	addi	s3,s3,1738 # 80009008 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r];
    80000946:	00fa0733          	add	a4,s4,a5
    8000094a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000094e:	2785                	addiw	a5,a5,1
    80000950:	41f7d71b          	sraiw	a4,a5,0x1f
    80000954:	01b7571b          	srliw	a4,a4,0x1b
    80000958:	9fb9                	addw	a5,a5,a4
    8000095a:	8bfd                	andi	a5,a5,31
    8000095c:	9f99                	subw	a5,a5,a4
    8000095e:	c09c                	sw	a5,0(s1)
    wakeup(&uart_tx_r);
    80000960:	8526                	mv	a0,s1
    80000962:	00002097          	auipc	ra,0x2
    80000966:	b56080e7          	jalr	-1194(ra) # 800024b8 <wakeup>
    WriteReg(THR, c);
    8000096a:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    8000096e:	409c                	lw	a5,0(s1)
    80000970:	0009a703          	lw	a4,0(s3)
    80000974:	00f70963          	beq	a4,a5,80000986 <uartstart+0x98>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000978:	00594703          	lbu	a4,5(s2)
    8000097c:	0ff77713          	andi	a4,a4,255
    80000980:	02077713          	andi	a4,a4,32
    80000984:	f369                	bnez	a4,80000946 <uartstart+0x58>
  }
}
    80000986:	70e2                	ld	ra,56(sp)
    80000988:	7442                	ld	s0,48(sp)
    8000098a:	74a2                	ld	s1,40(sp)
    8000098c:	7902                	ld	s2,32(sp)
    8000098e:	69e2                	ld	s3,24(sp)
    80000990:	6a42                	ld	s4,16(sp)
    80000992:	6aa2                	ld	s5,8(sp)
    80000994:	6121                	addi	sp,sp,64
    80000996:	8082                	ret
    80000998:	8082                	ret

000000008000099a <uartputc>:
{
    8000099a:	7179                	addi	sp,sp,-48
    8000099c:	f406                	sd	ra,40(sp)
    8000099e:	f022                	sd	s0,32(sp)
    800009a0:	ec26                	sd	s1,24(sp)
    800009a2:	e84a                	sd	s2,16(sp)
    800009a4:	e44e                	sd	s3,8(sp)
    800009a6:	e052                	sd	s4,0(sp)
    800009a8:	1800                	addi	s0,sp,48
    800009aa:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800009ac:	00011517          	auipc	a0,0x11
    800009b0:	f4c50513          	addi	a0,a0,-180 # 800118f8 <uart_tx_lock>
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	322080e7          	jalr	802(ra) # 80000cd6 <acquire>
  if(panicked){
    800009bc:	00008797          	auipc	a5,0x8
    800009c0:	64478793          	addi	a5,a5,1604 # 80009000 <panicked>
    800009c4:	439c                	lw	a5,0(a5)
    800009c6:	2781                	sext.w	a5,a5
    800009c8:	c391                	beqz	a5,800009cc <uartputc+0x32>
    for(;;)
    800009ca:	a001                	j	800009ca <uartputc+0x30>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009cc:	00008797          	auipc	a5,0x8
    800009d0:	63c78793          	addi	a5,a5,1596 # 80009008 <uart_tx_w>
    800009d4:	4398                	lw	a4,0(a5)
    800009d6:	0017079b          	addiw	a5,a4,1
    800009da:	41f7d69b          	sraiw	a3,a5,0x1f
    800009de:	01b6d69b          	srliw	a3,a3,0x1b
    800009e2:	9fb5                	addw	a5,a5,a3
    800009e4:	8bfd                	andi	a5,a5,31
    800009e6:	9f95                	subw	a5,a5,a3
    800009e8:	00008697          	auipc	a3,0x8
    800009ec:	61c68693          	addi	a3,a3,1564 # 80009004 <uart_tx_r>
    800009f0:	4294                	lw	a3,0(a3)
    800009f2:	04f69263          	bne	a3,a5,80000a36 <uartputc+0x9c>
      sleep(&uart_tx_r, &uart_tx_lock);
    800009f6:	00011a17          	auipc	s4,0x11
    800009fa:	f02a0a13          	addi	s4,s4,-254 # 800118f8 <uart_tx_lock>
    800009fe:	00008497          	auipc	s1,0x8
    80000a02:	60648493          	addi	s1,s1,1542 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000a06:	00008917          	auipc	s2,0x8
    80000a0a:	60290913          	addi	s2,s2,1538 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000a0e:	85d2                	mv	a1,s4
    80000a10:	8526                	mv	a0,s1
    80000a12:	00002097          	auipc	ra,0x2
    80000a16:	920080e7          	jalr	-1760(ra) # 80002332 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000a1a:	00092703          	lw	a4,0(s2)
    80000a1e:	0017079b          	addiw	a5,a4,1
    80000a22:	41f7d69b          	sraiw	a3,a5,0x1f
    80000a26:	01b6d69b          	srliw	a3,a3,0x1b
    80000a2a:	9fb5                	addw	a5,a5,a3
    80000a2c:	8bfd                	andi	a5,a5,31
    80000a2e:	9f95                	subw	a5,a5,a3
    80000a30:	4094                	lw	a3,0(s1)
    80000a32:	fcf68ee3          	beq	a3,a5,80000a0e <uartputc+0x74>
      uart_tx_buf[uart_tx_w] = c;
    80000a36:	00011497          	auipc	s1,0x11
    80000a3a:	ec248493          	addi	s1,s1,-318 # 800118f8 <uart_tx_lock>
    80000a3e:	9726                	add	a4,a4,s1
    80000a40:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000a44:	00008717          	auipc	a4,0x8
    80000a48:	5cf72223          	sw	a5,1476(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000a4c:	00000097          	auipc	ra,0x0
    80000a50:	ea2080e7          	jalr	-350(ra) # 800008ee <uartstart>
      release(&uart_tx_lock);
    80000a54:	8526                	mv	a0,s1
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	334080e7          	jalr	820(ra) # 80000d8a <release>
}
    80000a5e:	70a2                	ld	ra,40(sp)
    80000a60:	7402                	ld	s0,32(sp)
    80000a62:	64e2                	ld	s1,24(sp)
    80000a64:	6942                	ld	s2,16(sp)
    80000a66:	69a2                	ld	s3,8(sp)
    80000a68:	6a02                	ld	s4,0(sp)
    80000a6a:	6145                	addi	sp,sp,48
    80000a6c:	8082                	ret

0000000080000a6e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000a6e:	1141                	addi	sp,sp,-16
    80000a70:	e422                	sd	s0,8(sp)
    80000a72:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a74:	100007b7          	lui	a5,0x10000
    80000a78:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a7c:	8b85                	andi	a5,a5,1
    80000a7e:	cb91                	beqz	a5,80000a92 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a80:	100007b7          	lui	a5,0x10000
    80000a84:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000a88:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000a8c:	6422                	ld	s0,8(sp)
    80000a8e:	0141                	addi	sp,sp,16
    80000a90:	8082                	ret
    return -1;
    80000a92:	557d                	li	a0,-1
    80000a94:	bfe5                	j	80000a8c <uartgetc+0x1e>

0000000080000a96 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a96:	1101                	addi	sp,sp,-32
    80000a98:	ec06                	sd	ra,24(sp)
    80000a9a:	e822                	sd	s0,16(sp)
    80000a9c:	e426                	sd	s1,8(sp)
    80000a9e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000aa0:	54fd                	li	s1,-1
    int c = uartgetc();
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	fcc080e7          	jalr	-52(ra) # 80000a6e <uartgetc>
    if(c == -1)
    80000aaa:	00950763          	beq	a0,s1,80000ab8 <uartintr+0x22>
      break;
    consoleintr(c);
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	820080e7          	jalr	-2016(ra) # 800002ce <consoleintr>
  while(1){
    80000ab6:	b7f5                	j	80000aa2 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000ab8:	00011497          	auipc	s1,0x11
    80000abc:	e4048493          	addi	s1,s1,-448 # 800118f8 <uart_tx_lock>
    80000ac0:	8526                	mv	a0,s1
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	214080e7          	jalr	532(ra) # 80000cd6 <acquire>
  uartstart();
    80000aca:	00000097          	auipc	ra,0x0
    80000ace:	e24080e7          	jalr	-476(ra) # 800008ee <uartstart>
  release(&uart_tx_lock);
    80000ad2:	8526                	mv	a0,s1
    80000ad4:	00000097          	auipc	ra,0x0
    80000ad8:	2b6080e7          	jalr	694(ra) # 80000d8a <release>
}
    80000adc:	60e2                	ld	ra,24(sp)
    80000ade:	6442                	ld	s0,16(sp)
    80000ae0:	64a2                	ld	s1,8(sp)
    80000ae2:	6105                	addi	sp,sp,32
    80000ae4:	8082                	ret

0000000080000ae6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	e04a                	sd	s2,0(sp)
    80000af0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000af2:	6785                	lui	a5,0x1
    80000af4:	17fd                	addi	a5,a5,-1
    80000af6:	8fe9                	and	a5,a5,a0
    80000af8:	ebb9                	bnez	a5,80000b4e <kfree+0x68>
    80000afa:	84aa                	mv	s1,a0
    80000afc:	00026797          	auipc	a5,0x26
    80000b00:	50478793          	addi	a5,a5,1284 # 80027000 <end>
    80000b04:	04f56563          	bltu	a0,a5,80000b4e <kfree+0x68>
    80000b08:	47c5                	li	a5,17
    80000b0a:	07ee                	slli	a5,a5,0x1b
    80000b0c:	04f57163          	bleu	a5,a0,80000b4e <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000b10:	6605                	lui	a2,0x1
    80000b12:	4585                	li	a1,1
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	2be080e7          	jalr	702(ra) # 80000dd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000b1c:	00011917          	auipc	s2,0x11
    80000b20:	e1490913          	addi	s2,s2,-492 # 80011930 <kmem>
    80000b24:	854a                	mv	a0,s2
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	1b0080e7          	jalr	432(ra) # 80000cd6 <acquire>
  r->next = kmem.freelist;
    80000b2e:	01893783          	ld	a5,24(s2)
    80000b32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000b38:	854a                	mv	a0,s2
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	250080e7          	jalr	592(ra) # 80000d8a <release>
}
    80000b42:	60e2                	ld	ra,24(sp)
    80000b44:	6442                	ld	s0,16(sp)
    80000b46:	64a2                	ld	s1,8(sp)
    80000b48:	6902                	ld	s2,0(sp)
    80000b4a:	6105                	addi	sp,sp,32
    80000b4c:	8082                	ret
    panic("kfree");
    80000b4e:	00007517          	auipc	a0,0x7
    80000b52:	52a50513          	addi	a0,a0,1322 # 80008078 <digits+0x60>
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	abc080e7          	jalr	-1348(ra) # 80000612 <panic>

0000000080000b5e <freerange>:
{
    80000b5e:	7179                	addi	sp,sp,-48
    80000b60:	f406                	sd	ra,40(sp)
    80000b62:	f022                	sd	s0,32(sp)
    80000b64:	ec26                	sd	s1,24(sp)
    80000b66:	e84a                	sd	s2,16(sp)
    80000b68:	e44e                	sd	s3,8(sp)
    80000b6a:	e052                	sd	s4,0(sp)
    80000b6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b6e:	6705                	lui	a4,0x1
    80000b70:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    80000b74:	00f504b3          	add	s1,a0,a5
    80000b78:	77fd                	lui	a5,0xfffff
    80000b7a:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b7c:	94ba                	add	s1,s1,a4
    80000b7e:	0095ee63          	bltu	a1,s1,80000b9a <freerange+0x3c>
    80000b82:	892e                	mv	s2,a1
    kfree(p);
    80000b84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b86:	6985                	lui	s3,0x1
    kfree(p);
    80000b88:	01448533          	add	a0,s1,s4
    80000b8c:	00000097          	auipc	ra,0x0
    80000b90:	f5a080e7          	jalr	-166(ra) # 80000ae6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b94:	94ce                	add	s1,s1,s3
    80000b96:	fe9979e3          	bleu	s1,s2,80000b88 <freerange+0x2a>
}
    80000b9a:	70a2                	ld	ra,40(sp)
    80000b9c:	7402                	ld	s0,32(sp)
    80000b9e:	64e2                	ld	s1,24(sp)
    80000ba0:	6942                	ld	s2,16(sp)
    80000ba2:	69a2                	ld	s3,8(sp)
    80000ba4:	6a02                	ld	s4,0(sp)
    80000ba6:	6145                	addi	sp,sp,48
    80000ba8:	8082                	ret

0000000080000baa <kinit>:
{
    80000baa:	1141                	addi	sp,sp,-16
    80000bac:	e406                	sd	ra,8(sp)
    80000bae:	e022                	sd	s0,0(sp)
    80000bb0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000bb2:	00007597          	auipc	a1,0x7
    80000bb6:	4ce58593          	addi	a1,a1,1230 # 80008080 <digits+0x68>
    80000bba:	00011517          	auipc	a0,0x11
    80000bbe:	d7650513          	addi	a0,a0,-650 # 80011930 <kmem>
    80000bc2:	00000097          	auipc	ra,0x0
    80000bc6:	084080e7          	jalr	132(ra) # 80000c46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bca:	45c5                	li	a1,17
    80000bcc:	05ee                	slli	a1,a1,0x1b
    80000bce:	00026517          	auipc	a0,0x26
    80000bd2:	43250513          	addi	a0,a0,1074 # 80027000 <end>
    80000bd6:	00000097          	auipc	ra,0x0
    80000bda:	f88080e7          	jalr	-120(ra) # 80000b5e <freerange>
}
    80000bde:	60a2                	ld	ra,8(sp)
    80000be0:	6402                	ld	s0,0(sp)
    80000be2:	0141                	addi	sp,sp,16
    80000be4:	8082                	ret

0000000080000be6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000be6:	1101                	addi	sp,sp,-32
    80000be8:	ec06                	sd	ra,24(sp)
    80000bea:	e822                	sd	s0,16(sp)
    80000bec:	e426                	sd	s1,8(sp)
    80000bee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bf0:	00011497          	auipc	s1,0x11
    80000bf4:	d4048493          	addi	s1,s1,-704 # 80011930 <kmem>
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	0dc080e7          	jalr	220(ra) # 80000cd6 <acquire>
  r = kmem.freelist;
    80000c02:	6c84                	ld	s1,24(s1)
  if(r)
    80000c04:	c885                	beqz	s1,80000c34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000c06:	609c                	ld	a5,0(s1)
    80000c08:	00011517          	auipc	a0,0x11
    80000c0c:	d2850513          	addi	a0,a0,-728 # 80011930 <kmem>
    80000c10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000c12:	00000097          	auipc	ra,0x0
    80000c16:	178080e7          	jalr	376(ra) # 80000d8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c1a:	6605                	lui	a2,0x1
    80000c1c:	4595                	li	a1,5
    80000c1e:	8526                	mv	a0,s1
    80000c20:	00000097          	auipc	ra,0x0
    80000c24:	1b2080e7          	jalr	434(ra) # 80000dd2 <memset>
  return (void*)r;
}
    80000c28:	8526                	mv	a0,s1
    80000c2a:	60e2                	ld	ra,24(sp)
    80000c2c:	6442                	ld	s0,16(sp)
    80000c2e:	64a2                	ld	s1,8(sp)
    80000c30:	6105                	addi	sp,sp,32
    80000c32:	8082                	ret
  release(&kmem.lock);
    80000c34:	00011517          	auipc	a0,0x11
    80000c38:	cfc50513          	addi	a0,a0,-772 # 80011930 <kmem>
    80000c3c:	00000097          	auipc	ra,0x0
    80000c40:	14e080e7          	jalr	334(ra) # 80000d8a <release>
  if(r)
    80000c44:	b7d5                	j	80000c28 <kalloc+0x42>

0000000080000c46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c46:	1141                	addi	sp,sp,-16
    80000c48:	e422                	sd	s0,8(sp)
    80000c4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c52:	00053823          	sd	zero,16(a0)
}
    80000c56:	6422                	ld	s0,8(sp)
    80000c58:	0141                	addi	sp,sp,16
    80000c5a:	8082                	ret

0000000080000c5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c5c:	411c                	lw	a5,0(a0)
    80000c5e:	e399                	bnez	a5,80000c64 <holding+0x8>
    80000c60:	4501                	li	a0,0
  return r;
}
    80000c62:	8082                	ret
{
    80000c64:	1101                	addi	sp,sp,-32
    80000c66:	ec06                	sd	ra,24(sp)
    80000c68:	e822                	sd	s0,16(sp)
    80000c6a:	e426                	sd	s1,8(sp)
    80000c6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c6e:	6904                	ld	s1,16(a0)
    80000c70:	00001097          	auipc	ra,0x1
    80000c74:	e58080e7          	jalr	-424(ra) # 80001ac8 <mycpu>
    80000c78:	40a48533          	sub	a0,s1,a0
    80000c7c:	00153513          	seqz	a0,a0
}
    80000c80:	60e2                	ld	ra,24(sp)
    80000c82:	6442                	ld	s0,16(sp)
    80000c84:	64a2                	ld	s1,8(sp)
    80000c86:	6105                	addi	sp,sp,32
    80000c88:	8082                	ret

0000000080000c8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    80000c94:	100024f3          	csrr	s1,sstatus
    80000c98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    80000c9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ca2:	00001097          	auipc	ra,0x1
    80000ca6:	e26080e7          	jalr	-474(ra) # 80001ac8 <mycpu>
    80000caa:	5d3c                	lw	a5,120(a0)
    80000cac:	cf89                	beqz	a5,80000cc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cae:	00001097          	auipc	ra,0x1
    80000cb2:	e1a080e7          	jalr	-486(ra) # 80001ac8 <mycpu>
    80000cb6:	5d3c                	lw	a5,120(a0)
    80000cb8:	2785                	addiw	a5,a5,1
    80000cba:	dd3c                	sw	a5,120(a0)
}
    80000cbc:	60e2                	ld	ra,24(sp)
    80000cbe:	6442                	ld	s0,16(sp)
    80000cc0:	64a2                	ld	s1,8(sp)
    80000cc2:	6105                	addi	sp,sp,32
    80000cc4:	8082                	ret
    mycpu()->intena = old;
    80000cc6:	00001097          	auipc	ra,0x1
    80000cca:	e02080e7          	jalr	-510(ra) # 80001ac8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cce:	8085                	srli	s1,s1,0x1
    80000cd0:	8885                	andi	s1,s1,1
    80000cd2:	dd64                	sw	s1,124(a0)
    80000cd4:	bfe9                	j	80000cae <push_off+0x24>

0000000080000cd6 <acquire>:
{
    80000cd6:	1101                	addi	sp,sp,-32
    80000cd8:	ec06                	sd	ra,24(sp)
    80000cda:	e822                	sd	s0,16(sp)
    80000cdc:	e426                	sd	s1,8(sp)
    80000cde:	1000                	addi	s0,sp,32
    80000ce0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ce2:	00000097          	auipc	ra,0x0
    80000ce6:	fa8080e7          	jalr	-88(ra) # 80000c8a <push_off>
  if(holding(lk))
    80000cea:	8526                	mv	a0,s1
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	f70080e7          	jalr	-144(ra) # 80000c5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cf4:	4705                	li	a4,1
  if(holding(lk))
    80000cf6:	e115                	bnez	a0,80000d1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cf8:	87ba                	mv	a5,a4
    80000cfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cfe:	2781                	sext.w	a5,a5
    80000d00:	ffe5                	bnez	a5,80000cf8 <acquire+0x22>
  __sync_synchronize();
    80000d02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d06:	00001097          	auipc	ra,0x1
    80000d0a:	dc2080e7          	jalr	-574(ra) # 80001ac8 <mycpu>
    80000d0e:	e888                	sd	a0,16(s1)
}
    80000d10:	60e2                	ld	ra,24(sp)
    80000d12:	6442                	ld	s0,16(sp)
    80000d14:	64a2                	ld	s1,8(sp)
    80000d16:	6105                	addi	sp,sp,32
    80000d18:	8082                	ret
    panic("acquire");
    80000d1a:	00007517          	auipc	a0,0x7
    80000d1e:	36e50513          	addi	a0,a0,878 # 80008088 <digits+0x70>
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	8f0080e7          	jalr	-1808(ra) # 80000612 <panic>

0000000080000d2a <pop_off>:

void
pop_off(void)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e406                	sd	ra,8(sp)
    80000d2e:	e022                	sd	s0,0(sp)
    80000d30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d32:	00001097          	auipc	ra,0x1
    80000d36:	d96080e7          	jalr	-618(ra) # 80001ac8 <mycpu>
  asm volatile("csrr %0, sstatus"
    80000d3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d40:	e78d                	bnez	a5,80000d6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d42:	5d3c                	lw	a5,120(a0)
    80000d44:	02f05b63          	blez	a5,80000d7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d48:	37fd                	addiw	a5,a5,-1
    80000d4a:	0007871b          	sext.w	a4,a5
    80000d4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d50:	eb09                	bnez	a4,80000d62 <pop_off+0x38>
    80000d52:	5d7c                	lw	a5,124(a0)
    80000d54:	c799                	beqz	a5,80000d62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus"
    80000d56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80000d5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d62:	60a2                	ld	ra,8(sp)
    80000d64:	6402                	ld	s0,0(sp)
    80000d66:	0141                	addi	sp,sp,16
    80000d68:	8082                	ret
    panic("pop_off - interruptible");
    80000d6a:	00007517          	auipc	a0,0x7
    80000d6e:	32650513          	addi	a0,a0,806 # 80008090 <digits+0x78>
    80000d72:	00000097          	auipc	ra,0x0
    80000d76:	8a0080e7          	jalr	-1888(ra) # 80000612 <panic>
    panic("pop_off");
    80000d7a:	00007517          	auipc	a0,0x7
    80000d7e:	32e50513          	addi	a0,a0,814 # 800080a8 <digits+0x90>
    80000d82:	00000097          	auipc	ra,0x0
    80000d86:	890080e7          	jalr	-1904(ra) # 80000612 <panic>

0000000080000d8a <release>:
{
    80000d8a:	1101                	addi	sp,sp,-32
    80000d8c:	ec06                	sd	ra,24(sp)
    80000d8e:	e822                	sd	s0,16(sp)
    80000d90:	e426                	sd	s1,8(sp)
    80000d92:	1000                	addi	s0,sp,32
    80000d94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d96:	00000097          	auipc	ra,0x0
    80000d9a:	ec6080e7          	jalr	-314(ra) # 80000c5c <holding>
    80000d9e:	c115                	beqz	a0,80000dc2 <release+0x38>
  lk->cpu = 0;
    80000da0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000da4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000da8:	0f50000f          	fence	iorw,ow
    80000dac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000db0:	00000097          	auipc	ra,0x0
    80000db4:	f7a080e7          	jalr	-134(ra) # 80000d2a <pop_off>
}
    80000db8:	60e2                	ld	ra,24(sp)
    80000dba:	6442                	ld	s0,16(sp)
    80000dbc:	64a2                	ld	s1,8(sp)
    80000dbe:	6105                	addi	sp,sp,32
    80000dc0:	8082                	ret
    panic("release");
    80000dc2:	00007517          	auipc	a0,0x7
    80000dc6:	2ee50513          	addi	a0,a0,750 # 800080b0 <digits+0x98>
    80000dca:	00000097          	auipc	ra,0x0
    80000dce:	848080e7          	jalr	-1976(ra) # 80000612 <panic>

0000000080000dd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dd8:	ce09                	beqz	a2,80000df2 <memset+0x20>
    80000dda:	87aa                	mv	a5,a0
    80000ddc:	fff6071b          	addiw	a4,a2,-1
    80000de0:	1702                	slli	a4,a4,0x20
    80000de2:	9301                	srli	a4,a4,0x20
    80000de4:	0705                	addi	a4,a4,1
    80000de6:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000de8:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd8000>
  for(i = 0; i < n; i++){
    80000dec:	0785                	addi	a5,a5,1
    80000dee:	fee79de3          	bne	a5,a4,80000de8 <memset+0x16>
  }
  return dst;
}
    80000df2:	6422                	ld	s0,8(sp)
    80000df4:	0141                	addi	sp,sp,16
    80000df6:	8082                	ret

0000000080000df8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000df8:	1141                	addi	sp,sp,-16
    80000dfa:	e422                	sd	s0,8(sp)
    80000dfc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dfe:	ce15                	beqz	a2,80000e3a <memcmp+0x42>
    80000e00:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    80000e04:	00054783          	lbu	a5,0(a0)
    80000e08:	0005c703          	lbu	a4,0(a1)
    80000e0c:	02e79063          	bne	a5,a4,80000e2c <memcmp+0x34>
    80000e10:	1682                	slli	a3,a3,0x20
    80000e12:	9281                	srli	a3,a3,0x20
    80000e14:	0685                	addi	a3,a3,1
    80000e16:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    80000e18:	0505                	addi	a0,a0,1
    80000e1a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e1c:	00d50d63          	beq	a0,a3,80000e36 <memcmp+0x3e>
    if(*s1 != *s2)
    80000e20:	00054783          	lbu	a5,0(a0)
    80000e24:	0005c703          	lbu	a4,0(a1)
    80000e28:	fee788e3          	beq	a5,a4,80000e18 <memcmp+0x20>
      return *s1 - *s2;
    80000e2c:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    80000e30:	6422                	ld	s0,8(sp)
    80000e32:	0141                	addi	sp,sp,16
    80000e34:	8082                	ret
  return 0;
    80000e36:	4501                	li	a0,0
    80000e38:	bfe5                	j	80000e30 <memcmp+0x38>
    80000e3a:	4501                	li	a0,0
    80000e3c:	bfd5                	j	80000e30 <memcmp+0x38>

0000000080000e3e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e3e:	1141                	addi	sp,sp,-16
    80000e40:	e422                	sd	s0,8(sp)
    80000e42:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e44:	00a5f963          	bleu	a0,a1,80000e56 <memmove+0x18>
    80000e48:	02061713          	slli	a4,a2,0x20
    80000e4c:	9301                	srli	a4,a4,0x20
    80000e4e:	00e587b3          	add	a5,a1,a4
    80000e52:	02f56563          	bltu	a0,a5,80000e7c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e56:	fff6069b          	addiw	a3,a2,-1
    80000e5a:	ce11                	beqz	a2,80000e76 <memmove+0x38>
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	0685                	addi	a3,a3,1
    80000e62:	96ae                	add	a3,a3,a1
    80000e64:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000e66:	0585                	addi	a1,a1,1
    80000e68:	0785                	addi	a5,a5,1
    80000e6a:	fff5c703          	lbu	a4,-1(a1)
    80000e6e:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000e72:	fed59ae3          	bne	a1,a3,80000e66 <memmove+0x28>

  return dst;
}
    80000e76:	6422                	ld	s0,8(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret
    d += n;
    80000e7c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000e7e:	fff6069b          	addiw	a3,a2,-1
    80000e82:	da75                	beqz	a2,80000e76 <memmove+0x38>
    80000e84:	02069613          	slli	a2,a3,0x20
    80000e88:	9201                	srli	a2,a2,0x20
    80000e8a:	fff64613          	not	a2,a2
    80000e8e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e90:	17fd                	addi	a5,a5,-1
    80000e92:	177d                	addi	a4,a4,-1
    80000e94:	0007c683          	lbu	a3,0(a5)
    80000e98:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e9c:	fef61ae3          	bne	a2,a5,80000e90 <memmove+0x52>
    80000ea0:	bfd9                	j	80000e76 <memmove+0x38>

0000000080000ea2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e406                	sd	ra,8(sp)
    80000ea6:	e022                	sd	s0,0(sp)
    80000ea8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	f94080e7          	jalr	-108(ra) # 80000e3e <memmove>
}
    80000eb2:	60a2                	ld	ra,8(sp)
    80000eb4:	6402                	ld	s0,0(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e422                	sd	s0,8(sp)
    80000ebe:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ec0:	c229                	beqz	a2,80000f02 <strncmp+0x48>
    80000ec2:	00054783          	lbu	a5,0(a0)
    80000ec6:	c795                	beqz	a5,80000ef2 <strncmp+0x38>
    80000ec8:	0005c703          	lbu	a4,0(a1)
    80000ecc:	02f71363          	bne	a4,a5,80000ef2 <strncmp+0x38>
    80000ed0:	fff6071b          	addiw	a4,a2,-1
    80000ed4:	1702                	slli	a4,a4,0x20
    80000ed6:	9301                	srli	a4,a4,0x20
    80000ed8:	0705                	addi	a4,a4,1
    80000eda:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000edc:	0505                	addi	a0,a0,1
    80000ede:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ee0:	02e50363          	beq	a0,a4,80000f06 <strncmp+0x4c>
    80000ee4:	00054783          	lbu	a5,0(a0)
    80000ee8:	c789                	beqz	a5,80000ef2 <strncmp+0x38>
    80000eea:	0005c683          	lbu	a3,0(a1)
    80000eee:	fef687e3          	beq	a3,a5,80000edc <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    80000ef2:	00054503          	lbu	a0,0(a0)
    80000ef6:	0005c783          	lbu	a5,0(a1)
    80000efa:	9d1d                	subw	a0,a0,a5
}
    80000efc:	6422                	ld	s0,8(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret
    return 0;
    80000f02:	4501                	li	a0,0
    80000f04:	bfe5                	j	80000efc <strncmp+0x42>
    80000f06:	4501                	li	a0,0
    80000f08:	bfd5                	j	80000efc <strncmp+0x42>

0000000080000f0a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f0a:	1141                	addi	sp,sp,-16
    80000f0c:	e422                	sd	s0,8(sp)
    80000f0e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f10:	872a                	mv	a4,a0
    80000f12:	a011                	j	80000f16 <strncpy+0xc>
    80000f14:	8636                	mv	a2,a3
    80000f16:	fff6069b          	addiw	a3,a2,-1
    80000f1a:	00c05963          	blez	a2,80000f2c <strncpy+0x22>
    80000f1e:	0705                	addi	a4,a4,1
    80000f20:	0005c783          	lbu	a5,0(a1)
    80000f24:	fef70fa3          	sb	a5,-1(a4)
    80000f28:	0585                	addi	a1,a1,1
    80000f2a:	f7ed                	bnez	a5,80000f14 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000f2c:	00d05c63          	blez	a3,80000f44 <strncpy+0x3a>
    80000f30:	86ba                	mv	a3,a4
    *s++ = 0;
    80000f32:	0685                	addi	a3,a3,1
    80000f34:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f38:	fff6c793          	not	a5,a3
    80000f3c:	9fb9                	addw	a5,a5,a4
    80000f3e:	9fb1                	addw	a5,a5,a2
    80000f40:	fef049e3          	bgtz	a5,80000f32 <strncpy+0x28>
  return os;
}
    80000f44:	6422                	ld	s0,8(sp)
    80000f46:	0141                	addi	sp,sp,16
    80000f48:	8082                	ret

0000000080000f4a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f4a:	1141                	addi	sp,sp,-16
    80000f4c:	e422                	sd	s0,8(sp)
    80000f4e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f50:	02c05363          	blez	a2,80000f76 <safestrcpy+0x2c>
    80000f54:	fff6069b          	addiw	a3,a2,-1
    80000f58:	1682                	slli	a3,a3,0x20
    80000f5a:	9281                	srli	a3,a3,0x20
    80000f5c:	96ae                	add	a3,a3,a1
    80000f5e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f60:	00d58963          	beq	a1,a3,80000f72 <safestrcpy+0x28>
    80000f64:	0585                	addi	a1,a1,1
    80000f66:	0785                	addi	a5,a5,1
    80000f68:	fff5c703          	lbu	a4,-1(a1)
    80000f6c:	fee78fa3          	sb	a4,-1(a5)
    80000f70:	fb65                	bnez	a4,80000f60 <safestrcpy+0x16>
    ;
  *s = 0;
    80000f72:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f76:	6422                	ld	s0,8(sp)
    80000f78:	0141                	addi	sp,sp,16
    80000f7a:	8082                	ret

0000000080000f7c <strlen>:

int
strlen(const char *s)
{
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e422                	sd	s0,8(sp)
    80000f80:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f82:	00054783          	lbu	a5,0(a0)
    80000f86:	cf91                	beqz	a5,80000fa2 <strlen+0x26>
    80000f88:	0505                	addi	a0,a0,1
    80000f8a:	87aa                	mv	a5,a0
    80000f8c:	4685                	li	a3,1
    80000f8e:	9e89                	subw	a3,a3,a0
    80000f90:	00f6853b          	addw	a0,a3,a5
    80000f94:	0785                	addi	a5,a5,1
    80000f96:	fff7c703          	lbu	a4,-1(a5)
    80000f9a:	fb7d                	bnez	a4,80000f90 <strlen+0x14>
    ;
  return n;
}
    80000f9c:	6422                	ld	s0,8(sp)
    80000f9e:	0141                	addi	sp,sp,16
    80000fa0:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fa2:	4501                	li	a0,0
    80000fa4:	bfe5                	j	80000f9c <strlen+0x20>

0000000080000fa6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fa6:	1141                	addi	sp,sp,-16
    80000fa8:	e406                	sd	ra,8(sp)
    80000faa:	e022                	sd	s0,0(sp)
    80000fac:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fae:	00001097          	auipc	ra,0x1
    80000fb2:	b0a080e7          	jalr	-1270(ra) # 80001ab8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fb6:	00008717          	auipc	a4,0x8
    80000fba:	05670713          	addi	a4,a4,86 # 8000900c <started>
  if(cpuid() == 0){
    80000fbe:	c139                	beqz	a0,80001004 <main+0x5e>
    while(started == 0)
    80000fc0:	431c                	lw	a5,0(a4)
    80000fc2:	2781                	sext.w	a5,a5
    80000fc4:	dff5                	beqz	a5,80000fc0 <main+0x1a>
      ;
    __sync_synchronize();
    80000fc6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	aee080e7          	jalr	-1298(ra) # 80001ab8 <cpuid>
    80000fd2:	85aa                	mv	a1,a0
    80000fd4:	00007517          	auipc	a0,0x7
    80000fd8:	0fc50513          	addi	a0,a0,252 # 800080d0 <digits+0xb8>
    80000fdc:	fffff097          	auipc	ra,0xfffff
    80000fe0:	688080e7          	jalr	1672(ra) # 80000664 <printf>
    kvminithart();    // turn on paging
    80000fe4:	00000097          	auipc	ra,0x0
    80000fe8:	0d8080e7          	jalr	216(ra) # 800010bc <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fec:	00001097          	auipc	ra,0x1
    80000ff0:	796080e7          	jalr	1942(ra) # 80002782 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ff4:	00005097          	auipc	ra,0x5
    80000ff8:	ecc080e7          	jalr	-308(ra) # 80005ec0 <plicinithart>
  }

  scheduler();        
    80000ffc:	00001097          	auipc	ra,0x1
    80001000:	056080e7          	jalr	86(ra) # 80002052 <scheduler>
    consoleinit();
    80001004:	fffff097          	auipc	ra,0xfffff
    80001008:	47e080e7          	jalr	1150(ra) # 80000482 <consoleinit>
    printfinit();
    8000100c:	fffff097          	auipc	ra,0xfffff
    80001010:	568080e7          	jalr	1384(ra) # 80000574 <printfinit>
    printf("\n");
    80001014:	00007517          	auipc	a0,0x7
    80001018:	0cc50513          	addi	a0,a0,204 # 800080e0 <digits+0xc8>
    8000101c:	fffff097          	auipc	ra,0xfffff
    80001020:	648080e7          	jalr	1608(ra) # 80000664 <printf>
    printf("xv6 kernel is booting\n");
    80001024:	00007517          	auipc	a0,0x7
    80001028:	09450513          	addi	a0,a0,148 # 800080b8 <digits+0xa0>
    8000102c:	fffff097          	auipc	ra,0xfffff
    80001030:	638080e7          	jalr	1592(ra) # 80000664 <printf>
    printf("\n");
    80001034:	00007517          	auipc	a0,0x7
    80001038:	0ac50513          	addi	a0,a0,172 # 800080e0 <digits+0xc8>
    8000103c:	fffff097          	auipc	ra,0xfffff
    80001040:	628080e7          	jalr	1576(ra) # 80000664 <printf>
    kinit();         // physical page allocator
    80001044:	00000097          	auipc	ra,0x0
    80001048:	b66080e7          	jalr	-1178(ra) # 80000baa <kinit>
    kvminit();       // create kernel page table
    8000104c:	00000097          	auipc	ra,0x0
    80001050:	2a6080e7          	jalr	678(ra) # 800012f2 <kvminit>
    kvminithart();   // turn on paging
    80001054:	00000097          	auipc	ra,0x0
    80001058:	068080e7          	jalr	104(ra) # 800010bc <kvminithart>
    procinit();      // process table
    8000105c:	00001097          	auipc	ra,0x1
    80001060:	98c080e7          	jalr	-1652(ra) # 800019e8 <procinit>
    trapinit();      // trap vectors
    80001064:	00001097          	auipc	ra,0x1
    80001068:	6f6080e7          	jalr	1782(ra) # 8000275a <trapinit>
    trapinithart();  // install kernel trap vector
    8000106c:	00001097          	auipc	ra,0x1
    80001070:	716080e7          	jalr	1814(ra) # 80002782 <trapinithart>
    plicinit();      // set up interrupt controller
    80001074:	00005097          	auipc	ra,0x5
    80001078:	e36080e7          	jalr	-458(ra) # 80005eaa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000107c:	00005097          	auipc	ra,0x5
    80001080:	e44080e7          	jalr	-444(ra) # 80005ec0 <plicinithart>
    binit();         // buffer cache
    80001084:	00002097          	auipc	ra,0x2
    80001088:	f14080e7          	jalr	-236(ra) # 80002f98 <binit>
    iinit();         // inode cache
    8000108c:	00002097          	auipc	ra,0x2
    80001090:	5e6080e7          	jalr	1510(ra) # 80003672 <iinit>
    fileinit();      // file table
    80001094:	00003097          	auipc	ra,0x3
    80001098:	5ac080e7          	jalr	1452(ra) # 80004640 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000109c:	00005097          	auipc	ra,0x5
    800010a0:	f2e080e7          	jalr	-210(ra) # 80005fca <virtio_disk_init>
    userinit();      // first user process
    800010a4:	00001097          	auipc	ra,0x1
    800010a8:	d44080e7          	jalr	-700(ra) # 80001de8 <userinit>
    __sync_synchronize();
    800010ac:	0ff0000f          	fence
    started = 1;
    800010b0:	4785                	li	a5,1
    800010b2:	00008717          	auipc	a4,0x8
    800010b6:	f4f72d23          	sw	a5,-166(a4) # 8000900c <started>
    800010ba:	b789                	j	80000ffc <main+0x56>

00000000800010bc <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010bc:	1141                	addi	sp,sp,-16
    800010be:	e422                	sd	s0,8(sp)
    800010c0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800010c2:	00008797          	auipc	a5,0x8
    800010c6:	f4e78793          	addi	a5,a5,-178 # 80009010 <kernel_pagetable>
    800010ca:	639c                	ld	a5,0(a5)
    800010cc:	83b1                	srli	a5,a5,0xc
    800010ce:	577d                	li	a4,-1
    800010d0:	177e                	slli	a4,a4,0x3f
    800010d2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0"
    800010d4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010d8:	12000073          	sfence.vma
  sfence_vma();
}
    800010dc:	6422                	ld	s0,8(sp)
    800010de:	0141                	addi	sp,sp,16
    800010e0:	8082                	ret

00000000800010e2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010e2:	7139                	addi	sp,sp,-64
    800010e4:	fc06                	sd	ra,56(sp)
    800010e6:	f822                	sd	s0,48(sp)
    800010e8:	f426                	sd	s1,40(sp)
    800010ea:	f04a                	sd	s2,32(sp)
    800010ec:	ec4e                	sd	s3,24(sp)
    800010ee:	e852                	sd	s4,16(sp)
    800010f0:	e456                	sd	s5,8(sp)
    800010f2:	e05a                	sd	s6,0(sp)
    800010f4:	0080                	addi	s0,sp,64
    800010f6:	84aa                	mv	s1,a0
    800010f8:	89ae                	mv	s3,a1
    800010fa:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010fc:	57fd                	li	a5,-1
    800010fe:	83e9                	srli	a5,a5,0x1a
    80001100:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001102:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80001104:	04b7f263          	bleu	a1,a5,80001148 <walk+0x66>
    panic("walk");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xd0>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	502080e7          	jalr	1282(ra) # 80000612 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001118:	060b0663          	beqz	s6,80001184 <walk+0xa2>
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	aca080e7          	jalr	-1334(ra) # 80000be6 <kalloc>
    80001124:	84aa                	mv	s1,a0
    80001126:	c529                	beqz	a0,80001170 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001128:	6605                	lui	a2,0x1
    8000112a:	4581                	li	a1,0
    8000112c:	00000097          	auipc	ra,0x0
    80001130:	ca6080e7          	jalr	-858(ra) # 80000dd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001134:	00c4d793          	srli	a5,s1,0xc
    80001138:	07aa                	slli	a5,a5,0xa
    8000113a:	0017e793          	ori	a5,a5,1
    8000113e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001142:	3a5d                	addiw	s4,s4,-9
    80001144:	035a0063          	beq	s4,s5,80001164 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001148:	0149d933          	srl	s2,s3,s4
    8000114c:	1ff97913          	andi	s2,s2,511
    80001150:	090e                	slli	s2,s2,0x3
    80001152:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001154:	00093483          	ld	s1,0(s2)
    80001158:	0014f793          	andi	a5,s1,1
    8000115c:	dfd5                	beqz	a5,80001118 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000115e:	80a9                	srli	s1,s1,0xa
    80001160:	04b2                	slli	s1,s1,0xc
    80001162:	b7c5                	j	80001142 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001164:	00c9d513          	srli	a0,s3,0xc
    80001168:	1ff57513          	andi	a0,a0,511
    8000116c:	050e                	slli	a0,a0,0x3
    8000116e:	9526                	add	a0,a0,s1
}
    80001170:	70e2                	ld	ra,56(sp)
    80001172:	7442                	ld	s0,48(sp)
    80001174:	74a2                	ld	s1,40(sp)
    80001176:	7902                	ld	s2,32(sp)
    80001178:	69e2                	ld	s3,24(sp)
    8000117a:	6a42                	ld	s4,16(sp)
    8000117c:	6aa2                	ld	s5,8(sp)
    8000117e:	6b02                	ld	s6,0(sp)
    80001180:	6121                	addi	sp,sp,64
    80001182:	8082                	ret
        return 0;
    80001184:	4501                	li	a0,0
    80001186:	b7ed                	j	80001170 <walk+0x8e>

0000000080001188 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001188:	57fd                	li	a5,-1
    8000118a:	83e9                	srli	a5,a5,0x1a
    8000118c:	00b7f463          	bleu	a1,a5,80001194 <walkaddr+0xc>
    return 0;
    80001190:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001192:	8082                	ret
{
    80001194:	1141                	addi	sp,sp,-16
    80001196:	e406                	sd	ra,8(sp)
    80001198:	e022                	sd	s0,0(sp)
    8000119a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000119c:	4601                	li	a2,0
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	f44080e7          	jalr	-188(ra) # 800010e2 <walk>
  if(pte == 0)
    800011a6:	c105                	beqz	a0,800011c6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011a8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011aa:	0117f693          	andi	a3,a5,17
    800011ae:	4745                	li	a4,17
    return 0;
    800011b0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011b2:	00e68663          	beq	a3,a4,800011be <walkaddr+0x36>
}
    800011b6:	60a2                	ld	ra,8(sp)
    800011b8:	6402                	ld	s0,0(sp)
    800011ba:	0141                	addi	sp,sp,16
    800011bc:	8082                	ret
  pa = PTE2PA(*pte);
    800011be:	00a7d513          	srli	a0,a5,0xa
    800011c2:	0532                	slli	a0,a0,0xc
  return pa;
    800011c4:	bfcd                	j	800011b6 <walkaddr+0x2e>
    return 0;
    800011c6:	4501                	li	a0,0
    800011c8:	b7fd                	j	800011b6 <walkaddr+0x2e>

00000000800011ca <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800011ca:	1101                	addi	sp,sp,-32
    800011cc:	ec06                	sd	ra,24(sp)
    800011ce:	e822                	sd	s0,16(sp)
    800011d0:	e426                	sd	s1,8(sp)
    800011d2:	1000                	addi	s0,sp,32
    800011d4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800011d6:	6785                	lui	a5,0x1
    800011d8:	17fd                	addi	a5,a5,-1
    800011da:	00f574b3          	and	s1,a0,a5
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800011de:	4601                	li	a2,0
    800011e0:	00008797          	auipc	a5,0x8
    800011e4:	e3078793          	addi	a5,a5,-464 # 80009010 <kernel_pagetable>
    800011e8:	6388                	ld	a0,0(a5)
    800011ea:	00000097          	auipc	ra,0x0
    800011ee:	ef8080e7          	jalr	-264(ra) # 800010e2 <walk>
  if(pte == 0)
    800011f2:	cd09                	beqz	a0,8000120c <kvmpa+0x42>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800011f4:	6108                	ld	a0,0(a0)
    800011f6:	00157793          	andi	a5,a0,1
    800011fa:	c38d                	beqz	a5,8000121c <kvmpa+0x52>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800011fc:	8129                	srli	a0,a0,0xa
    800011fe:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001200:	9526                	add	a0,a0,s1
    80001202:	60e2                	ld	ra,24(sp)
    80001204:	6442                	ld	s0,16(sp)
    80001206:	64a2                	ld	s1,8(sp)
    80001208:	6105                	addi	sp,sp,32
    8000120a:	8082                	ret
    panic("kvmpa");
    8000120c:	00007517          	auipc	a0,0x7
    80001210:	ee450513          	addi	a0,a0,-284 # 800080f0 <digits+0xd8>
    80001214:	fffff097          	auipc	ra,0xfffff
    80001218:	3fe080e7          	jalr	1022(ra) # 80000612 <panic>
    panic("kvmpa");
    8000121c:	00007517          	auipc	a0,0x7
    80001220:	ed450513          	addi	a0,a0,-300 # 800080f0 <digits+0xd8>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	3ee080e7          	jalr	1006(ra) # 80000612 <panic>

000000008000122c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000122c:	715d                	addi	sp,sp,-80
    8000122e:	e486                	sd	ra,72(sp)
    80001230:	e0a2                	sd	s0,64(sp)
    80001232:	fc26                	sd	s1,56(sp)
    80001234:	f84a                	sd	s2,48(sp)
    80001236:	f44e                	sd	s3,40(sp)
    80001238:	f052                	sd	s4,32(sp)
    8000123a:	ec56                	sd	s5,24(sp)
    8000123c:	e85a                	sd	s6,16(sp)
    8000123e:	e45e                	sd	s7,8(sp)
    80001240:	0880                	addi	s0,sp,80
    80001242:	8aaa                	mv	s5,a0
    80001244:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001246:	79fd                	lui	s3,0xfffff
    80001248:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    8000124c:	167d                	addi	a2,a2,-1
    8000124e:	962e                	add	a2,a2,a1
    80001250:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    80001254:	8952                	mv	s2,s4
    80001256:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000125a:	6b85                	lui	s7,0x1
    8000125c:	a811                	j	80001270 <mappages+0x44>
      panic("remap");
    8000125e:	00007517          	auipc	a0,0x7
    80001262:	e9a50513          	addi	a0,a0,-358 # 800080f8 <digits+0xe0>
    80001266:	fffff097          	auipc	ra,0xfffff
    8000126a:	3ac080e7          	jalr	940(ra) # 80000612 <panic>
    a += PGSIZE;
    8000126e:	995e                	add	s2,s2,s7
  for(;;){
    80001270:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001274:	4605                	li	a2,1
    80001276:	85ca                	mv	a1,s2
    80001278:	8556                	mv	a0,s5
    8000127a:	00000097          	auipc	ra,0x0
    8000127e:	e68080e7          	jalr	-408(ra) # 800010e2 <walk>
    80001282:	cd19                	beqz	a0,800012a0 <mappages+0x74>
    if(*pte & PTE_V)
    80001284:	611c                	ld	a5,0(a0)
    80001286:	8b85                	andi	a5,a5,1
    80001288:	fbf9                	bnez	a5,8000125e <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000128a:	80b1                	srli	s1,s1,0xc
    8000128c:	04aa                	slli	s1,s1,0xa
    8000128e:	0164e4b3          	or	s1,s1,s6
    80001292:	0014e493          	ori	s1,s1,1
    80001296:	e104                	sd	s1,0(a0)
    if(a == last)
    80001298:	fd391be3          	bne	s2,s3,8000126e <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    8000129c:	4501                	li	a0,0
    8000129e:	a011                	j	800012a2 <mappages+0x76>
      return -1;
    800012a0:	557d                	li	a0,-1
}
    800012a2:	60a6                	ld	ra,72(sp)
    800012a4:	6406                	ld	s0,64(sp)
    800012a6:	74e2                	ld	s1,56(sp)
    800012a8:	7942                	ld	s2,48(sp)
    800012aa:	79a2                	ld	s3,40(sp)
    800012ac:	7a02                	ld	s4,32(sp)
    800012ae:	6ae2                	ld	s5,24(sp)
    800012b0:	6b42                	ld	s6,16(sp)
    800012b2:	6ba2                	ld	s7,8(sp)
    800012b4:	6161                	addi	sp,sp,80
    800012b6:	8082                	ret

00000000800012b8 <kvmmap>:
{
    800012b8:	1141                	addi	sp,sp,-16
    800012ba:	e406                	sd	ra,8(sp)
    800012bc:	e022                	sd	s0,0(sp)
    800012be:	0800                	addi	s0,sp,16
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800012c0:	8736                	mv	a4,a3
    800012c2:	86ae                	mv	a3,a1
    800012c4:	85aa                	mv	a1,a0
    800012c6:	00008797          	auipc	a5,0x8
    800012ca:	d4a78793          	addi	a5,a5,-694 # 80009010 <kernel_pagetable>
    800012ce:	6388                	ld	a0,0(a5)
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	f5c080e7          	jalr	-164(ra) # 8000122c <mappages>
    800012d8:	e509                	bnez	a0,800012e2 <kvmmap+0x2a>
}
    800012da:	60a2                	ld	ra,8(sp)
    800012dc:	6402                	ld	s0,0(sp)
    800012de:	0141                	addi	sp,sp,16
    800012e0:	8082                	ret
    panic("kvmmap");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e1e50513          	addi	a0,a0,-482 # 80008100 <digits+0xe8>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	328080e7          	jalr	808(ra) # 80000612 <panic>

00000000800012f2 <kvminit>:
{
    800012f2:	1101                	addi	sp,sp,-32
    800012f4:	ec06                	sd	ra,24(sp)
    800012f6:	e822                	sd	s0,16(sp)
    800012f8:	e426                	sd	s1,8(sp)
    800012fa:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	8ea080e7          	jalr	-1814(ra) # 80000be6 <kalloc>
    80001304:	00008797          	auipc	a5,0x8
    80001308:	d0a7b623          	sd	a0,-756(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000130c:	6605                	lui	a2,0x1
    8000130e:	4581                	li	a1,0
    80001310:	00000097          	auipc	ra,0x0
    80001314:	ac2080e7          	jalr	-1342(ra) # 80000dd2 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001318:	4699                	li	a3,6
    8000131a:	6605                	lui	a2,0x1
    8000131c:	100005b7          	lui	a1,0x10000
    80001320:	10000537          	lui	a0,0x10000
    80001324:	00000097          	auipc	ra,0x0
    80001328:	f94080e7          	jalr	-108(ra) # 800012b8 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000132c:	4699                	li	a3,6
    8000132e:	6605                	lui	a2,0x1
    80001330:	100015b7          	lui	a1,0x10001
    80001334:	10001537          	lui	a0,0x10001
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	f80080e7          	jalr	-128(ra) # 800012b8 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001340:	4699                	li	a3,6
    80001342:	6641                	lui	a2,0x10
    80001344:	020005b7          	lui	a1,0x2000
    80001348:	02000537          	lui	a0,0x2000
    8000134c:	00000097          	auipc	ra,0x0
    80001350:	f6c080e7          	jalr	-148(ra) # 800012b8 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001354:	4699                	li	a3,6
    80001356:	00400637          	lui	a2,0x400
    8000135a:	0c0005b7          	lui	a1,0xc000
    8000135e:	0c000537          	lui	a0,0xc000
    80001362:	00000097          	auipc	ra,0x0
    80001366:	f56080e7          	jalr	-170(ra) # 800012b8 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000136a:	00007497          	auipc	s1,0x7
    8000136e:	c9648493          	addi	s1,s1,-874 # 80008000 <etext>
    80001372:	46a9                	li	a3,10
    80001374:	80007617          	auipc	a2,0x80007
    80001378:	c8c60613          	addi	a2,a2,-884 # 8000 <_entry-0x7fff8000>
    8000137c:	4585                	li	a1,1
    8000137e:	05fe                	slli	a1,a1,0x1f
    80001380:	852e                	mv	a0,a1
    80001382:	00000097          	auipc	ra,0x0
    80001386:	f36080e7          	jalr	-202(ra) # 800012b8 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000138a:	4699                	li	a3,6
    8000138c:	4645                	li	a2,17
    8000138e:	066e                	slli	a2,a2,0x1b
    80001390:	8e05                	sub	a2,a2,s1
    80001392:	85a6                	mv	a1,s1
    80001394:	8526                	mv	a0,s1
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	f22080e7          	jalr	-222(ra) # 800012b8 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000139e:	46a9                	li	a3,10
    800013a0:	6605                	lui	a2,0x1
    800013a2:	00006597          	auipc	a1,0x6
    800013a6:	c5e58593          	addi	a1,a1,-930 # 80007000 <_trampoline>
    800013aa:	04000537          	lui	a0,0x4000
    800013ae:	157d                	addi	a0,a0,-1
    800013b0:	0532                	slli	a0,a0,0xc
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	f06080e7          	jalr	-250(ra) # 800012b8 <kvmmap>
}
    800013ba:	60e2                	ld	ra,24(sp)
    800013bc:	6442                	ld	s0,16(sp)
    800013be:	64a2                	ld	s1,8(sp)
    800013c0:	6105                	addi	sp,sp,32
    800013c2:	8082                	ret

00000000800013c4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013c4:	715d                	addi	sp,sp,-80
    800013c6:	e486                	sd	ra,72(sp)
    800013c8:	e0a2                	sd	s0,64(sp)
    800013ca:	fc26                	sd	s1,56(sp)
    800013cc:	f84a                	sd	s2,48(sp)
    800013ce:	f44e                	sd	s3,40(sp)
    800013d0:	f052                	sd	s4,32(sp)
    800013d2:	ec56                	sd	s5,24(sp)
    800013d4:	e85a                	sd	s6,16(sp)
    800013d6:	e45e                	sd	s7,8(sp)
    800013d8:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	8fed                	and	a5,a5,a1
    800013e0:	e795                	bnez	a5,8000140c <uvmunmap+0x48>
    800013e2:	8a2a                	mv	s4,a0
    800013e4:	84ae                	mv	s1,a1
    800013e6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013e8:	0632                	slli	a2,a2,0xc
    800013ea:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013ee:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013f0:	6b05                	lui	s6,0x1
    800013f2:	0735e863          	bltu	a1,s3,80001462 <uvmunmap+0x9e>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013f6:	60a6                	ld	ra,72(sp)
    800013f8:	6406                	ld	s0,64(sp)
    800013fa:	74e2                	ld	s1,56(sp)
    800013fc:	7942                	ld	s2,48(sp)
    800013fe:	79a2                	ld	s3,40(sp)
    80001400:	7a02                	ld	s4,32(sp)
    80001402:	6ae2                	ld	s5,24(sp)
    80001404:	6b42                	ld	s6,16(sp)
    80001406:	6ba2                	ld	s7,8(sp)
    80001408:	6161                	addi	sp,sp,80
    8000140a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000140c:	00007517          	auipc	a0,0x7
    80001410:	cfc50513          	addi	a0,a0,-772 # 80008108 <digits+0xf0>
    80001414:	fffff097          	auipc	ra,0xfffff
    80001418:	1fe080e7          	jalr	510(ra) # 80000612 <panic>
      panic("uvmunmap: walk");
    8000141c:	00007517          	auipc	a0,0x7
    80001420:	d0450513          	addi	a0,a0,-764 # 80008120 <digits+0x108>
    80001424:	fffff097          	auipc	ra,0xfffff
    80001428:	1ee080e7          	jalr	494(ra) # 80000612 <panic>
      panic("uvmunmap: not mapped");
    8000142c:	00007517          	auipc	a0,0x7
    80001430:	d0450513          	addi	a0,a0,-764 # 80008130 <digits+0x118>
    80001434:	fffff097          	auipc	ra,0xfffff
    80001438:	1de080e7          	jalr	478(ra) # 80000612 <panic>
      panic("uvmunmap: not a leaf");
    8000143c:	00007517          	auipc	a0,0x7
    80001440:	d0c50513          	addi	a0,a0,-756 # 80008148 <digits+0x130>
    80001444:	fffff097          	auipc	ra,0xfffff
    80001448:	1ce080e7          	jalr	462(ra) # 80000612 <panic>
      uint64 pa = PTE2PA(*pte);
    8000144c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000144e:	0532                	slli	a0,a0,0xc
    80001450:	fffff097          	auipc	ra,0xfffff
    80001454:	696080e7          	jalr	1686(ra) # 80000ae6 <kfree>
    *pte = 0;
    80001458:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000145c:	94da                	add	s1,s1,s6
    8000145e:	f934fce3          	bleu	s3,s1,800013f6 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001462:	4601                	li	a2,0
    80001464:	85a6                	mv	a1,s1
    80001466:	8552                	mv	a0,s4
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	c7a080e7          	jalr	-902(ra) # 800010e2 <walk>
    80001470:	892a                	mv	s2,a0
    80001472:	d54d                	beqz	a0,8000141c <uvmunmap+0x58>
    if((*pte & PTE_V) == 0)
    80001474:	6108                	ld	a0,0(a0)
    80001476:	00157793          	andi	a5,a0,1
    8000147a:	dbcd                	beqz	a5,8000142c <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000147c:	3ff57793          	andi	a5,a0,1023
    80001480:	fb778ee3          	beq	a5,s7,8000143c <uvmunmap+0x78>
    if(do_free){
    80001484:	fc0a8ae3          	beqz	s5,80001458 <uvmunmap+0x94>
    80001488:	b7d1                	j	8000144c <uvmunmap+0x88>

000000008000148a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000148a:	1101                	addi	sp,sp,-32
    8000148c:	ec06                	sd	ra,24(sp)
    8000148e:	e822                	sd	s0,16(sp)
    80001490:	e426                	sd	s1,8(sp)
    80001492:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001494:	fffff097          	auipc	ra,0xfffff
    80001498:	752080e7          	jalr	1874(ra) # 80000be6 <kalloc>
    8000149c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000149e:	c519                	beqz	a0,800014ac <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800014a0:	6605                	lui	a2,0x1
    800014a2:	4581                	li	a1,0
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	92e080e7          	jalr	-1746(ra) # 80000dd2 <memset>
  return pagetable;
}
    800014ac:	8526                	mv	a0,s1
    800014ae:	60e2                	ld	ra,24(sp)
    800014b0:	6442                	ld	s0,16(sp)
    800014b2:	64a2                	ld	s1,8(sp)
    800014b4:	6105                	addi	sp,sp,32
    800014b6:	8082                	ret

00000000800014b8 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800014b8:	7179                	addi	sp,sp,-48
    800014ba:	f406                	sd	ra,40(sp)
    800014bc:	f022                	sd	s0,32(sp)
    800014be:	ec26                	sd	s1,24(sp)
    800014c0:	e84a                	sd	s2,16(sp)
    800014c2:	e44e                	sd	s3,8(sp)
    800014c4:	e052                	sd	s4,0(sp)
    800014c6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800014c8:	6785                	lui	a5,0x1
    800014ca:	04f67863          	bleu	a5,a2,8000151a <uvminit+0x62>
    800014ce:	8a2a                	mv	s4,a0
    800014d0:	89ae                	mv	s3,a1
    800014d2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800014d4:	fffff097          	auipc	ra,0xfffff
    800014d8:	712080e7          	jalr	1810(ra) # 80000be6 <kalloc>
    800014dc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014de:	6605                	lui	a2,0x1
    800014e0:	4581                	li	a1,0
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	8f0080e7          	jalr	-1808(ra) # 80000dd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014ea:	4779                	li	a4,30
    800014ec:	86ca                	mv	a3,s2
    800014ee:	6605                	lui	a2,0x1
    800014f0:	4581                	li	a1,0
    800014f2:	8552                	mv	a0,s4
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	d38080e7          	jalr	-712(ra) # 8000122c <mappages>
  memmove(mem, src, sz);
    800014fc:	8626                	mv	a2,s1
    800014fe:	85ce                	mv	a1,s3
    80001500:	854a                	mv	a0,s2
    80001502:	00000097          	auipc	ra,0x0
    80001506:	93c080e7          	jalr	-1732(ra) # 80000e3e <memmove>
}
    8000150a:	70a2                	ld	ra,40(sp)
    8000150c:	7402                	ld	s0,32(sp)
    8000150e:	64e2                	ld	s1,24(sp)
    80001510:	6942                	ld	s2,16(sp)
    80001512:	69a2                	ld	s3,8(sp)
    80001514:	6a02                	ld	s4,0(sp)
    80001516:	6145                	addi	sp,sp,48
    80001518:	8082                	ret
    panic("inituvm: more than a page");
    8000151a:	00007517          	auipc	a0,0x7
    8000151e:	c4650513          	addi	a0,a0,-954 # 80008160 <digits+0x148>
    80001522:	fffff097          	auipc	ra,0xfffff
    80001526:	0f0080e7          	jalr	240(ra) # 80000612 <panic>

000000008000152a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000152a:	1101                	addi	sp,sp,-32
    8000152c:	ec06                	sd	ra,24(sp)
    8000152e:	e822                	sd	s0,16(sp)
    80001530:	e426                	sd	s1,8(sp)
    80001532:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001534:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001536:	00b67d63          	bleu	a1,a2,80001550 <uvmdealloc+0x26>
    8000153a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000153c:	6605                	lui	a2,0x1
    8000153e:	167d                	addi	a2,a2,-1
    80001540:	00c487b3          	add	a5,s1,a2
    80001544:	777d                	lui	a4,0xfffff
    80001546:	8ff9                	and	a5,a5,a4
    80001548:	962e                	add	a2,a2,a1
    8000154a:	8e79                	and	a2,a2,a4
    8000154c:	00c7e863          	bltu	a5,a2,8000155c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001550:	8526                	mv	a0,s1
    80001552:	60e2                	ld	ra,24(sp)
    80001554:	6442                	ld	s0,16(sp)
    80001556:	64a2                	ld	s1,8(sp)
    80001558:	6105                	addi	sp,sp,32
    8000155a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000155c:	8e1d                	sub	a2,a2,a5
    8000155e:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001560:	4685                	li	a3,1
    80001562:	2601                	sext.w	a2,a2
    80001564:	85be                	mv	a1,a5
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	e5e080e7          	jalr	-418(ra) # 800013c4 <uvmunmap>
    8000156e:	b7cd                	j	80001550 <uvmdealloc+0x26>

0000000080001570 <uvmalloc>:
  if(newsz < oldsz)
    80001570:	0ab66163          	bltu	a2,a1,80001612 <uvmalloc+0xa2>
{
    80001574:	7139                	addi	sp,sp,-64
    80001576:	fc06                	sd	ra,56(sp)
    80001578:	f822                	sd	s0,48(sp)
    8000157a:	f426                	sd	s1,40(sp)
    8000157c:	f04a                	sd	s2,32(sp)
    8000157e:	ec4e                	sd	s3,24(sp)
    80001580:	e852                	sd	s4,16(sp)
    80001582:	e456                	sd	s5,8(sp)
    80001584:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    80001586:	6a05                	lui	s4,0x1
    80001588:	1a7d                	addi	s4,s4,-1
    8000158a:	95d2                	add	a1,a1,s4
    8000158c:	7a7d                	lui	s4,0xfffff
    8000158e:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001592:	08ca7263          	bleu	a2,s4,80001616 <uvmalloc+0xa6>
    80001596:	89b2                	mv	s3,a2
    80001598:	8aaa                	mv	s5,a0
    8000159a:	8952                	mv	s2,s4
    mem = kalloc();
    8000159c:	fffff097          	auipc	ra,0xfffff
    800015a0:	64a080e7          	jalr	1610(ra) # 80000be6 <kalloc>
    800015a4:	84aa                	mv	s1,a0
    if(mem == 0){
    800015a6:	c51d                	beqz	a0,800015d4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800015a8:	6605                	lui	a2,0x1
    800015aa:	4581                	li	a1,0
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	826080e7          	jalr	-2010(ra) # 80000dd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800015b4:	4779                	li	a4,30
    800015b6:	86a6                	mv	a3,s1
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85ca                	mv	a1,s2
    800015bc:	8556                	mv	a0,s5
    800015be:	00000097          	auipc	ra,0x0
    800015c2:	c6e080e7          	jalr	-914(ra) # 8000122c <mappages>
    800015c6:	e905                	bnez	a0,800015f6 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015c8:	6785                	lui	a5,0x1
    800015ca:	993e                	add	s2,s2,a5
    800015cc:	fd3968e3          	bltu	s2,s3,8000159c <uvmalloc+0x2c>
  return newsz;
    800015d0:	854e                	mv	a0,s3
    800015d2:	a809                	j	800015e4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800015d4:	8652                	mv	a2,s4
    800015d6:	85ca                	mv	a1,s2
    800015d8:	8556                	mv	a0,s5
    800015da:	00000097          	auipc	ra,0x0
    800015de:	f50080e7          	jalr	-176(ra) # 8000152a <uvmdealloc>
      return 0;
    800015e2:	4501                	li	a0,0
}
    800015e4:	70e2                	ld	ra,56(sp)
    800015e6:	7442                	ld	s0,48(sp)
    800015e8:	74a2                	ld	s1,40(sp)
    800015ea:	7902                	ld	s2,32(sp)
    800015ec:	69e2                	ld	s3,24(sp)
    800015ee:	6a42                	ld	s4,16(sp)
    800015f0:	6aa2                	ld	s5,8(sp)
    800015f2:	6121                	addi	sp,sp,64
    800015f4:	8082                	ret
      kfree(mem);
    800015f6:	8526                	mv	a0,s1
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	4ee080e7          	jalr	1262(ra) # 80000ae6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001600:	8652                	mv	a2,s4
    80001602:	85ca                	mv	a1,s2
    80001604:	8556                	mv	a0,s5
    80001606:	00000097          	auipc	ra,0x0
    8000160a:	f24080e7          	jalr	-220(ra) # 8000152a <uvmdealloc>
      return 0;
    8000160e:	4501                	li	a0,0
    80001610:	bfd1                	j	800015e4 <uvmalloc+0x74>
    return oldsz;
    80001612:	852e                	mv	a0,a1
}
    80001614:	8082                	ret
  return newsz;
    80001616:	8532                	mv	a0,a2
    80001618:	b7f1                	j	800015e4 <uvmalloc+0x74>

000000008000161a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000161a:	7179                	addi	sp,sp,-48
    8000161c:	f406                	sd	ra,40(sp)
    8000161e:	f022                	sd	s0,32(sp)
    80001620:	ec26                	sd	s1,24(sp)
    80001622:	e84a                	sd	s2,16(sp)
    80001624:	e44e                	sd	s3,8(sp)
    80001626:	e052                	sd	s4,0(sp)
    80001628:	1800                	addi	s0,sp,48
    8000162a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000162c:	84aa                	mv	s1,a0
    8000162e:	6905                	lui	s2,0x1
    80001630:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001632:	4985                	li	s3,1
    80001634:	a821                	j	8000164c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001636:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001638:	0532                	slli	a0,a0,0xc
    8000163a:	00000097          	auipc	ra,0x0
    8000163e:	fe0080e7          	jalr	-32(ra) # 8000161a <freewalk>
      pagetable[i] = 0;
    80001642:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001646:	04a1                	addi	s1,s1,8
    80001648:	03248163          	beq	s1,s2,8000166a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000164c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000164e:	00f57793          	andi	a5,a0,15
    80001652:	ff3782e3          	beq	a5,s3,80001636 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001656:	8905                	andi	a0,a0,1
    80001658:	d57d                	beqz	a0,80001646 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000165a:	00007517          	auipc	a0,0x7
    8000165e:	b2650513          	addi	a0,a0,-1242 # 80008180 <digits+0x168>
    80001662:	fffff097          	auipc	ra,0xfffff
    80001666:	fb0080e7          	jalr	-80(ra) # 80000612 <panic>
    }
  }
  kfree((void*)pagetable);
    8000166a:	8552                	mv	a0,s4
    8000166c:	fffff097          	auipc	ra,0xfffff
    80001670:	47a080e7          	jalr	1146(ra) # 80000ae6 <kfree>
}
    80001674:	70a2                	ld	ra,40(sp)
    80001676:	7402                	ld	s0,32(sp)
    80001678:	64e2                	ld	s1,24(sp)
    8000167a:	6942                	ld	s2,16(sp)
    8000167c:	69a2                	ld	s3,8(sp)
    8000167e:	6a02                	ld	s4,0(sp)
    80001680:	6145                	addi	sp,sp,48
    80001682:	8082                	ret

0000000080001684 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001684:	1101                	addi	sp,sp,-32
    80001686:	ec06                	sd	ra,24(sp)
    80001688:	e822                	sd	s0,16(sp)
    8000168a:	e426                	sd	s1,8(sp)
    8000168c:	1000                	addi	s0,sp,32
    8000168e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001690:	e999                	bnez	a1,800016a6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001692:	8526                	mv	a0,s1
    80001694:	00000097          	auipc	ra,0x0
    80001698:	f86080e7          	jalr	-122(ra) # 8000161a <freewalk>
}
    8000169c:	60e2                	ld	ra,24(sp)
    8000169e:	6442                	ld	s0,16(sp)
    800016a0:	64a2                	ld	s1,8(sp)
    800016a2:	6105                	addi	sp,sp,32
    800016a4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016a6:	6605                	lui	a2,0x1
    800016a8:	167d                	addi	a2,a2,-1
    800016aa:	962e                	add	a2,a2,a1
    800016ac:	4685                	li	a3,1
    800016ae:	8231                	srli	a2,a2,0xc
    800016b0:	4581                	li	a1,0
    800016b2:	00000097          	auipc	ra,0x0
    800016b6:	d12080e7          	jalr	-750(ra) # 800013c4 <uvmunmap>
    800016ba:	bfe1                	j	80001692 <uvmfree+0xe>

00000000800016bc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016bc:	c679                	beqz	a2,8000178a <uvmcopy+0xce>
{
    800016be:	715d                	addi	sp,sp,-80
    800016c0:	e486                	sd	ra,72(sp)
    800016c2:	e0a2                	sd	s0,64(sp)
    800016c4:	fc26                	sd	s1,56(sp)
    800016c6:	f84a                	sd	s2,48(sp)
    800016c8:	f44e                	sd	s3,40(sp)
    800016ca:	f052                	sd	s4,32(sp)
    800016cc:	ec56                	sd	s5,24(sp)
    800016ce:	e85a                	sd	s6,16(sp)
    800016d0:	e45e                	sd	s7,8(sp)
    800016d2:	0880                	addi	s0,sp,80
    800016d4:	8ab2                	mv	s5,a2
    800016d6:	8b2e                	mv	s6,a1
    800016d8:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    800016da:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    800016dc:	4601                	li	a2,0
    800016de:	85ca                	mv	a1,s2
    800016e0:	855e                	mv	a0,s7
    800016e2:	00000097          	auipc	ra,0x0
    800016e6:	a00080e7          	jalr	-1536(ra) # 800010e2 <walk>
    800016ea:	c531                	beqz	a0,80001736 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800016ec:	6118                	ld	a4,0(a0)
    800016ee:	00177793          	andi	a5,a4,1
    800016f2:	cbb1                	beqz	a5,80001746 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800016f4:	00a75593          	srli	a1,a4,0xa
    800016f8:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016fc:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	4e6080e7          	jalr	1254(ra) # 80000be6 <kalloc>
    80001708:	8a2a                	mv	s4,a0
    8000170a:	c939                	beqz	a0,80001760 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000170c:	6605                	lui	a2,0x1
    8000170e:	85ce                	mv	a1,s3
    80001710:	fffff097          	auipc	ra,0xfffff
    80001714:	72e080e7          	jalr	1838(ra) # 80000e3e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001718:	8726                	mv	a4,s1
    8000171a:	86d2                	mv	a3,s4
    8000171c:	6605                	lui	a2,0x1
    8000171e:	85ca                	mv	a1,s2
    80001720:	855a                	mv	a0,s6
    80001722:	00000097          	auipc	ra,0x0
    80001726:	b0a080e7          	jalr	-1270(ra) # 8000122c <mappages>
    8000172a:	e515                	bnez	a0,80001756 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000172c:	6785                	lui	a5,0x1
    8000172e:	993e                	add	s2,s2,a5
    80001730:	fb5966e3          	bltu	s2,s5,800016dc <uvmcopy+0x20>
    80001734:	a081                	j	80001774 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001736:	00007517          	auipc	a0,0x7
    8000173a:	a5a50513          	addi	a0,a0,-1446 # 80008190 <digits+0x178>
    8000173e:	fffff097          	auipc	ra,0xfffff
    80001742:	ed4080e7          	jalr	-300(ra) # 80000612 <panic>
      panic("uvmcopy: page not present");
    80001746:	00007517          	auipc	a0,0x7
    8000174a:	a6a50513          	addi	a0,a0,-1430 # 800081b0 <digits+0x198>
    8000174e:	fffff097          	auipc	ra,0xfffff
    80001752:	ec4080e7          	jalr	-316(ra) # 80000612 <panic>
      kfree(mem);
    80001756:	8552                	mv	a0,s4
    80001758:	fffff097          	auipc	ra,0xfffff
    8000175c:	38e080e7          	jalr	910(ra) # 80000ae6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001760:	4685                	li	a3,1
    80001762:	00c95613          	srli	a2,s2,0xc
    80001766:	4581                	li	a1,0
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	c5a080e7          	jalr	-934(ra) # 800013c4 <uvmunmap>
  return -1;
    80001772:	557d                	li	a0,-1
}
    80001774:	60a6                	ld	ra,72(sp)
    80001776:	6406                	ld	s0,64(sp)
    80001778:	74e2                	ld	s1,56(sp)
    8000177a:	7942                	ld	s2,48(sp)
    8000177c:	79a2                	ld	s3,40(sp)
    8000177e:	7a02                	ld	s4,32(sp)
    80001780:	6ae2                	ld	s5,24(sp)
    80001782:	6b42                	ld	s6,16(sp)
    80001784:	6ba2                	ld	s7,8(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret
  return 0;
    8000178a:	4501                	li	a0,0
}
    8000178c:	8082                	ret

000000008000178e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000178e:	1141                	addi	sp,sp,-16
    80001790:	e406                	sd	ra,8(sp)
    80001792:	e022                	sd	s0,0(sp)
    80001794:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001796:	4601                	li	a2,0
    80001798:	00000097          	auipc	ra,0x0
    8000179c:	94a080e7          	jalr	-1718(ra) # 800010e2 <walk>
  if(pte == 0)
    800017a0:	c901                	beqz	a0,800017b0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017a2:	611c                	ld	a5,0(a0)
    800017a4:	9bbd                	andi	a5,a5,-17
    800017a6:	e11c                	sd	a5,0(a0)
}
    800017a8:	60a2                	ld	ra,8(sp)
    800017aa:	6402                	ld	s0,0(sp)
    800017ac:	0141                	addi	sp,sp,16
    800017ae:	8082                	ret
    panic("uvmclear");
    800017b0:	00007517          	auipc	a0,0x7
    800017b4:	a2050513          	addi	a0,a0,-1504 # 800081d0 <digits+0x1b8>
    800017b8:	fffff097          	auipc	ra,0xfffff
    800017bc:	e5a080e7          	jalr	-422(ra) # 80000612 <panic>

00000000800017c0 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017c0:	c6bd                	beqz	a3,8000182e <copyout+0x6e>
{
    800017c2:	715d                	addi	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	e062                	sd	s8,0(sp)
    800017d8:	0880                	addi	s0,sp,80
    800017da:	8baa                	mv	s7,a0
    800017dc:	8a2e                	mv	s4,a1
    800017de:	8ab2                	mv	s5,a2
    800017e0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800017e2:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800017e4:	6b05                	lui	s6,0x1
    800017e6:	a015                	j	8000180a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800017e8:	9552                	add	a0,a0,s4
    800017ea:	0004861b          	sext.w	a2,s1
    800017ee:	85d6                	mv	a1,s5
    800017f0:	41250533          	sub	a0,a0,s2
    800017f4:	fffff097          	auipc	ra,0xfffff
    800017f8:	64a080e7          	jalr	1610(ra) # 80000e3e <memmove>

    len -= n;
    800017fc:	409989b3          	sub	s3,s3,s1
    src += n;
    80001800:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    80001802:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001806:	02098263          	beqz	s3,8000182a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000180a:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    8000180e:	85ca                	mv	a1,s2
    80001810:	855e                	mv	a0,s7
    80001812:	00000097          	auipc	ra,0x0
    80001816:	976080e7          	jalr	-1674(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    8000181a:	cd01                	beqz	a0,80001832 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000181c:	414904b3          	sub	s1,s2,s4
    80001820:	94da                	add	s1,s1,s6
    if(n > len)
    80001822:	fc99f3e3          	bleu	s1,s3,800017e8 <copyout+0x28>
    80001826:	84ce                	mv	s1,s3
    80001828:	b7c1                	j	800017e8 <copyout+0x28>
  }
  return 0;
    8000182a:	4501                	li	a0,0
    8000182c:	a021                	j	80001834 <copyout+0x74>
    8000182e:	4501                	li	a0,0
}
    80001830:	8082                	ret
      return -1;
    80001832:	557d                	li	a0,-1
}
    80001834:	60a6                	ld	ra,72(sp)
    80001836:	6406                	ld	s0,64(sp)
    80001838:	74e2                	ld	s1,56(sp)
    8000183a:	7942                	ld	s2,48(sp)
    8000183c:	79a2                	ld	s3,40(sp)
    8000183e:	7a02                	ld	s4,32(sp)
    80001840:	6ae2                	ld	s5,24(sp)
    80001842:	6b42                	ld	s6,16(sp)
    80001844:	6ba2                	ld	s7,8(sp)
    80001846:	6c02                	ld	s8,0(sp)
    80001848:	6161                	addi	sp,sp,80
    8000184a:	8082                	ret

000000008000184c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000184c:	caa5                	beqz	a3,800018bc <copyin+0x70>
{
    8000184e:	715d                	addi	sp,sp,-80
    80001850:	e486                	sd	ra,72(sp)
    80001852:	e0a2                	sd	s0,64(sp)
    80001854:	fc26                	sd	s1,56(sp)
    80001856:	f84a                	sd	s2,48(sp)
    80001858:	f44e                	sd	s3,40(sp)
    8000185a:	f052                	sd	s4,32(sp)
    8000185c:	ec56                	sd	s5,24(sp)
    8000185e:	e85a                	sd	s6,16(sp)
    80001860:	e45e                	sd	s7,8(sp)
    80001862:	e062                	sd	s8,0(sp)
    80001864:	0880                	addi	s0,sp,80
    80001866:	8baa                	mv	s7,a0
    80001868:	8aae                	mv	s5,a1
    8000186a:	8a32                	mv	s4,a2
    8000186c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000186e:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001870:	6b05                	lui	s6,0x1
    80001872:	a01d                	j	80001898 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001874:	014505b3          	add	a1,a0,s4
    80001878:	0004861b          	sext.w	a2,s1
    8000187c:	412585b3          	sub	a1,a1,s2
    80001880:	8556                	mv	a0,s5
    80001882:	fffff097          	auipc	ra,0xfffff
    80001886:	5bc080e7          	jalr	1468(ra) # 80000e3e <memmove>

    len -= n;
    8000188a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000188e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001890:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80001894:	02098263          	beqz	s3,800018b8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001898:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    8000189c:	85ca                	mv	a1,s2
    8000189e:	855e                	mv	a0,s7
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8e8080e7          	jalr	-1816(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    800018a8:	cd01                	beqz	a0,800018c0 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018aa:	414904b3          	sub	s1,s2,s4
    800018ae:	94da                	add	s1,s1,s6
    if(n > len)
    800018b0:	fc99f2e3          	bleu	s1,s3,80001874 <copyin+0x28>
    800018b4:	84ce                	mv	s1,s3
    800018b6:	bf7d                	j	80001874 <copyin+0x28>
  }
  return 0;
    800018b8:	4501                	li	a0,0
    800018ba:	a021                	j	800018c2 <copyin+0x76>
    800018bc:	4501                	li	a0,0
}
    800018be:	8082                	ret
      return -1;
    800018c0:	557d                	li	a0,-1
}
    800018c2:	60a6                	ld	ra,72(sp)
    800018c4:	6406                	ld	s0,64(sp)
    800018c6:	74e2                	ld	s1,56(sp)
    800018c8:	7942                	ld	s2,48(sp)
    800018ca:	79a2                	ld	s3,40(sp)
    800018cc:	7a02                	ld	s4,32(sp)
    800018ce:	6ae2                	ld	s5,24(sp)
    800018d0:	6b42                	ld	s6,16(sp)
    800018d2:	6ba2                	ld	s7,8(sp)
    800018d4:	6c02                	ld	s8,0(sp)
    800018d6:	6161                	addi	sp,sp,80
    800018d8:	8082                	ret

00000000800018da <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800018da:	ced5                	beqz	a3,80001996 <copyinstr+0xbc>
{
    800018dc:	715d                	addi	sp,sp,-80
    800018de:	e486                	sd	ra,72(sp)
    800018e0:	e0a2                	sd	s0,64(sp)
    800018e2:	fc26                	sd	s1,56(sp)
    800018e4:	f84a                	sd	s2,48(sp)
    800018e6:	f44e                	sd	s3,40(sp)
    800018e8:	f052                	sd	s4,32(sp)
    800018ea:	ec56                	sd	s5,24(sp)
    800018ec:	e85a                	sd	s6,16(sp)
    800018ee:	e45e                	sd	s7,8(sp)
    800018f0:	e062                	sd	s8,0(sp)
    800018f2:	0880                	addi	s0,sp,80
    800018f4:	8aaa                	mv	s5,a0
    800018f6:	84ae                	mv	s1,a1
    800018f8:	8c32                	mv	s8,a2
    800018fa:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    800018fc:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018fe:	6985                	lui	s3,0x1
    80001900:	4b05                	li	s6,1
    80001902:	a801                	j	80001912 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    80001904:	87a6                	mv	a5,s1
    80001906:	a085                	j	80001966 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    80001908:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    8000190a:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    8000190e:	080b8063          	beqz	s7,8000198e <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80001912:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80001916:	85ca                	mv	a1,s2
    80001918:	8556                	mv	a0,s5
    8000191a:	00000097          	auipc	ra,0x0
    8000191e:	86e080e7          	jalr	-1938(ra) # 80001188 <walkaddr>
    if(pa0 == 0)
    80001922:	c925                	beqz	a0,80001992 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    80001924:	41890633          	sub	a2,s2,s8
    80001928:	964e                	add	a2,a2,s3
    if(n > max)
    8000192a:	00cbf363          	bleu	a2,s7,80001930 <copyinstr+0x56>
    8000192e:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80001930:	9562                	add	a0,a0,s8
    80001932:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001936:	da71                	beqz	a2,8000190a <copyinstr+0x30>
      if(*p == '\0'){
    80001938:	00054703          	lbu	a4,0(a0)
    8000193c:	d761                	beqz	a4,80001904 <copyinstr+0x2a>
    8000193e:	9626                	add	a2,a2,s1
    80001940:	87a6                	mv	a5,s1
    80001942:	1bfd                	addi	s7,s7,-1
    80001944:	009b86b3          	add	a3,s7,s1
    80001948:	409b04b3          	sub	s1,s6,s1
    8000194c:	94aa                	add	s1,s1,a0
        *dst = *p;
    8000194e:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80001952:	40f68bb3          	sub	s7,a3,a5
      p++;
    80001956:	00f48733          	add	a4,s1,a5
      dst++;
    8000195a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000195c:	faf606e3          	beq	a2,a5,80001908 <copyinstr+0x2e>
      if(*p == '\0'){
    80001960:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8000>
    80001964:	f76d                	bnez	a4,8000194e <copyinstr+0x74>
        *dst = '\0';
    80001966:	00078023          	sb	zero,0(a5)
    8000196a:	4785                	li	a5,1
  }
  if(got_null){
    8000196c:	0017b513          	seqz	a0,a5
    80001970:	40a0053b          	negw	a0,a0
    80001974:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80001976:	60a6                	ld	ra,72(sp)
    80001978:	6406                	ld	s0,64(sp)
    8000197a:	74e2                	ld	s1,56(sp)
    8000197c:	7942                	ld	s2,48(sp)
    8000197e:	79a2                	ld	s3,40(sp)
    80001980:	7a02                	ld	s4,32(sp)
    80001982:	6ae2                	ld	s5,24(sp)
    80001984:	6b42                	ld	s6,16(sp)
    80001986:	6ba2                	ld	s7,8(sp)
    80001988:	6c02                	ld	s8,0(sp)
    8000198a:	6161                	addi	sp,sp,80
    8000198c:	8082                	ret
    8000198e:	4781                	li	a5,0
    80001990:	bff1                	j	8000196c <copyinstr+0x92>
      return -1;
    80001992:	557d                	li	a0,-1
    80001994:	b7cd                	j	80001976 <copyinstr+0x9c>
  int got_null = 0;
    80001996:	4781                	li	a5,0
  if(got_null){
    80001998:	0017b513          	seqz	a0,a5
    8000199c:	40a0053b          	negw	a0,a0
    800019a0:	2501                	sext.w	a0,a0
}
    800019a2:	8082                	ret

00000000800019a4 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800019a4:	1101                	addi	sp,sp,-32
    800019a6:	ec06                	sd	ra,24(sp)
    800019a8:	e822                	sd	s0,16(sp)
    800019aa:	e426                	sd	s1,8(sp)
    800019ac:	1000                	addi	s0,sp,32
    800019ae:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	2ac080e7          	jalr	684(ra) # 80000c5c <holding>
    800019b8:	c909                	beqz	a0,800019ca <wakeup1+0x26>
    panic("wakeup1");
  if (p->chan == p && p->state == SLEEPING)
    800019ba:	749c                	ld	a5,40(s1)
    800019bc:	00978f63          	beq	a5,s1,800019da <wakeup1+0x36>
  {
    p->state = RUNNABLE;
  }
}
    800019c0:	60e2                	ld	ra,24(sp)
    800019c2:	6442                	ld	s0,16(sp)
    800019c4:	64a2                	ld	s1,8(sp)
    800019c6:	6105                	addi	sp,sp,32
    800019c8:	8082                	ret
    panic("wakeup1");
    800019ca:	00007517          	auipc	a0,0x7
    800019ce:	83e50513          	addi	a0,a0,-1986 # 80008208 <states.1731+0x28>
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	c40080e7          	jalr	-960(ra) # 80000612 <panic>
  if (p->chan == p && p->state == SLEEPING)
    800019da:	4c98                	lw	a4,24(s1)
    800019dc:	4785                	li	a5,1
    800019de:	fef711e3          	bne	a4,a5,800019c0 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800019e2:	4789                	li	a5,2
    800019e4:	cc9c                	sw	a5,24(s1)
}
    800019e6:	bfe9                	j	800019c0 <wakeup1+0x1c>

00000000800019e8 <procinit>:
{
    800019e8:	715d                	addi	sp,sp,-80
    800019ea:	e486                	sd	ra,72(sp)
    800019ec:	e0a2                	sd	s0,64(sp)
    800019ee:	fc26                	sd	s1,56(sp)
    800019f0:	f84a                	sd	s2,48(sp)
    800019f2:	f44e                	sd	s3,40(sp)
    800019f4:	f052                	sd	s4,32(sp)
    800019f6:	ec56                	sd	s5,24(sp)
    800019f8:	e85a                	sd	s6,16(sp)
    800019fa:	e45e                	sd	s7,8(sp)
    800019fc:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800019fe:	00007597          	auipc	a1,0x7
    80001a02:	81258593          	addi	a1,a1,-2030 # 80008210 <states.1731+0x30>
    80001a06:	00010517          	auipc	a0,0x10
    80001a0a:	f4a50513          	addi	a0,a0,-182 # 80011950 <pid_lock>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	238080e7          	jalr	568(ra) # 80000c46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001a16:	00010917          	auipc	s2,0x10
    80001a1a:	35290913          	addi	s2,s2,850 # 80011d68 <proc>
    initlock(&p->lock, "proc");
    80001a1e:	00006b97          	auipc	s7,0x6
    80001a22:	7fab8b93          	addi	s7,s7,2042 # 80008218 <states.1731+0x38>
    uint64 va = KSTACK((int)(p - proc));
    80001a26:	8b4a                	mv	s6,s2
    80001a28:	00006a97          	auipc	s5,0x6
    80001a2c:	5d8a8a93          	addi	s5,s5,1496 # 80008000 <etext>
    80001a30:	040009b7          	lui	s3,0x4000
    80001a34:	19fd                	addi	s3,s3,-1
    80001a36:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001a38:	00016a17          	auipc	s4,0x16
    80001a3c:	330a0a13          	addi	s4,s4,816 # 80017d68 <tickslock>
    initlock(&p->lock, "proc");
    80001a40:	85de                	mv	a1,s7
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	202080e7          	jalr	514(ra) # 80000c46 <initlock>
    char *pa = kalloc();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	19a080e7          	jalr	410(ra) # 80000be6 <kalloc>
    80001a54:	85aa                	mv	a1,a0
    if (pa == 0)
    80001a56:	c929                	beqz	a0,80001aa8 <procinit+0xc0>
    uint64 va = KSTACK((int)(p - proc));
    80001a58:	416904b3          	sub	s1,s2,s6
    80001a5c:	849d                	srai	s1,s1,0x7
    80001a5e:	000ab783          	ld	a5,0(s5)
    80001a62:	02f484b3          	mul	s1,s1,a5
    80001a66:	2485                	addiw	s1,s1,1
    80001a68:	00d4949b          	slliw	s1,s1,0xd
    80001a6c:	409984b3          	sub	s1,s3,s1
    kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a70:	4699                	li	a3,6
    80001a72:	6605                	lui	a2,0x1
    80001a74:	8526                	mv	a0,s1
    80001a76:	00000097          	auipc	ra,0x0
    80001a7a:	842080e7          	jalr	-1982(ra) # 800012b8 <kvmmap>
    p->kstack = va;
    80001a7e:	04993023          	sd	s1,64(s2)
  for (p = proc; p < &proc[NPROC]; p++)
    80001a82:	18090913          	addi	s2,s2,384
    80001a86:	fb491de3          	bne	s2,s4,80001a40 <procinit+0x58>
  kvminithart();
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	632080e7          	jalr	1586(ra) # 800010bc <kvminithart>
}
    80001a92:	60a6                	ld	ra,72(sp)
    80001a94:	6406                	ld	s0,64(sp)
    80001a96:	74e2                	ld	s1,56(sp)
    80001a98:	7942                	ld	s2,48(sp)
    80001a9a:	79a2                	ld	s3,40(sp)
    80001a9c:	7a02                	ld	s4,32(sp)
    80001a9e:	6ae2                	ld	s5,24(sp)
    80001aa0:	6b42                	ld	s6,16(sp)
    80001aa2:	6ba2                	ld	s7,8(sp)
    80001aa4:	6161                	addi	sp,sp,80
    80001aa6:	8082                	ret
      panic("kalloc");
    80001aa8:	00006517          	auipc	a0,0x6
    80001aac:	77850513          	addi	a0,a0,1912 # 80008220 <states.1731+0x40>
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	b62080e7          	jalr	-1182(ra) # 80000612 <panic>

0000000080001ab8 <cpuid>:
{
    80001ab8:	1141                	addi	sp,sp,-16
    80001aba:	e422                	sd	s0,8(sp)
    80001abc:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp"
    80001abe:	8512                	mv	a0,tp
}
    80001ac0:	2501                	sext.w	a0,a0
    80001ac2:	6422                	ld	s0,8(sp)
    80001ac4:	0141                	addi	sp,sp,16
    80001ac6:	8082                	ret

0000000080001ac8 <mycpu>:
{
    80001ac8:	1141                	addi	sp,sp,-16
    80001aca:	e422                	sd	s0,8(sp)
    80001acc:	0800                	addi	s0,sp,16
    80001ace:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001ad0:	2781                	sext.w	a5,a5
    80001ad2:	079e                	slli	a5,a5,0x7
}
    80001ad4:	00010517          	auipc	a0,0x10
    80001ad8:	e9450513          	addi	a0,a0,-364 # 80011968 <cpus>
    80001adc:	953e                	add	a0,a0,a5
    80001ade:	6422                	ld	s0,8(sp)
    80001ae0:	0141                	addi	sp,sp,16
    80001ae2:	8082                	ret

0000000080001ae4 <myproc>:
{
    80001ae4:	1101                	addi	sp,sp,-32
    80001ae6:	ec06                	sd	ra,24(sp)
    80001ae8:	e822                	sd	s0,16(sp)
    80001aea:	e426                	sd	s1,8(sp)
    80001aec:	1000                	addi	s0,sp,32
  push_off();
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	19c080e7          	jalr	412(ra) # 80000c8a <push_off>
    80001af6:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001af8:	2781                	sext.w	a5,a5
    80001afa:	079e                	slli	a5,a5,0x7
    80001afc:	00010717          	auipc	a4,0x10
    80001b00:	e5470713          	addi	a4,a4,-428 # 80011950 <pid_lock>
    80001b04:	97ba                	add	a5,a5,a4
    80001b06:	6f84                	ld	s1,24(a5)
  pop_off();
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	222080e7          	jalr	546(ra) # 80000d2a <pop_off>
}
    80001b10:	8526                	mv	a0,s1
    80001b12:	60e2                	ld	ra,24(sp)
    80001b14:	6442                	ld	s0,16(sp)
    80001b16:	64a2                	ld	s1,8(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret

0000000080001b1c <forkret>:
{
    80001b1c:	1141                	addi	sp,sp,-16
    80001b1e:	e406                	sd	ra,8(sp)
    80001b20:	e022                	sd	s0,0(sp)
    80001b22:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	fc0080e7          	jalr	-64(ra) # 80001ae4 <myproc>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	25e080e7          	jalr	606(ra) # 80000d8a <release>
  if (first)
    80001b34:	00007797          	auipc	a5,0x7
    80001b38:	d0c78793          	addi	a5,a5,-756 # 80008840 <first.1691>
    80001b3c:	439c                	lw	a5,0(a5)
    80001b3e:	eb89                	bnez	a5,80001b50 <forkret+0x34>
  usertrapret();
    80001b40:	00001097          	auipc	ra,0x1
    80001b44:	c5a080e7          	jalr	-934(ra) # 8000279a <usertrapret>
}
    80001b48:	60a2                	ld	ra,8(sp)
    80001b4a:	6402                	ld	s0,0(sp)
    80001b4c:	0141                	addi	sp,sp,16
    80001b4e:	8082                	ret
    first = 0;
    80001b50:	00007797          	auipc	a5,0x7
    80001b54:	ce07a823          	sw	zero,-784(a5) # 80008840 <first.1691>
    fsinit(ROOTDEV);
    80001b58:	4505                	li	a0,1
    80001b5a:	00002097          	auipc	ra,0x2
    80001b5e:	a9a080e7          	jalr	-1382(ra) # 800035f4 <fsinit>
    80001b62:	bff9                	j	80001b40 <forkret+0x24>

0000000080001b64 <allocpid>:
{
    80001b64:	1101                	addi	sp,sp,-32
    80001b66:	ec06                	sd	ra,24(sp)
    80001b68:	e822                	sd	s0,16(sp)
    80001b6a:	e426                	sd	s1,8(sp)
    80001b6c:	e04a                	sd	s2,0(sp)
    80001b6e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b70:	00010917          	auipc	s2,0x10
    80001b74:	de090913          	addi	s2,s2,-544 # 80011950 <pid_lock>
    80001b78:	854a                	mv	a0,s2
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	15c080e7          	jalr	348(ra) # 80000cd6 <acquire>
  pid = nextpid;
    80001b82:	00007797          	auipc	a5,0x7
    80001b86:	cc278793          	addi	a5,a5,-830 # 80008844 <nextpid>
    80001b8a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b8c:	0014871b          	addiw	a4,s1,1
    80001b90:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b92:	854a                	mv	a0,s2
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	1f6080e7          	jalr	502(ra) # 80000d8a <release>
}
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6902                	ld	s2,0(sp)
    80001ba6:	6105                	addi	sp,sp,32
    80001ba8:	8082                	ret

0000000080001baa <proc_pagetable>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bb8:	00000097          	auipc	ra,0x0
    80001bbc:	8d2080e7          	jalr	-1838(ra) # 8000148a <uvmcreate>
    80001bc0:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001bc2:	c121                	beqz	a0,80001c02 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bc4:	4729                	li	a4,10
    80001bc6:	00005697          	auipc	a3,0x5
    80001bca:	43a68693          	addi	a3,a3,1082 # 80007000 <_trampoline>
    80001bce:	6605                	lui	a2,0x1
    80001bd0:	040005b7          	lui	a1,0x4000
    80001bd4:	15fd                	addi	a1,a1,-1
    80001bd6:	05b2                	slli	a1,a1,0xc
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	654080e7          	jalr	1620(ra) # 8000122c <mappages>
    80001be0:	02054863          	bltz	a0,80001c10 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001be4:	4719                	li	a4,6
    80001be6:	05893683          	ld	a3,88(s2)
    80001bea:	6605                	lui	a2,0x1
    80001bec:	020005b7          	lui	a1,0x2000
    80001bf0:	15fd                	addi	a1,a1,-1
    80001bf2:	05b6                	slli	a1,a1,0xd
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	636080e7          	jalr	1590(ra) # 8000122c <mappages>
    80001bfe:	02054163          	bltz	a0,80001c20 <proc_pagetable+0x76>
}
    80001c02:	8526                	mv	a0,s1
    80001c04:	60e2                	ld	ra,24(sp)
    80001c06:	6442                	ld	s0,16(sp)
    80001c08:	64a2                	ld	s1,8(sp)
    80001c0a:	6902                	ld	s2,0(sp)
    80001c0c:	6105                	addi	sp,sp,32
    80001c0e:	8082                	ret
    uvmfree(pagetable, 0);
    80001c10:	4581                	li	a1,0
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	a70080e7          	jalr	-1424(ra) # 80001684 <uvmfree>
    return 0;
    80001c1c:	4481                	li	s1,0
    80001c1e:	b7d5                	j	80001c02 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c20:	4681                	li	a3,0
    80001c22:	4605                	li	a2,1
    80001c24:	040005b7          	lui	a1,0x4000
    80001c28:	15fd                	addi	a1,a1,-1
    80001c2a:	05b2                	slli	a1,a1,0xc
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	796080e7          	jalr	1942(ra) # 800013c4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c36:	4581                	li	a1,0
    80001c38:	8526                	mv	a0,s1
    80001c3a:	00000097          	auipc	ra,0x0
    80001c3e:	a4a080e7          	jalr	-1462(ra) # 80001684 <uvmfree>
    return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	bf7d                	j	80001c02 <proc_pagetable+0x58>

0000000080001c46 <proc_freepagetable>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	84aa                	mv	s1,a0
    80001c54:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c56:	4681                	li	a3,0
    80001c58:	4605                	li	a2,1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	762080e7          	jalr	1890(ra) # 800013c4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c6a:	4681                	li	a3,0
    80001c6c:	4605                	li	a2,1
    80001c6e:	020005b7          	lui	a1,0x2000
    80001c72:	15fd                	addi	a1,a1,-1
    80001c74:	05b6                	slli	a1,a1,0xd
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	74c080e7          	jalr	1868(ra) # 800013c4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c80:	85ca                	mv	a1,s2
    80001c82:	8526                	mv	a0,s1
    80001c84:	00000097          	auipc	ra,0x0
    80001c88:	a00080e7          	jalr	-1536(ra) # 80001684 <uvmfree>
}
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret

0000000080001c98 <freeproc>:
{
    80001c98:	1101                	addi	sp,sp,-32
    80001c9a:	ec06                	sd	ra,24(sp)
    80001c9c:	e822                	sd	s0,16(sp)
    80001c9e:	e426                	sd	s1,8(sp)
    80001ca0:	1000                	addi	s0,sp,32
    80001ca2:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001ca4:	6d28                	ld	a0,88(a0)
    80001ca6:	c509                	beqz	a0,80001cb0 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	e3e080e7          	jalr	-450(ra) # 80000ae6 <kfree>
  if (p->trapframealarm)
    80001cb0:	1784b503          	ld	a0,376(s1)
    80001cb4:	c509                	beqz	a0,80001cbe <freeproc+0x26>
    kfree((void *)p->trapframealarm);
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	e30080e7          	jalr	-464(ra) # 80000ae6 <kfree>
  p->trapframe = 0;
    80001cbe:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001cc2:	68a8                	ld	a0,80(s1)
    80001cc4:	c511                	beqz	a0,80001cd0 <freeproc+0x38>
    proc_freepagetable(p->pagetable, p->sz);
    80001cc6:	64ac                	ld	a1,72(s1)
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	f7e080e7          	jalr	-130(ra) # 80001c46 <proc_freepagetable>
  p->pagetable = 0;
    80001cd0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cd4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cd8:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001cdc:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001ce0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ce4:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001ce8:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001cec:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001cf0:	0004ac23          	sw	zero,24(s1)
}
    80001cf4:	60e2                	ld	ra,24(sp)
    80001cf6:	6442                	ld	s0,16(sp)
    80001cf8:	64a2                	ld	s1,8(sp)
    80001cfa:	6105                	addi	sp,sp,32
    80001cfc:	8082                	ret

0000000080001cfe <allocproc>:
{
    80001cfe:	1101                	addi	sp,sp,-32
    80001d00:	ec06                	sd	ra,24(sp)
    80001d02:	e822                	sd	s0,16(sp)
    80001d04:	e426                	sd	s1,8(sp)
    80001d06:	e04a                	sd	s2,0(sp)
    80001d08:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001d0a:	00010497          	auipc	s1,0x10
    80001d0e:	05e48493          	addi	s1,s1,94 # 80011d68 <proc>
    80001d12:	00016917          	auipc	s2,0x16
    80001d16:	05690913          	addi	s2,s2,86 # 80017d68 <tickslock>
    acquire(&p->lock);
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	fba080e7          	jalr	-70(ra) # 80000cd6 <acquire>
    if (p->state == UNUSED)
    80001d24:	4c9c                	lw	a5,24(s1)
    80001d26:	cf81                	beqz	a5,80001d3e <allocproc+0x40>
      release(&p->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	060080e7          	jalr	96(ra) # 80000d8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001d32:	18048493          	addi	s1,s1,384
    80001d36:	ff2492e3          	bne	s1,s2,80001d1a <allocproc+0x1c>
  return 0;
    80001d3a:	4481                	li	s1,0
    80001d3c:	a0ad                	j	80001da6 <allocproc+0xa8>
  p->pid = allocpid();
    80001d3e:	00000097          	auipc	ra,0x0
    80001d42:	e26080e7          	jalr	-474(ra) # 80001b64 <allocpid>
    80001d46:	dc88                	sw	a0,56(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	e9e080e7          	jalr	-354(ra) # 80000be6 <kalloc>
    80001d50:	892a                	mv	s2,a0
    80001d52:	eca8                	sd	a0,88(s1)
    80001d54:	c125                	beqz	a0,80001db4 <allocproc+0xb6>
  if ((p->trapframealarm = (struct trapframe *)kalloc()) == 0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	e90080e7          	jalr	-368(ra) # 80000be6 <kalloc>
    80001d5e:	892a                	mv	s2,a0
    80001d60:	16a4bc23          	sd	a0,376(s1)
    80001d64:	cd39                	beqz	a0,80001dc2 <allocproc+0xc4>
  p->pagetable = proc_pagetable(p);
    80001d66:	8526                	mv	a0,s1
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	e42080e7          	jalr	-446(ra) # 80001baa <proc_pagetable>
    80001d70:	892a                	mv	s2,a0
    80001d72:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001d74:	cd31                	beqz	a0,80001dd0 <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80001d76:	07000613          	li	a2,112
    80001d7a:	4581                	li	a1,0
    80001d7c:	06048513          	addi	a0,s1,96
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	052080e7          	jalr	82(ra) # 80000dd2 <memset>
  p->context.ra = (uint64)forkret;
    80001d88:	00000797          	auipc	a5,0x0
    80001d8c:	d9478793          	addi	a5,a5,-620 # 80001b1c <forkret>
    80001d90:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d92:	60bc                	ld	a5,64(s1)
    80001d94:	6705                	lui	a4,0x1
    80001d96:	97ba                	add	a5,a5,a4
    80001d98:	f4bc                	sd	a5,104(s1)
  p->alarmnum = 0;
    80001d9a:	1604a823          	sw	zero,368(s1)
  p->handler = 0;
    80001d9e:	1604b423          	sd	zero,360(s1)
  p->clickcnt = 0;
    80001da2:	1604aa23          	sw	zero,372(s1)
}
    80001da6:	8526                	mv	a0,s1
    80001da8:	60e2                	ld	ra,24(sp)
    80001daa:	6442                	ld	s0,16(sp)
    80001dac:	64a2                	ld	s1,8(sp)
    80001dae:	6902                	ld	s2,0(sp)
    80001db0:	6105                	addi	sp,sp,32
    80001db2:	8082                	ret
    release(&p->lock);
    80001db4:	8526                	mv	a0,s1
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	fd4080e7          	jalr	-44(ra) # 80000d8a <release>
    return 0;
    80001dbe:	84ca                	mv	s1,s2
    80001dc0:	b7dd                	j	80001da6 <allocproc+0xa8>
    release(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	fc6080e7          	jalr	-58(ra) # 80000d8a <release>
    return 0;
    80001dcc:	84ca                	mv	s1,s2
    80001dce:	bfe1                	j	80001da6 <allocproc+0xa8>
    freeproc(p);
    80001dd0:	8526                	mv	a0,s1
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	ec6080e7          	jalr	-314(ra) # 80001c98 <freeproc>
    release(&p->lock);
    80001dda:	8526                	mv	a0,s1
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	fae080e7          	jalr	-82(ra) # 80000d8a <release>
    return 0;
    80001de4:	84ca                	mv	s1,s2
    80001de6:	b7c1                	j	80001da6 <allocproc+0xa8>

0000000080001de8 <userinit>:
{
    80001de8:	1101                	addi	sp,sp,-32
    80001dea:	ec06                	sd	ra,24(sp)
    80001dec:	e822                	sd	s0,16(sp)
    80001dee:	e426                	sd	s1,8(sp)
    80001df0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	f0c080e7          	jalr	-244(ra) # 80001cfe <allocproc>
    80001dfa:	84aa                	mv	s1,a0
  initproc = p;
    80001dfc:	00007797          	auipc	a5,0x7
    80001e00:	20a7be23          	sd	a0,540(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e04:	03400613          	li	a2,52
    80001e08:	00007597          	auipc	a1,0x7
    80001e0c:	a4858593          	addi	a1,a1,-1464 # 80008850 <initcode>
    80001e10:	6928                	ld	a0,80(a0)
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	6a6080e7          	jalr	1702(ra) # 800014b8 <uvminit>
  p->sz = PGSIZE;
    80001e1a:	6785                	lui	a5,0x1
    80001e1c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001e1e:	6cb8                	ld	a4,88(s1)
    80001e20:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001e24:	6cb8                	ld	a4,88(s1)
    80001e26:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e28:	4641                	li	a2,16
    80001e2a:	00006597          	auipc	a1,0x6
    80001e2e:	3fe58593          	addi	a1,a1,1022 # 80008228 <states.1731+0x48>
    80001e32:	15848513          	addi	a0,s1,344
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	114080e7          	jalr	276(ra) # 80000f4a <safestrcpy>
  p->cwd = namei("/");
    80001e3e:	00006517          	auipc	a0,0x6
    80001e42:	3fa50513          	addi	a0,a0,1018 # 80008238 <states.1731+0x58>
    80001e46:	00002097          	auipc	ra,0x2
    80001e4a:	1e2080e7          	jalr	482(ra) # 80004028 <namei>
    80001e4e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e52:	4789                	li	a5,2
    80001e54:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	f32080e7          	jalr	-206(ra) # 80000d8a <release>
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret

0000000080001e6a <growproc>:
{
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	e04a                	sd	s2,0(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	c6c080e7          	jalr	-916(ra) # 80001ae4 <myproc>
    80001e80:	892a                	mv	s2,a0
  sz = p->sz;
    80001e82:	652c                	ld	a1,72(a0)
    80001e84:	0005851b          	sext.w	a0,a1
  if (n > 0)
    80001e88:	00904f63          	bgtz	s1,80001ea6 <growproc+0x3c>
  else if (n < 0)
    80001e8c:	0204cd63          	bltz	s1,80001ec6 <growproc+0x5c>
  p->sz = sz;
    80001e90:	1502                	slli	a0,a0,0x20
    80001e92:	9101                	srli	a0,a0,0x20
    80001e94:	04a93423          	sd	a0,72(s2)
  return 0;
    80001e98:	4501                	li	a0,0
}
    80001e9a:	60e2                	ld	ra,24(sp)
    80001e9c:	6442                	ld	s0,16(sp)
    80001e9e:	64a2                	ld	s1,8(sp)
    80001ea0:	6902                	ld	s2,0(sp)
    80001ea2:	6105                	addi	sp,sp,32
    80001ea4:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001ea6:	00a4863b          	addw	a2,s1,a0
    80001eaa:	1602                	slli	a2,a2,0x20
    80001eac:	9201                	srli	a2,a2,0x20
    80001eae:	1582                	slli	a1,a1,0x20
    80001eb0:	9181                	srli	a1,a1,0x20
    80001eb2:	05093503          	ld	a0,80(s2)
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	6ba080e7          	jalr	1722(ra) # 80001570 <uvmalloc>
    80001ebe:	2501                	sext.w	a0,a0
    80001ec0:	f961                	bnez	a0,80001e90 <growproc+0x26>
      return -1;
    80001ec2:	557d                	li	a0,-1
    80001ec4:	bfd9                	j	80001e9a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ec6:	00a4863b          	addw	a2,s1,a0
    80001eca:	1602                	slli	a2,a2,0x20
    80001ecc:	9201                	srli	a2,a2,0x20
    80001ece:	1582                	slli	a1,a1,0x20
    80001ed0:	9181                	srli	a1,a1,0x20
    80001ed2:	05093503          	ld	a0,80(s2)
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	654080e7          	jalr	1620(ra) # 8000152a <uvmdealloc>
    80001ede:	2501                	sext.w	a0,a0
    80001ee0:	bf45                	j	80001e90 <growproc+0x26>

0000000080001ee2 <fork>:
{
    80001ee2:	7179                	addi	sp,sp,-48
    80001ee4:	f406                	sd	ra,40(sp)
    80001ee6:	f022                	sd	s0,32(sp)
    80001ee8:	ec26                	sd	s1,24(sp)
    80001eea:	e84a                	sd	s2,16(sp)
    80001eec:	e44e                	sd	s3,8(sp)
    80001eee:	e052                	sd	s4,0(sp)
    80001ef0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ef2:	00000097          	auipc	ra,0x0
    80001ef6:	bf2080e7          	jalr	-1038(ra) # 80001ae4 <myproc>
    80001efa:	892a                	mv	s2,a0
  if ((np = allocproc()) == 0)
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	e02080e7          	jalr	-510(ra) # 80001cfe <allocproc>
    80001f04:	c175                	beqz	a0,80001fe8 <fork+0x106>
    80001f06:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001f08:	04893603          	ld	a2,72(s2)
    80001f0c:	692c                	ld	a1,80(a0)
    80001f0e:	05093503          	ld	a0,80(s2)
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	7aa080e7          	jalr	1962(ra) # 800016bc <uvmcopy>
    80001f1a:	04054863          	bltz	a0,80001f6a <fork+0x88>
  np->sz = p->sz;
    80001f1e:	04893783          	ld	a5,72(s2)
    80001f22:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001f26:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001f2a:	05893683          	ld	a3,88(s2)
    80001f2e:	87b6                	mv	a5,a3
    80001f30:	0589b703          	ld	a4,88(s3)
    80001f34:	12068693          	addi	a3,a3,288
    80001f38:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f3c:	6788                	ld	a0,8(a5)
    80001f3e:	6b8c                	ld	a1,16(a5)
    80001f40:	6f90                	ld	a2,24(a5)
    80001f42:	01073023          	sd	a6,0(a4)
    80001f46:	e708                	sd	a0,8(a4)
    80001f48:	eb0c                	sd	a1,16(a4)
    80001f4a:	ef10                	sd	a2,24(a4)
    80001f4c:	02078793          	addi	a5,a5,32
    80001f50:	02070713          	addi	a4,a4,32
    80001f54:	fed792e3          	bne	a5,a3,80001f38 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f58:	0589b783          	ld	a5,88(s3)
    80001f5c:	0607b823          	sd	zero,112(a5)
    80001f60:	0d000493          	li	s1,208
  for (i = 0; i < NOFILE; i++)
    80001f64:	15000a13          	li	s4,336
    80001f68:	a03d                	j	80001f96 <fork+0xb4>
    freeproc(np);
    80001f6a:	854e                	mv	a0,s3
    80001f6c:	00000097          	auipc	ra,0x0
    80001f70:	d2c080e7          	jalr	-724(ra) # 80001c98 <freeproc>
    release(&np->lock);
    80001f74:	854e                	mv	a0,s3
    80001f76:	fffff097          	auipc	ra,0xfffff
    80001f7a:	e14080e7          	jalr	-492(ra) # 80000d8a <release>
    return -1;
    80001f7e:	54fd                	li	s1,-1
    80001f80:	a899                	j	80001fd6 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f82:	00002097          	auipc	ra,0x2
    80001f86:	764080e7          	jalr	1892(ra) # 800046e6 <filedup>
    80001f8a:	009987b3          	add	a5,s3,s1
    80001f8e:	e388                	sd	a0,0(a5)
  for (i = 0; i < NOFILE; i++)
    80001f90:	04a1                	addi	s1,s1,8
    80001f92:	01448763          	beq	s1,s4,80001fa0 <fork+0xbe>
    if (p->ofile[i])
    80001f96:	009907b3          	add	a5,s2,s1
    80001f9a:	6388                	ld	a0,0(a5)
    80001f9c:	f17d                	bnez	a0,80001f82 <fork+0xa0>
    80001f9e:	bfcd                	j	80001f90 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001fa0:	15093503          	ld	a0,336(s2)
    80001fa4:	00002097          	auipc	ra,0x2
    80001fa8:	88c080e7          	jalr	-1908(ra) # 80003830 <idup>
    80001fac:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fb0:	4641                	li	a2,16
    80001fb2:	15890593          	addi	a1,s2,344
    80001fb6:	15898513          	addi	a0,s3,344
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	f90080e7          	jalr	-112(ra) # 80000f4a <safestrcpy>
  pid = np->pid;
    80001fc2:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001fc6:	4789                	li	a5,2
    80001fc8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fcc:	854e                	mv	a0,s3
    80001fce:	fffff097          	auipc	ra,0xfffff
    80001fd2:	dbc080e7          	jalr	-580(ra) # 80000d8a <release>
}
    80001fd6:	8526                	mv	a0,s1
    80001fd8:	70a2                	ld	ra,40(sp)
    80001fda:	7402                	ld	s0,32(sp)
    80001fdc:	64e2                	ld	s1,24(sp)
    80001fde:	6942                	ld	s2,16(sp)
    80001fe0:	69a2                	ld	s3,8(sp)
    80001fe2:	6a02                	ld	s4,0(sp)
    80001fe4:	6145                	addi	sp,sp,48
    80001fe6:	8082                	ret
    return -1;
    80001fe8:	54fd                	li	s1,-1
    80001fea:	b7f5                	j	80001fd6 <fork+0xf4>

0000000080001fec <reparent>:
{
    80001fec:	7179                	addi	sp,sp,-48
    80001fee:	f406                	sd	ra,40(sp)
    80001ff0:	f022                	sd	s0,32(sp)
    80001ff2:	ec26                	sd	s1,24(sp)
    80001ff4:	e84a                	sd	s2,16(sp)
    80001ff6:	e44e                	sd	s3,8(sp)
    80001ff8:	e052                	sd	s4,0(sp)
    80001ffa:	1800                	addi	s0,sp,48
    80001ffc:	89aa                	mv	s3,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80001ffe:	00010497          	auipc	s1,0x10
    80002002:	d6a48493          	addi	s1,s1,-662 # 80011d68 <proc>
      pp->parent = initproc;
    80002006:	00007a17          	auipc	s4,0x7
    8000200a:	012a0a13          	addi	s4,s4,18 # 80009018 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000200e:	00016917          	auipc	s2,0x16
    80002012:	d5a90913          	addi	s2,s2,-678 # 80017d68 <tickslock>
    80002016:	a029                	j	80002020 <reparent+0x34>
    80002018:	18048493          	addi	s1,s1,384
    8000201c:	03248363          	beq	s1,s2,80002042 <reparent+0x56>
    if (pp->parent == p)
    80002020:	709c                	ld	a5,32(s1)
    80002022:	ff379be3          	bne	a5,s3,80002018 <reparent+0x2c>
      acquire(&pp->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	cae080e7          	jalr	-850(ra) # 80000cd6 <acquire>
      pp->parent = initproc;
    80002030:	000a3783          	ld	a5,0(s4)
    80002034:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80002036:	8526                	mv	a0,s1
    80002038:	fffff097          	auipc	ra,0xfffff
    8000203c:	d52080e7          	jalr	-686(ra) # 80000d8a <release>
    80002040:	bfe1                	j	80002018 <reparent+0x2c>
}
    80002042:	70a2                	ld	ra,40(sp)
    80002044:	7402                	ld	s0,32(sp)
    80002046:	64e2                	ld	s1,24(sp)
    80002048:	6942                	ld	s2,16(sp)
    8000204a:	69a2                	ld	s3,8(sp)
    8000204c:	6a02                	ld	s4,0(sp)
    8000204e:	6145                	addi	sp,sp,48
    80002050:	8082                	ret

0000000080002052 <scheduler>:
{
    80002052:	715d                	addi	sp,sp,-80
    80002054:	e486                	sd	ra,72(sp)
    80002056:	e0a2                	sd	s0,64(sp)
    80002058:	fc26                	sd	s1,56(sp)
    8000205a:	f84a                	sd	s2,48(sp)
    8000205c:	f44e                	sd	s3,40(sp)
    8000205e:	f052                	sd	s4,32(sp)
    80002060:	ec56                	sd	s5,24(sp)
    80002062:	e85a                	sd	s6,16(sp)
    80002064:	e45e                	sd	s7,8(sp)
    80002066:	e062                	sd	s8,0(sp)
    80002068:	0880                	addi	s0,sp,80
    8000206a:	8792                	mv	a5,tp
  int id = r_tp();
    8000206c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000206e:	00779b13          	slli	s6,a5,0x7
    80002072:	00010717          	auipc	a4,0x10
    80002076:	8de70713          	addi	a4,a4,-1826 # 80011950 <pid_lock>
    8000207a:	975a                	add	a4,a4,s6
    8000207c:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80002080:	00010717          	auipc	a4,0x10
    80002084:	8f070713          	addi	a4,a4,-1808 # 80011970 <cpus+0x8>
    80002088:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000208a:	4c0d                	li	s8,3
        c->proc = p;
    8000208c:	079e                	slli	a5,a5,0x7
    8000208e:	00010a17          	auipc	s4,0x10
    80002092:	8c2a0a13          	addi	s4,s4,-1854 # 80011950 <pid_lock>
    80002096:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002098:	00016997          	auipc	s3,0x16
    8000209c:	cd098993          	addi	s3,s3,-816 # 80017d68 <tickslock>
        found = 1;
    800020a0:	4b85                	li	s7,1
    800020a2:	a899                	j	800020f8 <scheduler+0xa6>
        p->state = RUNNING;
    800020a4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800020a8:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    800020ac:	06048593          	addi	a1,s1,96
    800020b0:	855a                	mv	a0,s6
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	63e080e7          	jalr	1598(ra) # 800026f0 <swtch>
        c->proc = 0;
    800020ba:	000a3c23          	sd	zero,24(s4)
        found = 1;
    800020be:	8ade                	mv	s5,s7
      release(&p->lock);
    800020c0:	8526                	mv	a0,s1
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	cc8080e7          	jalr	-824(ra) # 80000d8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800020ca:	18048493          	addi	s1,s1,384
    800020ce:	01348b63          	beq	s1,s3,800020e4 <scheduler+0x92>
      acquire(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	c02080e7          	jalr	-1022(ra) # 80000cd6 <acquire>
      if (p->state == RUNNABLE)
    800020dc:	4c9c                	lw	a5,24(s1)
    800020de:	ff2791e3          	bne	a5,s2,800020c0 <scheduler+0x6e>
    800020e2:	b7c9                	j	800020a4 <scheduler+0x52>
    if (found == 0)
    800020e4:	000a9a63          	bnez	s5,800020f8 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus"
    800020e8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    800020f0:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800020f4:	10500073          	wfi
  asm volatile("csrr %0, sstatus"
    800020f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020fc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002100:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002104:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++)
    80002106:	00010497          	auipc	s1,0x10
    8000210a:	c6248493          	addi	s1,s1,-926 # 80011d68 <proc>
      if (p->state == RUNNABLE)
    8000210e:	4909                	li	s2,2
    80002110:	b7c9                	j	800020d2 <scheduler+0x80>

0000000080002112 <sched>:
{
    80002112:	7179                	addi	sp,sp,-48
    80002114:	f406                	sd	ra,40(sp)
    80002116:	f022                	sd	s0,32(sp)
    80002118:	ec26                	sd	s1,24(sp)
    8000211a:	e84a                	sd	s2,16(sp)
    8000211c:	e44e                	sd	s3,8(sp)
    8000211e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002120:	00000097          	auipc	ra,0x0
    80002124:	9c4080e7          	jalr	-1596(ra) # 80001ae4 <myproc>
    80002128:	892a                	mv	s2,a0
  if (!holding(&p->lock))
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b32080e7          	jalr	-1230(ra) # 80000c5c <holding>
    80002132:	cd25                	beqz	a0,800021aa <sched+0x98>
  asm volatile("mv %0, tp"
    80002134:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002136:	2781                	sext.w	a5,a5
    80002138:	079e                	slli	a5,a5,0x7
    8000213a:	00010717          	auipc	a4,0x10
    8000213e:	81670713          	addi	a4,a4,-2026 # 80011950 <pid_lock>
    80002142:	97ba                	add	a5,a5,a4
    80002144:	0907a703          	lw	a4,144(a5)
    80002148:	4785                	li	a5,1
    8000214a:	06f71863          	bne	a4,a5,800021ba <sched+0xa8>
  if (p->state == RUNNING)
    8000214e:	01892703          	lw	a4,24(s2)
    80002152:	478d                	li	a5,3
    80002154:	06f70b63          	beq	a4,a5,800021ca <sched+0xb8>
  asm volatile("csrr %0, sstatus"
    80002158:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000215c:	8b89                	andi	a5,a5,2
  if (intr_get())
    8000215e:	efb5                	bnez	a5,800021da <sched+0xc8>
  asm volatile("mv %0, tp"
    80002160:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002162:	0000f497          	auipc	s1,0xf
    80002166:	7ee48493          	addi	s1,s1,2030 # 80011950 <pid_lock>
    8000216a:	2781                	sext.w	a5,a5
    8000216c:	079e                	slli	a5,a5,0x7
    8000216e:	97a6                	add	a5,a5,s1
    80002170:	0947a983          	lw	s3,148(a5)
    80002174:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002176:	2781                	sext.w	a5,a5
    80002178:	079e                	slli	a5,a5,0x7
    8000217a:	0000f597          	auipc	a1,0xf
    8000217e:	7f658593          	addi	a1,a1,2038 # 80011970 <cpus+0x8>
    80002182:	95be                	add	a1,a1,a5
    80002184:	06090513          	addi	a0,s2,96
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	568080e7          	jalr	1384(ra) # 800026f0 <swtch>
    80002190:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002192:	2781                	sext.w	a5,a5
    80002194:	079e                	slli	a5,a5,0x7
    80002196:	97a6                	add	a5,a5,s1
    80002198:	0937aa23          	sw	s3,148(a5)
}
    8000219c:	70a2                	ld	ra,40(sp)
    8000219e:	7402                	ld	s0,32(sp)
    800021a0:	64e2                	ld	s1,24(sp)
    800021a2:	6942                	ld	s2,16(sp)
    800021a4:	69a2                	ld	s3,8(sp)
    800021a6:	6145                	addi	sp,sp,48
    800021a8:	8082                	ret
    panic("sched p->lock");
    800021aa:	00006517          	auipc	a0,0x6
    800021ae:	09650513          	addi	a0,a0,150 # 80008240 <states.1731+0x60>
    800021b2:	ffffe097          	auipc	ra,0xffffe
    800021b6:	460080e7          	jalr	1120(ra) # 80000612 <panic>
    panic("sched locks");
    800021ba:	00006517          	auipc	a0,0x6
    800021be:	09650513          	addi	a0,a0,150 # 80008250 <states.1731+0x70>
    800021c2:	ffffe097          	auipc	ra,0xffffe
    800021c6:	450080e7          	jalr	1104(ra) # 80000612 <panic>
    panic("sched running");
    800021ca:	00006517          	auipc	a0,0x6
    800021ce:	09650513          	addi	a0,a0,150 # 80008260 <states.1731+0x80>
    800021d2:	ffffe097          	auipc	ra,0xffffe
    800021d6:	440080e7          	jalr	1088(ra) # 80000612 <panic>
    panic("sched interruptible");
    800021da:	00006517          	auipc	a0,0x6
    800021de:	09650513          	addi	a0,a0,150 # 80008270 <states.1731+0x90>
    800021e2:	ffffe097          	auipc	ra,0xffffe
    800021e6:	430080e7          	jalr	1072(ra) # 80000612 <panic>

00000000800021ea <exit>:
{
    800021ea:	7179                	addi	sp,sp,-48
    800021ec:	f406                	sd	ra,40(sp)
    800021ee:	f022                	sd	s0,32(sp)
    800021f0:	ec26                	sd	s1,24(sp)
    800021f2:	e84a                	sd	s2,16(sp)
    800021f4:	e44e                	sd	s3,8(sp)
    800021f6:	e052                	sd	s4,0(sp)
    800021f8:	1800                	addi	s0,sp,48
    800021fa:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	8e8080e7          	jalr	-1816(ra) # 80001ae4 <myproc>
    80002204:	89aa                	mv	s3,a0
  if (p == initproc)
    80002206:	00007797          	auipc	a5,0x7
    8000220a:	e1278793          	addi	a5,a5,-494 # 80009018 <initproc>
    8000220e:	639c                	ld	a5,0(a5)
    80002210:	0d050493          	addi	s1,a0,208
    80002214:	15050913          	addi	s2,a0,336
    80002218:	02a79363          	bne	a5,a0,8000223e <exit+0x54>
    panic("init exiting");
    8000221c:	00006517          	auipc	a0,0x6
    80002220:	06c50513          	addi	a0,a0,108 # 80008288 <states.1731+0xa8>
    80002224:	ffffe097          	auipc	ra,0xffffe
    80002228:	3ee080e7          	jalr	1006(ra) # 80000612 <panic>
      fileclose(f);
    8000222c:	00002097          	auipc	ra,0x2
    80002230:	50c080e7          	jalr	1292(ra) # 80004738 <fileclose>
      p->ofile[fd] = 0;
    80002234:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002238:	04a1                	addi	s1,s1,8
    8000223a:	01248563          	beq	s1,s2,80002244 <exit+0x5a>
    if (p->ofile[fd])
    8000223e:	6088                	ld	a0,0(s1)
    80002240:	f575                	bnez	a0,8000222c <exit+0x42>
    80002242:	bfdd                	j	80002238 <exit+0x4e>
  begin_op();
    80002244:	00002097          	auipc	ra,0x2
    80002248:	ff2080e7          	jalr	-14(ra) # 80004236 <begin_op>
  iput(p->cwd);
    8000224c:	1509b503          	ld	a0,336(s3)
    80002250:	00001097          	auipc	ra,0x1
    80002254:	7da080e7          	jalr	2010(ra) # 80003a2a <iput>
  end_op();
    80002258:	00002097          	auipc	ra,0x2
    8000225c:	05e080e7          	jalr	94(ra) # 800042b6 <end_op>
  p->cwd = 0;
    80002260:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002264:	00007497          	auipc	s1,0x7
    80002268:	db448493          	addi	s1,s1,-588 # 80009018 <initproc>
    8000226c:	6088                	ld	a0,0(s1)
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a68080e7          	jalr	-1432(ra) # 80000cd6 <acquire>
  wakeup1(initproc);
    80002276:	6088                	ld	a0,0(s1)
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	72c080e7          	jalr	1836(ra) # 800019a4 <wakeup1>
  release(&initproc->lock);
    80002280:	6088                	ld	a0,0(s1)
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	b08080e7          	jalr	-1272(ra) # 80000d8a <release>
  acquire(&p->lock);
    8000228a:	854e                	mv	a0,s3
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a4a080e7          	jalr	-1462(ra) # 80000cd6 <acquire>
  struct proc *original_parent = p->parent;
    80002294:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002298:	854e                	mv	a0,s3
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	af0080e7          	jalr	-1296(ra) # 80000d8a <release>
  acquire(&original_parent->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	a32080e7          	jalr	-1486(ra) # 80000cd6 <acquire>
  acquire(&p->lock);
    800022ac:	854e                	mv	a0,s3
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	a28080e7          	jalr	-1496(ra) # 80000cd6 <acquire>
  reparent(p);
    800022b6:	854e                	mv	a0,s3
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	d34080e7          	jalr	-716(ra) # 80001fec <reparent>
  wakeup1(original_parent);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	6e2080e7          	jalr	1762(ra) # 800019a4 <wakeup1>
  p->xstate = status;
    800022ca:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800022ce:	4791                	li	a5,4
    800022d0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	ab4080e7          	jalr	-1356(ra) # 80000d8a <release>
  sched();
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	e34080e7          	jalr	-460(ra) # 80002112 <sched>
  panic("zombie exit");
    800022e6:	00006517          	auipc	a0,0x6
    800022ea:	fb250513          	addi	a0,a0,-78 # 80008298 <states.1731+0xb8>
    800022ee:	ffffe097          	auipc	ra,0xffffe
    800022f2:	324080e7          	jalr	804(ra) # 80000612 <panic>

00000000800022f6 <yield>:
{
    800022f6:	1101                	addi	sp,sp,-32
    800022f8:	ec06                	sd	ra,24(sp)
    800022fa:	e822                	sd	s0,16(sp)
    800022fc:	e426                	sd	s1,8(sp)
    800022fe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	7e4080e7          	jalr	2020(ra) # 80001ae4 <myproc>
    80002308:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	9cc080e7          	jalr	-1588(ra) # 80000cd6 <acquire>
  p->state = RUNNABLE;
    80002312:	4789                	li	a5,2
    80002314:	cc9c                	sw	a5,24(s1)
  sched();
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	dfc080e7          	jalr	-516(ra) # 80002112 <sched>
  release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	a6a080e7          	jalr	-1430(ra) # 80000d8a <release>
}
    80002328:	60e2                	ld	ra,24(sp)
    8000232a:	6442                	ld	s0,16(sp)
    8000232c:	64a2                	ld	s1,8(sp)
    8000232e:	6105                	addi	sp,sp,32
    80002330:	8082                	ret

0000000080002332 <sleep>:
{
    80002332:	7179                	addi	sp,sp,-48
    80002334:	f406                	sd	ra,40(sp)
    80002336:	f022                	sd	s0,32(sp)
    80002338:	ec26                	sd	s1,24(sp)
    8000233a:	e84a                	sd	s2,16(sp)
    8000233c:	e44e                	sd	s3,8(sp)
    8000233e:	1800                	addi	s0,sp,48
    80002340:	89aa                	mv	s3,a0
    80002342:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	7a0080e7          	jalr	1952(ra) # 80001ae4 <myproc>
    8000234c:	84aa                	mv	s1,a0
  if (lk != &p->lock)
    8000234e:	05250663          	beq	a0,s2,8000239a <sleep+0x68>
    acquire(&p->lock); //DOC: sleeplock1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	984080e7          	jalr	-1660(ra) # 80000cd6 <acquire>
    release(lk);
    8000235a:	854a                	mv	a0,s2
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	a2e080e7          	jalr	-1490(ra) # 80000d8a <release>
  p->chan = chan;
    80002364:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002368:	4785                	li	a5,1
    8000236a:	cc9c                	sw	a5,24(s1)
  sched();
    8000236c:	00000097          	auipc	ra,0x0
    80002370:	da6080e7          	jalr	-602(ra) # 80002112 <sched>
  p->chan = 0;
    80002374:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	a10080e7          	jalr	-1520(ra) # 80000d8a <release>
    acquire(lk);
    80002382:	854a                	mv	a0,s2
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	952080e7          	jalr	-1710(ra) # 80000cd6 <acquire>
}
    8000238c:	70a2                	ld	ra,40(sp)
    8000238e:	7402                	ld	s0,32(sp)
    80002390:	64e2                	ld	s1,24(sp)
    80002392:	6942                	ld	s2,16(sp)
    80002394:	69a2                	ld	s3,8(sp)
    80002396:	6145                	addi	sp,sp,48
    80002398:	8082                	ret
  p->chan = chan;
    8000239a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000239e:	4785                	li	a5,1
    800023a0:	cd1c                	sw	a5,24(a0)
  sched();
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	d70080e7          	jalr	-656(ra) # 80002112 <sched>
  p->chan = 0;
    800023aa:	0204b423          	sd	zero,40(s1)
  if (lk != &p->lock)
    800023ae:	bff9                	j	8000238c <sleep+0x5a>

00000000800023b0 <wait>:
{
    800023b0:	715d                	addi	sp,sp,-80
    800023b2:	e486                	sd	ra,72(sp)
    800023b4:	e0a2                	sd	s0,64(sp)
    800023b6:	fc26                	sd	s1,56(sp)
    800023b8:	f84a                	sd	s2,48(sp)
    800023ba:	f44e                	sd	s3,40(sp)
    800023bc:	f052                	sd	s4,32(sp)
    800023be:	ec56                	sd	s5,24(sp)
    800023c0:	e85a                	sd	s6,16(sp)
    800023c2:	e45e                	sd	s7,8(sp)
    800023c4:	e062                	sd	s8,0(sp)
    800023c6:	0880                	addi	s0,sp,80
    800023c8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	71a080e7          	jalr	1818(ra) # 80001ae4 <myproc>
    800023d2:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023d4:	8c2a                	mv	s8,a0
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	900080e7          	jalr	-1792(ra) # 80000cd6 <acquire>
    havekids = 0;
    800023de:	4b01                	li	s6,0
        if (np->state == ZOMBIE)
    800023e0:	4a11                	li	s4,4
    for (np = proc; np < &proc[NPROC]; np++)
    800023e2:	00016997          	auipc	s3,0x16
    800023e6:	98698993          	addi	s3,s3,-1658 # 80017d68 <tickslock>
        havekids = 1;
    800023ea:	4a85                	li	s5,1
    havekids = 0;
    800023ec:	875a                	mv	a4,s6
    for (np = proc; np < &proc[NPROC]; np++)
    800023ee:	00010497          	auipc	s1,0x10
    800023f2:	97a48493          	addi	s1,s1,-1670 # 80011d68 <proc>
    800023f6:	a08d                	j	80002458 <wait+0xa8>
          pid = np->pid;
    800023f8:	0384a983          	lw	s3,56(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800023fc:	000b8e63          	beqz	s7,80002418 <wait+0x68>
    80002400:	4691                	li	a3,4
    80002402:	03448613          	addi	a2,s1,52
    80002406:	85de                	mv	a1,s7
    80002408:	05093503          	ld	a0,80(s2)
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	3b4080e7          	jalr	948(ra) # 800017c0 <copyout>
    80002414:	02054263          	bltz	a0,80002438 <wait+0x88>
          freeproc(np);
    80002418:	8526                	mv	a0,s1
    8000241a:	00000097          	auipc	ra,0x0
    8000241e:	87e080e7          	jalr	-1922(ra) # 80001c98 <freeproc>
          release(&np->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	966080e7          	jalr	-1690(ra) # 80000d8a <release>
          release(&p->lock);
    8000242c:	854a                	mv	a0,s2
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	95c080e7          	jalr	-1700(ra) # 80000d8a <release>
          return pid;
    80002436:	a8a9                	j	80002490 <wait+0xe0>
            release(&np->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	950080e7          	jalr	-1712(ra) # 80000d8a <release>
            release(&p->lock);
    80002442:	854a                	mv	a0,s2
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	946080e7          	jalr	-1722(ra) # 80000d8a <release>
            return -1;
    8000244c:	59fd                	li	s3,-1
    8000244e:	a089                	j	80002490 <wait+0xe0>
    for (np = proc; np < &proc[NPROC]; np++)
    80002450:	18048493          	addi	s1,s1,384
    80002454:	03348463          	beq	s1,s3,8000247c <wait+0xcc>
      if (np->parent == p)
    80002458:	709c                	ld	a5,32(s1)
    8000245a:	ff279be3          	bne	a5,s2,80002450 <wait+0xa0>
        acquire(&np->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	876080e7          	jalr	-1930(ra) # 80000cd6 <acquire>
        if (np->state == ZOMBIE)
    80002468:	4c9c                	lw	a5,24(s1)
    8000246a:	f94787e3          	beq	a5,s4,800023f8 <wait+0x48>
        release(&np->lock);
    8000246e:	8526                	mv	a0,s1
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	91a080e7          	jalr	-1766(ra) # 80000d8a <release>
        havekids = 1;
    80002478:	8756                	mv	a4,s5
    8000247a:	bfd9                	j	80002450 <wait+0xa0>
    if (!havekids || p->killed)
    8000247c:	c701                	beqz	a4,80002484 <wait+0xd4>
    8000247e:	03092783          	lw	a5,48(s2)
    80002482:	c785                	beqz	a5,800024aa <wait+0xfa>
      release(&p->lock);
    80002484:	854a                	mv	a0,s2
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	904080e7          	jalr	-1788(ra) # 80000d8a <release>
      return -1;
    8000248e:	59fd                	li	s3,-1
}
    80002490:	854e                	mv	a0,s3
    80002492:	60a6                	ld	ra,72(sp)
    80002494:	6406                	ld	s0,64(sp)
    80002496:	74e2                	ld	s1,56(sp)
    80002498:	7942                	ld	s2,48(sp)
    8000249a:	79a2                	ld	s3,40(sp)
    8000249c:	7a02                	ld	s4,32(sp)
    8000249e:	6ae2                	ld	s5,24(sp)
    800024a0:	6b42                	ld	s6,16(sp)
    800024a2:	6ba2                	ld	s7,8(sp)
    800024a4:	6c02                	ld	s8,0(sp)
    800024a6:	6161                	addi	sp,sp,80
    800024a8:	8082                	ret
    sleep(p, &p->lock); //DOC: wait-sleep
    800024aa:	85e2                	mv	a1,s8
    800024ac:	854a                	mv	a0,s2
    800024ae:	00000097          	auipc	ra,0x0
    800024b2:	e84080e7          	jalr	-380(ra) # 80002332 <sleep>
    havekids = 0;
    800024b6:	bf1d                	j	800023ec <wait+0x3c>

00000000800024b8 <wakeup>:
{
    800024b8:	7139                	addi	sp,sp,-64
    800024ba:	fc06                	sd	ra,56(sp)
    800024bc:	f822                	sd	s0,48(sp)
    800024be:	f426                	sd	s1,40(sp)
    800024c0:	f04a                	sd	s2,32(sp)
    800024c2:	ec4e                	sd	s3,24(sp)
    800024c4:	e852                	sd	s4,16(sp)
    800024c6:	e456                	sd	s5,8(sp)
    800024c8:	0080                	addi	s0,sp,64
    800024ca:	8a2a                	mv	s4,a0
  for (p = proc; p < &proc[NPROC]; p++)
    800024cc:	00010497          	auipc	s1,0x10
    800024d0:	89c48493          	addi	s1,s1,-1892 # 80011d68 <proc>
    if (p->state == SLEEPING && p->chan == chan)
    800024d4:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024d6:	4a89                	li	s5,2
  for (p = proc; p < &proc[NPROC]; p++)
    800024d8:	00016917          	auipc	s2,0x16
    800024dc:	89090913          	addi	s2,s2,-1904 # 80017d68 <tickslock>
    800024e0:	a821                	j	800024f8 <wakeup+0x40>
      p->state = RUNNABLE;
    800024e2:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	fffff097          	auipc	ra,0xfffff
    800024ec:	8a2080e7          	jalr	-1886(ra) # 80000d8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024f0:	18048493          	addi	s1,s1,384
    800024f4:	01248e63          	beq	s1,s2,80002510 <wakeup+0x58>
    acquire(&p->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	ffffe097          	auipc	ra,0xffffe
    800024fe:	7dc080e7          	jalr	2012(ra) # 80000cd6 <acquire>
    if (p->state == SLEEPING && p->chan == chan)
    80002502:	4c9c                	lw	a5,24(s1)
    80002504:	ff3791e3          	bne	a5,s3,800024e6 <wakeup+0x2e>
    80002508:	749c                	ld	a5,40(s1)
    8000250a:	fd479ee3          	bne	a5,s4,800024e6 <wakeup+0x2e>
    8000250e:	bfd1                	j	800024e2 <wakeup+0x2a>
}
    80002510:	70e2                	ld	ra,56(sp)
    80002512:	7442                	ld	s0,48(sp)
    80002514:	74a2                	ld	s1,40(sp)
    80002516:	7902                	ld	s2,32(sp)
    80002518:	69e2                	ld	s3,24(sp)
    8000251a:	6a42                	ld	s4,16(sp)
    8000251c:	6aa2                	ld	s5,8(sp)
    8000251e:	6121                	addi	sp,sp,64
    80002520:	8082                	ret

0000000080002522 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	1800                	addi	s0,sp,48
    80002530:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002532:	00010497          	auipc	s1,0x10
    80002536:	83648493          	addi	s1,s1,-1994 # 80011d68 <proc>
    8000253a:	00016997          	auipc	s3,0x16
    8000253e:	82e98993          	addi	s3,s3,-2002 # 80017d68 <tickslock>
  {
    acquire(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	792080e7          	jalr	1938(ra) # 80000cd6 <acquire>
    if (p->pid == pid)
    8000254c:	5c9c                	lw	a5,56(s1)
    8000254e:	01278d63          	beq	a5,s2,80002568 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	836080e7          	jalr	-1994(ra) # 80000d8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000255c:	18048493          	addi	s1,s1,384
    80002560:	ff3491e3          	bne	s1,s3,80002542 <kill+0x20>
  }
  return -1;
    80002564:	557d                	li	a0,-1
    80002566:	a829                	j	80002580 <kill+0x5e>
      p->killed = 1;
    80002568:	4785                	li	a5,1
    8000256a:	d89c                	sw	a5,48(s1)
      if (p->state == SLEEPING)
    8000256c:	4c98                	lw	a4,24(s1)
    8000256e:	4785                	li	a5,1
    80002570:	00f70f63          	beq	a4,a5,8000258e <kill+0x6c>
      release(&p->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	814080e7          	jalr	-2028(ra) # 80000d8a <release>
      return 0;
    8000257e:	4501                	li	a0,0
}
    80002580:	70a2                	ld	ra,40(sp)
    80002582:	7402                	ld	s0,32(sp)
    80002584:	64e2                	ld	s1,24(sp)
    80002586:	6942                	ld	s2,16(sp)
    80002588:	69a2                	ld	s3,8(sp)
    8000258a:	6145                	addi	sp,sp,48
    8000258c:	8082                	ret
        p->state = RUNNABLE;
    8000258e:	4789                	li	a5,2
    80002590:	cc9c                	sw	a5,24(s1)
    80002592:	b7cd                	j	80002574 <kill+0x52>

0000000080002594 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002594:	7179                	addi	sp,sp,-48
    80002596:	f406                	sd	ra,40(sp)
    80002598:	f022                	sd	s0,32(sp)
    8000259a:	ec26                	sd	s1,24(sp)
    8000259c:	e84a                	sd	s2,16(sp)
    8000259e:	e44e                	sd	s3,8(sp)
    800025a0:	e052                	sd	s4,0(sp)
    800025a2:	1800                	addi	s0,sp,48
    800025a4:	84aa                	mv	s1,a0
    800025a6:	892e                	mv	s2,a1
    800025a8:	89b2                	mv	s3,a2
    800025aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	538080e7          	jalr	1336(ra) # 80001ae4 <myproc>
  if (user_dst)
    800025b4:	c08d                	beqz	s1,800025d6 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025b6:	86d2                	mv	a3,s4
    800025b8:	864e                	mv	a2,s3
    800025ba:	85ca                	mv	a1,s2
    800025bc:	6928                	ld	a0,80(a0)
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	202080e7          	jalr	514(ra) # 800017c0 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6a02                	ld	s4,0(sp)
    800025d2:	6145                	addi	sp,sp,48
    800025d4:	8082                	ret
    memmove((char *)dst, src, len);
    800025d6:	000a061b          	sext.w	a2,s4
    800025da:	85ce                	mv	a1,s3
    800025dc:	854a                	mv	a0,s2
    800025de:	fffff097          	auipc	ra,0xfffff
    800025e2:	860080e7          	jalr	-1952(ra) # 80000e3e <memmove>
    return 0;
    800025e6:	8526                	mv	a0,s1
    800025e8:	bff9                	j	800025c6 <either_copyout+0x32>

00000000800025ea <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ea:	7179                	addi	sp,sp,-48
    800025ec:	f406                	sd	ra,40(sp)
    800025ee:	f022                	sd	s0,32(sp)
    800025f0:	ec26                	sd	s1,24(sp)
    800025f2:	e84a                	sd	s2,16(sp)
    800025f4:	e44e                	sd	s3,8(sp)
    800025f6:	e052                	sd	s4,0(sp)
    800025f8:	1800                	addi	s0,sp,48
    800025fa:	892a                	mv	s2,a0
    800025fc:	84ae                	mv	s1,a1
    800025fe:	89b2                	mv	s3,a2
    80002600:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	4e2080e7          	jalr	1250(ra) # 80001ae4 <myproc>
  if (user_src)
    8000260a:	c08d                	beqz	s1,8000262c <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000260c:	86d2                	mv	a3,s4
    8000260e:	864e                	mv	a2,s3
    80002610:	85ca                	mv	a1,s2
    80002612:	6928                	ld	a0,80(a0)
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	238080e7          	jalr	568(ra) # 8000184c <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000261c:	70a2                	ld	ra,40(sp)
    8000261e:	7402                	ld	s0,32(sp)
    80002620:	64e2                	ld	s1,24(sp)
    80002622:	6942                	ld	s2,16(sp)
    80002624:	69a2                	ld	s3,8(sp)
    80002626:	6a02                	ld	s4,0(sp)
    80002628:	6145                	addi	sp,sp,48
    8000262a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000262c:	000a061b          	sext.w	a2,s4
    80002630:	85ce                	mv	a1,s3
    80002632:	854a                	mv	a0,s2
    80002634:	fffff097          	auipc	ra,0xfffff
    80002638:	80a080e7          	jalr	-2038(ra) # 80000e3e <memmove>
    return 0;
    8000263c:	8526                	mv	a0,s1
    8000263e:	bff9                	j	8000261c <either_copyin+0x32>

0000000080002640 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002640:	715d                	addi	sp,sp,-80
    80002642:	e486                	sd	ra,72(sp)
    80002644:	e0a2                	sd	s0,64(sp)
    80002646:	fc26                	sd	s1,56(sp)
    80002648:	f84a                	sd	s2,48(sp)
    8000264a:	f44e                	sd	s3,40(sp)
    8000264c:	f052                	sd	s4,32(sp)
    8000264e:	ec56                	sd	s5,24(sp)
    80002650:	e85a                	sd	s6,16(sp)
    80002652:	e45e                	sd	s7,8(sp)
    80002654:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002656:	00006517          	auipc	a0,0x6
    8000265a:	a8a50513          	addi	a0,a0,-1398 # 800080e0 <digits+0xc8>
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	006080e7          	jalr	6(ra) # 80000664 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002666:	00010497          	auipc	s1,0x10
    8000266a:	85a48493          	addi	s1,s1,-1958 # 80011ec0 <proc+0x158>
    8000266e:	00016917          	auipc	s2,0x16
    80002672:	85290913          	addi	s2,s2,-1966 # 80017ec0 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002676:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002678:	00006997          	auipc	s3,0x6
    8000267c:	c3098993          	addi	s3,s3,-976 # 800082a8 <states.1731+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80002680:	00006a97          	auipc	s5,0x6
    80002684:	c30a8a93          	addi	s5,s5,-976 # 800082b0 <states.1731+0xd0>
    printf("\n");
    80002688:	00006a17          	auipc	s4,0x6
    8000268c:	a58a0a13          	addi	s4,s4,-1448 # 800080e0 <digits+0xc8>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002690:	00006b97          	auipc	s7,0x6
    80002694:	b50b8b93          	addi	s7,s7,-1200 # 800081e0 <states.1731>
    80002698:	a015                	j	800026bc <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    8000269a:	86ba                	mv	a3,a4
    8000269c:	ee072583          	lw	a1,-288(a4)
    800026a0:	8556                	mv	a0,s5
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	fc2080e7          	jalr	-62(ra) # 80000664 <printf>
    printf("\n");
    800026aa:	8552                	mv	a0,s4
    800026ac:	ffffe097          	auipc	ra,0xffffe
    800026b0:	fb8080e7          	jalr	-72(ra) # 80000664 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026b4:	18048493          	addi	s1,s1,384
    800026b8:	03248163          	beq	s1,s2,800026da <procdump+0x9a>
    if (p->state == UNUSED)
    800026bc:	8726                	mv	a4,s1
    800026be:	ec04a783          	lw	a5,-320(s1)
    800026c2:	dbed                	beqz	a5,800026b4 <procdump+0x74>
      state = "???";
    800026c4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c6:	fcfb6ae3          	bltu	s6,a5,8000269a <procdump+0x5a>
    800026ca:	1782                	slli	a5,a5,0x20
    800026cc:	9381                	srli	a5,a5,0x20
    800026ce:	078e                	slli	a5,a5,0x3
    800026d0:	97de                	add	a5,a5,s7
    800026d2:	6390                	ld	a2,0(a5)
    800026d4:	f279                	bnez	a2,8000269a <procdump+0x5a>
      state = "???";
    800026d6:	864e                	mv	a2,s3
    800026d8:	b7c9                	j	8000269a <procdump+0x5a>
  }
}
    800026da:	60a6                	ld	ra,72(sp)
    800026dc:	6406                	ld	s0,64(sp)
    800026de:	74e2                	ld	s1,56(sp)
    800026e0:	7942                	ld	s2,48(sp)
    800026e2:	79a2                	ld	s3,40(sp)
    800026e4:	7a02                	ld	s4,32(sp)
    800026e6:	6ae2                	ld	s5,24(sp)
    800026e8:	6b42                	ld	s6,16(sp)
    800026ea:	6ba2                	ld	s7,8(sp)
    800026ec:	6161                	addi	sp,sp,80
    800026ee:	8082                	ret

00000000800026f0 <swtch>:
    800026f0:	00153023          	sd	ra,0(a0)
    800026f4:	00253423          	sd	sp,8(a0)
    800026f8:	e900                	sd	s0,16(a0)
    800026fa:	ed04                	sd	s1,24(a0)
    800026fc:	03253023          	sd	s2,32(a0)
    80002700:	03353423          	sd	s3,40(a0)
    80002704:	03453823          	sd	s4,48(a0)
    80002708:	03553c23          	sd	s5,56(a0)
    8000270c:	05653023          	sd	s6,64(a0)
    80002710:	05753423          	sd	s7,72(a0)
    80002714:	05853823          	sd	s8,80(a0)
    80002718:	05953c23          	sd	s9,88(a0)
    8000271c:	07a53023          	sd	s10,96(a0)
    80002720:	07b53423          	sd	s11,104(a0)
    80002724:	0005b083          	ld	ra,0(a1)
    80002728:	0085b103          	ld	sp,8(a1)
    8000272c:	6980                	ld	s0,16(a1)
    8000272e:	6d84                	ld	s1,24(a1)
    80002730:	0205b903          	ld	s2,32(a1)
    80002734:	0285b983          	ld	s3,40(a1)
    80002738:	0305ba03          	ld	s4,48(a1)
    8000273c:	0385ba83          	ld	s5,56(a1)
    80002740:	0405bb03          	ld	s6,64(a1)
    80002744:	0485bb83          	ld	s7,72(a1)
    80002748:	0505bc03          	ld	s8,80(a1)
    8000274c:	0585bc83          	ld	s9,88(a1)
    80002750:	0605bd03          	ld	s10,96(a1)
    80002754:	0685bd83          	ld	s11,104(a1)
    80002758:	8082                	ret

000000008000275a <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000275a:	1141                	addi	sp,sp,-16
    8000275c:	e406                	sd	ra,8(sp)
    8000275e:	e022                	sd	s0,0(sp)
    80002760:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002762:	00006597          	auipc	a1,0x6
    80002766:	b8658593          	addi	a1,a1,-1146 # 800082e8 <states.1731+0x108>
    8000276a:	00015517          	auipc	a0,0x15
    8000276e:	5fe50513          	addi	a0,a0,1534 # 80017d68 <tickslock>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	4d4080e7          	jalr	1236(ra) # 80000c46 <initlock>
}
    8000277a:	60a2                	ld	ra,8(sp)
    8000277c:	6402                	ld	s0,0(sp)
    8000277e:	0141                	addi	sp,sp,16
    80002780:	8082                	ret

0000000080002782 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002782:	1141                	addi	sp,sp,-16
    80002784:	e422                	sd	s0,8(sp)
    80002786:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0"
    80002788:	00003797          	auipc	a5,0x3
    8000278c:	66878793          	addi	a5,a5,1640 # 80005df0 <kernelvec>
    80002790:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002794:	6422                	ld	s0,8(sp)
    80002796:	0141                	addi	sp,sp,16
    80002798:	8082                	ret

000000008000279a <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000279a:	1141                	addi	sp,sp,-16
    8000279c:	e406                	sd	ra,8(sp)
    8000279e:	e022                	sd	s0,0(sp)
    800027a0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	342080e7          	jalr	834(ra) # 80001ae4 <myproc>
  asm volatile("csrr %0, sstatus"
    800027aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ae:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0"
    800027b0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027b4:	00005617          	auipc	a2,0x5
    800027b8:	84c60613          	addi	a2,a2,-1972 # 80007000 <_trampoline>
    800027bc:	00005697          	auipc	a3,0x5
    800027c0:	84468693          	addi	a3,a3,-1980 # 80007000 <_trampoline>
    800027c4:	8e91                	sub	a3,a3,a2
    800027c6:	040007b7          	lui	a5,0x4000
    800027ca:	17fd                	addi	a5,a5,-1
    800027cc:	07b2                	slli	a5,a5,0xc
    800027ce:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0"
    800027d0:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp"
    800027d6:	180026f3          	csrr	a3,satp
    800027da:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027dc:	6d38                	ld	a4,88(a0)
    800027de:	6134                	ld	a3,64(a0)
    800027e0:	6585                	lui	a1,0x1
    800027e2:	96ae                	add	a3,a3,a1
    800027e4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027e6:	6d38                	ld	a4,88(a0)
    800027e8:	00000697          	auipc	a3,0x0
    800027ec:	13868693          	addi	a3,a3,312 # 80002920 <usertrap>
    800027f0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800027f2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp"
    800027f4:	8692                	mv	a3,tp
    800027f6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus"
    800027f8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027fc:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002800:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0"
    80002804:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002808:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0"
    8000280a:	6f18                	ld	a4,24(a4)
    8000280c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002810:	692c                	ld	a1,80(a0)
    80002812:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002814:	00005717          	auipc	a4,0x5
    80002818:	87c70713          	addi	a4,a4,-1924 # 80007090 <userret>
    8000281c:	8f11                	sub	a4,a4,a2
    8000281e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    80002820:	577d                	li	a4,-1
    80002822:	177e                	slli	a4,a4,0x3f
    80002824:	8dd9                	or	a1,a1,a4
    80002826:	02000537          	lui	a0,0x2000
    8000282a:	157d                	addi	a0,a0,-1
    8000282c:	0536                	slli	a0,a0,0xd
    8000282e:	9782                	jalr	a5
}
    80002830:	60a2                	ld	ra,8(sp)
    80002832:	6402                	ld	s0,0(sp)
    80002834:	0141                	addi	sp,sp,16
    80002836:	8082                	ret

0000000080002838 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002838:	1101                	addi	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002842:	00015497          	auipc	s1,0x15
    80002846:	52648493          	addi	s1,s1,1318 # 80017d68 <tickslock>
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	48a080e7          	jalr	1162(ra) # 80000cd6 <acquire>
  ticks++;
    80002854:	00006517          	auipc	a0,0x6
    80002858:	7cc50513          	addi	a0,a0,1996 # 80009020 <ticks>
    8000285c:	411c                	lw	a5,0(a0)
    8000285e:	2785                	addiw	a5,a5,1
    80002860:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002862:	00000097          	auipc	ra,0x0
    80002866:	c56080e7          	jalr	-938(ra) # 800024b8 <wakeup>
  release(&tickslock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	51e080e7          	jalr	1310(ra) # 80000d8a <release>
}
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	64a2                	ld	s1,8(sp)
    8000287a:	6105                	addi	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	e426                	sd	s1,8(sp)
    80002886:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause"
    80002888:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    8000288c:	00074d63          	bltz	a4,800028a6 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002890:	57fd                	li	a5,-1
    80002892:	17fe                	slli	a5,a5,0x3f
    80002894:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002896:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002898:	06f70363          	beq	a4,a5,800028fe <devintr+0x80>
  }
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret
      (scause & 0xff) == 9)
    800028a6:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    800028aa:	46a5                	li	a3,9
    800028ac:	fed792e3          	bne	a5,a3,80002890 <devintr+0x12>
    int irq = plic_claim();
    800028b0:	00003097          	auipc	ra,0x3
    800028b4:	648080e7          	jalr	1608(ra) # 80005ef8 <plic_claim>
    800028b8:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800028ba:	47a9                	li	a5,10
    800028bc:	02f50763          	beq	a0,a5,800028ea <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    800028c0:	4785                	li	a5,1
    800028c2:	02f50963          	beq	a0,a5,800028f4 <devintr+0x76>
    return 1;
    800028c6:	4505                	li	a0,1
    else if (irq)
    800028c8:	d8f1                	beqz	s1,8000289c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ca:	85a6                	mv	a1,s1
    800028cc:	00006517          	auipc	a0,0x6
    800028d0:	a2450513          	addi	a0,a0,-1500 # 800082f0 <states.1731+0x110>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	d90080e7          	jalr	-624(ra) # 80000664 <printf>
      plic_complete(irq);
    800028dc:	8526                	mv	a0,s1
    800028de:	00003097          	auipc	ra,0x3
    800028e2:	63e080e7          	jalr	1598(ra) # 80005f1c <plic_complete>
    return 1;
    800028e6:	4505                	li	a0,1
    800028e8:	bf55                	j	8000289c <devintr+0x1e>
      uartintr();
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	1ac080e7          	jalr	428(ra) # 80000a96 <uartintr>
    800028f2:	b7ed                	j	800028dc <devintr+0x5e>
      virtio_disk_intr();
    800028f4:	00004097          	auipc	ra,0x4
    800028f8:	ad4080e7          	jalr	-1324(ra) # 800063c8 <virtio_disk_intr>
    800028fc:	b7c5                	j	800028dc <devintr+0x5e>
    if (cpuid() == 0)
    800028fe:	fffff097          	auipc	ra,0xfffff
    80002902:	1ba080e7          	jalr	442(ra) # 80001ab8 <cpuid>
    80002906:	c901                	beqz	a0,80002916 <devintr+0x98>
  asm volatile("csrr %0, sip"
    80002908:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000290c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0"
    8000290e:	14479073          	csrw	sip,a5
    return 2;
    80002912:	4509                	li	a0,2
    80002914:	b761                	j	8000289c <devintr+0x1e>
      clockintr();
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	f22080e7          	jalr	-222(ra) # 80002838 <clockintr>
    8000291e:	b7ed                	j	80002908 <devintr+0x8a>

0000000080002920 <usertrap>:
{
    80002920:	1101                	addi	sp,sp,-32
    80002922:	ec06                	sd	ra,24(sp)
    80002924:	e822                	sd	s0,16(sp)
    80002926:	e426                	sd	s1,8(sp)
    80002928:	e04a                	sd	s2,0(sp)
    8000292a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus"
    8000292c:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002930:	1007f793          	andi	a5,a5,256
    80002934:	e3ad                	bnez	a5,80002996 <usertrap+0x76>
  asm volatile("csrw stvec, %0"
    80002936:	00003797          	auipc	a5,0x3
    8000293a:	4ba78793          	addi	a5,a5,1210 # 80005df0 <kernelvec>
    8000293e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	1a2080e7          	jalr	418(ra) # 80001ae4 <myproc>
    8000294a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000294c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc"
    8000294e:	14102773          	csrr	a4,sepc
    80002952:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause"
    80002954:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002958:	47a1                	li	a5,8
    8000295a:	04f71c63          	bne	a4,a5,800029b2 <usertrap+0x92>
    if (p->killed)
    8000295e:	591c                	lw	a5,48(a0)
    80002960:	e3b9                	bnez	a5,800029a6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002962:	6cb8                	ld	a4,88(s1)
    80002964:	6f1c                	ld	a5,24(a4)
    80002966:	0791                	addi	a5,a5,4
    80002968:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus"
    8000296a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000296e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0"
    80002972:	10079073          	csrw	sstatus,a5
    syscall();
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	31e080e7          	jalr	798(ra) # 80002c94 <syscall>
  if (p->killed)
    8000297e:	589c                	lw	a5,48(s1)
    80002980:	efcd                	bnez	a5,80002a3a <usertrap+0x11a>
  usertrapret();
    80002982:	00000097          	auipc	ra,0x0
    80002986:	e18080e7          	jalr	-488(ra) # 8000279a <usertrapret>
}
    8000298a:	60e2                	ld	ra,24(sp)
    8000298c:	6442                	ld	s0,16(sp)
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	6902                	ld	s2,0(sp)
    80002992:	6105                	addi	sp,sp,32
    80002994:	8082                	ret
    panic("usertrap: not from user mode");
    80002996:	00006517          	auipc	a0,0x6
    8000299a:	97a50513          	addi	a0,a0,-1670 # 80008310 <states.1731+0x130>
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	c74080e7          	jalr	-908(ra) # 80000612 <panic>
      exit(-1);
    800029a6:	557d                	li	a0,-1
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	842080e7          	jalr	-1982(ra) # 800021ea <exit>
    800029b0:	bf4d                	j	80002962 <usertrap+0x42>
  else if ((which_dev = devintr()) != 0)
    800029b2:	00000097          	auipc	ra,0x0
    800029b6:	ecc080e7          	jalr	-308(ra) # 8000287e <devintr>
    800029ba:	892a                	mv	s2,a0
    800029bc:	c501                	beqz	a0,800029c4 <usertrap+0xa4>
  if (p->killed)
    800029be:	589c                	lw	a5,48(s1)
    800029c0:	c3a1                	beqz	a5,80002a00 <usertrap+0xe0>
    800029c2:	a815                	j	800029f6 <usertrap+0xd6>
  asm volatile("csrr %0, scause"
    800029c4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029c8:	5c90                	lw	a2,56(s1)
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	96650513          	addi	a0,a0,-1690 # 80008330 <states.1731+0x150>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	c92080e7          	jalr	-878(ra) # 80000664 <printf>
  asm volatile("csrr %0, sepc"
    800029da:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    800029de:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e2:	00006517          	auipc	a0,0x6
    800029e6:	97e50513          	addi	a0,a0,-1666 # 80008360 <states.1731+0x180>
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	c7a080e7          	jalr	-902(ra) # 80000664 <printf>
    p->killed = 1;
    800029f2:	4785                	li	a5,1
    800029f4:	d89c                	sw	a5,48(s1)
    exit(-1);
    800029f6:	557d                	li	a0,-1
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	7f2080e7          	jalr	2034(ra) # 800021ea <exit>
  if (which_dev == 2)
    80002a00:	4789                	li	a5,2
    80002a02:	f8f910e3          	bne	s2,a5,80002982 <usertrap+0x62>
    if (p->alarmnum != 0)
    80002a06:	1704a783          	lw	a5,368(s1)
    80002a0a:	cb95                	beqz	a5,80002a3e <usertrap+0x11e>
      ++(p->clickcnt);
    80002a0c:	1744a703          	lw	a4,372(s1)
    80002a10:	2705                	addiw	a4,a4,1
    80002a12:	0007069b          	sext.w	a3,a4
    80002a16:	16e4aa23          	sw	a4,372(s1)
      if (p->alarmnum == p->clickcnt)
    80002a1a:	02d79463          	bne	a5,a3,80002a42 <usertrap+0x122>
        memmove(p->trapframealarm, p->trapframe, sizeof(struct trapframe));
    80002a1e:	12000613          	li	a2,288
    80002a22:	6cac                	ld	a1,88(s1)
    80002a24:	1784b503          	ld	a0,376(s1)
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	416080e7          	jalr	1046(ra) # 80000e3e <memmove>
        p->trapframe->epc = p->handler;
    80002a30:	6cbc                	ld	a5,88(s1)
    80002a32:	1684b703          	ld	a4,360(s1)
    80002a36:	ef98                	sd	a4,24(a5)
    80002a38:	a029                	j	80002a42 <usertrap+0x122>
  int which_dev = 0;
    80002a3a:	4901                	li	s2,0
    80002a3c:	bf6d                	j	800029f6 <usertrap+0xd6>
      p->clickcnt = 0;
    80002a3e:	1604aa23          	sw	zero,372(s1)
    yield();
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	8b4080e7          	jalr	-1868(ra) # 800022f6 <yield>
    80002a4a:	bf25                	j	80002982 <usertrap+0x62>

0000000080002a4c <kerneltrap>:
{
    80002a4c:	7179                	addi	sp,sp,-48
    80002a4e:	f406                	sd	ra,40(sp)
    80002a50:	f022                	sd	s0,32(sp)
    80002a52:	ec26                	sd	s1,24(sp)
    80002a54:	e84a                	sd	s2,16(sp)
    80002a56:	e44e                	sd	s3,8(sp)
    80002a58:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc"
    80002a5a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus"
    80002a5e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause"
    80002a62:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002a66:	1004f793          	andi	a5,s1,256
    80002a6a:	cb85                	beqz	a5,80002a9a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus"
    80002a6c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a70:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002a72:	ef85                	bnez	a5,80002aaa <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	e0a080e7          	jalr	-502(ra) # 8000287e <devintr>
    80002a7c:	cd1d                	beqz	a0,80002aba <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a7e:	4789                	li	a5,2
    80002a80:	06f50a63          	beq	a0,a5,80002af4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0"
    80002a84:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0"
    80002a88:	10049073          	csrw	sstatus,s1
}
    80002a8c:	70a2                	ld	ra,40(sp)
    80002a8e:	7402                	ld	s0,32(sp)
    80002a90:	64e2                	ld	s1,24(sp)
    80002a92:	6942                	ld	s2,16(sp)
    80002a94:	69a2                	ld	s3,8(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	8e650513          	addi	a0,a0,-1818 # 80008380 <states.1731+0x1a0>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	b70080e7          	jalr	-1168(ra) # 80000612 <panic>
    panic("kerneltrap: interrupts enabled");
    80002aaa:	00006517          	auipc	a0,0x6
    80002aae:	8fe50513          	addi	a0,a0,-1794 # 800083a8 <states.1731+0x1c8>
    80002ab2:	ffffe097          	auipc	ra,0xffffe
    80002ab6:	b60080e7          	jalr	-1184(ra) # 80000612 <panic>
    printf("scause %p\n", scause);
    80002aba:	85ce                	mv	a1,s3
    80002abc:	00006517          	auipc	a0,0x6
    80002ac0:	90c50513          	addi	a0,a0,-1780 # 800083c8 <states.1731+0x1e8>
    80002ac4:	ffffe097          	auipc	ra,0xffffe
    80002ac8:	ba0080e7          	jalr	-1120(ra) # 80000664 <printf>
  asm volatile("csrr %0, sepc"
    80002acc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval"
    80002ad0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad4:	00006517          	auipc	a0,0x6
    80002ad8:	90450513          	addi	a0,a0,-1788 # 800083d8 <states.1731+0x1f8>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	b88080e7          	jalr	-1144(ra) # 80000664 <printf>
    panic("kerneltrap");
    80002ae4:	00006517          	auipc	a0,0x6
    80002ae8:	90c50513          	addi	a0,a0,-1780 # 800083f0 <states.1731+0x210>
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	b26080e7          	jalr	-1242(ra) # 80000612 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	ff0080e7          	jalr	-16(ra) # 80001ae4 <myproc>
    80002afc:	d541                	beqz	a0,80002a84 <kerneltrap+0x38>
    80002afe:	fffff097          	auipc	ra,0xfffff
    80002b02:	fe6080e7          	jalr	-26(ra) # 80001ae4 <myproc>
    80002b06:	4d18                	lw	a4,24(a0)
    80002b08:	478d                	li	a5,3
    80002b0a:	f6f71de3          	bne	a4,a5,80002a84 <kerneltrap+0x38>
    yield();
    80002b0e:	fffff097          	auipc	ra,0xfffff
    80002b12:	7e8080e7          	jalr	2024(ra) # 800022f6 <yield>
    80002b16:	b7bd                	j	80002a84 <kerneltrap+0x38>

0000000080002b18 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	e426                	sd	s1,8(sp)
    80002b20:	1000                	addi	s0,sp,32
    80002b22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	fc0080e7          	jalr	-64(ra) # 80001ae4 <myproc>
  switch (n)
    80002b2c:	4795                	li	a5,5
    80002b2e:	0497e363          	bltu	a5,s1,80002b74 <argraw+0x5c>
    80002b32:	1482                	slli	s1,s1,0x20
    80002b34:	9081                	srli	s1,s1,0x20
    80002b36:	048a                	slli	s1,s1,0x2
    80002b38:	00006717          	auipc	a4,0x6
    80002b3c:	8c870713          	addi	a4,a4,-1848 # 80008400 <states.1731+0x220>
    80002b40:	94ba                	add	s1,s1,a4
    80002b42:	409c                	lw	a5,0(s1)
    80002b44:	97ba                	add	a5,a5,a4
    80002b46:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002b48:	6d3c                	ld	a5,88(a0)
    80002b4a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b4c:	60e2                	ld	ra,24(sp)
    80002b4e:	6442                	ld	s0,16(sp)
    80002b50:	64a2                	ld	s1,8(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret
    return p->trapframe->a1;
    80002b56:	6d3c                	ld	a5,88(a0)
    80002b58:	7fa8                	ld	a0,120(a5)
    80002b5a:	bfcd                	j	80002b4c <argraw+0x34>
    return p->trapframe->a2;
    80002b5c:	6d3c                	ld	a5,88(a0)
    80002b5e:	63c8                	ld	a0,128(a5)
    80002b60:	b7f5                	j	80002b4c <argraw+0x34>
    return p->trapframe->a3;
    80002b62:	6d3c                	ld	a5,88(a0)
    80002b64:	67c8                	ld	a0,136(a5)
    80002b66:	b7dd                	j	80002b4c <argraw+0x34>
    return p->trapframe->a4;
    80002b68:	6d3c                	ld	a5,88(a0)
    80002b6a:	6bc8                	ld	a0,144(a5)
    80002b6c:	b7c5                	j	80002b4c <argraw+0x34>
    return p->trapframe->a5;
    80002b6e:	6d3c                	ld	a5,88(a0)
    80002b70:	6fc8                	ld	a0,152(a5)
    80002b72:	bfe9                	j	80002b4c <argraw+0x34>
  panic("argraw");
    80002b74:	00006517          	auipc	a0,0x6
    80002b78:	96450513          	addi	a0,a0,-1692 # 800084d8 <syscalls+0xc0>
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	a96080e7          	jalr	-1386(ra) # 80000612 <panic>

0000000080002b84 <fetchaddr>:
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	e426                	sd	s1,8(sp)
    80002b8c:	e04a                	sd	s2,0(sp)
    80002b8e:	1000                	addi	s0,sp,32
    80002b90:	84aa                	mv	s1,a0
    80002b92:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	f50080e7          	jalr	-176(ra) # 80001ae4 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz)
    80002b9c:	653c                	ld	a5,72(a0)
    80002b9e:	02f4f963          	bleu	a5,s1,80002bd0 <fetchaddr+0x4c>
    80002ba2:	00848713          	addi	a4,s1,8
    80002ba6:	02e7e763          	bltu	a5,a4,80002bd4 <fetchaddr+0x50>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002baa:	46a1                	li	a3,8
    80002bac:	8626                	mv	a2,s1
    80002bae:	85ca                	mv	a1,s2
    80002bb0:	6928                	ld	a0,80(a0)
    80002bb2:	fffff097          	auipc	ra,0xfffff
    80002bb6:	c9a080e7          	jalr	-870(ra) # 8000184c <copyin>
    80002bba:	00a03533          	snez	a0,a0
    80002bbe:	40a0053b          	negw	a0,a0
    80002bc2:	2501                	sext.w	a0,a0
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	64a2                	ld	s1,8(sp)
    80002bca:	6902                	ld	s2,0(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret
    return -1;
    80002bd0:	557d                	li	a0,-1
    80002bd2:	bfcd                	j	80002bc4 <fetchaddr+0x40>
    80002bd4:	557d                	li	a0,-1
    80002bd6:	b7fd                	j	80002bc4 <fetchaddr+0x40>

0000000080002bd8 <fetchstr>:
{
    80002bd8:	7179                	addi	sp,sp,-48
    80002bda:	f406                	sd	ra,40(sp)
    80002bdc:	f022                	sd	s0,32(sp)
    80002bde:	ec26                	sd	s1,24(sp)
    80002be0:	e84a                	sd	s2,16(sp)
    80002be2:	e44e                	sd	s3,8(sp)
    80002be4:	1800                	addi	s0,sp,48
    80002be6:	892a                	mv	s2,a0
    80002be8:	84ae                	mv	s1,a1
    80002bea:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	ef8080e7          	jalr	-264(ra) # 80001ae4 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bf4:	86ce                	mv	a3,s3
    80002bf6:	864a                	mv	a2,s2
    80002bf8:	85a6                	mv	a1,s1
    80002bfa:	6928                	ld	a0,80(a0)
    80002bfc:	fffff097          	auipc	ra,0xfffff
    80002c00:	cde080e7          	jalr	-802(ra) # 800018da <copyinstr>
  if (err < 0)
    80002c04:	00054763          	bltz	a0,80002c12 <fetchstr+0x3a>
  return strlen(buf);
    80002c08:	8526                	mv	a0,s1
    80002c0a:	ffffe097          	auipc	ra,0xffffe
    80002c0e:	372080e7          	jalr	882(ra) # 80000f7c <strlen>
}
    80002c12:	70a2                	ld	ra,40(sp)
    80002c14:	7402                	ld	s0,32(sp)
    80002c16:	64e2                	ld	s1,24(sp)
    80002c18:	6942                	ld	s2,16(sp)
    80002c1a:	69a2                	ld	s3,8(sp)
    80002c1c:	6145                	addi	sp,sp,48
    80002c1e:	8082                	ret

0000000080002c20 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
    80002c20:	1101                	addi	sp,sp,-32
    80002c22:	ec06                	sd	ra,24(sp)
    80002c24:	e822                	sd	s0,16(sp)
    80002c26:	e426                	sd	s1,8(sp)
    80002c28:	1000                	addi	s0,sp,32
    80002c2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c2c:	00000097          	auipc	ra,0x0
    80002c30:	eec080e7          	jalr	-276(ra) # 80002b18 <argraw>
    80002c34:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c36:	4501                	li	a0,0
    80002c38:	60e2                	ld	ra,24(sp)
    80002c3a:	6442                	ld	s0,16(sp)
    80002c3c:	64a2                	ld	s1,8(sp)
    80002c3e:	6105                	addi	sp,sp,32
    80002c40:	8082                	ret

0000000080002c42 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int argaddr(int n, uint64 *ip)
{
    80002c42:	1101                	addi	sp,sp,-32
    80002c44:	ec06                	sd	ra,24(sp)
    80002c46:	e822                	sd	s0,16(sp)
    80002c48:	e426                	sd	s1,8(sp)
    80002c4a:	1000                	addi	s0,sp,32
    80002c4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	eca080e7          	jalr	-310(ra) # 80002b18 <argraw>
    80002c56:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c58:	4501                	li	a0,0
    80002c5a:	60e2                	ld	ra,24(sp)
    80002c5c:	6442                	ld	s0,16(sp)
    80002c5e:	64a2                	ld	s1,8(sp)
    80002c60:	6105                	addi	sp,sp,32
    80002c62:	8082                	ret

0000000080002c64 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002c64:	1101                	addi	sp,sp,-32
    80002c66:	ec06                	sd	ra,24(sp)
    80002c68:	e822                	sd	s0,16(sp)
    80002c6a:	e426                	sd	s1,8(sp)
    80002c6c:	e04a                	sd	s2,0(sp)
    80002c6e:	1000                	addi	s0,sp,32
    80002c70:	84ae                	mv	s1,a1
    80002c72:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c74:	00000097          	auipc	ra,0x0
    80002c78:	ea4080e7          	jalr	-348(ra) # 80002b18 <argraw>
  uint64 addr;
  if (argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c7c:	864a                	mv	a2,s2
    80002c7e:	85a6                	mv	a1,s1
    80002c80:	00000097          	auipc	ra,0x0
    80002c84:	f58080e7          	jalr	-168(ra) # 80002bd8 <fetchstr>
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6902                	ld	s2,0(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <syscall>:
    [SYS_sigalarm] sys_sigalarm,
    [SYS_sigreturn] sys_sigreturn,
};

void syscall(void)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	e04a                	sd	s2,0(sp)
    80002c9e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	e44080e7          	jalr	-444(ra) # 80001ae4 <myproc>
    80002ca8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002caa:	05853903          	ld	s2,88(a0)
    80002cae:	0a893783          	ld	a5,168(s2)
    80002cb2:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002cb6:	37fd                	addiw	a5,a5,-1
    80002cb8:	4759                	li	a4,22
    80002cba:	00f76f63          	bltu	a4,a5,80002cd8 <syscall+0x44>
    80002cbe:	00369713          	slli	a4,a3,0x3
    80002cc2:	00005797          	auipc	a5,0x5
    80002cc6:	75678793          	addi	a5,a5,1878 # 80008418 <syscalls>
    80002cca:	97ba                	add	a5,a5,a4
    80002ccc:	639c                	ld	a5,0(a5)
    80002cce:	c789                	beqz	a5,80002cd8 <syscall+0x44>
  {
    p->trapframe->a0 = syscalls[num]();
    80002cd0:	9782                	jalr	a5
    80002cd2:	06a93823          	sd	a0,112(s2)
    80002cd6:	a839                	j	80002cf4 <syscall+0x60>
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002cd8:	15848613          	addi	a2,s1,344
    80002cdc:	5c8c                	lw	a1,56(s1)
    80002cde:	00006517          	auipc	a0,0x6
    80002ce2:	80250513          	addi	a0,a0,-2046 # 800084e0 <syscalls+0xc8>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	97e080e7          	jalr	-1666(ra) # 80000664 <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cee:	6cbc                	ld	a5,88(s1)
    80002cf0:	577d                	li	a4,-1
    80002cf2:	fbb8                	sd	a4,112(a5)
  }
}
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	64a2                	ld	s1,8(sp)
    80002cfa:	6902                	ld	s2,0(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d00:	1101                	addi	sp,sp,-32
    80002d02:	ec06                	sd	ra,24(sp)
    80002d04:	e822                	sd	s0,16(sp)
    80002d06:	1000                	addi	s0,sp,32
  int n;
  if (argint(0, &n) < 0)
    80002d08:	fec40593          	addi	a1,s0,-20
    80002d0c:	4501                	li	a0,0
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	f12080e7          	jalr	-238(ra) # 80002c20 <argint>
    return -1;
    80002d16:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002d18:	00054963          	bltz	a0,80002d2a <sys_exit+0x2a>
  exit(n);
    80002d1c:	fec42503          	lw	a0,-20(s0)
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	4ca080e7          	jalr	1226(ra) # 800021ea <exit>
  return 0; // not reached
    80002d28:	4781                	li	a5,0
}
    80002d2a:	853e                	mv	a0,a5
    80002d2c:	60e2                	ld	ra,24(sp)
    80002d2e:	6442                	ld	s0,16(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret

0000000080002d34 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d34:	1141                	addi	sp,sp,-16
    80002d36:	e406                	sd	ra,8(sp)
    80002d38:	e022                	sd	s0,0(sp)
    80002d3a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	da8080e7          	jalr	-600(ra) # 80001ae4 <myproc>
}
    80002d44:	5d08                	lw	a0,56(a0)
    80002d46:	60a2                	ld	ra,8(sp)
    80002d48:	6402                	ld	s0,0(sp)
    80002d4a:	0141                	addi	sp,sp,16
    80002d4c:	8082                	ret

0000000080002d4e <sys_fork>:

uint64
sys_fork(void)
{
    80002d4e:	1141                	addi	sp,sp,-16
    80002d50:	e406                	sd	ra,8(sp)
    80002d52:	e022                	sd	s0,0(sp)
    80002d54:	0800                	addi	s0,sp,16
  return fork();
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	18c080e7          	jalr	396(ra) # 80001ee2 <fork>
}
    80002d5e:	60a2                	ld	ra,8(sp)
    80002d60:	6402                	ld	s0,0(sp)
    80002d62:	0141                	addi	sp,sp,16
    80002d64:	8082                	ret

0000000080002d66 <sys_wait>:

uint64
sys_wait(void)
{
    80002d66:	1101                	addi	sp,sp,-32
    80002d68:	ec06                	sd	ra,24(sp)
    80002d6a:	e822                	sd	s0,16(sp)
    80002d6c:	1000                	addi	s0,sp,32
  uint64 p;
  if (argaddr(0, &p) < 0)
    80002d6e:	fe840593          	addi	a1,s0,-24
    80002d72:	4501                	li	a0,0
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	ece080e7          	jalr	-306(ra) # 80002c42 <argaddr>
    return -1;
    80002d7c:	57fd                	li	a5,-1
  if (argaddr(0, &p) < 0)
    80002d7e:	00054963          	bltz	a0,80002d90 <sys_wait+0x2a>
  return wait(p);
    80002d82:	fe843503          	ld	a0,-24(s0)
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	62a080e7          	jalr	1578(ra) # 800023b0 <wait>
    80002d8e:	87aa                	mv	a5,a0
}
    80002d90:	853e                	mv	a0,a5
    80002d92:	60e2                	ld	ra,24(sp)
    80002d94:	6442                	ld	s0,16(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d9a:	7179                	addi	sp,sp,-48
    80002d9c:	f406                	sd	ra,40(sp)
    80002d9e:	f022                	sd	s0,32(sp)
    80002da0:	ec26                	sd	s1,24(sp)
    80002da2:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if (argint(0, &n) < 0)
    80002da4:	fdc40593          	addi	a1,s0,-36
    80002da8:	4501                	li	a0,0
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	e76080e7          	jalr	-394(ra) # 80002c20 <argint>
    return -1;
    80002db2:	54fd                	li	s1,-1
  if (argint(0, &n) < 0)
    80002db4:	00054f63          	bltz	a0,80002dd2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	d2c080e7          	jalr	-724(ra) # 80001ae4 <myproc>
    80002dc0:	4524                	lw	s1,72(a0)
  if (growproc(n) < 0)
    80002dc2:	fdc42503          	lw	a0,-36(s0)
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	0a4080e7          	jalr	164(ra) # 80001e6a <growproc>
    80002dce:	00054863          	bltz	a0,80002dde <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002dd2:	8526                	mv	a0,s1
    80002dd4:	70a2                	ld	ra,40(sp)
    80002dd6:	7402                	ld	s0,32(sp)
    80002dd8:	64e2                	ld	s1,24(sp)
    80002dda:	6145                	addi	sp,sp,48
    80002ddc:	8082                	ret
    return -1;
    80002dde:	54fd                	li	s1,-1
    80002de0:	bfcd                	j	80002dd2 <sys_sbrk+0x38>

0000000080002de2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002de2:	7139                	addi	sp,sp,-64
    80002de4:	fc06                	sd	ra,56(sp)
    80002de6:	f822                	sd	s0,48(sp)
    80002de8:	f426                	sd	s1,40(sp)
    80002dea:	f04a                	sd	s2,32(sp)
    80002dec:	ec4e                	sd	s3,24(sp)
    80002dee:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if (argint(0, &n) < 0)
    80002df0:	fcc40593          	addi	a1,s0,-52
    80002df4:	4501                	li	a0,0
    80002df6:	00000097          	auipc	ra,0x0
    80002dfa:	e2a080e7          	jalr	-470(ra) # 80002c20 <argint>
    return -1;
    80002dfe:	57fd                	li	a5,-1
  if (argint(0, &n) < 0)
    80002e00:	06054b63          	bltz	a0,80002e76 <sys_sleep+0x94>
  acquire(&tickslock);
    80002e04:	00015517          	auipc	a0,0x15
    80002e08:	f6450513          	addi	a0,a0,-156 # 80017d68 <tickslock>
    80002e0c:	ffffe097          	auipc	ra,0xffffe
    80002e10:	eca080e7          	jalr	-310(ra) # 80000cd6 <acquire>
  ticks0 = ticks;
    80002e14:	00006797          	auipc	a5,0x6
    80002e18:	20c78793          	addi	a5,a5,524 # 80009020 <ticks>
    80002e1c:	0007a903          	lw	s2,0(a5)
  while (ticks - ticks0 < n)
    80002e20:	fcc42783          	lw	a5,-52(s0)
    80002e24:	cf85                	beqz	a5,80002e5c <sys_sleep+0x7a>
    if (myproc()->killed)
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e26:	00015997          	auipc	s3,0x15
    80002e2a:	f4298993          	addi	s3,s3,-190 # 80017d68 <tickslock>
    80002e2e:	00006497          	auipc	s1,0x6
    80002e32:	1f248493          	addi	s1,s1,498 # 80009020 <ticks>
    if (myproc()->killed)
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	cae080e7          	jalr	-850(ra) # 80001ae4 <myproc>
    80002e3e:	591c                	lw	a5,48(a0)
    80002e40:	e3b9                	bnez	a5,80002e86 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    80002e42:	85ce                	mv	a1,s3
    80002e44:	8526                	mv	a0,s1
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	4ec080e7          	jalr	1260(ra) # 80002332 <sleep>
  while (ticks - ticks0 < n)
    80002e4e:	409c                	lw	a5,0(s1)
    80002e50:	412787bb          	subw	a5,a5,s2
    80002e54:	fcc42703          	lw	a4,-52(s0)
    80002e58:	fce7efe3          	bltu	a5,a4,80002e36 <sys_sleep+0x54>
  }
  release(&tickslock);
    80002e5c:	00015517          	auipc	a0,0x15
    80002e60:	f0c50513          	addi	a0,a0,-244 # 80017d68 <tickslock>
    80002e64:	ffffe097          	auipc	ra,0xffffe
    80002e68:	f26080e7          	jalr	-218(ra) # 80000d8a <release>

  backtrace();
    80002e6c:	ffffd097          	auipc	ra,0xffffd
    80002e70:	73a080e7          	jalr	1850(ra) # 800005a6 <backtrace>

  return 0;
    80002e74:	4781                	li	a5,0
}
    80002e76:	853e                	mv	a0,a5
    80002e78:	70e2                	ld	ra,56(sp)
    80002e7a:	7442                	ld	s0,48(sp)
    80002e7c:	74a2                	ld	s1,40(sp)
    80002e7e:	7902                	ld	s2,32(sp)
    80002e80:	69e2                	ld	s3,24(sp)
    80002e82:	6121                	addi	sp,sp,64
    80002e84:	8082                	ret
      release(&tickslock);
    80002e86:	00015517          	auipc	a0,0x15
    80002e8a:	ee250513          	addi	a0,a0,-286 # 80017d68 <tickslock>
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	efc080e7          	jalr	-260(ra) # 80000d8a <release>
      return -1;
    80002e96:	57fd                	li	a5,-1
    80002e98:	bff9                	j	80002e76 <sys_sleep+0x94>

0000000080002e9a <sys_kill>:

uint64
sys_kill(void)
{
    80002e9a:	1101                	addi	sp,sp,-32
    80002e9c:	ec06                	sd	ra,24(sp)
    80002e9e:	e822                	sd	s0,16(sp)
    80002ea0:	1000                	addi	s0,sp,32
  int pid;

  if (argint(0, &pid) < 0)
    80002ea2:	fec40593          	addi	a1,s0,-20
    80002ea6:	4501                	li	a0,0
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	d78080e7          	jalr	-648(ra) # 80002c20 <argint>
    return -1;
    80002eb0:	57fd                	li	a5,-1
  if (argint(0, &pid) < 0)
    80002eb2:	00054963          	bltz	a0,80002ec4 <sys_kill+0x2a>
  return kill(pid);
    80002eb6:	fec42503          	lw	a0,-20(s0)
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	668080e7          	jalr	1640(ra) # 80002522 <kill>
    80002ec2:	87aa                	mv	a5,a0
}
    80002ec4:	853e                	mv	a0,a5
    80002ec6:	60e2                	ld	ra,24(sp)
    80002ec8:	6442                	ld	s0,16(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ece:	1101                	addi	sp,sp,-32
    80002ed0:	ec06                	sd	ra,24(sp)
    80002ed2:	e822                	sd	s0,16(sp)
    80002ed4:	e426                	sd	s1,8(sp)
    80002ed6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ed8:	00015517          	auipc	a0,0x15
    80002edc:	e9050513          	addi	a0,a0,-368 # 80017d68 <tickslock>
    80002ee0:	ffffe097          	auipc	ra,0xffffe
    80002ee4:	df6080e7          	jalr	-522(ra) # 80000cd6 <acquire>
  xticks = ticks;
    80002ee8:	00006797          	auipc	a5,0x6
    80002eec:	13878793          	addi	a5,a5,312 # 80009020 <ticks>
    80002ef0:	4384                	lw	s1,0(a5)
  release(&tickslock);
    80002ef2:	00015517          	auipc	a0,0x15
    80002ef6:	e7650513          	addi	a0,a0,-394 # 80017d68 <tickslock>
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	e90080e7          	jalr	-368(ra) # 80000d8a <release>
  return xticks;
}
    80002f02:	02049513          	slli	a0,s1,0x20
    80002f06:	9101                	srli	a0,a0,0x20
    80002f08:	60e2                	ld	ra,24(sp)
    80002f0a:	6442                	ld	s0,16(sp)
    80002f0c:	64a2                	ld	s1,8(sp)
    80002f0e:	6105                	addi	sp,sp,32
    80002f10:	8082                	ret

0000000080002f12 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80002f12:	1101                	addi	sp,sp,-32
    80002f14:	ec06                	sd	ra,24(sp)
    80002f16:	e822                	sd	s0,16(sp)
    80002f18:	e426                	sd	s1,8(sp)
    80002f1a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	bc8080e7          	jalr	-1080(ra) # 80001ae4 <myproc>
    80002f24:	84aa                	mv	s1,a0
  if (argint(0, &(p->alarmnum)) < 0)
    80002f26:	17050593          	addi	a1,a0,368
    80002f2a:	4501                	li	a0,0
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	cf4080e7          	jalr	-780(ra) # 80002c20 <argint>
  {
    return -1;
    80002f34:	57fd                	li	a5,-1
  if (argint(0, &(p->alarmnum)) < 0)
    80002f36:	00054e63          	bltz	a0,80002f52 <sys_sigalarm+0x40>
  }
  if (argaddr(1, &(p->handler)) < 0)
    80002f3a:	16848593          	addi	a1,s1,360
    80002f3e:	4505                	li	a0,1
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	d02080e7          	jalr	-766(ra) # 80002c42 <argaddr>
    80002f48:	00054b63          	bltz	a0,80002f5e <sys_sigalarm+0x4c>
  {
    return -1;
  }
  p->clickcnt = 0;
    80002f4c:	1604aa23          	sw	zero,372(s1)
  return 0;
    80002f50:	4781                	li	a5,0
}
    80002f52:	853e                	mv	a0,a5
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret
    return -1;
    80002f5e:	57fd                	li	a5,-1
    80002f60:	bfcd                	j	80002f52 <sys_sigalarm+0x40>

0000000080002f62 <sys_sigreturn>:

uint64
sys_sigreturn()
{
    80002f62:	1101                	addi	sp,sp,-32
    80002f64:	ec06                	sd	ra,24(sp)
    80002f66:	e822                	sd	s0,16(sp)
    80002f68:	e426                	sd	s1,8(sp)
    80002f6a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	b78080e7          	jalr	-1160(ra) # 80001ae4 <myproc>
    80002f74:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->trapframealarm, sizeof(struct trapframe));
    80002f76:	12000613          	li	a2,288
    80002f7a:	17853583          	ld	a1,376(a0)
    80002f7e:	6d28                	ld	a0,88(a0)
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	ebe080e7          	jalr	-322(ra) # 80000e3e <memmove>
  p->clickcnt = 0;
    80002f88:	1604aa23          	sw	zero,372(s1)
  return 0;
}
    80002f8c:	4501                	li	a0,0
    80002f8e:	60e2                	ld	ra,24(sp)
    80002f90:	6442                	ld	s0,16(sp)
    80002f92:	64a2                	ld	s1,8(sp)
    80002f94:	6105                	addi	sp,sp,32
    80002f96:	8082                	ret

0000000080002f98 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f98:	7179                	addi	sp,sp,-48
    80002f9a:	f406                	sd	ra,40(sp)
    80002f9c:	f022                	sd	s0,32(sp)
    80002f9e:	ec26                	sd	s1,24(sp)
    80002fa0:	e84a                	sd	s2,16(sp)
    80002fa2:	e44e                	sd	s3,8(sp)
    80002fa4:	e052                	sd	s4,0(sp)
    80002fa6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fa8:	00005597          	auipc	a1,0x5
    80002fac:	55858593          	addi	a1,a1,1368 # 80008500 <syscalls+0xe8>
    80002fb0:	00015517          	auipc	a0,0x15
    80002fb4:	dd050513          	addi	a0,a0,-560 # 80017d80 <bcache>
    80002fb8:	ffffe097          	auipc	ra,0xffffe
    80002fbc:	c8e080e7          	jalr	-882(ra) # 80000c46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fc0:	0001d797          	auipc	a5,0x1d
    80002fc4:	dc078793          	addi	a5,a5,-576 # 8001fd80 <bcache+0x8000>
    80002fc8:	0001d717          	auipc	a4,0x1d
    80002fcc:	02070713          	addi	a4,a4,32 # 8001ffe8 <bcache+0x8268>
    80002fd0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002fd4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fd8:	00015497          	auipc	s1,0x15
    80002fdc:	dc048493          	addi	s1,s1,-576 # 80017d98 <bcache+0x18>
    b->next = bcache.head.next;
    80002fe0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fe2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fe4:	00005a17          	auipc	s4,0x5
    80002fe8:	524a0a13          	addi	s4,s4,1316 # 80008508 <syscalls+0xf0>
    b->next = bcache.head.next;
    80002fec:	2b893783          	ld	a5,696(s2)
    80002ff0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ff2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ff6:	85d2                	mv	a1,s4
    80002ff8:	01048513          	addi	a0,s1,16
    80002ffc:	00001097          	auipc	ra,0x1
    80003000:	51a080e7          	jalr	1306(ra) # 80004516 <initsleeplock>
    bcache.head.next->prev = b;
    80003004:	2b893783          	ld	a5,696(s2)
    80003008:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000300a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000300e:	45848493          	addi	s1,s1,1112
    80003012:	fd349de3          	bne	s1,s3,80002fec <binit+0x54>
  }
}
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6942                	ld	s2,16(sp)
    8000301e:	69a2                	ld	s3,8(sp)
    80003020:	6a02                	ld	s4,0(sp)
    80003022:	6145                	addi	sp,sp,48
    80003024:	8082                	ret

0000000080003026 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003026:	7179                	addi	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	e84a                	sd	s2,16(sp)
    80003030:	e44e                	sd	s3,8(sp)
    80003032:	1800                	addi	s0,sp,48
    80003034:	89aa                	mv	s3,a0
    80003036:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003038:	00015517          	auipc	a0,0x15
    8000303c:	d4850513          	addi	a0,a0,-696 # 80017d80 <bcache>
    80003040:	ffffe097          	auipc	ra,0xffffe
    80003044:	c96080e7          	jalr	-874(ra) # 80000cd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003048:	0001d797          	auipc	a5,0x1d
    8000304c:	d3878793          	addi	a5,a5,-712 # 8001fd80 <bcache+0x8000>
    80003050:	2b87b483          	ld	s1,696(a5)
    80003054:	0001d797          	auipc	a5,0x1d
    80003058:	f9478793          	addi	a5,a5,-108 # 8001ffe8 <bcache+0x8268>
    8000305c:	02f48f63          	beq	s1,a5,8000309a <bread+0x74>
    80003060:	873e                	mv	a4,a5
    80003062:	a021                	j	8000306a <bread+0x44>
    80003064:	68a4                	ld	s1,80(s1)
    80003066:	02e48a63          	beq	s1,a4,8000309a <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    8000306a:	449c                	lw	a5,8(s1)
    8000306c:	ff379ce3          	bne	a5,s3,80003064 <bread+0x3e>
    80003070:	44dc                	lw	a5,12(s1)
    80003072:	ff2799e3          	bne	a5,s2,80003064 <bread+0x3e>
      b->refcnt++;
    80003076:	40bc                	lw	a5,64(s1)
    80003078:	2785                	addiw	a5,a5,1
    8000307a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000307c:	00015517          	auipc	a0,0x15
    80003080:	d0450513          	addi	a0,a0,-764 # 80017d80 <bcache>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	d06080e7          	jalr	-762(ra) # 80000d8a <release>
      acquiresleep(&b->lock);
    8000308c:	01048513          	addi	a0,s1,16
    80003090:	00001097          	auipc	ra,0x1
    80003094:	4c0080e7          	jalr	1216(ra) # 80004550 <acquiresleep>
      return b;
    80003098:	a8b1                	j	800030f4 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000309a:	0001d797          	auipc	a5,0x1d
    8000309e:	ce678793          	addi	a5,a5,-794 # 8001fd80 <bcache+0x8000>
    800030a2:	2b07b483          	ld	s1,688(a5)
    800030a6:	0001d797          	auipc	a5,0x1d
    800030aa:	f4278793          	addi	a5,a5,-190 # 8001ffe8 <bcache+0x8268>
    800030ae:	04f48d63          	beq	s1,a5,80003108 <bread+0xe2>
    if(b->refcnt == 0) {
    800030b2:	40bc                	lw	a5,64(s1)
    800030b4:	cb91                	beqz	a5,800030c8 <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030b6:	0001d717          	auipc	a4,0x1d
    800030ba:	f3270713          	addi	a4,a4,-206 # 8001ffe8 <bcache+0x8268>
    800030be:	64a4                	ld	s1,72(s1)
    800030c0:	04e48463          	beq	s1,a4,80003108 <bread+0xe2>
    if(b->refcnt == 0) {
    800030c4:	40bc                	lw	a5,64(s1)
    800030c6:	ffe5                	bnez	a5,800030be <bread+0x98>
      b->dev = dev;
    800030c8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030cc:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800030d0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030d4:	4785                	li	a5,1
    800030d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030d8:	00015517          	auipc	a0,0x15
    800030dc:	ca850513          	addi	a0,a0,-856 # 80017d80 <bcache>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	caa080e7          	jalr	-854(ra) # 80000d8a <release>
      acquiresleep(&b->lock);
    800030e8:	01048513          	addi	a0,s1,16
    800030ec:	00001097          	auipc	ra,0x1
    800030f0:	464080e7          	jalr	1124(ra) # 80004550 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030f4:	409c                	lw	a5,0(s1)
    800030f6:	c38d                	beqz	a5,80003118 <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030f8:	8526                	mv	a0,s1
    800030fa:	70a2                	ld	ra,40(sp)
    800030fc:	7402                	ld	s0,32(sp)
    800030fe:	64e2                	ld	s1,24(sp)
    80003100:	6942                	ld	s2,16(sp)
    80003102:	69a2                	ld	s3,8(sp)
    80003104:	6145                	addi	sp,sp,48
    80003106:	8082                	ret
  panic("bget: no buffers");
    80003108:	00005517          	auipc	a0,0x5
    8000310c:	40850513          	addi	a0,a0,1032 # 80008510 <syscalls+0xf8>
    80003110:	ffffd097          	auipc	ra,0xffffd
    80003114:	502080e7          	jalr	1282(ra) # 80000612 <panic>
    virtio_disk_rw(b, 0);
    80003118:	4581                	li	a1,0
    8000311a:	8526                	mv	a0,s1
    8000311c:	00003097          	auipc	ra,0x3
    80003120:	ff2080e7          	jalr	-14(ra) # 8000610e <virtio_disk_rw>
    b->valid = 1;
    80003124:	4785                	li	a5,1
    80003126:	c09c                	sw	a5,0(s1)
  return b;
    80003128:	bfc1                	j	800030f8 <bread+0xd2>

000000008000312a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000312a:	1101                	addi	sp,sp,-32
    8000312c:	ec06                	sd	ra,24(sp)
    8000312e:	e822                	sd	s0,16(sp)
    80003130:	e426                	sd	s1,8(sp)
    80003132:	1000                	addi	s0,sp,32
    80003134:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003136:	0541                	addi	a0,a0,16
    80003138:	00001097          	auipc	ra,0x1
    8000313c:	4b2080e7          	jalr	1202(ra) # 800045ea <holdingsleep>
    80003140:	cd01                	beqz	a0,80003158 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003142:	4585                	li	a1,1
    80003144:	8526                	mv	a0,s1
    80003146:	00003097          	auipc	ra,0x3
    8000314a:	fc8080e7          	jalr	-56(ra) # 8000610e <virtio_disk_rw>
}
    8000314e:	60e2                	ld	ra,24(sp)
    80003150:	6442                	ld	s0,16(sp)
    80003152:	64a2                	ld	s1,8(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret
    panic("bwrite");
    80003158:	00005517          	auipc	a0,0x5
    8000315c:	3d050513          	addi	a0,a0,976 # 80008528 <syscalls+0x110>
    80003160:	ffffd097          	auipc	ra,0xffffd
    80003164:	4b2080e7          	jalr	1202(ra) # 80000612 <panic>

0000000080003168 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003168:	1101                	addi	sp,sp,-32
    8000316a:	ec06                	sd	ra,24(sp)
    8000316c:	e822                	sd	s0,16(sp)
    8000316e:	e426                	sd	s1,8(sp)
    80003170:	e04a                	sd	s2,0(sp)
    80003172:	1000                	addi	s0,sp,32
    80003174:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003176:	01050913          	addi	s2,a0,16
    8000317a:	854a                	mv	a0,s2
    8000317c:	00001097          	auipc	ra,0x1
    80003180:	46e080e7          	jalr	1134(ra) # 800045ea <holdingsleep>
    80003184:	c92d                	beqz	a0,800031f6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003186:	854a                	mv	a0,s2
    80003188:	00001097          	auipc	ra,0x1
    8000318c:	41e080e7          	jalr	1054(ra) # 800045a6 <releasesleep>

  acquire(&bcache.lock);
    80003190:	00015517          	auipc	a0,0x15
    80003194:	bf050513          	addi	a0,a0,-1040 # 80017d80 <bcache>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	b3e080e7          	jalr	-1218(ra) # 80000cd6 <acquire>
  b->refcnt--;
    800031a0:	40bc                	lw	a5,64(s1)
    800031a2:	37fd                	addiw	a5,a5,-1
    800031a4:	0007871b          	sext.w	a4,a5
    800031a8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031aa:	eb05                	bnez	a4,800031da <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ac:	68bc                	ld	a5,80(s1)
    800031ae:	64b8                	ld	a4,72(s1)
    800031b0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031b2:	64bc                	ld	a5,72(s1)
    800031b4:	68b8                	ld	a4,80(s1)
    800031b6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031b8:	0001d797          	auipc	a5,0x1d
    800031bc:	bc878793          	addi	a5,a5,-1080 # 8001fd80 <bcache+0x8000>
    800031c0:	2b87b703          	ld	a4,696(a5)
    800031c4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031c6:	0001d717          	auipc	a4,0x1d
    800031ca:	e2270713          	addi	a4,a4,-478 # 8001ffe8 <bcache+0x8268>
    800031ce:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031d0:	2b87b703          	ld	a4,696(a5)
    800031d4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031d6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031da:	00015517          	auipc	a0,0x15
    800031de:	ba650513          	addi	a0,a0,-1114 # 80017d80 <bcache>
    800031e2:	ffffe097          	auipc	ra,0xffffe
    800031e6:	ba8080e7          	jalr	-1112(ra) # 80000d8a <release>
}
    800031ea:	60e2                	ld	ra,24(sp)
    800031ec:	6442                	ld	s0,16(sp)
    800031ee:	64a2                	ld	s1,8(sp)
    800031f0:	6902                	ld	s2,0(sp)
    800031f2:	6105                	addi	sp,sp,32
    800031f4:	8082                	ret
    panic("brelse");
    800031f6:	00005517          	auipc	a0,0x5
    800031fa:	33a50513          	addi	a0,a0,826 # 80008530 <syscalls+0x118>
    800031fe:	ffffd097          	auipc	ra,0xffffd
    80003202:	414080e7          	jalr	1044(ra) # 80000612 <panic>

0000000080003206 <bpin>:

void
bpin(struct buf *b) {
    80003206:	1101                	addi	sp,sp,-32
    80003208:	ec06                	sd	ra,24(sp)
    8000320a:	e822                	sd	s0,16(sp)
    8000320c:	e426                	sd	s1,8(sp)
    8000320e:	1000                	addi	s0,sp,32
    80003210:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003212:	00015517          	auipc	a0,0x15
    80003216:	b6e50513          	addi	a0,a0,-1170 # 80017d80 <bcache>
    8000321a:	ffffe097          	auipc	ra,0xffffe
    8000321e:	abc080e7          	jalr	-1348(ra) # 80000cd6 <acquire>
  b->refcnt++;
    80003222:	40bc                	lw	a5,64(s1)
    80003224:	2785                	addiw	a5,a5,1
    80003226:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003228:	00015517          	auipc	a0,0x15
    8000322c:	b5850513          	addi	a0,a0,-1192 # 80017d80 <bcache>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	b5a080e7          	jalr	-1190(ra) # 80000d8a <release>
}
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	64a2                	ld	s1,8(sp)
    8000323e:	6105                	addi	sp,sp,32
    80003240:	8082                	ret

0000000080003242 <bunpin>:

void
bunpin(struct buf *b) {
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000324e:	00015517          	auipc	a0,0x15
    80003252:	b3250513          	addi	a0,a0,-1230 # 80017d80 <bcache>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	a80080e7          	jalr	-1408(ra) # 80000cd6 <acquire>
  b->refcnt--;
    8000325e:	40bc                	lw	a5,64(s1)
    80003260:	37fd                	addiw	a5,a5,-1
    80003262:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003264:	00015517          	auipc	a0,0x15
    80003268:	b1c50513          	addi	a0,a0,-1252 # 80017d80 <bcache>
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	b1e080e7          	jalr	-1250(ra) # 80000d8a <release>
}
    80003274:	60e2                	ld	ra,24(sp)
    80003276:	6442                	ld	s0,16(sp)
    80003278:	64a2                	ld	s1,8(sp)
    8000327a:	6105                	addi	sp,sp,32
    8000327c:	8082                	ret

000000008000327e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000327e:	1101                	addi	sp,sp,-32
    80003280:	ec06                	sd	ra,24(sp)
    80003282:	e822                	sd	s0,16(sp)
    80003284:	e426                	sd	s1,8(sp)
    80003286:	e04a                	sd	s2,0(sp)
    80003288:	1000                	addi	s0,sp,32
    8000328a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000328c:	00d5d59b          	srliw	a1,a1,0xd
    80003290:	0001d797          	auipc	a5,0x1d
    80003294:	1b078793          	addi	a5,a5,432 # 80020440 <sb>
    80003298:	4fdc                	lw	a5,28(a5)
    8000329a:	9dbd                	addw	a1,a1,a5
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	d8a080e7          	jalr	-630(ra) # 80003026 <bread>
  bi = b % BPB;
    800032a4:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800032a6:	0074f793          	andi	a5,s1,7
    800032aa:	4705                	li	a4,1
    800032ac:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    800032b0:	6789                	lui	a5,0x2
    800032b2:	17fd                	addi	a5,a5,-1
    800032b4:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    800032b6:	41f4d79b          	sraiw	a5,s1,0x1f
    800032ba:	01d7d79b          	srliw	a5,a5,0x1d
    800032be:	9fa5                	addw	a5,a5,s1
    800032c0:	4037d79b          	sraiw	a5,a5,0x3
    800032c4:	00f506b3          	add	a3,a0,a5
    800032c8:	0586c683          	lbu	a3,88(a3)
    800032cc:	00d77633          	and	a2,a4,a3
    800032d0:	c61d                	beqz	a2,800032fe <bfree+0x80>
    800032d2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032d4:	97aa                	add	a5,a5,a0
    800032d6:	fff74713          	not	a4,a4
    800032da:	8f75                	and	a4,a4,a3
    800032dc:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    800032e0:	00001097          	auipc	ra,0x1
    800032e4:	132080e7          	jalr	306(ra) # 80004412 <log_write>
  brelse(bp);
    800032e8:	854a                	mv	a0,s2
    800032ea:	00000097          	auipc	ra,0x0
    800032ee:	e7e080e7          	jalr	-386(ra) # 80003168 <brelse>
}
    800032f2:	60e2                	ld	ra,24(sp)
    800032f4:	6442                	ld	s0,16(sp)
    800032f6:	64a2                	ld	s1,8(sp)
    800032f8:	6902                	ld	s2,0(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret
    panic("freeing free block");
    800032fe:	00005517          	auipc	a0,0x5
    80003302:	23a50513          	addi	a0,a0,570 # 80008538 <syscalls+0x120>
    80003306:	ffffd097          	auipc	ra,0xffffd
    8000330a:	30c080e7          	jalr	780(ra) # 80000612 <panic>

000000008000330e <balloc>:
{
    8000330e:	711d                	addi	sp,sp,-96
    80003310:	ec86                	sd	ra,88(sp)
    80003312:	e8a2                	sd	s0,80(sp)
    80003314:	e4a6                	sd	s1,72(sp)
    80003316:	e0ca                	sd	s2,64(sp)
    80003318:	fc4e                	sd	s3,56(sp)
    8000331a:	f852                	sd	s4,48(sp)
    8000331c:	f456                	sd	s5,40(sp)
    8000331e:	f05a                	sd	s6,32(sp)
    80003320:	ec5e                	sd	s7,24(sp)
    80003322:	e862                	sd	s8,16(sp)
    80003324:	e466                	sd	s9,8(sp)
    80003326:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003328:	0001d797          	auipc	a5,0x1d
    8000332c:	11878793          	addi	a5,a5,280 # 80020440 <sb>
    80003330:	43dc                	lw	a5,4(a5)
    80003332:	10078e63          	beqz	a5,8000344e <balloc+0x140>
    80003336:	8baa                	mv	s7,a0
    80003338:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000333a:	0001db17          	auipc	s6,0x1d
    8000333e:	106b0b13          	addi	s6,s6,262 # 80020440 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003342:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80003344:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003346:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003348:	6c89                	lui	s9,0x2
    8000334a:	a079                	j	800033d8 <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000334c:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    8000334e:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003350:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    80003352:	96a6                	add	a3,a3,s1
    80003354:	8f51                	or	a4,a4,a2
    80003356:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    8000335a:	8526                	mv	a0,s1
    8000335c:	00001097          	auipc	ra,0x1
    80003360:	0b6080e7          	jalr	182(ra) # 80004412 <log_write>
        brelse(bp);
    80003364:	8526                	mv	a0,s1
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	e02080e7          	jalr	-510(ra) # 80003168 <brelse>
  bp = bread(dev, bno);
    8000336e:	85ca                	mv	a1,s2
    80003370:	855e                	mv	a0,s7
    80003372:	00000097          	auipc	ra,0x0
    80003376:	cb4080e7          	jalr	-844(ra) # 80003026 <bread>
    8000337a:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    8000337c:	40000613          	li	a2,1024
    80003380:	4581                	li	a1,0
    80003382:	05850513          	addi	a0,a0,88
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	a4c080e7          	jalr	-1460(ra) # 80000dd2 <memset>
  log_write(bp);
    8000338e:	8526                	mv	a0,s1
    80003390:	00001097          	auipc	ra,0x1
    80003394:	082080e7          	jalr	130(ra) # 80004412 <log_write>
  brelse(bp);
    80003398:	8526                	mv	a0,s1
    8000339a:	00000097          	auipc	ra,0x0
    8000339e:	dce080e7          	jalr	-562(ra) # 80003168 <brelse>
}
    800033a2:	854a                	mv	a0,s2
    800033a4:	60e6                	ld	ra,88(sp)
    800033a6:	6446                	ld	s0,80(sp)
    800033a8:	64a6                	ld	s1,72(sp)
    800033aa:	6906                	ld	s2,64(sp)
    800033ac:	79e2                	ld	s3,56(sp)
    800033ae:	7a42                	ld	s4,48(sp)
    800033b0:	7aa2                	ld	s5,40(sp)
    800033b2:	7b02                	ld	s6,32(sp)
    800033b4:	6be2                	ld	s7,24(sp)
    800033b6:	6c42                	ld	s8,16(sp)
    800033b8:	6ca2                	ld	s9,8(sp)
    800033ba:	6125                	addi	sp,sp,96
    800033bc:	8082                	ret
    brelse(bp);
    800033be:	8526                	mv	a0,s1
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	da8080e7          	jalr	-600(ra) # 80003168 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033c8:	015c87bb          	addw	a5,s9,s5
    800033cc:	00078a9b          	sext.w	s5,a5
    800033d0:	004b2703          	lw	a4,4(s6)
    800033d4:	06eafd63          	bleu	a4,s5,8000344e <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    800033d8:	41fad79b          	sraiw	a5,s5,0x1f
    800033dc:	0137d79b          	srliw	a5,a5,0x13
    800033e0:	015787bb          	addw	a5,a5,s5
    800033e4:	40d7d79b          	sraiw	a5,a5,0xd
    800033e8:	01cb2583          	lw	a1,28(s6)
    800033ec:	9dbd                	addw	a1,a1,a5
    800033ee:	855e                	mv	a0,s7
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	c36080e7          	jalr	-970(ra) # 80003026 <bread>
    800033f8:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033fa:	000a881b          	sext.w	a6,s5
    800033fe:	004b2503          	lw	a0,4(s6)
    80003402:	faa87ee3          	bleu	a0,a6,800033be <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003406:	0584c603          	lbu	a2,88(s1)
    8000340a:	00167793          	andi	a5,a2,1
    8000340e:	df9d                	beqz	a5,8000334c <balloc+0x3e>
    80003410:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003414:	87e2                	mv	a5,s8
    80003416:	0107893b          	addw	s2,a5,a6
    8000341a:	faa782e3          	beq	a5,a0,800033be <balloc+0xb0>
      m = 1 << (bi % 8);
    8000341e:	41f7d71b          	sraiw	a4,a5,0x1f
    80003422:	01d7561b          	srliw	a2,a4,0x1d
    80003426:	00f606bb          	addw	a3,a2,a5
    8000342a:	0076f713          	andi	a4,a3,7
    8000342e:	9f11                	subw	a4,a4,a2
    80003430:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003434:	4036d69b          	sraiw	a3,a3,0x3
    80003438:	00d48633          	add	a2,s1,a3
    8000343c:	05864603          	lbu	a2,88(a2)
    80003440:	00c775b3          	and	a1,a4,a2
    80003444:	d599                	beqz	a1,80003352 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003446:	2785                	addiw	a5,a5,1
    80003448:	fd4797e3          	bne	a5,s4,80003416 <balloc+0x108>
    8000344c:	bf8d                	j	800033be <balloc+0xb0>
  panic("balloc: out of blocks");
    8000344e:	00005517          	auipc	a0,0x5
    80003452:	10250513          	addi	a0,a0,258 # 80008550 <syscalls+0x138>
    80003456:	ffffd097          	auipc	ra,0xffffd
    8000345a:	1bc080e7          	jalr	444(ra) # 80000612 <panic>

000000008000345e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000345e:	7179                	addi	sp,sp,-48
    80003460:	f406                	sd	ra,40(sp)
    80003462:	f022                	sd	s0,32(sp)
    80003464:	ec26                	sd	s1,24(sp)
    80003466:	e84a                	sd	s2,16(sp)
    80003468:	e44e                	sd	s3,8(sp)
    8000346a:	e052                	sd	s4,0(sp)
    8000346c:	1800                	addi	s0,sp,48
    8000346e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003470:	47ad                	li	a5,11
    80003472:	04b7fe63          	bleu	a1,a5,800034ce <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003476:	ff45849b          	addiw	s1,a1,-12
    8000347a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000347e:	0ff00793          	li	a5,255
    80003482:	0ae7e363          	bltu	a5,a4,80003528 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003486:	08052583          	lw	a1,128(a0)
    8000348a:	c5ad                	beqz	a1,800034f4 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000348c:	0009a503          	lw	a0,0(s3)
    80003490:	00000097          	auipc	ra,0x0
    80003494:	b96080e7          	jalr	-1130(ra) # 80003026 <bread>
    80003498:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000349a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000349e:	02049593          	slli	a1,s1,0x20
    800034a2:	9181                	srli	a1,a1,0x20
    800034a4:	058a                	slli	a1,a1,0x2
    800034a6:	00b784b3          	add	s1,a5,a1
    800034aa:	0004a903          	lw	s2,0(s1)
    800034ae:	04090d63          	beqz	s2,80003508 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034b2:	8552                	mv	a0,s4
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	cb4080e7          	jalr	-844(ra) # 80003168 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034bc:	854a                	mv	a0,s2
    800034be:	70a2                	ld	ra,40(sp)
    800034c0:	7402                	ld	s0,32(sp)
    800034c2:	64e2                	ld	s1,24(sp)
    800034c4:	6942                	ld	s2,16(sp)
    800034c6:	69a2                	ld	s3,8(sp)
    800034c8:	6a02                	ld	s4,0(sp)
    800034ca:	6145                	addi	sp,sp,48
    800034cc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034ce:	02059493          	slli	s1,a1,0x20
    800034d2:	9081                	srli	s1,s1,0x20
    800034d4:	048a                	slli	s1,s1,0x2
    800034d6:	94aa                	add	s1,s1,a0
    800034d8:	0504a903          	lw	s2,80(s1)
    800034dc:	fe0910e3          	bnez	s2,800034bc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034e0:	4108                	lw	a0,0(a0)
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	e2c080e7          	jalr	-468(ra) # 8000330e <balloc>
    800034ea:	0005091b          	sext.w	s2,a0
    800034ee:	0524a823          	sw	s2,80(s1)
    800034f2:	b7e9                	j	800034bc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034f4:	4108                	lw	a0,0(a0)
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	e18080e7          	jalr	-488(ra) # 8000330e <balloc>
    800034fe:	0005059b          	sext.w	a1,a0
    80003502:	08b9a023          	sw	a1,128(s3)
    80003506:	b759                	j	8000348c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003508:	0009a503          	lw	a0,0(s3)
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	e02080e7          	jalr	-510(ra) # 8000330e <balloc>
    80003514:	0005091b          	sext.w	s2,a0
    80003518:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    8000351c:	8552                	mv	a0,s4
    8000351e:	00001097          	auipc	ra,0x1
    80003522:	ef4080e7          	jalr	-268(ra) # 80004412 <log_write>
    80003526:	b771                	j	800034b2 <bmap+0x54>
  panic("bmap: out of range");
    80003528:	00005517          	auipc	a0,0x5
    8000352c:	04050513          	addi	a0,a0,64 # 80008568 <syscalls+0x150>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	0e2080e7          	jalr	226(ra) # 80000612 <panic>

0000000080003538 <iget>:
{
    80003538:	7179                	addi	sp,sp,-48
    8000353a:	f406                	sd	ra,40(sp)
    8000353c:	f022                	sd	s0,32(sp)
    8000353e:	ec26                	sd	s1,24(sp)
    80003540:	e84a                	sd	s2,16(sp)
    80003542:	e44e                	sd	s3,8(sp)
    80003544:	e052                	sd	s4,0(sp)
    80003546:	1800                	addi	s0,sp,48
    80003548:	89aa                	mv	s3,a0
    8000354a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000354c:	0001d517          	auipc	a0,0x1d
    80003550:	f1450513          	addi	a0,a0,-236 # 80020460 <icache>
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	782080e7          	jalr	1922(ra) # 80000cd6 <acquire>
  empty = 0;
    8000355c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000355e:	0001d497          	auipc	s1,0x1d
    80003562:	f1a48493          	addi	s1,s1,-230 # 80020478 <icache+0x18>
    80003566:	0001f697          	auipc	a3,0x1f
    8000356a:	9a268693          	addi	a3,a3,-1630 # 80021f08 <log>
    8000356e:	a039                	j	8000357c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003570:	02090b63          	beqz	s2,800035a6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003574:	08848493          	addi	s1,s1,136
    80003578:	02d48a63          	beq	s1,a3,800035ac <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000357c:	449c                	lw	a5,8(s1)
    8000357e:	fef059e3          	blez	a5,80003570 <iget+0x38>
    80003582:	4098                	lw	a4,0(s1)
    80003584:	ff3716e3          	bne	a4,s3,80003570 <iget+0x38>
    80003588:	40d8                	lw	a4,4(s1)
    8000358a:	ff4713e3          	bne	a4,s4,80003570 <iget+0x38>
      ip->ref++;
    8000358e:	2785                	addiw	a5,a5,1
    80003590:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003592:	0001d517          	auipc	a0,0x1d
    80003596:	ece50513          	addi	a0,a0,-306 # 80020460 <icache>
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	7f0080e7          	jalr	2032(ra) # 80000d8a <release>
      return ip;
    800035a2:	8926                	mv	s2,s1
    800035a4:	a03d                	j	800035d2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035a6:	f7f9                	bnez	a5,80003574 <iget+0x3c>
    800035a8:	8926                	mv	s2,s1
    800035aa:	b7e9                	j	80003574 <iget+0x3c>
  if(empty == 0)
    800035ac:	02090c63          	beqz	s2,800035e4 <iget+0xac>
  ip->dev = dev;
    800035b0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035b4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035b8:	4785                	li	a5,1
    800035ba:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035be:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800035c2:	0001d517          	auipc	a0,0x1d
    800035c6:	e9e50513          	addi	a0,a0,-354 # 80020460 <icache>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	7c0080e7          	jalr	1984(ra) # 80000d8a <release>
}
    800035d2:	854a                	mv	a0,s2
    800035d4:	70a2                	ld	ra,40(sp)
    800035d6:	7402                	ld	s0,32(sp)
    800035d8:	64e2                	ld	s1,24(sp)
    800035da:	6942                	ld	s2,16(sp)
    800035dc:	69a2                	ld	s3,8(sp)
    800035de:	6a02                	ld	s4,0(sp)
    800035e0:	6145                	addi	sp,sp,48
    800035e2:	8082                	ret
    panic("iget: no inodes");
    800035e4:	00005517          	auipc	a0,0x5
    800035e8:	f9c50513          	addi	a0,a0,-100 # 80008580 <syscalls+0x168>
    800035ec:	ffffd097          	auipc	ra,0xffffd
    800035f0:	026080e7          	jalr	38(ra) # 80000612 <panic>

00000000800035f4 <fsinit>:
fsinit(int dev) {
    800035f4:	7179                	addi	sp,sp,-48
    800035f6:	f406                	sd	ra,40(sp)
    800035f8:	f022                	sd	s0,32(sp)
    800035fa:	ec26                	sd	s1,24(sp)
    800035fc:	e84a                	sd	s2,16(sp)
    800035fe:	e44e                	sd	s3,8(sp)
    80003600:	1800                	addi	s0,sp,48
    80003602:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80003604:	4585                	li	a1,1
    80003606:	00000097          	auipc	ra,0x0
    8000360a:	a20080e7          	jalr	-1504(ra) # 80003026 <bread>
    8000360e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003610:	0001d497          	auipc	s1,0x1d
    80003614:	e3048493          	addi	s1,s1,-464 # 80020440 <sb>
    80003618:	02000613          	li	a2,32
    8000361c:	05850593          	addi	a1,a0,88
    80003620:	8526                	mv	a0,s1
    80003622:	ffffe097          	auipc	ra,0xffffe
    80003626:	81c080e7          	jalr	-2020(ra) # 80000e3e <memmove>
  brelse(bp);
    8000362a:	854a                	mv	a0,s2
    8000362c:	00000097          	auipc	ra,0x0
    80003630:	b3c080e7          	jalr	-1220(ra) # 80003168 <brelse>
  if(sb.magic != FSMAGIC)
    80003634:	4098                	lw	a4,0(s1)
    80003636:	102037b7          	lui	a5,0x10203
    8000363a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000363e:	02f71263          	bne	a4,a5,80003662 <fsinit+0x6e>
  initlog(dev, &sb);
    80003642:	0001d597          	auipc	a1,0x1d
    80003646:	dfe58593          	addi	a1,a1,-514 # 80020440 <sb>
    8000364a:	854e                	mv	a0,s3
    8000364c:	00001097          	auipc	ra,0x1
    80003650:	b48080e7          	jalr	-1208(ra) # 80004194 <initlog>
}
    80003654:	70a2                	ld	ra,40(sp)
    80003656:	7402                	ld	s0,32(sp)
    80003658:	64e2                	ld	s1,24(sp)
    8000365a:	6942                	ld	s2,16(sp)
    8000365c:	69a2                	ld	s3,8(sp)
    8000365e:	6145                	addi	sp,sp,48
    80003660:	8082                	ret
    panic("invalid file system");
    80003662:	00005517          	auipc	a0,0x5
    80003666:	f2e50513          	addi	a0,a0,-210 # 80008590 <syscalls+0x178>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	fa8080e7          	jalr	-88(ra) # 80000612 <panic>

0000000080003672 <iinit>:
{
    80003672:	7179                	addi	sp,sp,-48
    80003674:	f406                	sd	ra,40(sp)
    80003676:	f022                	sd	s0,32(sp)
    80003678:	ec26                	sd	s1,24(sp)
    8000367a:	e84a                	sd	s2,16(sp)
    8000367c:	e44e                	sd	s3,8(sp)
    8000367e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003680:	00005597          	auipc	a1,0x5
    80003684:	f2858593          	addi	a1,a1,-216 # 800085a8 <syscalls+0x190>
    80003688:	0001d517          	auipc	a0,0x1d
    8000368c:	dd850513          	addi	a0,a0,-552 # 80020460 <icache>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	5b6080e7          	jalr	1462(ra) # 80000c46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003698:	0001d497          	auipc	s1,0x1d
    8000369c:	df048493          	addi	s1,s1,-528 # 80020488 <icache+0x28>
    800036a0:	0001f997          	auipc	s3,0x1f
    800036a4:	87898993          	addi	s3,s3,-1928 # 80021f18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036a8:	00005917          	auipc	s2,0x5
    800036ac:	f0890913          	addi	s2,s2,-248 # 800085b0 <syscalls+0x198>
    800036b0:	85ca                	mv	a1,s2
    800036b2:	8526                	mv	a0,s1
    800036b4:	00001097          	auipc	ra,0x1
    800036b8:	e62080e7          	jalr	-414(ra) # 80004516 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036bc:	08848493          	addi	s1,s1,136
    800036c0:	ff3498e3          	bne	s1,s3,800036b0 <iinit+0x3e>
}
    800036c4:	70a2                	ld	ra,40(sp)
    800036c6:	7402                	ld	s0,32(sp)
    800036c8:	64e2                	ld	s1,24(sp)
    800036ca:	6942                	ld	s2,16(sp)
    800036cc:	69a2                	ld	s3,8(sp)
    800036ce:	6145                	addi	sp,sp,48
    800036d0:	8082                	ret

00000000800036d2 <ialloc>:
{
    800036d2:	715d                	addi	sp,sp,-80
    800036d4:	e486                	sd	ra,72(sp)
    800036d6:	e0a2                	sd	s0,64(sp)
    800036d8:	fc26                	sd	s1,56(sp)
    800036da:	f84a                	sd	s2,48(sp)
    800036dc:	f44e                	sd	s3,40(sp)
    800036de:	f052                	sd	s4,32(sp)
    800036e0:	ec56                	sd	s5,24(sp)
    800036e2:	e85a                	sd	s6,16(sp)
    800036e4:	e45e                	sd	s7,8(sp)
    800036e6:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e8:	0001d797          	auipc	a5,0x1d
    800036ec:	d5878793          	addi	a5,a5,-680 # 80020440 <sb>
    800036f0:	47d8                	lw	a4,12(a5)
    800036f2:	4785                	li	a5,1
    800036f4:	04e7fa63          	bleu	a4,a5,80003748 <ialloc+0x76>
    800036f8:	8a2a                	mv	s4,a0
    800036fa:	8b2e                	mv	s6,a1
    800036fc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036fe:	0001d997          	auipc	s3,0x1d
    80003702:	d4298993          	addi	s3,s3,-702 # 80020440 <sb>
    80003706:	00048a9b          	sext.w	s5,s1
    8000370a:	0044d593          	srli	a1,s1,0x4
    8000370e:	0189a783          	lw	a5,24(s3)
    80003712:	9dbd                	addw	a1,a1,a5
    80003714:	8552                	mv	a0,s4
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	910080e7          	jalr	-1776(ra) # 80003026 <bread>
    8000371e:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003720:	05850913          	addi	s2,a0,88
    80003724:	00f4f793          	andi	a5,s1,15
    80003728:	079a                	slli	a5,a5,0x6
    8000372a:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    8000372c:	00091783          	lh	a5,0(s2)
    80003730:	c785                	beqz	a5,80003758 <ialloc+0x86>
    brelse(bp);
    80003732:	00000097          	auipc	ra,0x0
    80003736:	a36080e7          	jalr	-1482(ra) # 80003168 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000373a:	0485                	addi	s1,s1,1
    8000373c:	00c9a703          	lw	a4,12(s3)
    80003740:	0004879b          	sext.w	a5,s1
    80003744:	fce7e1e3          	bltu	a5,a4,80003706 <ialloc+0x34>
  panic("ialloc: no inodes");
    80003748:	00005517          	auipc	a0,0x5
    8000374c:	e7050513          	addi	a0,a0,-400 # 800085b8 <syscalls+0x1a0>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	ec2080e7          	jalr	-318(ra) # 80000612 <panic>
      memset(dip, 0, sizeof(*dip));
    80003758:	04000613          	li	a2,64
    8000375c:	4581                	li	a1,0
    8000375e:	854a                	mv	a0,s2
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	672080e7          	jalr	1650(ra) # 80000dd2 <memset>
      dip->type = type;
    80003768:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    8000376c:	855e                	mv	a0,s7
    8000376e:	00001097          	auipc	ra,0x1
    80003772:	ca4080e7          	jalr	-860(ra) # 80004412 <log_write>
      brelse(bp);
    80003776:	855e                	mv	a0,s7
    80003778:	00000097          	auipc	ra,0x0
    8000377c:	9f0080e7          	jalr	-1552(ra) # 80003168 <brelse>
      return iget(dev, inum);
    80003780:	85d6                	mv	a1,s5
    80003782:	8552                	mv	a0,s4
    80003784:	00000097          	auipc	ra,0x0
    80003788:	db4080e7          	jalr	-588(ra) # 80003538 <iget>
}
    8000378c:	60a6                	ld	ra,72(sp)
    8000378e:	6406                	ld	s0,64(sp)
    80003790:	74e2                	ld	s1,56(sp)
    80003792:	7942                	ld	s2,48(sp)
    80003794:	79a2                	ld	s3,40(sp)
    80003796:	7a02                	ld	s4,32(sp)
    80003798:	6ae2                	ld	s5,24(sp)
    8000379a:	6b42                	ld	s6,16(sp)
    8000379c:	6ba2                	ld	s7,8(sp)
    8000379e:	6161                	addi	sp,sp,80
    800037a0:	8082                	ret

00000000800037a2 <iupdate>:
{
    800037a2:	1101                	addi	sp,sp,-32
    800037a4:	ec06                	sd	ra,24(sp)
    800037a6:	e822                	sd	s0,16(sp)
    800037a8:	e426                	sd	s1,8(sp)
    800037aa:	e04a                	sd	s2,0(sp)
    800037ac:	1000                	addi	s0,sp,32
    800037ae:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037b0:	415c                	lw	a5,4(a0)
    800037b2:	0047d79b          	srliw	a5,a5,0x4
    800037b6:	0001d717          	auipc	a4,0x1d
    800037ba:	c8a70713          	addi	a4,a4,-886 # 80020440 <sb>
    800037be:	4f0c                	lw	a1,24(a4)
    800037c0:	9dbd                	addw	a1,a1,a5
    800037c2:	4108                	lw	a0,0(a0)
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	862080e7          	jalr	-1950(ra) # 80003026 <bread>
    800037cc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037ce:	05850513          	addi	a0,a0,88
    800037d2:	40dc                	lw	a5,4(s1)
    800037d4:	8bbd                	andi	a5,a5,15
    800037d6:	079a                	slli	a5,a5,0x6
    800037d8:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037da:	04449783          	lh	a5,68(s1)
    800037de:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    800037e2:	04649783          	lh	a5,70(s1)
    800037e6:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    800037ea:	04849783          	lh	a5,72(s1)
    800037ee:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    800037f2:	04a49783          	lh	a5,74(s1)
    800037f6:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    800037fa:	44fc                	lw	a5,76(s1)
    800037fc:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037fe:	03400613          	li	a2,52
    80003802:	05048593          	addi	a1,s1,80
    80003806:	0531                	addi	a0,a0,12
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	636080e7          	jalr	1590(ra) # 80000e3e <memmove>
  log_write(bp);
    80003810:	854a                	mv	a0,s2
    80003812:	00001097          	auipc	ra,0x1
    80003816:	c00080e7          	jalr	-1024(ra) # 80004412 <log_write>
  brelse(bp);
    8000381a:	854a                	mv	a0,s2
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	94c080e7          	jalr	-1716(ra) # 80003168 <brelse>
}
    80003824:	60e2                	ld	ra,24(sp)
    80003826:	6442                	ld	s0,16(sp)
    80003828:	64a2                	ld	s1,8(sp)
    8000382a:	6902                	ld	s2,0(sp)
    8000382c:	6105                	addi	sp,sp,32
    8000382e:	8082                	ret

0000000080003830 <idup>:
{
    80003830:	1101                	addi	sp,sp,-32
    80003832:	ec06                	sd	ra,24(sp)
    80003834:	e822                	sd	s0,16(sp)
    80003836:	e426                	sd	s1,8(sp)
    80003838:	1000                	addi	s0,sp,32
    8000383a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000383c:	0001d517          	auipc	a0,0x1d
    80003840:	c2450513          	addi	a0,a0,-988 # 80020460 <icache>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	492080e7          	jalr	1170(ra) # 80000cd6 <acquire>
  ip->ref++;
    8000384c:	449c                	lw	a5,8(s1)
    8000384e:	2785                	addiw	a5,a5,1
    80003850:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003852:	0001d517          	auipc	a0,0x1d
    80003856:	c0e50513          	addi	a0,a0,-1010 # 80020460 <icache>
    8000385a:	ffffd097          	auipc	ra,0xffffd
    8000385e:	530080e7          	jalr	1328(ra) # 80000d8a <release>
}
    80003862:	8526                	mv	a0,s1
    80003864:	60e2                	ld	ra,24(sp)
    80003866:	6442                	ld	s0,16(sp)
    80003868:	64a2                	ld	s1,8(sp)
    8000386a:	6105                	addi	sp,sp,32
    8000386c:	8082                	ret

000000008000386e <ilock>:
{
    8000386e:	1101                	addi	sp,sp,-32
    80003870:	ec06                	sd	ra,24(sp)
    80003872:	e822                	sd	s0,16(sp)
    80003874:	e426                	sd	s1,8(sp)
    80003876:	e04a                	sd	s2,0(sp)
    80003878:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000387a:	c115                	beqz	a0,8000389e <ilock+0x30>
    8000387c:	84aa                	mv	s1,a0
    8000387e:	451c                	lw	a5,8(a0)
    80003880:	00f05f63          	blez	a5,8000389e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003884:	0541                	addi	a0,a0,16
    80003886:	00001097          	auipc	ra,0x1
    8000388a:	cca080e7          	jalr	-822(ra) # 80004550 <acquiresleep>
  if(ip->valid == 0){
    8000388e:	40bc                	lw	a5,64(s1)
    80003890:	cf99                	beqz	a5,800038ae <ilock+0x40>
}
    80003892:	60e2                	ld	ra,24(sp)
    80003894:	6442                	ld	s0,16(sp)
    80003896:	64a2                	ld	s1,8(sp)
    80003898:	6902                	ld	s2,0(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret
    panic("ilock");
    8000389e:	00005517          	auipc	a0,0x5
    800038a2:	d3250513          	addi	a0,a0,-718 # 800085d0 <syscalls+0x1b8>
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	d6c080e7          	jalr	-660(ra) # 80000612 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038ae:	40dc                	lw	a5,4(s1)
    800038b0:	0047d79b          	srliw	a5,a5,0x4
    800038b4:	0001d717          	auipc	a4,0x1d
    800038b8:	b8c70713          	addi	a4,a4,-1140 # 80020440 <sb>
    800038bc:	4f0c                	lw	a1,24(a4)
    800038be:	9dbd                	addw	a1,a1,a5
    800038c0:	4088                	lw	a0,0(s1)
    800038c2:	fffff097          	auipc	ra,0xfffff
    800038c6:	764080e7          	jalr	1892(ra) # 80003026 <bread>
    800038ca:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038cc:	05850593          	addi	a1,a0,88
    800038d0:	40dc                	lw	a5,4(s1)
    800038d2:	8bbd                	andi	a5,a5,15
    800038d4:	079a                	slli	a5,a5,0x6
    800038d6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038d8:	00059783          	lh	a5,0(a1)
    800038dc:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038e0:	00259783          	lh	a5,2(a1)
    800038e4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038e8:	00459783          	lh	a5,4(a1)
    800038ec:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038f0:	00659783          	lh	a5,6(a1)
    800038f4:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038f8:	459c                	lw	a5,8(a1)
    800038fa:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038fc:	03400613          	li	a2,52
    80003900:	05b1                	addi	a1,a1,12
    80003902:	05048513          	addi	a0,s1,80
    80003906:	ffffd097          	auipc	ra,0xffffd
    8000390a:	538080e7          	jalr	1336(ra) # 80000e3e <memmove>
    brelse(bp);
    8000390e:	854a                	mv	a0,s2
    80003910:	00000097          	auipc	ra,0x0
    80003914:	858080e7          	jalr	-1960(ra) # 80003168 <brelse>
    ip->valid = 1;
    80003918:	4785                	li	a5,1
    8000391a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000391c:	04449783          	lh	a5,68(s1)
    80003920:	fbad                	bnez	a5,80003892 <ilock+0x24>
      panic("ilock: no type");
    80003922:	00005517          	auipc	a0,0x5
    80003926:	cb650513          	addi	a0,a0,-842 # 800085d8 <syscalls+0x1c0>
    8000392a:	ffffd097          	auipc	ra,0xffffd
    8000392e:	ce8080e7          	jalr	-792(ra) # 80000612 <panic>

0000000080003932 <iunlock>:
{
    80003932:	1101                	addi	sp,sp,-32
    80003934:	ec06                	sd	ra,24(sp)
    80003936:	e822                	sd	s0,16(sp)
    80003938:	e426                	sd	s1,8(sp)
    8000393a:	e04a                	sd	s2,0(sp)
    8000393c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000393e:	c905                	beqz	a0,8000396e <iunlock+0x3c>
    80003940:	84aa                	mv	s1,a0
    80003942:	01050913          	addi	s2,a0,16
    80003946:	854a                	mv	a0,s2
    80003948:	00001097          	auipc	ra,0x1
    8000394c:	ca2080e7          	jalr	-862(ra) # 800045ea <holdingsleep>
    80003950:	cd19                	beqz	a0,8000396e <iunlock+0x3c>
    80003952:	449c                	lw	a5,8(s1)
    80003954:	00f05d63          	blez	a5,8000396e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003958:	854a                	mv	a0,s2
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	c4c080e7          	jalr	-948(ra) # 800045a6 <releasesleep>
}
    80003962:	60e2                	ld	ra,24(sp)
    80003964:	6442                	ld	s0,16(sp)
    80003966:	64a2                	ld	s1,8(sp)
    80003968:	6902                	ld	s2,0(sp)
    8000396a:	6105                	addi	sp,sp,32
    8000396c:	8082                	ret
    panic("iunlock");
    8000396e:	00005517          	auipc	a0,0x5
    80003972:	c7a50513          	addi	a0,a0,-902 # 800085e8 <syscalls+0x1d0>
    80003976:	ffffd097          	auipc	ra,0xffffd
    8000397a:	c9c080e7          	jalr	-868(ra) # 80000612 <panic>

000000008000397e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000397e:	7179                	addi	sp,sp,-48
    80003980:	f406                	sd	ra,40(sp)
    80003982:	f022                	sd	s0,32(sp)
    80003984:	ec26                	sd	s1,24(sp)
    80003986:	e84a                	sd	s2,16(sp)
    80003988:	e44e                	sd	s3,8(sp)
    8000398a:	e052                	sd	s4,0(sp)
    8000398c:	1800                	addi	s0,sp,48
    8000398e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003990:	05050493          	addi	s1,a0,80
    80003994:	08050913          	addi	s2,a0,128
    80003998:	a821                	j	800039b0 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    8000399a:	0009a503          	lw	a0,0(s3)
    8000399e:	00000097          	auipc	ra,0x0
    800039a2:	8e0080e7          	jalr	-1824(ra) # 8000327e <bfree>
      ip->addrs[i] = 0;
    800039a6:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    800039aa:	0491                	addi	s1,s1,4
    800039ac:	01248563          	beq	s1,s2,800039b6 <itrunc+0x38>
    if(ip->addrs[i]){
    800039b0:	408c                	lw	a1,0(s1)
    800039b2:	dde5                	beqz	a1,800039aa <itrunc+0x2c>
    800039b4:	b7dd                	j	8000399a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039b6:	0809a583          	lw	a1,128(s3)
    800039ba:	e185                	bnez	a1,800039da <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039bc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039c0:	854e                	mv	a0,s3
    800039c2:	00000097          	auipc	ra,0x0
    800039c6:	de0080e7          	jalr	-544(ra) # 800037a2 <iupdate>
}
    800039ca:	70a2                	ld	ra,40(sp)
    800039cc:	7402                	ld	s0,32(sp)
    800039ce:	64e2                	ld	s1,24(sp)
    800039d0:	6942                	ld	s2,16(sp)
    800039d2:	69a2                	ld	s3,8(sp)
    800039d4:	6a02                	ld	s4,0(sp)
    800039d6:	6145                	addi	sp,sp,48
    800039d8:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039da:	0009a503          	lw	a0,0(s3)
    800039de:	fffff097          	auipc	ra,0xfffff
    800039e2:	648080e7          	jalr	1608(ra) # 80003026 <bread>
    800039e6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039e8:	05850493          	addi	s1,a0,88
    800039ec:	45850913          	addi	s2,a0,1112
    800039f0:	a811                	j	80003a04 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039f2:	0009a503          	lw	a0,0(s3)
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	888080e7          	jalr	-1912(ra) # 8000327e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039fe:	0491                	addi	s1,s1,4
    80003a00:	01248563          	beq	s1,s2,80003a0a <itrunc+0x8c>
      if(a[j])
    80003a04:	408c                	lw	a1,0(s1)
    80003a06:	dde5                	beqz	a1,800039fe <itrunc+0x80>
    80003a08:	b7ed                	j	800039f2 <itrunc+0x74>
    brelse(bp);
    80003a0a:	8552                	mv	a0,s4
    80003a0c:	fffff097          	auipc	ra,0xfffff
    80003a10:	75c080e7          	jalr	1884(ra) # 80003168 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a14:	0809a583          	lw	a1,128(s3)
    80003a18:	0009a503          	lw	a0,0(s3)
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	862080e7          	jalr	-1950(ra) # 8000327e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a24:	0809a023          	sw	zero,128(s3)
    80003a28:	bf51                	j	800039bc <itrunc+0x3e>

0000000080003a2a <iput>:
{
    80003a2a:	1101                	addi	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	e04a                	sd	s2,0(sp)
    80003a34:	1000                	addi	s0,sp,32
    80003a36:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003a38:	0001d517          	auipc	a0,0x1d
    80003a3c:	a2850513          	addi	a0,a0,-1496 # 80020460 <icache>
    80003a40:	ffffd097          	auipc	ra,0xffffd
    80003a44:	296080e7          	jalr	662(ra) # 80000cd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a48:	4498                	lw	a4,8(s1)
    80003a4a:	4785                	li	a5,1
    80003a4c:	02f70363          	beq	a4,a5,80003a72 <iput+0x48>
  ip->ref--;
    80003a50:	449c                	lw	a5,8(s1)
    80003a52:	37fd                	addiw	a5,a5,-1
    80003a54:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003a56:	0001d517          	auipc	a0,0x1d
    80003a5a:	a0a50513          	addi	a0,a0,-1526 # 80020460 <icache>
    80003a5e:	ffffd097          	auipc	ra,0xffffd
    80003a62:	32c080e7          	jalr	812(ra) # 80000d8a <release>
}
    80003a66:	60e2                	ld	ra,24(sp)
    80003a68:	6442                	ld	s0,16(sp)
    80003a6a:	64a2                	ld	s1,8(sp)
    80003a6c:	6902                	ld	s2,0(sp)
    80003a6e:	6105                	addi	sp,sp,32
    80003a70:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a72:	40bc                	lw	a5,64(s1)
    80003a74:	dff1                	beqz	a5,80003a50 <iput+0x26>
    80003a76:	04a49783          	lh	a5,74(s1)
    80003a7a:	fbf9                	bnez	a5,80003a50 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a7c:	01048913          	addi	s2,s1,16
    80003a80:	854a                	mv	a0,s2
    80003a82:	00001097          	auipc	ra,0x1
    80003a86:	ace080e7          	jalr	-1330(ra) # 80004550 <acquiresleep>
    release(&icache.lock);
    80003a8a:	0001d517          	auipc	a0,0x1d
    80003a8e:	9d650513          	addi	a0,a0,-1578 # 80020460 <icache>
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	2f8080e7          	jalr	760(ra) # 80000d8a <release>
    itrunc(ip);
    80003a9a:	8526                	mv	a0,s1
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	ee2080e7          	jalr	-286(ra) # 8000397e <itrunc>
    ip->type = 0;
    80003aa4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	cf8080e7          	jalr	-776(ra) # 800037a2 <iupdate>
    ip->valid = 0;
    80003ab2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ab6:	854a                	mv	a0,s2
    80003ab8:	00001097          	auipc	ra,0x1
    80003abc:	aee080e7          	jalr	-1298(ra) # 800045a6 <releasesleep>
    acquire(&icache.lock);
    80003ac0:	0001d517          	auipc	a0,0x1d
    80003ac4:	9a050513          	addi	a0,a0,-1632 # 80020460 <icache>
    80003ac8:	ffffd097          	auipc	ra,0xffffd
    80003acc:	20e080e7          	jalr	526(ra) # 80000cd6 <acquire>
    80003ad0:	b741                	j	80003a50 <iput+0x26>

0000000080003ad2 <iunlockput>:
{
    80003ad2:	1101                	addi	sp,sp,-32
    80003ad4:	ec06                	sd	ra,24(sp)
    80003ad6:	e822                	sd	s0,16(sp)
    80003ad8:	e426                	sd	s1,8(sp)
    80003ada:	1000                	addi	s0,sp,32
    80003adc:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ade:	00000097          	auipc	ra,0x0
    80003ae2:	e54080e7          	jalr	-428(ra) # 80003932 <iunlock>
  iput(ip);
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	f42080e7          	jalr	-190(ra) # 80003a2a <iput>
}
    80003af0:	60e2                	ld	ra,24(sp)
    80003af2:	6442                	ld	s0,16(sp)
    80003af4:	64a2                	ld	s1,8(sp)
    80003af6:	6105                	addi	sp,sp,32
    80003af8:	8082                	ret

0000000080003afa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003afa:	1141                	addi	sp,sp,-16
    80003afc:	e422                	sd	s0,8(sp)
    80003afe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b00:	411c                	lw	a5,0(a0)
    80003b02:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b04:	415c                	lw	a5,4(a0)
    80003b06:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b08:	04451783          	lh	a5,68(a0)
    80003b0c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b10:	04a51783          	lh	a5,74(a0)
    80003b14:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b18:	04c56783          	lwu	a5,76(a0)
    80003b1c:	e99c                	sd	a5,16(a1)
}
    80003b1e:	6422                	ld	s0,8(sp)
    80003b20:	0141                	addi	sp,sp,16
    80003b22:	8082                	ret

0000000080003b24 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b24:	457c                	lw	a5,76(a0)
    80003b26:	0ed7e863          	bltu	a5,a3,80003c16 <readi+0xf2>
{
    80003b2a:	7159                	addi	sp,sp,-112
    80003b2c:	f486                	sd	ra,104(sp)
    80003b2e:	f0a2                	sd	s0,96(sp)
    80003b30:	eca6                	sd	s1,88(sp)
    80003b32:	e8ca                	sd	s2,80(sp)
    80003b34:	e4ce                	sd	s3,72(sp)
    80003b36:	e0d2                	sd	s4,64(sp)
    80003b38:	fc56                	sd	s5,56(sp)
    80003b3a:	f85a                	sd	s6,48(sp)
    80003b3c:	f45e                	sd	s7,40(sp)
    80003b3e:	f062                	sd	s8,32(sp)
    80003b40:	ec66                	sd	s9,24(sp)
    80003b42:	e86a                	sd	s10,16(sp)
    80003b44:	e46e                	sd	s11,8(sp)
    80003b46:	1880                	addi	s0,sp,112
    80003b48:	8baa                	mv	s7,a0
    80003b4a:	8c2e                	mv	s8,a1
    80003b4c:	8a32                	mv	s4,a2
    80003b4e:	84b6                	mv	s1,a3
    80003b50:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b52:	9f35                	addw	a4,a4,a3
    return 0;
    80003b54:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b56:	08d76f63          	bltu	a4,a3,80003bf4 <readi+0xd0>
  if(off + n > ip->size)
    80003b5a:	00e7f463          	bleu	a4,a5,80003b62 <readi+0x3e>
    n = ip->size - off;
    80003b5e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b62:	0a0b0863          	beqz	s6,80003c12 <readi+0xee>
    80003b66:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b68:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b6c:	5cfd                	li	s9,-1
    80003b6e:	a82d                	j	80003ba8 <readi+0x84>
    80003b70:	02099d93          	slli	s11,s3,0x20
    80003b74:	020ddd93          	srli	s11,s11,0x20
    80003b78:	058a8613          	addi	a2,s5,88
    80003b7c:	86ee                	mv	a3,s11
    80003b7e:	963a                	add	a2,a2,a4
    80003b80:	85d2                	mv	a1,s4
    80003b82:	8562                	mv	a0,s8
    80003b84:	fffff097          	auipc	ra,0xfffff
    80003b88:	a10080e7          	jalr	-1520(ra) # 80002594 <either_copyout>
    80003b8c:	05950d63          	beq	a0,s9,80003be6 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b90:	8556                	mv	a0,s5
    80003b92:	fffff097          	auipc	ra,0xfffff
    80003b96:	5d6080e7          	jalr	1494(ra) # 80003168 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b9a:	0129893b          	addw	s2,s3,s2
    80003b9e:	009984bb          	addw	s1,s3,s1
    80003ba2:	9a6e                	add	s4,s4,s11
    80003ba4:	05697663          	bleu	s6,s2,80003bf0 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ba8:	000ba983          	lw	s3,0(s7)
    80003bac:	00a4d59b          	srliw	a1,s1,0xa
    80003bb0:	855e                	mv	a0,s7
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	8ac080e7          	jalr	-1876(ra) # 8000345e <bmap>
    80003bba:	0005059b          	sext.w	a1,a0
    80003bbe:	854e                	mv	a0,s3
    80003bc0:	fffff097          	auipc	ra,0xfffff
    80003bc4:	466080e7          	jalr	1126(ra) # 80003026 <bread>
    80003bc8:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bca:	3ff4f713          	andi	a4,s1,1023
    80003bce:	40ed07bb          	subw	a5,s10,a4
    80003bd2:	412b06bb          	subw	a3,s6,s2
    80003bd6:	89be                	mv	s3,a5
    80003bd8:	2781                	sext.w	a5,a5
    80003bda:	0006861b          	sext.w	a2,a3
    80003bde:	f8f679e3          	bleu	a5,a2,80003b70 <readi+0x4c>
    80003be2:	89b6                	mv	s3,a3
    80003be4:	b771                	j	80003b70 <readi+0x4c>
      brelse(bp);
    80003be6:	8556                	mv	a0,s5
    80003be8:	fffff097          	auipc	ra,0xfffff
    80003bec:	580080e7          	jalr	1408(ra) # 80003168 <brelse>
  }
  return tot;
    80003bf0:	0009051b          	sext.w	a0,s2
}
    80003bf4:	70a6                	ld	ra,104(sp)
    80003bf6:	7406                	ld	s0,96(sp)
    80003bf8:	64e6                	ld	s1,88(sp)
    80003bfa:	6946                	ld	s2,80(sp)
    80003bfc:	69a6                	ld	s3,72(sp)
    80003bfe:	6a06                	ld	s4,64(sp)
    80003c00:	7ae2                	ld	s5,56(sp)
    80003c02:	7b42                	ld	s6,48(sp)
    80003c04:	7ba2                	ld	s7,40(sp)
    80003c06:	7c02                	ld	s8,32(sp)
    80003c08:	6ce2                	ld	s9,24(sp)
    80003c0a:	6d42                	ld	s10,16(sp)
    80003c0c:	6da2                	ld	s11,8(sp)
    80003c0e:	6165                	addi	sp,sp,112
    80003c10:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c12:	895a                	mv	s2,s6
    80003c14:	bff1                	j	80003bf0 <readi+0xcc>
    return 0;
    80003c16:	4501                	li	a0,0
}
    80003c18:	8082                	ret

0000000080003c1a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c1a:	457c                	lw	a5,76(a0)
    80003c1c:	10d7e663          	bltu	a5,a3,80003d28 <writei+0x10e>
{
    80003c20:	7159                	addi	sp,sp,-112
    80003c22:	f486                	sd	ra,104(sp)
    80003c24:	f0a2                	sd	s0,96(sp)
    80003c26:	eca6                	sd	s1,88(sp)
    80003c28:	e8ca                	sd	s2,80(sp)
    80003c2a:	e4ce                	sd	s3,72(sp)
    80003c2c:	e0d2                	sd	s4,64(sp)
    80003c2e:	fc56                	sd	s5,56(sp)
    80003c30:	f85a                	sd	s6,48(sp)
    80003c32:	f45e                	sd	s7,40(sp)
    80003c34:	f062                	sd	s8,32(sp)
    80003c36:	ec66                	sd	s9,24(sp)
    80003c38:	e86a                	sd	s10,16(sp)
    80003c3a:	e46e                	sd	s11,8(sp)
    80003c3c:	1880                	addi	s0,sp,112
    80003c3e:	8baa                	mv	s7,a0
    80003c40:	8c2e                	mv	s8,a1
    80003c42:	8ab2                	mv	s5,a2
    80003c44:	84b6                	mv	s1,a3
    80003c46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c48:	00e687bb          	addw	a5,a3,a4
    80003c4c:	0ed7e063          	bltu	a5,a3,80003d2c <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c50:	00043737          	lui	a4,0x43
    80003c54:	0cf76e63          	bltu	a4,a5,80003d30 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c58:	0a0b0763          	beqz	s6,80003d06 <writei+0xec>
    80003c5c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c5e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c62:	5cfd                	li	s9,-1
    80003c64:	a091                	j	80003ca8 <writei+0x8e>
    80003c66:	02091d93          	slli	s11,s2,0x20
    80003c6a:	020ddd93          	srli	s11,s11,0x20
    80003c6e:	05898513          	addi	a0,s3,88
    80003c72:	86ee                	mv	a3,s11
    80003c74:	8656                	mv	a2,s5
    80003c76:	85e2                	mv	a1,s8
    80003c78:	953a                	add	a0,a0,a4
    80003c7a:	fffff097          	auipc	ra,0xfffff
    80003c7e:	970080e7          	jalr	-1680(ra) # 800025ea <either_copyin>
    80003c82:	07950263          	beq	a0,s9,80003ce6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c86:	854e                	mv	a0,s3
    80003c88:	00000097          	auipc	ra,0x0
    80003c8c:	78a080e7          	jalr	1930(ra) # 80004412 <log_write>
    brelse(bp);
    80003c90:	854e                	mv	a0,s3
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	4d6080e7          	jalr	1238(ra) # 80003168 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c9a:	01490a3b          	addw	s4,s2,s4
    80003c9e:	009904bb          	addw	s1,s2,s1
    80003ca2:	9aee                	add	s5,s5,s11
    80003ca4:	056a7663          	bleu	s6,s4,80003cf0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ca8:	000ba903          	lw	s2,0(s7)
    80003cac:	00a4d59b          	srliw	a1,s1,0xa
    80003cb0:	855e                	mv	a0,s7
    80003cb2:	fffff097          	auipc	ra,0xfffff
    80003cb6:	7ac080e7          	jalr	1964(ra) # 8000345e <bmap>
    80003cba:	0005059b          	sext.w	a1,a0
    80003cbe:	854a                	mv	a0,s2
    80003cc0:	fffff097          	auipc	ra,0xfffff
    80003cc4:	366080e7          	jalr	870(ra) # 80003026 <bread>
    80003cc8:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cca:	3ff4f713          	andi	a4,s1,1023
    80003cce:	40ed07bb          	subw	a5,s10,a4
    80003cd2:	414b06bb          	subw	a3,s6,s4
    80003cd6:	893e                	mv	s2,a5
    80003cd8:	2781                	sext.w	a5,a5
    80003cda:	0006861b          	sext.w	a2,a3
    80003cde:	f8f674e3          	bleu	a5,a2,80003c66 <writei+0x4c>
    80003ce2:	8936                	mv	s2,a3
    80003ce4:	b749                	j	80003c66 <writei+0x4c>
      brelse(bp);
    80003ce6:	854e                	mv	a0,s3
    80003ce8:	fffff097          	auipc	ra,0xfffff
    80003cec:	480080e7          	jalr	1152(ra) # 80003168 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003cf0:	04cba783          	lw	a5,76(s7)
    80003cf4:	0097f463          	bleu	s1,a5,80003cfc <writei+0xe2>
      ip->size = off;
    80003cf8:	049ba623          	sw	s1,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003cfc:	855e                	mv	a0,s7
    80003cfe:	00000097          	auipc	ra,0x0
    80003d02:	aa4080e7          	jalr	-1372(ra) # 800037a2 <iupdate>
  }

  return n;
    80003d06:	000b051b          	sext.w	a0,s6
}
    80003d0a:	70a6                	ld	ra,104(sp)
    80003d0c:	7406                	ld	s0,96(sp)
    80003d0e:	64e6                	ld	s1,88(sp)
    80003d10:	6946                	ld	s2,80(sp)
    80003d12:	69a6                	ld	s3,72(sp)
    80003d14:	6a06                	ld	s4,64(sp)
    80003d16:	7ae2                	ld	s5,56(sp)
    80003d18:	7b42                	ld	s6,48(sp)
    80003d1a:	7ba2                	ld	s7,40(sp)
    80003d1c:	7c02                	ld	s8,32(sp)
    80003d1e:	6ce2                	ld	s9,24(sp)
    80003d20:	6d42                	ld	s10,16(sp)
    80003d22:	6da2                	ld	s11,8(sp)
    80003d24:	6165                	addi	sp,sp,112
    80003d26:	8082                	ret
    return -1;
    80003d28:	557d                	li	a0,-1
}
    80003d2a:	8082                	ret
    return -1;
    80003d2c:	557d                	li	a0,-1
    80003d2e:	bff1                	j	80003d0a <writei+0xf0>
    return -1;
    80003d30:	557d                	li	a0,-1
    80003d32:	bfe1                	j	80003d0a <writei+0xf0>

0000000080003d34 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d34:	1141                	addi	sp,sp,-16
    80003d36:	e406                	sd	ra,8(sp)
    80003d38:	e022                	sd	s0,0(sp)
    80003d3a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d3c:	4639                	li	a2,14
    80003d3e:	ffffd097          	auipc	ra,0xffffd
    80003d42:	17c080e7          	jalr	380(ra) # 80000eba <strncmp>
}
    80003d46:	60a2                	ld	ra,8(sp)
    80003d48:	6402                	ld	s0,0(sp)
    80003d4a:	0141                	addi	sp,sp,16
    80003d4c:	8082                	ret

0000000080003d4e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d4e:	7139                	addi	sp,sp,-64
    80003d50:	fc06                	sd	ra,56(sp)
    80003d52:	f822                	sd	s0,48(sp)
    80003d54:	f426                	sd	s1,40(sp)
    80003d56:	f04a                	sd	s2,32(sp)
    80003d58:	ec4e                	sd	s3,24(sp)
    80003d5a:	e852                	sd	s4,16(sp)
    80003d5c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d5e:	04451703          	lh	a4,68(a0)
    80003d62:	4785                	li	a5,1
    80003d64:	00f71a63          	bne	a4,a5,80003d78 <dirlookup+0x2a>
    80003d68:	892a                	mv	s2,a0
    80003d6a:	89ae                	mv	s3,a1
    80003d6c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d6e:	457c                	lw	a5,76(a0)
    80003d70:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d72:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d74:	e79d                	bnez	a5,80003da2 <dirlookup+0x54>
    80003d76:	a8a5                	j	80003dee <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d78:	00005517          	auipc	a0,0x5
    80003d7c:	87850513          	addi	a0,a0,-1928 # 800085f0 <syscalls+0x1d8>
    80003d80:	ffffd097          	auipc	ra,0xffffd
    80003d84:	892080e7          	jalr	-1902(ra) # 80000612 <panic>
      panic("dirlookup read");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	88050513          	addi	a0,a0,-1920 # 80008608 <syscalls+0x1f0>
    80003d90:	ffffd097          	auipc	ra,0xffffd
    80003d94:	882080e7          	jalr	-1918(ra) # 80000612 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d98:	24c1                	addiw	s1,s1,16
    80003d9a:	04c92783          	lw	a5,76(s2)
    80003d9e:	04f4f763          	bleu	a5,s1,80003dec <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003da2:	4741                	li	a4,16
    80003da4:	86a6                	mv	a3,s1
    80003da6:	fc040613          	addi	a2,s0,-64
    80003daa:	4581                	li	a1,0
    80003dac:	854a                	mv	a0,s2
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	d76080e7          	jalr	-650(ra) # 80003b24 <readi>
    80003db6:	47c1                	li	a5,16
    80003db8:	fcf518e3          	bne	a0,a5,80003d88 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dbc:	fc045783          	lhu	a5,-64(s0)
    80003dc0:	dfe1                	beqz	a5,80003d98 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dc2:	fc240593          	addi	a1,s0,-62
    80003dc6:	854e                	mv	a0,s3
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	f6c080e7          	jalr	-148(ra) # 80003d34 <namecmp>
    80003dd0:	f561                	bnez	a0,80003d98 <dirlookup+0x4a>
      if(poff)
    80003dd2:	000a0463          	beqz	s4,80003dda <dirlookup+0x8c>
        *poff = off;
    80003dd6:	009a2023          	sw	s1,0(s4) # 2000 <_entry-0x7fffe000>
      return iget(dp->dev, inum);
    80003dda:	fc045583          	lhu	a1,-64(s0)
    80003dde:	00092503          	lw	a0,0(s2)
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	756080e7          	jalr	1878(ra) # 80003538 <iget>
    80003dea:	a011                	j	80003dee <dirlookup+0xa0>
  return 0;
    80003dec:	4501                	li	a0,0
}
    80003dee:	70e2                	ld	ra,56(sp)
    80003df0:	7442                	ld	s0,48(sp)
    80003df2:	74a2                	ld	s1,40(sp)
    80003df4:	7902                	ld	s2,32(sp)
    80003df6:	69e2                	ld	s3,24(sp)
    80003df8:	6a42                	ld	s4,16(sp)
    80003dfa:	6121                	addi	sp,sp,64
    80003dfc:	8082                	ret

0000000080003dfe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003dfe:	711d                	addi	sp,sp,-96
    80003e00:	ec86                	sd	ra,88(sp)
    80003e02:	e8a2                	sd	s0,80(sp)
    80003e04:	e4a6                	sd	s1,72(sp)
    80003e06:	e0ca                	sd	s2,64(sp)
    80003e08:	fc4e                	sd	s3,56(sp)
    80003e0a:	f852                	sd	s4,48(sp)
    80003e0c:	f456                	sd	s5,40(sp)
    80003e0e:	f05a                	sd	s6,32(sp)
    80003e10:	ec5e                	sd	s7,24(sp)
    80003e12:	e862                	sd	s8,16(sp)
    80003e14:	e466                	sd	s9,8(sp)
    80003e16:	1080                	addi	s0,sp,96
    80003e18:	84aa                	mv	s1,a0
    80003e1a:	8bae                	mv	s7,a1
    80003e1c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e1e:	00054703          	lbu	a4,0(a0)
    80003e22:	02f00793          	li	a5,47
    80003e26:	02f70363          	beq	a4,a5,80003e4c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e2a:	ffffe097          	auipc	ra,0xffffe
    80003e2e:	cba080e7          	jalr	-838(ra) # 80001ae4 <myproc>
    80003e32:	15053503          	ld	a0,336(a0)
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	9fa080e7          	jalr	-1542(ra) # 80003830 <idup>
    80003e3e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e40:	02f00913          	li	s2,47
  len = path - s;
    80003e44:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e46:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e48:	4c05                	li	s8,1
    80003e4a:	a865                	j	80003f02 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e4c:	4585                	li	a1,1
    80003e4e:	4505                	li	a0,1
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	6e8080e7          	jalr	1768(ra) # 80003538 <iget>
    80003e58:	89aa                	mv	s3,a0
    80003e5a:	b7dd                	j	80003e40 <namex+0x42>
      iunlockput(ip);
    80003e5c:	854e                	mv	a0,s3
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	c74080e7          	jalr	-908(ra) # 80003ad2 <iunlockput>
      return 0;
    80003e66:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e68:	854e                	mv	a0,s3
    80003e6a:	60e6                	ld	ra,88(sp)
    80003e6c:	6446                	ld	s0,80(sp)
    80003e6e:	64a6                	ld	s1,72(sp)
    80003e70:	6906                	ld	s2,64(sp)
    80003e72:	79e2                	ld	s3,56(sp)
    80003e74:	7a42                	ld	s4,48(sp)
    80003e76:	7aa2                	ld	s5,40(sp)
    80003e78:	7b02                	ld	s6,32(sp)
    80003e7a:	6be2                	ld	s7,24(sp)
    80003e7c:	6c42                	ld	s8,16(sp)
    80003e7e:	6ca2                	ld	s9,8(sp)
    80003e80:	6125                	addi	sp,sp,96
    80003e82:	8082                	ret
      iunlock(ip);
    80003e84:	854e                	mv	a0,s3
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	aac080e7          	jalr	-1364(ra) # 80003932 <iunlock>
      return ip;
    80003e8e:	bfe9                	j	80003e68 <namex+0x6a>
      iunlockput(ip);
    80003e90:	854e                	mv	a0,s3
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	c40080e7          	jalr	-960(ra) # 80003ad2 <iunlockput>
      return 0;
    80003e9a:	89d2                	mv	s3,s4
    80003e9c:	b7f1                	j	80003e68 <namex+0x6a>
  len = path - s;
    80003e9e:	40b48633          	sub	a2,s1,a1
    80003ea2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003ea6:	094cd663          	ble	s4,s9,80003f32 <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003eaa:	4639                	li	a2,14
    80003eac:	8556                	mv	a0,s5
    80003eae:	ffffd097          	auipc	ra,0xffffd
    80003eb2:	f90080e7          	jalr	-112(ra) # 80000e3e <memmove>
  while(*path == '/')
    80003eb6:	0004c783          	lbu	a5,0(s1)
    80003eba:	01279763          	bne	a5,s2,80003ec8 <namex+0xca>
    path++;
    80003ebe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ec0:	0004c783          	lbu	a5,0(s1)
    80003ec4:	ff278de3          	beq	a5,s2,80003ebe <namex+0xc0>
    ilock(ip);
    80003ec8:	854e                	mv	a0,s3
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	9a4080e7          	jalr	-1628(ra) # 8000386e <ilock>
    if(ip->type != T_DIR){
    80003ed2:	04499783          	lh	a5,68(s3)
    80003ed6:	f98793e3          	bne	a5,s8,80003e5c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003eda:	000b8563          	beqz	s7,80003ee4 <namex+0xe6>
    80003ede:	0004c783          	lbu	a5,0(s1)
    80003ee2:	d3cd                	beqz	a5,80003e84 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ee4:	865a                	mv	a2,s6
    80003ee6:	85d6                	mv	a1,s5
    80003ee8:	854e                	mv	a0,s3
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	e64080e7          	jalr	-412(ra) # 80003d4e <dirlookup>
    80003ef2:	8a2a                	mv	s4,a0
    80003ef4:	dd51                	beqz	a0,80003e90 <namex+0x92>
    iunlockput(ip);
    80003ef6:	854e                	mv	a0,s3
    80003ef8:	00000097          	auipc	ra,0x0
    80003efc:	bda080e7          	jalr	-1062(ra) # 80003ad2 <iunlockput>
    ip = next;
    80003f00:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f02:	0004c783          	lbu	a5,0(s1)
    80003f06:	05279d63          	bne	a5,s2,80003f60 <namex+0x162>
    path++;
    80003f0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f0c:	0004c783          	lbu	a5,0(s1)
    80003f10:	ff278de3          	beq	a5,s2,80003f0a <namex+0x10c>
  if(*path == 0)
    80003f14:	cf8d                	beqz	a5,80003f4e <namex+0x150>
  while(*path != '/' && *path != 0)
    80003f16:	01278b63          	beq	a5,s2,80003f2c <namex+0x12e>
    80003f1a:	c795                	beqz	a5,80003f46 <namex+0x148>
    path++;
    80003f1c:	85a6                	mv	a1,s1
    path++;
    80003f1e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f20:	0004c783          	lbu	a5,0(s1)
    80003f24:	f7278de3          	beq	a5,s2,80003e9e <namex+0xa0>
    80003f28:	fbfd                	bnez	a5,80003f1e <namex+0x120>
    80003f2a:	bf95                	j	80003e9e <namex+0xa0>
    80003f2c:	85a6                	mv	a1,s1
  len = path - s;
    80003f2e:	8a5a                	mv	s4,s6
    80003f30:	865a                	mv	a2,s6
    memmove(name, s, len);
    80003f32:	2601                	sext.w	a2,a2
    80003f34:	8556                	mv	a0,s5
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	f08080e7          	jalr	-248(ra) # 80000e3e <memmove>
    name[len] = 0;
    80003f3e:	9a56                	add	s4,s4,s5
    80003f40:	000a0023          	sb	zero,0(s4)
    80003f44:	bf8d                	j	80003eb6 <namex+0xb8>
  while(*path != '/' && *path != 0)
    80003f46:	85a6                	mv	a1,s1
  len = path - s;
    80003f48:	8a5a                	mv	s4,s6
    80003f4a:	865a                	mv	a2,s6
    80003f4c:	b7dd                	j	80003f32 <namex+0x134>
  if(nameiparent){
    80003f4e:	f00b8de3          	beqz	s7,80003e68 <namex+0x6a>
    iput(ip);
    80003f52:	854e                	mv	a0,s3
    80003f54:	00000097          	auipc	ra,0x0
    80003f58:	ad6080e7          	jalr	-1322(ra) # 80003a2a <iput>
    return 0;
    80003f5c:	4981                	li	s3,0
    80003f5e:	b729                	j	80003e68 <namex+0x6a>
  if(*path == 0)
    80003f60:	d7fd                	beqz	a5,80003f4e <namex+0x150>
    80003f62:	85a6                	mv	a1,s1
    80003f64:	bf6d                	j	80003f1e <namex+0x120>

0000000080003f66 <dirlink>:
{
    80003f66:	7139                	addi	sp,sp,-64
    80003f68:	fc06                	sd	ra,56(sp)
    80003f6a:	f822                	sd	s0,48(sp)
    80003f6c:	f426                	sd	s1,40(sp)
    80003f6e:	f04a                	sd	s2,32(sp)
    80003f70:	ec4e                	sd	s3,24(sp)
    80003f72:	e852                	sd	s4,16(sp)
    80003f74:	0080                	addi	s0,sp,64
    80003f76:	892a                	mv	s2,a0
    80003f78:	8a2e                	mv	s4,a1
    80003f7a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f7c:	4601                	li	a2,0
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	dd0080e7          	jalr	-560(ra) # 80003d4e <dirlookup>
    80003f86:	e93d                	bnez	a0,80003ffc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f88:	04c92483          	lw	s1,76(s2)
    80003f8c:	c49d                	beqz	s1,80003fba <dirlink+0x54>
    80003f8e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f90:	4741                	li	a4,16
    80003f92:	86a6                	mv	a3,s1
    80003f94:	fc040613          	addi	a2,s0,-64
    80003f98:	4581                	li	a1,0
    80003f9a:	854a                	mv	a0,s2
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	b88080e7          	jalr	-1144(ra) # 80003b24 <readi>
    80003fa4:	47c1                	li	a5,16
    80003fa6:	06f51163          	bne	a0,a5,80004008 <dirlink+0xa2>
    if(de.inum == 0)
    80003faa:	fc045783          	lhu	a5,-64(s0)
    80003fae:	c791                	beqz	a5,80003fba <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb0:	24c1                	addiw	s1,s1,16
    80003fb2:	04c92783          	lw	a5,76(s2)
    80003fb6:	fcf4ede3          	bltu	s1,a5,80003f90 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fba:	4639                	li	a2,14
    80003fbc:	85d2                	mv	a1,s4
    80003fbe:	fc240513          	addi	a0,s0,-62
    80003fc2:	ffffd097          	auipc	ra,0xffffd
    80003fc6:	f48080e7          	jalr	-184(ra) # 80000f0a <strncpy>
  de.inum = inum;
    80003fca:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fce:	4741                	li	a4,16
    80003fd0:	86a6                	mv	a3,s1
    80003fd2:	fc040613          	addi	a2,s0,-64
    80003fd6:	4581                	li	a1,0
    80003fd8:	854a                	mv	a0,s2
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	c40080e7          	jalr	-960(ra) # 80003c1a <writei>
    80003fe2:	4741                	li	a4,16
  return 0;
    80003fe4:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe6:	02e51963          	bne	a0,a4,80004018 <dirlink+0xb2>
}
    80003fea:	853e                	mv	a0,a5
    80003fec:	70e2                	ld	ra,56(sp)
    80003fee:	7442                	ld	s0,48(sp)
    80003ff0:	74a2                	ld	s1,40(sp)
    80003ff2:	7902                	ld	s2,32(sp)
    80003ff4:	69e2                	ld	s3,24(sp)
    80003ff6:	6a42                	ld	s4,16(sp)
    80003ff8:	6121                	addi	sp,sp,64
    80003ffa:	8082                	ret
    iput(ip);
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	a2e080e7          	jalr	-1490(ra) # 80003a2a <iput>
    return -1;
    80004004:	57fd                	li	a5,-1
    80004006:	b7d5                	j	80003fea <dirlink+0x84>
      panic("dirlink read");
    80004008:	00004517          	auipc	a0,0x4
    8000400c:	61050513          	addi	a0,a0,1552 # 80008618 <syscalls+0x200>
    80004010:	ffffc097          	auipc	ra,0xffffc
    80004014:	602080e7          	jalr	1538(ra) # 80000612 <panic>
    panic("dirlink");
    80004018:	00004517          	auipc	a0,0x4
    8000401c:	72050513          	addi	a0,a0,1824 # 80008738 <syscalls+0x320>
    80004020:	ffffc097          	auipc	ra,0xffffc
    80004024:	5f2080e7          	jalr	1522(ra) # 80000612 <panic>

0000000080004028 <namei>:

struct inode*
namei(char *path)
{
    80004028:	1101                	addi	sp,sp,-32
    8000402a:	ec06                	sd	ra,24(sp)
    8000402c:	e822                	sd	s0,16(sp)
    8000402e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004030:	fe040613          	addi	a2,s0,-32
    80004034:	4581                	li	a1,0
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	dc8080e7          	jalr	-568(ra) # 80003dfe <namex>
}
    8000403e:	60e2                	ld	ra,24(sp)
    80004040:	6442                	ld	s0,16(sp)
    80004042:	6105                	addi	sp,sp,32
    80004044:	8082                	ret

0000000080004046 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004046:	1141                	addi	sp,sp,-16
    80004048:	e406                	sd	ra,8(sp)
    8000404a:	e022                	sd	s0,0(sp)
    8000404c:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    8000404e:	862e                	mv	a2,a1
    80004050:	4585                	li	a1,1
    80004052:	00000097          	auipc	ra,0x0
    80004056:	dac080e7          	jalr	-596(ra) # 80003dfe <namex>
}
    8000405a:	60a2                	ld	ra,8(sp)
    8000405c:	6402                	ld	s0,0(sp)
    8000405e:	0141                	addi	sp,sp,16
    80004060:	8082                	ret

0000000080004062 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004062:	1101                	addi	sp,sp,-32
    80004064:	ec06                	sd	ra,24(sp)
    80004066:	e822                	sd	s0,16(sp)
    80004068:	e426                	sd	s1,8(sp)
    8000406a:	e04a                	sd	s2,0(sp)
    8000406c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000406e:	0001e917          	auipc	s2,0x1e
    80004072:	e9a90913          	addi	s2,s2,-358 # 80021f08 <log>
    80004076:	01892583          	lw	a1,24(s2)
    8000407a:	02892503          	lw	a0,40(s2)
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	fa8080e7          	jalr	-88(ra) # 80003026 <bread>
    80004086:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004088:	02c92683          	lw	a3,44(s2)
    8000408c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000408e:	02d05763          	blez	a3,800040bc <write_head+0x5a>
    80004092:	0001e797          	auipc	a5,0x1e
    80004096:	ea678793          	addi	a5,a5,-346 # 80021f38 <log+0x30>
    8000409a:	05c50713          	addi	a4,a0,92
    8000409e:	36fd                	addiw	a3,a3,-1
    800040a0:	1682                	slli	a3,a3,0x20
    800040a2:	9281                	srli	a3,a3,0x20
    800040a4:	068a                	slli	a3,a3,0x2
    800040a6:	0001e617          	auipc	a2,0x1e
    800040aa:	e9660613          	addi	a2,a2,-362 # 80021f3c <log+0x34>
    800040ae:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040b0:	4390                	lw	a2,0(a5)
    800040b2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040b4:	0791                	addi	a5,a5,4
    800040b6:	0711                	addi	a4,a4,4
    800040b8:	fed79ce3          	bne	a5,a3,800040b0 <write_head+0x4e>
  }
  bwrite(buf);
    800040bc:	8526                	mv	a0,s1
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	06c080e7          	jalr	108(ra) # 8000312a <bwrite>
  brelse(buf);
    800040c6:	8526                	mv	a0,s1
    800040c8:	fffff097          	auipc	ra,0xfffff
    800040cc:	0a0080e7          	jalr	160(ra) # 80003168 <brelse>
}
    800040d0:	60e2                	ld	ra,24(sp)
    800040d2:	6442                	ld	s0,16(sp)
    800040d4:	64a2                	ld	s1,8(sp)
    800040d6:	6902                	ld	s2,0(sp)
    800040d8:	6105                	addi	sp,sp,32
    800040da:	8082                	ret

00000000800040dc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040dc:	0001e797          	auipc	a5,0x1e
    800040e0:	e2c78793          	addi	a5,a5,-468 # 80021f08 <log>
    800040e4:	57dc                	lw	a5,44(a5)
    800040e6:	0af05663          	blez	a5,80004192 <install_trans+0xb6>
{
    800040ea:	7139                	addi	sp,sp,-64
    800040ec:	fc06                	sd	ra,56(sp)
    800040ee:	f822                	sd	s0,48(sp)
    800040f0:	f426                	sd	s1,40(sp)
    800040f2:	f04a                	sd	s2,32(sp)
    800040f4:	ec4e                	sd	s3,24(sp)
    800040f6:	e852                	sd	s4,16(sp)
    800040f8:	e456                	sd	s5,8(sp)
    800040fa:	0080                	addi	s0,sp,64
    800040fc:	0001ea17          	auipc	s4,0x1e
    80004100:	e3ca0a13          	addi	s4,s4,-452 # 80021f38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004104:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004106:	0001e917          	auipc	s2,0x1e
    8000410a:	e0290913          	addi	s2,s2,-510 # 80021f08 <log>
    8000410e:	01892583          	lw	a1,24(s2)
    80004112:	013585bb          	addw	a1,a1,s3
    80004116:	2585                	addiw	a1,a1,1
    80004118:	02892503          	lw	a0,40(s2)
    8000411c:	fffff097          	auipc	ra,0xfffff
    80004120:	f0a080e7          	jalr	-246(ra) # 80003026 <bread>
    80004124:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004126:	000a2583          	lw	a1,0(s4)
    8000412a:	02892503          	lw	a0,40(s2)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	ef8080e7          	jalr	-264(ra) # 80003026 <bread>
    80004136:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004138:	40000613          	li	a2,1024
    8000413c:	058a8593          	addi	a1,s5,88
    80004140:	05850513          	addi	a0,a0,88
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	cfa080e7          	jalr	-774(ra) # 80000e3e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	fdc080e7          	jalr	-36(ra) # 8000312a <bwrite>
    bunpin(dbuf);
    80004156:	8526                	mv	a0,s1
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	0ea080e7          	jalr	234(ra) # 80003242 <bunpin>
    brelse(lbuf);
    80004160:	8556                	mv	a0,s5
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	006080e7          	jalr	6(ra) # 80003168 <brelse>
    brelse(dbuf);
    8000416a:	8526                	mv	a0,s1
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	ffc080e7          	jalr	-4(ra) # 80003168 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004174:	2985                	addiw	s3,s3,1
    80004176:	0a11                	addi	s4,s4,4
    80004178:	02c92783          	lw	a5,44(s2)
    8000417c:	f8f9c9e3          	blt	s3,a5,8000410e <install_trans+0x32>
}
    80004180:	70e2                	ld	ra,56(sp)
    80004182:	7442                	ld	s0,48(sp)
    80004184:	74a2                	ld	s1,40(sp)
    80004186:	7902                	ld	s2,32(sp)
    80004188:	69e2                	ld	s3,24(sp)
    8000418a:	6a42                	ld	s4,16(sp)
    8000418c:	6aa2                	ld	s5,8(sp)
    8000418e:	6121                	addi	sp,sp,64
    80004190:	8082                	ret
    80004192:	8082                	ret

0000000080004194 <initlog>:
{
    80004194:	7179                	addi	sp,sp,-48
    80004196:	f406                	sd	ra,40(sp)
    80004198:	f022                	sd	s0,32(sp)
    8000419a:	ec26                	sd	s1,24(sp)
    8000419c:	e84a                	sd	s2,16(sp)
    8000419e:	e44e                	sd	s3,8(sp)
    800041a0:	1800                	addi	s0,sp,48
    800041a2:	892a                	mv	s2,a0
    800041a4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041a6:	0001e497          	auipc	s1,0x1e
    800041aa:	d6248493          	addi	s1,s1,-670 # 80021f08 <log>
    800041ae:	00004597          	auipc	a1,0x4
    800041b2:	47a58593          	addi	a1,a1,1146 # 80008628 <syscalls+0x210>
    800041b6:	8526                	mv	a0,s1
    800041b8:	ffffd097          	auipc	ra,0xffffd
    800041bc:	a8e080e7          	jalr	-1394(ra) # 80000c46 <initlock>
  log.start = sb->logstart;
    800041c0:	0149a583          	lw	a1,20(s3)
    800041c4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041c6:	0109a783          	lw	a5,16(s3)
    800041ca:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041cc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041d0:	854a                	mv	a0,s2
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	e54080e7          	jalr	-428(ra) # 80003026 <bread>
  log.lh.n = lh->n;
    800041da:	4d3c                	lw	a5,88(a0)
    800041dc:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041de:	02f05563          	blez	a5,80004208 <initlog+0x74>
    800041e2:	05c50713          	addi	a4,a0,92
    800041e6:	0001e697          	auipc	a3,0x1e
    800041ea:	d5268693          	addi	a3,a3,-686 # 80021f38 <log+0x30>
    800041ee:	37fd                	addiw	a5,a5,-1
    800041f0:	1782                	slli	a5,a5,0x20
    800041f2:	9381                	srli	a5,a5,0x20
    800041f4:	078a                	slli	a5,a5,0x2
    800041f6:	06050613          	addi	a2,a0,96
    800041fa:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041fc:	4310                	lw	a2,0(a4)
    800041fe:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004200:	0711                	addi	a4,a4,4
    80004202:	0691                	addi	a3,a3,4
    80004204:	fef71ce3          	bne	a4,a5,800041fc <initlog+0x68>
  brelse(buf);
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	f60080e7          	jalr	-160(ra) # 80003168 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004210:	00000097          	auipc	ra,0x0
    80004214:	ecc080e7          	jalr	-308(ra) # 800040dc <install_trans>
  log.lh.n = 0;
    80004218:	0001e797          	auipc	a5,0x1e
    8000421c:	d007ae23          	sw	zero,-740(a5) # 80021f34 <log+0x2c>
  write_head(); // clear the log
    80004220:	00000097          	auipc	ra,0x0
    80004224:	e42080e7          	jalr	-446(ra) # 80004062 <write_head>
}
    80004228:	70a2                	ld	ra,40(sp)
    8000422a:	7402                	ld	s0,32(sp)
    8000422c:	64e2                	ld	s1,24(sp)
    8000422e:	6942                	ld	s2,16(sp)
    80004230:	69a2                	ld	s3,8(sp)
    80004232:	6145                	addi	sp,sp,48
    80004234:	8082                	ret

0000000080004236 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004236:	1101                	addi	sp,sp,-32
    80004238:	ec06                	sd	ra,24(sp)
    8000423a:	e822                	sd	s0,16(sp)
    8000423c:	e426                	sd	s1,8(sp)
    8000423e:	e04a                	sd	s2,0(sp)
    80004240:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004242:	0001e517          	auipc	a0,0x1e
    80004246:	cc650513          	addi	a0,a0,-826 # 80021f08 <log>
    8000424a:	ffffd097          	auipc	ra,0xffffd
    8000424e:	a8c080e7          	jalr	-1396(ra) # 80000cd6 <acquire>
  while(1){
    if(log.committing){
    80004252:	0001e497          	auipc	s1,0x1e
    80004256:	cb648493          	addi	s1,s1,-842 # 80021f08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000425a:	4979                	li	s2,30
    8000425c:	a039                	j	8000426a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000425e:	85a6                	mv	a1,s1
    80004260:	8526                	mv	a0,s1
    80004262:	ffffe097          	auipc	ra,0xffffe
    80004266:	0d0080e7          	jalr	208(ra) # 80002332 <sleep>
    if(log.committing){
    8000426a:	50dc                	lw	a5,36(s1)
    8000426c:	fbed                	bnez	a5,8000425e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000426e:	509c                	lw	a5,32(s1)
    80004270:	0017871b          	addiw	a4,a5,1
    80004274:	0007069b          	sext.w	a3,a4
    80004278:	0027179b          	slliw	a5,a4,0x2
    8000427c:	9fb9                	addw	a5,a5,a4
    8000427e:	0017979b          	slliw	a5,a5,0x1
    80004282:	54d8                	lw	a4,44(s1)
    80004284:	9fb9                	addw	a5,a5,a4
    80004286:	00f95963          	ble	a5,s2,80004298 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000428a:	85a6                	mv	a1,s1
    8000428c:	8526                	mv	a0,s1
    8000428e:	ffffe097          	auipc	ra,0xffffe
    80004292:	0a4080e7          	jalr	164(ra) # 80002332 <sleep>
    80004296:	bfd1                	j	8000426a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004298:	0001e517          	auipc	a0,0x1e
    8000429c:	c7050513          	addi	a0,a0,-912 # 80021f08 <log>
    800042a0:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	ae8080e7          	jalr	-1304(ra) # 80000d8a <release>
      break;
    }
  }
}
    800042aa:	60e2                	ld	ra,24(sp)
    800042ac:	6442                	ld	s0,16(sp)
    800042ae:	64a2                	ld	s1,8(sp)
    800042b0:	6902                	ld	s2,0(sp)
    800042b2:	6105                	addi	sp,sp,32
    800042b4:	8082                	ret

00000000800042b6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042b6:	7139                	addi	sp,sp,-64
    800042b8:	fc06                	sd	ra,56(sp)
    800042ba:	f822                	sd	s0,48(sp)
    800042bc:	f426                	sd	s1,40(sp)
    800042be:	f04a                	sd	s2,32(sp)
    800042c0:	ec4e                	sd	s3,24(sp)
    800042c2:	e852                	sd	s4,16(sp)
    800042c4:	e456                	sd	s5,8(sp)
    800042c6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042c8:	0001e917          	auipc	s2,0x1e
    800042cc:	c4090913          	addi	s2,s2,-960 # 80021f08 <log>
    800042d0:	854a                	mv	a0,s2
    800042d2:	ffffd097          	auipc	ra,0xffffd
    800042d6:	a04080e7          	jalr	-1532(ra) # 80000cd6 <acquire>
  log.outstanding -= 1;
    800042da:	02092783          	lw	a5,32(s2)
    800042de:	37fd                	addiw	a5,a5,-1
    800042e0:	0007849b          	sext.w	s1,a5
    800042e4:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    800042e8:	02492783          	lw	a5,36(s2)
    800042ec:	eba1                	bnez	a5,8000433c <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    800042ee:	ecb9                	bnez	s1,8000434c <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    800042f0:	0001e917          	auipc	s2,0x1e
    800042f4:	c1890913          	addi	s2,s2,-1000 # 80021f08 <log>
    800042f8:	4785                	li	a5,1
    800042fa:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042fe:	854a                	mv	a0,s2
    80004300:	ffffd097          	auipc	ra,0xffffd
    80004304:	a8a080e7          	jalr	-1398(ra) # 80000d8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004308:	02c92783          	lw	a5,44(s2)
    8000430c:	06f04763          	bgtz	a5,8000437a <end_op+0xc4>
    acquire(&log.lock);
    80004310:	0001e497          	auipc	s1,0x1e
    80004314:	bf848493          	addi	s1,s1,-1032 # 80021f08 <log>
    80004318:	8526                	mv	a0,s1
    8000431a:	ffffd097          	auipc	ra,0xffffd
    8000431e:	9bc080e7          	jalr	-1604(ra) # 80000cd6 <acquire>
    log.committing = 0;
    80004322:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004326:	8526                	mv	a0,s1
    80004328:	ffffe097          	auipc	ra,0xffffe
    8000432c:	190080e7          	jalr	400(ra) # 800024b8 <wakeup>
    release(&log.lock);
    80004330:	8526                	mv	a0,s1
    80004332:	ffffd097          	auipc	ra,0xffffd
    80004336:	a58080e7          	jalr	-1448(ra) # 80000d8a <release>
}
    8000433a:	a03d                	j	80004368 <end_op+0xb2>
    panic("log.committing");
    8000433c:	00004517          	auipc	a0,0x4
    80004340:	2f450513          	addi	a0,a0,756 # 80008630 <syscalls+0x218>
    80004344:	ffffc097          	auipc	ra,0xffffc
    80004348:	2ce080e7          	jalr	718(ra) # 80000612 <panic>
    wakeup(&log);
    8000434c:	0001e497          	auipc	s1,0x1e
    80004350:	bbc48493          	addi	s1,s1,-1092 # 80021f08 <log>
    80004354:	8526                	mv	a0,s1
    80004356:	ffffe097          	auipc	ra,0xffffe
    8000435a:	162080e7          	jalr	354(ra) # 800024b8 <wakeup>
  release(&log.lock);
    8000435e:	8526                	mv	a0,s1
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	a2a080e7          	jalr	-1494(ra) # 80000d8a <release>
}
    80004368:	70e2                	ld	ra,56(sp)
    8000436a:	7442                	ld	s0,48(sp)
    8000436c:	74a2                	ld	s1,40(sp)
    8000436e:	7902                	ld	s2,32(sp)
    80004370:	69e2                	ld	s3,24(sp)
    80004372:	6a42                	ld	s4,16(sp)
    80004374:	6aa2                	ld	s5,8(sp)
    80004376:	6121                	addi	sp,sp,64
    80004378:	8082                	ret
    8000437a:	0001ea17          	auipc	s4,0x1e
    8000437e:	bbea0a13          	addi	s4,s4,-1090 # 80021f38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004382:	0001e917          	auipc	s2,0x1e
    80004386:	b8690913          	addi	s2,s2,-1146 # 80021f08 <log>
    8000438a:	01892583          	lw	a1,24(s2)
    8000438e:	9da5                	addw	a1,a1,s1
    80004390:	2585                	addiw	a1,a1,1
    80004392:	02892503          	lw	a0,40(s2)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	c90080e7          	jalr	-880(ra) # 80003026 <bread>
    8000439e:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043a0:	000a2583          	lw	a1,0(s4)
    800043a4:	02892503          	lw	a0,40(s2)
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	c7e080e7          	jalr	-898(ra) # 80003026 <bread>
    800043b0:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    800043b2:	40000613          	li	a2,1024
    800043b6:	05850593          	addi	a1,a0,88
    800043ba:	05898513          	addi	a0,s3,88
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	a80080e7          	jalr	-1408(ra) # 80000e3e <memmove>
    bwrite(to);  // write the log
    800043c6:	854e                	mv	a0,s3
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	d62080e7          	jalr	-670(ra) # 8000312a <bwrite>
    brelse(from);
    800043d0:	8556                	mv	a0,s5
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	d96080e7          	jalr	-618(ra) # 80003168 <brelse>
    brelse(to);
    800043da:	854e                	mv	a0,s3
    800043dc:	fffff097          	auipc	ra,0xfffff
    800043e0:	d8c080e7          	jalr	-628(ra) # 80003168 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e4:	2485                	addiw	s1,s1,1
    800043e6:	0a11                	addi	s4,s4,4
    800043e8:	02c92783          	lw	a5,44(s2)
    800043ec:	f8f4cfe3          	blt	s1,a5,8000438a <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	c72080e7          	jalr	-910(ra) # 80004062 <write_head>
    install_trans(); // Now install writes to home locations
    800043f8:	00000097          	auipc	ra,0x0
    800043fc:	ce4080e7          	jalr	-796(ra) # 800040dc <install_trans>
    log.lh.n = 0;
    80004400:	0001e797          	auipc	a5,0x1e
    80004404:	b207aa23          	sw	zero,-1228(a5) # 80021f34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004408:	00000097          	auipc	ra,0x0
    8000440c:	c5a080e7          	jalr	-934(ra) # 80004062 <write_head>
    80004410:	b701                	j	80004310 <end_op+0x5a>

0000000080004412 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004412:	1101                	addi	sp,sp,-32
    80004414:	ec06                	sd	ra,24(sp)
    80004416:	e822                	sd	s0,16(sp)
    80004418:	e426                	sd	s1,8(sp)
    8000441a:	e04a                	sd	s2,0(sp)
    8000441c:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000441e:	0001e797          	auipc	a5,0x1e
    80004422:	aea78793          	addi	a5,a5,-1302 # 80021f08 <log>
    80004426:	57d8                	lw	a4,44(a5)
    80004428:	47f5                	li	a5,29
    8000442a:	08e7c563          	blt	a5,a4,800044b4 <log_write+0xa2>
    8000442e:	892a                	mv	s2,a0
    80004430:	0001e797          	auipc	a5,0x1e
    80004434:	ad878793          	addi	a5,a5,-1320 # 80021f08 <log>
    80004438:	4fdc                	lw	a5,28(a5)
    8000443a:	37fd                	addiw	a5,a5,-1
    8000443c:	06f75c63          	ble	a5,a4,800044b4 <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004440:	0001e797          	auipc	a5,0x1e
    80004444:	ac878793          	addi	a5,a5,-1336 # 80021f08 <log>
    80004448:	539c                	lw	a5,32(a5)
    8000444a:	06f05d63          	blez	a5,800044c4 <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000444e:	0001e497          	auipc	s1,0x1e
    80004452:	aba48493          	addi	s1,s1,-1350 # 80021f08 <log>
    80004456:	8526                	mv	a0,s1
    80004458:	ffffd097          	auipc	ra,0xffffd
    8000445c:	87e080e7          	jalr	-1922(ra) # 80000cd6 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004460:	54d0                	lw	a2,44(s1)
    80004462:	0ac05063          	blez	a2,80004502 <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004466:	00c92583          	lw	a1,12(s2)
    8000446a:	589c                	lw	a5,48(s1)
    8000446c:	0ab78363          	beq	a5,a1,80004512 <log_write+0x100>
    80004470:	0001e717          	auipc	a4,0x1e
    80004474:	acc70713          	addi	a4,a4,-1332 # 80021f3c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    80004478:	4781                	li	a5,0
    8000447a:	2785                	addiw	a5,a5,1
    8000447c:	04c78c63          	beq	a5,a2,800044d4 <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004480:	4314                	lw	a3,0(a4)
    80004482:	0711                	addi	a4,a4,4
    80004484:	feb69be3          	bne	a3,a1,8000447a <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004488:	07a1                	addi	a5,a5,8
    8000448a:	078a                	slli	a5,a5,0x2
    8000448c:	0001e717          	auipc	a4,0x1e
    80004490:	a7c70713          	addi	a4,a4,-1412 # 80021f08 <log>
    80004494:	97ba                	add	a5,a5,a4
    80004496:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80004498:	0001e517          	auipc	a0,0x1e
    8000449c:	a7050513          	addi	a0,a0,-1424 # 80021f08 <log>
    800044a0:	ffffd097          	auipc	ra,0xffffd
    800044a4:	8ea080e7          	jalr	-1814(ra) # 80000d8a <release>
}
    800044a8:	60e2                	ld	ra,24(sp)
    800044aa:	6442                	ld	s0,16(sp)
    800044ac:	64a2                	ld	s1,8(sp)
    800044ae:	6902                	ld	s2,0(sp)
    800044b0:	6105                	addi	sp,sp,32
    800044b2:	8082                	ret
    panic("too big a transaction");
    800044b4:	00004517          	auipc	a0,0x4
    800044b8:	18c50513          	addi	a0,a0,396 # 80008640 <syscalls+0x228>
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	156080e7          	jalr	342(ra) # 80000612 <panic>
    panic("log_write outside of trans");
    800044c4:	00004517          	auipc	a0,0x4
    800044c8:	19450513          	addi	a0,a0,404 # 80008658 <syscalls+0x240>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	146080e7          	jalr	326(ra) # 80000612 <panic>
  log.lh.block[i] = b->blockno;
    800044d4:	0621                	addi	a2,a2,8
    800044d6:	060a                	slli	a2,a2,0x2
    800044d8:	0001e797          	auipc	a5,0x1e
    800044dc:	a3078793          	addi	a5,a5,-1488 # 80021f08 <log>
    800044e0:	963e                	add	a2,a2,a5
    800044e2:	00c92783          	lw	a5,12(s2)
    800044e6:	ca1c                	sw	a5,16(a2)
    bpin(b);
    800044e8:	854a                	mv	a0,s2
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	d1c080e7          	jalr	-740(ra) # 80003206 <bpin>
    log.lh.n++;
    800044f2:	0001e717          	auipc	a4,0x1e
    800044f6:	a1670713          	addi	a4,a4,-1514 # 80021f08 <log>
    800044fa:	575c                	lw	a5,44(a4)
    800044fc:	2785                	addiw	a5,a5,1
    800044fe:	d75c                	sw	a5,44(a4)
    80004500:	bf61                	j	80004498 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    80004502:	00c92783          	lw	a5,12(s2)
    80004506:	0001e717          	auipc	a4,0x1e
    8000450a:	a2f72923          	sw	a5,-1486(a4) # 80021f38 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    8000450e:	f649                	bnez	a2,80004498 <log_write+0x86>
    80004510:	bfe1                	j	800044e8 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    80004512:	4781                	li	a5,0
    80004514:	bf95                	j	80004488 <log_write+0x76>

0000000080004516 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004516:	1101                	addi	sp,sp,-32
    80004518:	ec06                	sd	ra,24(sp)
    8000451a:	e822                	sd	s0,16(sp)
    8000451c:	e426                	sd	s1,8(sp)
    8000451e:	e04a                	sd	s2,0(sp)
    80004520:	1000                	addi	s0,sp,32
    80004522:	84aa                	mv	s1,a0
    80004524:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004526:	00004597          	auipc	a1,0x4
    8000452a:	15258593          	addi	a1,a1,338 # 80008678 <syscalls+0x260>
    8000452e:	0521                	addi	a0,a0,8
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	716080e7          	jalr	1814(ra) # 80000c46 <initlock>
  lk->name = name;
    80004538:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000453c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004540:	0204a423          	sw	zero,40(s1)
}
    80004544:	60e2                	ld	ra,24(sp)
    80004546:	6442                	ld	s0,16(sp)
    80004548:	64a2                	ld	s1,8(sp)
    8000454a:	6902                	ld	s2,0(sp)
    8000454c:	6105                	addi	sp,sp,32
    8000454e:	8082                	ret

0000000080004550 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004550:	1101                	addi	sp,sp,-32
    80004552:	ec06                	sd	ra,24(sp)
    80004554:	e822                	sd	s0,16(sp)
    80004556:	e426                	sd	s1,8(sp)
    80004558:	e04a                	sd	s2,0(sp)
    8000455a:	1000                	addi	s0,sp,32
    8000455c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000455e:	00850913          	addi	s2,a0,8
    80004562:	854a                	mv	a0,s2
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	772080e7          	jalr	1906(ra) # 80000cd6 <acquire>
  while (lk->locked) {
    8000456c:	409c                	lw	a5,0(s1)
    8000456e:	cb89                	beqz	a5,80004580 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004570:	85ca                	mv	a1,s2
    80004572:	8526                	mv	a0,s1
    80004574:	ffffe097          	auipc	ra,0xffffe
    80004578:	dbe080e7          	jalr	-578(ra) # 80002332 <sleep>
  while (lk->locked) {
    8000457c:	409c                	lw	a5,0(s1)
    8000457e:	fbed                	bnez	a5,80004570 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004580:	4785                	li	a5,1
    80004582:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004584:	ffffd097          	auipc	ra,0xffffd
    80004588:	560080e7          	jalr	1376(ra) # 80001ae4 <myproc>
    8000458c:	5d1c                	lw	a5,56(a0)
    8000458e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004590:	854a                	mv	a0,s2
    80004592:	ffffc097          	auipc	ra,0xffffc
    80004596:	7f8080e7          	jalr	2040(ra) # 80000d8a <release>
}
    8000459a:	60e2                	ld	ra,24(sp)
    8000459c:	6442                	ld	s0,16(sp)
    8000459e:	64a2                	ld	s1,8(sp)
    800045a0:	6902                	ld	s2,0(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret

00000000800045a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045a6:	1101                	addi	sp,sp,-32
    800045a8:	ec06                	sd	ra,24(sp)
    800045aa:	e822                	sd	s0,16(sp)
    800045ac:	e426                	sd	s1,8(sp)
    800045ae:	e04a                	sd	s2,0(sp)
    800045b0:	1000                	addi	s0,sp,32
    800045b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045b4:	00850913          	addi	s2,a0,8
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	71c080e7          	jalr	1820(ra) # 80000cd6 <acquire>
  lk->locked = 0;
    800045c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045c6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045ca:	8526                	mv	a0,s1
    800045cc:	ffffe097          	auipc	ra,0xffffe
    800045d0:	eec080e7          	jalr	-276(ra) # 800024b8 <wakeup>
  release(&lk->lk);
    800045d4:	854a                	mv	a0,s2
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	7b4080e7          	jalr	1972(ra) # 80000d8a <release>
}
    800045de:	60e2                	ld	ra,24(sp)
    800045e0:	6442                	ld	s0,16(sp)
    800045e2:	64a2                	ld	s1,8(sp)
    800045e4:	6902                	ld	s2,0(sp)
    800045e6:	6105                	addi	sp,sp,32
    800045e8:	8082                	ret

00000000800045ea <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045ea:	7179                	addi	sp,sp,-48
    800045ec:	f406                	sd	ra,40(sp)
    800045ee:	f022                	sd	s0,32(sp)
    800045f0:	ec26                	sd	s1,24(sp)
    800045f2:	e84a                	sd	s2,16(sp)
    800045f4:	e44e                	sd	s3,8(sp)
    800045f6:	1800                	addi	s0,sp,48
    800045f8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045fa:	00850913          	addi	s2,a0,8
    800045fe:	854a                	mv	a0,s2
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	6d6080e7          	jalr	1750(ra) # 80000cd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004608:	409c                	lw	a5,0(s1)
    8000460a:	ef99                	bnez	a5,80004628 <holdingsleep+0x3e>
    8000460c:	4481                	li	s1,0
  release(&lk->lk);
    8000460e:	854a                	mv	a0,s2
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	77a080e7          	jalr	1914(ra) # 80000d8a <release>
  return r;
}
    80004618:	8526                	mv	a0,s1
    8000461a:	70a2                	ld	ra,40(sp)
    8000461c:	7402                	ld	s0,32(sp)
    8000461e:	64e2                	ld	s1,24(sp)
    80004620:	6942                	ld	s2,16(sp)
    80004622:	69a2                	ld	s3,8(sp)
    80004624:	6145                	addi	sp,sp,48
    80004626:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004628:	0284a983          	lw	s3,40(s1)
    8000462c:	ffffd097          	auipc	ra,0xffffd
    80004630:	4b8080e7          	jalr	1208(ra) # 80001ae4 <myproc>
    80004634:	5d04                	lw	s1,56(a0)
    80004636:	413484b3          	sub	s1,s1,s3
    8000463a:	0014b493          	seqz	s1,s1
    8000463e:	bfc1                	j	8000460e <holdingsleep+0x24>

0000000080004640 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004640:	1141                	addi	sp,sp,-16
    80004642:	e406                	sd	ra,8(sp)
    80004644:	e022                	sd	s0,0(sp)
    80004646:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004648:	00004597          	auipc	a1,0x4
    8000464c:	04058593          	addi	a1,a1,64 # 80008688 <syscalls+0x270>
    80004650:	0001e517          	auipc	a0,0x1e
    80004654:	a0050513          	addi	a0,a0,-1536 # 80022050 <ftable>
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	5ee080e7          	jalr	1518(ra) # 80000c46 <initlock>
}
    80004660:	60a2                	ld	ra,8(sp)
    80004662:	6402                	ld	s0,0(sp)
    80004664:	0141                	addi	sp,sp,16
    80004666:	8082                	ret

0000000080004668 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004668:	1101                	addi	sp,sp,-32
    8000466a:	ec06                	sd	ra,24(sp)
    8000466c:	e822                	sd	s0,16(sp)
    8000466e:	e426                	sd	s1,8(sp)
    80004670:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004672:	0001e517          	auipc	a0,0x1e
    80004676:	9de50513          	addi	a0,a0,-1570 # 80022050 <ftable>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	65c080e7          	jalr	1628(ra) # 80000cd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    80004682:	0001e797          	auipc	a5,0x1e
    80004686:	9ce78793          	addi	a5,a5,-1586 # 80022050 <ftable>
    8000468a:	4fdc                	lw	a5,28(a5)
    8000468c:	cb8d                	beqz	a5,800046be <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000468e:	0001e497          	auipc	s1,0x1e
    80004692:	a0248493          	addi	s1,s1,-1534 # 80022090 <ftable+0x40>
    80004696:	0001f717          	auipc	a4,0x1f
    8000469a:	97270713          	addi	a4,a4,-1678 # 80023008 <ftable+0xfb8>
    if(f->ref == 0){
    8000469e:	40dc                	lw	a5,4(s1)
    800046a0:	c39d                	beqz	a5,800046c6 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046a2:	02848493          	addi	s1,s1,40
    800046a6:	fee49ce3          	bne	s1,a4,8000469e <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046aa:	0001e517          	auipc	a0,0x1e
    800046ae:	9a650513          	addi	a0,a0,-1626 # 80022050 <ftable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	6d8080e7          	jalr	1752(ra) # 80000d8a <release>
  return 0;
    800046ba:	4481                	li	s1,0
    800046bc:	a839                	j	800046da <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046be:	0001e497          	auipc	s1,0x1e
    800046c2:	9aa48493          	addi	s1,s1,-1622 # 80022068 <ftable+0x18>
      f->ref = 1;
    800046c6:	4785                	li	a5,1
    800046c8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046ca:	0001e517          	auipc	a0,0x1e
    800046ce:	98650513          	addi	a0,a0,-1658 # 80022050 <ftable>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	6b8080e7          	jalr	1720(ra) # 80000d8a <release>
}
    800046da:	8526                	mv	a0,s1
    800046dc:	60e2                	ld	ra,24(sp)
    800046de:	6442                	ld	s0,16(sp)
    800046e0:	64a2                	ld	s1,8(sp)
    800046e2:	6105                	addi	sp,sp,32
    800046e4:	8082                	ret

00000000800046e6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046e6:	1101                	addi	sp,sp,-32
    800046e8:	ec06                	sd	ra,24(sp)
    800046ea:	e822                	sd	s0,16(sp)
    800046ec:	e426                	sd	s1,8(sp)
    800046ee:	1000                	addi	s0,sp,32
    800046f0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046f2:	0001e517          	auipc	a0,0x1e
    800046f6:	95e50513          	addi	a0,a0,-1698 # 80022050 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	5dc080e7          	jalr	1500(ra) # 80000cd6 <acquire>
  if(f->ref < 1)
    80004702:	40dc                	lw	a5,4(s1)
    80004704:	02f05263          	blez	a5,80004728 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004708:	2785                	addiw	a5,a5,1
    8000470a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000470c:	0001e517          	auipc	a0,0x1e
    80004710:	94450513          	addi	a0,a0,-1724 # 80022050 <ftable>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	676080e7          	jalr	1654(ra) # 80000d8a <release>
  return f;
}
    8000471c:	8526                	mv	a0,s1
    8000471e:	60e2                	ld	ra,24(sp)
    80004720:	6442                	ld	s0,16(sp)
    80004722:	64a2                	ld	s1,8(sp)
    80004724:	6105                	addi	sp,sp,32
    80004726:	8082                	ret
    panic("filedup");
    80004728:	00004517          	auipc	a0,0x4
    8000472c:	f6850513          	addi	a0,a0,-152 # 80008690 <syscalls+0x278>
    80004730:	ffffc097          	auipc	ra,0xffffc
    80004734:	ee2080e7          	jalr	-286(ra) # 80000612 <panic>

0000000080004738 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004738:	7139                	addi	sp,sp,-64
    8000473a:	fc06                	sd	ra,56(sp)
    8000473c:	f822                	sd	s0,48(sp)
    8000473e:	f426                	sd	s1,40(sp)
    80004740:	f04a                	sd	s2,32(sp)
    80004742:	ec4e                	sd	s3,24(sp)
    80004744:	e852                	sd	s4,16(sp)
    80004746:	e456                	sd	s5,8(sp)
    80004748:	0080                	addi	s0,sp,64
    8000474a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000474c:	0001e517          	auipc	a0,0x1e
    80004750:	90450513          	addi	a0,a0,-1788 # 80022050 <ftable>
    80004754:	ffffc097          	auipc	ra,0xffffc
    80004758:	582080e7          	jalr	1410(ra) # 80000cd6 <acquire>
  if(f->ref < 1)
    8000475c:	40dc                	lw	a5,4(s1)
    8000475e:	06f05163          	blez	a5,800047c0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004762:	37fd                	addiw	a5,a5,-1
    80004764:	0007871b          	sext.w	a4,a5
    80004768:	c0dc                	sw	a5,4(s1)
    8000476a:	06e04363          	bgtz	a4,800047d0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000476e:	0004a903          	lw	s2,0(s1)
    80004772:	0094ca83          	lbu	s5,9(s1)
    80004776:	0104ba03          	ld	s4,16(s1)
    8000477a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000477e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004782:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004786:	0001e517          	auipc	a0,0x1e
    8000478a:	8ca50513          	addi	a0,a0,-1846 # 80022050 <ftable>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	5fc080e7          	jalr	1532(ra) # 80000d8a <release>

  if(ff.type == FD_PIPE){
    80004796:	4785                	li	a5,1
    80004798:	04f90d63          	beq	s2,a5,800047f2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000479c:	3979                	addiw	s2,s2,-2
    8000479e:	4785                	li	a5,1
    800047a0:	0527e063          	bltu	a5,s2,800047e0 <fileclose+0xa8>
    begin_op();
    800047a4:	00000097          	auipc	ra,0x0
    800047a8:	a92080e7          	jalr	-1390(ra) # 80004236 <begin_op>
    iput(ff.ip);
    800047ac:	854e                	mv	a0,s3
    800047ae:	fffff097          	auipc	ra,0xfffff
    800047b2:	27c080e7          	jalr	636(ra) # 80003a2a <iput>
    end_op();
    800047b6:	00000097          	auipc	ra,0x0
    800047ba:	b00080e7          	jalr	-1280(ra) # 800042b6 <end_op>
    800047be:	a00d                	j	800047e0 <fileclose+0xa8>
    panic("fileclose");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	ed850513          	addi	a0,a0,-296 # 80008698 <syscalls+0x280>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	e4a080e7          	jalr	-438(ra) # 80000612 <panic>
    release(&ftable.lock);
    800047d0:	0001e517          	auipc	a0,0x1e
    800047d4:	88050513          	addi	a0,a0,-1920 # 80022050 <ftable>
    800047d8:	ffffc097          	auipc	ra,0xffffc
    800047dc:	5b2080e7          	jalr	1458(ra) # 80000d8a <release>
  }
}
    800047e0:	70e2                	ld	ra,56(sp)
    800047e2:	7442                	ld	s0,48(sp)
    800047e4:	74a2                	ld	s1,40(sp)
    800047e6:	7902                	ld	s2,32(sp)
    800047e8:	69e2                	ld	s3,24(sp)
    800047ea:	6a42                	ld	s4,16(sp)
    800047ec:	6aa2                	ld	s5,8(sp)
    800047ee:	6121                	addi	sp,sp,64
    800047f0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047f2:	85d6                	mv	a1,s5
    800047f4:	8552                	mv	a0,s4
    800047f6:	00000097          	auipc	ra,0x0
    800047fa:	364080e7          	jalr	868(ra) # 80004b5a <pipeclose>
    800047fe:	b7cd                	j	800047e0 <fileclose+0xa8>

0000000080004800 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004800:	715d                	addi	sp,sp,-80
    80004802:	e486                	sd	ra,72(sp)
    80004804:	e0a2                	sd	s0,64(sp)
    80004806:	fc26                	sd	s1,56(sp)
    80004808:	f84a                	sd	s2,48(sp)
    8000480a:	f44e                	sd	s3,40(sp)
    8000480c:	0880                	addi	s0,sp,80
    8000480e:	84aa                	mv	s1,a0
    80004810:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004812:	ffffd097          	auipc	ra,0xffffd
    80004816:	2d2080e7          	jalr	722(ra) # 80001ae4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000481a:	409c                	lw	a5,0(s1)
    8000481c:	37f9                	addiw	a5,a5,-2
    8000481e:	4705                	li	a4,1
    80004820:	04f76763          	bltu	a4,a5,8000486e <filestat+0x6e>
    80004824:	892a                	mv	s2,a0
    ilock(f->ip);
    80004826:	6c88                	ld	a0,24(s1)
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	046080e7          	jalr	70(ra) # 8000386e <ilock>
    stati(f->ip, &st);
    80004830:	fb840593          	addi	a1,s0,-72
    80004834:	6c88                	ld	a0,24(s1)
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	2c4080e7          	jalr	708(ra) # 80003afa <stati>
    iunlock(f->ip);
    8000483e:	6c88                	ld	a0,24(s1)
    80004840:	fffff097          	auipc	ra,0xfffff
    80004844:	0f2080e7          	jalr	242(ra) # 80003932 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004848:	46e1                	li	a3,24
    8000484a:	fb840613          	addi	a2,s0,-72
    8000484e:	85ce                	mv	a1,s3
    80004850:	05093503          	ld	a0,80(s2)
    80004854:	ffffd097          	auipc	ra,0xffffd
    80004858:	f6c080e7          	jalr	-148(ra) # 800017c0 <copyout>
    8000485c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004860:	60a6                	ld	ra,72(sp)
    80004862:	6406                	ld	s0,64(sp)
    80004864:	74e2                	ld	s1,56(sp)
    80004866:	7942                	ld	s2,48(sp)
    80004868:	79a2                	ld	s3,40(sp)
    8000486a:	6161                	addi	sp,sp,80
    8000486c:	8082                	ret
  return -1;
    8000486e:	557d                	li	a0,-1
    80004870:	bfc5                	j	80004860 <filestat+0x60>

0000000080004872 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004872:	7179                	addi	sp,sp,-48
    80004874:	f406                	sd	ra,40(sp)
    80004876:	f022                	sd	s0,32(sp)
    80004878:	ec26                	sd	s1,24(sp)
    8000487a:	e84a                	sd	s2,16(sp)
    8000487c:	e44e                	sd	s3,8(sp)
    8000487e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004880:	00854783          	lbu	a5,8(a0)
    80004884:	c3d5                	beqz	a5,80004928 <fileread+0xb6>
    80004886:	89b2                	mv	s3,a2
    80004888:	892e                	mv	s2,a1
    8000488a:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000488c:	411c                	lw	a5,0(a0)
    8000488e:	4705                	li	a4,1
    80004890:	04e78963          	beq	a5,a4,800048e2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004894:	470d                	li	a4,3
    80004896:	04e78d63          	beq	a5,a4,800048f0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000489a:	4709                	li	a4,2
    8000489c:	06e79e63          	bne	a5,a4,80004918 <fileread+0xa6>
    ilock(f->ip);
    800048a0:	6d08                	ld	a0,24(a0)
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	fcc080e7          	jalr	-52(ra) # 8000386e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048aa:	874e                	mv	a4,s3
    800048ac:	5094                	lw	a3,32(s1)
    800048ae:	864a                	mv	a2,s2
    800048b0:	4585                	li	a1,1
    800048b2:	6c88                	ld	a0,24(s1)
    800048b4:	fffff097          	auipc	ra,0xfffff
    800048b8:	270080e7          	jalr	624(ra) # 80003b24 <readi>
    800048bc:	892a                	mv	s2,a0
    800048be:	00a05563          	blez	a0,800048c8 <fileread+0x56>
      f->off += r;
    800048c2:	509c                	lw	a5,32(s1)
    800048c4:	9fa9                	addw	a5,a5,a0
    800048c6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048c8:	6c88                	ld	a0,24(s1)
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	068080e7          	jalr	104(ra) # 80003932 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048d2:	854a                	mv	a0,s2
    800048d4:	70a2                	ld	ra,40(sp)
    800048d6:	7402                	ld	s0,32(sp)
    800048d8:	64e2                	ld	s1,24(sp)
    800048da:	6942                	ld	s2,16(sp)
    800048dc:	69a2                	ld	s3,8(sp)
    800048de:	6145                	addi	sp,sp,48
    800048e0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048e2:	6908                	ld	a0,16(a0)
    800048e4:	00000097          	auipc	ra,0x0
    800048e8:	416080e7          	jalr	1046(ra) # 80004cfa <piperead>
    800048ec:	892a                	mv	s2,a0
    800048ee:	b7d5                	j	800048d2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048f0:	02451783          	lh	a5,36(a0)
    800048f4:	03079693          	slli	a3,a5,0x30
    800048f8:	92c1                	srli	a3,a3,0x30
    800048fa:	4725                	li	a4,9
    800048fc:	02d76863          	bltu	a4,a3,8000492c <fileread+0xba>
    80004900:	0792                	slli	a5,a5,0x4
    80004902:	0001d717          	auipc	a4,0x1d
    80004906:	6ae70713          	addi	a4,a4,1710 # 80021fb0 <devsw>
    8000490a:	97ba                	add	a5,a5,a4
    8000490c:	639c                	ld	a5,0(a5)
    8000490e:	c38d                	beqz	a5,80004930 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004910:	4505                	li	a0,1
    80004912:	9782                	jalr	a5
    80004914:	892a                	mv	s2,a0
    80004916:	bf75                	j	800048d2 <fileread+0x60>
    panic("fileread");
    80004918:	00004517          	auipc	a0,0x4
    8000491c:	d9050513          	addi	a0,a0,-624 # 800086a8 <syscalls+0x290>
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	cf2080e7          	jalr	-782(ra) # 80000612 <panic>
    return -1;
    80004928:	597d                	li	s2,-1
    8000492a:	b765                	j	800048d2 <fileread+0x60>
      return -1;
    8000492c:	597d                	li	s2,-1
    8000492e:	b755                	j	800048d2 <fileread+0x60>
    80004930:	597d                	li	s2,-1
    80004932:	b745                	j	800048d2 <fileread+0x60>

0000000080004934 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004934:	00954783          	lbu	a5,9(a0)
    80004938:	12078e63          	beqz	a5,80004a74 <filewrite+0x140>
{
    8000493c:	715d                	addi	sp,sp,-80
    8000493e:	e486                	sd	ra,72(sp)
    80004940:	e0a2                	sd	s0,64(sp)
    80004942:	fc26                	sd	s1,56(sp)
    80004944:	f84a                	sd	s2,48(sp)
    80004946:	f44e                	sd	s3,40(sp)
    80004948:	f052                	sd	s4,32(sp)
    8000494a:	ec56                	sd	s5,24(sp)
    8000494c:	e85a                	sd	s6,16(sp)
    8000494e:	e45e                	sd	s7,8(sp)
    80004950:	e062                	sd	s8,0(sp)
    80004952:	0880                	addi	s0,sp,80
    80004954:	8ab2                	mv	s5,a2
    80004956:	8b2e                	mv	s6,a1
    80004958:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    8000495a:	411c                	lw	a5,0(a0)
    8000495c:	4705                	li	a4,1
    8000495e:	02e78263          	beq	a5,a4,80004982 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004962:	470d                	li	a4,3
    80004964:	02e78563          	beq	a5,a4,8000498e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004968:	4709                	li	a4,2
    8000496a:	0ee79d63          	bne	a5,a4,80004a64 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000496e:	0ec05763          	blez	a2,80004a5c <filewrite+0x128>
    int i = 0;
    80004972:	4901                	li	s2,0
    80004974:	6b85                	lui	s7,0x1
    80004976:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000497a:	6c05                	lui	s8,0x1
    8000497c:	c00c0c1b          	addiw	s8,s8,-1024
    80004980:	a061                	j	80004a08 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    80004982:	6908                	ld	a0,16(a0)
    80004984:	00000097          	auipc	ra,0x0
    80004988:	246080e7          	jalr	582(ra) # 80004bca <pipewrite>
    8000498c:	a065                	j	80004a34 <filewrite+0x100>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000498e:	02451783          	lh	a5,36(a0)
    80004992:	03079693          	slli	a3,a5,0x30
    80004996:	92c1                	srli	a3,a3,0x30
    80004998:	4725                	li	a4,9
    8000499a:	0cd76f63          	bltu	a4,a3,80004a78 <filewrite+0x144>
    8000499e:	0792                	slli	a5,a5,0x4
    800049a0:	0001d717          	auipc	a4,0x1d
    800049a4:	61070713          	addi	a4,a4,1552 # 80021fb0 <devsw>
    800049a8:	97ba                	add	a5,a5,a4
    800049aa:	679c                	ld	a5,8(a5)
    800049ac:	cbe1                	beqz	a5,80004a7c <filewrite+0x148>
    ret = devsw[f->major].write(1, addr, n);
    800049ae:	4505                	li	a0,1
    800049b0:	9782                	jalr	a5
    800049b2:	a049                	j	80004a34 <filewrite+0x100>
    800049b4:	00098a1b          	sext.w	s4,s3
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049b8:	00000097          	auipc	ra,0x0
    800049bc:	87e080e7          	jalr	-1922(ra) # 80004236 <begin_op>
      ilock(f->ip);
    800049c0:	6c88                	ld	a0,24(s1)
    800049c2:	fffff097          	auipc	ra,0xfffff
    800049c6:	eac080e7          	jalr	-340(ra) # 8000386e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049ca:	8752                	mv	a4,s4
    800049cc:	5094                	lw	a3,32(s1)
    800049ce:	01690633          	add	a2,s2,s6
    800049d2:	4585                	li	a1,1
    800049d4:	6c88                	ld	a0,24(s1)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	244080e7          	jalr	580(ra) # 80003c1a <writei>
    800049de:	89aa                	mv	s3,a0
    800049e0:	02a05c63          	blez	a0,80004a18 <filewrite+0xe4>
        f->off += r;
    800049e4:	509c                	lw	a5,32(s1)
    800049e6:	9fa9                	addw	a5,a5,a0
    800049e8:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800049ea:	6c88                	ld	a0,24(s1)
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	f46080e7          	jalr	-186(ra) # 80003932 <iunlock>
      end_op();
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	8c2080e7          	jalr	-1854(ra) # 800042b6 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800049fc:	05499863          	bne	s3,s4,80004a4c <filewrite+0x118>
        panic("short filewrite");
      i += r;
    80004a00:	012a093b          	addw	s2,s4,s2
    while(i < n){
    80004a04:	03595563          	ble	s5,s2,80004a2e <filewrite+0xfa>
      int n1 = n - i;
    80004a08:	412a87bb          	subw	a5,s5,s2
      if(n1 > max)
    80004a0c:	89be                	mv	s3,a5
    80004a0e:	2781                	sext.w	a5,a5
    80004a10:	fafbd2e3          	ble	a5,s7,800049b4 <filewrite+0x80>
    80004a14:	89e2                	mv	s3,s8
    80004a16:	bf79                	j	800049b4 <filewrite+0x80>
      iunlock(f->ip);
    80004a18:	6c88                	ld	a0,24(s1)
    80004a1a:	fffff097          	auipc	ra,0xfffff
    80004a1e:	f18080e7          	jalr	-232(ra) # 80003932 <iunlock>
      end_op();
    80004a22:	00000097          	auipc	ra,0x0
    80004a26:	894080e7          	jalr	-1900(ra) # 800042b6 <end_op>
      if(r < 0)
    80004a2a:	fc09d9e3          	bgez	s3,800049fc <filewrite+0xc8>
    }
    ret = (i == n ? n : -1);
    80004a2e:	8556                	mv	a0,s5
    80004a30:	032a9863          	bne	s5,s2,80004a60 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a34:	60a6                	ld	ra,72(sp)
    80004a36:	6406                	ld	s0,64(sp)
    80004a38:	74e2                	ld	s1,56(sp)
    80004a3a:	7942                	ld	s2,48(sp)
    80004a3c:	79a2                	ld	s3,40(sp)
    80004a3e:	7a02                	ld	s4,32(sp)
    80004a40:	6ae2                	ld	s5,24(sp)
    80004a42:	6b42                	ld	s6,16(sp)
    80004a44:	6ba2                	ld	s7,8(sp)
    80004a46:	6c02                	ld	s8,0(sp)
    80004a48:	6161                	addi	sp,sp,80
    80004a4a:	8082                	ret
        panic("short filewrite");
    80004a4c:	00004517          	auipc	a0,0x4
    80004a50:	c6c50513          	addi	a0,a0,-916 # 800086b8 <syscalls+0x2a0>
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	bbe080e7          	jalr	-1090(ra) # 80000612 <panic>
    int i = 0;
    80004a5c:	4901                	li	s2,0
    80004a5e:	bfc1                	j	80004a2e <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004a60:	557d                	li	a0,-1
    80004a62:	bfc9                	j	80004a34 <filewrite+0x100>
    panic("filewrite");
    80004a64:	00004517          	auipc	a0,0x4
    80004a68:	c6450513          	addi	a0,a0,-924 # 800086c8 <syscalls+0x2b0>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	ba6080e7          	jalr	-1114(ra) # 80000612 <panic>
    return -1;
    80004a74:	557d                	li	a0,-1
}
    80004a76:	8082                	ret
      return -1;
    80004a78:	557d                	li	a0,-1
    80004a7a:	bf6d                	j	80004a34 <filewrite+0x100>
    80004a7c:	557d                	li	a0,-1
    80004a7e:	bf5d                	j	80004a34 <filewrite+0x100>

0000000080004a80 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a80:	7179                	addi	sp,sp,-48
    80004a82:	f406                	sd	ra,40(sp)
    80004a84:	f022                	sd	s0,32(sp)
    80004a86:	ec26                	sd	s1,24(sp)
    80004a88:	e84a                	sd	s2,16(sp)
    80004a8a:	e44e                	sd	s3,8(sp)
    80004a8c:	e052                	sd	s4,0(sp)
    80004a8e:	1800                	addi	s0,sp,48
    80004a90:	84aa                	mv	s1,a0
    80004a92:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a94:	0005b023          	sd	zero,0(a1)
    80004a98:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a9c:	00000097          	auipc	ra,0x0
    80004aa0:	bcc080e7          	jalr	-1076(ra) # 80004668 <filealloc>
    80004aa4:	e088                	sd	a0,0(s1)
    80004aa6:	c551                	beqz	a0,80004b32 <pipealloc+0xb2>
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	bc0080e7          	jalr	-1088(ra) # 80004668 <filealloc>
    80004ab0:	00a93023          	sd	a0,0(s2)
    80004ab4:	c92d                	beqz	a0,80004b26 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ab6:	ffffc097          	auipc	ra,0xffffc
    80004aba:	130080e7          	jalr	304(ra) # 80000be6 <kalloc>
    80004abe:	89aa                	mv	s3,a0
    80004ac0:	c125                	beqz	a0,80004b20 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ac2:	4a05                	li	s4,1
    80004ac4:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80004ac8:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80004acc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ad0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ad4:	00004597          	auipc	a1,0x4
    80004ad8:	c0458593          	addi	a1,a1,-1020 # 800086d8 <syscalls+0x2c0>
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	16a080e7          	jalr	362(ra) # 80000c46 <initlock>
  (*f0)->type = FD_PIPE;
    80004ae4:	609c                	ld	a5,0(s1)
    80004ae6:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80004aea:	609c                	ld	a5,0(s1)
    80004aec:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80004af0:	609c                	ld	a5,0(s1)
    80004af2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004af6:	609c                	ld	a5,0(s1)
    80004af8:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80004afc:	00093783          	ld	a5,0(s2)
    80004b00:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80004b04:	00093783          	ld	a5,0(s2)
    80004b08:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b0c:	00093783          	ld	a5,0(s2)
    80004b10:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80004b14:	00093783          	ld	a5,0(s2)
    80004b18:	0137b823          	sd	s3,16(a5)
  return 0;
    80004b1c:	4501                	li	a0,0
    80004b1e:	a025                	j	80004b46 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b20:	6088                	ld	a0,0(s1)
    80004b22:	e501                	bnez	a0,80004b2a <pipealloc+0xaa>
    80004b24:	a039                	j	80004b32 <pipealloc+0xb2>
    80004b26:	6088                	ld	a0,0(s1)
    80004b28:	c51d                	beqz	a0,80004b56 <pipealloc+0xd6>
    fileclose(*f0);
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	c0e080e7          	jalr	-1010(ra) # 80004738 <fileclose>
  if(*f1)
    80004b32:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80004b36:	557d                	li	a0,-1
  if(*f1)
    80004b38:	c799                	beqz	a5,80004b46 <pipealloc+0xc6>
    fileclose(*f1);
    80004b3a:	853e                	mv	a0,a5
    80004b3c:	00000097          	auipc	ra,0x0
    80004b40:	bfc080e7          	jalr	-1028(ra) # 80004738 <fileclose>
  return -1;
    80004b44:	557d                	li	a0,-1
}
    80004b46:	70a2                	ld	ra,40(sp)
    80004b48:	7402                	ld	s0,32(sp)
    80004b4a:	64e2                	ld	s1,24(sp)
    80004b4c:	6942                	ld	s2,16(sp)
    80004b4e:	69a2                	ld	s3,8(sp)
    80004b50:	6a02                	ld	s4,0(sp)
    80004b52:	6145                	addi	sp,sp,48
    80004b54:	8082                	ret
  return -1;
    80004b56:	557d                	li	a0,-1
    80004b58:	b7fd                	j	80004b46 <pipealloc+0xc6>

0000000080004b5a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b5a:	1101                	addi	sp,sp,-32
    80004b5c:	ec06                	sd	ra,24(sp)
    80004b5e:	e822                	sd	s0,16(sp)
    80004b60:	e426                	sd	s1,8(sp)
    80004b62:	e04a                	sd	s2,0(sp)
    80004b64:	1000                	addi	s0,sp,32
    80004b66:	84aa                	mv	s1,a0
    80004b68:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b6a:	ffffc097          	auipc	ra,0xffffc
    80004b6e:	16c080e7          	jalr	364(ra) # 80000cd6 <acquire>
  if(writable){
    80004b72:	02090d63          	beqz	s2,80004bac <pipeclose+0x52>
    pi->writeopen = 0;
    80004b76:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b7a:	21848513          	addi	a0,s1,536
    80004b7e:	ffffe097          	auipc	ra,0xffffe
    80004b82:	93a080e7          	jalr	-1734(ra) # 800024b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b86:	2204b783          	ld	a5,544(s1)
    80004b8a:	eb95                	bnez	a5,80004bbe <pipeclose+0x64>
    release(&pi->lock);
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	1fc080e7          	jalr	508(ra) # 80000d8a <release>
    kfree((char*)pi);
    80004b96:	8526                	mv	a0,s1
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	f4e080e7          	jalr	-178(ra) # 80000ae6 <kfree>
  } else
    release(&pi->lock);
}
    80004ba0:	60e2                	ld	ra,24(sp)
    80004ba2:	6442                	ld	s0,16(sp)
    80004ba4:	64a2                	ld	s1,8(sp)
    80004ba6:	6902                	ld	s2,0(sp)
    80004ba8:	6105                	addi	sp,sp,32
    80004baa:	8082                	ret
    pi->readopen = 0;
    80004bac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bb0:	21c48513          	addi	a0,s1,540
    80004bb4:	ffffe097          	auipc	ra,0xffffe
    80004bb8:	904080e7          	jalr	-1788(ra) # 800024b8 <wakeup>
    80004bbc:	b7e9                	j	80004b86 <pipeclose+0x2c>
    release(&pi->lock);
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	1ca080e7          	jalr	458(ra) # 80000d8a <release>
}
    80004bc8:	bfe1                	j	80004ba0 <pipeclose+0x46>

0000000080004bca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bca:	7119                	addi	sp,sp,-128
    80004bcc:	fc86                	sd	ra,120(sp)
    80004bce:	f8a2                	sd	s0,112(sp)
    80004bd0:	f4a6                	sd	s1,104(sp)
    80004bd2:	f0ca                	sd	s2,96(sp)
    80004bd4:	ecce                	sd	s3,88(sp)
    80004bd6:	e8d2                	sd	s4,80(sp)
    80004bd8:	e4d6                	sd	s5,72(sp)
    80004bda:	e0da                	sd	s6,64(sp)
    80004bdc:	fc5e                	sd	s7,56(sp)
    80004bde:	f862                	sd	s8,48(sp)
    80004be0:	f466                	sd	s9,40(sp)
    80004be2:	f06a                	sd	s10,32(sp)
    80004be4:	ec6e                	sd	s11,24(sp)
    80004be6:	0100                	addi	s0,sp,128
    80004be8:	84aa                	mv	s1,a0
    80004bea:	8d2e                	mv	s10,a1
    80004bec:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004bee:	ffffd097          	auipc	ra,0xffffd
    80004bf2:	ef6080e7          	jalr	-266(ra) # 80001ae4 <myproc>
    80004bf6:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	0dc080e7          	jalr	220(ra) # 80000cd6 <acquire>
  for(i = 0; i < n; i++){
    80004c02:	0d605f63          	blez	s6,80004ce0 <pipewrite+0x116>
    80004c06:	89a6                	mv	s3,s1
    80004c08:	3b7d                	addiw	s6,s6,-1
    80004c0a:	1b02                	slli	s6,s6,0x20
    80004c0c:	020b5b13          	srli	s6,s6,0x20
    80004c10:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004c12:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c16:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c1a:	5dfd                	li	s11,-1
    80004c1c:	000b8c9b          	sext.w	s9,s7
    80004c20:	8c66                	mv	s8,s9
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c22:	2184a783          	lw	a5,536(s1)
    80004c26:	21c4a703          	lw	a4,540(s1)
    80004c2a:	2007879b          	addiw	a5,a5,512
    80004c2e:	06f71763          	bne	a4,a5,80004c9c <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c32:	2204a783          	lw	a5,544(s1)
    80004c36:	cf8d                	beqz	a5,80004c70 <pipewrite+0xa6>
    80004c38:	03092783          	lw	a5,48(s2)
    80004c3c:	eb95                	bnez	a5,80004c70 <pipewrite+0xa6>
      wakeup(&pi->nread);
    80004c3e:	8556                	mv	a0,s5
    80004c40:	ffffe097          	auipc	ra,0xffffe
    80004c44:	878080e7          	jalr	-1928(ra) # 800024b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c48:	85ce                	mv	a1,s3
    80004c4a:	8552                	mv	a0,s4
    80004c4c:	ffffd097          	auipc	ra,0xffffd
    80004c50:	6e6080e7          	jalr	1766(ra) # 80002332 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004c54:	2184a783          	lw	a5,536(s1)
    80004c58:	21c4a703          	lw	a4,540(s1)
    80004c5c:	2007879b          	addiw	a5,a5,512
    80004c60:	02f71e63          	bne	a4,a5,80004c9c <pipewrite+0xd2>
      if(pi->readopen == 0 || pr->killed){
    80004c64:	2204a783          	lw	a5,544(s1)
    80004c68:	c781                	beqz	a5,80004c70 <pipewrite+0xa6>
    80004c6a:	03092783          	lw	a5,48(s2)
    80004c6e:	dbe1                	beqz	a5,80004c3e <pipewrite+0x74>
        release(&pi->lock);
    80004c70:	8526                	mv	a0,s1
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	118080e7          	jalr	280(ra) # 80000d8a <release>
        return -1;
    80004c7a:	5c7d                	li	s8,-1
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004c7c:	8562                	mv	a0,s8
    80004c7e:	70e6                	ld	ra,120(sp)
    80004c80:	7446                	ld	s0,112(sp)
    80004c82:	74a6                	ld	s1,104(sp)
    80004c84:	7906                	ld	s2,96(sp)
    80004c86:	69e6                	ld	s3,88(sp)
    80004c88:	6a46                	ld	s4,80(sp)
    80004c8a:	6aa6                	ld	s5,72(sp)
    80004c8c:	6b06                	ld	s6,64(sp)
    80004c8e:	7be2                	ld	s7,56(sp)
    80004c90:	7c42                	ld	s8,48(sp)
    80004c92:	7ca2                	ld	s9,40(sp)
    80004c94:	7d02                	ld	s10,32(sp)
    80004c96:	6de2                	ld	s11,24(sp)
    80004c98:	6109                	addi	sp,sp,128
    80004c9a:	8082                	ret
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c9c:	4685                	li	a3,1
    80004c9e:	01ab8633          	add	a2,s7,s10
    80004ca2:	f8f40593          	addi	a1,s0,-113
    80004ca6:	05093503          	ld	a0,80(s2)
    80004caa:	ffffd097          	auipc	ra,0xffffd
    80004cae:	ba2080e7          	jalr	-1118(ra) # 8000184c <copyin>
    80004cb2:	03b50863          	beq	a0,s11,80004ce2 <pipewrite+0x118>
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cb6:	21c4a783          	lw	a5,540(s1)
    80004cba:	0017871b          	addiw	a4,a5,1
    80004cbe:	20e4ae23          	sw	a4,540(s1)
    80004cc2:	1ff7f793          	andi	a5,a5,511
    80004cc6:	97a6                	add	a5,a5,s1
    80004cc8:	f8f44703          	lbu	a4,-113(s0)
    80004ccc:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004cd0:	001c8c1b          	addiw	s8,s9,1
    80004cd4:	001b8793          	addi	a5,s7,1
    80004cd8:	016b8563          	beq	s7,s6,80004ce2 <pipewrite+0x118>
    80004cdc:	8bbe                	mv	s7,a5
    80004cde:	bf3d                	j	80004c1c <pipewrite+0x52>
    80004ce0:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004ce2:	21848513          	addi	a0,s1,536
    80004ce6:	ffffd097          	auipc	ra,0xffffd
    80004cea:	7d2080e7          	jalr	2002(ra) # 800024b8 <wakeup>
  release(&pi->lock);
    80004cee:	8526                	mv	a0,s1
    80004cf0:	ffffc097          	auipc	ra,0xffffc
    80004cf4:	09a080e7          	jalr	154(ra) # 80000d8a <release>
  return i;
    80004cf8:	b751                	j	80004c7c <pipewrite+0xb2>

0000000080004cfa <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cfa:	715d                	addi	sp,sp,-80
    80004cfc:	e486                	sd	ra,72(sp)
    80004cfe:	e0a2                	sd	s0,64(sp)
    80004d00:	fc26                	sd	s1,56(sp)
    80004d02:	f84a                	sd	s2,48(sp)
    80004d04:	f44e                	sd	s3,40(sp)
    80004d06:	f052                	sd	s4,32(sp)
    80004d08:	ec56                	sd	s5,24(sp)
    80004d0a:	e85a                	sd	s6,16(sp)
    80004d0c:	0880                	addi	s0,sp,80
    80004d0e:	84aa                	mv	s1,a0
    80004d10:	89ae                	mv	s3,a1
    80004d12:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d14:	ffffd097          	auipc	ra,0xffffd
    80004d18:	dd0080e7          	jalr	-560(ra) # 80001ae4 <myproc>
    80004d1c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d1e:	8526                	mv	a0,s1
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	fb6080e7          	jalr	-74(ra) # 80000cd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d28:	2184a703          	lw	a4,536(s1)
    80004d2c:	21c4a783          	lw	a5,540(s1)
    80004d30:	06f71b63          	bne	a4,a5,80004da6 <piperead+0xac>
    80004d34:	8926                	mv	s2,s1
    80004d36:	2244a783          	lw	a5,548(s1)
    80004d3a:	cf9d                	beqz	a5,80004d78 <piperead+0x7e>
    if(pr->killed){
    80004d3c:	030a2783          	lw	a5,48(s4)
    80004d40:	e78d                	bnez	a5,80004d6a <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d42:	21848b13          	addi	s6,s1,536
    80004d46:	85ca                	mv	a1,s2
    80004d48:	855a                	mv	a0,s6
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	5e8080e7          	jalr	1512(ra) # 80002332 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d52:	2184a703          	lw	a4,536(s1)
    80004d56:	21c4a783          	lw	a5,540(s1)
    80004d5a:	04f71663          	bne	a4,a5,80004da6 <piperead+0xac>
    80004d5e:	2244a783          	lw	a5,548(s1)
    80004d62:	cb99                	beqz	a5,80004d78 <piperead+0x7e>
    if(pr->killed){
    80004d64:	030a2783          	lw	a5,48(s4)
    80004d68:	dff9                	beqz	a5,80004d46 <piperead+0x4c>
      release(&pi->lock);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	01e080e7          	jalr	30(ra) # 80000d8a <release>
      return -1;
    80004d74:	597d                	li	s2,-1
    80004d76:	a829                	j	80004d90 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    80004d78:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d7a:	21c48513          	addi	a0,s1,540
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	73a080e7          	jalr	1850(ra) # 800024b8 <wakeup>
  release(&pi->lock);
    80004d86:	8526                	mv	a0,s1
    80004d88:	ffffc097          	auipc	ra,0xffffc
    80004d8c:	002080e7          	jalr	2(ra) # 80000d8a <release>
  return i;
}
    80004d90:	854a                	mv	a0,s2
    80004d92:	60a6                	ld	ra,72(sp)
    80004d94:	6406                	ld	s0,64(sp)
    80004d96:	74e2                	ld	s1,56(sp)
    80004d98:	7942                	ld	s2,48(sp)
    80004d9a:	79a2                	ld	s3,40(sp)
    80004d9c:	7a02                	ld	s4,32(sp)
    80004d9e:	6ae2                	ld	s5,24(sp)
    80004da0:	6b42                	ld	s6,16(sp)
    80004da2:	6161                	addi	sp,sp,80
    80004da4:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004da6:	4901                	li	s2,0
    80004da8:	fd5059e3          	blez	s5,80004d7a <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004dac:	2184a783          	lw	a5,536(s1)
    80004db0:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db2:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004db4:	0017871b          	addiw	a4,a5,1
    80004db8:	20e4ac23          	sw	a4,536(s1)
    80004dbc:	1ff7f793          	andi	a5,a5,511
    80004dc0:	97a6                	add	a5,a5,s1
    80004dc2:	0187c783          	lbu	a5,24(a5)
    80004dc6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dca:	4685                	li	a3,1
    80004dcc:	fbf40613          	addi	a2,s0,-65
    80004dd0:	85ce                	mv	a1,s3
    80004dd2:	050a3503          	ld	a0,80(s4)
    80004dd6:	ffffd097          	auipc	ra,0xffffd
    80004dda:	9ea080e7          	jalr	-1558(ra) # 800017c0 <copyout>
    80004dde:	f9650ee3          	beq	a0,s6,80004d7a <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004de2:	2905                	addiw	s2,s2,1
    80004de4:	f92a8be3          	beq	s5,s2,80004d7a <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004de8:	2184a783          	lw	a5,536(s1)
    80004dec:	0985                	addi	s3,s3,1
    80004dee:	21c4a703          	lw	a4,540(s1)
    80004df2:	fcf711e3          	bne	a4,a5,80004db4 <piperead+0xba>
    80004df6:	b751                	j	80004d7a <piperead+0x80>

0000000080004df8 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004df8:	de010113          	addi	sp,sp,-544
    80004dfc:	20113c23          	sd	ra,536(sp)
    80004e00:	20813823          	sd	s0,528(sp)
    80004e04:	20913423          	sd	s1,520(sp)
    80004e08:	21213023          	sd	s2,512(sp)
    80004e0c:	ffce                	sd	s3,504(sp)
    80004e0e:	fbd2                	sd	s4,496(sp)
    80004e10:	f7d6                	sd	s5,488(sp)
    80004e12:	f3da                	sd	s6,480(sp)
    80004e14:	efde                	sd	s7,472(sp)
    80004e16:	ebe2                	sd	s8,464(sp)
    80004e18:	e7e6                	sd	s9,456(sp)
    80004e1a:	e3ea                	sd	s10,448(sp)
    80004e1c:	ff6e                	sd	s11,440(sp)
    80004e1e:	1400                	addi	s0,sp,544
    80004e20:	892a                	mv	s2,a0
    80004e22:	dea43823          	sd	a0,-528(s0)
    80004e26:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	cba080e7          	jalr	-838(ra) # 80001ae4 <myproc>
    80004e32:	84aa                	mv	s1,a0

  begin_op();
    80004e34:	fffff097          	auipc	ra,0xfffff
    80004e38:	402080e7          	jalr	1026(ra) # 80004236 <begin_op>

  if((ip = namei(path)) == 0){
    80004e3c:	854a                	mv	a0,s2
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	1ea080e7          	jalr	490(ra) # 80004028 <namei>
    80004e46:	c93d                	beqz	a0,80004ebc <exec+0xc4>
    80004e48:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	a24080e7          	jalr	-1500(ra) # 8000386e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e52:	04000713          	li	a4,64
    80004e56:	4681                	li	a3,0
    80004e58:	e4840613          	addi	a2,s0,-440
    80004e5c:	4581                	li	a1,0
    80004e5e:	854a                	mv	a0,s2
    80004e60:	fffff097          	auipc	ra,0xfffff
    80004e64:	cc4080e7          	jalr	-828(ra) # 80003b24 <readi>
    80004e68:	04000793          	li	a5,64
    80004e6c:	00f51a63          	bne	a0,a5,80004e80 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e70:	e4842703          	lw	a4,-440(s0)
    80004e74:	464c47b7          	lui	a5,0x464c4
    80004e78:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e7c:	04f70663          	beq	a4,a5,80004ec8 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e80:	854a                	mv	a0,s2
    80004e82:	fffff097          	auipc	ra,0xfffff
    80004e86:	c50080e7          	jalr	-944(ra) # 80003ad2 <iunlockput>
    end_op();
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	42c080e7          	jalr	1068(ra) # 800042b6 <end_op>
  }
  return -1;
    80004e92:	557d                	li	a0,-1
}
    80004e94:	21813083          	ld	ra,536(sp)
    80004e98:	21013403          	ld	s0,528(sp)
    80004e9c:	20813483          	ld	s1,520(sp)
    80004ea0:	20013903          	ld	s2,512(sp)
    80004ea4:	79fe                	ld	s3,504(sp)
    80004ea6:	7a5e                	ld	s4,496(sp)
    80004ea8:	7abe                	ld	s5,488(sp)
    80004eaa:	7b1e                	ld	s6,480(sp)
    80004eac:	6bfe                	ld	s7,472(sp)
    80004eae:	6c5e                	ld	s8,464(sp)
    80004eb0:	6cbe                	ld	s9,456(sp)
    80004eb2:	6d1e                	ld	s10,448(sp)
    80004eb4:	7dfa                	ld	s11,440(sp)
    80004eb6:	22010113          	addi	sp,sp,544
    80004eba:	8082                	ret
    end_op();
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	3fa080e7          	jalr	1018(ra) # 800042b6 <end_op>
    return -1;
    80004ec4:	557d                	li	a0,-1
    80004ec6:	b7f9                	j	80004e94 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ec8:	8526                	mv	a0,s1
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	ce0080e7          	jalr	-800(ra) # 80001baa <proc_pagetable>
    80004ed2:	e0a43423          	sd	a0,-504(s0)
    80004ed6:	d54d                	beqz	a0,80004e80 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ed8:	e6842983          	lw	s3,-408(s0)
    80004edc:	e8045783          	lhu	a5,-384(s0)
    80004ee0:	c7ad                	beqz	a5,80004f4a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004ee2:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ee4:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004ee6:	6c05                	lui	s8,0x1
    80004ee8:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004eec:	def43423          	sd	a5,-536(s0)
    80004ef0:	7cfd                	lui	s9,0xfffff
    80004ef2:	ac1d                	j	80005128 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ef4:	00003517          	auipc	a0,0x3
    80004ef8:	7ec50513          	addi	a0,a0,2028 # 800086e0 <syscalls+0x2c8>
    80004efc:	ffffb097          	auipc	ra,0xffffb
    80004f00:	716080e7          	jalr	1814(ra) # 80000612 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f04:	8756                	mv	a4,s5
    80004f06:	009d86bb          	addw	a3,s11,s1
    80004f0a:	4581                	li	a1,0
    80004f0c:	854a                	mv	a0,s2
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	c16080e7          	jalr	-1002(ra) # 80003b24 <readi>
    80004f16:	2501                	sext.w	a0,a0
    80004f18:	1aaa9e63          	bne	s5,a0,800050d4 <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004f1c:	6785                	lui	a5,0x1
    80004f1e:	9cbd                	addw	s1,s1,a5
    80004f20:	014c8a3b          	addw	s4,s9,s4
    80004f24:	1f74f963          	bleu	s7,s1,80005116 <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004f28:	02049593          	slli	a1,s1,0x20
    80004f2c:	9181                	srli	a1,a1,0x20
    80004f2e:	95ea                	add	a1,a1,s10
    80004f30:	e0843503          	ld	a0,-504(s0)
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	254080e7          	jalr	596(ra) # 80001188 <walkaddr>
    80004f3c:	862a                	mv	a2,a0
    if(pa == 0)
    80004f3e:	d95d                	beqz	a0,80004ef4 <exec+0xfc>
      n = PGSIZE;
    80004f40:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    80004f42:	fd8a71e3          	bleu	s8,s4,80004f04 <exec+0x10c>
      n = sz - i;
    80004f46:	8ad2                	mv	s5,s4
    80004f48:	bf75                	j	80004f04 <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004f4a:	4481                	li	s1,0
  iunlockput(ip);
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	b84080e7          	jalr	-1148(ra) # 80003ad2 <iunlockput>
  end_op();
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	360080e7          	jalr	864(ra) # 800042b6 <end_op>
  p = myproc();
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	b86080e7          	jalr	-1146(ra) # 80001ae4 <myproc>
    80004f66:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f68:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f6c:	6785                	lui	a5,0x1
    80004f6e:	17fd                	addi	a5,a5,-1
    80004f70:	94be                	add	s1,s1,a5
    80004f72:	77fd                	lui	a5,0xfffff
    80004f74:	8fe5                	and	a5,a5,s1
    80004f76:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f7a:	6609                	lui	a2,0x2
    80004f7c:	963e                	add	a2,a2,a5
    80004f7e:	85be                	mv	a1,a5
    80004f80:	e0843483          	ld	s1,-504(s0)
    80004f84:	8526                	mv	a0,s1
    80004f86:	ffffc097          	auipc	ra,0xffffc
    80004f8a:	5ea080e7          	jalr	1514(ra) # 80001570 <uvmalloc>
    80004f8e:	8b2a                	mv	s6,a0
  ip = 0;
    80004f90:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f92:	14050163          	beqz	a0,800050d4 <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f96:	75f9                	lui	a1,0xffffe
    80004f98:	95aa                	add	a1,a1,a0
    80004f9a:	8526                	mv	a0,s1
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	7f2080e7          	jalr	2034(ra) # 8000178e <uvmclear>
  stackbase = sp - PGSIZE;
    80004fa4:	7bfd                	lui	s7,0xfffff
    80004fa6:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fa8:	df843783          	ld	a5,-520(s0)
    80004fac:	6388                	ld	a0,0(a5)
    80004fae:	c925                	beqz	a0,8000501e <exec+0x226>
    80004fb0:	e8840993          	addi	s3,s0,-376
    80004fb4:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004fb8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fba:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	fc0080e7          	jalr	-64(ra) # 80000f7c <strlen>
    80004fc4:	2505                	addiw	a0,a0,1
    80004fc6:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fca:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004fce:	13796863          	bltu	s2,s7,800050fe <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd2:	df843c83          	ld	s9,-520(s0)
    80004fd6:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd8000>
    80004fda:	8552                	mv	a0,s4
    80004fdc:	ffffc097          	auipc	ra,0xffffc
    80004fe0:	fa0080e7          	jalr	-96(ra) # 80000f7c <strlen>
    80004fe4:	0015069b          	addiw	a3,a0,1
    80004fe8:	8652                	mv	a2,s4
    80004fea:	85ca                	mv	a1,s2
    80004fec:	e0843503          	ld	a0,-504(s0)
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	7d0080e7          	jalr	2000(ra) # 800017c0 <copyout>
    80004ff8:	10054763          	bltz	a0,80005106 <exec+0x30e>
    ustack[argc] = sp;
    80004ffc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005000:	0485                	addi	s1,s1,1
    80005002:	008c8793          	addi	a5,s9,8
    80005006:	def43c23          	sd	a5,-520(s0)
    8000500a:	008cb503          	ld	a0,8(s9)
    8000500e:	c911                	beqz	a0,80005022 <exec+0x22a>
    if(argc >= MAXARG)
    80005010:	09a1                	addi	s3,s3,8
    80005012:	fb8995e3          	bne	s3,s8,80004fbc <exec+0x1c4>
  sz = sz1;
    80005016:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000501a:	4901                	li	s2,0
    8000501c:	a865                	j	800050d4 <exec+0x2dc>
  sp = sz;
    8000501e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005020:	4481                	li	s1,0
  ustack[argc] = 0;
    80005022:	00349793          	slli	a5,s1,0x3
    80005026:	f9040713          	addi	a4,s0,-112
    8000502a:	97ba                	add	a5,a5,a4
    8000502c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7ef8>
  sp -= (argc+1) * sizeof(uint64);
    80005030:	00148693          	addi	a3,s1,1
    80005034:	068e                	slli	a3,a3,0x3
    80005036:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000503a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000503e:	01797663          	bleu	s7,s2,8000504a <exec+0x252>
  sz = sz1;
    80005042:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005046:	4901                	li	s2,0
    80005048:	a071                	j	800050d4 <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000504a:	e8840613          	addi	a2,s0,-376
    8000504e:	85ca                	mv	a1,s2
    80005050:	e0843503          	ld	a0,-504(s0)
    80005054:	ffffc097          	auipc	ra,0xffffc
    80005058:	76c080e7          	jalr	1900(ra) # 800017c0 <copyout>
    8000505c:	0a054963          	bltz	a0,8000510e <exec+0x316>
  p->trapframe->a1 = sp;
    80005060:	058ab783          	ld	a5,88(s5)
    80005064:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005068:	df043783          	ld	a5,-528(s0)
    8000506c:	0007c703          	lbu	a4,0(a5)
    80005070:	cf11                	beqz	a4,8000508c <exec+0x294>
    80005072:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005074:	02f00693          	li	a3,47
    80005078:	a029                	j	80005082 <exec+0x28a>
  for(last=s=path; *s; s++)
    8000507a:	0785                	addi	a5,a5,1
    8000507c:	fff7c703          	lbu	a4,-1(a5)
    80005080:	c711                	beqz	a4,8000508c <exec+0x294>
    if(*s == '/')
    80005082:	fed71ce3          	bne	a4,a3,8000507a <exec+0x282>
      last = s+1;
    80005086:	def43823          	sd	a5,-528(s0)
    8000508a:	bfc5                	j	8000507a <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    8000508c:	4641                	li	a2,16
    8000508e:	df043583          	ld	a1,-528(s0)
    80005092:	158a8513          	addi	a0,s5,344
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	eb4080e7          	jalr	-332(ra) # 80000f4a <safestrcpy>
  oldpagetable = p->pagetable;
    8000509e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050a2:	e0843783          	ld	a5,-504(s0)
    800050a6:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    800050aa:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050ae:	058ab783          	ld	a5,88(s5)
    800050b2:	e6043703          	ld	a4,-416(s0)
    800050b6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050b8:	058ab783          	ld	a5,88(s5)
    800050bc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050c0:	85ea                	mv	a1,s10
    800050c2:	ffffd097          	auipc	ra,0xffffd
    800050c6:	b84080e7          	jalr	-1148(ra) # 80001c46 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050ca:	0004851b          	sext.w	a0,s1
    800050ce:	b3d9                	j	80004e94 <exec+0x9c>
    800050d0:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    800050d4:	e0043583          	ld	a1,-512(s0)
    800050d8:	e0843503          	ld	a0,-504(s0)
    800050dc:	ffffd097          	auipc	ra,0xffffd
    800050e0:	b6a080e7          	jalr	-1174(ra) # 80001c46 <proc_freepagetable>
  if(ip){
    800050e4:	d8091ee3          	bnez	s2,80004e80 <exec+0x88>
  return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	b36d                	j	80004e94 <exec+0x9c>
    800050ec:	e0943023          	sd	s1,-512(s0)
    800050f0:	b7d5                	j	800050d4 <exec+0x2dc>
    800050f2:	e0943023          	sd	s1,-512(s0)
    800050f6:	bff9                	j	800050d4 <exec+0x2dc>
    800050f8:	e0943023          	sd	s1,-512(s0)
    800050fc:	bfe1                	j	800050d4 <exec+0x2dc>
  sz = sz1;
    800050fe:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005102:	4901                	li	s2,0
    80005104:	bfc1                	j	800050d4 <exec+0x2dc>
  sz = sz1;
    80005106:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000510a:	4901                	li	s2,0
    8000510c:	b7e1                	j	800050d4 <exec+0x2dc>
  sz = sz1;
    8000510e:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80005112:	4901                	li	s2,0
    80005114:	b7c1                	j	800050d4 <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005116:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000511a:	2b05                	addiw	s6,s6,1
    8000511c:	0389899b          	addiw	s3,s3,56
    80005120:	e8045783          	lhu	a5,-384(s0)
    80005124:	e2fb54e3          	ble	a5,s6,80004f4c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005128:	2981                	sext.w	s3,s3
    8000512a:	03800713          	li	a4,56
    8000512e:	86ce                	mv	a3,s3
    80005130:	e1040613          	addi	a2,s0,-496
    80005134:	4581                	li	a1,0
    80005136:	854a                	mv	a0,s2
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	9ec080e7          	jalr	-1556(ra) # 80003b24 <readi>
    80005140:	03800793          	li	a5,56
    80005144:	f8f516e3          	bne	a0,a5,800050d0 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    80005148:	e1042783          	lw	a5,-496(s0)
    8000514c:	4705                	li	a4,1
    8000514e:	fce796e3          	bne	a5,a4,8000511a <exec+0x322>
    if(ph.memsz < ph.filesz)
    80005152:	e3843603          	ld	a2,-456(s0)
    80005156:	e3043783          	ld	a5,-464(s0)
    8000515a:	f8f669e3          	bltu	a2,a5,800050ec <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000515e:	e2043783          	ld	a5,-480(s0)
    80005162:	963e                	add	a2,a2,a5
    80005164:	f8f667e3          	bltu	a2,a5,800050f2 <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005168:	85a6                	mv	a1,s1
    8000516a:	e0843503          	ld	a0,-504(s0)
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	402080e7          	jalr	1026(ra) # 80001570 <uvmalloc>
    80005176:	e0a43023          	sd	a0,-512(s0)
    8000517a:	dd3d                	beqz	a0,800050f8 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    8000517c:	e2043d03          	ld	s10,-480(s0)
    80005180:	de843783          	ld	a5,-536(s0)
    80005184:	00fd77b3          	and	a5,s10,a5
    80005188:	f7b1                	bnez	a5,800050d4 <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000518a:	e1842d83          	lw	s11,-488(s0)
    8000518e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005192:	f80b82e3          	beqz	s7,80005116 <exec+0x31e>
    80005196:	8a5e                	mv	s4,s7
    80005198:	4481                	li	s1,0
    8000519a:	b379                	j	80004f28 <exec+0x130>

000000008000519c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000519c:	7179                	addi	sp,sp,-48
    8000519e:	f406                	sd	ra,40(sp)
    800051a0:	f022                	sd	s0,32(sp)
    800051a2:	ec26                	sd	s1,24(sp)
    800051a4:	e84a                	sd	s2,16(sp)
    800051a6:	1800                	addi	s0,sp,48
    800051a8:	892e                	mv	s2,a1
    800051aa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051ac:	fdc40593          	addi	a1,s0,-36
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	a70080e7          	jalr	-1424(ra) # 80002c20 <argint>
    800051b8:	04054063          	bltz	a0,800051f8 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051bc:	fdc42703          	lw	a4,-36(s0)
    800051c0:	47bd                	li	a5,15
    800051c2:	02e7ed63          	bltu	a5,a4,800051fc <argfd+0x60>
    800051c6:	ffffd097          	auipc	ra,0xffffd
    800051ca:	91e080e7          	jalr	-1762(ra) # 80001ae4 <myproc>
    800051ce:	fdc42703          	lw	a4,-36(s0)
    800051d2:	01a70793          	addi	a5,a4,26
    800051d6:	078e                	slli	a5,a5,0x3
    800051d8:	953e                	add	a0,a0,a5
    800051da:	611c                	ld	a5,0(a0)
    800051dc:	c395                	beqz	a5,80005200 <argfd+0x64>
    return -1;
  if(pfd)
    800051de:	00090463          	beqz	s2,800051e6 <argfd+0x4a>
    *pfd = fd;
    800051e2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051e6:	4501                	li	a0,0
  if(pf)
    800051e8:	c091                	beqz	s1,800051ec <argfd+0x50>
    *pf = f;
    800051ea:	e09c                	sd	a5,0(s1)
}
    800051ec:	70a2                	ld	ra,40(sp)
    800051ee:	7402                	ld	s0,32(sp)
    800051f0:	64e2                	ld	s1,24(sp)
    800051f2:	6942                	ld	s2,16(sp)
    800051f4:	6145                	addi	sp,sp,48
    800051f6:	8082                	ret
    return -1;
    800051f8:	557d                	li	a0,-1
    800051fa:	bfcd                	j	800051ec <argfd+0x50>
    return -1;
    800051fc:	557d                	li	a0,-1
    800051fe:	b7fd                	j	800051ec <argfd+0x50>
    80005200:	557d                	li	a0,-1
    80005202:	b7ed                	j	800051ec <argfd+0x50>

0000000080005204 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005204:	1101                	addi	sp,sp,-32
    80005206:	ec06                	sd	ra,24(sp)
    80005208:	e822                	sd	s0,16(sp)
    8000520a:	e426                	sd	s1,8(sp)
    8000520c:	1000                	addi	s0,sp,32
    8000520e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	8d4080e7          	jalr	-1836(ra) # 80001ae4 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80005218:	697c                	ld	a5,208(a0)
    8000521a:	c395                	beqz	a5,8000523e <fdalloc+0x3a>
    8000521c:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80005220:	4785                	li	a5,1
    80005222:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    80005224:	6314                	ld	a3,0(a4)
    80005226:	ce89                	beqz	a3,80005240 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80005228:	2785                	addiw	a5,a5,1
    8000522a:	0721                	addi	a4,a4,8
    8000522c:	fec79ce3          	bne	a5,a2,80005224 <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005230:	57fd                	li	a5,-1
}
    80005232:	853e                	mv	a0,a5
    80005234:	60e2                	ld	ra,24(sp)
    80005236:	6442                	ld	s0,16(sp)
    80005238:	64a2                	ld	s1,8(sp)
    8000523a:	6105                	addi	sp,sp,32
    8000523c:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    8000523e:	4781                	li	a5,0
      p->ofile[fd] = f;
    80005240:	01a78713          	addi	a4,a5,26
    80005244:	070e                	slli	a4,a4,0x3
    80005246:	953a                	add	a0,a0,a4
    80005248:	e104                	sd	s1,0(a0)
      return fd;
    8000524a:	b7e5                	j	80005232 <fdalloc+0x2e>

000000008000524c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000524c:	715d                	addi	sp,sp,-80
    8000524e:	e486                	sd	ra,72(sp)
    80005250:	e0a2                	sd	s0,64(sp)
    80005252:	fc26                	sd	s1,56(sp)
    80005254:	f84a                	sd	s2,48(sp)
    80005256:	f44e                	sd	s3,40(sp)
    80005258:	f052                	sd	s4,32(sp)
    8000525a:	ec56                	sd	s5,24(sp)
    8000525c:	0880                	addi	s0,sp,80
    8000525e:	89ae                	mv	s3,a1
    80005260:	8ab2                	mv	s5,a2
    80005262:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005264:	fb040593          	addi	a1,s0,-80
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	dde080e7          	jalr	-546(ra) # 80004046 <nameiparent>
    80005270:	892a                	mv	s2,a0
    80005272:	12050f63          	beqz	a0,800053b0 <create+0x164>
    return 0;

  ilock(dp);
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	5f8080e7          	jalr	1528(ra) # 8000386e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000527e:	4601                	li	a2,0
    80005280:	fb040593          	addi	a1,s0,-80
    80005284:	854a                	mv	a0,s2
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	ac8080e7          	jalr	-1336(ra) # 80003d4e <dirlookup>
    8000528e:	84aa                	mv	s1,a0
    80005290:	c921                	beqz	a0,800052e0 <create+0x94>
    iunlockput(dp);
    80005292:	854a                	mv	a0,s2
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	83e080e7          	jalr	-1986(ra) # 80003ad2 <iunlockput>
    ilock(ip);
    8000529c:	8526                	mv	a0,s1
    8000529e:	ffffe097          	auipc	ra,0xffffe
    800052a2:	5d0080e7          	jalr	1488(ra) # 8000386e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052a6:	2981                	sext.w	s3,s3
    800052a8:	4789                	li	a5,2
    800052aa:	02f99463          	bne	s3,a5,800052d2 <create+0x86>
    800052ae:	0444d783          	lhu	a5,68(s1)
    800052b2:	37f9                	addiw	a5,a5,-2
    800052b4:	17c2                	slli	a5,a5,0x30
    800052b6:	93c1                	srli	a5,a5,0x30
    800052b8:	4705                	li	a4,1
    800052ba:	00f76c63          	bltu	a4,a5,800052d2 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052be:	8526                	mv	a0,s1
    800052c0:	60a6                	ld	ra,72(sp)
    800052c2:	6406                	ld	s0,64(sp)
    800052c4:	74e2                	ld	s1,56(sp)
    800052c6:	7942                	ld	s2,48(sp)
    800052c8:	79a2                	ld	s3,40(sp)
    800052ca:	7a02                	ld	s4,32(sp)
    800052cc:	6ae2                	ld	s5,24(sp)
    800052ce:	6161                	addi	sp,sp,80
    800052d0:	8082                	ret
    iunlockput(ip);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	7fe080e7          	jalr	2046(ra) # 80003ad2 <iunlockput>
    return 0;
    800052dc:	4481                	li	s1,0
    800052de:	b7c5                	j	800052be <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052e0:	85ce                	mv	a1,s3
    800052e2:	00092503          	lw	a0,0(s2)
    800052e6:	ffffe097          	auipc	ra,0xffffe
    800052ea:	3ec080e7          	jalr	1004(ra) # 800036d2 <ialloc>
    800052ee:	84aa                	mv	s1,a0
    800052f0:	c529                	beqz	a0,8000533a <create+0xee>
  ilock(ip);
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	57c080e7          	jalr	1404(ra) # 8000386e <ilock>
  ip->major = major;
    800052fa:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800052fe:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005302:	4785                	li	a5,1
    80005304:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005308:	8526                	mv	a0,s1
    8000530a:	ffffe097          	auipc	ra,0xffffe
    8000530e:	498080e7          	jalr	1176(ra) # 800037a2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005312:	2981                	sext.w	s3,s3
    80005314:	4785                	li	a5,1
    80005316:	02f98a63          	beq	s3,a5,8000534a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000531a:	40d0                	lw	a2,4(s1)
    8000531c:	fb040593          	addi	a1,s0,-80
    80005320:	854a                	mv	a0,s2
    80005322:	fffff097          	auipc	ra,0xfffff
    80005326:	c44080e7          	jalr	-956(ra) # 80003f66 <dirlink>
    8000532a:	06054b63          	bltz	a0,800053a0 <create+0x154>
  iunlockput(dp);
    8000532e:	854a                	mv	a0,s2
    80005330:	ffffe097          	auipc	ra,0xffffe
    80005334:	7a2080e7          	jalr	1954(ra) # 80003ad2 <iunlockput>
  return ip;
    80005338:	b759                	j	800052be <create+0x72>
    panic("create: ialloc");
    8000533a:	00003517          	auipc	a0,0x3
    8000533e:	3c650513          	addi	a0,a0,966 # 80008700 <syscalls+0x2e8>
    80005342:	ffffb097          	auipc	ra,0xffffb
    80005346:	2d0080e7          	jalr	720(ra) # 80000612 <panic>
    dp->nlink++;  // for ".."
    8000534a:	04a95783          	lhu	a5,74(s2)
    8000534e:	2785                	addiw	a5,a5,1
    80005350:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005354:	854a                	mv	a0,s2
    80005356:	ffffe097          	auipc	ra,0xffffe
    8000535a:	44c080e7          	jalr	1100(ra) # 800037a2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000535e:	40d0                	lw	a2,4(s1)
    80005360:	00003597          	auipc	a1,0x3
    80005364:	3b058593          	addi	a1,a1,944 # 80008710 <syscalls+0x2f8>
    80005368:	8526                	mv	a0,s1
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	bfc080e7          	jalr	-1028(ra) # 80003f66 <dirlink>
    80005372:	00054f63          	bltz	a0,80005390 <create+0x144>
    80005376:	00492603          	lw	a2,4(s2)
    8000537a:	00003597          	auipc	a1,0x3
    8000537e:	39e58593          	addi	a1,a1,926 # 80008718 <syscalls+0x300>
    80005382:	8526                	mv	a0,s1
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	be2080e7          	jalr	-1054(ra) # 80003f66 <dirlink>
    8000538c:	f80557e3          	bgez	a0,8000531a <create+0xce>
      panic("create dots");
    80005390:	00003517          	auipc	a0,0x3
    80005394:	39050513          	addi	a0,a0,912 # 80008720 <syscalls+0x308>
    80005398:	ffffb097          	auipc	ra,0xffffb
    8000539c:	27a080e7          	jalr	634(ra) # 80000612 <panic>
    panic("create: dirlink");
    800053a0:	00003517          	auipc	a0,0x3
    800053a4:	39050513          	addi	a0,a0,912 # 80008730 <syscalls+0x318>
    800053a8:	ffffb097          	auipc	ra,0xffffb
    800053ac:	26a080e7          	jalr	618(ra) # 80000612 <panic>
    return 0;
    800053b0:	84aa                	mv	s1,a0
    800053b2:	b731                	j	800052be <create+0x72>

00000000800053b4 <sys_dup>:
{
    800053b4:	7179                	addi	sp,sp,-48
    800053b6:	f406                	sd	ra,40(sp)
    800053b8:	f022                	sd	s0,32(sp)
    800053ba:	ec26                	sd	s1,24(sp)
    800053bc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053be:	fd840613          	addi	a2,s0,-40
    800053c2:	4581                	li	a1,0
    800053c4:	4501                	li	a0,0
    800053c6:	00000097          	auipc	ra,0x0
    800053ca:	dd6080e7          	jalr	-554(ra) # 8000519c <argfd>
    return -1;
    800053ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053d0:	02054363          	bltz	a0,800053f6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053d4:	fd843503          	ld	a0,-40(s0)
    800053d8:	00000097          	auipc	ra,0x0
    800053dc:	e2c080e7          	jalr	-468(ra) # 80005204 <fdalloc>
    800053e0:	84aa                	mv	s1,a0
    return -1;
    800053e2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053e4:	00054963          	bltz	a0,800053f6 <sys_dup+0x42>
  filedup(f);
    800053e8:	fd843503          	ld	a0,-40(s0)
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	2fa080e7          	jalr	762(ra) # 800046e6 <filedup>
  return fd;
    800053f4:	87a6                	mv	a5,s1
}
    800053f6:	853e                	mv	a0,a5
    800053f8:	70a2                	ld	ra,40(sp)
    800053fa:	7402                	ld	s0,32(sp)
    800053fc:	64e2                	ld	s1,24(sp)
    800053fe:	6145                	addi	sp,sp,48
    80005400:	8082                	ret

0000000080005402 <sys_read>:
{
    80005402:	7179                	addi	sp,sp,-48
    80005404:	f406                	sd	ra,40(sp)
    80005406:	f022                	sd	s0,32(sp)
    80005408:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000540a:	fe840613          	addi	a2,s0,-24
    8000540e:	4581                	li	a1,0
    80005410:	4501                	li	a0,0
    80005412:	00000097          	auipc	ra,0x0
    80005416:	d8a080e7          	jalr	-630(ra) # 8000519c <argfd>
    return -1;
    8000541a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000541c:	04054163          	bltz	a0,8000545e <sys_read+0x5c>
    80005420:	fe440593          	addi	a1,s0,-28
    80005424:	4509                	li	a0,2
    80005426:	ffffd097          	auipc	ra,0xffffd
    8000542a:	7fa080e7          	jalr	2042(ra) # 80002c20 <argint>
    return -1;
    8000542e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005430:	02054763          	bltz	a0,8000545e <sys_read+0x5c>
    80005434:	fd840593          	addi	a1,s0,-40
    80005438:	4505                	li	a0,1
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	808080e7          	jalr	-2040(ra) # 80002c42 <argaddr>
    return -1;
    80005442:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005444:	00054d63          	bltz	a0,8000545e <sys_read+0x5c>
  return fileread(f, p, n);
    80005448:	fe442603          	lw	a2,-28(s0)
    8000544c:	fd843583          	ld	a1,-40(s0)
    80005450:	fe843503          	ld	a0,-24(s0)
    80005454:	fffff097          	auipc	ra,0xfffff
    80005458:	41e080e7          	jalr	1054(ra) # 80004872 <fileread>
    8000545c:	87aa                	mv	a5,a0
}
    8000545e:	853e                	mv	a0,a5
    80005460:	70a2                	ld	ra,40(sp)
    80005462:	7402                	ld	s0,32(sp)
    80005464:	6145                	addi	sp,sp,48
    80005466:	8082                	ret

0000000080005468 <sys_write>:
{
    80005468:	7179                	addi	sp,sp,-48
    8000546a:	f406                	sd	ra,40(sp)
    8000546c:	f022                	sd	s0,32(sp)
    8000546e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005470:	fe840613          	addi	a2,s0,-24
    80005474:	4581                	li	a1,0
    80005476:	4501                	li	a0,0
    80005478:	00000097          	auipc	ra,0x0
    8000547c:	d24080e7          	jalr	-732(ra) # 8000519c <argfd>
    return -1;
    80005480:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005482:	04054163          	bltz	a0,800054c4 <sys_write+0x5c>
    80005486:	fe440593          	addi	a1,s0,-28
    8000548a:	4509                	li	a0,2
    8000548c:	ffffd097          	auipc	ra,0xffffd
    80005490:	794080e7          	jalr	1940(ra) # 80002c20 <argint>
    return -1;
    80005494:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005496:	02054763          	bltz	a0,800054c4 <sys_write+0x5c>
    8000549a:	fd840593          	addi	a1,s0,-40
    8000549e:	4505                	li	a0,1
    800054a0:	ffffd097          	auipc	ra,0xffffd
    800054a4:	7a2080e7          	jalr	1954(ra) # 80002c42 <argaddr>
    return -1;
    800054a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054aa:	00054d63          	bltz	a0,800054c4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800054ae:	fe442603          	lw	a2,-28(s0)
    800054b2:	fd843583          	ld	a1,-40(s0)
    800054b6:	fe843503          	ld	a0,-24(s0)
    800054ba:	fffff097          	auipc	ra,0xfffff
    800054be:	47a080e7          	jalr	1146(ra) # 80004934 <filewrite>
    800054c2:	87aa                	mv	a5,a0
}
    800054c4:	853e                	mv	a0,a5
    800054c6:	70a2                	ld	ra,40(sp)
    800054c8:	7402                	ld	s0,32(sp)
    800054ca:	6145                	addi	sp,sp,48
    800054cc:	8082                	ret

00000000800054ce <sys_close>:
{
    800054ce:	1101                	addi	sp,sp,-32
    800054d0:	ec06                	sd	ra,24(sp)
    800054d2:	e822                	sd	s0,16(sp)
    800054d4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054d6:	fe040613          	addi	a2,s0,-32
    800054da:	fec40593          	addi	a1,s0,-20
    800054de:	4501                	li	a0,0
    800054e0:	00000097          	auipc	ra,0x0
    800054e4:	cbc080e7          	jalr	-836(ra) # 8000519c <argfd>
    return -1;
    800054e8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054ea:	02054463          	bltz	a0,80005512 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054ee:	ffffc097          	auipc	ra,0xffffc
    800054f2:	5f6080e7          	jalr	1526(ra) # 80001ae4 <myproc>
    800054f6:	fec42783          	lw	a5,-20(s0)
    800054fa:	07e9                	addi	a5,a5,26
    800054fc:	078e                	slli	a5,a5,0x3
    800054fe:	953e                	add	a0,a0,a5
    80005500:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005504:	fe043503          	ld	a0,-32(s0)
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	230080e7          	jalr	560(ra) # 80004738 <fileclose>
  return 0;
    80005510:	4781                	li	a5,0
}
    80005512:	853e                	mv	a0,a5
    80005514:	60e2                	ld	ra,24(sp)
    80005516:	6442                	ld	s0,16(sp)
    80005518:	6105                	addi	sp,sp,32
    8000551a:	8082                	ret

000000008000551c <sys_fstat>:
{
    8000551c:	1101                	addi	sp,sp,-32
    8000551e:	ec06                	sd	ra,24(sp)
    80005520:	e822                	sd	s0,16(sp)
    80005522:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005524:	fe840613          	addi	a2,s0,-24
    80005528:	4581                	li	a1,0
    8000552a:	4501                	li	a0,0
    8000552c:	00000097          	auipc	ra,0x0
    80005530:	c70080e7          	jalr	-912(ra) # 8000519c <argfd>
    return -1;
    80005534:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005536:	02054563          	bltz	a0,80005560 <sys_fstat+0x44>
    8000553a:	fe040593          	addi	a1,s0,-32
    8000553e:	4505                	li	a0,1
    80005540:	ffffd097          	auipc	ra,0xffffd
    80005544:	702080e7          	jalr	1794(ra) # 80002c42 <argaddr>
    return -1;
    80005548:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000554a:	00054b63          	bltz	a0,80005560 <sys_fstat+0x44>
  return filestat(f, st);
    8000554e:	fe043583          	ld	a1,-32(s0)
    80005552:	fe843503          	ld	a0,-24(s0)
    80005556:	fffff097          	auipc	ra,0xfffff
    8000555a:	2aa080e7          	jalr	682(ra) # 80004800 <filestat>
    8000555e:	87aa                	mv	a5,a0
}
    80005560:	853e                	mv	a0,a5
    80005562:	60e2                	ld	ra,24(sp)
    80005564:	6442                	ld	s0,16(sp)
    80005566:	6105                	addi	sp,sp,32
    80005568:	8082                	ret

000000008000556a <sys_link>:
{
    8000556a:	7169                	addi	sp,sp,-304
    8000556c:	f606                	sd	ra,296(sp)
    8000556e:	f222                	sd	s0,288(sp)
    80005570:	ee26                	sd	s1,280(sp)
    80005572:	ea4a                	sd	s2,272(sp)
    80005574:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005576:	08000613          	li	a2,128
    8000557a:	ed040593          	addi	a1,s0,-304
    8000557e:	4501                	li	a0,0
    80005580:	ffffd097          	auipc	ra,0xffffd
    80005584:	6e4080e7          	jalr	1764(ra) # 80002c64 <argstr>
    return -1;
    80005588:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000558a:	10054e63          	bltz	a0,800056a6 <sys_link+0x13c>
    8000558e:	08000613          	li	a2,128
    80005592:	f5040593          	addi	a1,s0,-176
    80005596:	4505                	li	a0,1
    80005598:	ffffd097          	auipc	ra,0xffffd
    8000559c:	6cc080e7          	jalr	1740(ra) # 80002c64 <argstr>
    return -1;
    800055a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055a2:	10054263          	bltz	a0,800056a6 <sys_link+0x13c>
  begin_op();
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	c90080e7          	jalr	-880(ra) # 80004236 <begin_op>
  if((ip = namei(old)) == 0){
    800055ae:	ed040513          	addi	a0,s0,-304
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	a76080e7          	jalr	-1418(ra) # 80004028 <namei>
    800055ba:	84aa                	mv	s1,a0
    800055bc:	c551                	beqz	a0,80005648 <sys_link+0xde>
  ilock(ip);
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	2b0080e7          	jalr	688(ra) # 8000386e <ilock>
  if(ip->type == T_DIR){
    800055c6:	04449703          	lh	a4,68(s1)
    800055ca:	4785                	li	a5,1
    800055cc:	08f70463          	beq	a4,a5,80005654 <sys_link+0xea>
  ip->nlink++;
    800055d0:	04a4d783          	lhu	a5,74(s1)
    800055d4:	2785                	addiw	a5,a5,1
    800055d6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055da:	8526                	mv	a0,s1
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	1c6080e7          	jalr	454(ra) # 800037a2 <iupdate>
  iunlock(ip);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	34c080e7          	jalr	844(ra) # 80003932 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055ee:	fd040593          	addi	a1,s0,-48
    800055f2:	f5040513          	addi	a0,s0,-176
    800055f6:	fffff097          	auipc	ra,0xfffff
    800055fa:	a50080e7          	jalr	-1456(ra) # 80004046 <nameiparent>
    800055fe:	892a                	mv	s2,a0
    80005600:	c935                	beqz	a0,80005674 <sys_link+0x10a>
  ilock(dp);
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	26c080e7          	jalr	620(ra) # 8000386e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000560a:	00092703          	lw	a4,0(s2)
    8000560e:	409c                	lw	a5,0(s1)
    80005610:	04f71d63          	bne	a4,a5,8000566a <sys_link+0x100>
    80005614:	40d0                	lw	a2,4(s1)
    80005616:	fd040593          	addi	a1,s0,-48
    8000561a:	854a                	mv	a0,s2
    8000561c:	fffff097          	auipc	ra,0xfffff
    80005620:	94a080e7          	jalr	-1718(ra) # 80003f66 <dirlink>
    80005624:	04054363          	bltz	a0,8000566a <sys_link+0x100>
  iunlockput(dp);
    80005628:	854a                	mv	a0,s2
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	4a8080e7          	jalr	1192(ra) # 80003ad2 <iunlockput>
  iput(ip);
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	3f6080e7          	jalr	1014(ra) # 80003a2a <iput>
  end_op();
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	c7a080e7          	jalr	-902(ra) # 800042b6 <end_op>
  return 0;
    80005644:	4781                	li	a5,0
    80005646:	a085                	j	800056a6 <sys_link+0x13c>
    end_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	c6e080e7          	jalr	-914(ra) # 800042b6 <end_op>
    return -1;
    80005650:	57fd                	li	a5,-1
    80005652:	a891                	j	800056a6 <sys_link+0x13c>
    iunlockput(ip);
    80005654:	8526                	mv	a0,s1
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	47c080e7          	jalr	1148(ra) # 80003ad2 <iunlockput>
    end_op();
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	c58080e7          	jalr	-936(ra) # 800042b6 <end_op>
    return -1;
    80005666:	57fd                	li	a5,-1
    80005668:	a83d                	j	800056a6 <sys_link+0x13c>
    iunlockput(dp);
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	466080e7          	jalr	1126(ra) # 80003ad2 <iunlockput>
  ilock(ip);
    80005674:	8526                	mv	a0,s1
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	1f8080e7          	jalr	504(ra) # 8000386e <ilock>
  ip->nlink--;
    8000567e:	04a4d783          	lhu	a5,74(s1)
    80005682:	37fd                	addiw	a5,a5,-1
    80005684:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	118080e7          	jalr	280(ra) # 800037a2 <iupdate>
  iunlockput(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	43e080e7          	jalr	1086(ra) # 80003ad2 <iunlockput>
  end_op();
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	c1a080e7          	jalr	-998(ra) # 800042b6 <end_op>
  return -1;
    800056a4:	57fd                	li	a5,-1
}
    800056a6:	853e                	mv	a0,a5
    800056a8:	70b2                	ld	ra,296(sp)
    800056aa:	7412                	ld	s0,288(sp)
    800056ac:	64f2                	ld	s1,280(sp)
    800056ae:	6952                	ld	s2,272(sp)
    800056b0:	6155                	addi	sp,sp,304
    800056b2:	8082                	ret

00000000800056b4 <sys_unlink>:
{
    800056b4:	7151                	addi	sp,sp,-240
    800056b6:	f586                	sd	ra,232(sp)
    800056b8:	f1a2                	sd	s0,224(sp)
    800056ba:	eda6                	sd	s1,216(sp)
    800056bc:	e9ca                	sd	s2,208(sp)
    800056be:	e5ce                	sd	s3,200(sp)
    800056c0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056c2:	08000613          	li	a2,128
    800056c6:	f3040593          	addi	a1,s0,-208
    800056ca:	4501                	li	a0,0
    800056cc:	ffffd097          	auipc	ra,0xffffd
    800056d0:	598080e7          	jalr	1432(ra) # 80002c64 <argstr>
    800056d4:	16054f63          	bltz	a0,80005852 <sys_unlink+0x19e>
  begin_op();
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	b5e080e7          	jalr	-1186(ra) # 80004236 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056e0:	fb040593          	addi	a1,s0,-80
    800056e4:	f3040513          	addi	a0,s0,-208
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	95e080e7          	jalr	-1698(ra) # 80004046 <nameiparent>
    800056f0:	89aa                	mv	s3,a0
    800056f2:	c979                	beqz	a0,800057c8 <sys_unlink+0x114>
  ilock(dp);
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	17a080e7          	jalr	378(ra) # 8000386e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056fc:	00003597          	auipc	a1,0x3
    80005700:	01458593          	addi	a1,a1,20 # 80008710 <syscalls+0x2f8>
    80005704:	fb040513          	addi	a0,s0,-80
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	62c080e7          	jalr	1580(ra) # 80003d34 <namecmp>
    80005710:	14050863          	beqz	a0,80005860 <sys_unlink+0x1ac>
    80005714:	00003597          	auipc	a1,0x3
    80005718:	00458593          	addi	a1,a1,4 # 80008718 <syscalls+0x300>
    8000571c:	fb040513          	addi	a0,s0,-80
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	614080e7          	jalr	1556(ra) # 80003d34 <namecmp>
    80005728:	12050c63          	beqz	a0,80005860 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000572c:	f2c40613          	addi	a2,s0,-212
    80005730:	fb040593          	addi	a1,s0,-80
    80005734:	854e                	mv	a0,s3
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	618080e7          	jalr	1560(ra) # 80003d4e <dirlookup>
    8000573e:	84aa                	mv	s1,a0
    80005740:	12050063          	beqz	a0,80005860 <sys_unlink+0x1ac>
  ilock(ip);
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	12a080e7          	jalr	298(ra) # 8000386e <ilock>
  if(ip->nlink < 1)
    8000574c:	04a49783          	lh	a5,74(s1)
    80005750:	08f05263          	blez	a5,800057d4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005754:	04449703          	lh	a4,68(s1)
    80005758:	4785                	li	a5,1
    8000575a:	08f70563          	beq	a4,a5,800057e4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000575e:	4641                	li	a2,16
    80005760:	4581                	li	a1,0
    80005762:	fc040513          	addi	a0,s0,-64
    80005766:	ffffb097          	auipc	ra,0xffffb
    8000576a:	66c080e7          	jalr	1644(ra) # 80000dd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000576e:	4741                	li	a4,16
    80005770:	f2c42683          	lw	a3,-212(s0)
    80005774:	fc040613          	addi	a2,s0,-64
    80005778:	4581                	li	a1,0
    8000577a:	854e                	mv	a0,s3
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	49e080e7          	jalr	1182(ra) # 80003c1a <writei>
    80005784:	47c1                	li	a5,16
    80005786:	0af51363          	bne	a0,a5,8000582c <sys_unlink+0x178>
  if(ip->type == T_DIR){
    8000578a:	04449703          	lh	a4,68(s1)
    8000578e:	4785                	li	a5,1
    80005790:	0af70663          	beq	a4,a5,8000583c <sys_unlink+0x188>
  iunlockput(dp);
    80005794:	854e                	mv	a0,s3
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	33c080e7          	jalr	828(ra) # 80003ad2 <iunlockput>
  ip->nlink--;
    8000579e:	04a4d783          	lhu	a5,74(s1)
    800057a2:	37fd                	addiw	a5,a5,-1
    800057a4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	ff8080e7          	jalr	-8(ra) # 800037a2 <iupdate>
  iunlockput(ip);
    800057b2:	8526                	mv	a0,s1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	31e080e7          	jalr	798(ra) # 80003ad2 <iunlockput>
  end_op();
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	afa080e7          	jalr	-1286(ra) # 800042b6 <end_op>
  return 0;
    800057c4:	4501                	li	a0,0
    800057c6:	a07d                	j	80005874 <sys_unlink+0x1c0>
    end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	aee080e7          	jalr	-1298(ra) # 800042b6 <end_op>
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	a04d                	j	80005874 <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    800057d4:	00003517          	auipc	a0,0x3
    800057d8:	f6c50513          	addi	a0,a0,-148 # 80008740 <syscalls+0x328>
    800057dc:	ffffb097          	auipc	ra,0xffffb
    800057e0:	e36080e7          	jalr	-458(ra) # 80000612 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e4:	44f8                	lw	a4,76(s1)
    800057e6:	02000793          	li	a5,32
    800057ea:	f6e7fae3          	bleu	a4,a5,8000575e <sys_unlink+0xaa>
    800057ee:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f2:	4741                	li	a4,16
    800057f4:	86ca                	mv	a3,s2
    800057f6:	f1840613          	addi	a2,s0,-232
    800057fa:	4581                	li	a1,0
    800057fc:	8526                	mv	a0,s1
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	326080e7          	jalr	806(ra) # 80003b24 <readi>
    80005806:	47c1                	li	a5,16
    80005808:	00f51a63          	bne	a0,a5,8000581c <sys_unlink+0x168>
    if(de.inum != 0)
    8000580c:	f1845783          	lhu	a5,-232(s0)
    80005810:	e3b9                	bnez	a5,80005856 <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005812:	2941                	addiw	s2,s2,16
    80005814:	44fc                	lw	a5,76(s1)
    80005816:	fcf96ee3          	bltu	s2,a5,800057f2 <sys_unlink+0x13e>
    8000581a:	b791                	j	8000575e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000581c:	00003517          	auipc	a0,0x3
    80005820:	f3c50513          	addi	a0,a0,-196 # 80008758 <syscalls+0x340>
    80005824:	ffffb097          	auipc	ra,0xffffb
    80005828:	dee080e7          	jalr	-530(ra) # 80000612 <panic>
    panic("unlink: writei");
    8000582c:	00003517          	auipc	a0,0x3
    80005830:	f4450513          	addi	a0,a0,-188 # 80008770 <syscalls+0x358>
    80005834:	ffffb097          	auipc	ra,0xffffb
    80005838:	dde080e7          	jalr	-546(ra) # 80000612 <panic>
    dp->nlink--;
    8000583c:	04a9d783          	lhu	a5,74(s3)
    80005840:	37fd                	addiw	a5,a5,-1
    80005842:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    80005846:	854e                	mv	a0,s3
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	f5a080e7          	jalr	-166(ra) # 800037a2 <iupdate>
    80005850:	b791                	j	80005794 <sys_unlink+0xe0>
    return -1;
    80005852:	557d                	li	a0,-1
    80005854:	a005                	j	80005874 <sys_unlink+0x1c0>
    iunlockput(ip);
    80005856:	8526                	mv	a0,s1
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	27a080e7          	jalr	634(ra) # 80003ad2 <iunlockput>
  iunlockput(dp);
    80005860:	854e                	mv	a0,s3
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	270080e7          	jalr	624(ra) # 80003ad2 <iunlockput>
  end_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	a4c080e7          	jalr	-1460(ra) # 800042b6 <end_op>
  return -1;
    80005872:	557d                	li	a0,-1
}
    80005874:	70ae                	ld	ra,232(sp)
    80005876:	740e                	ld	s0,224(sp)
    80005878:	64ee                	ld	s1,216(sp)
    8000587a:	694e                	ld	s2,208(sp)
    8000587c:	69ae                	ld	s3,200(sp)
    8000587e:	616d                	addi	sp,sp,240
    80005880:	8082                	ret

0000000080005882 <sys_open>:

uint64
sys_open(void)
{
    80005882:	7131                	addi	sp,sp,-192
    80005884:	fd06                	sd	ra,184(sp)
    80005886:	f922                	sd	s0,176(sp)
    80005888:	f526                	sd	s1,168(sp)
    8000588a:	f14a                	sd	s2,160(sp)
    8000588c:	ed4e                	sd	s3,152(sp)
    8000588e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005890:	08000613          	li	a2,128
    80005894:	f5040593          	addi	a1,s0,-176
    80005898:	4501                	li	a0,0
    8000589a:	ffffd097          	auipc	ra,0xffffd
    8000589e:	3ca080e7          	jalr	970(ra) # 80002c64 <argstr>
    return -1;
    800058a2:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058a4:	0c054163          	bltz	a0,80005966 <sys_open+0xe4>
    800058a8:	f4c40593          	addi	a1,s0,-180
    800058ac:	4505                	li	a0,1
    800058ae:	ffffd097          	auipc	ra,0xffffd
    800058b2:	372080e7          	jalr	882(ra) # 80002c20 <argint>
    800058b6:	0a054863          	bltz	a0,80005966 <sys_open+0xe4>

  begin_op();
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	97c080e7          	jalr	-1668(ra) # 80004236 <begin_op>

  if(omode & O_CREATE){
    800058c2:	f4c42783          	lw	a5,-180(s0)
    800058c6:	2007f793          	andi	a5,a5,512
    800058ca:	cbdd                	beqz	a5,80005980 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058cc:	4681                	li	a3,0
    800058ce:	4601                	li	a2,0
    800058d0:	4589                	li	a1,2
    800058d2:	f5040513          	addi	a0,s0,-176
    800058d6:	00000097          	auipc	ra,0x0
    800058da:	976080e7          	jalr	-1674(ra) # 8000524c <create>
    800058de:	892a                	mv	s2,a0
    if(ip == 0){
    800058e0:	c959                	beqz	a0,80005976 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058e2:	04491703          	lh	a4,68(s2)
    800058e6:	478d                	li	a5,3
    800058e8:	00f71763          	bne	a4,a5,800058f6 <sys_open+0x74>
    800058ec:	04695703          	lhu	a4,70(s2)
    800058f0:	47a5                	li	a5,9
    800058f2:	0ce7ec63          	bltu	a5,a4,800059ca <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	d72080e7          	jalr	-654(ra) # 80004668 <filealloc>
    800058fe:	89aa                	mv	s3,a0
    80005900:	10050263          	beqz	a0,80005a04 <sys_open+0x182>
    80005904:	00000097          	auipc	ra,0x0
    80005908:	900080e7          	jalr	-1792(ra) # 80005204 <fdalloc>
    8000590c:	84aa                	mv	s1,a0
    8000590e:	0e054663          	bltz	a0,800059fa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005912:	04491703          	lh	a4,68(s2)
    80005916:	478d                	li	a5,3
    80005918:	0cf70463          	beq	a4,a5,800059e0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000591c:	4789                	li	a5,2
    8000591e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005922:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005926:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000592a:	f4c42783          	lw	a5,-180(s0)
    8000592e:	0017c713          	xori	a4,a5,1
    80005932:	8b05                	andi	a4,a4,1
    80005934:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005938:	0037f713          	andi	a4,a5,3
    8000593c:	00e03733          	snez	a4,a4
    80005940:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005944:	4007f793          	andi	a5,a5,1024
    80005948:	c791                	beqz	a5,80005954 <sys_open+0xd2>
    8000594a:	04491703          	lh	a4,68(s2)
    8000594e:	4789                	li	a5,2
    80005950:	08f70f63          	beq	a4,a5,800059ee <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005954:	854a                	mv	a0,s2
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	fdc080e7          	jalr	-36(ra) # 80003932 <iunlock>
  end_op();
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	958080e7          	jalr	-1704(ra) # 800042b6 <end_op>

  return fd;
}
    80005966:	8526                	mv	a0,s1
    80005968:	70ea                	ld	ra,184(sp)
    8000596a:	744a                	ld	s0,176(sp)
    8000596c:	74aa                	ld	s1,168(sp)
    8000596e:	790a                	ld	s2,160(sp)
    80005970:	69ea                	ld	s3,152(sp)
    80005972:	6129                	addi	sp,sp,192
    80005974:	8082                	ret
      end_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	940080e7          	jalr	-1728(ra) # 800042b6 <end_op>
      return -1;
    8000597e:	b7e5                	j	80005966 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005980:	f5040513          	addi	a0,s0,-176
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	6a4080e7          	jalr	1700(ra) # 80004028 <namei>
    8000598c:	892a                	mv	s2,a0
    8000598e:	c905                	beqz	a0,800059be <sys_open+0x13c>
    ilock(ip);
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	ede080e7          	jalr	-290(ra) # 8000386e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005998:	04491703          	lh	a4,68(s2)
    8000599c:	4785                	li	a5,1
    8000599e:	f4f712e3          	bne	a4,a5,800058e2 <sys_open+0x60>
    800059a2:	f4c42783          	lw	a5,-180(s0)
    800059a6:	dba1                	beqz	a5,800058f6 <sys_open+0x74>
      iunlockput(ip);
    800059a8:	854a                	mv	a0,s2
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	128080e7          	jalr	296(ra) # 80003ad2 <iunlockput>
      end_op();
    800059b2:	fffff097          	auipc	ra,0xfffff
    800059b6:	904080e7          	jalr	-1788(ra) # 800042b6 <end_op>
      return -1;
    800059ba:	54fd                	li	s1,-1
    800059bc:	b76d                	j	80005966 <sys_open+0xe4>
      end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	8f8080e7          	jalr	-1800(ra) # 800042b6 <end_op>
      return -1;
    800059c6:	54fd                	li	s1,-1
    800059c8:	bf79                	j	80005966 <sys_open+0xe4>
    iunlockput(ip);
    800059ca:	854a                	mv	a0,s2
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	106080e7          	jalr	262(ra) # 80003ad2 <iunlockput>
    end_op();
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	8e2080e7          	jalr	-1822(ra) # 800042b6 <end_op>
    return -1;
    800059dc:	54fd                	li	s1,-1
    800059de:	b761                	j	80005966 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059e0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059e4:	04691783          	lh	a5,70(s2)
    800059e8:	02f99223          	sh	a5,36(s3)
    800059ec:	bf2d                	j	80005926 <sys_open+0xa4>
    itrunc(ip);
    800059ee:	854a                	mv	a0,s2
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	f8e080e7          	jalr	-114(ra) # 8000397e <itrunc>
    800059f8:	bfb1                	j	80005954 <sys_open+0xd2>
      fileclose(f);
    800059fa:	854e                	mv	a0,s3
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	d3c080e7          	jalr	-708(ra) # 80004738 <fileclose>
    iunlockput(ip);
    80005a04:	854a                	mv	a0,s2
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	0cc080e7          	jalr	204(ra) # 80003ad2 <iunlockput>
    end_op();
    80005a0e:	fffff097          	auipc	ra,0xfffff
    80005a12:	8a8080e7          	jalr	-1880(ra) # 800042b6 <end_op>
    return -1;
    80005a16:	54fd                	li	s1,-1
    80005a18:	b7b9                	j	80005966 <sys_open+0xe4>

0000000080005a1a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a1a:	7175                	addi	sp,sp,-144
    80005a1c:	e506                	sd	ra,136(sp)
    80005a1e:	e122                	sd	s0,128(sp)
    80005a20:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	814080e7          	jalr	-2028(ra) # 80004236 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a2a:	08000613          	li	a2,128
    80005a2e:	f7040593          	addi	a1,s0,-144
    80005a32:	4501                	li	a0,0
    80005a34:	ffffd097          	auipc	ra,0xffffd
    80005a38:	230080e7          	jalr	560(ra) # 80002c64 <argstr>
    80005a3c:	02054963          	bltz	a0,80005a6e <sys_mkdir+0x54>
    80005a40:	4681                	li	a3,0
    80005a42:	4601                	li	a2,0
    80005a44:	4585                	li	a1,1
    80005a46:	f7040513          	addi	a0,s0,-144
    80005a4a:	00000097          	auipc	ra,0x0
    80005a4e:	802080e7          	jalr	-2046(ra) # 8000524c <create>
    80005a52:	cd11                	beqz	a0,80005a6e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	07e080e7          	jalr	126(ra) # 80003ad2 <iunlockput>
  end_op();
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	85a080e7          	jalr	-1958(ra) # 800042b6 <end_op>
  return 0;
    80005a64:	4501                	li	a0,0
}
    80005a66:	60aa                	ld	ra,136(sp)
    80005a68:	640a                	ld	s0,128(sp)
    80005a6a:	6149                	addi	sp,sp,144
    80005a6c:	8082                	ret
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	848080e7          	jalr	-1976(ra) # 800042b6 <end_op>
    return -1;
    80005a76:	557d                	li	a0,-1
    80005a78:	b7fd                	j	80005a66 <sys_mkdir+0x4c>

0000000080005a7a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a7a:	7135                	addi	sp,sp,-160
    80005a7c:	ed06                	sd	ra,152(sp)
    80005a7e:	e922                	sd	s0,144(sp)
    80005a80:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	7b4080e7          	jalr	1972(ra) # 80004236 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a8a:	08000613          	li	a2,128
    80005a8e:	f7040593          	addi	a1,s0,-144
    80005a92:	4501                	li	a0,0
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	1d0080e7          	jalr	464(ra) # 80002c64 <argstr>
    80005a9c:	04054a63          	bltz	a0,80005af0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005aa0:	f6c40593          	addi	a1,s0,-148
    80005aa4:	4505                	li	a0,1
    80005aa6:	ffffd097          	auipc	ra,0xffffd
    80005aaa:	17a080e7          	jalr	378(ra) # 80002c20 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aae:	04054163          	bltz	a0,80005af0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ab2:	f6840593          	addi	a1,s0,-152
    80005ab6:	4509                	li	a0,2
    80005ab8:	ffffd097          	auipc	ra,0xffffd
    80005abc:	168080e7          	jalr	360(ra) # 80002c20 <argint>
     argint(1, &major) < 0 ||
    80005ac0:	02054863          	bltz	a0,80005af0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ac4:	f6841683          	lh	a3,-152(s0)
    80005ac8:	f6c41603          	lh	a2,-148(s0)
    80005acc:	458d                	li	a1,3
    80005ace:	f7040513          	addi	a0,s0,-144
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	77a080e7          	jalr	1914(ra) # 8000524c <create>
     argint(2, &minor) < 0 ||
    80005ada:	c919                	beqz	a0,80005af0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	ff6080e7          	jalr	-10(ra) # 80003ad2 <iunlockput>
  end_op();
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	7d2080e7          	jalr	2002(ra) # 800042b6 <end_op>
  return 0;
    80005aec:	4501                	li	a0,0
    80005aee:	a031                	j	80005afa <sys_mknod+0x80>
    end_op();
    80005af0:	ffffe097          	auipc	ra,0xffffe
    80005af4:	7c6080e7          	jalr	1990(ra) # 800042b6 <end_op>
    return -1;
    80005af8:	557d                	li	a0,-1
}
    80005afa:	60ea                	ld	ra,152(sp)
    80005afc:	644a                	ld	s0,144(sp)
    80005afe:	610d                	addi	sp,sp,160
    80005b00:	8082                	ret

0000000080005b02 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b02:	7135                	addi	sp,sp,-160
    80005b04:	ed06                	sd	ra,152(sp)
    80005b06:	e922                	sd	s0,144(sp)
    80005b08:	e526                	sd	s1,136(sp)
    80005b0a:	e14a                	sd	s2,128(sp)
    80005b0c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b0e:	ffffc097          	auipc	ra,0xffffc
    80005b12:	fd6080e7          	jalr	-42(ra) # 80001ae4 <myproc>
    80005b16:	892a                	mv	s2,a0
  
  begin_op();
    80005b18:	ffffe097          	auipc	ra,0xffffe
    80005b1c:	71e080e7          	jalr	1822(ra) # 80004236 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b20:	08000613          	li	a2,128
    80005b24:	f6040593          	addi	a1,s0,-160
    80005b28:	4501                	li	a0,0
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	13a080e7          	jalr	314(ra) # 80002c64 <argstr>
    80005b32:	04054b63          	bltz	a0,80005b88 <sys_chdir+0x86>
    80005b36:	f6040513          	addi	a0,s0,-160
    80005b3a:	ffffe097          	auipc	ra,0xffffe
    80005b3e:	4ee080e7          	jalr	1262(ra) # 80004028 <namei>
    80005b42:	84aa                	mv	s1,a0
    80005b44:	c131                	beqz	a0,80005b88 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	d28080e7          	jalr	-728(ra) # 8000386e <ilock>
  if(ip->type != T_DIR){
    80005b4e:	04449703          	lh	a4,68(s1)
    80005b52:	4785                	li	a5,1
    80005b54:	04f71063          	bne	a4,a5,80005b94 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b58:	8526                	mv	a0,s1
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	dd8080e7          	jalr	-552(ra) # 80003932 <iunlock>
  iput(p->cwd);
    80005b62:	15093503          	ld	a0,336(s2)
    80005b66:	ffffe097          	auipc	ra,0xffffe
    80005b6a:	ec4080e7          	jalr	-316(ra) # 80003a2a <iput>
  end_op();
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	748080e7          	jalr	1864(ra) # 800042b6 <end_op>
  p->cwd = ip;
    80005b76:	14993823          	sd	s1,336(s2)
  return 0;
    80005b7a:	4501                	li	a0,0
}
    80005b7c:	60ea                	ld	ra,152(sp)
    80005b7e:	644a                	ld	s0,144(sp)
    80005b80:	64aa                	ld	s1,136(sp)
    80005b82:	690a                	ld	s2,128(sp)
    80005b84:	610d                	addi	sp,sp,160
    80005b86:	8082                	ret
    end_op();
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	72e080e7          	jalr	1838(ra) # 800042b6 <end_op>
    return -1;
    80005b90:	557d                	li	a0,-1
    80005b92:	b7ed                	j	80005b7c <sys_chdir+0x7a>
    iunlockput(ip);
    80005b94:	8526                	mv	a0,s1
    80005b96:	ffffe097          	auipc	ra,0xffffe
    80005b9a:	f3c080e7          	jalr	-196(ra) # 80003ad2 <iunlockput>
    end_op();
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	718080e7          	jalr	1816(ra) # 800042b6 <end_op>
    return -1;
    80005ba6:	557d                	li	a0,-1
    80005ba8:	bfd1                	j	80005b7c <sys_chdir+0x7a>

0000000080005baa <sys_exec>:

uint64
sys_exec(void)
{
    80005baa:	7145                	addi	sp,sp,-464
    80005bac:	e786                	sd	ra,456(sp)
    80005bae:	e3a2                	sd	s0,448(sp)
    80005bb0:	ff26                	sd	s1,440(sp)
    80005bb2:	fb4a                	sd	s2,432(sp)
    80005bb4:	f74e                	sd	s3,424(sp)
    80005bb6:	f352                	sd	s4,416(sp)
    80005bb8:	ef56                	sd	s5,408(sp)
    80005bba:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bbc:	08000613          	li	a2,128
    80005bc0:	f4040593          	addi	a1,s0,-192
    80005bc4:	4501                	li	a0,0
    80005bc6:	ffffd097          	auipc	ra,0xffffd
    80005bca:	09e080e7          	jalr	158(ra) # 80002c64 <argstr>
    return -1;
    80005bce:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bd0:	0e054c63          	bltz	a0,80005cc8 <sys_exec+0x11e>
    80005bd4:	e3840593          	addi	a1,s0,-456
    80005bd8:	4505                	li	a0,1
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	068080e7          	jalr	104(ra) # 80002c42 <argaddr>
    80005be2:	0e054363          	bltz	a0,80005cc8 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80005be6:	e4040913          	addi	s2,s0,-448
    80005bea:	10000613          	li	a2,256
    80005bee:	4581                	li	a1,0
    80005bf0:	854a                	mv	a0,s2
    80005bf2:	ffffb097          	auipc	ra,0xffffb
    80005bf6:	1e0080e7          	jalr	480(ra) # 80000dd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bfa:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80005bfc:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005bfe:	02000a93          	li	s5,32
    80005c02:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c06:	00349513          	slli	a0,s1,0x3
    80005c0a:	e3040593          	addi	a1,s0,-464
    80005c0e:	e3843783          	ld	a5,-456(s0)
    80005c12:	953e                	add	a0,a0,a5
    80005c14:	ffffd097          	auipc	ra,0xffffd
    80005c18:	f70080e7          	jalr	-144(ra) # 80002b84 <fetchaddr>
    80005c1c:	02054a63          	bltz	a0,80005c50 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c20:	e3043783          	ld	a5,-464(s0)
    80005c24:	cfa9                	beqz	a5,80005c7e <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c26:	ffffb097          	auipc	ra,0xffffb
    80005c2a:	fc0080e7          	jalr	-64(ra) # 80000be6 <kalloc>
    80005c2e:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005c32:	cd19                	beqz	a0,80005c50 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c34:	6605                	lui	a2,0x1
    80005c36:	85aa                	mv	a1,a0
    80005c38:	e3043503          	ld	a0,-464(s0)
    80005c3c:	ffffd097          	auipc	ra,0xffffd
    80005c40:	f9c080e7          	jalr	-100(ra) # 80002bd8 <fetchstr>
    80005c44:	00054663          	bltz	a0,80005c50 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c48:	0485                	addi	s1,s1,1
    80005c4a:	0921                	addi	s2,s2,8
    80005c4c:	fb549be3          	bne	s1,s5,80005c02 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c50:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80005c54:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c56:	c92d                	beqz	a0,80005cc8 <sys_exec+0x11e>
    kfree(argv[i]);
    80005c58:	ffffb097          	auipc	ra,0xffffb
    80005c5c:	e8e080e7          	jalr	-370(ra) # 80000ae6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c60:	e4840493          	addi	s1,s0,-440
    80005c64:	10098993          	addi	s3,s3,256
    80005c68:	6088                	ld	a0,0(s1)
    80005c6a:	cd31                	beqz	a0,80005cc6 <sys_exec+0x11c>
    kfree(argv[i]);
    80005c6c:	ffffb097          	auipc	ra,0xffffb
    80005c70:	e7a080e7          	jalr	-390(ra) # 80000ae6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c74:	04a1                	addi	s1,s1,8
    80005c76:	ff3499e3          	bne	s1,s3,80005c68 <sys_exec+0xbe>
  return -1;
    80005c7a:	597d                	li	s2,-1
    80005c7c:	a0b1                	j	80005cc8 <sys_exec+0x11e>
      argv[i] = 0;
    80005c7e:	0a0e                	slli	s4,s4,0x3
    80005c80:	fc040793          	addi	a5,s0,-64
    80005c84:	9a3e                	add	s4,s4,a5
    80005c86:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80005c8a:	e4040593          	addi	a1,s0,-448
    80005c8e:	f4040513          	addi	a0,s0,-192
    80005c92:	fffff097          	auipc	ra,0xfffff
    80005c96:	166080e7          	jalr	358(ra) # 80004df8 <exec>
    80005c9a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c9c:	e4043503          	ld	a0,-448(s0)
    80005ca0:	c505                	beqz	a0,80005cc8 <sys_exec+0x11e>
    kfree(argv[i]);
    80005ca2:	ffffb097          	auipc	ra,0xffffb
    80005ca6:	e44080e7          	jalr	-444(ra) # 80000ae6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005caa:	e4840493          	addi	s1,s0,-440
    80005cae:	10098993          	addi	s3,s3,256
    80005cb2:	6088                	ld	a0,0(s1)
    80005cb4:	c911                	beqz	a0,80005cc8 <sys_exec+0x11e>
    kfree(argv[i]);
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	e30080e7          	jalr	-464(ra) # 80000ae6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	04a1                	addi	s1,s1,8
    80005cc0:	ff3499e3          	bne	s1,s3,80005cb2 <sys_exec+0x108>
    80005cc4:	a011                	j	80005cc8 <sys_exec+0x11e>
  return -1;
    80005cc6:	597d                	li	s2,-1
}
    80005cc8:	854a                	mv	a0,s2
    80005cca:	60be                	ld	ra,456(sp)
    80005ccc:	641e                	ld	s0,448(sp)
    80005cce:	74fa                	ld	s1,440(sp)
    80005cd0:	795a                	ld	s2,432(sp)
    80005cd2:	79ba                	ld	s3,424(sp)
    80005cd4:	7a1a                	ld	s4,416(sp)
    80005cd6:	6afa                	ld	s5,408(sp)
    80005cd8:	6179                	addi	sp,sp,464
    80005cda:	8082                	ret

0000000080005cdc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cdc:	7139                	addi	sp,sp,-64
    80005cde:	fc06                	sd	ra,56(sp)
    80005ce0:	f822                	sd	s0,48(sp)
    80005ce2:	f426                	sd	s1,40(sp)
    80005ce4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ce6:	ffffc097          	auipc	ra,0xffffc
    80005cea:	dfe080e7          	jalr	-514(ra) # 80001ae4 <myproc>
    80005cee:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cf0:	fd840593          	addi	a1,s0,-40
    80005cf4:	4501                	li	a0,0
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	f4c080e7          	jalr	-180(ra) # 80002c42 <argaddr>
    return -1;
    80005cfe:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d00:	0c054f63          	bltz	a0,80005dde <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    80005d04:	fc840593          	addi	a1,s0,-56
    80005d08:	fd040513          	addi	a0,s0,-48
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	d74080e7          	jalr	-652(ra) # 80004a80 <pipealloc>
    return -1;
    80005d14:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d16:	0c054463          	bltz	a0,80005dde <sys_pipe+0x102>
  fd0 = -1;
    80005d1a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d1e:	fd043503          	ld	a0,-48(s0)
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	4e2080e7          	jalr	1250(ra) # 80005204 <fdalloc>
    80005d2a:	fca42223          	sw	a0,-60(s0)
    80005d2e:	08054b63          	bltz	a0,80005dc4 <sys_pipe+0xe8>
    80005d32:	fc843503          	ld	a0,-56(s0)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	4ce080e7          	jalr	1230(ra) # 80005204 <fdalloc>
    80005d3e:	fca42023          	sw	a0,-64(s0)
    80005d42:	06054863          	bltz	a0,80005db2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d46:	4691                	li	a3,4
    80005d48:	fc440613          	addi	a2,s0,-60
    80005d4c:	fd843583          	ld	a1,-40(s0)
    80005d50:	68a8                	ld	a0,80(s1)
    80005d52:	ffffc097          	auipc	ra,0xffffc
    80005d56:	a6e080e7          	jalr	-1426(ra) # 800017c0 <copyout>
    80005d5a:	02054063          	bltz	a0,80005d7a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d5e:	4691                	li	a3,4
    80005d60:	fc040613          	addi	a2,s0,-64
    80005d64:	fd843583          	ld	a1,-40(s0)
    80005d68:	0591                	addi	a1,a1,4
    80005d6a:	68a8                	ld	a0,80(s1)
    80005d6c:	ffffc097          	auipc	ra,0xffffc
    80005d70:	a54080e7          	jalr	-1452(ra) # 800017c0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d74:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d76:	06055463          	bgez	a0,80005dde <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    80005d7a:	fc442783          	lw	a5,-60(s0)
    80005d7e:	07e9                	addi	a5,a5,26
    80005d80:	078e                	slli	a5,a5,0x3
    80005d82:	97a6                	add	a5,a5,s1
    80005d84:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d88:	fc042783          	lw	a5,-64(s0)
    80005d8c:	07e9                	addi	a5,a5,26
    80005d8e:	078e                	slli	a5,a5,0x3
    80005d90:	94be                	add	s1,s1,a5
    80005d92:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d96:	fd043503          	ld	a0,-48(s0)
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	99e080e7          	jalr	-1634(ra) # 80004738 <fileclose>
    fileclose(wf);
    80005da2:	fc843503          	ld	a0,-56(s0)
    80005da6:	fffff097          	auipc	ra,0xfffff
    80005daa:	992080e7          	jalr	-1646(ra) # 80004738 <fileclose>
    return -1;
    80005dae:	57fd                	li	a5,-1
    80005db0:	a03d                	j	80005dde <sys_pipe+0x102>
    if(fd0 >= 0)
    80005db2:	fc442783          	lw	a5,-60(s0)
    80005db6:	0007c763          	bltz	a5,80005dc4 <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005dba:	07e9                	addi	a5,a5,26
    80005dbc:	078e                	slli	a5,a5,0x3
    80005dbe:	94be                	add	s1,s1,a5
    80005dc0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005dc4:	fd043503          	ld	a0,-48(s0)
    80005dc8:	fffff097          	auipc	ra,0xfffff
    80005dcc:	970080e7          	jalr	-1680(ra) # 80004738 <fileclose>
    fileclose(wf);
    80005dd0:	fc843503          	ld	a0,-56(s0)
    80005dd4:	fffff097          	auipc	ra,0xfffff
    80005dd8:	964080e7          	jalr	-1692(ra) # 80004738 <fileclose>
    return -1;
    80005ddc:	57fd                	li	a5,-1
}
    80005dde:	853e                	mv	a0,a5
    80005de0:	70e2                	ld	ra,56(sp)
    80005de2:	7442                	ld	s0,48(sp)
    80005de4:	74a2                	ld	s1,40(sp)
    80005de6:	6121                	addi	sp,sp,64
    80005de8:	8082                	ret
    80005dea:	0000                	unimp
    80005dec:	0000                	unimp
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
    80005e30:	c1dfc0ef          	jal	ra,80002a4c <kerneltrap>
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
    80005ecc:	bf0080e7          	jalr	-1040(ra) # 80001ab8 <cpuid>
  
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
    80005f04:	bb8080e7          	jalr	-1096(ra) # 80001ab8 <cpuid>
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
    80005f2c:	b90080e7          	jalr	-1136(ra) # 80001ab8 <cpuid>
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
    80005f54:	0001e797          	auipc	a5,0x1e
    80005f58:	0ac78793          	addi	a5,a5,172 # 80024000 <disk>
    80005f5c:	00a78733          	add	a4,a5,a0
    80005f60:	6789                	lui	a5,0x2
    80005f62:	97ba                	add	a5,a5,a4
    80005f64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f68:	eba9                	bnez	a5,80005fba <free_desc+0x74>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005f6a:	00020797          	auipc	a5,0x20
    80005f6e:	09678793          	addi	a5,a5,150 # 80026000 <disk+0x2000>
    80005f72:	639c                	ld	a5,0(a5)
    80005f74:	00451713          	slli	a4,a0,0x4
    80005f78:	97ba                	add	a5,a5,a4
    80005f7a:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005f7e:	0001e797          	auipc	a5,0x1e
    80005f82:	08278793          	addi	a5,a5,130 # 80024000 <disk>
    80005f86:	97aa                	add	a5,a5,a0
    80005f88:	6509                	lui	a0,0x2
    80005f8a:	953e                	add	a0,a0,a5
    80005f8c:	4785                	li	a5,1
    80005f8e:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005f92:	00020517          	auipc	a0,0x20
    80005f96:	08650513          	addi	a0,a0,134 # 80026018 <disk+0x2018>
    80005f9a:	ffffc097          	auipc	ra,0xffffc
    80005f9e:	51e080e7          	jalr	1310(ra) # 800024b8 <wakeup>
}
    80005fa2:	60a2                	ld	ra,8(sp)
    80005fa4:	6402                	ld	s0,0(sp)
    80005fa6:	0141                	addi	sp,sp,16
    80005fa8:	8082                	ret
    panic("virtio_disk_intr 1");
    80005faa:	00002517          	auipc	a0,0x2
    80005fae:	7d650513          	addi	a0,a0,2006 # 80008780 <syscalls+0x368>
    80005fb2:	ffffa097          	auipc	ra,0xffffa
    80005fb6:	660080e7          	jalr	1632(ra) # 80000612 <panic>
    panic("virtio_disk_intr 2");
    80005fba:	00002517          	auipc	a0,0x2
    80005fbe:	7de50513          	addi	a0,a0,2014 # 80008798 <syscalls+0x380>
    80005fc2:	ffffa097          	auipc	ra,0xffffa
    80005fc6:	650080e7          	jalr	1616(ra) # 80000612 <panic>

0000000080005fca <virtio_disk_init>:
{
    80005fca:	1101                	addi	sp,sp,-32
    80005fcc:	ec06                	sd	ra,24(sp)
    80005fce:	e822                	sd	s0,16(sp)
    80005fd0:	e426                	sd	s1,8(sp)
    80005fd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fd4:	00002597          	auipc	a1,0x2
    80005fd8:	7dc58593          	addi	a1,a1,2012 # 800087b0 <syscalls+0x398>
    80005fdc:	00020517          	auipc	a0,0x20
    80005fe0:	0cc50513          	addi	a0,a0,204 # 800260a8 <disk+0x20a8>
    80005fe4:	ffffb097          	auipc	ra,0xffffb
    80005fe8:	c62080e7          	jalr	-926(ra) # 80000c46 <initlock>
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
    80006042:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
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
    80006074:	0001e517          	auipc	a0,0x1e
    80006078:	f8c50513          	addi	a0,a0,-116 # 80024000 <disk>
    8000607c:	ffffb097          	auipc	ra,0xffffb
    80006080:	d56080e7          	jalr	-682(ra) # 80000dd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006084:	0001e717          	auipc	a4,0x1e
    80006088:	f7c70713          	addi	a4,a4,-132 # 80024000 <disk>
    8000608c:	00c75793          	srli	a5,a4,0xc
    80006090:	2781                	sext.w	a5,a5
    80006092:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80006094:	00020797          	auipc	a5,0x20
    80006098:	f6c78793          	addi	a5,a5,-148 # 80026000 <disk+0x2000>
    8000609c:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    8000609e:	0001e717          	auipc	a4,0x1e
    800060a2:	fe270713          	addi	a4,a4,-30 # 80024080 <disk+0x80>
    800060a6:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    800060a8:	0001f717          	auipc	a4,0x1f
    800060ac:	f5870713          	addi	a4,a4,-168 # 80025000 <disk+0x1000>
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
    800060de:	00002517          	auipc	a0,0x2
    800060e2:	6e250513          	addi	a0,a0,1762 # 800087c0 <syscalls+0x3a8>
    800060e6:	ffffa097          	auipc	ra,0xffffa
    800060ea:	52c080e7          	jalr	1324(ra) # 80000612 <panic>
    panic("virtio disk has no queue 0");
    800060ee:	00002517          	auipc	a0,0x2
    800060f2:	6f250513          	addi	a0,a0,1778 # 800087e0 <syscalls+0x3c8>
    800060f6:	ffffa097          	auipc	ra,0xffffa
    800060fa:	51c080e7          	jalr	1308(ra) # 80000612 <panic>
    panic("virtio disk max queue too short");
    800060fe:	00002517          	auipc	a0,0x2
    80006102:	70250513          	addi	a0,a0,1794 # 80008800 <syscalls+0x3e8>
    80006106:	ffffa097          	auipc	ra,0xffffa
    8000610a:	50c080e7          	jalr	1292(ra) # 80000612 <panic>

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
    80006138:	00020517          	auipc	a0,0x20
    8000613c:	f7050513          	addi	a0,a0,-144 # 800260a8 <disk+0x20a8>
    80006140:	ffffb097          	auipc	ra,0xffffb
    80006144:	b96080e7          	jalr	-1130(ra) # 80000cd6 <acquire>
    if(disk.free[i]){
    80006148:	00020997          	auipc	s3,0x20
    8000614c:	eb898993          	addi	s3,s3,-328 # 80026000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80006150:	4b21                	li	s6,8
      disk.free[i] = 0;
    80006152:	0001ea97          	auipc	s5,0x1e
    80006156:	eaea8a93          	addi	s5,s5,-338 # 80024000 <disk>
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
    80006180:	00020697          	auipc	a3,0x20
    80006184:	e9968693          	addi	a3,a3,-359 # 80026019 <disk+0x2019>
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
    800061d2:	00020597          	auipc	a1,0x20
    800061d6:	ed658593          	addi	a1,a1,-298 # 800260a8 <disk+0x20a8>
    800061da:	00020517          	auipc	a0,0x20
    800061de:	e3e50513          	addi	a0,a0,-450 # 80026018 <disk+0x2018>
    800061e2:	ffffc097          	auipc	ra,0xffffc
    800061e6:	150080e7          	jalr	336(ra) # 80002332 <sleep>
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
    8000620c:	00020a17          	auipc	s4,0x20
    80006210:	df4a0a13          	addi	s4,s4,-524 # 80026000 <disk+0x2000>
    80006214:	000a3a83          	ld	s5,0(s4)
    80006218:	9aa6                	add	s5,s5,s1
    8000621a:	f9040513          	addi	a0,s0,-112
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	fac080e7          	jalr	-84(ra) # 800011ca <kvmpa>
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
    80006276:	0001e517          	auipc	a0,0x1e
    8000627a:	d8a50513          	addi	a0,a0,-630 # 80024000 <disk>
    8000627e:	00020797          	auipc	a5,0x20
    80006282:	d8278793          	addi	a5,a5,-638 # 80026000 <disk+0x2000>
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
    80006318:	00020997          	auipc	s3,0x20
    8000631c:	d9098993          	addi	s3,s3,-624 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006320:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006322:	85ce                	mv	a1,s3
    80006324:	854a                	mv	a0,s2
    80006326:	ffffc097          	auipc	ra,0xffffc
    8000632a:	00c080e7          	jalr	12(ra) # 80002332 <sleep>
  while(b->disk == 1) {
    8000632e:	00492783          	lw	a5,4(s2)
    80006332:	fe9788e3          	beq	a5,s1,80006322 <virtio_disk_rw+0x214>
  }

  disk.info[idx[0]].b = 0;
    80006336:	fa042483          	lw	s1,-96(s0)
    8000633a:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    8000633e:	00479713          	slli	a4,a5,0x4
    80006342:	0001e797          	auipc	a5,0x1e
    80006346:	cbe78793          	addi	a5,a5,-834 # 80024000 <disk>
    8000634a:	97ba                	add	a5,a5,a4
    8000634c:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006350:	00020917          	auipc	s2,0x20
    80006354:	cb090913          	addi	s2,s2,-848 # 80026000 <disk+0x2000>
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
    80006378:	00020797          	auipc	a5,0x20
    8000637c:	c8878793          	addi	a5,a5,-888 # 80026000 <disk+0x2000>
    80006380:	639c                	ld	a5,0(a5)
    80006382:	97ba                	add	a5,a5,a4
    80006384:	4689                	li	a3,2
    80006386:	00d79623          	sh	a3,12(a5)
    8000638a:	b5f5                	j	80006276 <virtio_disk_rw+0x168>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000638c:	00020517          	auipc	a0,0x20
    80006390:	d1c50513          	addi	a0,a0,-740 # 800260a8 <disk+0x20a8>
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	9f6080e7          	jalr	-1546(ra) # 80000d8a <release>
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
    800063d4:	00020517          	auipc	a0,0x20
    800063d8:	cd450513          	addi	a0,a0,-812 # 800260a8 <disk+0x20a8>
    800063dc:	ffffb097          	auipc	ra,0xffffb
    800063e0:	8fa080e7          	jalr	-1798(ra) # 80000cd6 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800063e4:	00020797          	auipc	a5,0x20
    800063e8:	c1c78793          	addi	a5,a5,-996 # 80026000 <disk+0x2000>
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
    8000640a:	0001e717          	auipc	a4,0x1e
    8000640e:	bf670713          	addi	a4,a4,-1034 # 80024000 <disk>
    80006412:	9736                	add	a4,a4,a3
    80006414:	03074703          	lbu	a4,48(a4)
    80006418:	ef31                	bnez	a4,80006474 <virtio_disk_intr+0xac>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000641a:	0001e917          	auipc	s2,0x1e
    8000641e:	be690913          	addi	s2,s2,-1050 # 80024000 <disk>
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006422:	00020497          	auipc	s1,0x20
    80006426:	bde48493          	addi	s1,s1,-1058 # 80026000 <disk+0x2000>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000642a:	20078793          	addi	a5,a5,512
    8000642e:	0792                	slli	a5,a5,0x4
    80006430:	97ca                	add	a5,a5,s2
    80006432:	7798                	ld	a4,40(a5)
    80006434:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006438:	7788                	ld	a0,40(a5)
    8000643a:	ffffc097          	auipc	ra,0xffffc
    8000643e:	07e080e7          	jalr	126(ra) # 800024b8 <wakeup>
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
    80006478:	3ac50513          	addi	a0,a0,940 # 80008820 <syscalls+0x408>
    8000647c:	ffffa097          	auipc	ra,0xffffa
    80006480:	196080e7          	jalr	406(ra) # 80000612 <panic>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006484:	10001737          	lui	a4,0x10001
    80006488:	533c                	lw	a5,96(a4)
    8000648a:	8b8d                	andi	a5,a5,3
    8000648c:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    8000648e:	00020517          	auipc	a0,0x20
    80006492:	c1a50513          	addi	a0,a0,-998 # 800260a8 <disk+0x20a8>
    80006496:	ffffb097          	auipc	ra,0xffffb
    8000649a:	8f4080e7          	jalr	-1804(ra) # 80000d8a <release>
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
