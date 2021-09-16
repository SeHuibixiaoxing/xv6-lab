#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"

void getname(char *path, char *name)
{
    char *p;
    for (p = path + strlen(path); p >= path && *p != '/'; --p)
        ;

    ++p;
    //printf("[p]:%s\n", p);
    int namelen = strlen(p);
    memmove(name, p, namelen);
    name[namelen] = 0;
}

int strdot(char *str)
{
    if (str[0] == '.' && str[1] == 0)
        return 1;
    if (str[0] == '.' && str[1] == '.' && str[2] == 0)
        return 1;
    return 0;
}

int find_file(char *path, char *name)
{
    //printf("[path]:%s\n", path);

    char buf[DIRSIZ + 1];
    int fd = open(path, 0);
    struct dirent de;
    char *tmppath;
    if (fd < 0)
    {
        printf("Can't open file %s\n", path);
        return 0;
    }

    struct stat st;
    if (fstat(fd, &st) < 0)
    {
        printf("Can't get the stat of %s\n", path);
        return 0;
    }
    //printf("type:%d\n", st.type);
    if (st.type == T_FILE)
    {
        getname(path, buf);
        //printf("[path name]:%s, [path]:%s\n", buf, path);
        if (strcmp(buf, name) == 0)
            printf("%s\n", path);
    }
    else if (st.type == T_DIR)
    {
        tmppath = path + strlen(path);
        *tmppath = '/';
        ++tmppath;
        *tmppath = 0;
        while (read(fd, &de, sizeof(de)) == sizeof(de))
        {
            if (de.inum == 0 || strdot(de.name))
            {
                continue;
            }
            //printf("[de.name]:%s;[path]:%s\n", de.name, path);
            memmove(tmppath, de.name, DIRSIZ);
            tmppath += strlen(de.name);
            *tmppath = 0;
            int flag = find_file(path, name);
            tmppath -= strlen(de.name);
            *tmppath = 0;
            if (flag == 0)
            {
                return 0;
            }
        }
    }
    // printf("return\n");
    close(fd);
    return 1;
}

int find(char *path, char *name)
{
    char buf[MAXPATH + 1];
    int lenth = strlen(path);
    if (lenth > MAXPATH + 1)
    {
        printf("The path is too long!\n");
        return 0;
    }
    memmove(buf, path, lenth);
    *(buf + lenth) = 0;
    return find_file(buf, name);
}

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        printf("You need to enter two parameter\n");
        exit(0);
    }
    if (strlen(argv[1]) + strlen(argv[2]) > MAXPATH)
    {
        printf("The path is too long.");
        exit(0);
    }
    find(argv[1], argv[2]);
    //printf("end");
    exit(0);
}

/*
echo > b
mkdir a
echo > a/b
find . b
*/
