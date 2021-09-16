#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc == 0)
    {
        printf("You need to enter a parameter for hte sleep commadn\n");
        exit(0);
    }

    long long times = 0;

    for (int i = 0; i < argc; ++i)
    {
        if ((long long)argv[1][i] >= (long long)'0' && (long long)argv[1][i] <= (long long)'9')
        {
            times = times * 10 + (long long)argv[1][i] - '0';
        }
        else
        {
            printf("You need to enter a integer.\n");
            exit(0);
        }
    }

    sleep(times);

    exit(0);
}
