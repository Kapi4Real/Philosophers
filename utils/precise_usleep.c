#include "../philosophers.h"

void precise_usleep(long milliseconds)
{
    long start;
    long current;

    start = get_time();
    while (1)
    {
        current = get_time();
        if (current - start >= milliseconds)
            break;
        usleep(500);
    }
}
