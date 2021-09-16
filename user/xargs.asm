
user/_xargs：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run>:
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"

void run(char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    // for (int i = 0; argv[i] != 0; ++i)
    // {
    //     printf("%s\n", argv[i]);
    // }
    int pid = fork();
   c:	00000097          	auipc	ra,0x0
  10:	3e0080e7          	jalr	992(ra) # 3ec <fork>
    if (pid == 0)
  14:	ed01                	bnez	a0,2c <run+0x2c>
    {
        exec(argv[0], argv);
  16:	85a6                	mv	a1,s1
  18:	6088                	ld	a0,0(s1)
  1a:	00000097          	auipc	ra,0x0
  1e:	412080e7          	jalr	1042(ra) # 42c <exec>
    else
    {
        wait(0);
    }
    return;
}
  22:	60e2                	ld	ra,24(sp)
  24:	6442                	ld	s0,16(sp)
  26:	64a2                	ld	s1,8(sp)
  28:	6105                	addi	sp,sp,32
  2a:	8082                	ret
        wait(0);
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3ce080e7          	jalr	974(ra) # 3fc <wait>
    return;
  36:	b7f5                	j	22 <run+0x22>

0000000000000038 <main>:

int main(int argc, char *argv[])
{
  38:	cc010113          	addi	sp,sp,-832
  3c:	32113c23          	sd	ra,824(sp)
  40:	32813823          	sd	s0,816(sp)
  44:	32913423          	sd	s1,808(sp)
  48:	33213023          	sd	s2,800(sp)
  4c:	31313c23          	sd	s3,792(sp)
  50:	0680                	addi	s0,sp,832
  52:	892a                	mv	s2,a0
  54:	84ae                	mv	s1,a1
    int p[2];
    pipe(p);
  56:	fc840513          	addi	a0,s0,-56
  5a:	00000097          	auipc	ra,0x0
  5e:	3aa080e7          	jalr	938(ra) # 404 <pipe>

    char *newargv[MAXARG];
    int newargc = argc - 1;

    if (argc > MAXARG)
  62:	02000793          	li	a5,32
  66:	0127df63          	ble	s2,a5,84 <main+0x4c>
    {
        printf("Too many arguments !\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	8ae50513          	addi	a0,a0,-1874 # 918 <malloc+0xec>
  72:	00000097          	auipc	ra,0x0
  76:	6fa080e7          	jalr	1786(ra) # 76c <printf>
        exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	378080e7          	jalr	888(ra) # 3f4 <exit>
    int newargc = argc - 1;
  84:	fff9099b          	addiw	s3,s2,-1
    }

    memset(newargv, 0, sizeof(newargv));
  88:	10000613          	li	a2,256
  8c:	4581                	li	a1,0
  8e:	ec840513          	addi	a0,s0,-312
  92:	00000097          	auipc	ra,0x0
  96:	14c080e7          	jalr	332(ra) # 1de <memset>

    for (int i = 0; i < argc - 1; ++i)
  9a:	03305463          	blez	s3,c2 <main+0x8a>
  9e:	00848593          	addi	a1,s1,8
  a2:	ec840793          	addi	a5,s0,-312
  a6:	ffe9071b          	addiw	a4,s2,-2
  aa:	1702                	slli	a4,a4,0x20
  ac:	9301                	srli	a4,a4,0x20
  ae:	070e                	slli	a4,a4,0x3
  b0:	ed040693          	addi	a3,s0,-304
  b4:	9736                	add	a4,a4,a3
        newargv[i] = argv[i + 1];
  b6:	6194                	ld	a3,0(a1)
  b8:	e394                	sd	a3,0(a5)
    for (int i = 0; i < argc - 1; ++i)
  ba:	05a1                	addi	a1,a1,8
  bc:	07a1                	addi	a5,a5,8
  be:	fee79ce3          	bne	a5,a4,b6 <main+0x7e>

    char buf[512];
    char *end = buf;
    newargv[newargc++] = buf;
  c2:	098e                	slli	s3,s3,0x3
  c4:	fd040793          	addi	a5,s0,-48
  c8:	99be                	add	s3,s3,a5
  ca:	cc840493          	addi	s1,s0,-824
  ce:	ee99bc23          	sd	s1,-264(s3)
    memset(buf, 0, sizeof(buf));
  d2:	20000613          	li	a2,512
  d6:	4581                	li	a1,0
  d8:	8526                	mv	a0,s1
  da:	00000097          	auipc	ra,0x0
  de:	104080e7          	jalr	260(ra) # 1de <memset>

    int runflag = 1;
  e2:	4985                	li	s3,1

    while (read(0, end, 1) == 1)
    {
        // printf("%s\n", buf);
        if (*end == '\n')
  e4:	4929                	li	s2,10
    while (read(0, end, 1) == 1)
  e6:	a02d                	j	110 <main+0xd8>
        {
            *end = 0;
  e8:	00048023          	sb	zero,0(s1)
            run(newargv);
  ec:	ec840513          	addi	a0,s0,-312
  f0:	00000097          	auipc	ra,0x0
  f4:	f10080e7          	jalr	-240(ra) # 0 <run>
            runflag = 0;
            memset(buf, 0, sizeof(buf));
  f8:	20000613          	li	a2,512
  fc:	4581                	li	a1,0
  fe:	cc840513          	addi	a0,s0,-824
 102:	00000097          	auipc	ra,0x0
 106:	0dc080e7          	jalr	220(ra) # 1de <memset>
            runflag = 0;
 10a:	4981                	li	s3,0
            end = buf;
 10c:	cc840493          	addi	s1,s0,-824
    while (read(0, end, 1) == 1)
 110:	4605                	li	a2,1
 112:	85a6                	mv	a1,s1
 114:	4501                	li	a0,0
 116:	00000097          	auipc	ra,0x0
 11a:	2f6080e7          	jalr	758(ra) # 40c <read>
 11e:	4785                	li	a5,1
 120:	00f51863          	bne	a0,a5,130 <main+0xf8>
        if (*end == '\n')
 124:	0004c783          	lbu	a5,0(s1)
 128:	fd2780e3          	beq	a5,s2,e8 <main+0xb0>
        }
        else
        {
            ++end;
 12c:	0485                	addi	s1,s1,1
 12e:	b7cd                	j	110 <main+0xd8>
        }
    }
    if (end != buf)
 130:	cc840793          	addi	a5,s0,-824
 134:	00f48f63          	beq	s1,a5,152 <main+0x11a>
    {
        ++end;
        *end = 0;
 138:	000480a3          	sb	zero,1(s1)
        run(newargv);
 13c:	ec840513          	addi	a0,s0,-312
 140:	00000097          	auipc	ra,0x0
 144:	ec0080e7          	jalr	-320(ra) # 0 <run>
    }

    if (runflag)
        run(newargv);

    exit(0);
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	2aa080e7          	jalr	682(ra) # 3f4 <exit>
    if (runflag)
 152:	fe098be3          	beqz	s3,148 <main+0x110>
        run(newargv);
 156:	ec840513          	addi	a0,s0,-312
 15a:	00000097          	auipc	ra,0x0
 15e:	ea6080e7          	jalr	-346(ra) # 0 <run>
 162:	b7dd                	j	148 <main+0x110>

0000000000000164 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 16a:	87aa                	mv	a5,a0
 16c:	0585                	addi	a1,a1,1
 16e:	0785                	addi	a5,a5,1
 170:	fff5c703          	lbu	a4,-1(a1)
 174:	fee78fa3          	sb	a4,-1(a5)
 178:	fb75                	bnez	a4,16c <strcpy+0x8>
    ;
  return os;
}
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strcmp+0x26>
 18c:	0005c703          	lbu	a4,0(a1)
 190:	00f71b63          	bne	a4,a5,1a6 <strcmp+0x26>
    p++, q++;
 194:	0505                	addi	a0,a0,1
 196:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 198:	00054783          	lbu	a5,0(a0)
 19c:	c789                	beqz	a5,1a6 <strcmp+0x26>
 19e:	0005c703          	lbu	a4,0(a1)
 1a2:	fef709e3          	beq	a4,a5,194 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	4685                	li	a3,1
 1c6:	9e89                	subw	a3,a3,a0
 1c8:	00f6853b          	addw	a0,a3,a5
 1cc:	0785                	addi	a5,a5,1
 1ce:	fff7c703          	lbu	a4,-1(a5)
 1d2:	fb7d                	bnez	a4,1c8 <strlen+0x14>
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ce09                	beqz	a2,1fe <memset+0x20>
 1e6:	87aa                	mv	a5,a0
 1e8:	fff6071b          	addiw	a4,a2,-1
 1ec:	1702                	slli	a4,a4,0x20
 1ee:	9301                	srli	a4,a4,0x20
 1f0:	0705                	addi	a4,a4,1
 1f2:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1f4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f8:	0785                	addi	a5,a5,1
 1fa:	fee79de3          	bne	a5,a4,1f4 <memset+0x16>
  }
  return dst;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret

0000000000000204 <strchr>:

char*
strchr(const char *s, char c)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  for(; *s; s++)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	cf91                	beqz	a5,22a <strchr+0x26>
    if(*s == c)
 210:	00f58a63          	beq	a1,a5,224 <strchr+0x20>
  for(; *s; s++)
 214:	0505                	addi	a0,a0,1
 216:	00054783          	lbu	a5,0(a0)
 21a:	c781                	beqz	a5,222 <strchr+0x1e>
    if(*s == c)
 21c:	feb79ce3          	bne	a5,a1,214 <strchr+0x10>
 220:	a011                	j	224 <strchr+0x20>
      return (char*)s;
  return 0;
 222:	4501                	li	a0,0
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
  return 0;
 22a:	4501                	li	a0,0
 22c:	bfe5                	j	224 <strchr+0x20>

000000000000022e <gets>:

char*
gets(char *buf, int max)
{
 22e:	711d                	addi	sp,sp,-96
 230:	ec86                	sd	ra,88(sp)
 232:	e8a2                	sd	s0,80(sp)
 234:	e4a6                	sd	s1,72(sp)
 236:	e0ca                	sd	s2,64(sp)
 238:	fc4e                	sd	s3,56(sp)
 23a:	f852                	sd	s4,48(sp)
 23c:	f456                	sd	s5,40(sp)
 23e:	f05a                	sd	s6,32(sp)
 240:	ec5e                	sd	s7,24(sp)
 242:	1080                	addi	s0,sp,96
 244:	8baa                	mv	s7,a0
 246:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 248:	892a                	mv	s2,a0
 24a:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 24c:	4aa9                	li	s5,10
 24e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 250:	0019849b          	addiw	s1,s3,1
 254:	0344d863          	ble	s4,s1,284 <gets+0x56>
    cc = read(0, &c, 1);
 258:	4605                	li	a2,1
 25a:	faf40593          	addi	a1,s0,-81
 25e:	4501                	li	a0,0
 260:	00000097          	auipc	ra,0x0
 264:	1ac080e7          	jalr	428(ra) # 40c <read>
    if(cc < 1)
 268:	00a05e63          	blez	a0,284 <gets+0x56>
    buf[i++] = c;
 26c:	faf44783          	lbu	a5,-81(s0)
 270:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 274:	01578763          	beq	a5,s5,282 <gets+0x54>
 278:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 27a:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 27c:	fd679ae3          	bne	a5,s6,250 <gets+0x22>
 280:	a011                	j	284 <gets+0x56>
  for(i=0; i+1 < max; ){
 282:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 284:	99de                	add	s3,s3,s7
 286:	00098023          	sb	zero,0(s3)
  return buf;
}
 28a:	855e                	mv	a0,s7
 28c:	60e6                	ld	ra,88(sp)
 28e:	6446                	ld	s0,80(sp)
 290:	64a6                	ld	s1,72(sp)
 292:	6906                	ld	s2,64(sp)
 294:	79e2                	ld	s3,56(sp)
 296:	7a42                	ld	s4,48(sp)
 298:	7aa2                	ld	s5,40(sp)
 29a:	7b02                	ld	s6,32(sp)
 29c:	6be2                	ld	s7,24(sp)
 29e:	6125                	addi	sp,sp,96
 2a0:	8082                	ret

00000000000002a2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a2:	1101                	addi	sp,sp,-32
 2a4:	ec06                	sd	ra,24(sp)
 2a6:	e822                	sd	s0,16(sp)
 2a8:	e426                	sd	s1,8(sp)
 2aa:	e04a                	sd	s2,0(sp)
 2ac:	1000                	addi	s0,sp,32
 2ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b0:	4581                	li	a1,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	182080e7          	jalr	386(ra) # 434 <open>
  if(fd < 0)
 2ba:	02054563          	bltz	a0,2e4 <stat+0x42>
 2be:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c0:	85ca                	mv	a1,s2
 2c2:	00000097          	auipc	ra,0x0
 2c6:	18a080e7          	jalr	394(ra) # 44c <fstat>
 2ca:	892a                	mv	s2,a0
  close(fd);
 2cc:	8526                	mv	a0,s1
 2ce:	00000097          	auipc	ra,0x0
 2d2:	14e080e7          	jalr	334(ra) # 41c <close>
  return r;
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	64a2                	ld	s1,8(sp)
 2de:	6902                	ld	s2,0(sp)
 2e0:	6105                	addi	sp,sp,32
 2e2:	8082                	ret
    return -1;
 2e4:	597d                	li	s2,-1
 2e6:	bfc5                	j	2d6 <stat+0x34>

00000000000002e8 <atoi>:

int
atoi(const char *s)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ee:	00054683          	lbu	a3,0(a0)
 2f2:	fd06879b          	addiw	a5,a3,-48
 2f6:	0ff7f793          	andi	a5,a5,255
 2fa:	4725                	li	a4,9
 2fc:	02f76963          	bltu	a4,a5,32e <atoi+0x46>
 300:	862a                	mv	a2,a0
  n = 0;
 302:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 304:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 306:	0605                	addi	a2,a2,1
 308:	0025179b          	slliw	a5,a0,0x2
 30c:	9fa9                	addw	a5,a5,a0
 30e:	0017979b          	slliw	a5,a5,0x1
 312:	9fb5                	addw	a5,a5,a3
 314:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 318:	00064683          	lbu	a3,0(a2)
 31c:	fd06871b          	addiw	a4,a3,-48
 320:	0ff77713          	andi	a4,a4,255
 324:	fee5f1e3          	bleu	a4,a1,306 <atoi+0x1e>
  return n;
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  n = 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <atoi+0x40>

0000000000000332 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 338:	02b57663          	bleu	a1,a0,364 <memmove+0x32>
    while(n-- > 0)
 33c:	02c05163          	blez	a2,35e <memmove+0x2c>
 340:	fff6079b          	addiw	a5,a2,-1
 344:	1782                	slli	a5,a5,0x20
 346:	9381                	srli	a5,a5,0x20
 348:	0785                	addi	a5,a5,1
 34a:	97aa                	add	a5,a5,a0
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
    dst += n;
 364:	00c50733          	add	a4,a0,a2
    src += n;
 368:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36a:	fec05ae3          	blez	a2,35e <memmove+0x2c>
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	fff7c793          	not	a5,a5
 37a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37c:	15fd                	addi	a1,a1,-1
 37e:	177d                	addi	a4,a4,-1
 380:	0005c683          	lbu	a3,0(a1)
 384:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 388:	fef71ae3          	bne	a4,a5,37c <memmove+0x4a>
 38c:	bfc9                	j	35e <memmove+0x2c>

000000000000038e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 394:	ce15                	beqz	a2,3d0 <memcmp+0x42>
 396:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	02e79063          	bne	a5,a4,3c2 <memcmp+0x34>
 3a6:	1682                	slli	a3,a3,0x20
 3a8:	9281                	srli	a3,a3,0x20
 3aa:	0685                	addi	a3,a3,1
 3ac:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	00d50d63          	beq	a0,a3,3cc <memcmp+0x3e>
    if (*p1 != *p2) {
 3b6:	00054783          	lbu	a5,0(a0)
 3ba:	0005c703          	lbu	a4,0(a1)
 3be:	fee788e3          	beq	a5,a4,3ae <memcmp+0x20>
      return *p1 - *p2;
 3c2:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
  return 0;
 3cc:	4501                	li	a0,0
 3ce:	bfe5                	j	3c6 <memcmp+0x38>
 3d0:	4501                	li	a0,0
 3d2:	bfd5                	j	3c6 <memcmp+0x38>

00000000000003d4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e406                	sd	ra,8(sp)
 3d8:	e022                	sd	s0,0(sp)
 3da:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3dc:	00000097          	auipc	ra,0x0
 3e0:	f56080e7          	jalr	-170(ra) # 332 <memmove>
}
 3e4:	60a2                	ld	ra,8(sp)
 3e6:	6402                	ld	s0,0(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ec:	4885                	li	a7,1
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f4:	4889                	li	a7,2
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fc:	488d                	li	a7,3
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 404:	4891                	li	a7,4
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <read>:
.global read
read:
 li a7, SYS_read
 40c:	4895                	li	a7,5
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <write>:
.global write
write:
 li a7, SYS_write
 414:	48c1                	li	a7,16
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <close>:
.global close
close:
 li a7, SYS_close
 41c:	48d5                	li	a7,21
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <kill>:
.global kill
kill:
 li a7, SYS_kill
 424:	4899                	li	a7,6
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <exec>:
.global exec
exec:
 li a7, SYS_exec
 42c:	489d                	li	a7,7
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <open>:
.global open
open:
 li a7, SYS_open
 434:	48bd                	li	a7,15
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43c:	48c5                	li	a7,17
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 444:	48c9                	li	a7,18
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44c:	48a1                	li	a7,8
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <link>:
.global link
link:
 li a7, SYS_link
 454:	48cd                	li	a7,19
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45c:	48d1                	li	a7,20
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 464:	48a5                	li	a7,9
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <dup>:
.global dup
dup:
 li a7, SYS_dup
 46c:	48a9                	li	a7,10
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 474:	48ad                	li	a7,11
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 47c:	48b1                	li	a7,12
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 484:	48b5                	li	a7,13
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48c:	48b9                	li	a7,14
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 494:	1101                	addi	sp,sp,-32
 496:	ec06                	sd	ra,24(sp)
 498:	e822                	sd	s0,16(sp)
 49a:	1000                	addi	s0,sp,32
 49c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	fef40593          	addi	a1,s0,-17
 4a6:	00000097          	auipc	ra,0x0
 4aa:	f6e080e7          	jalr	-146(ra) # 414 <write>
}
 4ae:	60e2                	ld	ra,24(sp)
 4b0:	6442                	ld	s0,16(sp)
 4b2:	6105                	addi	sp,sp,32
 4b4:	8082                	ret

00000000000004b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b6:	7139                	addi	sp,sp,-64
 4b8:	fc06                	sd	ra,56(sp)
 4ba:	f822                	sd	s0,48(sp)
 4bc:	f426                	sd	s1,40(sp)
 4be:	f04a                	sd	s2,32(sp)
 4c0:	ec4e                	sd	s3,24(sp)
 4c2:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c4:	c299                	beqz	a3,4ca <printint+0x14>
 4c6:	0005cd63          	bltz	a1,4e0 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ca:	2581                	sext.w	a1,a1
  neg = 0;
 4cc:	4301                	li	t1,0
 4ce:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 4d2:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 4d4:	2601                	sext.w	a2,a2
 4d6:	00000897          	auipc	a7,0x0
 4da:	45a88893          	addi	a7,a7,1114 # 930 <digits>
 4de:	a801                	j	4ee <printint+0x38>
    x = -xx;
 4e0:	40b005bb          	negw	a1,a1
 4e4:	2581                	sext.w	a1,a1
    neg = 1;
 4e6:	4305                	li	t1,1
    x = -xx;
 4e8:	b7dd                	j	4ce <printint+0x18>
  }while((x /= base) != 0);
 4ea:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 4ec:	8836                	mv	a6,a3
 4ee:	0018069b          	addiw	a3,a6,1
 4f2:	02c5f7bb          	remuw	a5,a1,a2
 4f6:	1782                	slli	a5,a5,0x20
 4f8:	9381                	srli	a5,a5,0x20
 4fa:	97c6                	add	a5,a5,a7
 4fc:	0007c783          	lbu	a5,0(a5)
 500:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 504:	0705                	addi	a4,a4,1
 506:	02c5d7bb          	divuw	a5,a1,a2
 50a:	fec5f0e3          	bleu	a2,a1,4ea <printint+0x34>
  if(neg)
 50e:	00030b63          	beqz	t1,524 <printint+0x6e>
    buf[i++] = '-';
 512:	fd040793          	addi	a5,s0,-48
 516:	96be                	add	a3,a3,a5
 518:	02d00793          	li	a5,45
 51c:	fef68823          	sb	a5,-16(a3)
 520:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 524:	02d05963          	blez	a3,556 <printint+0xa0>
 528:	89aa                	mv	s3,a0
 52a:	fc040793          	addi	a5,s0,-64
 52e:	00d784b3          	add	s1,a5,a3
 532:	fff78913          	addi	s2,a5,-1
 536:	9936                	add	s2,s2,a3
 538:	36fd                	addiw	a3,a3,-1
 53a:	1682                	slli	a3,a3,0x20
 53c:	9281                	srli	a3,a3,0x20
 53e:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 542:	fff4c583          	lbu	a1,-1(s1)
 546:	854e                	mv	a0,s3
 548:	00000097          	auipc	ra,0x0
 54c:	f4c080e7          	jalr	-180(ra) # 494 <putc>
  while(--i >= 0)
 550:	14fd                	addi	s1,s1,-1
 552:	ff2498e3          	bne	s1,s2,542 <printint+0x8c>
}
 556:	70e2                	ld	ra,56(sp)
 558:	7442                	ld	s0,48(sp)
 55a:	74a2                	ld	s1,40(sp)
 55c:	7902                	ld	s2,32(sp)
 55e:	69e2                	ld	s3,24(sp)
 560:	6121                	addi	sp,sp,64
 562:	8082                	ret

0000000000000564 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 564:	7119                	addi	sp,sp,-128
 566:	fc86                	sd	ra,120(sp)
 568:	f8a2                	sd	s0,112(sp)
 56a:	f4a6                	sd	s1,104(sp)
 56c:	f0ca                	sd	s2,96(sp)
 56e:	ecce                	sd	s3,88(sp)
 570:	e8d2                	sd	s4,80(sp)
 572:	e4d6                	sd	s5,72(sp)
 574:	e0da                	sd	s6,64(sp)
 576:	fc5e                	sd	s7,56(sp)
 578:	f862                	sd	s8,48(sp)
 57a:	f466                	sd	s9,40(sp)
 57c:	f06a                	sd	s10,32(sp)
 57e:	ec6e                	sd	s11,24(sp)
 580:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 582:	0005c483          	lbu	s1,0(a1)
 586:	18048d63          	beqz	s1,720 <vprintf+0x1bc>
 58a:	8aaa                	mv	s5,a0
 58c:	8b32                	mv	s6,a2
 58e:	00158913          	addi	s2,a1,1
  state = 0;
 592:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 594:	02500a13          	li	s4,37
      if(c == 'd'){
 598:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 59c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5a0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5a4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a8:	00000b97          	auipc	s7,0x0
 5ac:	388b8b93          	addi	s7,s7,904 # 930 <digits>
 5b0:	a839                	j	5ce <vprintf+0x6a>
        putc(fd, c);
 5b2:	85a6                	mv	a1,s1
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	ede080e7          	jalr	-290(ra) # 494 <putc>
 5be:	a019                	j	5c4 <vprintf+0x60>
    } else if(state == '%'){
 5c0:	01498f63          	beq	s3,s4,5de <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c4:	0905                	addi	s2,s2,1
 5c6:	fff94483          	lbu	s1,-1(s2)
 5ca:	14048b63          	beqz	s1,720 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 5ce:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5d2:	fe0997e3          	bnez	s3,5c0 <vprintf+0x5c>
      if(c == '%'){
 5d6:	fd479ee3          	bne	a5,s4,5b2 <vprintf+0x4e>
        state = '%';
 5da:	89be                	mv	s3,a5
 5dc:	b7e5                	j	5c4 <vprintf+0x60>
      if(c == 'd'){
 5de:	05878063          	beq	a5,s8,61e <vprintf+0xba>
      } else if(c == 'l') {
 5e2:	05978c63          	beq	a5,s9,63a <vprintf+0xd6>
      } else if(c == 'x') {
 5e6:	07a78863          	beq	a5,s10,656 <vprintf+0xf2>
      } else if(c == 'p') {
 5ea:	09b78463          	beq	a5,s11,672 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ee:	07300713          	li	a4,115
 5f2:	0ce78563          	beq	a5,a4,6bc <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f6:	06300713          	li	a4,99
 5fa:	0ee78c63          	beq	a5,a4,6f2 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5fe:	11478663          	beq	a5,s4,70a <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 602:	85d2                	mv	a1,s4
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e8e080e7          	jalr	-370(ra) # 494 <putc>
        putc(fd, c);
 60e:	85a6                	mv	a1,s1
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e82080e7          	jalr	-382(ra) # 494 <putc>
      }
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b765                	j	5c4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 61e:	008b0493          	addi	s1,s6,8
 622:	4685                	li	a3,1
 624:	4629                	li	a2,10
 626:	000b2583          	lw	a1,0(s6)
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	e8a080e7          	jalr	-374(ra) # 4b6 <printint>
 634:	8b26                	mv	s6,s1
      state = 0;
 636:	4981                	li	s3,0
 638:	b771                	j	5c4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 63a:	008b0493          	addi	s1,s6,8
 63e:	4681                	li	a3,0
 640:	4629                	li	a2,10
 642:	000b2583          	lw	a1,0(s6)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e6e080e7          	jalr	-402(ra) # 4b6 <printint>
 650:	8b26                	mv	s6,s1
      state = 0;
 652:	4981                	li	s3,0
 654:	bf85                	j	5c4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 656:	008b0493          	addi	s1,s6,8
 65a:	4681                	li	a3,0
 65c:	4641                	li	a2,16
 65e:	000b2583          	lw	a1,0(s6)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e52080e7          	jalr	-430(ra) # 4b6 <printint>
 66c:	8b26                	mv	s6,s1
      state = 0;
 66e:	4981                	li	s3,0
 670:	bf91                	j	5c4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 672:	008b0793          	addi	a5,s6,8
 676:	f8f43423          	sd	a5,-120(s0)
 67a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 67e:	03000593          	li	a1,48
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	e10080e7          	jalr	-496(ra) # 494 <putc>
  putc(fd, 'x');
 68c:	85ea                	mv	a1,s10
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e04080e7          	jalr	-508(ra) # 494 <putc>
 698:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69a:	03c9d793          	srli	a5,s3,0x3c
 69e:	97de                	add	a5,a5,s7
 6a0:	0007c583          	lbu	a1,0(a5)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	dee080e7          	jalr	-530(ra) # 494 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ae:	0992                	slli	s3,s3,0x4
 6b0:	34fd                	addiw	s1,s1,-1
 6b2:	f4e5                	bnez	s1,69a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6b4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b729                	j	5c4 <vprintf+0x60>
        s = va_arg(ap, char*);
 6bc:	008b0993          	addi	s3,s6,8
 6c0:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 6c4:	c085                	beqz	s1,6e4 <vprintf+0x180>
        while(*s != 0){
 6c6:	0004c583          	lbu	a1,0(s1)
 6ca:	c9a1                	beqz	a1,71a <vprintf+0x1b6>
          putc(fd, *s);
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	dc6080e7          	jalr	-570(ra) # 494 <putc>
          s++;
 6d6:	0485                	addi	s1,s1,1
        while(*s != 0){
 6d8:	0004c583          	lbu	a1,0(s1)
 6dc:	f9e5                	bnez	a1,6cc <vprintf+0x168>
        s = va_arg(ap, char*);
 6de:	8b4e                	mv	s6,s3
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	b5cd                	j	5c4 <vprintf+0x60>
          s = "(null)";
 6e4:	00000497          	auipc	s1,0x0
 6e8:	26448493          	addi	s1,s1,612 # 948 <digits+0x18>
        while(*s != 0){
 6ec:	02800593          	li	a1,40
 6f0:	bff1                	j	6cc <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 6f2:	008b0493          	addi	s1,s6,8
 6f6:	000b4583          	lbu	a1,0(s6)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	d98080e7          	jalr	-616(ra) # 494 <putc>
 704:	8b26                	mv	s6,s1
      state = 0;
 706:	4981                	li	s3,0
 708:	bd75                	j	5c4 <vprintf+0x60>
        putc(fd, c);
 70a:	85d2                	mv	a1,s4
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	d86080e7          	jalr	-634(ra) # 494 <putc>
      state = 0;
 716:	4981                	li	s3,0
 718:	b575                	j	5c4 <vprintf+0x60>
        s = va_arg(ap, char*);
 71a:	8b4e                	mv	s6,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b55d                	j	5c4 <vprintf+0x60>
    }
  }
}
 720:	70e6                	ld	ra,120(sp)
 722:	7446                	ld	s0,112(sp)
 724:	74a6                	ld	s1,104(sp)
 726:	7906                	ld	s2,96(sp)
 728:	69e6                	ld	s3,88(sp)
 72a:	6a46                	ld	s4,80(sp)
 72c:	6aa6                	ld	s5,72(sp)
 72e:	6b06                	ld	s6,64(sp)
 730:	7be2                	ld	s7,56(sp)
 732:	7c42                	ld	s8,48(sp)
 734:	7ca2                	ld	s9,40(sp)
 736:	7d02                	ld	s10,32(sp)
 738:	6de2                	ld	s11,24(sp)
 73a:	6109                	addi	sp,sp,128
 73c:	8082                	ret

000000000000073e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73e:	715d                	addi	sp,sp,-80
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e010                	sd	a2,0(s0)
 748:	e414                	sd	a3,8(s0)
 74a:	e818                	sd	a4,16(s0)
 74c:	ec1c                	sd	a5,24(s0)
 74e:	03043023          	sd	a6,32(s0)
 752:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75a:	8622                	mv	a2,s0
 75c:	00000097          	auipc	ra,0x0
 760:	e08080e7          	jalr	-504(ra) # 564 <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6161                	addi	sp,sp,80
 76a:	8082                	ret

000000000000076c <printf>:

void
printf(const char *fmt, ...)
{
 76c:	711d                	addi	sp,sp,-96
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e40c                	sd	a1,8(s0)
 776:	e810                	sd	a2,16(s0)
 778:	ec14                	sd	a3,24(s0)
 77a:	f018                	sd	a4,32(s0)
 77c:	f41c                	sd	a5,40(s0)
 77e:	03043823          	sd	a6,48(s0)
 782:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	00840613          	addi	a2,s0,8
 78a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78e:	85aa                	mv	a1,a0
 790:	4505                	li	a0,1
 792:	00000097          	auipc	ra,0x0
 796:	dd2080e7          	jalr	-558(ra) # 564 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6125                	addi	sp,sp,96
 7a0:	8082                	ret

00000000000007a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a2:	1141                	addi	sp,sp,-16
 7a4:	e422                	sd	s0,8(sp)
 7a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	00000797          	auipc	a5,0x0
 7b0:	1a478793          	addi	a5,a5,420 # 950 <__bss_start>
 7b4:	639c                	ld	a5,0(a5)
 7b6:	a805                	j	7e6 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b8:	4618                	lw	a4,8(a2)
 7ba:	9db9                	addw	a1,a1,a4
 7bc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	6398                	ld	a4,0(a5)
 7c2:	6318                	ld	a4,0(a4)
 7c4:	fee53823          	sd	a4,-16(a0)
 7c8:	a091                	j	80c <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ca:	ff852703          	lw	a4,-8(a0)
 7ce:	9e39                	addw	a2,a2,a4
 7d0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7d2:	ff053703          	ld	a4,-16(a0)
 7d6:	e398                	sd	a4,0(a5)
 7d8:	a099                	j	81e <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e7e463          	bltu	a5,a4,7e4 <free+0x42>
 7e0:	00e6ea63          	bltu	a3,a4,7f4 <free+0x52>
{
 7e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	fed7fae3          	bleu	a3,a5,7da <free+0x38>
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e6e463          	bltu	a3,a4,7f4 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	fee7eae3          	bltu	a5,a4,7e4 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 7f4:	ff852583          	lw	a1,-8(a0)
 7f8:	6390                	ld	a2,0(a5)
 7fa:	02059713          	slli	a4,a1,0x20
 7fe:	9301                	srli	a4,a4,0x20
 800:	0712                	slli	a4,a4,0x4
 802:	9736                	add	a4,a4,a3
 804:	fae60ae3          	beq	a2,a4,7b8 <free+0x16>
    bp->s.ptr = p->s.ptr;
 808:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80c:	4790                	lw	a2,8(a5)
 80e:	02061713          	slli	a4,a2,0x20
 812:	9301                	srli	a4,a4,0x20
 814:	0712                	slli	a4,a4,0x4
 816:	973e                	add	a4,a4,a5
 818:	fae689e3          	beq	a3,a4,7ca <free+0x28>
  } else
    p->s.ptr = bp;
 81c:	e394                	sd	a3,0(a5)
  freep = p;
 81e:	00000717          	auipc	a4,0x0
 822:	12f73923          	sd	a5,306(a4) # 950 <__bss_start>
}
 826:	6422                	ld	s0,8(sp)
 828:	0141                	addi	sp,sp,16
 82a:	8082                	ret

000000000000082c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82c:	7139                	addi	sp,sp,-64
 82e:	fc06                	sd	ra,56(sp)
 830:	f822                	sd	s0,48(sp)
 832:	f426                	sd	s1,40(sp)
 834:	f04a                	sd	s2,32(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	e852                	sd	s4,16(sp)
 83a:	e456                	sd	s5,8(sp)
 83c:	e05a                	sd	s6,0(sp)
 83e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051993          	slli	s3,a0,0x20
 844:	0209d993          	srli	s3,s3,0x20
 848:	09bd                	addi	s3,s3,15
 84a:	0049d993          	srli	s3,s3,0x4
 84e:	2985                	addiw	s3,s3,1
 850:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 854:	00000797          	auipc	a5,0x0
 858:	0fc78793          	addi	a5,a5,252 # 950 <__bss_start>
 85c:	6388                	ld	a0,0(a5)
 85e:	c515                	beqz	a0,88a <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 860:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 862:	4798                	lw	a4,8(a5)
 864:	03277f63          	bleu	s2,a4,8a2 <malloc+0x76>
 868:	8a4e                	mv	s4,s3
 86a:	0009871b          	sext.w	a4,s3
 86e:	6685                	lui	a3,0x1
 870:	00d77363          	bleu	a3,a4,876 <malloc+0x4a>
 874:	6a05                	lui	s4,0x1
 876:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 87a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87e:	00000497          	auipc	s1,0x0
 882:	0d248493          	addi	s1,s1,210 # 950 <__bss_start>
  if(p == (char*)-1)
 886:	5b7d                	li	s6,-1
 888:	a885                	j	8f8 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 88a:	00000797          	auipc	a5,0x0
 88e:	0ce78793          	addi	a5,a5,206 # 958 <base>
 892:	00000717          	auipc	a4,0x0
 896:	0af73f23          	sd	a5,190(a4) # 950 <__bss_start>
 89a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 89c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a0:	b7e1                	j	868 <malloc+0x3c>
      if(p->s.size == nunits)
 8a2:	02e90b63          	beq	s2,a4,8d8 <malloc+0xac>
        p->s.size -= nunits;
 8a6:	4137073b          	subw	a4,a4,s3
 8aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ac:	1702                	slli	a4,a4,0x20
 8ae:	9301                	srli	a4,a4,0x20
 8b0:	0712                	slli	a4,a4,0x4
 8b2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b8:	00000717          	auipc	a4,0x0
 8bc:	08a73c23          	sd	a0,152(a4) # 950 <__bss_start>
      return (void*)(p + 1);
 8c0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c4:	70e2                	ld	ra,56(sp)
 8c6:	7442                	ld	s0,48(sp)
 8c8:	74a2                	ld	s1,40(sp)
 8ca:	7902                	ld	s2,32(sp)
 8cc:	69e2                	ld	s3,24(sp)
 8ce:	6a42                	ld	s4,16(sp)
 8d0:	6aa2                	ld	s5,8(sp)
 8d2:	6b02                	ld	s6,0(sp)
 8d4:	6121                	addi	sp,sp,64
 8d6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d8:	6398                	ld	a4,0(a5)
 8da:	e118                	sd	a4,0(a0)
 8dc:	bff1                	j	8b8 <malloc+0x8c>
  hp->s.size = nu;
 8de:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 8e2:	0541                	addi	a0,a0,16
 8e4:	00000097          	auipc	ra,0x0
 8e8:	ebe080e7          	jalr	-322(ra) # 7a2 <free>
  return freep;
 8ec:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8ee:	d979                	beqz	a0,8c4 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f2:	4798                	lw	a4,8(a5)
 8f4:	fb2777e3          	bleu	s2,a4,8a2 <malloc+0x76>
    if(p == freep)
 8f8:	6098                	ld	a4,0(s1)
 8fa:	853e                	mv	a0,a5
 8fc:	fef71ae3          	bne	a4,a5,8f0 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 900:	8552                	mv	a0,s4
 902:	00000097          	auipc	ra,0x0
 906:	b7a080e7          	jalr	-1158(ra) # 47c <sbrk>
  if(p == (char*)-1)
 90a:	fd651ae3          	bne	a0,s6,8de <malloc+0xb2>
        return 0;
 90e:	4501                	li	a0,0
 910:	bf55                	j	8c4 <malloc+0x98>
