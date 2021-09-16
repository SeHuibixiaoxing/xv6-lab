#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int p1[2], p2[2];
    pipe(p1);
    pipe(p2);

    if (fork() == 0)
    {
        char str[5];
        read(p1[0], str, 4);
        str[4] = '\0';
        printf("%d: received %s\n", getpid(), str);
        write(p2[1], "pong", 4);
    }
    else
    {
        write(p1[1], "ping", 4);
        char str[5];
        read(p2[0], str, 4);
        str[4] = '\0';
        printf("%d: received %s\n", getpid(), str);
    }

    exit(0);
}
