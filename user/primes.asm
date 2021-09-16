
user/_primes：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find_prime>:
#include "kernel/stat.h"
#include "user/user.h"

//p管道用于存放已经被求得的素数筛过的管道，它将在使用当前求得的最大素数筛选的过程中被写入
void find_prime(int *p)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
   c:	84aa                	mv	s1,a0
    //从管道中读取第一个数为素数
    int prime = 0;
   e:	fc042e23          	sw	zero,-36(s0)
    int read_re = read(p[0], &prime, sizeof(prime));
  12:	4611                	li	a2,4
  14:	fdc40593          	addi	a1,s0,-36
  18:	4108                	lw	a0,0(a0)
  1a:	00000097          	auipc	ra,0x0
  1e:	3f8080e7          	jalr	1016(ra) # 412 <read>

    //如果写通道被关闭，说明没有数可被写入，算法结束
    if (read_re == 0)
  22:	cd15                	beqz	a0,5e <find_prime+0x5e>
    {
        close(p[1]);
        close(p[0]);
        return;
    }
    printf("prime %d\n", prime);
  24:	fdc42583          	lw	a1,-36(s0)
  28:	00001517          	auipc	a0,0x1
  2c:	8f050513          	addi	a0,a0,-1808 # 918 <malloc+0xe6>
  30:	00000097          	auipc	ra,0x0
  34:	742080e7          	jalr	1858(ra) # 772 <printf>

    //为使用prime筛选的线程分配管道
    int new_p[2];
    pipe(new_p);
  38:	fd040513          	addi	a0,s0,-48
  3c:	00000097          	auipc	ra,0x0
  40:	3ce080e7          	jalr	974(ra) # 40a <pipe>

    int pid = fork();
  44:	00000097          	auipc	ra,0x0
  48:	3ae080e7          	jalr	942(ra) # 3f2 <fork>
  4c:	892a                	mv	s2,a0

    if (pid == 0)
  4e:	c11d                	beqz	a0,74 <find_prime+0x74>
        find_prime(new_p);
        exit(0);
    }
    else
    {
        close(new_p[0]);
  50:	fd042503          	lw	a0,-48(s0)
  54:	00000097          	auipc	ra,0x0
  58:	3ce080e7          	jalr	974(ra) # 422 <close>
        //从管道p读数，用prime筛，直到读完
        int re = -1;
  5c:	a0b1                	j	a8 <find_prime+0xa8>
        close(p[1]);
  5e:	40c8                	lw	a0,4(s1)
  60:	00000097          	auipc	ra,0x0
  64:	3c2080e7          	jalr	962(ra) # 422 <close>
        close(p[0]);
  68:	4088                	lw	a0,0(s1)
  6a:	00000097          	auipc	ra,0x0
  6e:	3b8080e7          	jalr	952(ra) # 422 <close>
        return;
  72:	a059                	j	f8 <find_prime+0xf8>
        close(new_p[1]);
  74:	fd442503          	lw	a0,-44(s0)
  78:	00000097          	auipc	ra,0x0
  7c:	3aa080e7          	jalr	938(ra) # 422 <close>
        find_prime(new_p);
  80:	fd040513          	addi	a0,s0,-48
  84:	00000097          	auipc	ra,0x0
  88:	f7c080e7          	jalr	-132(ra) # 0 <find_prime>
        exit(0);
  8c:	4501                	li	a0,0
  8e:	00000097          	auipc	ra,0x0
  92:	36c080e7          	jalr	876(ra) # 3fa <exit>
            int number;
            re = read(p[0], &number, sizeof(number));
            if (re == 0)
                break;
            if (number % prime != 0)
                write(new_p[1], &number, sizeof(number));
  96:	4611                	li	a2,4
  98:	fcc40593          	addi	a1,s0,-52
  9c:	fd442503          	lw	a0,-44(s0)
  a0:	00000097          	auipc	ra,0x0
  a4:	37a080e7          	jalr	890(ra) # 41a <write>
            re = read(p[0], &number, sizeof(number));
  a8:	4611                	li	a2,4
  aa:	fcc40593          	addi	a1,s0,-52
  ae:	4088                	lw	a0,0(s1)
  b0:	00000097          	auipc	ra,0x0
  b4:	362080e7          	jalr	866(ra) # 412 <read>
            if (re == 0)
  b8:	c909                	beqz	a0,ca <find_prime+0xca>
            if (number % prime != 0)
  ba:	fcc42783          	lw	a5,-52(s0)
  be:	fdc42703          	lw	a4,-36(s0)
  c2:	02e7e7bb          	remw	a5,a5,a4
  c6:	d3ed                	beqz	a5,a8 <find_prime+0xa8>
  c8:	b7f9                	j	96 <find_prime+0x96>
        };

        close(new_p[1]);
  ca:	fd442503          	lw	a0,-44(s0)
  ce:	00000097          	auipc	ra,0x0
  d2:	354080e7          	jalr	852(ra) # 422 <close>

        int wait_pid = -1;
        do
        {
            wait_pid = wait(0);
  d6:	4501                	li	a0,0
  d8:	00000097          	auipc	ra,0x0
  dc:	32a080e7          	jalr	810(ra) # 402 <wait>
        } while (pid != wait_pid);
  e0:	fea91be3          	bne	s2,a0,d6 <find_prime+0xd6>
        wait(0);
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	31c080e7          	jalr	796(ra) # 402 <wait>

        close(p[0]);
  ee:	4088                	lw	a0,0(s1)
  f0:	00000097          	auipc	ra,0x0
  f4:	332080e7          	jalr	818(ra) # 422 <close>
    }

    return;
}
  f8:	70e2                	ld	ra,56(sp)
  fa:	7442                	ld	s0,48(sp)
  fc:	74a2                	ld	s1,40(sp)
  fe:	7902                	ld	s2,32(sp)
 100:	6121                	addi	sp,sp,64
 102:	8082                	ret

0000000000000104 <main>:

int main(int argc, char *argv[])
{
 104:	7179                	addi	sp,sp,-48
 106:	f406                	sd	ra,40(sp)
 108:	f022                	sd	s0,32(sp)
 10a:	ec26                	sd	s1,24(sp)
 10c:	1800                	addi	s0,sp,48
    // 创建初始管道
    int p[2];
    pipe(p);
 10e:	fd840513          	addi	a0,s0,-40
 112:	00000097          	auipc	ra,0x0
 116:	2f8080e7          	jalr	760(ra) # 40a <pipe>
    int max_n = 35;
    //写入数据
    for (int i = 2; i <= max_n; ++i)
 11a:	4789                	li	a5,2
 11c:	fcf42a23          	sw	a5,-44(s0)
 120:	02300493          	li	s1,35
        write(p[1], &i, sizeof(int));
 124:	4611                	li	a2,4
 126:	fd440593          	addi	a1,s0,-44
 12a:	fdc42503          	lw	a0,-36(s0)
 12e:	00000097          	auipc	ra,0x0
 132:	2ec080e7          	jalr	748(ra) # 41a <write>
    for (int i = 2; i <= max_n; ++i)
 136:	fd442783          	lw	a5,-44(s0)
 13a:	2785                	addiw	a5,a5,1
 13c:	0007871b          	sext.w	a4,a5
 140:	fcf42a23          	sw	a5,-44(s0)
 144:	fee4d0e3          	ble	a4,s1,124 <main+0x20>
    //关闭写描述符
    close(p[1]);
 148:	fdc42503          	lw	a0,-36(s0)
 14c:	00000097          	auipc	ra,0x0
 150:	2d6080e7          	jalr	726(ra) # 422 <close>
    //递归地筛素数
    find_prime(p);
 154:	fd840513          	addi	a0,s0,-40
 158:	00000097          	auipc	ra,0x0
 15c:	ea8080e7          	jalr	-344(ra) # 0 <find_prime>
    exit(0);
 160:	4501                	li	a0,0
 162:	00000097          	auipc	ra,0x0
 166:	298080e7          	jalr	664(ra) # 3fa <exit>

000000000000016a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 170:	87aa                	mv	a5,a0
 172:	0585                	addi	a1,a1,1
 174:	0785                	addi	a5,a5,1
 176:	fff5c703          	lbu	a4,-1(a1)
 17a:	fee78fa3          	sb	a4,-1(a5)
 17e:	fb75                	bnez	a4,172 <strcpy+0x8>
    ;
  return os;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18c:	00054783          	lbu	a5,0(a0)
 190:	cf91                	beqz	a5,1ac <strcmp+0x26>
 192:	0005c703          	lbu	a4,0(a1)
 196:	00f71b63          	bne	a4,a5,1ac <strcmp+0x26>
    p++, q++;
 19a:	0505                	addi	a0,a0,1
 19c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	c789                	beqz	a5,1ac <strcmp+0x26>
 1a4:	0005c703          	lbu	a4,0(a1)
 1a8:	fef709e3          	beq	a4,a5,19a <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 1ac:	0005c503          	lbu	a0,0(a1)
}
 1b0:	40a7853b          	subw	a0,a5,a0
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strlen>:

uint
strlen(const char *s)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cf91                	beqz	a5,1e0 <strlen+0x26>
 1c6:	0505                	addi	a0,a0,1
 1c8:	87aa                	mv	a5,a0
 1ca:	4685                	li	a3,1
 1cc:	9e89                	subw	a3,a3,a0
 1ce:	00f6853b          	addw	a0,a3,a5
 1d2:	0785                	addi	a5,a5,1
 1d4:	fff7c703          	lbu	a4,-1(a5)
 1d8:	fb7d                	bnez	a4,1ce <strlen+0x14>
    ;
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  for(n = 0; s[n]; n++)
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strlen+0x20>

00000000000001e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ea:	ce09                	beqz	a2,204 <memset+0x20>
 1ec:	87aa                	mv	a5,a0
 1ee:	fff6071b          	addiw	a4,a2,-1
 1f2:	1702                	slli	a4,a4,0x20
 1f4:	9301                	srli	a4,a4,0x20
 1f6:	0705                	addi	a4,a4,1
 1f8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1fa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1fe:	0785                	addi	a5,a5,1
 200:	fee79de3          	bne	a5,a4,1fa <memset+0x16>
  }
  return dst;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret

000000000000020a <strchr>:

char*
strchr(const char *s, char c)
{
 20a:	1141                	addi	sp,sp,-16
 20c:	e422                	sd	s0,8(sp)
 20e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 210:	00054783          	lbu	a5,0(a0)
 214:	cf91                	beqz	a5,230 <strchr+0x26>
    if(*s == c)
 216:	00f58a63          	beq	a1,a5,22a <strchr+0x20>
  for(; *s; s++)
 21a:	0505                	addi	a0,a0,1
 21c:	00054783          	lbu	a5,0(a0)
 220:	c781                	beqz	a5,228 <strchr+0x1e>
    if(*s == c)
 222:	feb79ce3          	bne	a5,a1,21a <strchr+0x10>
 226:	a011                	j	22a <strchr+0x20>
      return (char*)s;
  return 0;
 228:	4501                	li	a0,0
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  return 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <strchr+0x20>

0000000000000234 <gets>:

char*
gets(char *buf, int max)
{
 234:	711d                	addi	sp,sp,-96
 236:	ec86                	sd	ra,88(sp)
 238:	e8a2                	sd	s0,80(sp)
 23a:	e4a6                	sd	s1,72(sp)
 23c:	e0ca                	sd	s2,64(sp)
 23e:	fc4e                	sd	s3,56(sp)
 240:	f852                	sd	s4,48(sp)
 242:	f456                	sd	s5,40(sp)
 244:	f05a                	sd	s6,32(sp)
 246:	ec5e                	sd	s7,24(sp)
 248:	1080                	addi	s0,sp,96
 24a:	8baa                	mv	s7,a0
 24c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24e:	892a                	mv	s2,a0
 250:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 252:	4aa9                	li	s5,10
 254:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 256:	0019849b          	addiw	s1,s3,1
 25a:	0344d863          	ble	s4,s1,28a <gets+0x56>
    cc = read(0, &c, 1);
 25e:	4605                	li	a2,1
 260:	faf40593          	addi	a1,s0,-81
 264:	4501                	li	a0,0
 266:	00000097          	auipc	ra,0x0
 26a:	1ac080e7          	jalr	428(ra) # 412 <read>
    if(cc < 1)
 26e:	00a05e63          	blez	a0,28a <gets+0x56>
    buf[i++] = c;
 272:	faf44783          	lbu	a5,-81(s0)
 276:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27a:	01578763          	beq	a5,s5,288 <gets+0x54>
 27e:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 280:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 282:	fd679ae3          	bne	a5,s6,256 <gets+0x22>
 286:	a011                	j	28a <gets+0x56>
  for(i=0; i+1 < max; ){
 288:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28a:	99de                	add	s3,s3,s7
 28c:	00098023          	sb	zero,0(s3)
  return buf;
}
 290:	855e                	mv	a0,s7
 292:	60e6                	ld	ra,88(sp)
 294:	6446                	ld	s0,80(sp)
 296:	64a6                	ld	s1,72(sp)
 298:	6906                	ld	s2,64(sp)
 29a:	79e2                	ld	s3,56(sp)
 29c:	7a42                	ld	s4,48(sp)
 29e:	7aa2                	ld	s5,40(sp)
 2a0:	7b02                	ld	s6,32(sp)
 2a2:	6be2                	ld	s7,24(sp)
 2a4:	6125                	addi	sp,sp,96
 2a6:	8082                	ret

00000000000002a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a8:	1101                	addi	sp,sp,-32
 2aa:	ec06                	sd	ra,24(sp)
 2ac:	e822                	sd	s0,16(sp)
 2ae:	e426                	sd	s1,8(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	00000097          	auipc	ra,0x0
 2bc:	182080e7          	jalr	386(ra) # 43a <open>
  if(fd < 0)
 2c0:	02054563          	bltz	a0,2ea <stat+0x42>
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	18a080e7          	jalr	394(ra) # 452 <fstat>
 2d0:	892a                	mv	s2,a0
  close(fd);
 2d2:	8526                	mv	a0,s1
 2d4:	00000097          	auipc	ra,0x0
 2d8:	14e080e7          	jalr	334(ra) # 422 <close>
  return r;
}
 2dc:	854a                	mv	a0,s2
 2de:	60e2                	ld	ra,24(sp)
 2e0:	6442                	ld	s0,16(sp)
 2e2:	64a2                	ld	s1,8(sp)
 2e4:	6902                	ld	s2,0(sp)
 2e6:	6105                	addi	sp,sp,32
 2e8:	8082                	ret
    return -1;
 2ea:	597d                	li	s2,-1
 2ec:	bfc5                	j	2dc <stat+0x34>

00000000000002ee <atoi>:

int
atoi(const char *s)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f4:	00054683          	lbu	a3,0(a0)
 2f8:	fd06879b          	addiw	a5,a3,-48
 2fc:	0ff7f793          	andi	a5,a5,255
 300:	4725                	li	a4,9
 302:	02f76963          	bltu	a4,a5,334 <atoi+0x46>
 306:	862a                	mv	a2,a0
  n = 0;
 308:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 30a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 30c:	0605                	addi	a2,a2,1
 30e:	0025179b          	slliw	a5,a0,0x2
 312:	9fa9                	addw	a5,a5,a0
 314:	0017979b          	slliw	a5,a5,0x1
 318:	9fb5                	addw	a5,a5,a3
 31a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31e:	00064683          	lbu	a3,0(a2)
 322:	fd06871b          	addiw	a4,a3,-48
 326:	0ff77713          	andi	a4,a4,255
 32a:	fee5f1e3          	bleu	a4,a1,30c <atoi+0x1e>
  return n;
}
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	addi	sp,sp,16
 332:	8082                	ret
  n = 0;
 334:	4501                	li	a0,0
 336:	bfe5                	j	32e <atoi+0x40>

0000000000000338 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 338:	1141                	addi	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33e:	02b57663          	bleu	a1,a0,36a <memmove+0x32>
    while(n-- > 0)
 342:	02c05163          	blez	a2,364 <memmove+0x2c>
 346:	fff6079b          	addiw	a5,a2,-1
 34a:	1782                	slli	a5,a5,0x20
 34c:	9381                	srli	a5,a5,0x20
 34e:	0785                	addi	a5,a5,1
 350:	97aa                	add	a5,a5,a0
  dst = vdst;
 352:	872a                	mv	a4,a0
      *dst++ = *src++;
 354:	0585                	addi	a1,a1,1
 356:	0705                	addi	a4,a4,1
 358:	fff5c683          	lbu	a3,-1(a1)
 35c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 360:	fee79ae3          	bne	a5,a4,354 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 370:	fec05ae3          	blez	a2,364 <memmove+0x2c>
 374:	fff6079b          	addiw	a5,a2,-1
 378:	1782                	slli	a5,a5,0x20
 37a:	9381                	srli	a5,a5,0x20
 37c:	fff7c793          	not	a5,a5
 380:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 382:	15fd                	addi	a1,a1,-1
 384:	177d                	addi	a4,a4,-1
 386:	0005c683          	lbu	a3,0(a1)
 38a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38e:	fef71ae3          	bne	a4,a5,382 <memmove+0x4a>
 392:	bfc9                	j	364 <memmove+0x2c>

0000000000000394 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39a:	ce15                	beqz	a2,3d6 <memcmp+0x42>
 39c:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 3a0:	00054783          	lbu	a5,0(a0)
 3a4:	0005c703          	lbu	a4,0(a1)
 3a8:	02e79063          	bne	a5,a4,3c8 <memcmp+0x34>
 3ac:	1682                	slli	a3,a3,0x20
 3ae:	9281                	srli	a3,a3,0x20
 3b0:	0685                	addi	a3,a3,1
 3b2:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 3b4:	0505                	addi	a0,a0,1
    p2++;
 3b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b8:	00d50d63          	beq	a0,a3,3d2 <memcmp+0x3e>
    if (*p1 != *p2) {
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	0005c703          	lbu	a4,0(a1)
 3c4:	fee788e3          	beq	a5,a4,3b4 <memcmp+0x20>
      return *p1 - *p2;
 3c8:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  return 0;
 3d2:	4501                	li	a0,0
 3d4:	bfe5                	j	3cc <memcmp+0x38>
 3d6:	4501                	li	a0,0
 3d8:	bfd5                	j	3cc <memcmp+0x38>

00000000000003da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3da:	1141                	addi	sp,sp,-16
 3dc:	e406                	sd	ra,8(sp)
 3de:	e022                	sd	s0,0(sp)
 3e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e2:	00000097          	auipc	ra,0x0
 3e6:	f56080e7          	jalr	-170(ra) # 338 <memmove>
}
 3ea:	60a2                	ld	ra,8(sp)
 3ec:	6402                	ld	s0,0(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret

00000000000003f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f2:	4885                	li	a7,1
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fa:	4889                	li	a7,2
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <wait>:
.global wait
wait:
 li a7, SYS_wait
 402:	488d                	li	a7,3
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40a:	4891                	li	a7,4
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <read>:
.global read
read:
 li a7, SYS_read
 412:	4895                	li	a7,5
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <write>:
.global write
write:
 li a7, SYS_write
 41a:	48c1                	li	a7,16
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <close>:
.global close
close:
 li a7, SYS_close
 422:	48d5                	li	a7,21
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <kill>:
.global kill
kill:
 li a7, SYS_kill
 42a:	4899                	li	a7,6
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <exec>:
.global exec
exec:
 li a7, SYS_exec
 432:	489d                	li	a7,7
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <open>:
.global open
open:
 li a7, SYS_open
 43a:	48bd                	li	a7,15
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 442:	48c5                	li	a7,17
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44a:	48c9                	li	a7,18
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 452:	48a1                	li	a7,8
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <link>:
.global link
link:
 li a7, SYS_link
 45a:	48cd                	li	a7,19
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 462:	48d1                	li	a7,20
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46a:	48a5                	li	a7,9
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <dup>:
.global dup
dup:
 li a7, SYS_dup
 472:	48a9                	li	a7,10
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47a:	48ad                	li	a7,11
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 482:	48b1                	li	a7,12
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48a:	48b5                	li	a7,13
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 492:	48b9                	li	a7,14
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49a:	1101                	addi	sp,sp,-32
 49c:	ec06                	sd	ra,24(sp)
 49e:	e822                	sd	s0,16(sp)
 4a0:	1000                	addi	s0,sp,32
 4a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a6:	4605                	li	a2,1
 4a8:	fef40593          	addi	a1,s0,-17
 4ac:	00000097          	auipc	ra,0x0
 4b0:	f6e080e7          	jalr	-146(ra) # 41a <write>
}
 4b4:	60e2                	ld	ra,24(sp)
 4b6:	6442                	ld	s0,16(sp)
 4b8:	6105                	addi	sp,sp,32
 4ba:	8082                	ret

00000000000004bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4bc:	7139                	addi	sp,sp,-64
 4be:	fc06                	sd	ra,56(sp)
 4c0:	f822                	sd	s0,48(sp)
 4c2:	f426                	sd	s1,40(sp)
 4c4:	f04a                	sd	s2,32(sp)
 4c6:	ec4e                	sd	s3,24(sp)
 4c8:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ca:	c299                	beqz	a3,4d0 <printint+0x14>
 4cc:	0005cd63          	bltz	a1,4e6 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d0:	2581                	sext.w	a1,a1
  neg = 0;
 4d2:	4301                	li	t1,0
 4d4:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 4d8:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 4da:	2601                	sext.w	a2,a2
 4dc:	00000897          	auipc	a7,0x0
 4e0:	44c88893          	addi	a7,a7,1100 # 928 <digits>
 4e4:	a801                	j	4f4 <printint+0x38>
    x = -xx;
 4e6:	40b005bb          	negw	a1,a1
 4ea:	2581                	sext.w	a1,a1
    neg = 1;
 4ec:	4305                	li	t1,1
    x = -xx;
 4ee:	b7dd                	j	4d4 <printint+0x18>
  }while((x /= base) != 0);
 4f0:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 4f2:	8836                	mv	a6,a3
 4f4:	0018069b          	addiw	a3,a6,1
 4f8:	02c5f7bb          	remuw	a5,a1,a2
 4fc:	1782                	slli	a5,a5,0x20
 4fe:	9381                	srli	a5,a5,0x20
 500:	97c6                	add	a5,a5,a7
 502:	0007c783          	lbu	a5,0(a5)
 506:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 50a:	0705                	addi	a4,a4,1
 50c:	02c5d7bb          	divuw	a5,a1,a2
 510:	fec5f0e3          	bleu	a2,a1,4f0 <printint+0x34>
  if(neg)
 514:	00030b63          	beqz	t1,52a <printint+0x6e>
    buf[i++] = '-';
 518:	fd040793          	addi	a5,s0,-48
 51c:	96be                	add	a3,a3,a5
 51e:	02d00793          	li	a5,45
 522:	fef68823          	sb	a5,-16(a3)
 526:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 52a:	02d05963          	blez	a3,55c <printint+0xa0>
 52e:	89aa                	mv	s3,a0
 530:	fc040793          	addi	a5,s0,-64
 534:	00d784b3          	add	s1,a5,a3
 538:	fff78913          	addi	s2,a5,-1
 53c:	9936                	add	s2,s2,a3
 53e:	36fd                	addiw	a3,a3,-1
 540:	1682                	slli	a3,a3,0x20
 542:	9281                	srli	a3,a3,0x20
 544:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 548:	fff4c583          	lbu	a1,-1(s1)
 54c:	854e                	mv	a0,s3
 54e:	00000097          	auipc	ra,0x0
 552:	f4c080e7          	jalr	-180(ra) # 49a <putc>
  while(--i >= 0)
 556:	14fd                	addi	s1,s1,-1
 558:	ff2498e3          	bne	s1,s2,548 <printint+0x8c>
}
 55c:	70e2                	ld	ra,56(sp)
 55e:	7442                	ld	s0,48(sp)
 560:	74a2                	ld	s1,40(sp)
 562:	7902                	ld	s2,32(sp)
 564:	69e2                	ld	s3,24(sp)
 566:	6121                	addi	sp,sp,64
 568:	8082                	ret

000000000000056a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56a:	7119                	addi	sp,sp,-128
 56c:	fc86                	sd	ra,120(sp)
 56e:	f8a2                	sd	s0,112(sp)
 570:	f4a6                	sd	s1,104(sp)
 572:	f0ca                	sd	s2,96(sp)
 574:	ecce                	sd	s3,88(sp)
 576:	e8d2                	sd	s4,80(sp)
 578:	e4d6                	sd	s5,72(sp)
 57a:	e0da                	sd	s6,64(sp)
 57c:	fc5e                	sd	s7,56(sp)
 57e:	f862                	sd	s8,48(sp)
 580:	f466                	sd	s9,40(sp)
 582:	f06a                	sd	s10,32(sp)
 584:	ec6e                	sd	s11,24(sp)
 586:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c483          	lbu	s1,0(a1)
 58c:	18048d63          	beqz	s1,726 <vprintf+0x1bc>
 590:	8aaa                	mv	s5,a0
 592:	8b32                	mv	s6,a2
 594:	00158913          	addi	s2,a1,1
  state = 0;
 598:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 59a:	02500a13          	li	s4,37
      if(c == 'd'){
 59e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5a2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5a6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5aa:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ae:	00000b97          	auipc	s7,0x0
 5b2:	37ab8b93          	addi	s7,s7,890 # 928 <digits>
 5b6:	a839                	j	5d4 <vprintf+0x6a>
        putc(fd, c);
 5b8:	85a6                	mv	a1,s1
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	ede080e7          	jalr	-290(ra) # 49a <putc>
 5c4:	a019                	j	5ca <vprintf+0x60>
    } else if(state == '%'){
 5c6:	01498f63          	beq	s3,s4,5e4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5ca:	0905                	addi	s2,s2,1
 5cc:	fff94483          	lbu	s1,-1(s2)
 5d0:	14048b63          	beqz	s1,726 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 5d4:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5d8:	fe0997e3          	bnez	s3,5c6 <vprintf+0x5c>
      if(c == '%'){
 5dc:	fd479ee3          	bne	a5,s4,5b8 <vprintf+0x4e>
        state = '%';
 5e0:	89be                	mv	s3,a5
 5e2:	b7e5                	j	5ca <vprintf+0x60>
      if(c == 'd'){
 5e4:	05878063          	beq	a5,s8,624 <vprintf+0xba>
      } else if(c == 'l') {
 5e8:	05978c63          	beq	a5,s9,640 <vprintf+0xd6>
      } else if(c == 'x') {
 5ec:	07a78863          	beq	a5,s10,65c <vprintf+0xf2>
      } else if(c == 'p') {
 5f0:	09b78463          	beq	a5,s11,678 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5f4:	07300713          	li	a4,115
 5f8:	0ce78563          	beq	a5,a4,6c2 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5fc:	06300713          	li	a4,99
 600:	0ee78c63          	beq	a5,a4,6f8 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 604:	11478663          	beq	a5,s4,710 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 608:	85d2                	mv	a1,s4
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e8e080e7          	jalr	-370(ra) # 49a <putc>
        putc(fd, c);
 614:	85a6                	mv	a1,s1
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e82080e7          	jalr	-382(ra) # 49a <putc>
      }
      state = 0;
 620:	4981                	li	s3,0
 622:	b765                	j	5ca <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 624:	008b0493          	addi	s1,s6,8
 628:	4685                	li	a3,1
 62a:	4629                	li	a2,10
 62c:	000b2583          	lw	a1,0(s6)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e8a080e7          	jalr	-374(ra) # 4bc <printint>
 63a:	8b26                	mv	s6,s1
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b771                	j	5ca <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 640:	008b0493          	addi	s1,s6,8
 644:	4681                	li	a3,0
 646:	4629                	li	a2,10
 648:	000b2583          	lw	a1,0(s6)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e6e080e7          	jalr	-402(ra) # 4bc <printint>
 656:	8b26                	mv	s6,s1
      state = 0;
 658:	4981                	li	s3,0
 65a:	bf85                	j	5ca <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 65c:	008b0493          	addi	s1,s6,8
 660:	4681                	li	a3,0
 662:	4641                	li	a2,16
 664:	000b2583          	lw	a1,0(s6)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e52080e7          	jalr	-430(ra) # 4bc <printint>
 672:	8b26                	mv	s6,s1
      state = 0;
 674:	4981                	li	s3,0
 676:	bf91                	j	5ca <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 678:	008b0793          	addi	a5,s6,8
 67c:	f8f43423          	sd	a5,-120(s0)
 680:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 684:	03000593          	li	a1,48
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e10080e7          	jalr	-496(ra) # 49a <putc>
  putc(fd, 'x');
 692:	85ea                	mv	a1,s10
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e04080e7          	jalr	-508(ra) # 49a <putc>
 69e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6a0:	03c9d793          	srli	a5,s3,0x3c
 6a4:	97de                	add	a5,a5,s7
 6a6:	0007c583          	lbu	a1,0(a5)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	dee080e7          	jalr	-530(ra) # 49a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b4:	0992                	slli	s3,s3,0x4
 6b6:	34fd                	addiw	s1,s1,-1
 6b8:	f4e5                	bnez	s1,6a0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6ba:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b729                	j	5ca <vprintf+0x60>
        s = va_arg(ap, char*);
 6c2:	008b0993          	addi	s3,s6,8
 6c6:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 6ca:	c085                	beqz	s1,6ea <vprintf+0x180>
        while(*s != 0){
 6cc:	0004c583          	lbu	a1,0(s1)
 6d0:	c9a1                	beqz	a1,720 <vprintf+0x1b6>
          putc(fd, *s);
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	dc6080e7          	jalr	-570(ra) # 49a <putc>
          s++;
 6dc:	0485                	addi	s1,s1,1
        while(*s != 0){
 6de:	0004c583          	lbu	a1,0(s1)
 6e2:	f9e5                	bnez	a1,6d2 <vprintf+0x168>
        s = va_arg(ap, char*);
 6e4:	8b4e                	mv	s6,s3
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b5cd                	j	5ca <vprintf+0x60>
          s = "(null)";
 6ea:	00000497          	auipc	s1,0x0
 6ee:	25648493          	addi	s1,s1,598 # 940 <digits+0x18>
        while(*s != 0){
 6f2:	02800593          	li	a1,40
 6f6:	bff1                	j	6d2 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 6f8:	008b0493          	addi	s1,s6,8
 6fc:	000b4583          	lbu	a1,0(s6)
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	d98080e7          	jalr	-616(ra) # 49a <putc>
 70a:	8b26                	mv	s6,s1
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bd75                	j	5ca <vprintf+0x60>
        putc(fd, c);
 710:	85d2                	mv	a1,s4
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	d86080e7          	jalr	-634(ra) # 49a <putc>
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b575                	j	5ca <vprintf+0x60>
        s = va_arg(ap, char*);
 720:	8b4e                	mv	s6,s3
      state = 0;
 722:	4981                	li	s3,0
 724:	b55d                	j	5ca <vprintf+0x60>
    }
  }
}
 726:	70e6                	ld	ra,120(sp)
 728:	7446                	ld	s0,112(sp)
 72a:	74a6                	ld	s1,104(sp)
 72c:	7906                	ld	s2,96(sp)
 72e:	69e6                	ld	s3,88(sp)
 730:	6a46                	ld	s4,80(sp)
 732:	6aa6                	ld	s5,72(sp)
 734:	6b06                	ld	s6,64(sp)
 736:	7be2                	ld	s7,56(sp)
 738:	7c42                	ld	s8,48(sp)
 73a:	7ca2                	ld	s9,40(sp)
 73c:	7d02                	ld	s10,32(sp)
 73e:	6de2                	ld	s11,24(sp)
 740:	6109                	addi	sp,sp,128
 742:	8082                	ret

0000000000000744 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 744:	715d                	addi	sp,sp,-80
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e010                	sd	a2,0(s0)
 74e:	e414                	sd	a3,8(s0)
 750:	e818                	sd	a4,16(s0)
 752:	ec1c                	sd	a5,24(s0)
 754:	03043023          	sd	a6,32(s0)
 758:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 760:	8622                	mv	a2,s0
 762:	00000097          	auipc	ra,0x0
 766:	e08080e7          	jalr	-504(ra) # 56a <vprintf>
}
 76a:	60e2                	ld	ra,24(sp)
 76c:	6442                	ld	s0,16(sp)
 76e:	6161                	addi	sp,sp,80
 770:	8082                	ret

0000000000000772 <printf>:

void
printf(const char *fmt, ...)
{
 772:	711d                	addi	sp,sp,-96
 774:	ec06                	sd	ra,24(sp)
 776:	e822                	sd	s0,16(sp)
 778:	1000                	addi	s0,sp,32
 77a:	e40c                	sd	a1,8(s0)
 77c:	e810                	sd	a2,16(s0)
 77e:	ec14                	sd	a3,24(s0)
 780:	f018                	sd	a4,32(s0)
 782:	f41c                	sd	a5,40(s0)
 784:	03043823          	sd	a6,48(s0)
 788:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	00840613          	addi	a2,s0,8
 790:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 794:	85aa                	mv	a1,a0
 796:	4505                	li	a0,1
 798:	00000097          	auipc	ra,0x0
 79c:	dd2080e7          	jalr	-558(ra) # 56a <vprintf>
}
 7a0:	60e2                	ld	ra,24(sp)
 7a2:	6442                	ld	s0,16(sp)
 7a4:	6125                	addi	sp,sp,96
 7a6:	8082                	ret

00000000000007a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a8:	1141                	addi	sp,sp,-16
 7aa:	e422                	sd	s0,8(sp)
 7ac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b2:	00000797          	auipc	a5,0x0
 7b6:	19678793          	addi	a5,a5,406 # 948 <__bss_start>
 7ba:	639c                	ld	a5,0(a5)
 7bc:	a805                	j	7ec <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7be:	4618                	lw	a4,8(a2)
 7c0:	9db9                	addw	a1,a1,a4
 7c2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	6318                	ld	a4,0(a4)
 7ca:	fee53823          	sd	a4,-16(a0)
 7ce:	a091                	j	812 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d0:	ff852703          	lw	a4,-8(a0)
 7d4:	9e39                	addw	a2,a2,a4
 7d6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7d8:	ff053703          	ld	a4,-16(a0)
 7dc:	e398                	sd	a4,0(a5)
 7de:	a099                	j	824 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x42>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x52>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bleu	a3,a5,7e0 <free+0x38>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059713          	slli	a4,a1,0x20
 804:	9301                	srli	a4,a4,0x20
 806:	0712                	slli	a4,a4,0x4
 808:	9736                	add	a4,a4,a3
 80a:	fae60ae3          	beq	a2,a4,7be <free+0x16>
    bp->s.ptr = p->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061713          	slli	a4,a2,0x20
 818:	9301                	srli	a4,a4,0x20
 81a:	0712                	slli	a4,a4,0x4
 81c:	973e                	add	a4,a4,a5
 81e:	fae689e3          	beq	a3,a4,7d0 <free+0x28>
  } else
    p->s.ptr = bp;
 822:	e394                	sd	a3,0(a5)
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	12f73223          	sd	a5,292(a4) # 948 <__bss_start>
}
 82c:	6422                	ld	s0,8(sp)
 82e:	0141                	addi	sp,sp,16
 830:	8082                	ret

0000000000000832 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 832:	7139                	addi	sp,sp,-64
 834:	fc06                	sd	ra,56(sp)
 836:	f822                	sd	s0,48(sp)
 838:	f426                	sd	s1,40(sp)
 83a:	f04a                	sd	s2,32(sp)
 83c:	ec4e                	sd	s3,24(sp)
 83e:	e852                	sd	s4,16(sp)
 840:	e456                	sd	s5,8(sp)
 842:	e05a                	sd	s6,0(sp)
 844:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 846:	02051993          	slli	s3,a0,0x20
 84a:	0209d993          	srli	s3,s3,0x20
 84e:	09bd                	addi	s3,s3,15
 850:	0049d993          	srli	s3,s3,0x4
 854:	2985                	addiw	s3,s3,1
 856:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 85a:	00000797          	auipc	a5,0x0
 85e:	0ee78793          	addi	a5,a5,238 # 948 <__bss_start>
 862:	6388                	ld	a0,0(a5)
 864:	c515                	beqz	a0,890 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	03277f63          	bleu	s2,a4,8a8 <malloc+0x76>
 86e:	8a4e                	mv	s4,s3
 870:	0009871b          	sext.w	a4,s3
 874:	6685                	lui	a3,0x1
 876:	00d77363          	bleu	a3,a4,87c <malloc+0x4a>
 87a:	6a05                	lui	s4,0x1
 87c:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 880:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 884:	00000497          	auipc	s1,0x0
 888:	0c448493          	addi	s1,s1,196 # 948 <__bss_start>
  if(p == (char*)-1)
 88c:	5b7d                	li	s6,-1
 88e:	a885                	j	8fe <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 890:	00000797          	auipc	a5,0x0
 894:	0c078793          	addi	a5,a5,192 # 950 <base>
 898:	00000717          	auipc	a4,0x0
 89c:	0af73823          	sd	a5,176(a4) # 948 <__bss_start>
 8a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a6:	b7e1                	j	86e <malloc+0x3c>
      if(p->s.size == nunits)
 8a8:	02e90b63          	beq	s2,a4,8de <malloc+0xac>
        p->s.size -= nunits;
 8ac:	4137073b          	subw	a4,a4,s3
 8b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b2:	1702                	slli	a4,a4,0x20
 8b4:	9301                	srli	a4,a4,0x20
 8b6:	0712                	slli	a4,a4,0x4
 8b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8be:	00000717          	auipc	a4,0x0
 8c2:	08a73523          	sd	a0,138(a4) # 948 <__bss_start>
      return (void*)(p + 1);
 8c6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ca:	70e2                	ld	ra,56(sp)
 8cc:	7442                	ld	s0,48(sp)
 8ce:	74a2                	ld	s1,40(sp)
 8d0:	7902                	ld	s2,32(sp)
 8d2:	69e2                	ld	s3,24(sp)
 8d4:	6a42                	ld	s4,16(sp)
 8d6:	6aa2                	ld	s5,8(sp)
 8d8:	6b02                	ld	s6,0(sp)
 8da:	6121                	addi	sp,sp,64
 8dc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8de:	6398                	ld	a4,0(a5)
 8e0:	e118                	sd	a4,0(a0)
 8e2:	bff1                	j	8be <malloc+0x8c>
  hp->s.size = nu;
 8e4:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 8e8:	0541                	addi	a0,a0,16
 8ea:	00000097          	auipc	ra,0x0
 8ee:	ebe080e7          	jalr	-322(ra) # 7a8 <free>
  return freep;
 8f2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8f4:	d979                	beqz	a0,8ca <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f8:	4798                	lw	a4,8(a5)
 8fa:	fb2777e3          	bleu	s2,a4,8a8 <malloc+0x76>
    if(p == freep)
 8fe:	6098                	ld	a4,0(s1)
 900:	853e                	mv	a0,a5
 902:	fef71ae3          	bne	a4,a5,8f6 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 906:	8552                	mv	a0,s4
 908:	00000097          	auipc	ra,0x0
 90c:	b7a080e7          	jalr	-1158(ra) # 482 <sbrk>
  if(p == (char*)-1)
 910:	fd651ae3          	bne	a0,s6,8e4 <malloc+0xb2>
        return 0;
 914:	4501                	li	a0,0
 916:	bf55                	j	8ca <malloc+0x98>
