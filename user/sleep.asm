
user/_sleep：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (argc == 0)
   8:	c13d                	beqz	a0,6e <main+0x6e>
        exit(0);
    }

    long long times = 0;

    for (int i = 0; i < argc; ++i)
   a:	06a05f63          	blez	a0,88 <main+0x88>
    {
        if ((long long)argv[1][i] >= (long long)'0' && (long long)argv[1][i] <= (long long)'9')
   e:	658c                	ld	a1,8(a1)
  10:	0005c603          	lbu	a2,0(a1)
  14:	fd06079b          	addiw	a5,a2,-48
  18:	0ff7f793          	andi	a5,a5,255
  1c:	4725                	li	a4,9
  1e:	02f76b63          	bltu	a4,a5,54 <main+0x54>
  22:	872e                	mv	a4,a1
  24:	357d                	addiw	a0,a0,-1
  26:	1502                	slli	a0,a0,0x20
  28:	9101                	srli	a0,a0,0x20
  2a:	95aa                	add	a1,a1,a0
    long long times = 0;
  2c:	4501                	li	a0,0
        if ((long long)argv[1][i] >= (long long)'0' && (long long)argv[1][i] <= (long long)'9')
  2e:	4825                	li	a6,9
        {
            times = times * 10 + (long long)argv[1][i] - '0';
  30:	00251793          	slli	a5,a0,0x2
  34:	953e                	add	a0,a0,a5
  36:	0506                	slli	a0,a0,0x1
  38:	9532                	add	a0,a0,a2
  3a:	fd050513          	addi	a0,a0,-48
    for (int i = 0; i < argc; ++i)
  3e:	04b70663          	beq	a4,a1,8a <main+0x8a>
        if ((long long)argv[1][i] >= (long long)'0' && (long long)argv[1][i] <= (long long)'9')
  42:	00174603          	lbu	a2,1(a4)
  46:	0705                	addi	a4,a4,1
  48:	fd06069b          	addiw	a3,a2,-48
  4c:	0ff6f693          	andi	a3,a3,255
  50:	fed870e3          	bleu	a3,a6,30 <main+0x30>
        }
        else
        {
            printf("You need to enter a integer.\n");
  54:	00001517          	auipc	a0,0x1
  58:	83450513          	addi	a0,a0,-1996 # 888 <malloc+0x122>
  5c:	00000097          	auipc	ra,0x0
  60:	64a080e7          	jalr	1610(ra) # 6a6 <printf>
            exit(0);
  64:	4501                	li	a0,0
  66:	00000097          	auipc	ra,0x0
  6a:	2c8080e7          	jalr	712(ra) # 32e <exit>
        printf("You need to enter a parameter for hte sleep commadn\n");
  6e:	00000517          	auipc	a0,0x0
  72:	7e250513          	addi	a0,a0,2018 # 850 <malloc+0xea>
  76:	00000097          	auipc	ra,0x0
  7a:	630080e7          	jalr	1584(ra) # 6a6 <printf>
        exit(0);
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	2ae080e7          	jalr	686(ra) # 32e <exit>
    long long times = 0;
  88:	4501                	li	a0,0
        }
    }

    sleep(times);
  8a:	2501                	sext.w	a0,a0
  8c:	00000097          	auipc	ra,0x0
  90:	332080e7          	jalr	818(ra) # 3be <sleep>

    exit(0);
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	298080e7          	jalr	664(ra) # 32e <exit>

000000000000009e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  a4:	87aa                	mv	a5,a0
  a6:	0585                	addi	a1,a1,1
  a8:	0785                	addi	a5,a5,1
  aa:	fff5c703          	lbu	a4,-1(a1)
  ae:	fee78fa3          	sb	a4,-1(a5)
  b2:	fb75                	bnez	a4,a6 <strcpy+0x8>
    ;
  return os;
}
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cf91                	beqz	a5,e0 <strcmp+0x26>
  c6:	0005c703          	lbu	a4,0(a1)
  ca:	00f71b63          	bne	a4,a5,e0 <strcmp+0x26>
    p++, q++;
  ce:	0505                	addi	a0,a0,1
  d0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	c789                	beqz	a5,e0 <strcmp+0x26>
  d8:	0005c703          	lbu	a4,0(a1)
  dc:	fef709e3          	beq	a4,a5,ce <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
  e0:	0005c503          	lbu	a0,0(a1)
}
  e4:	40a7853b          	subw	a0,a5,a0
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strlen>:

uint
strlen(const char *s)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cf91                	beqz	a5,114 <strlen+0x26>
  fa:	0505                	addi	a0,a0,1
  fc:	87aa                	mv	a5,a0
  fe:	4685                	li	a3,1
 100:	9e89                	subw	a3,a3,a0
 102:	00f6853b          	addw	a0,a3,a5
 106:	0785                	addi	a5,a5,1
 108:	fff7c703          	lbu	a4,-1(a5)
 10c:	fb7d                	bnez	a4,102 <strlen+0x14>
    ;
  return n;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret
  for(n = 0; s[n]; n++)
 114:	4501                	li	a0,0
 116:	bfe5                	j	10e <strlen+0x20>

0000000000000118 <memset>:

void*
memset(void *dst, int c, uint n)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 11e:	ce09                	beqz	a2,138 <memset+0x20>
 120:	87aa                	mv	a5,a0
 122:	fff6071b          	addiw	a4,a2,-1
 126:	1702                	slli	a4,a4,0x20
 128:	9301                	srli	a4,a4,0x20
 12a:	0705                	addi	a4,a4,1
 12c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 12e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 132:	0785                	addi	a5,a5,1
 134:	fee79de3          	bne	a5,a4,12e <memset+0x16>
  }
  return dst;
}
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret

000000000000013e <strchr>:

char*
strchr(const char *s, char c)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  for(; *s; s++)
 144:	00054783          	lbu	a5,0(a0)
 148:	cf91                	beqz	a5,164 <strchr+0x26>
    if(*s == c)
 14a:	00f58a63          	beq	a1,a5,15e <strchr+0x20>
  for(; *s; s++)
 14e:	0505                	addi	a0,a0,1
 150:	00054783          	lbu	a5,0(a0)
 154:	c781                	beqz	a5,15c <strchr+0x1e>
    if(*s == c)
 156:	feb79ce3          	bne	a5,a1,14e <strchr+0x10>
 15a:	a011                	j	15e <strchr+0x20>
      return (char*)s;
  return 0;
 15c:	4501                	li	a0,0
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  return 0;
 164:	4501                	li	a0,0
 166:	bfe5                	j	15e <strchr+0x20>

0000000000000168 <gets>:

char*
gets(char *buf, int max)
{
 168:	711d                	addi	sp,sp,-96
 16a:	ec86                	sd	ra,88(sp)
 16c:	e8a2                	sd	s0,80(sp)
 16e:	e4a6                	sd	s1,72(sp)
 170:	e0ca                	sd	s2,64(sp)
 172:	fc4e                	sd	s3,56(sp)
 174:	f852                	sd	s4,48(sp)
 176:	f456                	sd	s5,40(sp)
 178:	f05a                	sd	s6,32(sp)
 17a:	ec5e                	sd	s7,24(sp)
 17c:	1080                	addi	s0,sp,96
 17e:	8baa                	mv	s7,a0
 180:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 182:	892a                	mv	s2,a0
 184:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 186:	4aa9                	li	s5,10
 188:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18a:	0019849b          	addiw	s1,s3,1
 18e:	0344d863          	ble	s4,s1,1be <gets+0x56>
    cc = read(0, &c, 1);
 192:	4605                	li	a2,1
 194:	faf40593          	addi	a1,s0,-81
 198:	4501                	li	a0,0
 19a:	00000097          	auipc	ra,0x0
 19e:	1ac080e7          	jalr	428(ra) # 346 <read>
    if(cc < 1)
 1a2:	00a05e63          	blez	a0,1be <gets+0x56>
    buf[i++] = c;
 1a6:	faf44783          	lbu	a5,-81(s0)
 1aa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ae:	01578763          	beq	a5,s5,1bc <gets+0x54>
 1b2:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 1b4:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 1b6:	fd679ae3          	bne	a5,s6,18a <gets+0x22>
 1ba:	a011                	j	1be <gets+0x56>
  for(i=0; i+1 < max; ){
 1bc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1be:	99de                	add	s3,s3,s7
 1c0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c4:	855e                	mv	a0,s7
 1c6:	60e6                	ld	ra,88(sp)
 1c8:	6446                	ld	s0,80(sp)
 1ca:	64a6                	ld	s1,72(sp)
 1cc:	6906                	ld	s2,64(sp)
 1ce:	79e2                	ld	s3,56(sp)
 1d0:	7a42                	ld	s4,48(sp)
 1d2:	7aa2                	ld	s5,40(sp)
 1d4:	7b02                	ld	s6,32(sp)
 1d6:	6be2                	ld	s7,24(sp)
 1d8:	6125                	addi	sp,sp,96
 1da:	8082                	ret

00000000000001dc <stat>:

int
stat(const char *n, struct stat *st)
{
 1dc:	1101                	addi	sp,sp,-32
 1de:	ec06                	sd	ra,24(sp)
 1e0:	e822                	sd	s0,16(sp)
 1e2:	e426                	sd	s1,8(sp)
 1e4:	e04a                	sd	s2,0(sp)
 1e6:	1000                	addi	s0,sp,32
 1e8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ea:	4581                	li	a1,0
 1ec:	00000097          	auipc	ra,0x0
 1f0:	182080e7          	jalr	386(ra) # 36e <open>
  if(fd < 0)
 1f4:	02054563          	bltz	a0,21e <stat+0x42>
 1f8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fa:	85ca                	mv	a1,s2
 1fc:	00000097          	auipc	ra,0x0
 200:	18a080e7          	jalr	394(ra) # 386 <fstat>
 204:	892a                	mv	s2,a0
  close(fd);
 206:	8526                	mv	a0,s1
 208:	00000097          	auipc	ra,0x0
 20c:	14e080e7          	jalr	334(ra) # 356 <close>
  return r;
}
 210:	854a                	mv	a0,s2
 212:	60e2                	ld	ra,24(sp)
 214:	6442                	ld	s0,16(sp)
 216:	64a2                	ld	s1,8(sp)
 218:	6902                	ld	s2,0(sp)
 21a:	6105                	addi	sp,sp,32
 21c:	8082                	ret
    return -1;
 21e:	597d                	li	s2,-1
 220:	bfc5                	j	210 <stat+0x34>

0000000000000222 <atoi>:

int
atoi(const char *s)
{
 222:	1141                	addi	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 228:	00054683          	lbu	a3,0(a0)
 22c:	fd06879b          	addiw	a5,a3,-48
 230:	0ff7f793          	andi	a5,a5,255
 234:	4725                	li	a4,9
 236:	02f76963          	bltu	a4,a5,268 <atoi+0x46>
 23a:	862a                	mv	a2,a0
  n = 0;
 23c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 23e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 240:	0605                	addi	a2,a2,1
 242:	0025179b          	slliw	a5,a0,0x2
 246:	9fa9                	addw	a5,a5,a0
 248:	0017979b          	slliw	a5,a5,0x1
 24c:	9fb5                	addw	a5,a5,a3
 24e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 252:	00064683          	lbu	a3,0(a2)
 256:	fd06871b          	addiw	a4,a3,-48
 25a:	0ff77713          	andi	a4,a4,255
 25e:	fee5f1e3          	bleu	a4,a1,240 <atoi+0x1e>
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  n = 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <atoi+0x40>

000000000000026c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 272:	02b57663          	bleu	a1,a0,29e <memmove+0x32>
    while(n-- > 0)
 276:	02c05163          	blez	a2,298 <memmove+0x2c>
 27a:	fff6079b          	addiw	a5,a2,-1
 27e:	1782                	slli	a5,a5,0x20
 280:	9381                	srli	a5,a5,0x20
 282:	0785                	addi	a5,a5,1
 284:	97aa                	add	a5,a5,a0
  dst = vdst;
 286:	872a                	mv	a4,a0
      *dst++ = *src++;
 288:	0585                	addi	a1,a1,1
 28a:	0705                	addi	a4,a4,1
 28c:	fff5c683          	lbu	a3,-1(a1)
 290:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 294:	fee79ae3          	bne	a5,a4,288 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
    dst += n;
 29e:	00c50733          	add	a4,a0,a2
    src += n;
 2a2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a4:	fec05ae3          	blez	a2,298 <memmove+0x2c>
 2a8:	fff6079b          	addiw	a5,a2,-1
 2ac:	1782                	slli	a5,a5,0x20
 2ae:	9381                	srli	a5,a5,0x20
 2b0:	fff7c793          	not	a5,a5
 2b4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b6:	15fd                	addi	a1,a1,-1
 2b8:	177d                	addi	a4,a4,-1
 2ba:	0005c683          	lbu	a3,0(a1)
 2be:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c2:	fef71ae3          	bne	a4,a5,2b6 <memmove+0x4a>
 2c6:	bfc9                	j	298 <memmove+0x2c>

00000000000002c8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ce:	ce15                	beqz	a2,30a <memcmp+0x42>
 2d0:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	0005c703          	lbu	a4,0(a1)
 2dc:	02e79063          	bne	a5,a4,2fc <memcmp+0x34>
 2e0:	1682                	slli	a3,a3,0x20
 2e2:	9281                	srli	a3,a3,0x20
 2e4:	0685                	addi	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 2e8:	0505                	addi	a0,a0,1
    p2++;
 2ea:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2ec:	00d50d63          	beq	a0,a3,306 <memcmp+0x3e>
    if (*p1 != *p2) {
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	0005c703          	lbu	a4,0(a1)
 2f8:	fee788e3          	beq	a5,a4,2e8 <memcmp+0x20>
      return *p1 - *p2;
 2fc:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  return 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <memcmp+0x38>
 30a:	4501                	li	a0,0
 30c:	bfd5                	j	300 <memcmp+0x38>

000000000000030e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 316:	00000097          	auipc	ra,0x0
 31a:	f56080e7          	jalr	-170(ra) # 26c <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 326:	4885                	li	a7,1
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exit>:
.global exit
exit:
 li a7, SYS_exit
 32e:	4889                	li	a7,2
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait>:
.global wait
wait:
 li a7, SYS_wait
 336:	488d                	li	a7,3
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33e:	4891                	li	a7,4
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <read>:
.global read
read:
 li a7, SYS_read
 346:	4895                	li	a7,5
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <write>:
.global write
write:
 li a7, SYS_write
 34e:	48c1                	li	a7,16
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <close>:
.global close
close:
 li a7, SYS_close
 356:	48d5                	li	a7,21
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <kill>:
.global kill
kill:
 li a7, SYS_kill
 35e:	4899                	li	a7,6
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exec>:
.global exec
exec:
 li a7, SYS_exec
 366:	489d                	li	a7,7
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <open>:
.global open
open:
 li a7, SYS_open
 36e:	48bd                	li	a7,15
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 376:	48c5                	li	a7,17
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37e:	48c9                	li	a7,18
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 386:	48a1                	li	a7,8
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <link>:
.global link
link:
 li a7, SYS_link
 38e:	48cd                	li	a7,19
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 396:	48d1                	li	a7,20
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39e:	48a5                	li	a7,9
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a6:	48a9                	li	a7,10
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ae:	48ad                	li	a7,11
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b6:	48b1                	li	a7,12
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48b5                	li	a7,13
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c6:	48b9                	li	a7,14
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ce:	1101                	addi	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	1000                	addi	s0,sp,32
 3d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3da:	4605                	li	a2,1
 3dc:	fef40593          	addi	a1,s0,-17
 3e0:	00000097          	auipc	ra,0x0
 3e4:	f6e080e7          	jalr	-146(ra) # 34e <write>
}
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6105                	addi	sp,sp,32
 3ee:	8082                	ret

00000000000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	7139                	addi	sp,sp,-64
 3f2:	fc06                	sd	ra,56(sp)
 3f4:	f822                	sd	s0,48(sp)
 3f6:	f426                	sd	s1,40(sp)
 3f8:	f04a                	sd	s2,32(sp)
 3fa:	ec4e                	sd	s3,24(sp)
 3fc:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fe:	c299                	beqz	a3,404 <printint+0x14>
 400:	0005cd63          	bltz	a1,41a <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 404:	2581                	sext.w	a1,a1
  neg = 0;
 406:	4301                	li	t1,0
 408:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 40c:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 40e:	2601                	sext.w	a2,a2
 410:	00000897          	auipc	a7,0x0
 414:	49888893          	addi	a7,a7,1176 # 8a8 <digits>
 418:	a801                	j	428 <printint+0x38>
    x = -xx;
 41a:	40b005bb          	negw	a1,a1
 41e:	2581                	sext.w	a1,a1
    neg = 1;
 420:	4305                	li	t1,1
    x = -xx;
 422:	b7dd                	j	408 <printint+0x18>
  }while((x /= base) != 0);
 424:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 426:	8836                	mv	a6,a3
 428:	0018069b          	addiw	a3,a6,1
 42c:	02c5f7bb          	remuw	a5,a1,a2
 430:	1782                	slli	a5,a5,0x20
 432:	9381                	srli	a5,a5,0x20
 434:	97c6                	add	a5,a5,a7
 436:	0007c783          	lbu	a5,0(a5)
 43a:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 43e:	0705                	addi	a4,a4,1
 440:	02c5d7bb          	divuw	a5,a1,a2
 444:	fec5f0e3          	bleu	a2,a1,424 <printint+0x34>
  if(neg)
 448:	00030b63          	beqz	t1,45e <printint+0x6e>
    buf[i++] = '-';
 44c:	fd040793          	addi	a5,s0,-48
 450:	96be                	add	a3,a3,a5
 452:	02d00793          	li	a5,45
 456:	fef68823          	sb	a5,-16(a3)
 45a:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 45e:	02d05963          	blez	a3,490 <printint+0xa0>
 462:	89aa                	mv	s3,a0
 464:	fc040793          	addi	a5,s0,-64
 468:	00d784b3          	add	s1,a5,a3
 46c:	fff78913          	addi	s2,a5,-1
 470:	9936                	add	s2,s2,a3
 472:	36fd                	addiw	a3,a3,-1
 474:	1682                	slli	a3,a3,0x20
 476:	9281                	srli	a3,a3,0x20
 478:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 47c:	fff4c583          	lbu	a1,-1(s1)
 480:	854e                	mv	a0,s3
 482:	00000097          	auipc	ra,0x0
 486:	f4c080e7          	jalr	-180(ra) # 3ce <putc>
  while(--i >= 0)
 48a:	14fd                	addi	s1,s1,-1
 48c:	ff2498e3          	bne	s1,s2,47c <printint+0x8c>
}
 490:	70e2                	ld	ra,56(sp)
 492:	7442                	ld	s0,48(sp)
 494:	74a2                	ld	s1,40(sp)
 496:	7902                	ld	s2,32(sp)
 498:	69e2                	ld	s3,24(sp)
 49a:	6121                	addi	sp,sp,64
 49c:	8082                	ret

000000000000049e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49e:	7119                	addi	sp,sp,-128
 4a0:	fc86                	sd	ra,120(sp)
 4a2:	f8a2                	sd	s0,112(sp)
 4a4:	f4a6                	sd	s1,104(sp)
 4a6:	f0ca                	sd	s2,96(sp)
 4a8:	ecce                	sd	s3,88(sp)
 4aa:	e8d2                	sd	s4,80(sp)
 4ac:	e4d6                	sd	s5,72(sp)
 4ae:	e0da                	sd	s6,64(sp)
 4b0:	fc5e                	sd	s7,56(sp)
 4b2:	f862                	sd	s8,48(sp)
 4b4:	f466                	sd	s9,40(sp)
 4b6:	f06a                	sd	s10,32(sp)
 4b8:	ec6e                	sd	s11,24(sp)
 4ba:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4bc:	0005c483          	lbu	s1,0(a1)
 4c0:	18048d63          	beqz	s1,65a <vprintf+0x1bc>
 4c4:	8aaa                	mv	s5,a0
 4c6:	8b32                	mv	s6,a2
 4c8:	00158913          	addi	s2,a1,1
  state = 0;
 4cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ce:	02500a13          	li	s4,37
      if(c == 'd'){
 4d2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4d6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4da:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4de:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4e2:	00000b97          	auipc	s7,0x0
 4e6:	3c6b8b93          	addi	s7,s7,966 # 8a8 <digits>
 4ea:	a839                	j	508 <vprintf+0x6a>
        putc(fd, c);
 4ec:	85a6                	mv	a1,s1
 4ee:	8556                	mv	a0,s5
 4f0:	00000097          	auipc	ra,0x0
 4f4:	ede080e7          	jalr	-290(ra) # 3ce <putc>
 4f8:	a019                	j	4fe <vprintf+0x60>
    } else if(state == '%'){
 4fa:	01498f63          	beq	s3,s4,518 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4fe:	0905                	addi	s2,s2,1
 500:	fff94483          	lbu	s1,-1(s2)
 504:	14048b63          	beqz	s1,65a <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 508:	0004879b          	sext.w	a5,s1
    if(state == 0){
 50c:	fe0997e3          	bnez	s3,4fa <vprintf+0x5c>
      if(c == '%'){
 510:	fd479ee3          	bne	a5,s4,4ec <vprintf+0x4e>
        state = '%';
 514:	89be                	mv	s3,a5
 516:	b7e5                	j	4fe <vprintf+0x60>
      if(c == 'd'){
 518:	05878063          	beq	a5,s8,558 <vprintf+0xba>
      } else if(c == 'l') {
 51c:	05978c63          	beq	a5,s9,574 <vprintf+0xd6>
      } else if(c == 'x') {
 520:	07a78863          	beq	a5,s10,590 <vprintf+0xf2>
      } else if(c == 'p') {
 524:	09b78463          	beq	a5,s11,5ac <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 528:	07300713          	li	a4,115
 52c:	0ce78563          	beq	a5,a4,5f6 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 530:	06300713          	li	a4,99
 534:	0ee78c63          	beq	a5,a4,62c <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 538:	11478663          	beq	a5,s4,644 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 53c:	85d2                	mv	a1,s4
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e8e080e7          	jalr	-370(ra) # 3ce <putc>
        putc(fd, c);
 548:	85a6                	mv	a1,s1
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e82080e7          	jalr	-382(ra) # 3ce <putc>
      }
      state = 0;
 554:	4981                	li	s3,0
 556:	b765                	j	4fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 558:	008b0493          	addi	s1,s6,8
 55c:	4685                	li	a3,1
 55e:	4629                	li	a2,10
 560:	000b2583          	lw	a1,0(s6)
 564:	8556                	mv	a0,s5
 566:	00000097          	auipc	ra,0x0
 56a:	e8a080e7          	jalr	-374(ra) # 3f0 <printint>
 56e:	8b26                	mv	s6,s1
      state = 0;
 570:	4981                	li	s3,0
 572:	b771                	j	4fe <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 574:	008b0493          	addi	s1,s6,8
 578:	4681                	li	a3,0
 57a:	4629                	li	a2,10
 57c:	000b2583          	lw	a1,0(s6)
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e6e080e7          	jalr	-402(ra) # 3f0 <printint>
 58a:	8b26                	mv	s6,s1
      state = 0;
 58c:	4981                	li	s3,0
 58e:	bf85                	j	4fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 590:	008b0493          	addi	s1,s6,8
 594:	4681                	li	a3,0
 596:	4641                	li	a2,16
 598:	000b2583          	lw	a1,0(s6)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e52080e7          	jalr	-430(ra) # 3f0 <printint>
 5a6:	8b26                	mv	s6,s1
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	bf91                	j	4fe <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5ac:	008b0793          	addi	a5,s6,8
 5b0:	f8f43423          	sd	a5,-120(s0)
 5b4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5b8:	03000593          	li	a1,48
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e10080e7          	jalr	-496(ra) # 3ce <putc>
  putc(fd, 'x');
 5c6:	85ea                	mv	a1,s10
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e04080e7          	jalr	-508(ra) # 3ce <putc>
 5d2:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d4:	03c9d793          	srli	a5,s3,0x3c
 5d8:	97de                	add	a5,a5,s7
 5da:	0007c583          	lbu	a1,0(a5)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	dee080e7          	jalr	-530(ra) # 3ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e8:	0992                	slli	s3,s3,0x4
 5ea:	34fd                	addiw	s1,s1,-1
 5ec:	f4e5                	bnez	s1,5d4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b729                	j	4fe <vprintf+0x60>
        s = va_arg(ap, char*);
 5f6:	008b0993          	addi	s3,s6,8
 5fa:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 5fe:	c085                	beqz	s1,61e <vprintf+0x180>
        while(*s != 0){
 600:	0004c583          	lbu	a1,0(s1)
 604:	c9a1                	beqz	a1,654 <vprintf+0x1b6>
          putc(fd, *s);
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	dc6080e7          	jalr	-570(ra) # 3ce <putc>
          s++;
 610:	0485                	addi	s1,s1,1
        while(*s != 0){
 612:	0004c583          	lbu	a1,0(s1)
 616:	f9e5                	bnez	a1,606 <vprintf+0x168>
        s = va_arg(ap, char*);
 618:	8b4e                	mv	s6,s3
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b5cd                	j	4fe <vprintf+0x60>
          s = "(null)";
 61e:	00000497          	auipc	s1,0x0
 622:	2a248493          	addi	s1,s1,674 # 8c0 <digits+0x18>
        while(*s != 0){
 626:	02800593          	li	a1,40
 62a:	bff1                	j	606 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 62c:	008b0493          	addi	s1,s6,8
 630:	000b4583          	lbu	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d98080e7          	jalr	-616(ra) # 3ce <putc>
 63e:	8b26                	mv	s6,s1
      state = 0;
 640:	4981                	li	s3,0
 642:	bd75                	j	4fe <vprintf+0x60>
        putc(fd, c);
 644:	85d2                	mv	a1,s4
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	d86080e7          	jalr	-634(ra) # 3ce <putc>
      state = 0;
 650:	4981                	li	s3,0
 652:	b575                	j	4fe <vprintf+0x60>
        s = va_arg(ap, char*);
 654:	8b4e                	mv	s6,s3
      state = 0;
 656:	4981                	li	s3,0
 658:	b55d                	j	4fe <vprintf+0x60>
    }
  }
}
 65a:	70e6                	ld	ra,120(sp)
 65c:	7446                	ld	s0,112(sp)
 65e:	74a6                	ld	s1,104(sp)
 660:	7906                	ld	s2,96(sp)
 662:	69e6                	ld	s3,88(sp)
 664:	6a46                	ld	s4,80(sp)
 666:	6aa6                	ld	s5,72(sp)
 668:	6b06                	ld	s6,64(sp)
 66a:	7be2                	ld	s7,56(sp)
 66c:	7c42                	ld	s8,48(sp)
 66e:	7ca2                	ld	s9,40(sp)
 670:	7d02                	ld	s10,32(sp)
 672:	6de2                	ld	s11,24(sp)
 674:	6109                	addi	sp,sp,128
 676:	8082                	ret

0000000000000678 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 678:	715d                	addi	sp,sp,-80
 67a:	ec06                	sd	ra,24(sp)
 67c:	e822                	sd	s0,16(sp)
 67e:	1000                	addi	s0,sp,32
 680:	e010                	sd	a2,0(s0)
 682:	e414                	sd	a3,8(s0)
 684:	e818                	sd	a4,16(s0)
 686:	ec1c                	sd	a5,24(s0)
 688:	03043023          	sd	a6,32(s0)
 68c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 690:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 694:	8622                	mv	a2,s0
 696:	00000097          	auipc	ra,0x0
 69a:	e08080e7          	jalr	-504(ra) # 49e <vprintf>
}
 69e:	60e2                	ld	ra,24(sp)
 6a0:	6442                	ld	s0,16(sp)
 6a2:	6161                	addi	sp,sp,80
 6a4:	8082                	ret

00000000000006a6 <printf>:

void
printf(const char *fmt, ...)
{
 6a6:	711d                	addi	sp,sp,-96
 6a8:	ec06                	sd	ra,24(sp)
 6aa:	e822                	sd	s0,16(sp)
 6ac:	1000                	addi	s0,sp,32
 6ae:	e40c                	sd	a1,8(s0)
 6b0:	e810                	sd	a2,16(s0)
 6b2:	ec14                	sd	a3,24(s0)
 6b4:	f018                	sd	a4,32(s0)
 6b6:	f41c                	sd	a5,40(s0)
 6b8:	03043823          	sd	a6,48(s0)
 6bc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c0:	00840613          	addi	a2,s0,8
 6c4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c8:	85aa                	mv	a1,a0
 6ca:	4505                	li	a0,1
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dd2080e7          	jalr	-558(ra) # 49e <vprintf>
}
 6d4:	60e2                	ld	ra,24(sp)
 6d6:	6442                	ld	s0,16(sp)
 6d8:	6125                	addi	sp,sp,96
 6da:	8082                	ret

00000000000006dc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6dc:	1141                	addi	sp,sp,-16
 6de:	e422                	sd	s0,8(sp)
 6e0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e6:	00000797          	auipc	a5,0x0
 6ea:	1e278793          	addi	a5,a5,482 # 8c8 <__bss_start>
 6ee:	639c                	ld	a5,0(a5)
 6f0:	a805                	j	720 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f2:	4618                	lw	a4,8(a2)
 6f4:	9db9                	addw	a1,a1,a4
 6f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fa:	6398                	ld	a4,0(a5)
 6fc:	6318                	ld	a4,0(a4)
 6fe:	fee53823          	sd	a4,-16(a0)
 702:	a091                	j	746 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 704:	ff852703          	lw	a4,-8(a0)
 708:	9e39                	addw	a2,a2,a4
 70a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 70c:	ff053703          	ld	a4,-16(a0)
 710:	e398                	sd	a4,0(a5)
 712:	a099                	j	758 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 714:	6398                	ld	a4,0(a5)
 716:	00e7e463          	bltu	a5,a4,71e <free+0x42>
 71a:	00e6ea63          	bltu	a3,a4,72e <free+0x52>
{
 71e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 720:	fed7fae3          	bleu	a3,a5,714 <free+0x38>
 724:	6398                	ld	a4,0(a5)
 726:	00e6e463          	bltu	a3,a4,72e <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72a:	fee7eae3          	bltu	a5,a4,71e <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 72e:	ff852583          	lw	a1,-8(a0)
 732:	6390                	ld	a2,0(a5)
 734:	02059713          	slli	a4,a1,0x20
 738:	9301                	srli	a4,a4,0x20
 73a:	0712                	slli	a4,a4,0x4
 73c:	9736                	add	a4,a4,a3
 73e:	fae60ae3          	beq	a2,a4,6f2 <free+0x16>
    bp->s.ptr = p->s.ptr;
 742:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 746:	4790                	lw	a2,8(a5)
 748:	02061713          	slli	a4,a2,0x20
 74c:	9301                	srli	a4,a4,0x20
 74e:	0712                	slli	a4,a4,0x4
 750:	973e                	add	a4,a4,a5
 752:	fae689e3          	beq	a3,a4,704 <free+0x28>
  } else
    p->s.ptr = bp;
 756:	e394                	sd	a3,0(a5)
  freep = p;
 758:	00000717          	auipc	a4,0x0
 75c:	16f73823          	sd	a5,368(a4) # 8c8 <__bss_start>
}
 760:	6422                	ld	s0,8(sp)
 762:	0141                	addi	sp,sp,16
 764:	8082                	ret

0000000000000766 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 766:	7139                	addi	sp,sp,-64
 768:	fc06                	sd	ra,56(sp)
 76a:	f822                	sd	s0,48(sp)
 76c:	f426                	sd	s1,40(sp)
 76e:	f04a                	sd	s2,32(sp)
 770:	ec4e                	sd	s3,24(sp)
 772:	e852                	sd	s4,16(sp)
 774:	e456                	sd	s5,8(sp)
 776:	e05a                	sd	s6,0(sp)
 778:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77a:	02051993          	slli	s3,a0,0x20
 77e:	0209d993          	srli	s3,s3,0x20
 782:	09bd                	addi	s3,s3,15
 784:	0049d993          	srli	s3,s3,0x4
 788:	2985                	addiw	s3,s3,1
 78a:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 78e:	00000797          	auipc	a5,0x0
 792:	13a78793          	addi	a5,a5,314 # 8c8 <__bss_start>
 796:	6388                	ld	a0,0(a5)
 798:	c515                	beqz	a0,7c4 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79c:	4798                	lw	a4,8(a5)
 79e:	03277f63          	bleu	s2,a4,7dc <malloc+0x76>
 7a2:	8a4e                	mv	s4,s3
 7a4:	0009871b          	sext.w	a4,s3
 7a8:	6685                	lui	a3,0x1
 7aa:	00d77363          	bleu	a3,a4,7b0 <malloc+0x4a>
 7ae:	6a05                	lui	s4,0x1
 7b0:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 7b4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b8:	00000497          	auipc	s1,0x0
 7bc:	11048493          	addi	s1,s1,272 # 8c8 <__bss_start>
  if(p == (char*)-1)
 7c0:	5b7d                	li	s6,-1
 7c2:	a885                	j	832 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 7c4:	00000797          	auipc	a5,0x0
 7c8:	10c78793          	addi	a5,a5,268 # 8d0 <base>
 7cc:	00000717          	auipc	a4,0x0
 7d0:	0ef73e23          	sd	a5,252(a4) # 8c8 <__bss_start>
 7d4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7da:	b7e1                	j	7a2 <malloc+0x3c>
      if(p->s.size == nunits)
 7dc:	02e90b63          	beq	s2,a4,812 <malloc+0xac>
        p->s.size -= nunits;
 7e0:	4137073b          	subw	a4,a4,s3
 7e4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7e6:	1702                	slli	a4,a4,0x20
 7e8:	9301                	srli	a4,a4,0x20
 7ea:	0712                	slli	a4,a4,0x4
 7ec:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ee:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f2:	00000717          	auipc	a4,0x0
 7f6:	0ca73b23          	sd	a0,214(a4) # 8c8 <__bss_start>
      return (void*)(p + 1);
 7fa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7fe:	70e2                	ld	ra,56(sp)
 800:	7442                	ld	s0,48(sp)
 802:	74a2                	ld	s1,40(sp)
 804:	7902                	ld	s2,32(sp)
 806:	69e2                	ld	s3,24(sp)
 808:	6a42                	ld	s4,16(sp)
 80a:	6aa2                	ld	s5,8(sp)
 80c:	6b02                	ld	s6,0(sp)
 80e:	6121                	addi	sp,sp,64
 810:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 812:	6398                	ld	a4,0(a5)
 814:	e118                	sd	a4,0(a0)
 816:	bff1                	j	7f2 <malloc+0x8c>
  hp->s.size = nu;
 818:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 81c:	0541                	addi	a0,a0,16
 81e:	00000097          	auipc	ra,0x0
 822:	ebe080e7          	jalr	-322(ra) # 6dc <free>
  return freep;
 826:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 828:	d979                	beqz	a0,7fe <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	fb2777e3          	bleu	s2,a4,7dc <malloc+0x76>
    if(p == freep)
 832:	6098                	ld	a4,0(s1)
 834:	853e                	mv	a0,a5
 836:	fef71ae3          	bne	a4,a5,82a <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 83a:	8552                	mv	a0,s4
 83c:	00000097          	auipc	ra,0x0
 840:	b7a080e7          	jalr	-1158(ra) # 3b6 <sbrk>
  if(p == (char*)-1)
 844:	fd651ae3          	bne	a0,s6,818 <malloc+0xb2>
        return 0;
 848:	4501                	li	a0,0
 84a:	bf55                	j	7fe <malloc+0x98>
