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
