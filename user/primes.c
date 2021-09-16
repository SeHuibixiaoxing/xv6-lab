#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

//p管道用于存放已经被求得的素数筛过的管道，它将在使用当前求得的最大素数筛选的过程中被写入
void find_prime(int *p)
{
    //从管道中读取第一个数为素数
    int prime = 0;
    int read_re = read(p[0], &prime, sizeof(prime));

    //如果写通道被关闭，说明没有数可被写入，算法结束
    if (read_re == 0)
    {
        close(p[1]);
        close(p[0]);
        return;
    }
    printf("prime %d\n", prime);

    //为使用prime筛选的线程分配管道
    int new_p[2];
    pipe(new_p);

    int pid = fork();

    if (pid == 0)
    {
        //子进程，递归地筛选，new_p存放被prime及其之前素数筛过的数
        close(new_p[1]);
        find_prime(new_p);
        exit(0);
    }
    else
    {
        close(new_p[0]);
        //从管道p读数，用prime筛，直到读完
        int re = -1;
        while (1)
        {
            int number;
            re = read(p[0], &number, sizeof(number));
            if (re == 0)
                break;
            if (number % prime != 0)
                write(new_p[1], &number, sizeof(number));
        };

        close(new_p[1]);

        int wait_pid = -1;
        do
        {
            wait_pid = wait(0);
        } while (pid != wait_pid);
        wait(0);

        close(p[0]);
    }

    return;
}

int main(int argc, char *argv[])
{
    // 创建初始管道
    int p[2];
    pipe(p);
    int max_n = 35;
    //写入数据
    for (int i = 2; i <= max_n; ++i)
        write(p[1], &i, sizeof(int));
    //关闭写描述符
    close(p[1]);
    //递归地筛素数
    find_prime(p);
    exit(0);
}
