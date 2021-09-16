
user/_pingpong：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
    int p1[2], p2[2];
    pipe(p1);
   8:	fe840513          	addi	a0,s0,-24
   c:	00000097          	auipc	ra,0x0
  10:	35e080e7          	jalr	862(ra) # 36a <pipe>
    pipe(p2);
  14:	fe040513          	addi	a0,s0,-32
  18:	00000097          	auipc	ra,0x0
  1c:	352080e7          	jalr	850(ra) # 36a <pipe>

    if (fork() == 0)
  20:	00000097          	auipc	ra,0x0
  24:	332080e7          	jalr	818(ra) # 352 <fork>
  28:	e939                	bnez	a0,7e <main+0x7e>
    {
        char str[5];
        read(p1[0], str, 4);
  2a:	4611                	li	a2,4
  2c:	fd840593          	addi	a1,s0,-40
  30:	fe842503          	lw	a0,-24(s0)
  34:	00000097          	auipc	ra,0x0
  38:	33e080e7          	jalr	830(ra) # 372 <read>
        str[4] = '\0';
  3c:	fc040e23          	sb	zero,-36(s0)
        printf("%d: received %s\n", getpid(), str);
  40:	00000097          	auipc	ra,0x0
  44:	39a080e7          	jalr	922(ra) # 3da <getpid>
  48:	fd840613          	addi	a2,s0,-40
  4c:	85aa                	mv	a1,a0
  4e:	00001517          	auipc	a0,0x1
  52:	82a50513          	addi	a0,a0,-2006 # 878 <malloc+0xe6>
  56:	00000097          	auipc	ra,0x0
  5a:	67c080e7          	jalr	1660(ra) # 6d2 <printf>
        write(p2[1], "pong", 4);
  5e:	4611                	li	a2,4
  60:	00001597          	auipc	a1,0x1
  64:	83058593          	addi	a1,a1,-2000 # 890 <malloc+0xfe>
  68:	fe442503          	lw	a0,-28(s0)
  6c:	00000097          	auipc	ra,0x0
  70:	30e080e7          	jalr	782(ra) # 37a <write>
        read(p2[0], str, 4);
        str[4] = '\0';
        printf("%d: received %s\n", getpid(), str);
    }

    exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	2e4080e7          	jalr	740(ra) # 35a <exit>
        write(p1[1], "ping", 4);
  7e:	4611                	li	a2,4
  80:	00001597          	auipc	a1,0x1
  84:	81858593          	addi	a1,a1,-2024 # 898 <malloc+0x106>
  88:	fec42503          	lw	a0,-20(s0)
  8c:	00000097          	auipc	ra,0x0
  90:	2ee080e7          	jalr	750(ra) # 37a <write>
        read(p2[0], str, 4);
  94:	4611                	li	a2,4
  96:	fd840593          	addi	a1,s0,-40
  9a:	fe042503          	lw	a0,-32(s0)
  9e:	00000097          	auipc	ra,0x0
  a2:	2d4080e7          	jalr	724(ra) # 372 <read>
        str[4] = '\0';
  a6:	fc040e23          	sb	zero,-36(s0)
        printf("%d: received %s\n", getpid(), str);
  aa:	00000097          	auipc	ra,0x0
  ae:	330080e7          	jalr	816(ra) # 3da <getpid>
  b2:	fd840613          	addi	a2,s0,-40
  b6:	85aa                	mv	a1,a0
  b8:	00000517          	auipc	a0,0x0
  bc:	7c050513          	addi	a0,a0,1984 # 878 <malloc+0xe6>
  c0:	00000097          	auipc	ra,0x0
  c4:	612080e7          	jalr	1554(ra) # 6d2 <printf>
  c8:	b775                	j	74 <main+0x74>

00000000000000ca <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d0:	87aa                	mv	a5,a0
  d2:	0585                	addi	a1,a1,1
  d4:	0785                	addi	a5,a5,1
  d6:	fff5c703          	lbu	a4,-1(a1)
  da:	fee78fa3          	sb	a4,-1(a5)
  de:	fb75                	bnez	a4,d2 <strcpy+0x8>
    ;
  return os;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strcmp+0x26>
  f2:	0005c703          	lbu	a4,0(a1)
  f6:	00f71b63          	bne	a4,a5,10c <strcmp+0x26>
    p++, q++;
  fa:	0505                	addi	a0,a0,1
  fc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  fe:	00054783          	lbu	a5,0(a0)
 102:	c789                	beqz	a5,10c <strcmp+0x26>
 104:	0005c703          	lbu	a4,0(a1)
 108:	fef709e3          	beq	a4,a5,fa <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 10c:	0005c503          	lbu	a0,0(a1)
}
 110:	40a7853b          	subw	a0,a5,a0
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret

000000000000011a <strlen>:

uint
strlen(const char *s)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 120:	00054783          	lbu	a5,0(a0)
 124:	cf91                	beqz	a5,140 <strlen+0x26>
 126:	0505                	addi	a0,a0,1
 128:	87aa                	mv	a5,a0
 12a:	4685                	li	a3,1
 12c:	9e89                	subw	a3,a3,a0
 12e:	00f6853b          	addw	a0,a3,a5
 132:	0785                	addi	a5,a5,1
 134:	fff7c703          	lbu	a4,-1(a5)
 138:	fb7d                	bnez	a4,12e <strlen+0x14>
    ;
  return n;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  for(n = 0; s[n]; n++)
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strlen+0x20>

0000000000000144 <memset>:

void*
memset(void *dst, int c, uint n)
{
 144:	1141                	addi	sp,sp,-16
 146:	e422                	sd	s0,8(sp)
 148:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14a:	ce09                	beqz	a2,164 <memset+0x20>
 14c:	87aa                	mv	a5,a0
 14e:	fff6071b          	addiw	a4,a2,-1
 152:	1702                	slli	a4,a4,0x20
 154:	9301                	srli	a4,a4,0x20
 156:	0705                	addi	a4,a4,1
 158:	972a                	add	a4,a4,a0
    cdst[i] = c;
 15a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15e:	0785                	addi	a5,a5,1
 160:	fee79de3          	bne	a5,a4,15a <memset+0x16>
  }
  return dst;
}
 164:	6422                	ld	s0,8(sp)
 166:	0141                	addi	sp,sp,16
 168:	8082                	ret

000000000000016a <strchr>:

char*
strchr(const char *s, char c)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 170:	00054783          	lbu	a5,0(a0)
 174:	cf91                	beqz	a5,190 <strchr+0x26>
    if(*s == c)
 176:	00f58a63          	beq	a1,a5,18a <strchr+0x20>
  for(; *s; s++)
 17a:	0505                	addi	a0,a0,1
 17c:	00054783          	lbu	a5,0(a0)
 180:	c781                	beqz	a5,188 <strchr+0x1e>
    if(*s == c)
 182:	feb79ce3          	bne	a5,a1,17a <strchr+0x10>
 186:	a011                	j	18a <strchr+0x20>
      return (char*)s;
  return 0;
 188:	4501                	li	a0,0
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret
  return 0;
 190:	4501                	li	a0,0
 192:	bfe5                	j	18a <strchr+0x20>

0000000000000194 <gets>:

char*
gets(char *buf, int max)
{
 194:	711d                	addi	sp,sp,-96
 196:	ec86                	sd	ra,88(sp)
 198:	e8a2                	sd	s0,80(sp)
 19a:	e4a6                	sd	s1,72(sp)
 19c:	e0ca                	sd	s2,64(sp)
 19e:	fc4e                	sd	s3,56(sp)
 1a0:	f852                	sd	s4,48(sp)
 1a2:	f456                	sd	s5,40(sp)
 1a4:	f05a                	sd	s6,32(sp)
 1a6:	ec5e                	sd	s7,24(sp)
 1a8:	1080                	addi	s0,sp,96
 1aa:	8baa                	mv	s7,a0
 1ac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ae:	892a                	mv	s2,a0
 1b0:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b2:	4aa9                	li	s5,10
 1b4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1b6:	0019849b          	addiw	s1,s3,1
 1ba:	0344d863          	ble	s4,s1,1ea <gets+0x56>
    cc = read(0, &c, 1);
 1be:	4605                	li	a2,1
 1c0:	faf40593          	addi	a1,s0,-81
 1c4:	4501                	li	a0,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	1ac080e7          	jalr	428(ra) # 372 <read>
    if(cc < 1)
 1ce:	00a05e63          	blez	a0,1ea <gets+0x56>
    buf[i++] = c;
 1d2:	faf44783          	lbu	a5,-81(s0)
 1d6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1da:	01578763          	beq	a5,s5,1e8 <gets+0x54>
 1de:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 1e0:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 1e2:	fd679ae3          	bne	a5,s6,1b6 <gets+0x22>
 1e6:	a011                	j	1ea <gets+0x56>
  for(i=0; i+1 < max; ){
 1e8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ea:	99de                	add	s3,s3,s7
 1ec:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f0:	855e                	mv	a0,s7
 1f2:	60e6                	ld	ra,88(sp)
 1f4:	6446                	ld	s0,80(sp)
 1f6:	64a6                	ld	s1,72(sp)
 1f8:	6906                	ld	s2,64(sp)
 1fa:	79e2                	ld	s3,56(sp)
 1fc:	7a42                	ld	s4,48(sp)
 1fe:	7aa2                	ld	s5,40(sp)
 200:	7b02                	ld	s6,32(sp)
 202:	6be2                	ld	s7,24(sp)
 204:	6125                	addi	sp,sp,96
 206:	8082                	ret

0000000000000208 <stat>:

int
stat(const char *n, struct stat *st)
{
 208:	1101                	addi	sp,sp,-32
 20a:	ec06                	sd	ra,24(sp)
 20c:	e822                	sd	s0,16(sp)
 20e:	e426                	sd	s1,8(sp)
 210:	e04a                	sd	s2,0(sp)
 212:	1000                	addi	s0,sp,32
 214:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 216:	4581                	li	a1,0
 218:	00000097          	auipc	ra,0x0
 21c:	182080e7          	jalr	386(ra) # 39a <open>
  if(fd < 0)
 220:	02054563          	bltz	a0,24a <stat+0x42>
 224:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 226:	85ca                	mv	a1,s2
 228:	00000097          	auipc	ra,0x0
 22c:	18a080e7          	jalr	394(ra) # 3b2 <fstat>
 230:	892a                	mv	s2,a0
  close(fd);
 232:	8526                	mv	a0,s1
 234:	00000097          	auipc	ra,0x0
 238:	14e080e7          	jalr	334(ra) # 382 <close>
  return r;
}
 23c:	854a                	mv	a0,s2
 23e:	60e2                	ld	ra,24(sp)
 240:	6442                	ld	s0,16(sp)
 242:	64a2                	ld	s1,8(sp)
 244:	6902                	ld	s2,0(sp)
 246:	6105                	addi	sp,sp,32
 248:	8082                	ret
    return -1;
 24a:	597d                	li	s2,-1
 24c:	bfc5                	j	23c <stat+0x34>

000000000000024e <atoi>:

int
atoi(const char *s)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 254:	00054683          	lbu	a3,0(a0)
 258:	fd06879b          	addiw	a5,a3,-48
 25c:	0ff7f793          	andi	a5,a5,255
 260:	4725                	li	a4,9
 262:	02f76963          	bltu	a4,a5,294 <atoi+0x46>
 266:	862a                	mv	a2,a0
  n = 0;
 268:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 26a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 26c:	0605                	addi	a2,a2,1
 26e:	0025179b          	slliw	a5,a0,0x2
 272:	9fa9                	addw	a5,a5,a0
 274:	0017979b          	slliw	a5,a5,0x1
 278:	9fb5                	addw	a5,a5,a3
 27a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 27e:	00064683          	lbu	a3,0(a2)
 282:	fd06871b          	addiw	a4,a3,-48
 286:	0ff77713          	andi	a4,a4,255
 28a:	fee5f1e3          	bleu	a4,a1,26c <atoi+0x1e>
  return n;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  n = 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <atoi+0x40>

0000000000000298 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 29e:	02b57663          	bleu	a1,a0,2ca <memmove+0x32>
    while(n-- > 0)
 2a2:	02c05163          	blez	a2,2c4 <memmove+0x2c>
 2a6:	fff6079b          	addiw	a5,a2,-1
 2aa:	1782                	slli	a5,a5,0x20
 2ac:	9381                	srli	a5,a5,0x20
 2ae:	0785                	addi	a5,a5,1
 2b0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2b2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b4:	0585                	addi	a1,a1,1
 2b6:	0705                	addi	a4,a4,1
 2b8:	fff5c683          	lbu	a3,-1(a1)
 2bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
    dst += n;
 2ca:	00c50733          	add	a4,a0,a2
    src += n;
 2ce:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d0:	fec05ae3          	blez	a2,2c4 <memmove+0x2c>
 2d4:	fff6079b          	addiw	a5,a2,-1
 2d8:	1782                	slli	a5,a5,0x20
 2da:	9381                	srli	a5,a5,0x20
 2dc:	fff7c793          	not	a5,a5
 2e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e2:	15fd                	addi	a1,a1,-1
 2e4:	177d                	addi	a4,a4,-1
 2e6:	0005c683          	lbu	a3,0(a1)
 2ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ee:	fef71ae3          	bne	a4,a5,2e2 <memmove+0x4a>
 2f2:	bfc9                	j	2c4 <memmove+0x2c>

00000000000002f4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fa:	ce15                	beqz	a2,336 <memcmp+0x42>
 2fc:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 300:	00054783          	lbu	a5,0(a0)
 304:	0005c703          	lbu	a4,0(a1)
 308:	02e79063          	bne	a5,a4,328 <memcmp+0x34>
 30c:	1682                	slli	a3,a3,0x20
 30e:	9281                	srli	a3,a3,0x20
 310:	0685                	addi	a3,a3,1
 312:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 314:	0505                	addi	a0,a0,1
    p2++;
 316:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 318:	00d50d63          	beq	a0,a3,332 <memcmp+0x3e>
    if (*p1 != *p2) {
 31c:	00054783          	lbu	a5,0(a0)
 320:	0005c703          	lbu	a4,0(a1)
 324:	fee788e3          	beq	a5,a4,314 <memcmp+0x20>
      return *p1 - *p2;
 328:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  return 0;
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <memcmp+0x38>
 336:	4501                	li	a0,0
 338:	bfd5                	j	32c <memcmp+0x38>

000000000000033a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33a:	1141                	addi	sp,sp,-16
 33c:	e406                	sd	ra,8(sp)
 33e:	e022                	sd	s0,0(sp)
 340:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 342:	00000097          	auipc	ra,0x0
 346:	f56080e7          	jalr	-170(ra) # 298 <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36a:	4891                	li	a7,4
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <read>:
.global read
read:
 li a7, SYS_read
 372:	4895                	li	a7,5
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <write>:
.global write
write:
 li a7, SYS_write
 37a:	48c1                	li	a7,16
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <close>:
.global close
close:
 li a7, SYS_close
 382:	48d5                	li	a7,21
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kill>:
.global kill
kill:
 li a7, SYS_kill
 38a:	4899                	li	a7,6
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exec>:
.global exec
exec:
 li a7, SYS_exec
 392:	489d                	li	a7,7
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <open>:
.global open
open:
 li a7, SYS_open
 39a:	48bd                	li	a7,15
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a2:	48c5                	li	a7,17
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3aa:	48c9                	li	a7,18
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b2:	48a1                	li	a7,8
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <link>:
.global link
link:
 li a7, SYS_link
 3ba:	48cd                	li	a7,19
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c2:	48d1                	li	a7,20
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ca:	48a5                	li	a7,9
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d2:	48a9                	li	a7,10
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3da:	48ad                	li	a7,11
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e2:	48b1                	li	a7,12
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ea:	48b5                	li	a7,13
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f2:	48b9                	li	a7,14
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fa:	1101                	addi	sp,sp,-32
 3fc:	ec06                	sd	ra,24(sp)
 3fe:	e822                	sd	s0,16(sp)
 400:	1000                	addi	s0,sp,32
 402:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 406:	4605                	li	a2,1
 408:	fef40593          	addi	a1,s0,-17
 40c:	00000097          	auipc	ra,0x0
 410:	f6e080e7          	jalr	-146(ra) # 37a <write>
}
 414:	60e2                	ld	ra,24(sp)
 416:	6442                	ld	s0,16(sp)
 418:	6105                	addi	sp,sp,32
 41a:	8082                	ret

000000000000041c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41c:	7139                	addi	sp,sp,-64
 41e:	fc06                	sd	ra,56(sp)
 420:	f822                	sd	s0,48(sp)
 422:	f426                	sd	s1,40(sp)
 424:	f04a                	sd	s2,32(sp)
 426:	ec4e                	sd	s3,24(sp)
 428:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42a:	c299                	beqz	a3,430 <printint+0x14>
 42c:	0005cd63          	bltz	a1,446 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 430:	2581                	sext.w	a1,a1
  neg = 0;
 432:	4301                	li	t1,0
 434:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 438:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 43a:	2601                	sext.w	a2,a2
 43c:	00000897          	auipc	a7,0x0
 440:	46488893          	addi	a7,a7,1124 # 8a0 <digits>
 444:	a801                	j	454 <printint+0x38>
    x = -xx;
 446:	40b005bb          	negw	a1,a1
 44a:	2581                	sext.w	a1,a1
    neg = 1;
 44c:	4305                	li	t1,1
    x = -xx;
 44e:	b7dd                	j	434 <printint+0x18>
  }while((x /= base) != 0);
 450:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 452:	8836                	mv	a6,a3
 454:	0018069b          	addiw	a3,a6,1
 458:	02c5f7bb          	remuw	a5,a1,a2
 45c:	1782                	slli	a5,a5,0x20
 45e:	9381                	srli	a5,a5,0x20
 460:	97c6                	add	a5,a5,a7
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 46a:	0705                	addi	a4,a4,1
 46c:	02c5d7bb          	divuw	a5,a1,a2
 470:	fec5f0e3          	bleu	a2,a1,450 <printint+0x34>
  if(neg)
 474:	00030b63          	beqz	t1,48a <printint+0x6e>
    buf[i++] = '-';
 478:	fd040793          	addi	a5,s0,-48
 47c:	96be                	add	a3,a3,a5
 47e:	02d00793          	li	a5,45
 482:	fef68823          	sb	a5,-16(a3)
 486:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 48a:	02d05963          	blez	a3,4bc <printint+0xa0>
 48e:	89aa                	mv	s3,a0
 490:	fc040793          	addi	a5,s0,-64
 494:	00d784b3          	add	s1,a5,a3
 498:	fff78913          	addi	s2,a5,-1
 49c:	9936                	add	s2,s2,a3
 49e:	36fd                	addiw	a3,a3,-1
 4a0:	1682                	slli	a3,a3,0x20
 4a2:	9281                	srli	a3,a3,0x20
 4a4:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 4a8:	fff4c583          	lbu	a1,-1(s1)
 4ac:	854e                	mv	a0,s3
 4ae:	00000097          	auipc	ra,0x0
 4b2:	f4c080e7          	jalr	-180(ra) # 3fa <putc>
  while(--i >= 0)
 4b6:	14fd                	addi	s1,s1,-1
 4b8:	ff2498e3          	bne	s1,s2,4a8 <printint+0x8c>
}
 4bc:	70e2                	ld	ra,56(sp)
 4be:	7442                	ld	s0,48(sp)
 4c0:	74a2                	ld	s1,40(sp)
 4c2:	7902                	ld	s2,32(sp)
 4c4:	69e2                	ld	s3,24(sp)
 4c6:	6121                	addi	sp,sp,64
 4c8:	8082                	ret

00000000000004ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ca:	7119                	addi	sp,sp,-128
 4cc:	fc86                	sd	ra,120(sp)
 4ce:	f8a2                	sd	s0,112(sp)
 4d0:	f4a6                	sd	s1,104(sp)
 4d2:	f0ca                	sd	s2,96(sp)
 4d4:	ecce                	sd	s3,88(sp)
 4d6:	e8d2                	sd	s4,80(sp)
 4d8:	e4d6                	sd	s5,72(sp)
 4da:	e0da                	sd	s6,64(sp)
 4dc:	fc5e                	sd	s7,56(sp)
 4de:	f862                	sd	s8,48(sp)
 4e0:	f466                	sd	s9,40(sp)
 4e2:	f06a                	sd	s10,32(sp)
 4e4:	ec6e                	sd	s11,24(sp)
 4e6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e8:	0005c483          	lbu	s1,0(a1)
 4ec:	18048d63          	beqz	s1,686 <vprintf+0x1bc>
 4f0:	8aaa                	mv	s5,a0
 4f2:	8b32                	mv	s6,a2
 4f4:	00158913          	addi	s2,a1,1
  state = 0;
 4f8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fa:	02500a13          	li	s4,37
      if(c == 'd'){
 4fe:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 502:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 506:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 50a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 50e:	00000b97          	auipc	s7,0x0
 512:	392b8b93          	addi	s7,s7,914 # 8a0 <digits>
 516:	a839                	j	534 <vprintf+0x6a>
        putc(fd, c);
 518:	85a6                	mv	a1,s1
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	ede080e7          	jalr	-290(ra) # 3fa <putc>
 524:	a019                	j	52a <vprintf+0x60>
    } else if(state == '%'){
 526:	01498f63          	beq	s3,s4,544 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 52a:	0905                	addi	s2,s2,1
 52c:	fff94483          	lbu	s1,-1(s2)
 530:	14048b63          	beqz	s1,686 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 534:	0004879b          	sext.w	a5,s1
    if(state == 0){
 538:	fe0997e3          	bnez	s3,526 <vprintf+0x5c>
      if(c == '%'){
 53c:	fd479ee3          	bne	a5,s4,518 <vprintf+0x4e>
        state = '%';
 540:	89be                	mv	s3,a5
 542:	b7e5                	j	52a <vprintf+0x60>
      if(c == 'd'){
 544:	05878063          	beq	a5,s8,584 <vprintf+0xba>
      } else if(c == 'l') {
 548:	05978c63          	beq	a5,s9,5a0 <vprintf+0xd6>
      } else if(c == 'x') {
 54c:	07a78863          	beq	a5,s10,5bc <vprintf+0xf2>
      } else if(c == 'p') {
 550:	09b78463          	beq	a5,s11,5d8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 554:	07300713          	li	a4,115
 558:	0ce78563          	beq	a5,a4,622 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 55c:	06300713          	li	a4,99
 560:	0ee78c63          	beq	a5,a4,658 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 564:	11478663          	beq	a5,s4,670 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 568:	85d2                	mv	a1,s4
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e8e080e7          	jalr	-370(ra) # 3fa <putc>
        putc(fd, c);
 574:	85a6                	mv	a1,s1
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e82080e7          	jalr	-382(ra) # 3fa <putc>
      }
      state = 0;
 580:	4981                	li	s3,0
 582:	b765                	j	52a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 584:	008b0493          	addi	s1,s6,8
 588:	4685                	li	a3,1
 58a:	4629                	li	a2,10
 58c:	000b2583          	lw	a1,0(s6)
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e8a080e7          	jalr	-374(ra) # 41c <printint>
 59a:	8b26                	mv	s6,s1
      state = 0;
 59c:	4981                	li	s3,0
 59e:	b771                	j	52a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a0:	008b0493          	addi	s1,s6,8
 5a4:	4681                	li	a3,0
 5a6:	4629                	li	a2,10
 5a8:	000b2583          	lw	a1,0(s6)
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	e6e080e7          	jalr	-402(ra) # 41c <printint>
 5b6:	8b26                	mv	s6,s1
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf85                	j	52a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5bc:	008b0493          	addi	s1,s6,8
 5c0:	4681                	li	a3,0
 5c2:	4641                	li	a2,16
 5c4:	000b2583          	lw	a1,0(s6)
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e52080e7          	jalr	-430(ra) # 41c <printint>
 5d2:	8b26                	mv	s6,s1
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bf91                	j	52a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5d8:	008b0793          	addi	a5,s6,8
 5dc:	f8f43423          	sd	a5,-120(s0)
 5e0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5e4:	03000593          	li	a1,48
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e10080e7          	jalr	-496(ra) # 3fa <putc>
  putc(fd, 'x');
 5f2:	85ea                	mv	a1,s10
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e04080e7          	jalr	-508(ra) # 3fa <putc>
 5fe:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 600:	03c9d793          	srli	a5,s3,0x3c
 604:	97de                	add	a5,a5,s7
 606:	0007c583          	lbu	a1,0(a5)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	dee080e7          	jalr	-530(ra) # 3fa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 614:	0992                	slli	s3,s3,0x4
 616:	34fd                	addiw	s1,s1,-1
 618:	f4e5                	bnez	s1,600 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 61a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 61e:	4981                	li	s3,0
 620:	b729                	j	52a <vprintf+0x60>
        s = va_arg(ap, char*);
 622:	008b0993          	addi	s3,s6,8
 626:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 62a:	c085                	beqz	s1,64a <vprintf+0x180>
        while(*s != 0){
 62c:	0004c583          	lbu	a1,0(s1)
 630:	c9a1                	beqz	a1,680 <vprintf+0x1b6>
          putc(fd, *s);
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	dc6080e7          	jalr	-570(ra) # 3fa <putc>
          s++;
 63c:	0485                	addi	s1,s1,1
        while(*s != 0){
 63e:	0004c583          	lbu	a1,0(s1)
 642:	f9e5                	bnez	a1,632 <vprintf+0x168>
        s = va_arg(ap, char*);
 644:	8b4e                	mv	s6,s3
      state = 0;
 646:	4981                	li	s3,0
 648:	b5cd                	j	52a <vprintf+0x60>
          s = "(null)";
 64a:	00000497          	auipc	s1,0x0
 64e:	26e48493          	addi	s1,s1,622 # 8b8 <digits+0x18>
        while(*s != 0){
 652:	02800593          	li	a1,40
 656:	bff1                	j	632 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 658:	008b0493          	addi	s1,s6,8
 65c:	000b4583          	lbu	a1,0(s6)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	d98080e7          	jalr	-616(ra) # 3fa <putc>
 66a:	8b26                	mv	s6,s1
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bd75                	j	52a <vprintf+0x60>
        putc(fd, c);
 670:	85d2                	mv	a1,s4
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	d86080e7          	jalr	-634(ra) # 3fa <putc>
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b575                	j	52a <vprintf+0x60>
        s = va_arg(ap, char*);
 680:	8b4e                	mv	s6,s3
      state = 0;
 682:	4981                	li	s3,0
 684:	b55d                	j	52a <vprintf+0x60>
    }
  }
}
 686:	70e6                	ld	ra,120(sp)
 688:	7446                	ld	s0,112(sp)
 68a:	74a6                	ld	s1,104(sp)
 68c:	7906                	ld	s2,96(sp)
 68e:	69e6                	ld	s3,88(sp)
 690:	6a46                	ld	s4,80(sp)
 692:	6aa6                	ld	s5,72(sp)
 694:	6b06                	ld	s6,64(sp)
 696:	7be2                	ld	s7,56(sp)
 698:	7c42                	ld	s8,48(sp)
 69a:	7ca2                	ld	s9,40(sp)
 69c:	7d02                	ld	s10,32(sp)
 69e:	6de2                	ld	s11,24(sp)
 6a0:	6109                	addi	sp,sp,128
 6a2:	8082                	ret

00000000000006a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a4:	715d                	addi	sp,sp,-80
 6a6:	ec06                	sd	ra,24(sp)
 6a8:	e822                	sd	s0,16(sp)
 6aa:	1000                	addi	s0,sp,32
 6ac:	e010                	sd	a2,0(s0)
 6ae:	e414                	sd	a3,8(s0)
 6b0:	e818                	sd	a4,16(s0)
 6b2:	ec1c                	sd	a5,24(s0)
 6b4:	03043023          	sd	a6,32(s0)
 6b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c0:	8622                	mv	a2,s0
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e08080e7          	jalr	-504(ra) # 4ca <vprintf>
}
 6ca:	60e2                	ld	ra,24(sp)
 6cc:	6442                	ld	s0,16(sp)
 6ce:	6161                	addi	sp,sp,80
 6d0:	8082                	ret

00000000000006d2 <printf>:

void
printf(const char *fmt, ...)
{
 6d2:	711d                	addi	sp,sp,-96
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	addi	s0,sp,32
 6da:	e40c                	sd	a1,8(s0)
 6dc:	e810                	sd	a2,16(s0)
 6de:	ec14                	sd	a3,24(s0)
 6e0:	f018                	sd	a4,32(s0)
 6e2:	f41c                	sd	a5,40(s0)
 6e4:	03043823          	sd	a6,48(s0)
 6e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	00840613          	addi	a2,s0,8
 6f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f4:	85aa                	mv	a1,a0
 6f6:	4505                	li	a0,1
 6f8:	00000097          	auipc	ra,0x0
 6fc:	dd2080e7          	jalr	-558(ra) # 4ca <vprintf>
}
 700:	60e2                	ld	ra,24(sp)
 702:	6442                	ld	s0,16(sp)
 704:	6125                	addi	sp,sp,96
 706:	8082                	ret

0000000000000708 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 708:	1141                	addi	sp,sp,-16
 70a:	e422                	sd	s0,8(sp)
 70c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	00000797          	auipc	a5,0x0
 716:	1ae78793          	addi	a5,a5,430 # 8c0 <__bss_start>
 71a:	639c                	ld	a5,0(a5)
 71c:	a805                	j	74c <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71e:	4618                	lw	a4,8(a2)
 720:	9db9                	addw	a1,a1,a4
 722:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 726:	6398                	ld	a4,0(a5)
 728:	6318                	ld	a4,0(a4)
 72a:	fee53823          	sd	a4,-16(a0)
 72e:	a091                	j	772 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 730:	ff852703          	lw	a4,-8(a0)
 734:	9e39                	addw	a2,a2,a4
 736:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 738:	ff053703          	ld	a4,-16(a0)
 73c:	e398                	sd	a4,0(a5)
 73e:	a099                	j	784 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 740:	6398                	ld	a4,0(a5)
 742:	00e7e463          	bltu	a5,a4,74a <free+0x42>
 746:	00e6ea63          	bltu	a3,a4,75a <free+0x52>
{
 74a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	fed7fae3          	bleu	a3,a5,740 <free+0x38>
 750:	6398                	ld	a4,0(a5)
 752:	00e6e463          	bltu	a3,a4,75a <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 756:	fee7eae3          	bltu	a5,a4,74a <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 75a:	ff852583          	lw	a1,-8(a0)
 75e:	6390                	ld	a2,0(a5)
 760:	02059713          	slli	a4,a1,0x20
 764:	9301                	srli	a4,a4,0x20
 766:	0712                	slli	a4,a4,0x4
 768:	9736                	add	a4,a4,a3
 76a:	fae60ae3          	beq	a2,a4,71e <free+0x16>
    bp->s.ptr = p->s.ptr;
 76e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 772:	4790                	lw	a2,8(a5)
 774:	02061713          	slli	a4,a2,0x20
 778:	9301                	srli	a4,a4,0x20
 77a:	0712                	slli	a4,a4,0x4
 77c:	973e                	add	a4,a4,a5
 77e:	fae689e3          	beq	a3,a4,730 <free+0x28>
  } else
    p->s.ptr = bp;
 782:	e394                	sd	a3,0(a5)
  freep = p;
 784:	00000717          	auipc	a4,0x0
 788:	12f73e23          	sd	a5,316(a4) # 8c0 <__bss_start>
}
 78c:	6422                	ld	s0,8(sp)
 78e:	0141                	addi	sp,sp,16
 790:	8082                	ret

0000000000000792 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 792:	7139                	addi	sp,sp,-64
 794:	fc06                	sd	ra,56(sp)
 796:	f822                	sd	s0,48(sp)
 798:	f426                	sd	s1,40(sp)
 79a:	f04a                	sd	s2,32(sp)
 79c:	ec4e                	sd	s3,24(sp)
 79e:	e852                	sd	s4,16(sp)
 7a0:	e456                	sd	s5,8(sp)
 7a2:	e05a                	sd	s6,0(sp)
 7a4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7a6:	02051993          	slli	s3,a0,0x20
 7aa:	0209d993          	srli	s3,s3,0x20
 7ae:	09bd                	addi	s3,s3,15
 7b0:	0049d993          	srli	s3,s3,0x4
 7b4:	2985                	addiw	s3,s3,1
 7b6:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 7ba:	00000797          	auipc	a5,0x0
 7be:	10678793          	addi	a5,a5,262 # 8c0 <__bss_start>
 7c2:	6388                	ld	a0,0(a5)
 7c4:	c515                	beqz	a0,7f0 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c8:	4798                	lw	a4,8(a5)
 7ca:	03277f63          	bleu	s2,a4,808 <malloc+0x76>
 7ce:	8a4e                	mv	s4,s3
 7d0:	0009871b          	sext.w	a4,s3
 7d4:	6685                	lui	a3,0x1
 7d6:	00d77363          	bleu	a3,a4,7dc <malloc+0x4a>
 7da:	6a05                	lui	s4,0x1
 7dc:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 7e0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7e4:	00000497          	auipc	s1,0x0
 7e8:	0dc48493          	addi	s1,s1,220 # 8c0 <__bss_start>
  if(p == (char*)-1)
 7ec:	5b7d                	li	s6,-1
 7ee:	a885                	j	85e <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 7f0:	00000797          	auipc	a5,0x0
 7f4:	0d878793          	addi	a5,a5,216 # 8c8 <base>
 7f8:	00000717          	auipc	a4,0x0
 7fc:	0cf73423          	sd	a5,200(a4) # 8c0 <__bss_start>
 800:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 802:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 806:	b7e1                	j	7ce <malloc+0x3c>
      if(p->s.size == nunits)
 808:	02e90b63          	beq	s2,a4,83e <malloc+0xac>
        p->s.size -= nunits;
 80c:	4137073b          	subw	a4,a4,s3
 810:	c798                	sw	a4,8(a5)
        p += p->s.size;
 812:	1702                	slli	a4,a4,0x20
 814:	9301                	srli	a4,a4,0x20
 816:	0712                	slli	a4,a4,0x4
 818:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 81a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 81e:	00000717          	auipc	a4,0x0
 822:	0aa73123          	sd	a0,162(a4) # 8c0 <__bss_start>
      return (void*)(p + 1);
 826:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 82a:	70e2                	ld	ra,56(sp)
 82c:	7442                	ld	s0,48(sp)
 82e:	74a2                	ld	s1,40(sp)
 830:	7902                	ld	s2,32(sp)
 832:	69e2                	ld	s3,24(sp)
 834:	6a42                	ld	s4,16(sp)
 836:	6aa2                	ld	s5,8(sp)
 838:	6b02                	ld	s6,0(sp)
 83a:	6121                	addi	sp,sp,64
 83c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 83e:	6398                	ld	a4,0(a5)
 840:	e118                	sd	a4,0(a0)
 842:	bff1                	j	81e <malloc+0x8c>
  hp->s.size = nu;
 844:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 848:	0541                	addi	a0,a0,16
 84a:	00000097          	auipc	ra,0x0
 84e:	ebe080e7          	jalr	-322(ra) # 708 <free>
  return freep;
 852:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 854:	d979                	beqz	a0,82a <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 856:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 858:	4798                	lw	a4,8(a5)
 85a:	fb2777e3          	bleu	s2,a4,808 <malloc+0x76>
    if(p == freep)
 85e:	6098                	ld	a4,0(s1)
 860:	853e                	mv	a0,a5
 862:	fef71ae3          	bne	a4,a5,856 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 866:	8552                	mv	a0,s4
 868:	00000097          	auipc	ra,0x0
 86c:	b7a080e7          	jalr	-1158(ra) # 3e2 <sbrk>
  if(p == (char*)-1)
 870:	fd651ae3          	bne	a0,s6,844 <malloc+0xb2>
        return 0;
 874:	4501                	li	a0,0
 876:	bf55                	j	82a <malloc+0x98>
