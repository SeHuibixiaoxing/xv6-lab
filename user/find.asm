
user/_find：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getname>:
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"

void getname(char *path, char *name)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  10:	892e                	mv	s2,a1
    char *p;
    for (p = path + strlen(path); p >= path && *p != '/'; --p)
  12:	00000097          	auipc	ra,0x0
  16:	344080e7          	jalr	836(ra) # 356 <strlen>
  1a:	1502                	slli	a0,a0,0x20
  1c:	9101                	srli	a0,a0,0x20
  1e:	9526                	add	a0,a0,s1
  20:	02956163          	bltu	a0,s1,42 <getname+0x42>
  24:	00054703          	lbu	a4,0(a0)
  28:	02f00793          	li	a5,47
  2c:	00f70b63          	beq	a4,a5,42 <getname+0x42>
  30:	02f00713          	li	a4,47
  34:	157d                	addi	a0,a0,-1
  36:	00956663          	bltu	a0,s1,42 <getname+0x42>
  3a:	00054783          	lbu	a5,0(a0)
  3e:	fee79be3          	bne	a5,a4,34 <getname+0x34>
        ;

    ++p;
  42:	00150493          	addi	s1,a0,1
    //printf("[p]:%s\n", p);
    int namelen = strlen(p);
  46:	8526                	mv	a0,s1
  48:	00000097          	auipc	ra,0x0
  4c:	30e080e7          	jalr	782(ra) # 356 <strlen>
  50:	0005099b          	sext.w	s3,a0
    memmove(name, p, namelen);
  54:	864e                	mv	a2,s3
  56:	85a6                	mv	a1,s1
  58:	854a                	mv	a0,s2
  5a:	00000097          	auipc	ra,0x0
  5e:	47a080e7          	jalr	1146(ra) # 4d4 <memmove>
    name[namelen] = 0;
  62:	994e                	add	s2,s2,s3
  64:	00090023          	sb	zero,0(s2)
}
  68:	70a2                	ld	ra,40(sp)
  6a:	7402                	ld	s0,32(sp)
  6c:	64e2                	ld	s1,24(sp)
  6e:	6942                	ld	s2,16(sp)
  70:	69a2                	ld	s3,8(sp)
  72:	6145                	addi	sp,sp,48
  74:	8082                	ret

0000000000000076 <strdot>:

int strdot(char *str)
{
  76:	1141                	addi	sp,sp,-16
  78:	e422                	sd	s0,8(sp)
  7a:	0800                	addi	s0,sp,16
    if (str[0] == '.' && str[1] == 0)
  7c:	00054703          	lbu	a4,0(a0)
  80:	02e00793          	li	a5,46
  84:	00f70763          	beq	a4,a5,92 <strdot+0x1c>
        return 1;
    if (str[0] == '.' && str[1] == '.' && str[2] == 0)
        return 1;
    return 0;
  88:	4781                	li	a5,0
}
  8a:	853e                	mv	a0,a5
  8c:	6422                	ld	s0,8(sp)
  8e:	0141                	addi	sp,sp,16
  90:	8082                	ret
    if (str[0] == '.' && str[1] == 0)
  92:	00154703          	lbu	a4,1(a0)
        return 1;
  96:	4785                	li	a5,1
    if (str[0] == '.' && str[1] == 0)
  98:	db6d                	beqz	a4,8a <strdot+0x14>
    if (str[0] == '.' && str[1] == '.' && str[2] == 0)
  9a:	02e00693          	li	a3,46
    return 0;
  9e:	4781                	li	a5,0
    if (str[0] == '.' && str[1] == '.' && str[2] == 0)
  a0:	fed715e3          	bne	a4,a3,8a <strdot+0x14>
  a4:	00254783          	lbu	a5,2(a0)
        return 1;
  a8:	0017b793          	seqz	a5,a5
  ac:	bff9                	j	8a <strdot+0x14>

00000000000000ae <find_file>:

int find_file(char *path, char *name)
{
  ae:	7119                	addi	sp,sp,-128
  b0:	fc86                	sd	ra,120(sp)
  b2:	f8a2                	sd	s0,112(sp)
  b4:	f4a6                	sd	s1,104(sp)
  b6:	f0ca                	sd	s2,96(sp)
  b8:	ecce                	sd	s3,88(sp)
  ba:	e8d2                	sd	s4,80(sp)
  bc:	e4d6                	sd	s5,72(sp)
  be:	0100                	addi	s0,sp,128
  c0:	89aa                	mv	s3,a0
  c2:	8aae                	mv	s5,a1
    //printf("[path]:%s\n", path);

    char buf[DIRSIZ + 1];
    int fd = open(path, 0);
  c4:	4581                	li	a1,0
  c6:	00000097          	auipc	ra,0x0
  ca:	510080e7          	jalr	1296(ra) # 5d6 <open>
    struct dirent de;
    char *tmppath;
    if (fd < 0)
  ce:	04054663          	bltz	a0,11a <find_file+0x6c>
  d2:	84aa                	mv	s1,a0
        printf("Can't open file %s\n", path);
        return 0;
    }

    struct stat st;
    if (fstat(fd, &st) < 0)
  d4:	f8840593          	addi	a1,s0,-120
  d8:	00000097          	auipc	ra,0x0
  dc:	516080e7          	jalr	1302(ra) # 5ee <fstat>
  e0:	04054863          	bltz	a0,130 <find_file+0x82>
    {
        printf("Can't get the stat of %s\n", path);
        return 0;
    }
    //printf("type:%d\n", st.type);
    if (st.type == T_FILE)
  e4:	f9041783          	lh	a5,-112(s0)
  e8:	0007869b          	sext.w	a3,a5
  ec:	4709                	li	a4,2
  ee:	04e68c63          	beq	a3,a4,146 <find_file+0x98>
        getname(path, buf);
        //printf("[path name]:%s, [path]:%s\n", buf, path);
        if (strcmp(buf, name) == 0)
            printf("%s\n", path);
    }
    else if (st.type == T_DIR)
  f2:	2781                	sext.w	a5,a5
  f4:	4705                	li	a4,1
  f6:	08e78163          	beq	a5,a4,178 <find_file+0xca>
                return 0;
            }
        }
    }
    // printf("return\n");
    close(fd);
  fa:	8526                	mv	a0,s1
  fc:	00000097          	auipc	ra,0x0
 100:	4c2080e7          	jalr	1218(ra) # 5be <close>
    return 1;
 104:	4905                	li	s2,1
}
 106:	854a                	mv	a0,s2
 108:	70e6                	ld	ra,120(sp)
 10a:	7446                	ld	s0,112(sp)
 10c:	74a6                	ld	s1,104(sp)
 10e:	7906                	ld	s2,96(sp)
 110:	69e6                	ld	s3,88(sp)
 112:	6a46                	ld	s4,80(sp)
 114:	6aa6                	ld	s5,72(sp)
 116:	6109                	addi	sp,sp,128
 118:	8082                	ret
        printf("Can't open file %s\n", path);
 11a:	85ce                	mv	a1,s3
 11c:	00001517          	auipc	a0,0x1
 120:	99c50513          	addi	a0,a0,-1636 # ab8 <malloc+0xea>
 124:	00000097          	auipc	ra,0x0
 128:	7ea080e7          	jalr	2026(ra) # 90e <printf>
        return 0;
 12c:	4901                	li	s2,0
 12e:	bfe1                	j	106 <find_file+0x58>
        printf("Can't get the stat of %s\n", path);
 130:	85ce                	mv	a1,s3
 132:	00001517          	auipc	a0,0x1
 136:	99e50513          	addi	a0,a0,-1634 # ad0 <malloc+0x102>
 13a:	00000097          	auipc	ra,0x0
 13e:	7d4080e7          	jalr	2004(ra) # 90e <printf>
        return 0;
 142:	4901                	li	s2,0
 144:	b7c9                	j	106 <find_file+0x58>
        getname(path, buf);
 146:	fb040593          	addi	a1,s0,-80
 14a:	854e                	mv	a0,s3
 14c:	00000097          	auipc	ra,0x0
 150:	eb4080e7          	jalr	-332(ra) # 0 <getname>
        if (strcmp(buf, name) == 0)
 154:	85d6                	mv	a1,s5
 156:	fb040513          	addi	a0,s0,-80
 15a:	00000097          	auipc	ra,0x0
 15e:	1c8080e7          	jalr	456(ra) # 322 <strcmp>
 162:	fd41                	bnez	a0,fa <find_file+0x4c>
            printf("%s\n", path);
 164:	85ce                	mv	a1,s3
 166:	00001517          	auipc	a0,0x1
 16a:	96250513          	addi	a0,a0,-1694 # ac8 <malloc+0xfa>
 16e:	00000097          	auipc	ra,0x0
 172:	7a0080e7          	jalr	1952(ra) # 90e <printf>
 176:	b751                	j	fa <find_file+0x4c>
        tmppath = path + strlen(path);
 178:	854e                	mv	a0,s3
 17a:	00000097          	auipc	ra,0x0
 17e:	1dc080e7          	jalr	476(ra) # 356 <strlen>
 182:	1502                	slli	a0,a0,0x20
 184:	9101                	srli	a0,a0,0x20
 186:	954e                	add	a0,a0,s3
        *tmppath = '/';
 188:	02f00793          	li	a5,47
 18c:	00f50023          	sb	a5,0(a0)
        ++tmppath;
 190:	00150a13          	addi	s4,a0,1
        *tmppath = 0;
 194:	000500a3          	sb	zero,1(a0)
        while (read(fd, &de, sizeof(de)) == sizeof(de))
 198:	4641                	li	a2,16
 19a:	fa040593          	addi	a1,s0,-96
 19e:	8526                	mv	a0,s1
 1a0:	00000097          	auipc	ra,0x0
 1a4:	40e080e7          	jalr	1038(ra) # 5ae <read>
 1a8:	47c1                	li	a5,16
 1aa:	f4f518e3          	bne	a0,a5,fa <find_file+0x4c>
            if (de.inum == 0 || strdot(de.name))
 1ae:	fa045783          	lhu	a5,-96(s0)
 1b2:	d3fd                	beqz	a5,198 <find_file+0xea>
 1b4:	fa240513          	addi	a0,s0,-94
 1b8:	00000097          	auipc	ra,0x0
 1bc:	ebe080e7          	jalr	-322(ra) # 76 <strdot>
 1c0:	fd61                	bnez	a0,198 <find_file+0xea>
            memmove(tmppath, de.name, DIRSIZ);
 1c2:	4639                	li	a2,14
 1c4:	fa240593          	addi	a1,s0,-94
 1c8:	8552                	mv	a0,s4
 1ca:	00000097          	auipc	ra,0x0
 1ce:	30a080e7          	jalr	778(ra) # 4d4 <memmove>
            tmppath += strlen(de.name);
 1d2:	fa240513          	addi	a0,s0,-94
 1d6:	00000097          	auipc	ra,0x0
 1da:	180080e7          	jalr	384(ra) # 356 <strlen>
 1de:	1502                	slli	a0,a0,0x20
 1e0:	9101                	srli	a0,a0,0x20
 1e2:	9a2a                	add	s4,s4,a0
            *tmppath = 0;
 1e4:	000a0023          	sb	zero,0(s4)
            int flag = find_file(path, name);
 1e8:	85d6                	mv	a1,s5
 1ea:	854e                	mv	a0,s3
 1ec:	00000097          	auipc	ra,0x0
 1f0:	ec2080e7          	jalr	-318(ra) # ae <find_file>
 1f4:	892a                	mv	s2,a0
            tmppath -= strlen(de.name);
 1f6:	fa240513          	addi	a0,s0,-94
 1fa:	00000097          	auipc	ra,0x0
 1fe:	15c080e7          	jalr	348(ra) # 356 <strlen>
 202:	1502                	slli	a0,a0,0x20
 204:	9101                	srli	a0,a0,0x20
 206:	40aa0a33          	sub	s4,s4,a0
            *tmppath = 0;
 20a:	000a0023          	sb	zero,0(s4)
            if (flag == 0)
 20e:	f80915e3          	bnez	s2,198 <find_file+0xea>
 212:	bdd5                	j	106 <find_file+0x58>

0000000000000214 <find>:

int find(char *path, char *name)
{
 214:	7131                	addi	sp,sp,-192
 216:	fd06                	sd	ra,184(sp)
 218:	f922                	sd	s0,176(sp)
 21a:	f526                	sd	s1,168(sp)
 21c:	f14a                	sd	s2,160(sp)
 21e:	ed4e                	sd	s3,152(sp)
 220:	0180                	addi	s0,sp,192
 222:	89aa                	mv	s3,a0
 224:	892e                	mv	s2,a1
    char buf[MAXPATH + 1];
    int lenth = strlen(path);
 226:	00000097          	auipc	ra,0x0
 22a:	130080e7          	jalr	304(ra) # 356 <strlen>
 22e:	0005049b          	sext.w	s1,a0
    if (lenth > MAXPATH + 1)
 232:	08100793          	li	a5,129
 236:	0297cd63          	blt	a5,s1,270 <find+0x5c>
    {
        printf("The path is too long!\n");
        return 0;
    }
    memmove(buf, path, lenth);
 23a:	8626                	mv	a2,s1
 23c:	85ce                	mv	a1,s3
 23e:	f4840513          	addi	a0,s0,-184
 242:	00000097          	auipc	ra,0x0
 246:	292080e7          	jalr	658(ra) # 4d4 <memmove>
    *(buf + lenth) = 0;
 24a:	fd040793          	addi	a5,s0,-48
 24e:	94be                	add	s1,s1,a5
 250:	f6048c23          	sb	zero,-136(s1)
    return find_file(buf, name);
 254:	85ca                	mv	a1,s2
 256:	f4840513          	addi	a0,s0,-184
 25a:	00000097          	auipc	ra,0x0
 25e:	e54080e7          	jalr	-428(ra) # ae <find_file>
}
 262:	70ea                	ld	ra,184(sp)
 264:	744a                	ld	s0,176(sp)
 266:	74aa                	ld	s1,168(sp)
 268:	790a                	ld	s2,160(sp)
 26a:	69ea                	ld	s3,152(sp)
 26c:	6129                	addi	sp,sp,192
 26e:	8082                	ret
        printf("The path is too long!\n");
 270:	00001517          	auipc	a0,0x1
 274:	88050513          	addi	a0,a0,-1920 # af0 <malloc+0x122>
 278:	00000097          	auipc	ra,0x0
 27c:	696080e7          	jalr	1686(ra) # 90e <printf>
        return 0;
 280:	4501                	li	a0,0
 282:	b7c5                	j	262 <find+0x4e>

0000000000000284 <main>:

int main(int argc, char *argv[])
{
 284:	1101                	addi	sp,sp,-32
 286:	ec06                	sd	ra,24(sp)
 288:	e822                	sd	s0,16(sp)
 28a:	e426                	sd	s1,8(sp)
 28c:	e04a                	sd	s2,0(sp)
 28e:	1000                	addi	s0,sp,32
    if (argc != 3)
 290:	478d                	li	a5,3
 292:	00f50f63          	beq	a0,a5,2b0 <main+0x2c>
    {
        printf("You need to enter two parameter\n");
 296:	00001517          	auipc	a0,0x1
 29a:	87250513          	addi	a0,a0,-1934 # b08 <malloc+0x13a>
 29e:	00000097          	auipc	ra,0x0
 2a2:	670080e7          	jalr	1648(ra) # 90e <printf>
        exit(0);
 2a6:	4501                	li	a0,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	2ee080e7          	jalr	750(ra) # 596 <exit>
 2b0:	84ae                	mv	s1,a1
    }
    if (strlen(argv[1]) + strlen(argv[2]) > MAXPATH)
 2b2:	6588                	ld	a0,8(a1)
 2b4:	00000097          	auipc	ra,0x0
 2b8:	0a2080e7          	jalr	162(ra) # 356 <strlen>
 2bc:	0005091b          	sext.w	s2,a0
 2c0:	6888                	ld	a0,16(s1)
 2c2:	00000097          	auipc	ra,0x0
 2c6:	094080e7          	jalr	148(ra) # 356 <strlen>
 2ca:	0125053b          	addw	a0,a0,s2
 2ce:	08000793          	li	a5,128
 2d2:	00a7ff63          	bleu	a0,a5,2f0 <main+0x6c>
    {
        printf("The path is too long.");
 2d6:	00001517          	auipc	a0,0x1
 2da:	85a50513          	addi	a0,a0,-1958 # b30 <malloc+0x162>
 2de:	00000097          	auipc	ra,0x0
 2e2:	630080e7          	jalr	1584(ra) # 90e <printf>
        exit(0);
 2e6:	4501                	li	a0,0
 2e8:	00000097          	auipc	ra,0x0
 2ec:	2ae080e7          	jalr	686(ra) # 596 <exit>
    }
    find(argv[1], argv[2]);
 2f0:	688c                	ld	a1,16(s1)
 2f2:	6488                	ld	a0,8(s1)
 2f4:	00000097          	auipc	ra,0x0
 2f8:	f20080e7          	jalr	-224(ra) # 214 <find>
    //printf("end");
    exit(0);
 2fc:	4501                	li	a0,0
 2fe:	00000097          	auipc	ra,0x0
 302:	298080e7          	jalr	664(ra) # 596 <exit>

0000000000000306 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 30c:	87aa                	mv	a5,a0
 30e:	0585                	addi	a1,a1,1
 310:	0785                	addi	a5,a5,1
 312:	fff5c703          	lbu	a4,-1(a1)
 316:	fee78fa3          	sb	a4,-1(a5)
 31a:	fb75                	bnez	a4,30e <strcpy+0x8>
    ;
  return os;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret

0000000000000322 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 322:	1141                	addi	sp,sp,-16
 324:	e422                	sd	s0,8(sp)
 326:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 328:	00054783          	lbu	a5,0(a0)
 32c:	cf91                	beqz	a5,348 <strcmp+0x26>
 32e:	0005c703          	lbu	a4,0(a1)
 332:	00f71b63          	bne	a4,a5,348 <strcmp+0x26>
    p++, q++;
 336:	0505                	addi	a0,a0,1
 338:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 33a:	00054783          	lbu	a5,0(a0)
 33e:	c789                	beqz	a5,348 <strcmp+0x26>
 340:	0005c703          	lbu	a4,0(a1)
 344:	fef709e3          	beq	a4,a5,336 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 348:	0005c503          	lbu	a0,0(a1)
}
 34c:	40a7853b          	subw	a0,a5,a0
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <strlen>:

uint
strlen(const char *s)
{
 356:	1141                	addi	sp,sp,-16
 358:	e422                	sd	s0,8(sp)
 35a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 35c:	00054783          	lbu	a5,0(a0)
 360:	cf91                	beqz	a5,37c <strlen+0x26>
 362:	0505                	addi	a0,a0,1
 364:	87aa                	mv	a5,a0
 366:	4685                	li	a3,1
 368:	9e89                	subw	a3,a3,a0
 36a:	00f6853b          	addw	a0,a3,a5
 36e:	0785                	addi	a5,a5,1
 370:	fff7c703          	lbu	a4,-1(a5)
 374:	fb7d                	bnez	a4,36a <strlen+0x14>
    ;
  return n;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
  for(n = 0; s[n]; n++)
 37c:	4501                	li	a0,0
 37e:	bfe5                	j	376 <strlen+0x20>

0000000000000380 <memset>:

void*
memset(void *dst, int c, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 386:	ce09                	beqz	a2,3a0 <memset+0x20>
 388:	87aa                	mv	a5,a0
 38a:	fff6071b          	addiw	a4,a2,-1
 38e:	1702                	slli	a4,a4,0x20
 390:	9301                	srli	a4,a4,0x20
 392:	0705                	addi	a4,a4,1
 394:	972a                	add	a4,a4,a0
    cdst[i] = c;
 396:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 39a:	0785                	addi	a5,a5,1
 39c:	fee79de3          	bne	a5,a4,396 <memset+0x16>
  }
  return dst;
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret

00000000000003a6 <strchr>:

char*
strchr(const char *s, char c)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e422                	sd	s0,8(sp)
 3aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3ac:	00054783          	lbu	a5,0(a0)
 3b0:	cf91                	beqz	a5,3cc <strchr+0x26>
    if(*s == c)
 3b2:	00f58a63          	beq	a1,a5,3c6 <strchr+0x20>
  for(; *s; s++)
 3b6:	0505                	addi	a0,a0,1
 3b8:	00054783          	lbu	a5,0(a0)
 3bc:	c781                	beqz	a5,3c4 <strchr+0x1e>
    if(*s == c)
 3be:	feb79ce3          	bne	a5,a1,3b6 <strchr+0x10>
 3c2:	a011                	j	3c6 <strchr+0x20>
      return (char*)s;
  return 0;
 3c4:	4501                	li	a0,0
}
 3c6:	6422                	ld	s0,8(sp)
 3c8:	0141                	addi	sp,sp,16
 3ca:	8082                	ret
  return 0;
 3cc:	4501                	li	a0,0
 3ce:	bfe5                	j	3c6 <strchr+0x20>

00000000000003d0 <gets>:

char*
gets(char *buf, int max)
{
 3d0:	711d                	addi	sp,sp,-96
 3d2:	ec86                	sd	ra,88(sp)
 3d4:	e8a2                	sd	s0,80(sp)
 3d6:	e4a6                	sd	s1,72(sp)
 3d8:	e0ca                	sd	s2,64(sp)
 3da:	fc4e                	sd	s3,56(sp)
 3dc:	f852                	sd	s4,48(sp)
 3de:	f456                	sd	s5,40(sp)
 3e0:	f05a                	sd	s6,32(sp)
 3e2:	ec5e                	sd	s7,24(sp)
 3e4:	1080                	addi	s0,sp,96
 3e6:	8baa                	mv	s7,a0
 3e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ea:	892a                	mv	s2,a0
 3ec:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ee:	4aa9                	li	s5,10
 3f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3f2:	0019849b          	addiw	s1,s3,1
 3f6:	0344d863          	ble	s4,s1,426 <gets+0x56>
    cc = read(0, &c, 1);
 3fa:	4605                	li	a2,1
 3fc:	faf40593          	addi	a1,s0,-81
 400:	4501                	li	a0,0
 402:	00000097          	auipc	ra,0x0
 406:	1ac080e7          	jalr	428(ra) # 5ae <read>
    if(cc < 1)
 40a:	00a05e63          	blez	a0,426 <gets+0x56>
    buf[i++] = c;
 40e:	faf44783          	lbu	a5,-81(s0)
 412:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 416:	01578763          	beq	a5,s5,424 <gets+0x54>
 41a:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 41c:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 41e:	fd679ae3          	bne	a5,s6,3f2 <gets+0x22>
 422:	a011                	j	426 <gets+0x56>
  for(i=0; i+1 < max; ){
 424:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 426:	99de                	add	s3,s3,s7
 428:	00098023          	sb	zero,0(s3)
  return buf;
}
 42c:	855e                	mv	a0,s7
 42e:	60e6                	ld	ra,88(sp)
 430:	6446                	ld	s0,80(sp)
 432:	64a6                	ld	s1,72(sp)
 434:	6906                	ld	s2,64(sp)
 436:	79e2                	ld	s3,56(sp)
 438:	7a42                	ld	s4,48(sp)
 43a:	7aa2                	ld	s5,40(sp)
 43c:	7b02                	ld	s6,32(sp)
 43e:	6be2                	ld	s7,24(sp)
 440:	6125                	addi	sp,sp,96
 442:	8082                	ret

0000000000000444 <stat>:

int
stat(const char *n, struct stat *st)
{
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	e426                	sd	s1,8(sp)
 44c:	e04a                	sd	s2,0(sp)
 44e:	1000                	addi	s0,sp,32
 450:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 452:	4581                	li	a1,0
 454:	00000097          	auipc	ra,0x0
 458:	182080e7          	jalr	386(ra) # 5d6 <open>
  if(fd < 0)
 45c:	02054563          	bltz	a0,486 <stat+0x42>
 460:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 462:	85ca                	mv	a1,s2
 464:	00000097          	auipc	ra,0x0
 468:	18a080e7          	jalr	394(ra) # 5ee <fstat>
 46c:	892a                	mv	s2,a0
  close(fd);
 46e:	8526                	mv	a0,s1
 470:	00000097          	auipc	ra,0x0
 474:	14e080e7          	jalr	334(ra) # 5be <close>
  return r;
}
 478:	854a                	mv	a0,s2
 47a:	60e2                	ld	ra,24(sp)
 47c:	6442                	ld	s0,16(sp)
 47e:	64a2                	ld	s1,8(sp)
 480:	6902                	ld	s2,0(sp)
 482:	6105                	addi	sp,sp,32
 484:	8082                	ret
    return -1;
 486:	597d                	li	s2,-1
 488:	bfc5                	j	478 <stat+0x34>

000000000000048a <atoi>:

int
atoi(const char *s)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e422                	sd	s0,8(sp)
 48e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 490:	00054683          	lbu	a3,0(a0)
 494:	fd06879b          	addiw	a5,a3,-48
 498:	0ff7f793          	andi	a5,a5,255
 49c:	4725                	li	a4,9
 49e:	02f76963          	bltu	a4,a5,4d0 <atoi+0x46>
 4a2:	862a                	mv	a2,a0
  n = 0;
 4a4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4a6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4a8:	0605                	addi	a2,a2,1
 4aa:	0025179b          	slliw	a5,a0,0x2
 4ae:	9fa9                	addw	a5,a5,a0
 4b0:	0017979b          	slliw	a5,a5,0x1
 4b4:	9fb5                	addw	a5,a5,a3
 4b6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ba:	00064683          	lbu	a3,0(a2)
 4be:	fd06871b          	addiw	a4,a3,-48
 4c2:	0ff77713          	andi	a4,a4,255
 4c6:	fee5f1e3          	bleu	a4,a1,4a8 <atoi+0x1e>
  return n;
}
 4ca:	6422                	ld	s0,8(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret
  n = 0;
 4d0:	4501                	li	a0,0
 4d2:	bfe5                	j	4ca <atoi+0x40>

00000000000004d4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4d4:	1141                	addi	sp,sp,-16
 4d6:	e422                	sd	s0,8(sp)
 4d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4da:	02b57663          	bleu	a1,a0,506 <memmove+0x32>
    while(n-- > 0)
 4de:	02c05163          	blez	a2,500 <memmove+0x2c>
 4e2:	fff6079b          	addiw	a5,a2,-1
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	0785                	addi	a5,a5,1
 4ec:	97aa                	add	a5,a5,a0
  dst = vdst;
 4ee:	872a                	mv	a4,a0
      *dst++ = *src++;
 4f0:	0585                	addi	a1,a1,1
 4f2:	0705                	addi	a4,a4,1
 4f4:	fff5c683          	lbu	a3,-1(a1)
 4f8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4fc:	fee79ae3          	bne	a5,a4,4f0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 500:	6422                	ld	s0,8(sp)
 502:	0141                	addi	sp,sp,16
 504:	8082                	ret
    dst += n;
 506:	00c50733          	add	a4,a0,a2
    src += n;
 50a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 50c:	fec05ae3          	blez	a2,500 <memmove+0x2c>
 510:	fff6079b          	addiw	a5,a2,-1
 514:	1782                	slli	a5,a5,0x20
 516:	9381                	srli	a5,a5,0x20
 518:	fff7c793          	not	a5,a5
 51c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 51e:	15fd                	addi	a1,a1,-1
 520:	177d                	addi	a4,a4,-1
 522:	0005c683          	lbu	a3,0(a1)
 526:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 52a:	fef71ae3          	bne	a4,a5,51e <memmove+0x4a>
 52e:	bfc9                	j	500 <memmove+0x2c>

0000000000000530 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 530:	1141                	addi	sp,sp,-16
 532:	e422                	sd	s0,8(sp)
 534:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 536:	ce15                	beqz	a2,572 <memcmp+0x42>
 538:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 53c:	00054783          	lbu	a5,0(a0)
 540:	0005c703          	lbu	a4,0(a1)
 544:	02e79063          	bne	a5,a4,564 <memcmp+0x34>
 548:	1682                	slli	a3,a3,0x20
 54a:	9281                	srli	a3,a3,0x20
 54c:	0685                	addi	a3,a3,1
 54e:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 550:	0505                	addi	a0,a0,1
    p2++;
 552:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 554:	00d50d63          	beq	a0,a3,56e <memcmp+0x3e>
    if (*p1 != *p2) {
 558:	00054783          	lbu	a5,0(a0)
 55c:	0005c703          	lbu	a4,0(a1)
 560:	fee788e3          	beq	a5,a4,550 <memcmp+0x20>
      return *p1 - *p2;
 564:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 568:	6422                	ld	s0,8(sp)
 56a:	0141                	addi	sp,sp,16
 56c:	8082                	ret
  return 0;
 56e:	4501                	li	a0,0
 570:	bfe5                	j	568 <memcmp+0x38>
 572:	4501                	li	a0,0
 574:	bfd5                	j	568 <memcmp+0x38>

0000000000000576 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 576:	1141                	addi	sp,sp,-16
 578:	e406                	sd	ra,8(sp)
 57a:	e022                	sd	s0,0(sp)
 57c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 57e:	00000097          	auipc	ra,0x0
 582:	f56080e7          	jalr	-170(ra) # 4d4 <memmove>
}
 586:	60a2                	ld	ra,8(sp)
 588:	6402                	ld	s0,0(sp)
 58a:	0141                	addi	sp,sp,16
 58c:	8082                	ret

000000000000058e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 58e:	4885                	li	a7,1
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <exit>:
.global exit
exit:
 li a7, SYS_exit
 596:	4889                	li	a7,2
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <wait>:
.global wait
wait:
 li a7, SYS_wait
 59e:	488d                	li	a7,3
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5a6:	4891                	li	a7,4
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <read>:
.global read
read:
 li a7, SYS_read
 5ae:	4895                	li	a7,5
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <write>:
.global write
write:
 li a7, SYS_write
 5b6:	48c1                	li	a7,16
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <close>:
.global close
close:
 li a7, SYS_close
 5be:	48d5                	li	a7,21
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5c6:	4899                	li	a7,6
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ce:	489d                	li	a7,7
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <open>:
.global open
open:
 li a7, SYS_open
 5d6:	48bd                	li	a7,15
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5de:	48c5                	li	a7,17
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5e6:	48c9                	li	a7,18
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5ee:	48a1                	li	a7,8
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <link>:
.global link
link:
 li a7, SYS_link
 5f6:	48cd                	li	a7,19
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5fe:	48d1                	li	a7,20
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 606:	48a5                	li	a7,9
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <dup>:
.global dup
dup:
 li a7, SYS_dup
 60e:	48a9                	li	a7,10
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 616:	48ad                	li	a7,11
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 61e:	48b1                	li	a7,12
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 626:	48b5                	li	a7,13
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 62e:	48b9                	li	a7,14
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 636:	1101                	addi	sp,sp,-32
 638:	ec06                	sd	ra,24(sp)
 63a:	e822                	sd	s0,16(sp)
 63c:	1000                	addi	s0,sp,32
 63e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 642:	4605                	li	a2,1
 644:	fef40593          	addi	a1,s0,-17
 648:	00000097          	auipc	ra,0x0
 64c:	f6e080e7          	jalr	-146(ra) # 5b6 <write>
}
 650:	60e2                	ld	ra,24(sp)
 652:	6442                	ld	s0,16(sp)
 654:	6105                	addi	sp,sp,32
 656:	8082                	ret

0000000000000658 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 658:	7139                	addi	sp,sp,-64
 65a:	fc06                	sd	ra,56(sp)
 65c:	f822                	sd	s0,48(sp)
 65e:	f426                	sd	s1,40(sp)
 660:	f04a                	sd	s2,32(sp)
 662:	ec4e                	sd	s3,24(sp)
 664:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 666:	c299                	beqz	a3,66c <printint+0x14>
 668:	0005cd63          	bltz	a1,682 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 66c:	2581                	sext.w	a1,a1
  neg = 0;
 66e:	4301                	li	t1,0
 670:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 674:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 676:	2601                	sext.w	a2,a2
 678:	00000897          	auipc	a7,0x0
 67c:	4d088893          	addi	a7,a7,1232 # b48 <digits>
 680:	a801                	j	690 <printint+0x38>
    x = -xx;
 682:	40b005bb          	negw	a1,a1
 686:	2581                	sext.w	a1,a1
    neg = 1;
 688:	4305                	li	t1,1
    x = -xx;
 68a:	b7dd                	j	670 <printint+0x18>
  }while((x /= base) != 0);
 68c:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 68e:	8836                	mv	a6,a3
 690:	0018069b          	addiw	a3,a6,1
 694:	02c5f7bb          	remuw	a5,a1,a2
 698:	1782                	slli	a5,a5,0x20
 69a:	9381                	srli	a5,a5,0x20
 69c:	97c6                	add	a5,a5,a7
 69e:	0007c783          	lbu	a5,0(a5)
 6a2:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 6a6:	0705                	addi	a4,a4,1
 6a8:	02c5d7bb          	divuw	a5,a1,a2
 6ac:	fec5f0e3          	bleu	a2,a1,68c <printint+0x34>
  if(neg)
 6b0:	00030b63          	beqz	t1,6c6 <printint+0x6e>
    buf[i++] = '-';
 6b4:	fd040793          	addi	a5,s0,-48
 6b8:	96be                	add	a3,a3,a5
 6ba:	02d00793          	li	a5,45
 6be:	fef68823          	sb	a5,-16(a3)
 6c2:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 6c6:	02d05963          	blez	a3,6f8 <printint+0xa0>
 6ca:	89aa                	mv	s3,a0
 6cc:	fc040793          	addi	a5,s0,-64
 6d0:	00d784b3          	add	s1,a5,a3
 6d4:	fff78913          	addi	s2,a5,-1
 6d8:	9936                	add	s2,s2,a3
 6da:	36fd                	addiw	a3,a3,-1
 6dc:	1682                	slli	a3,a3,0x20
 6de:	9281                	srli	a3,a3,0x20
 6e0:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 6e4:	fff4c583          	lbu	a1,-1(s1)
 6e8:	854e                	mv	a0,s3
 6ea:	00000097          	auipc	ra,0x0
 6ee:	f4c080e7          	jalr	-180(ra) # 636 <putc>
  while(--i >= 0)
 6f2:	14fd                	addi	s1,s1,-1
 6f4:	ff2498e3          	bne	s1,s2,6e4 <printint+0x8c>
}
 6f8:	70e2                	ld	ra,56(sp)
 6fa:	7442                	ld	s0,48(sp)
 6fc:	74a2                	ld	s1,40(sp)
 6fe:	7902                	ld	s2,32(sp)
 700:	69e2                	ld	s3,24(sp)
 702:	6121                	addi	sp,sp,64
 704:	8082                	ret

0000000000000706 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 706:	7119                	addi	sp,sp,-128
 708:	fc86                	sd	ra,120(sp)
 70a:	f8a2                	sd	s0,112(sp)
 70c:	f4a6                	sd	s1,104(sp)
 70e:	f0ca                	sd	s2,96(sp)
 710:	ecce                	sd	s3,88(sp)
 712:	e8d2                	sd	s4,80(sp)
 714:	e4d6                	sd	s5,72(sp)
 716:	e0da                	sd	s6,64(sp)
 718:	fc5e                	sd	s7,56(sp)
 71a:	f862                	sd	s8,48(sp)
 71c:	f466                	sd	s9,40(sp)
 71e:	f06a                	sd	s10,32(sp)
 720:	ec6e                	sd	s11,24(sp)
 722:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 724:	0005c483          	lbu	s1,0(a1)
 728:	18048d63          	beqz	s1,8c2 <vprintf+0x1bc>
 72c:	8aaa                	mv	s5,a0
 72e:	8b32                	mv	s6,a2
 730:	00158913          	addi	s2,a1,1
  state = 0;
 734:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 736:	02500a13          	li	s4,37
      if(c == 'd'){
 73a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 73e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 742:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 746:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74a:	00000b97          	auipc	s7,0x0
 74e:	3feb8b93          	addi	s7,s7,1022 # b48 <digits>
 752:	a839                	j	770 <vprintf+0x6a>
        putc(fd, c);
 754:	85a6                	mv	a1,s1
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	ede080e7          	jalr	-290(ra) # 636 <putc>
 760:	a019                	j	766 <vprintf+0x60>
    } else if(state == '%'){
 762:	01498f63          	beq	s3,s4,780 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 766:	0905                	addi	s2,s2,1
 768:	fff94483          	lbu	s1,-1(s2)
 76c:	14048b63          	beqz	s1,8c2 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 770:	0004879b          	sext.w	a5,s1
    if(state == 0){
 774:	fe0997e3          	bnez	s3,762 <vprintf+0x5c>
      if(c == '%'){
 778:	fd479ee3          	bne	a5,s4,754 <vprintf+0x4e>
        state = '%';
 77c:	89be                	mv	s3,a5
 77e:	b7e5                	j	766 <vprintf+0x60>
      if(c == 'd'){
 780:	05878063          	beq	a5,s8,7c0 <vprintf+0xba>
      } else if(c == 'l') {
 784:	05978c63          	beq	a5,s9,7dc <vprintf+0xd6>
      } else if(c == 'x') {
 788:	07a78863          	beq	a5,s10,7f8 <vprintf+0xf2>
      } else if(c == 'p') {
 78c:	09b78463          	beq	a5,s11,814 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 790:	07300713          	li	a4,115
 794:	0ce78563          	beq	a5,a4,85e <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 798:	06300713          	li	a4,99
 79c:	0ee78c63          	beq	a5,a4,894 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7a0:	11478663          	beq	a5,s4,8ac <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a4:	85d2                	mv	a1,s4
 7a6:	8556                	mv	a0,s5
 7a8:	00000097          	auipc	ra,0x0
 7ac:	e8e080e7          	jalr	-370(ra) # 636 <putc>
        putc(fd, c);
 7b0:	85a6                	mv	a1,s1
 7b2:	8556                	mv	a0,s5
 7b4:	00000097          	auipc	ra,0x0
 7b8:	e82080e7          	jalr	-382(ra) # 636 <putc>
      }
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b765                	j	766 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7c0:	008b0493          	addi	s1,s6,8
 7c4:	4685                	li	a3,1
 7c6:	4629                	li	a2,10
 7c8:	000b2583          	lw	a1,0(s6)
 7cc:	8556                	mv	a0,s5
 7ce:	00000097          	auipc	ra,0x0
 7d2:	e8a080e7          	jalr	-374(ra) # 658 <printint>
 7d6:	8b26                	mv	s6,s1
      state = 0;
 7d8:	4981                	li	s3,0
 7da:	b771                	j	766 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7dc:	008b0493          	addi	s1,s6,8
 7e0:	4681                	li	a3,0
 7e2:	4629                	li	a2,10
 7e4:	000b2583          	lw	a1,0(s6)
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e6e080e7          	jalr	-402(ra) # 658 <printint>
 7f2:	8b26                	mv	s6,s1
      state = 0;
 7f4:	4981                	li	s3,0
 7f6:	bf85                	j	766 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7f8:	008b0493          	addi	s1,s6,8
 7fc:	4681                	li	a3,0
 7fe:	4641                	li	a2,16
 800:	000b2583          	lw	a1,0(s6)
 804:	8556                	mv	a0,s5
 806:	00000097          	auipc	ra,0x0
 80a:	e52080e7          	jalr	-430(ra) # 658 <printint>
 80e:	8b26                	mv	s6,s1
      state = 0;
 810:	4981                	li	s3,0
 812:	bf91                	j	766 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 814:	008b0793          	addi	a5,s6,8
 818:	f8f43423          	sd	a5,-120(s0)
 81c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 820:	03000593          	li	a1,48
 824:	8556                	mv	a0,s5
 826:	00000097          	auipc	ra,0x0
 82a:	e10080e7          	jalr	-496(ra) # 636 <putc>
  putc(fd, 'x');
 82e:	85ea                	mv	a1,s10
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	e04080e7          	jalr	-508(ra) # 636 <putc>
 83a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 83c:	03c9d793          	srli	a5,s3,0x3c
 840:	97de                	add	a5,a5,s7
 842:	0007c583          	lbu	a1,0(a5)
 846:	8556                	mv	a0,s5
 848:	00000097          	auipc	ra,0x0
 84c:	dee080e7          	jalr	-530(ra) # 636 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 850:	0992                	slli	s3,s3,0x4
 852:	34fd                	addiw	s1,s1,-1
 854:	f4e5                	bnez	s1,83c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 856:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 85a:	4981                	li	s3,0
 85c:	b729                	j	766 <vprintf+0x60>
        s = va_arg(ap, char*);
 85e:	008b0993          	addi	s3,s6,8
 862:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 866:	c085                	beqz	s1,886 <vprintf+0x180>
        while(*s != 0){
 868:	0004c583          	lbu	a1,0(s1)
 86c:	c9a1                	beqz	a1,8bc <vprintf+0x1b6>
          putc(fd, *s);
 86e:	8556                	mv	a0,s5
 870:	00000097          	auipc	ra,0x0
 874:	dc6080e7          	jalr	-570(ra) # 636 <putc>
          s++;
 878:	0485                	addi	s1,s1,1
        while(*s != 0){
 87a:	0004c583          	lbu	a1,0(s1)
 87e:	f9e5                	bnez	a1,86e <vprintf+0x168>
        s = va_arg(ap, char*);
 880:	8b4e                	mv	s6,s3
      state = 0;
 882:	4981                	li	s3,0
 884:	b5cd                	j	766 <vprintf+0x60>
          s = "(null)";
 886:	00000497          	auipc	s1,0x0
 88a:	2da48493          	addi	s1,s1,730 # b60 <digits+0x18>
        while(*s != 0){
 88e:	02800593          	li	a1,40
 892:	bff1                	j	86e <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 894:	008b0493          	addi	s1,s6,8
 898:	000b4583          	lbu	a1,0(s6)
 89c:	8556                	mv	a0,s5
 89e:	00000097          	auipc	ra,0x0
 8a2:	d98080e7          	jalr	-616(ra) # 636 <putc>
 8a6:	8b26                	mv	s6,s1
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	bd75                	j	766 <vprintf+0x60>
        putc(fd, c);
 8ac:	85d2                	mv	a1,s4
 8ae:	8556                	mv	a0,s5
 8b0:	00000097          	auipc	ra,0x0
 8b4:	d86080e7          	jalr	-634(ra) # 636 <putc>
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	b575                	j	766 <vprintf+0x60>
        s = va_arg(ap, char*);
 8bc:	8b4e                	mv	s6,s3
      state = 0;
 8be:	4981                	li	s3,0
 8c0:	b55d                	j	766 <vprintf+0x60>
    }
  }
}
 8c2:	70e6                	ld	ra,120(sp)
 8c4:	7446                	ld	s0,112(sp)
 8c6:	74a6                	ld	s1,104(sp)
 8c8:	7906                	ld	s2,96(sp)
 8ca:	69e6                	ld	s3,88(sp)
 8cc:	6a46                	ld	s4,80(sp)
 8ce:	6aa6                	ld	s5,72(sp)
 8d0:	6b06                	ld	s6,64(sp)
 8d2:	7be2                	ld	s7,56(sp)
 8d4:	7c42                	ld	s8,48(sp)
 8d6:	7ca2                	ld	s9,40(sp)
 8d8:	7d02                	ld	s10,32(sp)
 8da:	6de2                	ld	s11,24(sp)
 8dc:	6109                	addi	sp,sp,128
 8de:	8082                	ret

00000000000008e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8e0:	715d                	addi	sp,sp,-80
 8e2:	ec06                	sd	ra,24(sp)
 8e4:	e822                	sd	s0,16(sp)
 8e6:	1000                	addi	s0,sp,32
 8e8:	e010                	sd	a2,0(s0)
 8ea:	e414                	sd	a3,8(s0)
 8ec:	e818                	sd	a4,16(s0)
 8ee:	ec1c                	sd	a5,24(s0)
 8f0:	03043023          	sd	a6,32(s0)
 8f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8fc:	8622                	mv	a2,s0
 8fe:	00000097          	auipc	ra,0x0
 902:	e08080e7          	jalr	-504(ra) # 706 <vprintf>
}
 906:	60e2                	ld	ra,24(sp)
 908:	6442                	ld	s0,16(sp)
 90a:	6161                	addi	sp,sp,80
 90c:	8082                	ret

000000000000090e <printf>:

void
printf(const char *fmt, ...)
{
 90e:	711d                	addi	sp,sp,-96
 910:	ec06                	sd	ra,24(sp)
 912:	e822                	sd	s0,16(sp)
 914:	1000                	addi	s0,sp,32
 916:	e40c                	sd	a1,8(s0)
 918:	e810                	sd	a2,16(s0)
 91a:	ec14                	sd	a3,24(s0)
 91c:	f018                	sd	a4,32(s0)
 91e:	f41c                	sd	a5,40(s0)
 920:	03043823          	sd	a6,48(s0)
 924:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 928:	00840613          	addi	a2,s0,8
 92c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 930:	85aa                	mv	a1,a0
 932:	4505                	li	a0,1
 934:	00000097          	auipc	ra,0x0
 938:	dd2080e7          	jalr	-558(ra) # 706 <vprintf>
}
 93c:	60e2                	ld	ra,24(sp)
 93e:	6442                	ld	s0,16(sp)
 940:	6125                	addi	sp,sp,96
 942:	8082                	ret

0000000000000944 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 944:	1141                	addi	sp,sp,-16
 946:	e422                	sd	s0,8(sp)
 948:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 94a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 94e:	00000797          	auipc	a5,0x0
 952:	21a78793          	addi	a5,a5,538 # b68 <__bss_start>
 956:	639c                	ld	a5,0(a5)
 958:	a805                	j	988 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 95a:	4618                	lw	a4,8(a2)
 95c:	9db9                	addw	a1,a1,a4
 95e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 962:	6398                	ld	a4,0(a5)
 964:	6318                	ld	a4,0(a4)
 966:	fee53823          	sd	a4,-16(a0)
 96a:	a091                	j	9ae <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 96c:	ff852703          	lw	a4,-8(a0)
 970:	9e39                	addw	a2,a2,a4
 972:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 974:	ff053703          	ld	a4,-16(a0)
 978:	e398                	sd	a4,0(a5)
 97a:	a099                	j	9c0 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97c:	6398                	ld	a4,0(a5)
 97e:	00e7e463          	bltu	a5,a4,986 <free+0x42>
 982:	00e6ea63          	bltu	a3,a4,996 <free+0x52>
{
 986:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 988:	fed7fae3          	bleu	a3,a5,97c <free+0x38>
 98c:	6398                	ld	a4,0(a5)
 98e:	00e6e463          	bltu	a3,a4,996 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 992:	fee7eae3          	bltu	a5,a4,986 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 996:	ff852583          	lw	a1,-8(a0)
 99a:	6390                	ld	a2,0(a5)
 99c:	02059713          	slli	a4,a1,0x20
 9a0:	9301                	srli	a4,a4,0x20
 9a2:	0712                	slli	a4,a4,0x4
 9a4:	9736                	add	a4,a4,a3
 9a6:	fae60ae3          	beq	a2,a4,95a <free+0x16>
    bp->s.ptr = p->s.ptr;
 9aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9ae:	4790                	lw	a2,8(a5)
 9b0:	02061713          	slli	a4,a2,0x20
 9b4:	9301                	srli	a4,a4,0x20
 9b6:	0712                	slli	a4,a4,0x4
 9b8:	973e                	add	a4,a4,a5
 9ba:	fae689e3          	beq	a3,a4,96c <free+0x28>
  } else
    p->s.ptr = bp;
 9be:	e394                	sd	a3,0(a5)
  freep = p;
 9c0:	00000717          	auipc	a4,0x0
 9c4:	1af73423          	sd	a5,424(a4) # b68 <__bss_start>
}
 9c8:	6422                	ld	s0,8(sp)
 9ca:	0141                	addi	sp,sp,16
 9cc:	8082                	ret

00000000000009ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9ce:	7139                	addi	sp,sp,-64
 9d0:	fc06                	sd	ra,56(sp)
 9d2:	f822                	sd	s0,48(sp)
 9d4:	f426                	sd	s1,40(sp)
 9d6:	f04a                	sd	s2,32(sp)
 9d8:	ec4e                	sd	s3,24(sp)
 9da:	e852                	sd	s4,16(sp)
 9dc:	e456                	sd	s5,8(sp)
 9de:	e05a                	sd	s6,0(sp)
 9e0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9e2:	02051993          	slli	s3,a0,0x20
 9e6:	0209d993          	srli	s3,s3,0x20
 9ea:	09bd                	addi	s3,s3,15
 9ec:	0049d993          	srli	s3,s3,0x4
 9f0:	2985                	addiw	s3,s3,1
 9f2:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 9f6:	00000797          	auipc	a5,0x0
 9fa:	17278793          	addi	a5,a5,370 # b68 <__bss_start>
 9fe:	6388                	ld	a0,0(a5)
 a00:	c515                	beqz	a0,a2c <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a02:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a04:	4798                	lw	a4,8(a5)
 a06:	03277f63          	bleu	s2,a4,a44 <malloc+0x76>
 a0a:	8a4e                	mv	s4,s3
 a0c:	0009871b          	sext.w	a4,s3
 a10:	6685                	lui	a3,0x1
 a12:	00d77363          	bleu	a3,a4,a18 <malloc+0x4a>
 a16:	6a05                	lui	s4,0x1
 a18:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 a1c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a20:	00000497          	auipc	s1,0x0
 a24:	14848493          	addi	s1,s1,328 # b68 <__bss_start>
  if(p == (char*)-1)
 a28:	5b7d                	li	s6,-1
 a2a:	a885                	j	a9a <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 a2c:	00000797          	auipc	a5,0x0
 a30:	14478793          	addi	a5,a5,324 # b70 <base>
 a34:	00000717          	auipc	a4,0x0
 a38:	12f73a23          	sd	a5,308(a4) # b68 <__bss_start>
 a3c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a3e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a42:	b7e1                	j	a0a <malloc+0x3c>
      if(p->s.size == nunits)
 a44:	02e90b63          	beq	s2,a4,a7a <malloc+0xac>
        p->s.size -= nunits;
 a48:	4137073b          	subw	a4,a4,s3
 a4c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a4e:	1702                	slli	a4,a4,0x20
 a50:	9301                	srli	a4,a4,0x20
 a52:	0712                	slli	a4,a4,0x4
 a54:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a56:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a5a:	00000717          	auipc	a4,0x0
 a5e:	10a73723          	sd	a0,270(a4) # b68 <__bss_start>
      return (void*)(p + 1);
 a62:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a66:	70e2                	ld	ra,56(sp)
 a68:	7442                	ld	s0,48(sp)
 a6a:	74a2                	ld	s1,40(sp)
 a6c:	7902                	ld	s2,32(sp)
 a6e:	69e2                	ld	s3,24(sp)
 a70:	6a42                	ld	s4,16(sp)
 a72:	6aa2                	ld	s5,8(sp)
 a74:	6b02                	ld	s6,0(sp)
 a76:	6121                	addi	sp,sp,64
 a78:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a7a:	6398                	ld	a4,0(a5)
 a7c:	e118                	sd	a4,0(a0)
 a7e:	bff1                	j	a5a <malloc+0x8c>
  hp->s.size = nu;
 a80:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 a84:	0541                	addi	a0,a0,16
 a86:	00000097          	auipc	ra,0x0
 a8a:	ebe080e7          	jalr	-322(ra) # 944 <free>
  return freep;
 a8e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 a90:	d979                	beqz	a0,a66 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a92:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a94:	4798                	lw	a4,8(a5)
 a96:	fb2777e3          	bleu	s2,a4,a44 <malloc+0x76>
    if(p == freep)
 a9a:	6098                	ld	a4,0(s1)
 a9c:	853e                	mv	a0,a5
 a9e:	fef71ae3          	bne	a4,a5,a92 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 aa2:	8552                	mv	a0,s4
 aa4:	00000097          	auipc	ra,0x0
 aa8:	b7a080e7          	jalr	-1158(ra) # 61e <sbrk>
  if(p == (char*)-1)
 aac:	fd651ae3          	bne	a0,s6,a80 <malloc+0xb2>
        return 0;
 ab0:	4501                	li	a0,0
 ab2:	bf55                	j	a66 <malloc+0x98>
