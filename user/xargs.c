#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/param.h"

void run(char *argv[])
{
    // for (int i = 0; argv[i] != 0; ++i)
    // {
    //     printf("%s\n", argv[i]);
    // }
    int pid = fork();
    if (pid == 0)
    {
        exec(argv[0], argv);
    }
    else
    {
        wait(0);
    }
    return;
}

int main(int argc, char *argv[])
{
    int p[2];
    pipe(p);

    char *newargv[MAXARG];
    int newargc = argc - 1;

    if (argc > MAXARG)
    {
        printf("Too many arguments !\n");
        exit(0);
    }

    memset(newargv, 0, sizeof(newargv));

    for (int i = 0; i < argc - 1; ++i)
        newargv[i] = argv[i + 1];

    char buf[512];
    char *end = buf;
    newargv[newargc++] = buf;
    memset(buf, 0, sizeof(buf));

    int runflag = 1;

    while (read(0, end, 1) == 1)
    {
        // printf("%s\n", buf);
        if (*end == '\n')
        {
            *end = 0;
            run(newargv);
            runflag = 0;
            memset(buf, 0, sizeof(buf));
            end = buf;
        }
        else
        {
            ++end;
        }
    }
    if (end != buf)
    {
        ++end;
        *end = 0;
        run(newargv);
        runflag = 0;
    }

    if (runflag)
        run(newargv);

    exit(0);
}

/*
echo hello too | xargs echo bye

*/