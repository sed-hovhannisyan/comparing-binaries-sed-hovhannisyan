#include <stdio.h>

extern long add(long, long);

int main(void)
{
    long answer = add(20, 22);

    printf("%ld\n", answer);
    return 0;
}
