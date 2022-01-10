#include <time.h>

#ifndef TIME
#define TIME 0
#endif

time_t time(time_t *tloc)
{
	time_t ret = TIME;

	if (tloc)
	{
		*tloc = ret;
	}
	return ret;
}

int clock_gettime(clockid_t clk_id, struct timespec *tp){
	tp->tv_sec = TIME;
	return 0;
}

